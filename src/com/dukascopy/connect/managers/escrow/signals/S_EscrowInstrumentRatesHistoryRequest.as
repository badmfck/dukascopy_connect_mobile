package com.dukascopy.connect.managers.escrow.signals
{
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
    import com.telefision.sys.signals.SuperSignal;
    
    public class S_EscrowInstrumentRatesHistoryRequest extends SuperSignal{
        public function S_EscrowInstrumentRatesHistoryRequest(){
            super("S_EscrowOfferCreateRequest");
        }

        public function invoke(instrument:EscrowInstrument):void{
            _invoke(instrument);
        }
    }
}