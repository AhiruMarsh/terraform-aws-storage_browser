##------------------------------------------------------------------------------
## AuthZ (Unverified user)
##------------------------------------------------------------------------------
data "aws_iam_policy_document" "authz_unverified_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.authz_frontend.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

resource "aws_iam_role" "authz_unverified" {
  name               = "${local.authz_prefix_name}-unverified"
  assume_role_policy = data.aws_iam_policy_document.authz_unverified_assume_role.json
}

##------------------------------------------------------------------------------
## AuthZ (Verified user)
##------------------------------------------------------------------------------
data "aws_iam_policy_document" "authz_verified_iam_policy" {
  dynamic "statement" {
    for_each = toset(var.target_s3_bucket_name_list)

    content {
      effect = "Allow"

      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
      ]

      resources = [
        "arn:aws:s3:::${statement.value}",
        "arn:aws:s3:::${statement.value}/*",
      ]
    }
  }
}

data "aws_iam_policy_document" "authz_verified_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.authz_frontend.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

resource "aws_iam_role" "authz_verified" {
  name               = "${local.authz_prefix_name}-verified"
  assume_role_policy = data.aws_iam_policy_document.authz_verified_assume_role.json
}

resource "aws_iam_role_policy" "authz_verified" {
  count = length(var.target_s3_bucket_name_list) > 0 ? 1 : 0

  name   = "${local.authz_prefix_name}-verified"
  role   = aws_iam_role.authz_verified.id
  policy = data.aws_iam_policy_document.authz_verified_iam_policy.json
}
