package com.dukascopy.connect.managers.escrow
{
    import com.telefision.sys.signals.SuperSignal;

    public class S_EscrowDealsRequest extends SuperSignal{
        public function S_EscrowDealsRequest(){
            super("S_EscrowDealsRequest")
        }
        public function invoke():void{
            _invoke(null);
        }
    }
}