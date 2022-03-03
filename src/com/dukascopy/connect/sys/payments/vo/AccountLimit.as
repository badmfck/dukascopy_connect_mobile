package com.dukascopy.connect.sys.payments.vo {
	
	import com.dukascopy.langs.Lang;
	
	public class AccountLimit {
		
		// For Dukascopy Payments EU there are currently 6 possible accountLimits:
		public static var IDENTIFICATION_LIMIT_DEPOSITS:String = "IDENTIFICATION_LIMIT_DEPOSITS";
		public static var IDENTIFICATION_LIMIT_WITHDRAWALS:String = "IDENTIFICATION_LIMIT_WITHDRAWALS";
		
		public static var INCOMING_LIMIT_AMOUNT_1M:String = "INCOMING_LIMIT_AMOUNT_1M";
		public static var OUTGOING_LIMIT_AMOUNT_1M:String = "OUTGOING_LIMIT_AMOUNT_1M";
		
		public static var TURNOVER_NOKYC_COUNT:String = "TURNOVER_NOKYC_COUNT";
		public static var TURNOVER_NOKYC_EUR:String = "TURNOVER_NOKYC_EUR";
		
		// For Swiss Payments
		public static var TOTAL_EQUITY_USD:String = "TOTAL_EQUITY_USD";
		public static var DUKAPAY_INCOMING_LIMIT_AMOUNT_Q:String = "DUKAPAY_INCOMING_LIMIT_AMOUNT_Q";
		
		public static var TYPE_BEST_MARKET_PRICE:String = "BEST_MARKET_PRICE";
		
		public static var TYPE_FC_BALANCE:String = "FC_BALANCE";
		public static var TYPE_FC_CURRENT_BALANCE:String = "FC_CURRENT_BALANCE";
		public static var TYPE_FC_ANNUAL_RETURN:String = "FC_ANNUAL_RETURN";
		public static var TYPE_FC_ANNUAL_RETURN_FC:String = "FC_ANNUAL_RETURN_FC";
		public static var TYPE_FC_CLIENT_CODE:String = "FC_CLIENT_CODE";
		public static var TYPE_FC_NEED_TO_HAVE:String = "FC_NEED_TO_HAVE";
		public static var TYPE_FC_NEED_TO_HAVE_MONTHLY:String = "TYPE_FC_NEED_TO_HAVE_MONTHLY";
		public static var TYPE_FC_NEED_TO_ADD:String = "FC_NEED_TO_ADD";
		public static var TYPE_FC_EXPECTED_INCOME:String = "FC_EXPECTED_INCOME";
		
		public static var TYPE_COIN_TOTAL:String = "TYPE_COIN_TOTAL";
		public static var TYPE_COIN_STAT_TRADES_BUY:String = "TYPE_COIN_STAT_TRADES_BUY";
		public static var TYPE_COIN_STAT_TRADES_SELL:String = "TYPE_COIN_STAT_TRADES_SELL";
		public static var TYPE_COIN_STAT_TOTAL_BUY:String = "TYPE_COIN_STAT_TOTAL_BUY";
		public static var TYPE_COIN_STAT_TOTAL_BUY_ACTIVE:String = "TYPE_COIN_STAT_TOTAL_BUY_ACTIVE";
		public static var TYPE_COIN_STAT_TOTAL_SELL:String = "TYPE_COIN_STAT_TOTAL_SELL";
		public static var TYPE_COIN_STAT_TOTAL_SELL_ACTIVE:String = "TYPE_COIN_STAT_TOTAL_SELL_ACTIVE";
		public static var TYPE_COIN_STAT_AVG_PRICE_BUY:String = "TYPE_COIN_STAT_AVG_PRICE_BUY";
		public static var TYPE_COIN_STAT_AVG_PRICE_SELL:String = "TYPE_COIN_STAT_AVG_PRICE_SELL";
		
		public static var FIELD_DETAILS_TYPE:String = "FIELD_DETAILS_TYPE";
		public static var FIELD_DETAILS_SECURED:String = "FIELD_DETAILS_SECURED";
		public static var FIELD_DETAILS_UID:String = "FIELD_DETAILS_UID";
		public static var FIELD_DETAILS_AMOUNT:String = "FIELD_DETAILS_AMOUNT";
		public static var FIELD_DETAILS_STATUS:String = "FIELD_DETAILS_STATUS";
		public static var FIELD_DETAILS_CREATED:String = "FIELD_DETAILS_CREATED";
		public static var FIELD_DETAILS_UPDATED:String = "FIELD_DETAILS_UPDATED";
		public static var FIELD_DETAILS_DESC:String = "FIELD_DETAILS_DESC";
		public static var FIELD_DETAILS_FEE:String = "FIELD_DETAILS_FEE";
		public static var FIELD_DETAILS_FROM:String = "FIELD_DETAILS_FROM";
		public static var FIELD_DETAILS_TO:String = "FIELD_DETAILS_TO";
		public static var FIELD_DETAILS_MESSAGE:String = "FIELD_DETAILS_MESSAGE";
		
		public static var FIELD_SWAP_DETAILS_AMOUNT:String = "FIELD_SWAP_DETAILS_AMOUNT";
		public static var FIELD_SWAP_DETAILS_AMOUNT_RECEIVED:String = "FIELD_SWAP_DETAILS_AMOUNT_RECEIVED";
		public static var FIELD_SWAP_DETAILS_AMOUNT_BUYBACK:String = "FIELD_SWAP_DETAILS_AMOUNT_BUYBACK";
		public static var FIELD_SWAP_DETAILS_DATE_BUYBACK:String = "FIELD_SWAP_DETAILS_DATE_BUYBACK";
		public static var FIELD_SWAP_DETAILS_PROLONG_FEE:String = "FIELD_SWAP_DETAILS_PROLONG_FEE";
		public static var FIELD_SWAP_DETAILS_STATUS:String = "FIELD_SWAP_DETAILS_STATUS";
		public static var FIELD_SWAP_DETAILS_DATE_CREATED:String = "FIELD_SWAP_DETAILS_DATE_CREATED";
		public static var FIELD_SWAP_DETAILS_CODE:String = "FIELD_SWAP_DETAILS_CODE";
		public static var FIELD_SWAP_DETAILS_ROLLED_OVER:String = "FIELD_SWAP_DETAILS_ROLLED_OVER";
		public static var FIELD_SWAP_DETAILS_ADDRESS:String = "FIELD_SWAP_DETAILS_ADDRESS";
		
		static public function getLimitLabelsByType(type:String):String {
			switch (type) {
				case AccountLimit.IDENTIFICATION_LIMIT_DEPOSITS : {
					return Lang.IDENTIFICATION_LIMIT_DEPOSITS;
				}
				case AccountLimit.IDENTIFICATION_LIMIT_WITHDRAWALS : {
					return Lang.IDENTIFICATION_LIMIT_WITHDRAWALS;
				}
				case AccountLimit.INCOMING_LIMIT_AMOUNT_1M : {
					return Lang.INCOMING_LIMIT_AMOUNT_1M;
				}
				case AccountLimit.OUTGOING_LIMIT_AMOUNT_1M : {
					return Lang.OUTGOING_LIMIT_AMOUNT_1M;
				}
				case AccountLimit.TOTAL_EQUITY_USD : {
					return Lang.TOTAL_EQUITY_USD;
				}
				case AccountLimit.DUKAPAY_INCOMING_LIMIT_AMOUNT_Q : {
					return Lang.DUKAPAY_INCOMING_LIMIT_AMOUNT_Q;
				}
			}
			return "";
		}
		
		static public function getLimitBotLabelsByType(type:String):String {
			var monthkey:String = "month_" + new Date().getMonth();
			switch (type) {
				case AccountLimit.TOTAL_EQUITY_USD : {
					return Lang.TOTAL_EQUITY_USD_BOT;
				}
				case AccountLimit.DUKAPAY_INCOMING_LIMIT_AMOUNT_Q : {
					return Lang.DUKAPAY_INCOMING_LIMIT_AMOUNT_Q_BOT;
				}
				case AccountLimit.TYPE_BEST_MARKET_PRICE : {
					return Lang.bestMarketPrice;
				}
				case AccountLimit.TYPE_FC_BALANCE : {
					return Lang.fcBalanceNew.replace("%@", Lang[monthkey]);
				}
				case AccountLimit.TYPE_FC_CURRENT_BALANCE : {
					return Lang.fcCurrentBalanceNew.replace("%@", Lang[monthkey]);
				}
				case AccountLimit.TYPE_FC_ANNUAL_RETURN_FC : {
					return Lang.fcAnnualReturnNewFC.replace("%@", Lang[monthkey]);
				}
				case AccountLimit.TYPE_FC_ANNUAL_RETURN : {
					return Lang.fcAnnualReturnNew.replace("%@", Lang[monthkey]);
				}
				case AccountLimit.TYPE_FC_NEED_TO_HAVE : {
					return Lang.fcNeedToHave;
				}
				case AccountLimit.TYPE_FC_NEED_TO_HAVE_MONTHLY : {
					return Lang.fcNeedToHaveMonthly;
				}
				case AccountLimit.TYPE_FC_CLIENT_CODE : {
					return Lang.fcClientCode;
				}
				case AccountLimit.TYPE_FC_NEED_TO_ADD : {
					return Lang.fcNeedToAddNew.replace("%@", Lang[monthkey]);
				}
				case AccountLimit.TYPE_FC_EXPECTED_INCOME : {
					return Lang.fcExpectedIncomeNew.replace("%@", Lang[monthkey]);
				}
				case AccountLimit.TYPE_COIN_TOTAL : {
					return Lang.tStatCoinTotal;
				}
				case AccountLimit.TYPE_COIN_STAT_TRADES_BUY : {
					return Lang.tStatTradesBuy;
				}
				case AccountLimit.TYPE_COIN_STAT_TRADES_SELL : {
					return Lang.tStatTradesSell;
				}
				case AccountLimit.TYPE_COIN_STAT_TOTAL_BUY : {
					return Lang.tStatTotalBuy;
				}
				case AccountLimit.TYPE_COIN_STAT_TOTAL_BUY_ACTIVE : {
					return Lang.tStatTotalBuyActive;
				}
				case AccountLimit.TYPE_COIN_STAT_TOTAL_SELL : {
					return Lang.tStatTotalSell;
				}
				case AccountLimit.TYPE_COIN_STAT_TOTAL_SELL_ACTIVE : {
					return Lang.tStatTotalSellActive;
				}
				case AccountLimit.TYPE_COIN_STAT_AVG_PRICE_BUY : {
					return Lang.tStatCoinAvgPriceBuy;
				}
				case AccountLimit.TYPE_COIN_STAT_AVG_PRICE_SELL : {
					return Lang.tStatCoinAvgPriceSell;
				}
				case AccountLimit.FIELD_DETAILS_TYPE : {
					return Lang.textType; //"Type";
				}
				case AccountLimit.FIELD_DETAILS_SECURED : {
					return Lang.textCodeSecured; //"Code secured";
				}
				case AccountLimit.FIELD_DETAILS_UID : {
					return Lang.textReference; //"Reference";
				}
				case AccountLimit.FIELD_DETAILS_AMOUNT : {
					return Lang.textAmount; //"Amount";
				}
				case AccountLimit.FIELD_DETAILS_STATUS : {
					return Lang.textStatus; //"Status";
				}
				case AccountLimit.FIELD_DETAILS_CREATED : {
					return Lang.textCreated; //"Created";
				}
				case AccountLimit.FIELD_DETAILS_UPDATED : {
					return Lang.textUpdated; //"Updated";
				}
				case AccountLimit.FIELD_DETAILS_DESC : {
					return Lang.textDescription; //"Description";
				}
				case AccountLimit.FIELD_DETAILS_FEE : {
					return Lang.textFee; //"Fee";
				}
				case AccountLimit.FIELD_DETAILS_FROM : {
					return Lang.textFrom; //"From";
				}
				case AccountLimit.FIELD_DETAILS_TO : {
					return Lang.textTo; //"To";
				}
				case AccountLimit.FIELD_DETAILS_MESSAGE : {
					return Lang.textMessage; //"Message";
				}
				case AccountLimit.FIELD_SWAP_DETAILS_AMOUNT : {
					return Lang.textSwapAmount;
				}
				case AccountLimit.FIELD_SWAP_DETAILS_AMOUNT_RECEIVED : {
					return Lang.textSwapReceivedAmount;
				}
				case AccountLimit.FIELD_SWAP_DETAILS_AMOUNT_BUYBACK : {
					return Lang.textSwapBuybackAmount;
				}
				case AccountLimit.FIELD_SWAP_DETAILS_DATE_BUYBACK : {
					return Lang.textSwapBuybackDate;
				}
				case AccountLimit.FIELD_SWAP_DETAILS_PROLONG_FEE : {
					return Lang.textSwapProlongationFee;
				}
				case AccountLimit.FIELD_SWAP_DETAILS_STATUS : {
					return Lang.textStatus;
				}
				case AccountLimit.FIELD_SWAP_DETAILS_DATE_CREATED : {
					return Lang.created.substr(0, 1).toUpperCase() + Lang.created.substr(1).toLowerCase();
				}
				case AccountLimit.FIELD_SWAP_DETAILS_CODE : {
					return Lang.textSwapID;
				}
				case AccountLimit.FIELD_SWAP_DETAILS_ROLLED_OVER : {
					return Lang.textSwapRolledOver;
				}
				case AccountLimit.FIELD_SWAP_DETAILS_ADDRESS : {
					return Lang.textAddress;
				}
			}
			return "";
		}
	}
}