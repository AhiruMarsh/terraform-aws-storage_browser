# terraform-aws-storage_browser
Terraform module to create AWS Storage Browser for S3

モジュールを apply するだけで、Cognito・S3・CloudFront に加えて SPA（`app/`）も配置されます。

## SPA の仕組み
- `app/dist` は CI（`.github/workflows/build-app.yml`）が PR 上でビルドして git にコミットします。
- Terraform は `app/dist` を S3 にアップロードし、Cognito ID などを `config.json` として生成します（`app.tf`）。
- アプリは起動時に `/config.json` を取得するため、ビルド成果物は環境に依存しません。
- アプリの更新 = モジュールの更新です。利用側は `source` の `?ref=` を更新して apply してください
  （`?ref=` を省略すると既定ブランチの最新 `app/dist` が使われます）。

## カスタムドメイン
`custom_domain_name` を指定すると、CloudFront にカスタムドメインを設定し、ACM 証明書を us-east-1 に発行します（AWS provider v6 のリソース単位 `region` を使うため provider alias は不要です）。

- `route53_zone_id` も指定: DNS 検証レコードと CloudFront へのエイリアス（A/AAAA）まで自動で作成します。
- `route53_zone_id` 未指定: 出力 `acm_validation_records` の CNAME を自前の DNS に登録してください。
  証明書の検証が完了するまで apply は待機するため、apply 中に ACM コンソールで表示されるレコードを登録します。
  CloudFront への CNAME/ALIAS も自前で登録が必要です。
- Cognito のコールバック URL は `frontend_url` → `custom_domain_name` → CloudFront ドメインの順で決まります。

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_response_headers_policy.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_cognito_identity_pool.authz_frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool) | resource |
| [aws_cognito_identity_pool_roles_attachment.authz_frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool_roles_attachment) | resource |
| [aws_cognito_user_pool.authn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.authn_frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_iam_role.authz_unverified](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.authz_verified](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.authz_verified](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.acm_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudfront_cache_policy.caching_disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_cache_policy.caching_optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_iam_policy_document.authz_unverified_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.authz_verified_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.authz_verified_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.frontend_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudfront_function_arn"></a> [cloudfront\_function\_arn](#input\_cloudfront\_function\_arn) | ARN of the CloudFront Function to associate with the viewer-request event of the default cache behavior (e.g. header restriction for development environments) | `string` | `null` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | Custom domain name (FQDN) for the CloudFront distribution. When set, an ACM certificate is issued in us-east-1 and attached to the distribution | `string` | `null` | no |
| <a name="input_frontend_url"></a> [frontend\_url](#input\_frontend\_url) | frontend URL | `string` | `null` | no |
| <a name="input_prefix_name"></a> [prefix\_name](#input\_prefix\_name) | Prefix name | `string` | `"storagebrowser"` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route 53 hosted zone ID of custom\_domain\_name. When set, ACM DNS validation records and alias records (A/AAAA) are created automatically. When null, register the records in acm\_validation\_records in your own DNS (apply waits until the certificate is validated) | `string` | `null` | no |
| <a name="input_target_s3_bucket_name_list"></a> [target\_s3\_bucket\_name\_list](#input\_target\_s3\_bucket\_name\_list) | List of target S3 bucket name | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_validation_records"></a> [acm\_validation\_records](#output\_acm\_validation\_records) | ACM DNS validation records. Register these in your DNS when route53\_zone\_id is not set |
| <a name="output_cloudfront_distribution_fqdn"></a> [cloudfront\_distribution\_fqdn](#output\_cloudfront\_distribution\_fqdn) | n/a |
| <a name="output_cognito_identity_pool_id"></a> [cognito\_identity\_pool\_id](#output\_cognito\_identity\_pool\_id) | n/a |
| <a name="output_cognito_user_pool_client_id"></a> [cognito\_user\_pool\_client\_id](#output\_cognito\_user\_pool\_client\_id) | n/a |
| <a name="output_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#output\_cognito\_user\_pool\_id) | n/a |
| <a name="output_custom_domain_name"></a> [custom\_domain\_name](#output\_custom\_domain\_name) | Custom domain name of the CloudFront distribution (null when not configured) |
<!-- END_TF_DOCS -->