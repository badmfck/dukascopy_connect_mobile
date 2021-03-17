package com.dukascopy.connect.type 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FinanceFilterType 
	{
		static public const WITHDRAWAL:String =               "WITHDRAWAL";
		static public const INTERNAL_TRANSFER:String =        "INTERNAL TRANSFER";
		static public const INCOMING_TRANSFER:String =        "INCOMING TRANSFER";
		static public const OUTGOING_TRANSFER:String =        "OUTGOING TRANSFER";
		static public const DEPOSIT:String =                  "DEPOSIT";
		static public const ORDER_OF_PREPAID_CARD:String =    "ORDER OF PREPAID CARD";
		static public const INVESTMENT:String =               "INVESTMENT";
		static public const COIN_TRADE:String =               "COIN TRADE";
		static public const TERM_DEPOSIT:String =             "TERM DEPOSIT";
		static public const COMMISSION_CHARGE:String =        "COMMISSION CHARGE";
		static public const PARTNER_ACCOUNT_TRANSFER:String = "PARTNER ACCOUNT TRANSFER";
		static public const PARTNER_CRYPTO_TRADE:String =     "PARTNER CRYPTO TRADE";
		
		static public const COMPLETED:String = "COMPLETED";
		static public const PENDING:String = "PENDING";
		static public const CANCELLED:String = "CANCELLED";
		
		static public const DATE_RANGE:String = "dateRange";
		
		private var value:String;
		
		public function FinanceFilterType(value:String) 
		{
			this.value = value;
		}
		
		public function get type():String
		{
			return value;
		}
	}
}