package com.dukascopy.connect.sys.usersManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.UserPopupData;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidBanUserPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.questionsManager.QuestionsStatisticsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.ScreenLayer;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.timeout.Timeout;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * @author Igor Bloom
	 */
	
	public class UsersManager {
		
		static public var S_ONLINE_CHANGED:Signal = new Signal("UserManager.S_ONLINE_CHANGED");
		static public var USER_BLOCK_CHANGED:Signal = new Signal("UserManager.USER_BLOCK_CHANGED");
		
		static public var S_OFFLINE_ALL:Signal = new Signal("UserManager.S_OFFLINE_ALL");
		static public var S_ONLINE_STATUS_LIST:Signal = new Signal("UserManager.S_ONLINE_STATUS_LIST");
		
		static public var S_TOAD_UPDATED:Signal = new Signal("UserManager.S_TOAD_UPDATED");
		
		static public const METHOD_DISCONNECTED:String = "methodDisconnected";
		static public const METHOD_ONLINE_STATUS:String = "methodOnlineStatus";
		static public const METHOD_OFFLINE_STATUS:String = "methodOfflineStatus";
		static public const METHOD_ONLINE_LIST:String = "methodOnlineList";
		
		static private var inited:Boolean = false;
		static private var checkTimer:Timer = null;
		
		static private var uids:Object = new Object();
		
		static private var toads:Object;
		
		static private var lastOnlineAskTime:Number = 0;
		
		static public function init():void {
			if (inited)
				return;
			inited = true;
			WS.S_CONNECTED.add(onWSConnected);
			WS.S_DISCONNECTED.add(onWSDisconnected);
			WSClient.S_ONLINE_USERS.add(onOnlineUsers);
			WSClient.S_USERS_STATUS.add(onUserStatus);
			
			WSClient.S_USER_TOAD.add(onUserToad);
			WSClient.S_USER_PROFILE_UPDATE.add(onUserProfileUpdated);
			
			WSClient.S_PAID_MODERATOR_BAN_USER_CHANGE.add(onPaidBanUserByModerator);
			WSClient.S_MODERATOR_BAN_USER_CHANGE.add(onPaidBanUserByModerator);
			
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
			
			Auth.S_NEED_AUTHORIZATION.add(clearUsers);
			
			TweenMax.delayedCall(5, checkForToadExpired);
			
			checkOnlineStatus();
		}
		
		static private function onUserProfileUpdated(data:Object = null):void {
			if (data == null)
				return;
			if ("userUID" in data == false)
				return;
			
			var userVO:UserVO = getFullUserData(data.userUID);
			if (userVO == null)
				return;
			
			if ("payRating" in data == true)
				userVO.updateRating(data.payRating);
			
			if ("gift" in data == true)
				userVO.addGiftData(data.gift);
			
			S_USER_FULL_DATA.invoke(data.userUID);
			
			//!TODO:;
			S_TOAD_UPDATED.invoke();
		}
		
		static private function onPaidBanUserByModerator(rawData:Object):void {
			if (rawData != null) {
				if (rawData.user != null)
				{
					var userVO:UserVO = getUserByUID(rawData.user);
					if (userVO != null)
					{
						update(userVO);
					}
				}
			}
		}
		
		static private function checkForToadExpired():void {
			TweenMax.delayedCall(5, checkForToadExpired);
			if (toads == null)
				return;
			var needToInvokeSignal:Boolean = false;
			for (var n:String in toads) {
				if (toads[n] <= int(new Date().getTime() / 1000) + NetworkManager.timeDifference) {
					delete toads[n];
					needToInvokeSignal = true;
				}
			}
			if (needToInvokeSignal)
				S_TOAD_UPDATED.invoke();
		}
		
		static private function onUserToad(pack:Object):void {
			if (pack.time == -1 || pack.time <= pack.server) {
				if (toads == null)
					return;
				if (pack.uid in toads == true) {
					delete toads[pack.uid];
					S_TOAD_UPDATED.invoke();
				}
				return;
			}
			toads ||= { };
			toads[pack.uid] = pack.time;
			S_TOAD_UPDATED.invoke();
		}
		
		static public function checkForToad(userUID:String):Boolean {
			if (toads == null)
				return false;
			return userUID in toads;
		}
		
		static private function onUserWritting(pack:Object):void {
			if ("userUID" in pack) {
				registrateUserUID(pack["userUID"]);
				markUserOnline(pack["userUID"]);
			}
		}
		
		static private function onChatUserEnter(pack:Object):void {
			if ('userUid' in pack) {
				registrateUserUID(pack['userUid']);
				markUserOnline(pack['userUid']);
			}
		}
		
		static private function onUserStatus(data:Object):void {
			if ("status" in data && data.status != "offline")
				markUserOnline(data.uid, data.d, data.w, data.m, data.status);
			else
				markUserOffline(data.uid);
		}
		
		static private function onConnectionChanged():void {
			if (NetworkManager.isConnected == false) {
				onWSDisconnected();
				return;
			}
			checkOnlineStatus();
		}
		
		static private function onWSDisconnected():void {
			for (var n:String in uids) {
				var m:OnlineStatus = uids[n];
				var fireSignal:Boolean = true;
				if (m.online == false)
					fireSignal = false;
				m.wasSend = false;
				m.online = false;
				m.mob = 0;
				m.desk = 0;
				m.web = 0;
				m.status = OnlineStatus.STATUS_OFFLINE;
				if (fireSignal)
					S_ONLINE_CHANGED.invoke(m, METHOD_DISCONNECTED);
			}
			S_OFFLINE_ALL.invoke();
		}
		
		static public function forceAskForUsersOnline():void {
			checkOnlineStatus();
		}
		
		static private function onWSConnected():void {
			checkOnlineStatus();
			PHP.call_getToads(onToadsLoaded);
		}
		
		static private function onToadsLoaded(phpRespond:PHPRespond):void {
			if (phpRespond.error == true)
				return;
			toads ||= { };
			var phpToads:Array = phpRespond.data as Array;
			var l:int = phpToads.length;
			for (var i:int = 0; i < l; i++)
				toads[phpToads[i].uid] = phpToads[i].stop;
			S_TOAD_UPDATED.invoke();
		}
		
		static public function getAvatarImage(data:Object, sourcePath:String, size:int, imageType:int = 1, overrideForSelfUser:Boolean = true):String {
			if (!sourcePath)
				return null;
			if (sourcePath.indexOf(".vk.me") != -1)
				return sourcePath;
			if ("uid" in data && data.uid != null) {
				return getAvatarImageById(data.uid, sourcePath, size, imageType, overrideForSelfUser);
			}
			return sourcePath;
		}
		
		static public function getAvatarImageById(uid:String, sourcePath:String, size:int, imageType:int = 1, overrideForSelfUser:Boolean = true):String {
			if (uid == Auth.uid && overrideForSelfUser)
				return Auth.avatar;
			if (sourcePath == null || sourcePath.length == 0)
				return null;
			var index:int = sourcePath.indexOf("no_photo");
			if (index != -1)
				return null;
			index = sourcePath.indexOf("empty_avatar");
			if (index != -1)
				return null;
			index = sourcePath.indexOf("method=files.get");
			if (index == -1) {
				var userCode:Array = sourcePath.split("/");
				index = sourcePath.indexOf("graph.facebook.com")
				if (index != -1) {
					if (userCode.length > 4)
						return "https://graph.facebook.com/" + userCode[3] + "/picture?width=" + size + "&height=" + size;
				} else if (userCode.length > 4)
					return Config.URL_IMAGE + userCode[5] + "/" + Math.min(size, 2000) + "_" + imageType + "/image.jpg";
				return sourcePath;
			}
			index = sourcePath.indexOf("thumb=1");
			if (index != -1)
				return sourcePath.substring(0, index - 1) + sourcePath.substr(index + 7);
			return sourcePath;
		}
		
		static public function getSmallUserAvatarURL(avatarURL:String):String {
			var res:String = avatarURL;
			var userCode:Array = res.split("/");
			if (res.indexOf("graph.facebook.com") != -1) {
				if (userCode.length > 4)
					res = "https://graph.facebook.com/" + userCode[3] + "/picture?width=" + Config.SMALL_AVATAR_SIZE + "&height=" + Config.SMALL_AVATAR_SIZE;
			} else {
				if (userCode.length > 5)
					res = Config.URL_IMAGE + userCode[5] + "/" + Config.SMALL_AVATAR_SIZE + "_3/image.jpg";
			}
			return res;
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		//	avatarSize
		}
		
		static private function markUserOnline(uid:String, d:int = -1, w:int = -1, m:int = -1, status:String = OnlineStatus.STATUS_ONLINE):void {
			var os:OnlineStatus = uids[uid];
			if (os == null)
				return;
			var fireSignal:Boolean = false;
			if (os.status != status)
				fireSignal = true;
			os.online = true;
			os.status = status;
			if (m > -1) {
				if (os.mob != m && (os.mob == 0 || m == 0))
					fireSignal = true;
				os.mob = m;
			}
			if (w > -1) {
				if (os.web != w && (os.web == 0 || w == 0))
					fireSignal = true;
				os.web = w;
			}
			if (d > -1) {
				if (os.desk != d && (os.desk == 0 || d == 0))
					fireSignal = true;
				os.desk = d;
			}
			if (fireSignal)
				S_ONLINE_CHANGED.invoke(os, METHOD_ONLINE_STATUS);
		}
		
		static private function markUserOffline(uid:String):void {
			var m:OnlineStatus = uids[uid];
			if (m == null)
				return;
			var fireSignal:Boolean = true;
			if (m.online == false)
				fireSignal = false;
			m.online = false;
			m.status = OnlineStatus.STATUS_OFFLINE;
			m.desk = 0;
			m.web = 0;
			m.mob = 0;
			if (fireSignal)
				S_ONLINE_CHANGED.invoke(m, METHOD_OFFLINE_STATUS);
		}
		
		static private function onOnlineUsers(data:Object):void {
			echo("UsersManager", "onOnlineUsers", "call");
			if (!("online" in data))
				return;
			var online:Array = data.online;
			var fireSignal:Boolean = true;
			var m:OnlineStatus;
			var l:int = online.length;
			for (var i:int = 0; i < l; i++) {
				var obj:Object = online[i];
				if (!("uid" in obj))
					continue;
				if (obj.uid in uids) {
					m = uids[obj.uid];
					if (m != null) {
						fireSignal = true;
						if (m.online == true)
							fireSignal = false;
						m.online = true;
						m.desk = obj.d;
						m.web = obj.w;
						m.mob = obj.m;
						m.status = obj.status;
						if (fireSignal)
							S_ONLINE_CHANGED.invoke(m, METHOD_ONLINE_LIST);
					}
				}
			}
			S_ONLINE_STATUS_LIST.invoke();
		}
		
		static private function checkOnlineStatus():void {
			echo("UsersManager", "checkOnlineStatus");
			if (NetworkManager.isConnected == false)
				return;
			var tmpObserve:Array = [];
			var tmpOnlineUIDs:Array = [];
			var tmpOnlineStatuses:Array/*OnlineStatus*/ = [];
			for (var userUid:String in uids) {
				if (uids[userUid].wasSend == false) {
					tmpOnlineUIDs.push(uids[userUid].uid);
					tmpOnlineStatuses.push(uids[userUid]);
				}
				tmpObserve.push(userUid);
			}
			if (tmpObserve.length > 0)
				WSClient.call_userObserve(tmpObserve);
			if (tmpOnlineUIDs.length > 0) {
				if (WSClient.call_contactsOnline(tmpOnlineUIDs, 0) == true) {
					var l:int = tmpOnlineStatuses.length;
					for (var i:int = 0; i < l; i++)
						tmpOnlineStatuses[i].wasSend = true;
				}
			}
			echo("UsersManager", "checkOnlineStatus", "To userObserve: " + tmpObserve.length + "; To usersOnline: " + tmpOnlineUIDs.length);
		}
		
		static private var count:int = 0;
		static public function registrateUserUID(uid:String):void {
			if (uid == Auth.uid)
				return;
			if (uid in uids && uids[uid] != null)
				return;
				
			if (count > 200){
				echo("UsersManager", "registrateUserUID", uid, true);
				return;
			}
			
			uids[uid] = new OnlineStatus(uid, false, 0, 0, 0);
			
			if (checkStatusTimeout == null)
			{
				checkStatusTimeout = new Timeout();
			}
			checkStatusTimeout.add(0.1, checkOnlineStatus);
		//	TweenMax.killDelayedCallsTo(checkOnlineStatus);
		//	TweenMax.delayedCall(.1, checkOnlineStatus);
			count++
		}
		
		static public function isOnline(uid:String):OnlineStatus {
			if (uid in uids)
				return uids[uid];
			return null;
		}
		
		public static function getInterlocutor(chatVo:ChatVO):ChatUserVO {
			//!TODO: реализовать функционал для групповых чатов;
			if (!chatVo || !chatVo.users)
				return null;
			var l:int = chatVo.users.length;
			for (var i:int = 0; i < l; i++)
				if (chatVo.users[i].uid != Auth.uid)
					return chatVo.users[i];
			return null;
		}
		
		public static function getChatOwner(chatVo:ChatVO):Object {
			if (chatVo.ownerUID == Auth.uid) {
				return {
					uid:Auth.uid,
					avatar:Auth.avatar,
					fxid:Auth.fxcommID,
					name:Auth.username
				}
			}
			var l:int = chatVo.users.length;
			for (var i:int = 0; i < l; i++)
				if (chatVo.users[i].uid == chatVo.ownerUID)
					return chatVo.users[i];
			return null;
		}
		
		/**
		 * Method to block/unblock user
		 * 
		 * @param	uid String                User id in the system
		 * @param	newBlockUserStatus String New block status for selected user:
		 * 			   UserBlockStatusType.NO_CHANGE   Status not changed
		 * 			   UserBlockStatusType.BLOCK       Use to block user
		 * 			   UserBlockStatusType.UNBLOCK     Use to unblock user
		 * 
		 * On success will fire UserManager.USER_BLOCK_CHANGED Signal
		 * with data object containing next fields:
		 *      uid: user id for that block status was called 
		 *      status: new block status for selected user(UserBlockStatusType)
		 * 
		 * In case of error will fire UserManager.USER_BLOCK_CHANGED Signal
		 * with data object containing next fields:
		 *      uid: user id for that block status was called 
		 *      status: with value UserBlockStatusType.NO_CHANGE
		 */
		
		static public function changeUserBlock(uid:String, newBlockUserStatus:int):void {
			if (newBlockUserStatus == UserBlockStatusType.NO_CHANGE)
				return;
			var __onPHPResponde:Function = function(phpRespond:PHPRespond):void {
				if (phpRespond.error) {
					if (phpRespond.errorMsg.indexOf("pbk..02") == 0) {
						DialogManager.alert(Lang.information, Lang.somethingWentWrong);
					} else {
						DialogManager.alert(Lang.information, Lang.somethingWentWrong);
						return;
					}
					echo("UsersManager","changeUserBlock",phpRespond.errorMsg);
					USER_BLOCK_CHANGED.invoke( { uid:uid, status:UserBlockStatusType.NO_CHANGE } );
				}
				if (phpRespond.data != null) {
					USER_BLOCK_CHANGED.invoke( { uid:uid, status:newBlockUserStatus } );
				}
			};
			if (newBlockUserStatus == UserBlockStatusType.BLOCK)
				PHP.block_user(__onPHPResponde, uid);
			else if (newBlockUserStatus == UserBlockStatusType.UNBLOCK)
				PHP.unblock_user(__onPHPResponde, uid);
		}
		
		static public function getChatUserDataFxId(chat:ChatVO, uid:String):uint {
			if (chat && chat.users && chat.users.length > 0){
				var l:int = chat.users.length;
				for (var i:int = 0; i < l; i++)
					if (chat.users[i].uid == uid)
						return uint(chat.users[i].fxId);
			}
			return 0;
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  NEW USERS  -->  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public var S_USER_FULL_DATA:Signal = new Signal("UserManager.S_USER_FULL_DATA");
		static public var S_USERS_FULL_DATA:Signal = new Signal("UserManager.S_USERS_FULL_DATA");
		static public var S_USER:Signal = new Signal("UserManager.S_USER");
		static public var S_USER_UPDATED:Signal = new Signal("UserManager.S_NEW_USER");
		
		static private var lastGetProfileTime:Number = 0;
		
		static private var users:Object;
		static private var usersLoading:Object;
		static private var checkStatusTimeout:Timeout;
		static private var loadUsersTimeout:Timeout;
		
		/**
		 * Метод ищет UserVO по userUID и вызывает сигнал S_USER_FULL_DATA где первый параметр это userUID, а второй UserVO если есть.
		 * Сначала метод смотрит есть ли в объекте usersIndexes данный userUID.
		 * Если индекс есть, то метод проверяет массив users на длинну.
		 *   Если длинна массива users длинна меньше или равна найденному индексу, то значит, что индекс неверный и нужно его удалить и проверить есть ли в массиве users UserVO с данным userUID.
		 *   Если UserVO нашелся, то метод проверяет пользователя по данному userUID.
		 *   Если UserVO.uid неравен данному userUID, то значит, что индекс неверный и нужно его удалить и проверить есть ли в массиве users UserVO с данным userUID.
		 *   Если UserVO нашелся и параметр fromServer установлен в true, то данные пользователя с данным userUID будут грузиться с PHP.
		 *   Если параметр fromServer установлен в false, то вызывается сигнал S_USER_FULL_DATA.
		 * Если параметр onlyFromCache установлен в true, то вызывается сигнал S_USER_FULL_DATA и выаолнение заканчивается.
		 * Если параметр onlyFromCache установлен в false, то данные пользователя с данным userUID будут грузиться с PHP.
		 * 
		 * @param	userUID - Пользователь по которому будет браться UserVO вызываться S_USER_FULL_DATA с этим пользователем.
		 * @param	fromServer - Параметр, который указывает грузить ли данные с PHP.
		 */
		static public function getFullUserData(userUID:String, fromServer:Boolean = false):UserVO {
			if (userUID == null || userUID.length == 0)
				return null;
			if (users == null || userUID in users == false) {
				if (fromServer == false)
					return null;
				getFullUserDataFromPHP(userUID);
				return null;
			}
			var userVO:UserVO = users[userUID];
			if (fromServer == true)
				getFullUserDataFromPHP(userVO.uid, userVO.hash);
			return userVO;
		}
		
		static private function getFullUserDataFromPHP(userUID:String, hash:String = null, updateAnyway:Boolean = false):void {
			usersLoading ||= {};
			
			if (updateAnyway == true)
			{
				hash = null;
			}
			
			if (userUID in usersLoading == true)
			{
				if (updateAnyway == true)
				{
					delete usersLoading[userUID];
				}
				else
				{
					return;
				}
			}
			usersLoading[userUID] = (hash == null) ? "" : hash;
			
			if (loadUsersTimeout != null)
			{
				loadUsersTimeout.stop();
			}
		//	TweenMax.killDelayedCallsTo(onDelayedCallToTRY);
			if (tryToLoadFromPHP(updateAnyway) == true)
				return;
			if (loadUsersTimeout == null)
			{
				loadUsersTimeout = new Timeout();
			}
			loadUsersTimeout.add(5, onDelayedCallToTRY);
		//	TweenMax.delayedCall(5, onDelayedCallToTRY);
		}
		
		static private function onDelayedCallToTRY():void {
			if (loadUsersTimeout != null)
			{
				loadUsersTimeout.stop();
			}
		//	TweenMax.killDelayedCallsTo(onDelayedCallToTRY);
			if (tryToLoadFromPHP() == true)
				return;
			if (loadUsersTimeout == null)
			{
				loadUsersTimeout = new Timeout();
			}
			loadUsersTimeout.add(5, onDelayedCallToTRY);
		//	TweenMax.delayedCall(5, onDelayedCallToTRY);
		}
		
		static private function tryToLoadFromPHP(updateAnyway:Boolean = false):Boolean {
			var currentTime:Number = new Date().getTime();
			if (updateAnyway == false && lastGetProfileTime == 0) {
				lastGetProfileTime = currentTime;
				return false;
			}
			if (updateAnyway == false && currentTime - lastGetProfileTime < 5000)
				return false;
			lastGetProfileTime = 0;
			var toPHP:Array = [];
			var count:int;
			for (var s:String in usersLoading) {
				toPHP.push(s + "," + usersLoading[s]);
				count++
				if (count == 41)
					break;
			}
			if (toPHP.length == 0)
				return true;
			
			PHP.user_getByUIDs(onUsersFullDataReceivedFromPHP, toPHP);
			return (count == 41) ? false : true;
		}
		
		static private function onUsersFullDataReceivedFromPHP(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				if (loadUsersTimeout != null) {
					loadUsersTimeout.stop();
				}
				if (phpRespond.errorMsg.indexOf("core.01") == 0) {
					usersLoading = null;
					return;
				}
				if (loadUsersTimeout != null) {
					loadUsersTimeout.stop();
				}
				if (tryToLoadFromPHP() == true)
					return;
				if (loadUsersTimeout == null) {
					loadUsersTimeout = new Timeout();
				}
				loadUsersTimeout.add(5, onDelayedCallToTRY);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				phpRespond.dispose();
				return;
			}
			var i:int;
			if ("missed" in phpRespond.data == true && phpRespond.data.missed != null && phpRespond.data.missed.length != 0) {
				for (i = 0; i < phpRespond.data.missed.length; i++)
					delete usersLoading[phpRespond.data.missed[i].uid];
			}
			if ("users" in phpRespond.data == true && phpRespond.data.users != null && phpRespond.data.users.length != 0) {
				for (i = 0; i < phpRespond.data.users.length; i++) {
					if (phpRespond.data.users[i].uid in users == true && users[phpRespond.data.users[i].uid] != null) {
						users[phpRespond.data.users[i].uid].setData(phpRespond.data.users[i]);
					} else {
						var userVO:UserVO = getNewUserByType(phpRespond.data.users[i]);
						userVO.setDataFromContactObject(phpRespond.data.users[i])
						users[userVO.uid] = userVO;
					}
					delete usersLoading[phpRespond.data.users[i].uid];
				}
			}
			phpRespond.dispose();
			S_USERS_FULL_DATA.invoke();
		}
		
		static private function onUserFullDataReceivedFromPHP(phpRespond:PHPRespond):void {
			var userUID:String = phpRespond.additionalData.userUID;
			if (usersLoading != null) {
				var index:int = usersLoading.indexOf(userUID);
				if (index != -1)
					usersLoading.splice(index, 1);
			}
			if (phpRespond.error == true) {
				S_USER_FULL_DATA.invoke(phpRespond.additionalData.userUID);
				phpRespond.dispose;
			}
			if (phpRespond.data == null) {
				S_USER_FULL_DATA.invoke(phpRespond.additionalData.userUID);
				phpRespond.dispose;
			}
			var userVO:UserVO;
			if (users == null || userUID in users == false)
				userVO = getNewUserByType(phpRespond.data);
			else
				userVO = users[userUID];
			userVO.setData(phpRespond.data);
			addUser(userVO);
			S_USER_FULL_DATA.invoke(userVO.uid, userVO);
			phpRespond.dispose();
		}
		
		static private function addUser(userVO:UserVO, saveKey:String = null, needObserve:Boolean = true):void {
			users ||= { };
			if (saveKey == null) {
				S_USER.invoke(userVO);
				saveKey = userVO.uid;
				if (needObserve == true) {
					registrateUserUID(saveKey);
					getFullUserDataFromPHP(saveKey, userVO.hash);
				}
			}
			if (saveKey in users == true)
				return;
			users[saveKey] = userVO;
		}
		
		static public function removeUser(userVO:UserVO, saveKey:String = null, imideately:Boolean = false):void {
			if (userVO == null)
				return;
			if (users == null)
				return;
			if (saveKey == null)
				saveKey = userVO.uid;
			if (saveKey in users == false)
				return;
			if (userVO.dispose(imideately) == true) 
				delete users[saveKey];
		}
		
		static private function clearUsers():void {
			for (var s:String in users) {
				users[s].dispose(true);
				delete users[s];
			}
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  NEW USERS  ||  GET USER BY OBJECT  -->  ////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function getUserByContactObject(data:Object):UserVO {
			var userVO:UserVO = getFullUserData(data.uid, false);
			if (userVO != null) {
				if (userVO.hash != null)
					return userVO;
				if (userVO.setDataFromContactObject(data) == true)
					S_USER_UPDATED.invoke(userVO);
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromContactObject(data);
			addUser(userVO);
			return userVO;
		}
		
		static private function getNewUserByType(data:Object):UserVO 
		{
			if (data != null && "type" in data && data.type == UserType.BOT)
			{
				return new BotVO();
			}
			return new UserVO();
		}
		
		/*static public function getUserByMessageObject(data:Object):UserVO {
			var userVO:UserVO = getFullUserData(data.uid, false);
			if (userVO != null && userVO.hash == null) {
				userVO.setDataFromContactObject(data);
				return userVO;
			}
			userVO = new UserVO();
			userVO.setDataFromContactObject(data);
			addUser(userVO);
			return userVO;
		}*/
		
		static public function getUserByChatUserObject(data:Object, needObserve:Boolean = true):UserVO {
			var userVO:UserVO
			if ("uid" in data)
			{
				userVO = getFullUserData(data.uid, false);
			}
			
			if (userVO != null) {
				if (userVO.hash != null)
					return userVO;
				if (userVO.setDataFromChatUserObject(data) == true)
					S_USER_UPDATED.invoke(userVO);
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromChatUserObject(data);
			addUser(userVO, null, needObserve);
			return userVO;
		}
		
		static public function getUserByQuestionObject(data:Object):UserVO {
			if ("user" in data == false || data.user == null)
				return null;
			if ("uid" in data.user == false || data.user.uid == null || data.user.uid.length == 0)
				return null;
			var userVO:UserVO = getFullUserData(data.user.uid, false);
			if (userVO != null) {
				if (userVO.hash != null)
					return userVO;
				if (userVO.setDataFromQuestionUserObject(data.user) == true)
					S_USER_UPDATED.invoke(userVO);
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromQuestionUserObject(data.user);
			addUser(userVO);
			return userVO;
		}
		
		static public function getUserByPhonebookObject(data:Object, hash:String):UserVO {
			var userVO:UserVO = getFullUserData(hash, false);
			if (userVO != null) {
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromPhonebookObject(data);
			addUser(userVO, hash);
			return userVO;
		}
		
		static public function addContactObjectToUser(data:Object, hash:String):UserVO {
			var userVOByHash:UserVO = getFullUserData(hash, false);
			if (userVOByHash == null)
				return null;
			var userVO:UserVO = getFullUserData(data.uid, false);
			if (userVO != null) {
				if (userVO.setDataFromPhonebookObject( { phone:userVOByHash.phone, name:userVOByHash.phoneName } ) == true)
					S_USER_UPDATED.invoke(userVO);
				removeUser(userVOByHash, hash);
				return userVO;
			}
			userVOByHash.setDataFromContactObject(data);
			addUser(userVOByHash);
			delete users[hash];
			return userVOByHash;
		}
		
		static public function getUserByMessageObject(data:ChatMessageVO):UserVO {
			var userVO:UserVO = getFullUserData(data.userUID, false);
			if (userVO != null)
				return userVO;
			userVO = getNewUserByType(data);
			userVO.setDataFromMessageObject(data);
			addUser(userVO);
			return userVO;
		}
		
		static public function getUserByCallUserObject(data:Object):UserVO {
			var userVO:UserVO = getFullUserData(data.uid, false);
			if (userVO != null) {
				if (userVO.hash != null)
					return userVO;
				if (userVO.setDataFromCallUserObject(data) == true)
					S_USER_UPDATED.invoke(userVO);
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromCallUserObject(data);
			addUser(userVO);
			return userVO;
		}
		
		static public function getUserByBanObject(data:UserBan911VO):UserVO {
			var userVO:UserVO = getFullUserData(data.user_uid, false);
			if (userVO != null) {
				if (userVO.disposed) {
					userVO.disposed = false;
					userVO.setDataFromBanObject(data);
				}
				else if (userVO.getDisplayName() == "" || userVO.getDisplayName() == null) {
					userVO.setDataFromBanObject(data);
				}
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromBanObject(data);
			var needObserve:Boolean = false;
			if (userVO.getDisplayName() == "" || userVO.getDisplayName() == null)
			{
				needObserve = true;
			}
			addUser(userVO, null, needObserve);
			return userVO;
		}
		
		static public function getUserByExtensionObject(data:Extension):UserVO {
			var userVO:UserVO = getFullUserData(data.user_uid, false);
			if (userVO != null) {
				if (userVO.disposed) {
					userVO.disposed = false;
					userVO.setDataFromExtesnsionObject(data);
				}
				else if (userVO.getDisplayName() == "" || userVO.getDisplayName() == null) {
					userVO.setDataFromExtesnsionObject(data);
				}
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromExtesnsionObject(data);
			var needObserve:Boolean = false;
			if (userVO.getDisplayName() == "" || userVO.getDisplayName() == null)
			{
				needObserve = true;
			}
			addUser(userVO, null, needObserve);
			return userVO;
		}
		
		static public function getUserByBanPayerObject(data:UserBan911VO):UserVO {
			var userVO:UserVO = getFullUserData(data.payer_uid, false);
			if (userVO != null)
			{
				if (userVO.disposed) {
					userVO.disposed = false;
					userVO.setDataFromBanPayerObject(data);
				}
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromBanPayerObject(data);
			addUser(userVO);
			return userVO;
		}
		
		static public function getUserByBanProtectionObject(data:PaidBanProtectionData):UserVO {
			var userVO:UserVO = getFullUserData(data.user_uid, false);
			if (userVO != null)
			{
				if (userVO.disposed) {
					userVO.disposed = false;
					userVO.setDataFromBanProtectionObject(data);
				}
				else if (userVO.getDisplayName() == "" || userVO.getDisplayName() == null) {
					userVO.setDataFromBanProtectionObject(data);
				}
				return userVO;
			}
			userVO = getNewUserByType(data);
			userVO.setDataFromBanProtectionObject(data);
			addUser(userVO);
			return userVO;
		}
		
		static public function getUserByPhone(phone:String):UserVO {
			if (users == null) {
				return null;
			}
			for (var s:String in users) {
				if (users[s] != null && (users[s] as UserVO).phone == phone) {
					return users[s] as UserVO;
				}
			}
			return null;
		}
		
		static public function getRandomUser():UserVO {
			if (users == null)
				return null;
			var count:int = Math.random() * 11;
			if (count == 0)
				return null;
			var i:int = 0;
			for (var n:String in users) {
				if (i == count)
					return users[n];
				i++;
			}
			return null;
		}
		
		static public function getUserBy(val:String):UserVO {
			if (users == null)
				return null;
			if(val==null){
				echo("UsersManager","getUserBy","val is null, problem!",true);
				return null;
			}
			for (var n:String in users) {
				if (val.indexOf("+") == 0) {
					if (users[n].phone == val.substr(1))
						return users[n];
				} else if (users[n].login == val)
					return users[n];
			}
			return null;
		}
		
		static public function getUserByUID(val:String):UserVO {
			if (users == null)
			{
				return null;
			}
			if (val in users == true)
				return users[val];
			return null;
		}
		
		static public function addToMain(userVO:UserVO):void {
			if (userVO == null || userVO.disposed == true || userVO.setted == true)
				return;
			registrateUserUID(userVO.uid);
			getFullUserDataFromPHP(userVO.uid, userVO.hash);
		}
		
		static public function update(userVO:UserVO):void {
			getFullUserDataFromPHP(userVO.uid, userVO.hash, true);
			QuestionsStatisticsManager.clearByUser(userVO.uid);
		}
		
		static public function getUserByTradingOrder(tradingOrder:TradingOrder):UserVO {
			var userVO:UserVO = getFullUserData(tradingOrder.uid, false);
			if (userVO != null)
				return userVO;
			return null;
		}
		
		static public function complain(chat:ChatVO, callback:Function):void {
			if (chat != null && chat.users != null && chat.users.length == 1 && chat.type == ChatRoomType.PRIVATE) {
				PHP.complain_complain(onCompleinResult, "user", chat.users[0].uid, "alarm", null, callback);
				PHP.call_statVI("chatComplain", chat.uid + "," + chat.securityKey, null, chat.users[0].uid);
			}
		}
		
		static private function onCompleinResult(r:PHPRespond):void {
			if (r.additionalData != null && r.additionalData is Function) {
				(r.additionalData as Function)(!r.error);
			}
			if (r.error == true) {
				ToastMessage.display(r.errorMsg);
			} else {
				ToastMessage.display(Lang.repostSent);
			}
			r.dispose();
		}
	}
}