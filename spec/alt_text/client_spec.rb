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
      instance_double(Aws::BedrockRuntime::Types::InvokeModelResponse,
                      body: StringIO.new({ content: [{ text: 'alt text' }] }.to_json))
    end

    before do
      allow(mocked_bedrock_client).to receive(:invoke_model).and_return(mock_response)
    end

    context 'when no error occurs' do
      it 'returns the alt text from the model response' do
        result = client.process_image(image_path, prompt: prompt, model_id: model_id)
        expect(result).to eq('alt text')
      end
    end

    context 'when an error occurs' do
      before do
        allow(mocked_bedrock_client).to receive(:invoke_model).and_raise('error')
      end

      it 'raises an error' do
        expect {
          client.process_image(image_path, prompt: prompt, model_id: model_id)
        }.to raise_error('error')
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
