package com.dukascopy.connect.managers.escrow
{
    import com.telefision.sys.signals.SuperSignal;

    public class S_EscrowRequestInstruments extends SuperSignal{
        public function S_EscrowRequestInstruments(){
            super("S_EscrowRequestInstruments");
        }

        /**
         * Request available instruments
         * listen for S_ESCROW_INSTRUMENTS
         */
        public function invoke():void{
            _invoke()
        }
    }
}