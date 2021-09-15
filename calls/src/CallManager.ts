import GD from "./GD";

class CallManager{

    private peer?:RTCPeerConnection;
    private localStream?:MediaStream;
    private remoteStream?:MediaStream;

    private webRTCConfig={
        iceServers:[
            {urls:"stun:stun.l.google.com:19302"},
            {urls:'stun:stun1.l.google.com:19302'},
            {urls:'stun:stun2.l.google.com:19302'},
            {urls:'stun:stun3.l.google.com:19302'},
            {urls:'stun:stun4.l.google.com:19302'},
            {urls:'stun:stunserver.org'}
        ]
    }

    constructor(){

        GD.S_CALL_PLACED.add(req=>{
            GD.S_GUI_PANEL_SHOW.invoke({id:"calling"});
        });

        GD.S_CALL_ACCEPTED.add(()=>{
            GD.S_GUI_PANEL_SHOW.invoke({id:"processing"});
            GD.S_INVOKE_METHOD.invoke({name:"callAccepted",data:{}});
            this.createConnection();
        })

        GD.S_CALL_CANCELED.add(()=>{
            this.closeConnection();
            GD.S_GUI_PANEL_SHOW.invoke({id:null});
            GD.S_INVOKE_METHOD.invoke({name:"callCanceled",data:{}});
        })

        GD.S_GOT_OFFER.add(offer=>{
            this.gotOffer(offer);
        })
        GD.S_GOT_ANSWER.add(answer=>{
            this.gotAnswer(answer);
        })
        GD.S_GOT_CANDIDATE.add(candidate=>{
            this.gotCandidate(candidate);
        })
    }

    private createConnection=async ()=>{

        this.closeConnection();

        //1. create peer connection
        this.peer=new RTCPeerConnection(this.webRTCConfig);

        //2. attach listeners
        this.peer.onicecandidate=e=>{
            GD.S_INVOKE_METHOD.invoke({
                name:"peerEvent",
                data:{
                    type:"onicecandidate",
                    data:e.candidate?.toJSON()
                }
            })
        }

        this.peer.onconnectionstatechange=e=>{
            GD.S_INVOKE_METHOD.invoke({
                name:"peerEvent",
                data:{
                    type:"onconnectionstatechange",
                    data:this.peer?.iceConnectionState
                }
            })
        }

        this.peer.onicegatheringstatechange=e=>{
            GD.S_INVOKE_METHOD.invoke({
                name:"peerEvent",
                data:{
                    type:"onicegatheringstatechange",
                    data:this.peer?.iceGatheringState
                }
            })
        }

        this.peer.onicecandidateerror=(err:Event)=>{
            const e=err as RTCPeerConnectionIceErrorEvent;
            GD.S_INVOKE_METHOD.invoke({
                name:"peerEvent",
                data:{
                    type:"onicecandidateerror",
                    data:e.errorCode+" "+e.errorText
                }
            })
        }

        this.peer.ontrack=e=>{
            // GOT TRACK!
            let stat="";
            if(!this.remoteStream){
                stat="Remote stream created";
                this.remoteStream=new MediaStream();
                stat+=", remote video srcObject = remoteStream";
                GD.S_REMOTE_STREAM_READY.invoke(this.remoteStream);
            }
            
            let t:any=null;
            if(e.track){
                t={}
                try{
                    this.remoteStream.addTrack(e.track);
                }catch(e){
                    t.added=true;
                }
                
                t.id=e.track.id;
                t.kind=e.track.kind;
                t.label=e.track.label
                t.enabled=e.track.enabled;
                t.muted=e.track.muted;
                t.readyState=e.track.readyState;
            }else{
                stat+=", no track";
            }
            if(e.streams){
                if(t!=null)
                    t.streams=e.streams.length;
                else
                    t={streams:e.streams.length}
            }else{
                if(t!=null)
                    t.streams=-1
            }

            if(t!=null && this.remoteStream!=null){
                t.remoteStream={
                    active:this.remoteStream.active,
                    id:this.remoteStream.id
                }
            }

            GD.S_INVOKE_METHOD.invoke({
                name:"peerEvent",
                data:{
                    type:"ontrack",
                    data:t
                }
            })
        }

        //3. create local stream
        if(!this.localStream)
            await this.createLocalStream();

        if(!this.localStream){
            this.closeConnection();
            GD.S_INVOKE_METHOD.invoke({
                name:"peerCreateEvent",
                data:{status:false}
            })
            return;
        }

        //4. attach local stream to peer
        this.localStream.getTracks().forEach(track=>this.peer?.addTrack(track));
        GD.S_INVOKE_METHOD.invoke({
            name:"peerCreateEvent",
            data:{status:true}
        })
        return;
    }

