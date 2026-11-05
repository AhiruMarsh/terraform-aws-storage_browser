module "storagebrowser" {
  source = "git::https://github.com/AhiruMarsh/terraform-aws-storage_browser"

  prefix_name                = var.prefix_name
  target_s3_bucket_name_list = [aws_s3_bucket.test.id]
  cloudfront_function_arn    = aws_cloudfront_function.restricted_header.arn
}
