#!/usr/bin/env ruby
require 'aws-sdk-bedrockruntime'
require 'json'
require 'base64'
require 'fileutils'
require 'dotenv'
require 'securerandom'
require 'mini_magick'
require 'optparse'

# ---------- Defaults ----------
options = {
  save_file: '',
  model: 'default',
  prompt_file: 'prompt.txt',
  folder: '.',
  random: false
}

# ---------- CLI Parsing ----------
OptionParser.new do |opts|
  opts.banner = "Usage: ruby script.rb [options]"

  opts.on('-s FILE', '--save FILE', 'Save output file path') { |v| options[:save_file] = v }
  opts.on('-llm MODEL', 'Model name (default, sonnet3.51, sonnet3.52, sonnet3.571, novapro)') { |v| options[:model] = v }
  opts.on('-d FOLDER', '--dir FOLDER', 'Folder to process') { |v| options[:folder] = v }
  opts.on('-p FILE', '--prompt FILE', 'Prompt file path') { |v| options[:prompt_file] = v }
  opts.on('-r', '--random', 'Randomly pick 500 files') { options[:random] = true }
end.parse!

# ---------- Helpers ----------
def list_files_scandir(path='.', str_exclude='pdf')
  Dir.glob(File.join(path, '**', '*'))
    .select { |f| File.file?(f) && !f.downcase.end_with?(str_exclude) }
end

def get_model_id(id)
  case id
  when 'default', 'sonnet3.51'
    'anthropic.claude-3-5-sonnet-20240620-v1:0'
  when 'sonnet3.52'
    'anthropic.claude-3-5-sonnet-20241022-v2:0'
  when 'sonnet3.571'
    'us.anthropic.claude-3-7-sonnet-20250219-v1:0'
  when 'novapro'
    'us.amazon.nova-pro-v1:0'
  else
    'anthropic.claude-3-5-sonnet-20240620-v1:0'
  end
end

# ---------- Setup ----------
File.delete(options[:save_file]) if File.exist?(options[:save_file])
output_file = File.open(options[:save_file], 'w')

Dotenv.load('.env')
client = Aws::BedrockRuntime::Client.new(
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(
    ENV['AWS_ACCESS_KEY_ID'],
    ENV['AWS_SECRET_ACCESS_KEY']
  )
)

model_id = get_model_id(options[:model])
prompt_string = File.read(options[:prompt_file])

# ---------- Gather Files ----------
files = list_files_scandir(options[:folder])
files = files.sample(500) if options[:random]

# ---------- Process Files ----------
files.each_with_index do |filepath, index|
  puts "Processing image #{index + 1} of #{files.size}: #{filepath}"

  tmp_image_path = filepath
  if File.size(filepath) >= 4_000_000
    tmp_image_path = "#{filepath}_tmp_#{SecureRandom.hex}.png"
    image = MiniMagick::Image.open(filepath)
    image.resize "800x"
    image.write tmp_image_path
  end

  encoded_image = Base64.strict_encode64(File.binread(tmp_image_path))
  File.delete(tmp_image_path) if tmp_image_path != filepath

  payload = {
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'image',
            source: {
              type: 'base64',
              media_type: 'image/jpeg',
              data: encoded_image
            }
          },
          {
            type: 'text',
            text: prompt_string
          }
        ]
      }
    ],
    max_tokens: 10_000,
    anthropic_version: 'bedrock-2023-05-31'
  }

  begin
    response = client.invoke_model(
      model_id: model_id,
      content_type: 'application/json',
      body: payload.to_json
    )

    output_json = JSON.parse(response.body.read)
    output_text = output_json['content'][0]['text']
      .gsub('```json', '')
      .gsub('```', '')

    begin
      alt_text = JSON.parse(output_text)
      output_file.puts("#{filepath}\t#{alt_text['image']['alt']}\t#{alt_text['image']['desc']}\t#{alt_text['image']['subjects']}")
    rescue
      output_file.puts("#{filepath}\terror thrown by amazon api")
    end
  rescue
    output_file.puts("#{filepath}\terror returned via the ai -- skipping")
  end
end

puts "Script has completed"

