package com.dukascopy.connect.sys.payments.vo {
	
	public class SystemOptionsVO {
		public var coin_llf_price_limit:Number;
		public var coin_llf_eur_per_coin:Number;

		public var cardDepositCurrencies:Array;
		public var cardWithdrawalCurrencies:Array;
		
		public var currencyList:Array;
		public var terms:String;
		public var ppcardsCurrencies:Array;
		public var investmentCurrencies:Array;
		public var investmentDeliveryCurrencies:Array;
		public var investmentDisclaimer:String;
		public var currencyDecimalRules:Object;
		public var currencySymbols:Object;
		public var max_pwp_limit_amount:Number;
		public var max_pwp_limit_daily:Number;
		public var pp_cards_actions_disabled:Boolean;
		public var disable_plastic_ppcard_order:Boolean;
		public var coinMinFiatValue:Number;
		public var investmentsByGroups:Object;
		public var incomingQuarterlyLimitCoefficient:Number;
		public var equityLimitThreshold:Number;
		
		public var ppcardsTypes:Array = [
			{ title:"Visa", type:"VISA" },
			{ title:"MasterCard", type:"MC" }
		];
		
		
		public var ppDelivery:Array = [
			{ title:"textDeliveryStandard", type:"STANDARD" },
			{ title:"textDeliveryExpress", type:"EXPEDITED" }
		];
		
		public function SystemOptionsVO() { }
	//	
		public function update(data:Object):void {
			if (data == null)
				return;
			var key:String = 'currency-list';
			if (key in data == true)
				currencyList = data[key];
			key = 'gtc-text';
			if (key in data == true)
				terms = data[key];
			key = 'ppcards-currency';
			if (key in data == true)
				ppcardsCurrencies = data[key];
			key = 'max_pwp_limit_amount';
			if (key in data == true)
				max_pwp_limit_amount = data[key];
			key = 'max_pwp_limit_daily';
			if (key in data == true)
				max_pwp_limit_daily = data[key];
			key = 'ppcards-actions-disabled';
			if (key in data == true)
				pp_cards_actions_disabled = data[key];
			key = 'disable_plastic_ppcard_order';
			if (key in data == true)
				disable_plastic_ppcard_order = data[key];
			key = 'currency-list-investment';
			if (key in data == true)
				investmentCurrencies = data[key];
			key = 'currency-list-investment-delivery';
			if (key in data == true)
				investmentDeliveryCurrencies = data[key];
			key = 'currency-decimal-rules';
			if (key in data == true)
				currencyDecimalRules = data[key];
			key = 'currency-symbols';
			if (key in data == true)
				currencySymbols = data[key];
			key = 'invest_disclaimer';
			if (key in data == true)
				investmentDisclaimer = data[key];
			key = 'coin-min-fiat-value';
			if (key in data == true)
				coinMinFiatValue = data[key];
			
			key = 'equity_limit_threshold';
			if (key in data == true)
				equityLimitThreshold = data[key];
			key = 'incoming_quarterly_limit_coefficient';
			if (key in data == true)
				incomingQuarterlyLimitCoefficient = data[key];
				
			key = 'coin_llf_price_limit';
			if (key in data == true)
				coin_llf_price_limit = data[key];

			key = 'coin_llf_eur_per_coin';
			if (key in data == true)
				coin_llf_eur_per_coin = data[key];

			key = 'currency-list-investment-groups';
			if (key in data == true)
				investmentsByGroups = data[key];
			if ("currency-operation" in data == true && data["currency-operation"] != null) {
				if ("deposit" in data["currency-operation"] && data["currency-operation"]["deposit"] != null && "linked" in data["currency-operation"]["deposit"]) {
					cardDepositCurrencies = data["currency-operation"]["deposit"]["linked"];
				}
				if ("withdrawal" in data["currency-operation"] && data["currency-operation"]["withdrawal"] != null && "linked" in data["currency-operation"]["withdrawal"]) {
					cardWithdrawalCurrencies = data["currency-operation"]["withdrawal"]["linked"];
				}
			}
		}
	}
}