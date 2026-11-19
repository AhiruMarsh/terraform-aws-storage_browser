# Storage Browser for Amazon S3 (React + AWS)

## 実行時設定（`/config.json`）
Cognito の ID や対象バケット名はビルドに埋め込まず、起動時に `/config.json` を取得して読み込みます。
Terraform モジュールがデプロイ時にこのファイルを S3 に生成するため、同じビルド成果物をどの環境でも利用できます。

```json
{
  "region": "",
  "userPoolId": "",
  "userPoolClientId": "",
  "identityPoolId": "",
  "buckets": [""]
}
```

`buckets` の先頭が `default`、2 つ目以降が `additional01`, `additional02`, ... として扱われます。

## ローカル開発
1. `config.example.json` を `public/config.json` にコピーし、Terraform の出力値で埋める（gitignore 済み）
2. `npm ci && npm run dev`

## ビルドとデプロイ
`app/dist` は CI（`.github/workflows/build-app.yml`）が PR 上で自動ビルド・コミットします。
手元で `dist` をコミットする必要はありません。Terraform モジュールは `app/dist` を S3 にアップロードします。
