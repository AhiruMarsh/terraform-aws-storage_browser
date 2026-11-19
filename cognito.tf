locals {
  url = coalesce(
    var.frontend_url,
    local.custom_domain_enabled ? "https://${var.custom_domain_name}" : null,
    "https://${aws_cloudfront_distribution.frontend.domain_name}"
  )
}

# Cognito User Pool（ユーザー管理・認証）
resource "aws_cognito_user_pool" "authn" {
  name = local.authn_prefix_name

  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "authn_frontend" {
  name         = "${local.authn_prefix_name}-frontend"
  user_pool_id = aws_cognito_user_pool.authn.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = ["${local.url}/callback"]
  logout_urls                          = [local.url]
  supported_identity_providers         = ["COGNITO"]
}

# Cognito Identity Pool (for AWS SDK/S3操作を想定)
resource "aws_cognito_identity_pool" "authz_frontend" {
  identity_pool_name               = "${local.authz_prefix_name}-frontend"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.authn_frontend.id
    provider_name           = aws_cognito_user_pool.authn.endpoint
    server_side_token_check = false
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "authz_frontend" {
  identity_pool_id = aws_cognito_identity_pool.authz_frontend.id

  roles = {
    "authenticated"   = aws_iam_role.authz_verified.arn
    "unauthenticated" = aws_iam_role.authz_unverified.arn
  }
}
