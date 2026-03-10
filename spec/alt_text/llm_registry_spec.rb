# frozen_string_literal: true

require 'spec_helper'
require 'alt_text/llm_registry'

RSpec.describe AltText::LLMRegistry do
  describe '.resolve' do
    it 'returns the correct model id for a valid key' do
      expect(described_class.resolve('default')).to eq('us.amazon.nova-pro-v1:0')
      expect(described_class.resolve('sonnet4.5')).to eq('anthropic.claude-sonnet-4-5')
      expect(described_class.resolve('novalite')).to eq('amazon.nova-lite-v1:0')
      expect(described_class.resolve('novapro')).to eq('us.amazon.nova-pro-v1:0')
    end

    it 'raises ArgumentError for an unsupported key' do
      expect { described_class.resolve('unknown') }.to raise_error(ArgumentError, /Unsupported LLM: unknown/)
    end
  end

  describe '.available' do
    it 'returns all available keys' do
      expect(described_class.available).to contain_exactly('default', 'sonnet4.5', 'novalite', 'novapro')
    end
  end
end
