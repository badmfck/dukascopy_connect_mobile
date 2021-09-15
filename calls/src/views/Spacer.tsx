import React  from "react";

const Spacer = (params:{grow?:number,width?:string,height?:string})=>{
    const {grow,width,height}=params;
    const style={
        flexGrow:grow,
        width:width,
        height:height,
    }
    return <div style={style}></div>
}

export default Spacer;