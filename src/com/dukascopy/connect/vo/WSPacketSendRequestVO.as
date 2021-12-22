package com.dukascopy.connect.vo
{
    public class WSPacketSendRequestVO{
        public var method:String;
        public var data:Object;
        public var callback:Function;
        public var simulateSend:Boolean; // if true, will not send to server
        public function WSPacketSendRequestVO(method:String,data:Object,callback:Function=null,simulateSend:Boolean=false){
            this.method=method;
            this.data=data;
            this.callback=callback;
            this.simulateSend=simulateSend;
        }
        public function toJSON():String{
            return JSON.stringify({
                method:method,
                data:data
            })
        }
    }
}