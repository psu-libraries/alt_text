Gem::Specification.new do |spec|
  spec.name          = "alt_text"
  spec.version       = '0.1.0'
  spec.authors       = ['Alex Kiessling']
  spec.email         = ['ajk5603@psu.edu']

  spec.summary       = "Generates alt text"
  spec.description   = "AltText helps with accessibility by generating alt text for images."
  spec.homepage      = "https://github.com/psu-libraries/alt_text"
  spec.license       = "MIT"

  spec.files = Dir["lib/**/*", "bin/*", "README.md", "LICENSE.txt", "prompt.txt"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 3.4'

  spec.add_dependency "aws-sdk-bedrockruntime", '~> 1.55.0'
  spec.add_dependency "dotenv", '~> 3.1.8'
  spec.add_dependency "mini_magick", '~> 5.3.0'
end
