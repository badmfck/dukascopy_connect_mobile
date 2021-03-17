package com.dukascopy.connect.type 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BankPhaze 
	{
		static public const EMPTY:String = "EMPTY";
		static public const RTO_STARTED:String = "RTO_STARTED";
		static public const NOTARY:String = "NOTARY";
		static public const REJECT:String = "REJECT";
		static public const ACC_APPROVED:String = "ACC_APPROVED";
		static public const ACC_CREATED:String = "ACC_CREATED";
		static public const VI_COMPLETED:String = "VI_COMPLETED";
		static public const VI_FAIL:String = "VI_FAIL";
		static public const VIDID_QUEUE:String = "VIDID_QUEUE";
		static public const VIDID_PROGRESS:String = "VIDID_PROGRESS";
		static public const VIDID_READY:String = "VIDID_READY";
		static public const VIDID:String = "VIDID";
		static public const CARD:String = "CARD";
		static public const DOCUMENT_SCAN:String = "DOCUMENT_SCAN";
		static public const SOLVENCY_CHECK:String = "SOLVENCY_CHECK";
		static public const ZBX:String = "ZBX";
		static public const DONATE:String = "DONATE";
		//! DEPRECATED
		static public const SCAN:String = "SCAN";
		
		
		public function BankPhaze() 
		{
			
		}
	}
}