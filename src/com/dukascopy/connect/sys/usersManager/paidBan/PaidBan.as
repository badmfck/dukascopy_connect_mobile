package com.dukascopy.connect.sys.usersManager.paidBan {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LabelItem;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.data.paidBan.config.PaidBanConfig;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanConfigParser;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanParser;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanProtectionDataParser;
	import com.dukascopy.connect.data.screenAction.customActions.BuyBanProtectionAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidBanUserPopup;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidBanUsersListScreen;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidBuyProtectionUserPopup;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidProtectionInfoUserPopup;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidUnbanUserPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.product.ProductCost;
	import com.dukascopy.connect.sys.applicationShop.serverTask.PaidBanProtectionRequestData;
	import com.dukascopy.connect.sys.applicationShop.serverTask.PaidBanRequestData;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class PaidBan 
	{
		static public var S_UPDATED:Signal = new Signal("PaidBan.S_UPDATED");
		static public var S_BAN_SET_RESPONSE:Signal = new Signal("PaidBan.S_BAN_SET_RESPONSE");
		static public var S_BAN_REMOVE_RESPONSE:Signal = new Signal("PaidBan.S_BAN_REMOVE_RESPONSE");
		static public var S_ADD_PROTECTOION_RESPONSE:Signal = new Signal("PaidBan.S_ADD_PROTECTOION_RESPONSE");
		static public var S_USER_BAN_UPDATED:Signal = new Signal("PaidBan.S_USER_BAN_UPDATED");
		static public var S_BANS_LIST:Signal = new Signal("PaidBan.S_BANS_LIST");
		static public var S_BANS_TOP_LIST:Signal = new Signal("PaidBan.S_BANS_TOP_LIST");
		static public var S_SHOW_BAN_NOTIFICATION:Signal = new Signal("PaidBan.S_SHOW_BAN_NOTIFICATION");
		
		static public const SERVER_STATUS_PAID:String = "paid";
		static public const SERVER_STATUS_BUYOUT:String = "buyout";
		
		static private var avaliable:Boolean = true;
		static private var config:PaidBanConfig;
		static private var busy:Boolean;
		static private var banInPayProcess:UserBan911VO;
		static private var pendingFullDataRequests:Array;
		static private var unbansForPayStack:Array;
		static private var serverTasks:Vector.<ShopServerTask>;
		static private var currentServerTask:ShopServerTask;
		
		static private var myBansBusy:Boolean;
		static private var updateMyBansTomeout:Number = 3 * 60 * 1000;
		static private var myBans:Array;
		static private var lastMyBansLoadTime:Number;
		
		static private var topBansBusy:Boolean;
		static private var updateTopBansTomeout:Number = 5 * 1000;
		static private var lastTopBansLoadTime:Number;
		
		private static var notifications:PaidBanNotification;
		static private var topBansHash:String;
		static private var jailData:Array;
		static private var bansProtections:Array;
		static private var topBansActive:Array;
		static private var topBansInactive:Array;
		static private var bansProtectionsHash:String;
		static private var timer:int;
		static private var lockedAtStart:Boolean;
		static private var bansExist:Boolean;
		static public var showJailSection:Boolean = true;
		
		public function PaidBan() {
			
		}
		
		public static function init():void {
			
			notifications = new PaidBanNotification();
			
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
			Auth.S_NEED_AUTHORIZATION.add(clean);
			
			WSClient.S_PAID_BAN_USER_BANNED.add(onPaidBanUserBanned);
			WSClient.S_PAID_BAN_USER_UNBANNED.add(onPaidBanUserUnbanned);
			Auth.S_AUTH_DATA_UPDATED.add(onAuthDataUpdated);
			
			lockedAtStart = true;
			TweenMax.delayedCall(1000, unlock);
		}
		
		static private function unlock():void 
		{
			lockedAtStart = false;
		}
		
		static private function onAuthDataUpdated():void {
			if (bansExist != Auth.existBans())
			{
				bansExist = Auth.existBans();
				S_USER_BAN_UPDATED.invoke(Auth.uid);
			}
		}
		
		static private function onPaidBanUserBanned(rawData:Object):void {
			if (rawData != null) {
				var banData:UserBan911VO = new UserBan911VO();
				if (rawData.hasOwnProperty("incognito") == true)
					banData.incognito = rawData.incognito;
				if (rawData.hasOwnProperty("reason") == true) {
					try	{
						var reasonData:Object = JSON.parse(rawData.reason);
						if (reasonData != null && reasonData.hasOwnProperty("id")) {
							banData.reason = reasonData.id;
						}
						else {
							banData.reason = rawData.reason;
						}
					}
					catch (e:Error) {
						banData.reason = rawData.reason;
					}
				}
				
				if (rawData.hasOwnProperty("user") == true && rawData.user != null)
					banData.user_uid = rawData.user;
				if (rawData.hasOwnProperty("canceled") == true)
					banData.canceled = rawData.cancelled/1000;
				if (rawData.hasOwnProperty("payer") == true && rawData.payer != null)
					banData.payer_uid = rawData.payer;
				if (rawData.hasOwnProperty("id") == true)
					banData.id = rawData.id;
				
				addBanToUser(banData);
				notifications.newBan(banData);
			}
			else {
				ApplicationErrors.add("bad server data");
			}
		}
		
		static private function onPaidBanUserUnbanned(rawData:Object):void {
			if (rawData != null) {
				var banData:UserBan911VO = new UserBan911VO();
				if (rawData.hasOwnProperty("user") == true && rawData.user != null)
					banData.user_uid = rawData.user;
				if (rawData.hasOwnProperty("id") == true)
					banData.id = rawData.id;
				
				removeBanFromUser(banData);
			}
			else {
				ApplicationErrors.add("bad server data");
			}
		}
		
		static private function clean():void {
			cleanBans();
			topBansHash = null;
		}
		
		static private function onConnectionChanged():void {
			if (NetworkManager.isConnected && Auth.key != "web" && lockedAtStart == false) {
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
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, PaidBuyProtectionUserPopup, { user:Auth.myProfile } );
		}
		
		static public function showProtection(userVO:UserVO):void {
			if (userVO != null && userVO.paidPanProtection != null && userVO.disposed == false) {
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, PaidProtectionInfoUserPopup, {user:userVO, protectionData:userVO.paidPanProtection});
			}
			else {
				ApplicationErrors.add("empty model");
			}
		}
		
		static public function showMyBans():void {
			getConfig();
			MobileGui.changeMainScreen(PaidBanUsersListScreen,  {
																	userUID:Auth.uid, 
																	title:Lang.myBans,
																	backScreen:MobileGui.centerScreen.currentScreenClass, 
																	backScreenData:MobileGui.centerScreen.currentScreen.data
																},
										ScreenManager.DIRECTION_RIGHT_LEFT);
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
						updateMyBansTomeout = NaN;
						cleanBans();
						S_BAN_SET_RESPONSE.invoke(false, task.requestId, task.failMessage, taskCanBeRequestedAgain);
						break;
					}
					case ShopServerTask.BUY_UNBAN:
					{
						updateMyBansTomeout = NaN;
						cleanBans();
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
				var user:UserVO;
				if (banData.user_uid == Auth.uid) {
					user = Auth.myProfile;
				}
				else {
					if (banData.user == null) {
						user = UsersManager.getUserByBanObject(banData);
						user.incUseCounter();
					}
					else {
						user = banData.user;
					}
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
			if (success)
			{
				if (topBansBusy == false) {
					S_BANS_TOP_LIST.invoke();
				}
				if (myBansBusy == false) {
					S_BANS_LIST.invoke();
				}
			}
			
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
				var cost:ProductCost;
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
					var result:Number = cost.value * banData.days;
					result = Math.round(result * 100) / 100;
					return result;
				}
			}
			else {
			//	ApplicationErrors.add("no config");
			}
			return 0;
		}
		
		static public function getCurrency(type:int):String {
			return ConfigManager.config.innerCurrency;
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
			//	ApplicationErrors.add("no config");
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
		
		static public function getBans(userUID:Object):void {
			myBansBusy = true;
			if (myBans == null) {
				loadMyBansFromStore();
			}
			else {
				if (isNaN(lastMyBansLoadTime) == true || (new Date()).getTime() - lastMyBansLoadTime > updateMyBansTomeout) {
					loadMyBansFromPHP();
				}
				else {
					S_BANS_LIST.invoke(myBans);
					myBansBusy = false;
				}
			}
		}
		
		static private function loadMyBansFromPHP():void {
			PHP.paidBan_getBan(onMyBansLoadedFromPHP);
		}
		
		private static function onMyBansLoadedFromPHP(respond:PHPRespond):void {
			lastMyBansLoadTime = (new Date()).getTime();
			myBansBusy = false;
			
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				//ToastMessage.display(message);
			}
			else {
				if ("data" in respond && respond.data != null && "bans" in respond.data && respond.data.bans != null && respond.data.bans is Array) {
					Store.save(Store.VAR_MY_BANS, respond.data.bans);
					
					parseMyBans(respond.data.bans);
				//	myBans = ArrayUtils.sortArray(myBans, "name");
					updateMyBansWithUserModel();
					S_BANS_LIST.invoke(myBans);
				}
				else {
					
				}
			}
			respond.dispose();
		}
		
		static private function parseMyBans(data:Array):void {
			if (myBans != null)	{
				cleanBans();
			}
			myBans = new Array();
			
			var paidBanParser:PaidBanParser = new PaidBanParser();
			var l:int = data.length;
			var banData:UserBan911VO;
			for (var i:int = 0; i < l; i++) {
				banData = paidBanParser.parse(data[i]);
				if (banData != null) {
					myBans.push(banData);
				}
			}
			paidBanParser = null;
		}
		
		static private function cleanBans():void {
			if (myBans != null)	{
				var l:int = myBans.length;
				for (var i:int = 0; i < l; i++) {
					(myBans[i] as UserBan911VO).dispose();
				}
			}
			myBans = null;
			
			cleanTopBans();
			cleanBansProtections();
			jailData = null;
			
			topBansActive = null;
			topBansInactive = null;
		}
		
		static private function updateMyBansWithUserModel():Boolean {
			var updated:Boolean = false;
			if (myBans != null) {
				var l:int = myBans.length;
				for (var i:int = 0; i < l; i++) {
					if ((myBans[i] as UserBan911VO).user == null) {
						
						(myBans[i] as UserBan911VO).user = UsersManager.getUserByBanObject(myBans[i] as UserBan911VO);
						
						(myBans[i] as UserBan911VO).user.incUseCounter();
						updated = true;
					}
				}
			}
			return updated;
		}
		
		static private function loadMyBansFromStore():void {
			Store.load(Store.VAR_MY_BANS, onLoadMyBansFromStore);
		}
		
		static private function onLoadMyBansFromStore(data:Object, error:Boolean):void {
			if (data != null && data is Array) {
				parseMyBans(data as Array);
			//	myBans = ArrayUtils.sortArray(myBans, "name");
				updateMyBansWithUserModel();
				S_BANS_LIST.invoke(myBans);
			}
			
			loadMyBansFromPHP();
		}
		
		static public function getJailData():Array {
			timer = getTimer();
			getConfig();
			if (topBansBusy == false)
			{
				if (jailData == null) {
					loadTopBansFromStore();
				}
				else {
					if (isNaN(lastTopBansLoadTime) == true || (new Date()).getTime() - lastTopBansLoadTime > updateTopBansTomeout && topBansBusy == false) {
						loadTopBansFromPHP();
					}
					else {
						if (jailData == null) {
							jailData = new Array();
						}
					}
				}
			}
			
			return jailData;
		}
		
		static public function hideJail():void {
			showJailSection = false;
			S_UPDATED.invoke(true);
		}
		
		static private function loadTopBansFromStore():void {
			topBansBusy = true;
			Store.load(Store.VAR_TOP_BANS, onLoadTopBansFromStore);
		}
		
		static private function onLoadTopBansFromStore(data:Object, error:Boolean):void {
			if (data != null && data is Array) {
				parseTopBans(data as Array);
				updateTopBansWithUserModel();
			//	S_BANS_TOP_LIST.invoke();
			}
			
			loadProtectionsFromStore();
		}
		
		static private function loadProtectionsFromStore():void 
		{
			Store.load(Store.VAR_BAN_PROTECTIONS, onLoadBansProtectionsFromStore);
		}
		
		static private function onLoadBansProtectionsFromStore(data:Object, error:Boolean):void {
			if (data != null && data is Array) {
				parseProtections(data as Array);
				updateProtectionsWithUserModel();
				fillJailData();
				S_BANS_TOP_LIST.invoke();
			}
			
			loadTopBansFromPHP();
		}
		
		static private function parseProtections(data:Array):void {
			if (bansProtections != null) {
				cleanBansProtections();
			}
			bansProtections = new Array();
			
			var protectionParser:PaidBanProtectionDataParser = new PaidBanProtectionDataParser();
			var l:int = data.length;
			var protectionData:PaidBanProtectionData;
			for (var i:int = 0; i < l; i++) {
				protectionData = protectionParser.parse(data[i]);
				if (protectionData != null) {
					if (isProtectionActive(protectionData)){
						bansProtections.push(protectionData);
					}
				}
			}
			
			protectionParser = null;
		}
		
		static private function parseTopBans(data:Array):void {
			if (topBansActive != null || topBansInactive != null) {
				cleanTopBans();
			}
			topBansActive = new Array();
			topBansInactive = new Array();
			
			var paidBanParser:PaidBanParser = new PaidBanParser();
			var l:int = data.length;
			var banData:UserBan911VO;
			for (var i:int = 0; i < l; i++) {
				banData = paidBanParser.parse(data[i]);
				if (banData != null) {
					if (banData.isExpired() == true || banData.status == "buyout") {
						topBansInactive.push(banData);
					}
					else {
						topBansActive.push(banData);
					}
				}
			}
			
			paidBanParser = null;
		}
		
		static private function cleanBansProtections():void {
			if (bansProtections != null) {
				var l:int = bansProtections.length;
				for (var i:int = 0; i < l; i++) {
					if (bansProtections[i] is PaidBanProtectionData) {
						(bansProtections[i] as PaidBanProtectionData).dispose();
					}
				}
			}
		}
		
		static private function cleanTopBans():void {
			if (topBansActive != null)	{
				var l:int = topBansActive.length;
				for (var i:int = 0; i < l; i++) {
					if (topBansActive[i] is UserBan911VO) {
						(topBansActive[i] as UserBan911VO).dispose();
					}
				}
			}
			if (topBansInactive != null)	{
				var l2:int = topBansInactive.length;
				for (var i2:int = 0; i2 < l2; i2++) {
					if (topBansInactive[i2] is UserBan911VO) {
						(topBansInactive[i2] as UserBan911VO).dispose();
					}
				}
			}
		}
		
		static private function updateProtectionsWithUserModel():Boolean {
			var updated:Boolean = false;
			var protectionData:PaidBanProtectionData;
			if (bansProtections != null) {
				var l:int = bansProtections.length;
				for (var i:int = 0; i < l; i++) {
					if (bansProtections[i] is PaidBanProtectionData) {
						protectionData = bansProtections[i] as PaidBanProtectionData;
						if (protectionData.user == null) {
							protectionData.user = UsersManager.getUserByBanProtectionObject(protectionData);
							protectionData.user.incUseCounter();
							if (protectionData.user.paidPanProtection == null && isProtectionActive(protectionData)) {
								protectionData.user.paidPanProtection = protectionData;
							}
							
							updated = true;
						}
						if (protectionData.payer == null) {
							protectionData.payer = UsersManager.getFullUserData(protectionData.payer_uid, true);
							protectionData.payer.incUseCounter();
							
							updated = true;
						}
					}
				}
			}
			return updated;
		}
		
		static private function updateTopBansWithUserModel():Boolean {
			var updated:Boolean = false;
			var banData:UserBan911VO;
			if (topBansActive != null) {
				var l:int = topBansActive.length;
				for (var i:int = 0; i < l; i++) {
					if (topBansActive[i] is UserBan911VO) {
						banData = topBansActive[i] as UserBan911VO;
						if (banData.user == null) {
							banData.user = UsersManager.getUserByBanObject(banData);
							banData.user.incUseCounter();
							if (banData.user.ban911VO == null && isBanActive(banData)) {
								banData.user.ban911VO = banData;
							}
							
							updated = true;
						}
						if (banData.payer == null) {
							banData.payer = UsersManager.getUserByBanPayerObject(banData);
							banData.payer.incUseCounter();
							updated = true;
						}
					}
				}
			}
			
			if (topBansInactive != null) {
				var l2:int = topBansInactive.length;
				for (var i2:int = 0; i2 < l2; i2++) {
					if (topBansInactive[i2] is UserBan911VO) {
						banData = topBansInactive[i2] as UserBan911VO;
						if (banData.user == null) {
							banData.user = UsersManager.getUserByBanObject(banData);
							banData.user.incUseCounter();
							if (banData.user.ban911VO == null && isBanActive(banData)) {
								banData.user.ban911VO = banData;
							}
							
							updated = true;
						}
					}
				}
			}
			
			return updated;
		}
		
		static private function loadTopBansFromPHP():void {
			topBansBusy = true;
			if (topBansHash == null) {
				Store.load(Store.VAR_TOP_BANS_HASH, onLoadTopBansHashFromStore);
			}
			else{
				PHP.paidBan_getTopBans(onTopBansLoadedFromPHP, topBansHash);
			}
		}
		
		static private function onLoadTopBansHashFromStore(data:Object, error:Boolean):void {
			if (data != null) {
				topBansHash = data as String;
			}
			
			PHP.paidBan_getTopBans(onTopBansLoadedFromPHP, topBansHash);
		}
		
		private static function onTopBansLoadedFromPHP(respond:PHPRespond):void {
		//	lastTopBansLoadTime = (new Date()).getTime();
		//	topBansBusy = false;
			
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				//ToastMessage.display(message);
			}
			else {
				if ("data" in respond && respond.data != null && "bans" in respond.data && respond.data.bans != null) {
					topBansHash = respond.data.hash;
					Store.save(Store.VAR_TOP_BANS, respond.data.bans);
					Store.save(Store.VAR_TOP_BANS_HASH, topBansHash);
					parseTopBans(respond.data.bans as Array);
					updateTopBansWithUserModel();
				//	S_BANS_TOP_LIST.invoke();
				}
				else {
					
				}
			}
			respond.dispose();
		//	trace("TOP_BANS", getTimer() - timer);
			loadBansProtectionsFromPHP();
		}
		
		static private function loadBansProtectionsFromPHP():void {
			if (bansProtectionsHash == null) {
				Store.load(Store.VAR_BANS_PROTECTIONS_HASH, onLoadBansProtectionsHashFromStore);
			}
			else{
				PHP.paidBan_getActiveProtections(onBansProtectionsLoadedFromPHP, topBansHash);
			}
		}
		
		static private function onLoadBansProtectionsHashFromStore(data:Object, error:Boolean):void {
			if (data != null) {
				bansProtectionsHash = data as String;
			}
			
			PHP.paidBan_getActiveProtections(onBansProtectionsLoadedFromPHP, topBansHash);
		}
		
		private static function onBansProtectionsLoadedFromPHP(respond:PHPRespond):void {
			lastTopBansLoadTime = (new Date()).getTime();
			topBansBusy = false;
			
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				//ToastMessage.display(message);
			}
			else {
				if ("data" in respond && respond.data != null && "protections" in respond.data && respond.data.protections != null) {
					bansProtectionsHash = respond.data.hash;
					Store.save(Store.VAR_BAN_PROTECTIONS, respond.data.protections);
					Store.save(Store.VAR_BANS_PROTECTIONS_HASH, bansProtectionsHash);
					parseProtections(respond.data.protections as Array);
					updateProtectionsWithUserModel();
				//	S_BANS_TOP_LIST.invoke();
				}
				else {
					
				}
			}
			respond.dispose();
			
			fillJailData();
			
		//	trace("PROTECTIONS", getTimer() - timer);
		}
		
		static private function fillJailData():void 
		{
			jailData = new Array();
			
			if (topBansActive != null && topBansActive.length > 0) {
				jailData.push(new LabelItem(Lang.inJail));
				jailData = jailData.concat(topBansActive);
			}
			
			if (bansProtections != null && bansProtections.length > 0) {
				var buyBanProtectionAction:BuyBanProtectionAction;
				
				if (Auth.myProfile.ban911VO == null && Auth.myProfile.paidPanProtection == null) {
					buyBanProtectionAction = new BuyBanProtectionAction();
				}
				
				jailData.push(new LabelItem(Lang.jailImmunity, buyBanProtectionAction));
				jailData = jailData.concat(bansProtections);
			}
			
			if (topBansInactive != null && topBansInactive.length > 0) {
				jailData.push(new LabelItem(Lang.jailOver));
				jailData = jailData.concat(topBansInactive);
			}
			S_BANS_TOP_LIST.invoke();
		}
		
		static public function isBanActive(banData:UserBan911VO):Boolean {
			if (banData.status == "buyout")
			{
				return false;
			}
			if (!isNaN(banData.canceled)) {
				var date:Date = new Date();
				var difference:Number = banData.canceled * 1000 - date.getTime();
				return difference > 0;
			}
			return true;
		}
		
		static public function isProtectionActive(protectionData:PaidBanProtectionData):Boolean {
			if (!isNaN(protectionData.canceled)) {
				var date:Date = new Date();
				var difference:Number = protectionData.canceled * 1000 - date.getTime();
				return difference > 0;
			}
			return true;
		}
		
		static public function getProtectionCost(protectionData:PaidBanProtectionData):Number 
		{
			if (protectionData.days == -1) {
				return 0;
			}
			if (config != null) {
				var cost:ProductCost = config.protect;
				
				if (cost != null) {
					var result:Number = cost.value * protectionData.days;
					result = Math.round(result * 100) / 100;
					return result;
				}
			}
			else {
			//	ApplicationErrors.add("no config");
			}
			return 0;
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