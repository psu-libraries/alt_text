## Alt Text Generator

This uses Ruby's AWS SDK to send images and a prompt to an LLM in Amazon's Bedrock to generate Alt Text for the images.

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
