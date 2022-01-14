package com.telefision.sys.signals
{

    public class S_ChatUnsubscribeRequest extends SuperSignal{
        public function S_ChatUnsubscribeRequest(){
            super("S_ChatUnsubscribeRequest");
        }
        public function invoke(chatUID:String):void{
            _invoke(chatUID)
        }
    }
}