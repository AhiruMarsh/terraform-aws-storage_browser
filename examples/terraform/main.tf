module "storagebrowser" {
  source = "git::https://github.com/AhiruMarsh/terraform-aws-storage_browser?ref=main" # 利用時はタグ等で固定する

  prefix_name                = var.prefix_name
  custom_domain_name         = var.custom_domain_name
  route53_zone_id            = var.route53_zone_id
  target_s3_bucket_name_list = [aws_s3_bucket.test.id]
  cloudfront_function_arn    = aws_cloudfront_function.restricted_header.arn
}
