# frozen_string_literal: true

require 'aws-sdk-bedrockruntime'
require 'mini_magick'
require 'base64'

module AltText
  class Client
    def initialize(access_key:, secret_key:, region:)
      @client = Aws::BedrockRuntime::Client.new(
        access_key_id: access_key,
        secret_access_key: secret_key,
        region: region
      )
    end

    def process_image(image_path, prompt:, model_id:)
      model_id = AltText::LLMRegistry.resolve(model_id)
      tmp_image = resize_if_needed(image_path)

      encoded_image = Base64.strict_encode64(File.binread(tmp_image))
      File.delete(tmp_image) if tmp_image != image_path

      payload = {
        messages: [
          { role: 'user',
            content: [
              { type: 'image',
                source:
                  { type: 'base64',
                    media_type: 'image/jpeg',
                    data: encoded_image } },
              { type: 'text',
                text: prompt }
            ] }
        ],
        max_tokens: 10_000,
        anthropic_version: 'bedrock-2023-05-31'
      }

      response = @client.invoke_model(model_id: model_id,
                                      content_type: 'application/json',
                                      body: payload.to_json)
      JSON.parse(response.body.read)['content'][0]['text']
    end

    private

      def resize_if_needed(file)
        if File.size(file) < 4_000_000
          file
        else
          tmp_image_path = "#{filepath}_tmp_#{SecureRandom.hex}.png"
          image = MiniMagick::Image.open(file)
          image.resize '800x'
          image.write tmp_image_path
          tmp_image_path
        end
      end
  end
end
