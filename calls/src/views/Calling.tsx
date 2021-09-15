import React from "react";
import styled from "styled-components";
import GD from "../GD";
import Btn from "./Btn";
import Panel from "./Panel";
import Spacer from "./Spacer";



const UserBlockDiv=styled.div`
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-top:30%;

`

const UserBlockAvatarDiv=styled.div`
    width:35vw;
    height:35vw;
    background-color: rgba(0,0,0,.1);
    border-radius: 50%;
    overflow: hidden;
`

const UserBlockNameDiv=styled.div`
    padding-top: 12px;
`

const CallingButtonsDiv=styled.div`
    display: flex;
    align-items: center;
    justify-content: center;
`

const UserBlockStatusDiv=styled.div`
   
`

const Calling=()=>{
    
    const onAccept=(e:React.MouseEvent)=>{
        GD.S_CALL_ACCEPTED.invoke();
    }

    const onCancel=(e:React.MouseEvent)=>{
        GD.S_CALL_CANCELED.invoke();
    }

    return <Panel id="calling">
       
        <UserBlockDiv>
            <UserBlockAvatarDiv> </UserBlockAvatarDiv>
            <UserBlockNameDiv> USER 1 CALLING </UserBlockNameDiv>
        </UserBlockDiv>

        <UserBlockStatusDiv>CALLING...</UserBlockStatusDiv>

        <Spacer grow={1}/>

        <CallingButtonsDiv>
            <Btn type="accept" onClick={onAccept} />
            <Spacer width="20px"/>
            <Btn type="hangout" onClick={onCancel} />
        </CallingButtonsDiv>
        <Spacer height="35px" width="20px"/>
        </Panel>
}

export default Calling;
