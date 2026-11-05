output "cloudfront_distribution_fqdn" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.authn.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.authz_frontend.id
}

output "cognito_identity_pool_id" {
  value = aws_cognito_identity_pool.authz_frontend.id
}
