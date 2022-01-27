package com.telefision.sys.signals
{
    public class S_VoidSignal extends SuperSignal{
        public function S_VoidSignal(){
            super("S_VoidSignal");
        }
        public function invoke():void{
            _invoke();
        }
    }
}