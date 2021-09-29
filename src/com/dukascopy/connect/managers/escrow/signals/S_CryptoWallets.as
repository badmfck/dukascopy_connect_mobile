package com.dukascopy.connect.managers.escrow.signals
{
	import com.dukascopy.connect.managers.escrow.vo.CryptoWallet;
	import com.telefision.sys.signals.SuperSignal;

    public class S_CryptoWallets extends SuperSignal{
        public function S_CryptoWallets(){
            super("S_CryptoWallets");
        }
        public function invoke(wallets:Vector.<CryptoWallet>):void{
            _invoke(wallets);
        }
    }
}