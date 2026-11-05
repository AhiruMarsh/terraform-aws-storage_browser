# Storage Browser for Amazon S3 (React + AWS)

## 設定ファイル
- `/.env`（もしくは`.env.development`, `.env.production`など）は必ず `.env.example` を複製して利用してください

## 必要変数（Amplify/Storage用、Terraform出力と揃えること）
```
VITE_AWS_REGION=
VITE_USER_POOL_ID=
VITE_USER_POOL_CLIENT_ID=
VITE_IDENTITY_POOL_ID=
VITE_S3_BUCKET=
VITE_CLOUDFRONT_DOMAIN=
```

Terraformで構築した値を反映することで、開発・本番どちらでも動作します。