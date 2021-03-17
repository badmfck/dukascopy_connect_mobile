package com.dukascopy.connect.type {
	import com.dukascopy.langs.Lang;

	/**
	 * ...
	 * @author Sergey Dobarin & Aleksei L
	 */
	
	public class TransferType {
		
		static public const DEPOSIT:String = "DEPOSIT";//
		static public const WITHDRAWAL:String = "WITHDRAWAL";//
		static public const TRANSACTION:String = "TRANSACTION";//
		static public const INTERNAL_TRANSFER:String = "INTERNAL TRANSFER";//
		static public const INCOMING_TRANSFER:String = "INCOMING TRANSFER";//
		static public const OUTGOING_TRANSFER:String = "OUTGOING TRANSFER";//
		static public const ORDER_OF_PREPAID_CARD:String = "ORDER OF PREPAID CARD";
		static public const MERCHANT_TRANSFER:String = "MERCHANT TRANSFER";
		static public const INVESTMENT:String = "INVESTMENT";
		/**
		 * Temp type - used for client and for en lang
		 */
		static public const PREPAID_CARD_ORDER:String = "Prepaid Card Order";

		static public const WITHDRAWAL_FEE:String = "WITHDRAWAL FEE";
		static public const TRANSFER_FEE:String = "TRANSFER FEE";

		static public const TAX_FEE:String = "TAX FEE";
		static public const REVERSE_WITHDRAWAL_FEE:String = "REVERSE WITHDRAWAL FEE";
		static public const REVERSE_WITHDRAWAL:String = "REVERSE WITHDRAWAL";
		static public const REVERSE_TRANSFER_FEE:String = "REVERSE TRANSFER FEE";
		static public const REVERSE_PREPAID_CARD_WITHDRAWAL_FEE:String = "REVERSE PREPAID CARD WITHDRAWAL FEE";
		static public const REVERSE_PREPAID_CARD_WITHDRAWAL:String = "REVERSE PREPAID CARD WITHDRAWAL";
		static public const REVERSE_PREPAID_CARD_FEE:String = "REVERSE PREPAID CARD FEE";
		static public const REVERSE_INTERNAL_TRANSFER:String = "REVERSE INTERNAL TRANSFER";
		static public const REVERSE_DEPOSITE_FEE:String = "REVERSE DEPOSITE FEE";
		static public const REVERSE_DEPOSITE:String = "REVERSE DEPOSITE";
		static public const REFUND:String = "REFUND";
		static public const PREPAID_CARD_WITHDRAWAL:String = "PREPAID CARD WITHDRAWAL";
		static public const PREPAID_CARD_WITHDRAWAL_CORNER:String = "PREPAID CARD WITHDRAWAL CORNER";
		static public const PREPAID_CARD_WITHDRAWAL_FEE:String = "PREPAID CARD WITHDRAWAL FEE";
		static public const PREPAID_CARD_FEE:String = "PREPAID CARD FEE";
		static public const DEPOSIT_FEE:String = "DEPOSIT FEE";
		static public const CORRECTION:String = "CORRECTION";
		
		static public const DEBIT:String = "DEBIT";
		static public const CREDIT:String = "CREDIT";
		
		public function TransferType() { }

		public static function getTextByType(type:String):String {
			var result:String = "";

			switch(type.toUpperCase()){
				case TransferType.DEPOSIT:{
					result = Lang.TEXT_DEPOSIT;
					break;
				}
				case TransferType.INTERNAL_TRANSFER:{
					result = Lang.TEXT_INTERNAL_TRANSFER;
					break;
				}
				case TransferType.WITHDRAWAL:{
					result = Lang.TEXT_WITHDRAWAL;
					break;
				}
				case TransferType.ORDER_OF_PREPAID_CARD:{
					result = Lang.TEXT_PREPAID_CARD_ORDER;
					break;
				}
				case TransferType.OUTGOING_TRANSFER:{
					result = Lang.TEXT_OUTGOING_TRANSFER;
					break;
				}
				case TransferType.INCOMING_TRANSFER:{
					result = Lang.TEXT_INCOMING_TRANSFER;
					break;
				}
				case TransferType.PREPAID_CARD_ORDER.toUpperCase():{
					result = Lang.TEXT_PREPAID_CARD_ORDER;
					break;
				}
				
				case TransferType.MERCHANT_TRANSFER:{
					result = Lang.TEXT_MERCHANT_TRANSFER;
					break;
				}
				default:{
					//result = Lang.TEXT_ALL_TYPES
					result = type;
					break;
				}
			}
			return result;
		}
	}
}