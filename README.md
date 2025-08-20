## Alt Text Generator

This uses Ruby's AWS SDK to send images and a prompt to an LLM in Amazon's Bedrock to generate Alt Text for the images.

### Ruby Client Usage

Add the gem to your project:

```
gem install alt_text
```

Instantiate the client with injected AWS credentials:

```
client = AltText::Client.new {
  access_key_id: ENV['YOUR_ACCESS_KEY_ID'],
  secret_access_key: ENV['YOUR_SECRET_ACCESS_KEY'],
  region: 'us-east-1'
}
```

Call the `#process_image` method with the image path, prompt, and LLM ID as arguments:

```
client.process_image('folder/image.png', 'Please generate alt text', 'sonnet3.51`)
```

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
