## Alt Text Generator

This uses Ruby's AWS SDK to send images and a prompt to an LLM in Amazon's Bedrock to generate Alt Text for the images.

### Usage

Copy the `.env.sample` file to `.env` and add your AWS credentials.

```
cp .env.sample .env
```

General CLI command to generate Alt Text for images in the `images/` directory:

```
bundle exec ruby alt_text.rb \
  -s output/output.txt \
  -llm default \
  -d images \
  -p prompt.txt
```

Run this for help:

```
bundle exec ruby alt_text.rb -h
```
