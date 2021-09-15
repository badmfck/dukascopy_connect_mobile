import React, { useEffect, useRef } from "react";
import styled from "styled-components";
import GD from "../GD";
import Spacer from "./Spacer";

const PanelDiv=styled.div`
    background-color: #050509;
    position: absolute;
    top:0;
    left:0;
    width:100vw;
    height:100vh;
    flex-direction: column;
    opacity: 0;
    transform:translateY(25vh);
    transition: opacity .2s, transform .2s;
    pointer-events: none;
    display: none;
    &[data-visibility="1"]{
        opacity: 1;
        transform:translateY(0);
        pointer-events:all;
    }

    &[data-phase="show"]{
        display: flex;
    }
 
    /* Add the blur effect */
   /* filter: blur(8px);*/
`

//const timers:any={};
let currentPanelID:string|null=null;

const Panel=(params:{id:string,children:any})=>{
    const {id,children}=params;
    const ref = useRef<HTMLDivElement|null>(null);
    
    const hide=()=>{
        // show
        if(!ref.current)
            return;
        ref.current.removeAttribute("data-visibility");
        setTimeout(()=>{
            ref.current?.removeAttribute("data-phase");
        },201)
    }

    const show=(cb?:()=>void)=>{
        // show
        if(!ref.current)
            return;
        currentPanelID=id;
        ref.current.setAttribute("data-phase","show");
        setTimeout(()=>{
            if(ref.current)
                ref.current.setAttribute("data-visibility","1");   
            setTimeout(()=>{
                if(cb)
                    cb();
            },201)
        },50)
    }

    useEffect(() => {
        GD.S_GUI_PANEL_SHOW.add(req=>{
            if(id!==req.id){
                if(!ref.current)
                    return;
                hide();
                return;
            }

            if(!ref.current)
                return;

            show(req.onComplete);

        },"panel")
        return () => {
            GD.S_GUI_PANEL_SHOW.clearContext("panel");
        }
    }, [id])

    return  <PanelDiv ref={ref}>
                <Spacer height="35px" width="20px"/>
                    {children}
                <Spacer height="35px" width="20px"/>
            </PanelDiv>
}

export default Panel;