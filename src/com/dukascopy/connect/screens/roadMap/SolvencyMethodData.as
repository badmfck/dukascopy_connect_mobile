package com.dukascopy.connect.screens.roadMap 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SolvencyMethodData 
	{
		public var title:String;
		public var subtitle:String;
		public var selected:Boolean;
		public var icon:Class;
		public var type:String;
		
		static public const METHOD_CARD_DEPOSIT:String = "methodCardDeposit";
		static public const METHOD_CRYPTO_DEPOSIT:String = "methodCryptoDeposit";
		static public const METHOD_ASK_FRIEND:String = "methodAskFriend";
		static public const METHOD_WIRE_DEPOSIT:String = "methodWireDeposit";
		
		public function SolvencyMethodData() 
		{
			
		}
	}
}