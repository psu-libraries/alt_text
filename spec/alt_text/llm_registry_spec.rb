# frozen_string_literal: true

require 'spec_helper'
require 'alt_text/llm_registry'

RSpec.describe AltText::LLMRegistry do
  describe '.resolve' do
    it 'returns the correct model id for a valid key' do
      expect(described_class.resolve('default')).to eq('anthropic.claude-3-5-sonnet-20240620-v1:0')
      expect(described_class.resolve('sonnet3.51')).to eq('anthropic.claude-3-5-sonnet-20240620-v1:0')
      expect(described_class.resolve('sonnet3.52')).to eq('anthropic.claude-3-5-sonnet-20241022-v2:0')
      expect(described_class.resolve('sonnet3.571')).to eq('us.anthropic.claude-3-7-sonnet-20250219-v1:0')
      expect(described_class.resolve('novapro')).to eq('us.amazon.nova-pro-v1:0')
    end

    it 'raises ArgumentError for an unsupported key' do
      expect { described_class.resolve('unknown') }.to raise_error(ArgumentError, /Unsupported LLM: unknown/)
    end
  end

  describe '.available' do
    it 'returns all available keys' do
      expect(described_class.available).to contain_exactly('default', 'sonnet3.51', 'sonnet3.52', 'sonnet3.571',
                                                           'novapro')
    end
  end
end
