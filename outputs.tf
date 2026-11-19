output "cloudfront_distribution_fqdn" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.authn
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.authn_frontend.id
}

output "cognito_identity_pool_id" {
  value = aws_cognito_identity_pool.authz_frontend.id
}

output "custom_domain_name" {
  description = "Custom domain name of the CloudFront distribution (null when not configured)"
  value       = var.custom_domain_name
}

output "acm_validation_records" {
  description = "ACM DNS validation records. Register these in your DNS when route53_zone_id is not set"
  value = local.custom_domain_enabled ? [
    for dvo in aws_acm_certificate.frontend[0].domain_validation_options : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ] : []
}
