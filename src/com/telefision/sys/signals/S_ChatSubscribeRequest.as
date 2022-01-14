package com.telefision.sys.signals
{

    public class S_ChatSubscribeRequest extends SuperSignal{
        public function S_ChatSubscribeRequest(){
            super("S_ChatSubscribeRequest");
        }
        public function invoke(chatUID:String):void{
            _invoke(chatUID)
        }
    }
}