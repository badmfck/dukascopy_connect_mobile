package com.dukascopy.connect.vo.chat {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.utils.TextUtils;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class MoneyTransferMessageVO {
		
		public var comment:String;
		public var currency:String;
		public var amount:Number;
		public var pass:Boolean = false;
		
		public function MoneyTransferMessageVO(data:Object) {
			if (data == null)
				return;
			if ("amount" in data)
				amount = Number(data.amount);
			if ("currency" in data)
				currency = data.currency;
			if ("comment" in data)
				comment = data.comment;
			if ("pass" in data)
				pass = data.pass;
		}
		
		public function dispose():void {
			
		}
	}
}