import { Amplify } from 'aws-amplify';

const awsConfig = {
  Auth: {
    Cognito: {
      userPoolId: import.meta.env.VITE_USER_POOL_ID || '',
      userPoolClientId: import.meta.env.VITE_USER_POOL_CLIENT_ID || '',
      identityPoolId: import.meta.env.VITE_IDENTITY_POOL_ID || '',
      region: import.meta.env.VITE_AWS_REGION || '',
    },
  },
  Storage: {
    S3: {
      bucket: import.meta.env.VITE_S3_BUCKET || '',
      region: import.meta.env.VITE_AWS_REGION || '',
      buckets: {
        default: {
          bucketName: import.meta.env.VITE_S3_BUCKET || '',
          region: import.meta.env.VITE_AWS_REGION || '',
          paths: {
            "*": {
              authenticated: ["get", "list", "write", "delete"]
            }
          }
        },
        /*
        // https://docs.amplify.aws/react/build-a-backend/storage/use-with-custom-s3/#configure-the-s3-bucket
        additional01: {
          bucketName: import.meta.env.VITE_S3_BUCKET || '',
          region: import.meta.env.VITE_AWS_REGION || '',
          paths: {
            "*": {
              authenticated: ["get", "list", "write", "delete"],
            }
          }
        }
        */
      }
    },
  },
};

export default awsConfig;
export function configureAmplify() {
  Amplify.configure(awsConfig);
}