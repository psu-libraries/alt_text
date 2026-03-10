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

      image_bytes = File.binread(tmp_image)
      tmp_image.close! if tmp_image.is_a?(Tempfile)

      messages = [
        {
          role: 'user',
          content: [
            {
              image: {
                format: 'jpeg',
                source: {
                  bytes: image_bytes
                }
              }
            },
            {
              text: prompt
            }
          ]
        }
      ]

      # The `converse` method of the Bedrock Ruby SDK is used to interact with
      # LLM models in a standardized way, using a "messages" schema that supports
      # text, images, and tool calls. Unlike `invoke_model`, which requires
      # model-specific payloads, `converse` abstracts the input format so the
      # same structure can be used across multiple models.
      #
      # Examples of supported models:
      #   - Amazon Nova Pro (supports text and images)
      #   - Amazon Nova Lite (supports text and images)
      #   - Anthropic Claude / Opus (supports text and images)
      response = @client.converse(model_id: model_id,
                                  messages: messages)

      response.output.message.content.first.text
    end

    private

      def resize_if_needed(file)
        if File.size(file) < 4_000_000
          file
        else
          tmp = Tempfile.new("#{file}_tmp.jpg")
          image = MiniMagick::Image.open(file)
          image.resize '800x'
          image.write tmp.path
          tmp
        end
      end
  end
end
