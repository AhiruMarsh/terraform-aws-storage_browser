resource "aws_s3_bucket" "test" {
  bucket_prefix    = "${var.prefix_name}-test"
  bucket_namespace = "account-regional"

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "test" {
  bucket = aws_s3_bucket.test.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test" {
  bucket = aws_s3_bucket.test.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "test" {
  bucket = aws_s3_bucket.test.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "test" {
  bucket = aws_s3_bucket.test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  allow_origin_url = var.frontend_url != null ? var.frontend_url : "https://${module.storagebrowser.cloudfront_distribution_fqdn}"
}

resource "aws_s3_bucket_cors_configuration" "test" {
  bucket = aws_s3_bucket.test.id

  cors_rule {
    id              = "StorageBrowser"
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = [local.allow_origin_url]
    expose_headers = [
      "last-modified",
      "content-type",
      "content-length",
      "etag",
      "x-amz-version-id",
      "x-amz-request-id",
      "x-amz-id-2",
      "x-amz-cf-id",
      "x-amz-storage-class",
      "date",
      "access-control-expose-headers"
    ]
    max_age_seconds = 3000
  }
}

data "aws_iam_policy_document" "test_bucket_policy" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "${aws_s3_bucket.test.arn}",
      "${aws_s3_bucket.test.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "test" {
  bucket = aws_s3_bucket.test.id
  policy = data.aws_iam_policy_document.test_bucket_policy.json
}
