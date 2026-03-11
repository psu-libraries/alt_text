# frozen_string_literal: true

module AltText
  # Bedrock model IDs evolve over time, so this mapping is intentionally
  # centralized and easy to update as models are added, renamed, or retired.
  # Entries here are expected to work with the Bedrock Ruby SDK `converse` API.
  class LLMRegistry
    LLM_MAP = {
      'default' => 'us.amazon.nova-pro-v1:0',
      'novalite' => 'amazon.nova-lite-v1:0',
      'sonnet4.5' => 'anthropic.claude-sonnet-4-5',
      'novapro' => 'us.amazon.nova-pro-v1:0'
    }.freeze

    def self.resolve(key)
      LLM_MAP[key] or raise ArgumentError, "Unsupported LLM: #{key}"
    end

    def self.available
      LLM_MAP.keys
    end
  end
end
