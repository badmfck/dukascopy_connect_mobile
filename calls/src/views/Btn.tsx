import React from "react";
import styled from "styled-components";

const BtnDiv=styled.div`
    width: 20vw;
    
    height:20vw;
    min-height:20vw;
    min-width:20vw;

    max-width:20vw;
    max-height:20vw;
    border-radius: 50%;
    background-color: blue;
    &[data-type="accept"]{
        background-color: #00FF00;
    }
    &[data-type="hangout"]{
        background-color: #FF0000;
    }
`

const Btn=(params:{type:"accept"|"hangout",onClick:(e:React.MouseEvent)=>void})=>{
    const {type,onClick}=params;
    return <BtnDiv data-type={type} onClick={onClick}>BtN</BtnDiv>
}
export default Btn;