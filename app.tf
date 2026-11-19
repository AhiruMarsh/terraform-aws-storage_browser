# SPA（app/dist）を S3 に配置する。
# dist は CI（.github/workflows/build-app.yml）がビルドして git にコミットしたものを使う。
# 環境依存の値は config.json として別途生成し、アプリが起動時に取得する。

data "aws_region" "current" {}

locals {
  app_dist_dir = "${path.module}/app/dist"

  # config.json は Terraform が生成するため dist 側のファイルは配置しない
  app_files = setsubtract(fileset(local.app_dist_dir, "**"), ["config.json"])

  app_content_types = {
    html        = "text/html; charset=utf-8"
    js          = "text/javascript; charset=utf-8"
    mjs         = "text/javascript; charset=utf-8"
    css         = "text/css; charset=utf-8"
    json        = "application/json"
    map         = "application/json"
    txt         = "text/plain; charset=utf-8"
    svg         = "image/svg+xml"
    png         = "image/png"
    jpg         = "image/jpeg"
    jpeg        = "image/jpeg"
    gif         = "image/gif"
    webp        = "image/webp"
    ico         = "image/x-icon"
    woff        = "font/woff"
    woff2       = "font/woff2"
    webmanifest = "application/manifest+json"
  }
}

resource "aws_s3_object" "app" {
  for_each = local.app_files

  bucket = aws_s3_bucket.frontend.id
  key    = each.value

  source      = "${local.app_dist_dir}/${each.value}"
  source_hash = filemd5("${local.app_dist_dir}/${each.value}")

  content_type = lookup(
    local.app_content_types,
    lower(reverse(split(".", each.value))[0]),
    "application/octet-stream"
  )

  # assets/ 配下はファイル名にハッシュが付くため長期キャッシュ、それ以外は常に再検証
  cache_control = startswith(each.value, "assets/") ? "public, max-age=31536000, immutable" : "no-cache"
}

resource "aws_s3_object" "config" {
  bucket = aws_s3_bucket.frontend.id
  key    = "config.json"

  content_type  = "application/json"
  cache_control = "no-cache"

  content = jsonencode({
    region           = data.aws_region.current.region
    userPoolId       = aws_cognito_user_pool.authn.id
    userPoolClientId = aws_cognito_user_pool_client.authn_frontend.id
    identityPoolId   = aws_cognito_identity_pool.authz_frontend.id
    buckets          = var.target_s3_bucket_name_list
  })
}
