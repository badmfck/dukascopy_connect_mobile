package com.dukascopy.connect.managers.escrow{

    import com.telefision.sys.signals.SuperSignal;

    /**
     * Signal for create Escrow Deal
     */
    
    public class S_EscrowDealCreateRequest extends SuperSignal{
        public function S_EscrowDealCreateRequest(){
            super("S_EscrowDealCreateRequest");
        }
        public function invoke(req:EscrowDealCreateRequest):void{
            _invoke(req);
        }
    }
}