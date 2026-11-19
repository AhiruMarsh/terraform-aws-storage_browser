data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "frontend" {
  comment = "${var.prefix_name}-frontend"

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  origin {
    origin_id                = aws_s3_bucket.frontend.id
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    target_origin_id = aws_s3_bucket.frontend.id

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.frontend.id

    dynamic "function_association" {
      for_each = var.cloudfront_function_arn != null ? [var.cloudfront_function_arn] : []

      content {
        event_type   = "viewer-request"
        function_arn = function_association.value
      }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    target_origin_id = aws_s3_bucket.frontend.id

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.frontend.id

    dynamic "function_association" {
      for_each = var.cloudfront_function_arn != null ? [var.cloudfront_function_arn] : []

      content {
        event_type   = "viewer-request"
        function_arn = function_association.value
      }
    }
  }
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = aws_s3_bucket.frontend.id
  description                       = "OAC of ${aws_s3_bucket.frontend.id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "frontend" {
  name = "${var.prefix_name}-frontend"

  remove_headers_config {
    items {
      header = "x-amz-server-side-encryption-aws-kms-key-id"
    }
  }
}