    private createLocalStream=async ()=>{
        try{
            /*this.localStream=await navigator.mediaDevices.getUserMedia({
                audio:true,
                video:true
            })*/
            this.localStream=await navigator.mediaDevices.getUserMedia({
                audio:true,
                video:{facingMode:"user"} 
            })
        }catch(e){
            GD.S_INVOKE_METHOD.invoke({
                name:"localStreamCreateEvent",
                data:{status:false,data:(e as any).text}
            })
            return;
        }
 
        if(!this.localStream){
            GD.S_INVOKE_METHOD.invoke({
                name:"localStreamCreateEvent",
                data:{status:false,data:"local strean not created"}
            })
            return;
        }

        GD.S_MY_CAMERA_READY.invoke(this.localStream);

        GD.S_INVOKE_METHOD.invoke({
            name:"localStreamCreateEvent",
            data:{status:true,data:"local stream created"}
        })
    }


    private closeConnection=()=>{
        if(!this.peer)
            return;

        this.peer.onicecandidate=null;
        this.peer.onconnectionstatechange=null;
        this.peer.onicegatheringstatechange=null;
        this.peer.onicecandidateerror=null;
        this.peer.ontrack=null;
        this.peer.close();
        
        GD.S_CALL_CONNECTION_CLOSED.invoke();
    }


    private gotCandidate=async (data:any)=>{
        if(!this.peer)
            return;
        await this.peer.addIceCandidate(data);
        GD.S_INVOKE_METHOD.invoke({
            name:"peerEvent",
            data:{type:"oncandidateadded",data:null}
        })
        
    }

     private gotOffer=async (data:any)=>{
        if(!this.peer){
            GD.S_INVOKE_METHOD.invoke({
                name:"peerEvent",
                data:{type:"onOfferReceived",data:"NO_PEER"}
            })
            return;
        }
        try{
            await this.peer.setRemoteDescription(new RTCSessionDescription(data));
        }catch(e){
            GD.S_INVOKE_METHOD.invoke({
                name:"peerEvent",
                data:{type:"onOfferReceived",data:"CANT_SET_REMOTE_DESCRIPTION"}
            })
            return;
        }
        const answer=await this.peer.createAnswer({
            offerToReceiveAudio:true,
            offerToReceiveVideo:true,
        });
        
        await this.peer.setLocalDescription(answer);

        GD.S_INVOKE_METHOD.invoke({
            name:"peerEvent",
            data:{type:"onanswercreated",data:answer}
        })
    }
            
    private gotAnswer=async (data:any)=>{
        if(!this.peer)
            return;
        try{
            await this.peer.setRemoteDescription(data);
        }catch(e){
            GD.S_INVOKE_METHOD.invoke({
                name:"peerEvent",
                data:{type:"onAnswerReceived",data:"CANT_SET_REMOTE_DESCRIPTION"}
            })
            return;
        }

        GD.S_INVOKE_METHOD.invoke({
            name:"peerEvent",
            data:{type:"onremotedescriptionset",data:"ok"}
        })
        return;
    }
}
export default CallManager;