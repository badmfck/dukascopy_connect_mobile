package com.dukascopy.connect.managers.escrow.signals
{
    import com.telefision.sys.signals.SuperSignal;
    import com.dukascopy.connect.managers.escrow.vo.EscrowOffersRequestVO;

    public class S_EscrowOffersRequest extends SuperSignal{
        public function S_EscrowOffersRequest(){
            super("S_EscrowOffersRequest");
        }
        public function invoke(req:EscrowOffersRequestVO=null):void{
            _invoke(req);
        }
    }
}