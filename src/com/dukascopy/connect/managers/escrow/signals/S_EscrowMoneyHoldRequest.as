package com.dukascopy.connect.managers.escrow.signals
{
    import com.telefision.sys.signals.SuperSignal;

    public class S_EscrowMoneyHoldRequest extends SuperSignal{
        public function S_EscrowMoneyHoldRequest(){
            super("S_EscrowMoneyHoldRequest")
        }
        public function invoke(callback:Function):void{
            _invoke(callback);
        }
    }
}