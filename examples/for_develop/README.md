<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storagebrowser"></a> [storagebrowser](#module\_storagebrowser) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_function.restricted_header](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_s3_bucket.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_cors_configuration.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_ownership_controls.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.test_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_frontend_url"></a> [frontend\_url](#input\_frontend\_url) | Frontend URL | `string` | `null` | no |
| <a name="input_prefix_name"></a> [prefix\_name](#input\_prefix\_name) | Prefix name | `string` | `"storagebrowser"` | no |
| <a name="input_restricted_header_name"></a> [restricted\_header\_name](#input\_restricted\_header\_name) | Header name required to access CloudFront | `string` | n/a | yes |
| <a name="input_restricted_header_value"></a> [restricted\_header\_value](#input\_restricted\_header\_value) | Header value required to access CloudFront | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->