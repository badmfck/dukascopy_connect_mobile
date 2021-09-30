package com.dukascopy.connect.managers.escrow.signals
{
	import com.telefision.sys.signals.SuperSignal;

    public class S_CryptoWalletAdd extends SuperSignal{
        public function S_CryptoWalletAdd(){
            super("S_CryptoWalletAdd");
        }
        public function invoke(crypto:String, wallet:String):void{
            _invoke(crypto, wallet);
        }
    }
}