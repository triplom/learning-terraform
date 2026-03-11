# AWS S3 static website bucket

This module provisions an AWS S3 bucket configured for static website hosting.

## Features

- Enables static website hosting on the S3 bucket
- Configures index and error documents
- Manages bucket ownership controls and public access settings
- Applies customizable tags to the bucket

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.0.0  |
| aws       | >= 4.0.0  |

## Usage

```hcl
module "static_website" {
  source = "./modules/aws-s3-static-website-bucket"

  bucket_name    = "my-static-website"
  index_document = "index.html"
  error_document = "error.html"

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Inputs

| Name            | Description                              | Type          | Default       | Required |
|-----------------|------------------------------------------|---------------|---------------|----------|
| `bucket_name`   | The name of the S3 bucket                | `string`      | n/a           | yes      |
| `index_document`| The index document for the website       | `string`      | `index.html`  | no       |
| `error_document`| The error document for the website       | `string`      | `error.html`  | no       |
| `tags`          | A map of tags to assign to the bucket    | `map(string)` | `{}`          | no       |

## Outputs

| Name                  | Description                              |
|-----------------------|------------------------------------------|
| `bucket_id`           | The name of the S3 bucket                |
| `bucket_arn`          | The ARN of the S3 bucket                 |
| `website_endpoint`    | The website endpoint of the S3 bucket    |

## Notes

- The bucket will be configured with public read access to serve static content.
- Ensure your AWS credentials have the necessary permissions to create and manage S3 buckets.