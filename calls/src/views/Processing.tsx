import React, { useEffect, useRef } from "react"
import styled from "styled-components";
import GD from "../GD";
import Btn from "./Btn";
import Panel from "./Panel";

const RemoteVideo=styled.video`
   width: 320px;
   height: 240px;
` 
const LocalVideo=styled.video`
   
`
const ButtonsDiv=styled.div`
    position: absolute;
    right:0;
    height: 100vh;
    display: flex;
    flex-direction: column;
` 
const BottomButtonsDiv=styled.div`
    position: absolute;
    bottom:0;
    display: flex;
    width:100vw;
    flex-direction: column;
` 



const Processing=()=>{

    const remoteVideo = useRef<HTMLVideoElement|null>(null);
    const localVideo = useRef<HTMLVideoElement|null>(null);

    useEffect(() => {
        
        GD.S_MY_CAMERA_READY.add(stream=>{
            console.log(stream,localVideo);
            if(!localVideo || !localVideo.current)
                return;
            localVideo.current.srcObject=stream;
            
        })

        return () => {
            GD.S_CALL_ACCEPTED.clearContext("processing");
        }
    }, [])
    return(
        <Panel id="processing">
            <RemoteVideo playsInline={true} autoPlay={true} ref={remoteVideo}></RemoteVideo>
            <LocalVideo ref={localVideo}></LocalVideo>
            <ButtonsDiv>
                <Btn type={"accept"} onClick={e=>{}}/>
                <Btn type={"accept"} onClick={e=>{}}/>
                <Btn type={"accept"} onClick={e=>{}}/>
            </ButtonsDiv>
            <BottomButtonsDiv>
                <Btn type={"hangout"} onClick={e=>{
                    GD.S_CALL_CANCELED.invoke();
                }}/>
            </BottomButtonsDiv>
        </Panel>
    )
}

export default Processing;