Gem::Specification.new do |spec|
  spec.name          = "alt_text"
  spec.version       = '0.1.0'
  spec.authors       = ['Alex Kiessling']
  spec.email         = ['ajk5603@psu.edu']

  spec.summary       = "Generates alt text"
  spec.description   = "AltText helps with accessibility by generating alt text for images."
  spec.homepage      = "https://github.com/psu-libraries/alt_text"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-bedrockruntime"
  spec.add_dependency "dotenv"
  spec.add_dependency "mini_magick"
end
