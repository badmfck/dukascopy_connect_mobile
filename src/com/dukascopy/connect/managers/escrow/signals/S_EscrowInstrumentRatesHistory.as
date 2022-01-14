package com.dukascopy.connect.managers.escrow.signals
{
	import com.dukascopy.connect.managers.crypto.CryptoRates;
	import com.dukascopy.connect.managers.crypto.InvestmentRates;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
    import com.telefision.sys.signals.SuperSignal;
    
    public class S_EscrowInstrumentRatesHistory extends SuperSignal{
        public function S_EscrowInstrumentRatesHistory(){
            super("S_EscrowInstrumentRatesHistory");
        }

        public function invoke(instrumentCode:String, ratesHistory:InvestmentRates):void{
            _invoke(instrumentCode, ratesHistory);
        }
    }
}