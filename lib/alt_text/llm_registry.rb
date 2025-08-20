# frozen_string_literal: true

module AltText
  class LLMRegistry
    LLM_MAP = {
      'default' => 'anthropic.claude-3-5-sonnet-20240620-v1:0',
      'sonnet3.51' => 'anthropic.claude-3-5-sonnet-20240620-v1:0',
      'sonnet3.52' => 'anthropic.claude-3-5-sonnet-20241022-v2:0',
      'sonnet3.571' => 'us.anthropic.claude-3-7-sonnet-20250219-v1:0',
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
