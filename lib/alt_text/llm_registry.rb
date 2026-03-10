# frozen_string_literal: true

module AltText
  # Notice: Bedrock models are updated frequently.
  # This registry will likely change in the near future.
  # The ruby AWS Bedrock SDK's converse method supports these models.
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
