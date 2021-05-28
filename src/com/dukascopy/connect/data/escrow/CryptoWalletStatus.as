package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CryptoWalletStatus 
	{
		private var _status:String;
		public static const READY:String = "READY";
		public static const LINKAGE_REQUIRED:String = "LINKAGE_REQUIRED";
		
		public static const ready:CryptoWalletStatus = new CryptoWalletStatus(CryptoWalletStatus.READY);
		public static const linkageRequired:CryptoWalletStatus = new CryptoWalletStatus(CryptoWalletStatus.LINKAGE_REQUIRED);
		
		public function get status():String 
		{
			return _status;
		}
		
		public function CryptoWalletStatus(status:String) 
		{
			this._status = status;
		}
	}
}