package com.dukascopy.connect.managers.escrow.signals
{
    import com.telefision.sys.signals.SuperSignal;

    public class S_EscrowManagerAvailable extends SuperSignal{
        public function S_EscrowManagerAvailable(){
            super("S_EscrowManagerAvailable")
        }
        public function invoke(callback:Function):void{
            _invoke(callback);
        }
    }
}