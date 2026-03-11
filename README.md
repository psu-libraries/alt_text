## Alt Text Generator

This uses Ruby's AWS SDK to send images and a prompt to an LLM in Amazon's Bedrock to generate Alt Text for the images.

The client uses Bedrock's `converse` API and currently supports JPEG and PNG inputs.

### Ruby Client Usage

This gem uses imagemagick to resize large images, so you will need to install imagemagick:

Mac:

```
brew install imagemagick
```

Ubuntu:

```
apt-get update
apt-get install imagemagick
```

Then, add the gem to your project:

In the Gemfile:
```
# Gemfile
gem 'alt_text'
```
```
bundle install
```

Or, via `gem install`:

```
gem install alt_text
```

Instantiate the client with injected AWS credentials:

```
client = AltText::Client.new(
  access_key: ENV['AWS_ACCESS_KEY_ID'],
  secret_key: ENV['AWS_SECRET_ACCESS_KEY'],
  region: 'us-east-1'
)
```

Call the `#process_image` method with the image path, prompt, and LLM ID as arguments:

```
client.process_image(
  'folder/image.png',
  prompt: 'Please generate alt text',
  model_id: 'default'
)
```

Supported image types:

- `.jpg`
- `.jpeg`
- `.png`

*Note: A sample prompt can be found in `prompt.txt`.*

### CLI Usage

Copy the `.env.sample` file to `.env` and add your AWS credentials.

```
cp .env.sample .env
```

General CLI command to generate Alt Text for images in the `images/` directory:

```
bundle exec bin/alt_text \
  -s output/output.txt \
  -l default \
  -d images \
  -p prompt.txt
```

Run this for help:

```
bundle exec bin/alt_text -h
```
