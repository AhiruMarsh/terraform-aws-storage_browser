import { Amplify } from 'aws-amplify';

// Terraform モジュールが S3 に配置する /config.json の形式
interface RuntimeConfig {
  region: string;
  userPoolId: string;
  userPoolClientId: string;
  identityPoolId: string;
  buckets: string[];
}

async function loadConfig(): Promise<RuntimeConfig> {
  const res = await fetch('/config.json', { cache: 'no-store' });
  if (!res.ok) {
    throw new Error(`Failed to load /config.json: ${res.status}`);
  }
  return res.json();
}

function buildAwsConfig(config: RuntimeConfig) {
  const bucketEntries = Object.fromEntries(
    config.buckets.map((bucketName, index) => [
      // 先頭を default、以降を additional01, additional02, ... とする
      // https://docs.amplify.aws/react/build-a-backend/storage/use-with-custom-s3/#configure-the-s3-bucket
      index === 0 ? 'default' : `additional${String(index).padStart(2, '0')}`,
      {
        bucketName,
        region: config.region,
        paths: {
          '*': {
            authenticated: ['get', 'list', 'write', 'delete'],
          },
        },
      },
    ])
  );

  return {
    Auth: {
      Cognito: {
        userPoolId: config.userPoolId,
        userPoolClientId: config.userPoolClientId,
        identityPoolId: config.identityPoolId,
      },
    },
    Storage: {
      S3: {
        bucket: config.buckets[0] ?? '',
        region: config.region,
        buckets: bucketEntries,
      },
    },
  };
}

export async function configureAmplify() {
  const config = await loadConfig();
  Amplify.configure(buildAwsConfig(config));
}
