package com.dukascopy.connect.managers.escrow.signals
{
    import com.telefision.sys.signals.SuperSignal;

    public class S_EscrowWalletsRequest extends SuperSignal{
        
        public function S_EscrowWalletsRequest(){
            super("S_EscrowWalletsRequest")
        }

        public function invoke(callback:Function):void{
            _invoke(callback);
        }
    }
}