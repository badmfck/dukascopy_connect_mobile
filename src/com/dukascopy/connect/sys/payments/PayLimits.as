package com.dukascopy.connect.sys.payments {
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PayLimits {
		
		static private var payLimitsMax:Object = {
			"DEF":100,
			"PLN":420,
			"RUB":6000,
			"JPY":11000,
			"CNH":700
		};
		
		static private var payLimitsMin:Object = {
			"DEF":1,
			"PLN":4,
			"RUB":60,
			"JPY":110,
			"CNH":7
		};
		
		static private var payLimitsMaxPublic:Object = {
			"DEF":100,
			"PLN":420,
			"RUB":6000,
			"JPY":11000,
			"CNH":700
		};
		
		static private var payLimitsMinPublic:Object = {
			"DEF":3,
			"EUR":3,
			"GBP":3,
			"CHF":3,
			"USD":3,
			"PLN":13,
			"RUB":180,
			"JPY":330,
			"CNH":21
		};
		
		public function PayLimits() { }
		
		static public function getTipsLimitMaxForCurrency(cur:String, type:String):int {
			if (type == QuestionsManager.QUESTION_TYPE_PRIVATE) {
				if (cur in payLimitsMax)
					return payLimitsMax[cur.toUpperCase()];
				return payLimitsMax["DEF"];
			} else {
				if (cur in payLimitsMaxPublic)
					return payLimitsMaxPublic[cur.toUpperCase()];
				return payLimitsMaxPublic["DEF"];
			}
			return 0;
		}
		
		static public function getTipsLimitMinForCurrency(cur:String, type):Number {
			if (type == QuestionsManager.QUESTION_TYPE_PRIVATE) {
				if (cur in payLimitsMin)
					return payLimitsMin[cur.toUpperCase()];
				return payLimitsMin["DEF"];
			} else {
				if (cur in payLimitsMinPublic)
					return payLimitsMinPublic[cur.toUpperCase()];
				return payLimitsMinPublic["DEF"];
			}
			return 0;
		}
	}
}