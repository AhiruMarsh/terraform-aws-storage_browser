# CloudFront のカスタムドメイン（custom_domain_name 指定時のみ有効）
# - ACM 証明書は CloudFront の要件により us-east-1 に発行する（リソース単位の region 指定。provider alias 不要）
# - route53_zone_id を指定した場合は、DNS 検証レコードと CloudFront へのエイリアスも作成する
# - 未指定の場合は acm_validation_records を自前の DNS に登録する（検証完了まで apply が待機する）

locals {
  custom_domain_enabled = var.custom_domain_name != null
  route53_enabled       = local.custom_domain_enabled && var.route53_zone_id != null
}

resource "aws_acm_certificate" "frontend" {
  count = local.custom_domain_enabled ? 1 : 0

  region            = "us-east-1"
  domain_name       = var.custom_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = local.route53_enabled ? {
    for dvo in aws_acm_certificate.frontend[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id         = var.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

# 証明書が ISSUED になるまで待つ（CloudFront は発行済みの証明書しか関連付けられない）
resource "aws_acm_certificate_validation" "frontend" {
  count = local.custom_domain_enabled ? 1 : 0

  region          = "us-east-1"
  certificate_arn = aws_acm_certificate.frontend[0].arn

  # Route 53 を使わない場合は null（外部 DNS に検証レコードが登録されるまで待機）
  validation_record_fqdns = local.route53_enabled ? [for r in aws_route53_record.acm_validation : r.fqdn] : null
}

# CloudFront へのエイリアス（IPv6 有効のため A / AAAA）
resource "aws_route53_record" "frontend" {
  for_each = local.route53_enabled ? toset(["A", "AAAA"]) : toset([])

  zone_id = var.route53_zone_id
  name    = var.custom_domain_name
  type    = each.value

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}
