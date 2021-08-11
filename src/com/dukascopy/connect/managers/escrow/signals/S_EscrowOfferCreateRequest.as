package com.dukascopy.connect.managers.escrow.signals
{
    import com.telefision.sys.signals.SuperSignal;
    
    public class S_EscrowOfferCreateRequest extends SuperSignal{
        public function S_EscrowOfferCreateRequest(){
            super("S_EscrowOfferCreateRequest");
        }

        public function invoke(offer:*):void{
            _invoke(offer);
        }
    }
}