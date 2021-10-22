package com.telefision.sys.signals
{
    import com.dukascopy.connect.vo.WSPacketVO;

    public class S_WSPacketReceived extends SuperSignal{
        public function S_WSPacketReceived(){
            super("S_WSPacketReceived");
        }
        public function invoke(data:WSPacketVO):void{
            _invoke(data);
        }
    }
}