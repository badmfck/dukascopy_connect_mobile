import React from 'react';
import styled from 'styled-components';
import Calling from './views/Calling';
import Processing from './views/Processing';
import Spacer from './views/Spacer';


const AppDiv=styled.div`
  width:100vw;
  height:100vh;
  position:fixed;
  background-color: #080c10;
  color:white;
  font-family: sans-serif;
`

const topOffset="120px";
const bottomOffset="120px";

function App() {
  return (
    <AppDiv>
      <Processing/>
      <Calling/>
    </AppDiv>
  );
}

export default App;
