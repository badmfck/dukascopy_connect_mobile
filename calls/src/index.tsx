import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import CallManager from './CallManager';
import GD from './GD';


new CallManager();

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);

((window as unknown) as any)['GD']=GD;
((window as unknown) as any)['appReady']();
// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
