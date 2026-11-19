import React from 'react';
import ReactDOM from 'react-dom/client';
import { configureAmplify } from './awsConfig';

// App は評価時に Amplify の設定を参照するため、設定読み込み後に動的 import する
async function bootstrap() {
  const root = ReactDOM.createRoot(document.getElementById('root')!);
  try {
    await configureAmplify();
    const { default: App } = await import('./App');
    root.render(
      <React.StrictMode>
        <App />
      </React.StrictMode>
    );
  } catch (e) {
    console.error(e);
    root.render(<p>設定の読み込みに失敗しました。</p>);
  }
}

bootstrap();
