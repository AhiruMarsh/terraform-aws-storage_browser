import {
  createAmplifyAuthAdapter,
  createStorageBrowser,
} from '@aws-amplify/ui-react-storage/browser';
import '@aws-amplify/ui-react-storage/styles.css';
import { Authenticator, Button } from '@aws-amplify/ui-react';

import './App.css';

const { StorageBrowser } = createStorageBrowser({
  config: createAmplifyAuthAdapter(),
});

export default function App() {
  return (
    <Authenticator loginMechanisms={['email']} /*hideSignUp*/>
      {({ signOut, user }) => (
        <>
          <div className="header">
            <h1>{`Hello ${user?.username}`}</h1>
            <Button onClick={signOut}>Sign out</Button>
          </div>
          <StorageBrowser />
        </>
      )}
    </Authenticator>
  );
}