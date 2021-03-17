package com.dukascopy.connect.sys.ws {
import com.dukascopy.connect.Config;
import com.dukascopy.connect.GD;
import com.worlize.websocket.WebSocket;
import com.worlize.websocket.WebSocketEvent;


import com.greensock.TweenMax;
import com.adobe.crypto.MD5;

import flash.events.ErrorEvent;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;


public class DesktopWS extends EventDispatcher implements IWebSocket{

    static private var clientUID:String=MD5.hash(new Date().getTime()+"_"+Math.random()*1000);
    static private var instanceID:int=0;
    static private var bridgeWS:WebSocket=DesktopWS.connectToWSBridge();
    static private var instances:Array=[];

    private var _readyState:int = 3;
    public function getReadyState():int{ return _readyState;}

    private var url:String;
    private var id:int;

    public function DesktopWS(url:String,origin:String=""){
        this.url=url;
        this.id=instanceID++;
        instances.push(this);
        connect("desktop",true);
    }

    static private function connectToWSBridge():WebSocket{
        if(!Config.PLATFORM_WINDOWS)
            return null;

        if(DesktopWS.bridgeWS!=null){
            DesktopWS.bridgeWS.close();
            DesktopWS.bridgeWS=null;
        }

        var bridgeWS:WebSocket=new WebSocket("ws://localhost:9000","desktopws");
        bridgeWS.addEventListener(WebSocketEvent.OPEN, __onOpen);
        bridgeWS.addEventListener(WebSocketEvent.CLOSED, __onClose);
        bridgeWS.addEventListener(WebSocketEvent.MESSAGE, __onMessage);
        DesktopWS.bridgeWS=bridgeWS;
        return bridgeWS;
    }

    static private function __onOpen(e:WebSocketEvent):void{
        // Bridge opened
        trace("Bridge opened");
    }

    static private function __onClose(e:WebSocketEvent):void{
        trace("Bridge closed");
        TweenMax.delayedCall(.4,function():void{
            connectToWSBridge();
        })
    }

    static private function __onMessage(e:WebSocketEvent):void{
        // GOT WS MESSAGE
        //{"method":"connected","data":"wss://ws.dukascopy.com","uid":"2a28ac639c9b094be1c88b2d04dbb995","id":1}
        var packet:Object=null;

        try{
            packet=JSON.parse(e.message.utf8Data);
        }catch(err:Error){
            GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:"can't parse json"});
            return;
        }

        if(packet.uid!=clientUID){
            GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:{text:"wrong client uid "+packet.uid,currentUID:clientUID}});
            return;
        }

        var l:int=instances.length;
        var found:DesktopWS=null;
        var foundIndex:int=-1;
        for(var i:int=0;i<l;i++){
            var inst:DesktopWS=instances[i];
            if(inst==null || inst.id!=packet.id)
                continue;
            found=inst;
            foundIndex=i;
            break;
        }

        if(found==null){
            GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:"No instance for id:"+packet.id});
            return;
        }

        var method:String=packet.method;
        if(method=="connected"){
            found._readyState=1;
            if(found.onOpen!=null)
                found.onOpen();
            GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:"socket opened: "+found.id});
            return;
        }

        if(method=="connectionError"){
            found._readyState=3;
            if(found.onError!=null)
                found.onError(packet.data);
            GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:"socket error: "+found.id});
            return;
        }

        if(method=="closed"){
            found._readyState=3;
            if(found.onClose!=null)
                found.onClose(packet.data);
            GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:"socket closed: "+found.id});
            return;
        }

        if(method=="message"){
            if(found.onMessage!=null)
                found.onMessage(packet.data);
            GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:{instance:found.id,data:packet.data}});
            return;
        }

        if(method=="destroyed"){
            if(foundIndex>-1 && foundIndex<instances.length)
                instances.removeAt(foundIndex);
            GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:"Socket destroyed: "+found.id});
            return;
        }

        GD.S_LOG_WS.invoke({src:"WS",method:"__onMessage",txt:"Unhandled method: "+packet.method});

    }

    static private function __onError():void{
        GD.S_LOG_WS.invoke({src:"WS",method:"__onError",txt:"BRIDGE CONNECTION ERROR"});
    }

    // SEND COMMAND
    static private function __sendMessage(method:String,data:String,instanceID:int):void{
        if(DesktopWS.bridgeWS && DesktopWS.bridgeWS.readyState==1)
            DesktopWS.bridgeWS.sendUTF(JSON.stringify({method:method,data:data,id:instanceID,uid:clientUID}));
    }

    public function isAutoreconnect():Boolean{
        return false;
    }
    public function isOpen():Boolean{
        return _readyState==1;
    }
    public function isConnecting():Boolean{
        return  _readyState==0;
    }

    public function connect(reason:String,anyway:Boolean):void{
        if(DesktopWS.bridgeWS!=null && DesktopWS.bridgeWS.readyState==1){
            __sendMessage("connect",url,id);
            _readyState=0;
            return;
        }
        GD.S_LOG_WS.invoke({src:"WS",method:"connect",txt:"NO BRIDGE CONNECTION"})
        if(onError)
            onError("No Bridge connection")
        if(onClose)
            onClose("");
        _readyState=3;
    }

    public function destroy():void{

        if(DesktopWS.bridgeWS && DesktopWS.bridgeWS.readyState==1){
            __sendMessage("destroy",url,id);
            _readyState=2;
            return;
        }
        GD.S_LOG_WS.invoke({src:"WS",method:"close",txt:"NO BRIDGE CONNECTION"})
        if(onError)
            onError("No Bridge connection")
        _readyState=3;
    }

    public function close(waitForServer:Boolean=true,reason:String=null,clear:Boolean=false):void{
        if(DesktopWS.bridgeWS && DesktopWS.bridgeWS.readyState==1){
            __sendMessage("close",url,id);
            _readyState=2;
            return;
        }
        GD.S_LOG_WS.invoke({src:"WS",method:"close",txt:"NO BRIDGE CONNECTION"})
        if(onError)
            onError("No Bridge connection")
        if(onClose)
            onClose("");
        _readyState=3;
    }

    private function onMessage(msg:String):void{
        var evt:WebSocketEvent=new WebSocketEvent(WebSocketEvent.MESSAGE);
        evt.message.type="text";
        evt.message.utf8Data=msg;
        dispatchEvent(evt)
    }
    private function onClose(err:String):void{
        var evt:WebSocketEvent=new WebSocketEvent(WebSocketEvent.CLOSED);
        dispatchEvent(evt)
    }
    private function onOpen():void{
        var evt:WebSocketEvent=new WebSocketEvent(WebSocketEvent.OPEN);
        dispatchEvent(evt)
    }
    private function onError(err:String):void{
        var evt:ErrorEvent=new ErrorEvent(ErrorEvent.ERROR);
        trace(err);
        //dispatchEvent(evt)
    }


    public function sendBytes(ba:ByteArray):void{}

    public function sendUTF(text:String):void{
        if(DesktopWS.bridgeWS && DesktopWS.bridgeWS.readyState==1){
            __sendMessage("send",text,id);
            return;
        }
        GD.S_LOG_WS.invoke({src:"WS",method:"close",txt:"NO BRIDGE CONNECTION"})
        if(onError)
            onError("No Bridge connection")
        if(onClose)
            onClose("");
        _readyState=3;
    }
    }
}