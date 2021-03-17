package com.dukascopy.connect.sys.applicationShop.serverTask {
	
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.applicationShop.serverTask.BuyBanProtectionServerTask;
	import com.dukascopy.connect.sys.applicationShop.serverTask.BuyBanServerTask;
	import com.dukascopy.connect.sys.applicationShop.serverTask.BuyUnbanServerTask;
	import com.dukascopy.connect.sys.applicationShop.serverTask.BuyUnbanServerTask;
	import com.dukascopy.connect.sys.applicationShop.serverTask.IServerTask;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ShopServerTask {
		
		private var callback:Function;
		private var action:IServerTask;
		private var payWallet:String;
		public var resultData:Object;
		public var requestId:String;
		public var failMessage:String;
		public var type:int;
		
		public static const BUY_BAN:int = 1;
		public static const BUY_PROTECTION:int = 2;
		public static const BUY_UNBAN:int = 3;
		public static const BUY_SHOP_PRODUCT:int = 4;
		public static const BUY_QUESTION_PRODUCT:int = 5;
		static public const BUY_EXTENSION_PRODUCT:int = 6;
		static public const BUY_PAID_CHANNEL_START:int = 7;
		
		static public const TASK_STATUS_PAID:String = "taskStatusPaid";
		static public const TASK_STATUS_NEW:String = "taskStatusNew";
		
		//TODO:;
		public var data:Object;
		public var userUID:String;
		
		public function ShopServerTask(type:int, requestId:String, payWallet:String) {
			this.type = type;
			this.requestId = requestId;
			this.payWallet = payWallet;
		}
		
		public function execute(callback:Function):void {
			this.callback = callback;
			
			switch(type) {
				case BUY_BAN:
				{
					action = new BuyBanServerTask(data as UserBan911VO, payWallet);
					break;
				}
				case BUY_UNBAN:
				{
					action = new BuyUnbanServerTask(data as UserBan911VO, payWallet);
					break;
				}
				case BUY_PROTECTION:
				{
					action = new BuyBanProtectionServerTask(data as UserBan911VO, payWallet);
					break;
				}
				case BUY_SHOP_PRODUCT:
				{
					action = new BuyProductServerTask(data as ShopProduct, payWallet);
					break;
				}
				case BUY_QUESTION_PRODUCT:
				{
					action = new BuyQuestionProductServerTask(requestId, payWallet);
					break;
				}
				
				case BUY_EXTENSION_PRODUCT:
				{
					action = new BuyFlowerServerTask(data as ShopProduct, payWallet);
					break;
				}
				
				case BUY_PAID_CHANNEL_START:
				{
					action = new PaidChannelStartServerTask(data as ShopProduct, payWallet);
					break;
				}
			}
			
			if (action != null) {
				action.getSuccessSignal().add(onTaskSuccess);
				action.getFailSignal().add(onTaskFail);
				action.execute();
			} else {
				ApplicationErrors.add("wrong type");
				if (callback != null)
					callback(false, this);
			}
		}
		
		public function dispose():void {
			clearAction();
			callback = null;
			resultData = null;
		}
		
		public function getStatus():String {
			if (action != null)
				return action.getStatus();
			return null;
		}
		
		private function onTaskSuccess(data:Object = null):void {
			clearAction();
			resultData = data;
			callback(true, this);
		}
		
		private function onTaskFail(message:String = null):void {
			clearAction();
			failMessage = message;
			callback(false, this);
		}
		
		private function clearAction():void {
			if (action != null) {
				action.dispose();
				action = null;
			}
		}
	}
}