package com.dukascopy.connect.sys.payments.vo {
	
	import com.dukascopy.connect.sys.payments.PayManager;
	
	/**
	 * ...
	 * @author Aleksei Leschenko. Telefision TEAM Kiev. 02.05.2017
	 */

	public class SettingPWP {
		
		private var _PWP_ENABLED:Boolean;
		private var _PWP_IS_EMPTY:Boolean = true;
		private var _PWP_LIMIT_AMOUNT:int = -1;
		private var _PWP_LIMIT_DAILY:int = -1;
		
		public function SettingPWP(data:Object) {
			update(data);
		}
		
		public function update(data:Object):void {
			if (data == null)
				return;
			var key:String;
			key = "PWP_ENABLED";
			if (key in data == true) {
				if (data[key] != null)
					_PWP_ENABLED = data[key] == "1" ? true : false;
				else
					_PWP_ENABLED = false;
				_PWP_IS_EMPTY = false;
			} else
				_PWP_IS_EMPTY = true;
			key = "PWP_LIMIT_AMOUNT";
			if (key in data == true) {
				if (data[key] != null)
					_PWP_LIMIT_AMOUNT = data[key];
				else
					_PWP_LIMIT_AMOUNT = -1;
			}
			key = "PWP_LIMIT_DAILY";
			if (key in data == true) {
				if(data[key] != null)
					_PWP_LIMIT_DAILY = data[key];
				else
					_PWP_LIMIT_DAILY = -1;
			}
		}
		
		public function get PWP_ENABLED():Boolean {
			return _PWP_ENABLED;
		}
		
		public function get PWP_LIMIT_AMOUNT():int {
			if (_PWP_LIMIT_AMOUNT == -1 )
				return maxPWPLimitAmount;
			return _PWP_LIMIT_AMOUNT;
		}
		
		public function get PWP_LIMIT_DAILY():int {
			if (_PWP_LIMIT_DAILY == -1 )
				return maxPWPLimitDaily;
			return _PWP_LIMIT_DAILY;
		}
		

		public function get maxPWPLimitAmount():int {
			if (PayManager.systemOptions == null) {
				trace('LEHA TUT PROBLEMA!');
				return 0;
			}
			return int(PayManager.systemOptions.max_pwp_limit_amount);
		}
		
		public function get maxPWPLimitDaily():int {
			if (PayManager.systemOptions == null) {
				trace('LEHA TUT PROBLEMA!');
				return 0;
			}
			return int(PayManager.systemOptions.max_pwp_limit_daily);
		}
		
		public function get PWP_IS_EMPTY():Boolean {
			return _PWP_IS_EMPTY;
		}
	}
}