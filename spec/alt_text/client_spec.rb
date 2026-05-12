# frozen_string_literal: true

require 'spec_helper'
require 'alt_text/client'
require 'alt_text/llm_registry'
require 'securerandom'

RSpec.describe AltText::Client do
  let(:access_key) { 'test-access-key' }
  let(:secret_key) { 'test-secret-key' }
  let(:region) { 'us-east-1' }
  let(:mocked_bedrock_client) { instance_double(Aws::BedrockRuntime::Client) }
  let(:client) do
    described_class.new(access_key: access_key,
                        secret_key: secret_key,
                        region: region)
  end

  before do
    allow(Aws::BedrockRuntime::Client).to receive(:new).with(
      access_key_id: access_key,
      secret_access_key: secret_key,
      region: region
    ).and_return(mocked_bedrock_client)
  end

  describe '#process_image' do
    let(:image_path) { 'spec/fixtures/penn-state-shield.jpg' }
    let(:prompt) { 'Generate alt text from this image.' }
    let(:model_id) { 'default' }
    let(:mock_response) do
      content_block = instance_double(Aws::BedrockRuntime::Types::ContentBlock, text: 'alt text')
      message = instance_double(Aws::BedrockRuntime::Types::Message, content: [content_block])
      output = instance_double(Aws::BedrockRuntime::Types::ConverseOutput, message: message)

      instance_double(Aws::BedrockRuntime::Types::ConverseResponse, output: output)
    end
    let(:format) { 'jpeg' }

    before do
      allow(mocked_bedrock_client).to receive(:converse).with(
        model_id: AltText::LLMRegistry.resolve(model_id),
        messages: [
          {
            role: 'user',
            content: [
              {
                image: {
                  format: format,
                  source: {
                    bytes: File.binread(image_path)
                  }
                }
              },
              {
                text: prompt
              }
            ]
          }
        ],
        inference_config: { temperature: 0.0 }
      ).and_return(mock_response)
    end

    context 'when uploaded image is a jpeg' do
      it 'returns the alt text from the model response' do
        result = client.process_image(image_path, prompt: prompt, model_id: model_id)
        expect(result).to eq('alt text')
      end
    end

    context 'when uploaded image is a png' do
      let(:image_path) { 'spec/fixtures/penn-state-shield.png' }
      let(:format) { 'png' }

      it 'returns the alt text from the model response' do
        result = client.process_image(image_path, prompt: prompt, model_id: model_id)
        expect(result).to eq('alt text')
      end
    end

    context 'when uploaded image is an unsupported format' do
      let(:image_path) { 'spec/fixtures/penn-state-shield.jpg.pdf' }
      let(:format) { 'pdf' }

      it 'raises an error' do
        expect {
          client.process_image(image_path, prompt: prompt, model_id: model_id)
        }.to raise_error(ArgumentError, /Unsupported image type: application\/pdf/)
      end
    end

    context 'when an error occurs' do
      before do
        allow(mocked_bedrock_client).to receive(:converse).with(
          model_id: AltText::LLMRegistry.resolve(model_id),
          messages: anything,
          inference_config: anything
        ).and_raise('error')
      end

      it 'raises an error' do
        expect {
          client.process_image(image_path, prompt: prompt, model_id: model_id)
        }.to raise_error('error')
      end
    end

    context 'when temperature configuration' do
      it 'passes the temperature to the converse call' do
        allow(mocked_bedrock_client).to receive(:converse).with(
          model_id: AltText::LLMRegistry.resolve(model_id),
          messages: anything,
          inference_config: { temperature: 0.7 }
        ).and_return(mock_response)

        result = client.process_image(image_path, prompt: prompt, model_id: model_id, temperature: 0.7)
        expect(result).to eq('alt text')
      end

      it 'defaults temperature to 0.0' do
        allow(mocked_bedrock_client).to receive(:converse).with(
          model_id: AltText::LLMRegistry.resolve(model_id),
          messages: anything,
          inference_config: { temperature: 0.0 }
        ).and_return(mock_response)

        result = client.process_image(image_path, prompt: prompt, model_id: model_id)
        expect(result).to eq('alt text')
      end
    end
  end

  describe '#resize_if_needed' do
    let(:image_path) { 'spec/fixtures/penn-state-shield.jpg' }

    context 'when the image is < 4MB' do
      before do
        allow(File).to receive(:size).with(image_path).and_return(1000)
      end

      it 'returns the original file' do
        expect(client.send(:resize_if_needed, image_path)).to eq(image_path)
      end
    end

    context 'when the image is >= 4MB' do
      before do
        allow(File).to receive(:size).with(image_path).and_return(5_000_000)
      end

      it 'returns a tempfile' do
        tempfile = client.send(:resize_if_needed, image_path)
        tempfile_path = tempfile.path
        expect(tempfile).to be_a(Tempfile)
        expect(tempfile_path).to match(/_tmp\.jpg.*/)
        tempfile.close!
        expect(File).not_to exist(tempfile_path)
      end
    end
  end
end
