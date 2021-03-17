package com.dukascopy.connect.sys.usersManager 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.paidBan.config.PaidBanConfig;
	import com.dukascopy.connect.data.paidBan.config.PaidBanCost;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanConfigParser;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanParser;
	import com.dukascopy.connect.sys.applicationShop.serverTask.PaidBanProtectionRequestData;
	import com.dukascopy.connect.sys.applicationShop.serverTask.PaidBanRequestData;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidBanUserPopup;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidBuyProtectionUserPopup;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidProtectionInfoUserPopup;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidUnbanUserPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBan 
	{
		static public var S_UPDATED:Signal = new Signal("PaidBan.S_UPDATED");
		static public var S_BAN_SET_RESPONSE:Signal = new Signal("PaidBan.S_BAN_SET_RESPONSE");
		static public var S_BAN_REMOVE_RESPONSE:Signal = new Signal("PaidBan.S_BAN_REMOVE_RESPONSE");
		static public var S_ADD_PROTECTOION_RESPONSE:Signal = new Signal("PaidBan.S_ADD_PROTECTOION_RESPONSE");
		static public var S_USER_BAN_UPDATED:Signal = new Signal("PaidBan.S_USER_BAN_UPDATED");
		
		static public const SERVER_STATUS_PAID:String = "paid";
		static public const SERVER_STATUS_BUYOUT:String = "buyout";
		
		static private var avaliable:Boolean = true;
		static private var config:PaidBanConfig;
		static private var busy:Boolean;
		static private var banInPayProcess:UserBan911VO;
		static private var pendingFullDataRequests:Array;
		static private var unbansForPayStack:Array;
		static private var unbanInPayProcess:UserBan911VO;
		static private var serverTasks:Vector.<ShopServerTask>;
		static private var currentServerTask:ShopServerTask;
		
		public function PaidBan() {
			
		}
		
		public static function init():void {
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
		}
		
		static private function onConnectionChanged():void {
			if (NetworkManager.isConnected && Auth.key != "web") {
				getConfig();
				
				if (pendingFullDataRequests != null) {
					for (var id:String in pendingFullDataRequests) {
						PHP.getFullBanData(onFullBanDataLoaded, pendingFullDataRequests[id]);
					}
				}
			}
		}
		
		public static function isAvaliable():Boolean {
			return avaliable;
		}
		
		public static function getConfig():PaidBanConfig {
			if (config == null && avaliable == true) {
				loadConfig();
			}
			return config;
		}
		
		private static function loadConfig():void {
			if (busy == false) {
				busy = true;
				PHP.loadPaidBanConfig(onConfigLoaded);
			}
		}
		
		private static function onConfigLoaded(respond:PHPRespond):void {
			busy = false;
			if (respond.error == true) {
				onCongigChanged(false);
			}
			else if("data" in respond && respond.data != null) {
				var parser:PaidBanConfigParser = new PaidBanConfigParser();
				config = parser.parse(respond.data);
				onCongigChanged(true);
				parser = null;
			}
			
			respond.dispose();
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// SCREEN REQUEST ----------------------------------------------------------------------------------------//
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function paidBanUser(userVO:UserVO):void {
			if (userVO != null && userVO.disposed == false) {
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, PaidBanUserPopup, {user:userVO});
			}
			else{
				// application error;
				
				var errorDetails:String;
				if (userVO == null) {
					errorDetails = "user VO null";
				}
				else if (userVO.disposed == true){
					errorDetails = "user VO disposed";
				}
				ApplicationErrors.add(errorDetails);
			}
		}
		
		static public function paidUnbanUser(userVO:UserVO):void {
			if (userVO != null && userVO.disposed == false && userVO.ban911VO != null) {
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, PaidUnbanUserPopup, {user:userVO});
			}
			else{
				// application error;
				
				var errorDetails:String;
				if (userVO == null) {
					errorDetails = "user VO null";
				}
				else if (userVO.disposed == true){
					errorDetails = "user VO disposed";
				}
				ApplicationErrors.add(errorDetails);
			}
		}
		
		static public function buyProtection():void {
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, PaidBuyProtectionUserPopup, {user:Auth.myProfile});
		}
		
		static public function showProtection(userVO:UserVO):void {
			if (userVO != null && userVO.paidPanProtection != null && userVO.disposed == false) {
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, PaidProtectionInfoUserPopup, {user:userVO, protectionData:userVO.paidPanProtection});
			}
			else {
				ApplicationErrors.add("empty model");
			}
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// SERVER REQUEST ----------------------------------------------------------------------------------------//
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function processBan(requestData:PaidBanRequestData, requestId:String, payWallet:String):void {
			var task:ShopServerTask = new ShopServerTask(ShopServerTask.BUY_BAN, requestId, payWallet);
			
			var banData:UserBan911VO = new UserBan911VO();
			banData.days = requestData.days;
			banData.incognito = requestData.incognito;
			banData.reason = requestData.reason;
			banData.user_uid = requestData.userUID;
			task.data = banData;
			
			addTask(task);
		}
		
		static public function processUnban(banData:UserBan911VO, payWallet:String):void {
			var task:ShopServerTask = new ShopServerTask(ShopServerTask.BUY_UNBAN, banData.user_uid, payWallet);
			task.data = banData;
			addTask(task);
		}
		
		static public function processAddProtection(requestData:PaidBanProtectionRequestData, payWallet:String):void {
			var task:ShopServerTask = new ShopServerTask(ShopServerTask.BUY_PROTECTION, requestData.userUID, payWallet);
			
			var banData:UserBan911VO = new UserBan911VO();
			banData.days = requestData.days;
			banData.user_uid = requestData.userUID;
			
			task.data = banData;
			addTask(task);
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
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
					case ShopServerTask.BUY_BAN:
					{
						S_BAN_SET_RESPONSE.invoke(false, task.requestId, task.failMessage, taskCanBeRequestedAgain);
						break;
					}
					case ShopServerTask.BUY_UNBAN:
					{
						S_BAN_REMOVE_RESPONSE.invoke(false, task.requestId, task.failMessage, taskCanBeRequestedAgain);
						break;
					}
					case ShopServerTask.BUY_PROTECTION:
					{
						S_ADD_PROTECTOION_RESPONSE.invoke(false, task.requestId, task.failMessage, taskCanBeRequestedAgain);
						break;
					}
				}
			}
			else {
				var banData:UserBan911VO;
				
				switch(task.type) {
					case ShopServerTask.BUY_BAN:
					{
						if (task.resultData is UserBan911VO) {
							banData = task.resultData as UserBan911VO;
							addBanToUserModel(banData);
						}
						else {
							ApplicationErrors.add("wrong ban result data");
						}
						
						S_BAN_SET_RESPONSE.invoke(true, task.requestId);
						break;
					}
					case ShopServerTask.BUY_UNBAN:
					{
						if (task.data is UserBan911VO) {
							banData = task.data as UserBan911VO;
							removeBanFromUserModel(banData);
						}
						else {
							ApplicationErrors.add("wrong unban result data");
						}
						
						S_BAN_REMOVE_RESPONSE.invoke(true, task.requestId);
						break;
					}
					case ShopServerTask.BUY_PROTECTION:
					{
						S_ADD_PROTECTOION_RESPONSE.invoke(true, task.requestId);
						break;
					}
				}
			}
			
			task.dispose();
			currentServerTask = null;
			processNextTask();
		}
		
		static private function addBanToUserModel(banData:UserBan911VO):void {
			if (banData != null) {
				var user:UserVO = UsersManager.getFullUserData(banData.user_uid);
				if (banData.user_uid == Auth.uid) {
					user = Auth.myProfile;
				}
				if (user != null) {
					if (user.ban911VO != null) {
						user.ban911VO.update(banData);
					}
					else {
						user.ban911VO = banData;
					}
					S_USER_BAN_UPDATED.invoke(user.uid);
				}
			}
		}
		
		private static function onCongigChanged(success:Boolean):void {
			S_UPDATED.invoke(success);
		}
		
		static public function getBanFullData(id:Number):void {
			if (!isNaN(id)) {
				if (pendingFullDataRequests == null) {
					pendingFullDataRequests = new Array();
				}
				
				if (pendingFullDataRequests[id.toString()] == null) {
					pendingFullDataRequests[id.toString()] = id.toString();
					PHP.getFullBanData(onFullBanDataLoaded, id);
				}
			}
		}
		
		static public function getBanCost(banData:UserBan911VO, type:int):Number {
			if (config != null) {
				var cost:PaidBanCost;
				switch(type) {
					case ShopServerTask.BUY_BAN:
					{
						if (banData.incognito == true) {
							cost = config.setAsAnon;
						}
						else {
							cost = config.setCost;
						}
						break;
					}
					case ShopServerTask.BUY_UNBAN:
					{
						cost = config.remove;
						break;
					}
					case ShopServerTask.BUY_PROTECTION:
					{
						cost = config.protect;
						break;
					}
				}
				if (cost != null) {
					return cost.value * banData.days;
				}
			}
			else {
				ApplicationErrors.add("no config");
			}
			return 0;
		}
		
		static public function getCurrency(type:int):String {
			if (config != null) {
				switch(type) {
					case ShopServerTask.BUY_BAN:
					{
						return config.setCost.currency;
						break;
					}
					case ShopServerTask.BUY_UNBAN:
					{
						return config.remove.currency;
						break;
					}
					case ShopServerTask.BUY_PROTECTION:
					{
						return config.protect.currency;
						break;
					}
				}
			}
			else {
				ApplicationErrors.add("no config");
			}
			return TypeCurrency.EUR;
		}
		
		static public function onFailedFinishRequest(buyUnban:int):void {
			//!TODO:
		}
		
		static public function addBanToUser(banData:UserBan911VO):void {
			if (banData != null && banData.user_uid == Auth.uid) {
				ToastMessage.display(Lang.youWereBanned);
			}
			addBanToUserModel(banData);
		}
		
		static public function removeBanFromUser(banData:UserBan911VO, notify:Boolean = true):void {
			if (banData != null && banData.user_uid == Auth.uid) {
				if (notify) {
					ToastMessage.display(Lang.youWereUnbanned);
				}
			}
 			removeBanFromUserModel(banData, notify);
		}
		
		static public function disable():void {
			if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1)
				return;
			avaliable = false;
		}
		
		static public function checkBanStatus(ban911VO:UserBan911VO):void {
			if (isBanActive(ban911VO) == false) {
				removeBanFromUser(ban911VO, false);
			}
		}
		
		static public function checkProtectionStatus(userVO:UserVO):void {
			if (userVO != null && userVO.paidPanProtection != null && !isNaN(userVO.paidPanProtection.canceled)) {
				var date:Date = new Date();
				var difference:Number = userVO.paidPanProtection.canceled * 1000 - date.getTime();
				if (difference < 0) {
					userVO.paidPanProtection = null;
				}
			}
		}
		
		static private function isBanActive(banData:UserBan911VO):Boolean {
			if (!isNaN(banData.canceled)) {
				var date:Date = new Date();
				var difference:Number = banData.canceled * 1000 - date.getTime();
				return difference > 0;
			}
			return true;
		}
		
		static private function removeBanFromUserModel(banData:UserBan911VO, notify:Boolean = true):void {
			if (banData != null) {
				var user:UserVO = UsersManager.getFullUserData(banData.user_uid);
				if (banData.user_uid == Auth.uid) {
					user = Auth.myProfile;
				}
				if (user != null && user.ban911VO != null && user.ban911VO.id == banData.id) {
					user.ban911VO.dispose();
					user.ban911VO = null;
					if (notify) {
						S_USER_BAN_UPDATED.invoke(user.uid);
					}
				}
			}
		}
		
		private static function onFullBanDataLoaded(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				
				/*const ERROR_WRONG_DATA = 'pban.01 Wrong input data';
				const ERROR_UNKNOWN = 'pban.02 Unknown error';
				const ERROR_NO_USER = 'pban.03 No user';
				const ERROR_NO_ACCESS = 'pban.04 No access';
				const ERROR_MYSQL = 'pban.05 MySQL Error';
				const ERROR_NO_PAYMENTS = 'pban.06 No approved Payment account or or not enough money';
				const ERROR_WRONG_PAIDBANREG = 'pban.07 Wrong ban ID or you are not owner';
				const ERROR_WRONG_PAID_TRX = 'pban.08 Wrong payment request';
				const ERROR_LIMIT_MONTH = 'pban.09 User block limit per month reached';
				const ERROR_PROTECTED = 'pban.10 User protected';
				const ERROR_USER_FREE = 'pban.11 User not banned';
				const ERROR_WRONG_TIME = 'pban.12 Too long protection time';*/
				
				
				//!TODO:
				
				if (respond.errorMsg == PHP.NETWORK_ERROR) {
					
				}
				else {
					if (pendingFullDataRequests != null && respond.additionalData && respond.additionalData.banId != null) {
						delete pendingFullDataRequests[(respond.additionalData.banId).toString()];
					}
				}
			}
			else {
				if ("data" in respond && respond.data == false) {
					if (pendingFullDataRequests != null) {
						delete pendingFullDataRequests[(respond.additionalData.banId).toString()];
					}
				}
				else  {
					var paidBanParser:PaidBanParser = new PaidBanParser();
					var banData:UserBan911VO = paidBanParser.parse(respond.data);
					banData.fullData = true;
					paidBanParser = null;
					if (banData.status == SERVER_STATUS_BUYOUT) {
						removeBanFromUserModel(banData);
					}
					else {
						addBanToUserModel(banData);
					}
					
					if (pendingFullDataRequests != null) {
						delete pendingFullDataRequests[banData.id.toString()];
					}
					S_USER_BAN_UPDATED.invoke(banData.user_uid);
				}
				
				
			}
			
			respond.dispose();
		}
	}
}