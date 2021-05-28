package com.dukascopy.connect.managers.escrow
{
    import com.telefision.sys.signals.SuperSignal;

    public class S_EscrowInstruments extends SuperSignal{
        public function S_EscrowInstruments(){
            super("S_EscrowInstruments");
        }
        public function invoke(insturments:Vector.<EscrowInstrument>):void{
            _invoke(insturments);
        }
        
    }
}