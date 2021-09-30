package com.dukascopy.connect.managers.escrow.vo 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CryptoWallet 
	{
		public var wallet:String;
		public var crypto:String;
		
		public function CryptoWallet(crypto:String, wallet:String) 
		{
			this.crypto = crypto;
			this.wallet = wallet;
		}
	}
}