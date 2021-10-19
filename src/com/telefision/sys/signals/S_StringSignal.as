package com.telefision.sys.signals
{
    public class S_StringSignal extends SuperSignal{
        public function S_StringSignal(){
            super("S_StringSignal");
        }
        public function invoke(data:String):void{
            _invoke(data);
        }
    }
}