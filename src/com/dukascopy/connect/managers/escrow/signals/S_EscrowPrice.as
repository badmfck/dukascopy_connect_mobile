package com.dukascopy.connect.managers.escrow.signals
{
    import com.telefision.sys.signals.SuperSignal;
    import com.dukascopy.connect.managers.escrow.EscrowInstrument;

    public class S_EscrowPrice extends SuperSignal{
        public function S_EscrowPrice(){
            super("S_EscrowPrice");
        }
        public function invoke(instrument:EscrowInstrument):void{
            _invoke(instrument);
        }
    }
}