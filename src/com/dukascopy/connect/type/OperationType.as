package com.dukascopy.connect.type {
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OperationType {
		
		static public const MCA_MONEY_EXCHANGE:String = "mcaMoneyExchange";
		static public const SAVING_MONEY_EXCHANGE:String = "savingMoneyExchange";
		static public const SAVING_MONEY_TRANSFER:String = "fromMcaToSaving";
		static public const MCA_MONEY_TRANSFER:String = "fromSavingToMca";
		
		public function OperationType() { }
	}
}