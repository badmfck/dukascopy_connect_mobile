package com.dukascopy.connect.managers.escrow.signals{

    import com.telefision.sys.signals.SuperSignal;
    import com.dukascopy.connect.managers.escrow.vo.EscrowDealEventSentRequestVO;

    public class S_EscrowRequestDealEventSent extends SuperSignal{
        public function S_EscrowRequestDealEventSent(){
            super("S_EscrowRequestDealEventSent");
        }
        public function invoke(data:EscrowDealEventSentRequestVO):void{
            _invoke(data);
        }
    }
}
