package com.dukascopy.connect.managers.escrow.signals{
    import com.telefision.sys.signals.SuperSignal;
    import com.dukascopy.connect.managers.escrow.EscrowInstrument;

    public class S_EscrowPricesRequest extends SuperSignal{
        public function S_EscrowPricesRequest(){
            super("S_EscrowPricesRequest");
        }
        public function invoke(instruments:Vector.<EscrowInstrument>=null):void{
            _invoke(instruments);
        }
    }
}