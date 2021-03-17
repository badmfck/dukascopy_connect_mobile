package com.dukascopy.connect.sys.applicationShop 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.paidChat.PaidChatData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.dialogs.paidChat.OpenPaidChatPopup;
	import com.dukascopy.connect.screens.dialogs.paidChat.PaidChannelPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.shop.ProductsScreen;
	import com.dukascopy.connect.screens.shop.SubscriptionsScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.parser.OrderDataParser;
	import com.dukascopy.connect.sys.applicationShop.parser.ShopProductDataParser;
	import com.dukascopy.connect.sys.applicationShop.product.ProductCost;
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDuration;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDurationType;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class Shop 
	{
		
		static private var serverTasks:Vector.<ShopServerTask>;
		static private var currentServerTask:ShopServerTask;
		static private var orders:Vector.<Order>;
		static private var products:Vector.<ShopProduct>;
		static private var productBuyers:Array;
		static private var getOrdersBusy:Boolean;
		static private var getProductsBusy:Boolean;
		static private var paidChatData:PaidChatData;
		static private var paidChatPendingTransactions:Array;
		static private var chatBuyers:Vector.<UserVO>;
		
		static public var S_PRODUCT_BUY_RESPONSE:Signal = new Signal("Shop.S_PRODUCT_BUY_RESPONSE");
		static public var S_ORDERS:Signal = new Signal("Shop.S_ORDERS");
		static public var S_PRODUCTS:Signal = new Signal("Shop.S_PRODUCTS");
		static public var S_PRODUCTS_BUYERS:Signal = new Signal("Shop.S_PRODUCTS_BUYERS");
		static public var S_CHAT_BUYERS:Signal = new Signal("Shop.S_CHAT_BUYERS");
		static public var S_MY_PAID_CHAT_UPDATE:Signal = new Signal("Shop.S_MY_PAID_CHAT_UPDATE");
		
		public function Shop() 
		{
			
		}
		
		public static function init():void
		{
			productBuyers = new Array();
			Auth.S_NEED_AUTHORIZATION.add(clean);
		}
		
		static private function clean():void {
			
			//!TODO: dispose all orders;
			
			productBuyers = null;
			orders = null;
			products = null;
			serverTasks = null;
			if (currentServerTask != null) {
				currentServerTask.dispose();
			}
			
			currentServerTask = null;
			getOrdersBusy = false;
			getProductsBusy = false;
			
			productBuyers = new Array();
		}
		
		static public function onFailedFinishRequest(buyUnban:int):void {
			//!TODO:
		}
		
		static public function buyProduct(product:ShopProduct, requestId:String, payWallet:String):void {
			var task:ShopServerTask = new ShopServerTask(ShopServerTask.BUY_SHOP_PRODUCT, requestId, payWallet);
			task.data = product;
			addTask(task);
		}
		
		static public function buyPaidChannelStart(product:ShopProduct, requestId:String, payWallet:String):void {
			var task:ShopServerTask = new ShopServerTask(ShopServerTask.BUY_PAID_CHANNEL_START, requestId, payWallet);
			task.data = product;
			addTask(task);
		}
		
		static public function buyQuestionProduct(qUID:String, payWallet:String):void {
			var task:ShopServerTask = new ShopServerTask(ShopServerTask.BUY_QUESTION_PRODUCT, qUID, payWallet);
			
			addTask(task);
		}
		
		static public function buyExtensionProduct(product:ShopProduct, requestId:String, payWallet:String):void {
			var task:ShopServerTask = new ShopServerTask(ShopServerTask.BUY_EXTENSION_PRODUCT, requestId, payWallet);
			task.data = product;
			addTask(task);
		}
		
		static public function showMySubscriptions():void {
			MobileGui.changeMainScreen(SubscriptionsScreen);
		}
		
		static public function getOrders():Vector.<Order> {
			if (orders == null && getOrdersBusy == false) {
				loadOrdersFromPHP();
			}
			return orders;
		}
		
		static public function showMyProducts():void {
			MobileGui.changeMainScreen(ProductsScreen);
		}
		
		static public function getProducts():Vector.<ShopProduct> {
			if (products == null && getProductsBusy == false) {
				loadProductsFromPHP();
			}
			return products;
		}
		
		static public function getChatBuyers():Vector.<UserVO> {
			if (chatBuyers == null) {
				PHP.userAccess_stat(onChatBuyersLoaded);
			}
			return chatBuyers;
		}
		
		private static function onChatBuyersLoaded(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				if (respond.errorMsg == PHP.NETWORK_ERROR) {
					//!TODO:
				} else {
					//!TODO:
				}
			} else {
				if ("data" in respond && respond.data != null && respond.data is Array) {
					chatBuyers = new Vector.<UserVO>();
					var user:UserVO;
					var l:int = respond.data.length;
					for (var j:int = 0; j < l; j++) 
					{
						user = UsersManager.getUserByChatUserObject(respond.data[j].user);
						chatBuyers.push(user);
					}
					S_CHAT_BUYERS.invoke();
				}
			}
			respond.dispose();
		}
		
		static public function getProductBuyers(product:ShopProduct):Vector.<Order> {
			if (productBuyers[product.id.toString()] == null) {
				PHP.getProductBuyers(onProductBuyersLoaded, product.id);
			}
			return productBuyers[product.id.toString()];
		}
		
		static public function buyChannelAccess(uid:String, product:ShopProduct):void {
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, PaidChannelPopup, { chatUID:uid, product:product });
		}
		
		static public function isPaidChannelsAvaliable():Boolean {
			if ((Auth.companyID != null && Auth.companyID == Config.COMPANY_ID) || Config.ADMIN_UIDS.indexOf(Auth.uid)) {
				return true;
			}
			return Config.PAID_CHANNEL;
		}
		
		static public function createProduct(productType:ProductType, requestID:String):ShopProduct 
		{
			return new ShopProduct(
						new ProductType(ProductType.TYPE_PAID_CHANNEL), 
						new SubscriptionDuration(new SubscriptionDurationType(SubscriptionDurationType.MOUNTH)), 
						new ProductCost(1, TypeCurrency.DCO), 1);
		}
		
		static private function setMyPaidChat(value:PaidChatData):void 
		{
			paidChatData = value;
		}
		
		static public function getMyPaidChatData():PaidChatData 
		{
			return paidChatData;
		}
		
		static public function disablePaidChat():void 
		{
			PHP.userAccess_apply(onDisablePaidChatResponse, null);
		}
		
		static public function updateMyPaidBan():void 
		{
			PHP.userAccess_check(onPaidBanStatus, Auth.uid);
		}
		
		static public function applyPaidChat(request:PaidChatData):void 
		{
			PHP.userAccess_apply(setPaidModeResponse, request);
		}
		
		static public function buyPaidChat(data:PaidChatData):void 
		{
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, OpenPaidChatPopup, data);
		}
		
		static public function addPaidChatPendingTransaction(userUid:String, transactionId:String):void 
		{
			if (paidChatPendingTransactions == null)
			{
				paidChatPendingTransactions = new Array();
			}
			paidChatPendingTransactions[userUid] = transactionId;
		}
		
		static public function getPendingTransaction(userUID:String):String 
		{
			if (paidChatPendingTransactions != null && paidChatPendingTransactions[userUID] != null)
			{
				return paidChatPendingTransactions[userUID];
			}
			return null;
		}
		
		static public function clearPendingTransaction(userUid:String):void 
		{
			if (paidChatPendingTransactions != null && paidChatPendingTransactions[userUid] != null)
			{
				delete paidChatPendingTransactions[userUid];
			}
		}
		
		static private function setPaidModeResponse(r:PHPRespond):void 
		{
			if (r.error == true)
			{
				ToastMessage.display(r.errorMsgLocalized);
			}
			else
			{
				setMyPaidChat(new PaidChatData(r.data));
				S_MY_PAID_CHAT_UPDATE.invoke();
			}
			
			r.dispose();
		}
		
		static private function onPaidBanStatus(r:PHPRespond):void 
		{
			if (r.error == true)
			{
				ToastMessage.display(r.errorMsgLocalized);
			}
			else
			{
				if (r.data is Boolean && (r.data) as Boolean == false)
				{
					
				}
				else if(r.data != null)
				{
					paidChatData = new PaidChatData(r.data);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			
			S_MY_PAID_CHAT_UPDATE.invoke();
			
			r.dispose();
		}
		
		static private function onDisablePaidChatResponse(r:PHPRespond):void 
		{
			if (r.error == true)
			{
				ToastMessage.display(r.errorMsgLocalized);
			}
			else
			{
				paidChatData = null;
				S_MY_PAID_CHAT_UPDATE.invoke();
			}
			r.dispose();
		}
		
		private static function onProductBuyersLoaded(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				if (respond.errorMsg == PHP.NETWORK_ERROR) {
					//!TODO:
				} else {
					//!TODO:
				}
			} else {
				if ("data" in respond && respond.data != null && respond.data is Array) {
					var buyers:Vector.<Order> = new Vector.<Order>();
					var buyer:Order;
					var buyerParser:OrderDataParser = new OrderDataParser();
					var l:int = (respond.data as Array).length;
					for (var i:int = 0; i < l; i++) {
						buyer = buyerParser.parse(respond.data[i]);
						if (buyer != null) {
							buyers.push(buyer);
						}
					}
					if (respond.additionalData != null && "productId" in respond.additionalData) {
						productBuyers[respond.additionalData.productId] = buyers;
					}
					
					S_PRODUCTS_BUYERS.invoke(respond.additionalData.productId);
				}
			}
			respond.dispose();
		}
		
		static private function loadProductsFromPHP():void {
			getProductsBusy = true;
			PHP.getMyProducts(onProductsLoaded, null);
		}
		
		private static function onProductsLoaded(respond:PHPRespond):void {
			getProductsBusy = false;
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				
				if (respond.errorMsg == PHP.NETWORK_ERROR) {
					//!TODO:
				}
				else {
					//!TODO:
				}
			}
			else {
				if ("data" in respond && respond.data != null && respond.data is Array) {
					
					products = new Vector.<ShopProduct>();
					
					var l:int = (respond.data as Array).length;
					var product:ShopProduct;
					var parser:ShopProductDataParser = new ShopProductDataParser();
					var productType:ProductType = new ProductType(ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION);
					for (var i:int = 0; i < l; i++) 
					{
						product = parser.parse(respond.data[i], productType);
						if (product != null) {
							if (product.productType.value == ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION) {
								if (product.targetData != null && product.targetData is ChatVO && (product.targetData as ChatVO).avatar == null) {
									(product.targetData as ChatVO).avatar = Auth.avatar;
								}
							}
							
							products.push(product);
						}
					}
					
					S_PRODUCTS.invoke();
				}
			}
			
			respond.dispose();
		}
		
		static private function loadOrdersFromPHP():void 
		{
			getOrdersBusy = true;
			PHP.getMyOrders(onOrdersLoaded, null);
		}
		
		private static function onOrdersLoaded(respond:PHPRespond):void {
			getOrdersBusy = false;
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				
				if (respond.errorMsg == PHP.NETWORK_ERROR) {
					//!TODO:
				}
				else {
					//!TODO:
				}
			}
			else {
				if ("data" in respond && respond.data != null && respond.data is Array) {
					
					orders = new Vector.<Order>();
					
					var l:int = (respond.data as Array).length;
					var order:Order;
					var parser:OrderDataParser = new OrderDataParser();
					for (var i:int = 0; i < l; i++) 
					{
						order = parser.parse(respond.data[i]);
						if (order != null) {
							
							if (order.product != null && order.product.productType.value == ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION) {
								if (	order.product.targetData != null && order.product.targetData is ChatVO && 
										(order.product.targetData as ChatVO).avatar == null && 
										(order.product.targetData as ChatVO).ownerUID == Auth.uid)
								{
									(order.product.targetData as ChatVO).avatar = Auth.avatar;
								}
							}
							
							orders.push(order);
						}
					}
					
					S_ORDERS.invoke();
				}
			}
			
			respond.dispose();
		}
		
		static private function addTask(task:ShopServerTask):void {
			if (serverTasks == null) {
				serverTasks = new Vector.<ShopServerTask>();
			}
			serverTasks.push(task);
			processNextTask();
		}
		
		static private function processNextTask():void {
			if (serverTasks != null && serverTasks.length > 0 && currentServerTask == null) {
				currentServerTask = serverTasks.shift();
				currentServerTask.execute(onServerTaskResult);
			}
		}
		
		static private function onServerTaskResult(success:Boolean, task:ShopServerTask):void {
			if (success == false) {
				var taskCanBeRequestedAgain:Boolean = (task.getStatus() != ShopServerTask.TASK_STATUS_PAID);
				switch(task.type) {
					case ShopServerTask.BUY_SHOP_PRODUCT:
					{
						S_PRODUCT_BUY_RESPONSE.invoke(false, task.requestId, task.failMessage, taskCanBeRequestedAgain);
						break;
					}
					case ShopServerTask.BUY_QUESTION_PRODUCT:
					{
						S_PRODUCT_BUY_RESPONSE.invoke(false, task.requestId, task.failMessage);
						break;
					}
					case ShopServerTask.BUY_EXTENSION_PRODUCT:
					{
						S_PRODUCT_BUY_RESPONSE.invoke(false, task.requestId, task.failMessage);
						break;
					}
				}
			} else {
				switch(task.type) {
					case ShopServerTask.BUY_SHOP_PRODUCT:
					{
						refreshOrders();
						S_PRODUCT_BUY_RESPONSE.invoke(true, task.requestId);
						break;
					}
					case ShopServerTask.BUY_QUESTION_PRODUCT:
					{
						S_PRODUCT_BUY_RESPONSE.invoke(true, task.requestId);
						break;
					}
					case ShopServerTask.BUY_EXTENSION_PRODUCT:
					{
						S_PRODUCT_BUY_RESPONSE.invoke(true, task.requestId);
						break;
					}
				}
			}
			
			task.dispose();
			currentServerTask = null;
			processNextTask();
		}
		
		static private function refreshOrders():void {
			//!TODO: dispose;
			orders = null;
		}
	}
}