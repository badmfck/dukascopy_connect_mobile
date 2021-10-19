package com.telefision.sys.signals{

    import com.dukascopy.connect.vo.URLConfigVO;

    public class S_URLConfigReady extends SuperSignal{

        public function S_URLConfigReady(){
            super("S_URLConfigReady");
        }

        public function invoke(data:URLConfigVO):void{
            _invoke(data);
        }
    }

}