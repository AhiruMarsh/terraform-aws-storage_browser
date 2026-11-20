# CloudFront のアクセスログ（標準ログ v2）
# - CloudWatch Logs の Vended Logs (Delivery Source / Destination / Delivery) 経由で S3 に配信する
# - CloudFront のログ配信リソースは us-east-1 にのみ作成できるため、リソース単位で region を指定する
# - ログバケットも us-east-1 に作成する

locals {
  log_region      = "us-east-1"
  log_bucket_name = "${var.prefix_name}-logs-${local.aws_account_id}-${local.log_region}"
}

resource "aws_s3_bucket" "logs" {
  region        = local.log_region
  bucket        = local.log_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  region = local.log_region
  bucket = aws_s3_bucket.logs.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  region = local.log_region
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  region = local.log_region
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  region = local.log_region
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "RetentionRule"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

data "aws_iam_policy_document" "logs_bucket_policy" {
  statement {
    sid    = "AllowLogDeliveryWrite"
    effect = "Allow"

    actions = ["s3:PutObject"]

    resources = ["${aws_s3_bucket.logs.arn}/AWSLogs/${local.aws_account_id}/CloudFront/*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.aws_account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${local.log_region}:${local.aws_account_id}:delivery-source:*"]
    }
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  region = local.log_region
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs_bucket_policy.json

  depends_on = [aws_s3_bucket_public_access_block.logs]
}

resource "aws_cloudwatch_log_delivery_source" "cloudfront_frontend" {
  region = local.log_region

  name         = "${var.prefix_name}-frontend"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.frontend.arn
}

resource "aws_cloudwatch_log_delivery_destination" "logs_s3" {
  region = local.log_region

  name          = "${var.prefix_name}-logs-s3"
  output_format = "parquet"

  delivery_destination_configuration {
    destination_resource_arn = aws_s3_bucket.logs.arn
  }
}

resource "aws_cloudwatch_log_delivery" "cloudfront_frontend" {
  region = local.log_region

  delivery_source_name     = aws_cloudwatch_log_delivery_source.cloudfront_frontend.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.logs_s3.arn

  s3_delivery_configuration {
    suffix_path                 = "/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
    enable_hive_compatible_path = false
  }

  depends_on = [aws_s3_bucket_policy.logs]
}
