package com.telefision.sys.signals
{
    import com.dukascopy.connect.vo.WSPacketVO;
    import com.dukascopy.connect.vo.WSPacketSendRequestVO;

    public class S_WSPacketSendRequest extends SuperSignal{
        public function S_WSPacketSendRequest(){
            super("S_WSPacketSendRequest");
        }
        public function invoke(data:WSPacketSendRequestVO):void{
            _invoke(data)
        }
    }
}