package com.dukascopy.connect.data {
	
	import com.dukascopy.connect.vo.users.UserVO;
	import com.greensock.loading.core.DisplayObjectLoader;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CoinTradeOrder {
		
		public var quantity:Number;
		public var price:Number;
		public var fullOrder:Boolean;
		public var expirationTime:Date;
		public var privateOrderReciever:String;
		public var action:String;
		public var additionalData:Object;
		public var reciever:UserVO;
		
		private var _min:Number; 
		
		public function CoinTradeOrder() {
			
		}
	}
}