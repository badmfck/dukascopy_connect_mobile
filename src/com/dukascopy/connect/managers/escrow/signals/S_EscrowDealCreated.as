package com.dukascopy.connect.managers.escrow.signals
{
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
    import com.telefision.sys.signals.SuperSignal;
    import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;

    public class S_EscrowDealCreated extends SuperSignal{
        public function S_EscrowDealCreated(){
            super("S_EscrowDealCreated");
        }
        public function invoke(dealData:EscrowMessageData):void{
            _invoke(dealData);
        }
    }
}