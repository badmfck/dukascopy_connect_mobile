package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDuration;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ExtensionRequestData 
	{
		public var extension:Extension;
		public var wallet:String;
		public var duration:SubscriptionDuration;
		public var productId:Number;
		public var userUID:String;
		
		private var _id:String;
		
		public function get id():String 
		{
			return _id;
		}
		
		public function ExtensionRequestData(id:String) 
		{
			this._id = id;
		}
	}
}