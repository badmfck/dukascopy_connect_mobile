package com.dukascopy.connect.managers.escrow.signals
{
    import com.telefision.sys.signals.SuperSignal;
    import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;

    public class S_EscrowOfferCreateRequest extends SuperSignal{
        public function S_EscrowOfferCreateRequest(){
            super("S_EscrowOfferCreateRequest");
        }

        public function invoke(offer:EscrowOfferVO):void{
            _invoke(offer);
        }
    }
}