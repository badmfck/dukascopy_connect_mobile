package com.dukascopy.connect.sys.notificationManager {
	
	import com.distriqt.extension.core.Core;
	import com.distriqt.extension.firebase.Firebase;
	import com.distriqt.extension.pushnotifications.AuthorisationStatus;
	import com.distriqt.extension.pushnotifications.PushNotifications;
	import com.distriqt.extension.pushnotifications.Service;
	import com.distriqt.extension.pushnotifications.builders.ChannelBuilder;
	import com.distriqt.extension.pushnotifications.events.AuthorisationEvent;
	import com.distriqt.extension.pushnotifications.events.PushNotificationEvent;
	import com.distriqt.extension.pushnotifications.events.RegistrationEvent;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.LoginScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.chat.main.VIChatScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.sqlite.SQLRespond;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.greensock.TweenMax;
	import flash.desktop.InvokeEventReason;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.utils.ByteArray;
	
	public class PushNotificationsNative {
		
		/*static private const GCM_PROJECT_NUMBER:String = "478656391803";
		
		static private const FIREBASE_PROJECT_NUMBER:String = "nimble-gate-504";
		static private const FIREBASE_SERVICE_KEY:String = "AIzaSyCoZ166rrAThwHJF6FA6k4e1FE_a4hyk3U";*/
		
		static public const TYPE_URL:String = "url";
		static public const TYPE_TEXT:String = "text";
		static public const TYPE_PHASE:String = "phase";
		static public const NEW_PHONE:String = "new-phone";
		static public const TYPE_CHANNEL:String = "channel";
		static public const TYPE_CHALLENGE:String = "challenge";
		static public const NOTIFICATION_MAIN_CHANNEL:String = "main";
		
		private static var _invokedByNotification:Boolean = false;
		
		private static var notificationData:Object = null;	
		
		private static var invoked:Boolean = false;
		static private var updatedChats:Array;
		static private var updatedChatsNum:int;
		static private var currentMessagesArray:Array;
		static private var followNotification:Boolean;
		static private var messagesToSave:Array;
		
		static private var authorized:Boolean = false;
		static private var tokenSaved:Boolean = false;
		static private var initialized:Boolean = false;
		static private var coreInitialized:Boolean = false;
		static private var notificationsInitialized:Boolean = false;
		static private var notificationsAuthorized:Boolean = false;
		
		static private var notificationToken:String;
		static private var newUnreadedMessages:Array;
		static private var newNotificationMessages:Array;
		static public var sleepMode:Boolean;
		
		/**@CONSTRUCTOR**/
		public function PushNotificationsNative():void { }
		
		public static function init():void {
			if (initialized)
				return;
			initialized = true;
			// Native events
			NativeApplication.nativeApplication.executeInBackground = true;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
			// Push notifications
			initCore();
			initNotifications();
			// Authorization signals
			Auth.S_AUTHORIZED.add(onAuthComplete);
			Auth.S_NEED_AUTHORIZATION.add(onAuthExpire);
		}
		
		static private function onAuthComplete():void {
			authorized = true;
			saveToken();
		}
		
		private static function onAuthExpire():void {
			tokenSaved = false;
			authorized = false;
		}
		
		static private function initCore():void {
			if (Config.PLATFORM_WINDOWS)
				return;
			if (coreInitialized == true)
				return;
			if (Core.isSupported == true) {
				try {
					Core.init();
					coreInitialized = true;
				} catch (e:Error) {
					echo("PushNotificationsNative", "initCore", e.message);
				}
			} else
				echo("PushNotificationsNative", "initCore", "Core not supported");
		}
		
		private static function initNotifications():void {
			if (Config.PLATFORM_WINDOWS)
				return;
			if (notificationsInitialized == true)
				return;
			if (PushNotifications.isSupported == false) {
				echo("PushNotificationsNative", "initRemoteNotifications", "PushNotifications not supported");
				return;
			}
			notificationsInitialized = true;
			var service:Service;
			if (PushNotifications.service.implementation == "iOS") {
				service = new Service(Service.APNS);
			} else {
				Firebase.init("AIzaSyCoZ166rrAThwHJF6FA6k4e1FE_a4hyk3U");
				service = new Service(Service.FCM);
				service.channels.push(
					new ChannelBuilder()
						.setId(NOTIFICATION_MAIN_CHANNEL)
						.setName("channel notification")
						.enableVibration(false)
						.setImportance(4)
						.build()
				);
			}
			PushNotifications.service.addEventListener(AuthorisationEvent.CHANGED, authorisationChangedHandler);
			PushNotifications.service.setup(service);
			authorisationChangedHandler();
		}
		
		private static function authorisationChangedHandler(event:AuthorisationEvent = null):void {
			switch (PushNotifications.service.authorisationStatus()) {
				case AuthorisationStatus.AUTHORISED:
					if (notificationsAuthorized == false) {
						notificationsAuthorized = true;
						registerDevice();
						PushNotifications.service.register();
					}
					break;
				case AuthorisationStatus.NOT_DETERMINED:
					notificationsAuthorized = false;
					PushNotifications.service.requestAuthorisation();
					break;
				case AuthorisationStatus.DENIED:
					notificationsAuthorized = false;
					if (PushNotifications.service.canOpenDeviceSettings)
						PushNotifications.service.openDeviceSettings();
					break;
			}
		}
		
		private static function registerDevice():void {
			PushNotifications.service.addEventListener(RegistrationEvent.REGISTER_SUCCESS, registerSuccessHandler);
			PushNotifications.service.addEventListener(RegistrationEvent.CHANGED, registrationChangedHandler);
			PushNotifications.service.addEventListener(RegistrationEvent.REGISTER_FAILED, registerFailedHandler);
			PushNotifications.service.addEventListener(RegistrationEvent.ERROR, errorHandler);
			PushNotifications.service.addEventListener(PushNotificationEvent.NOTIFICATION_SELECTED, notificationHandler);
			
			PushNotifications.service.register();
		}
		
		private static function registerSuccessHandler(event:RegistrationEvent):void {
			notificationToken = event.data;
			saveToken();
		}
		
		static private function formatToken(data:String):String {
			if (data != null && data.indexOf("{") != -1 && data.indexOf("}") != -1) {
				try {
					var tokenData:Object = JSON.parse(data);
					if (tokenData != null && "bytes" in tokenData && tokenData.bytes is ByteArray) {
						var result:String = (tokenData.bytes as ByteArray).readUTF();
						return result;
					}
				} catch (e:Error) {
					//DialogManager.alert("!", e.message);
				}
			}
			return data;
		}
		
		private static function registrationChangedHandler(event:RegistrationEvent):void {
			notificationToken = event.data;
			saveToken();
		}
		
		private static function saveToken():void {
			if (tokenSaved == true)
				return;
			if (notificationToken == null || notificationData == "")
				return;
			if (authorized == false)
				return;
			tokenSaved = true;
			PHP.set_token(onTokenSentToServer, notificationToken);
			echo("PushNotificationsNative", "saveToken", "TOKEN SAVED: " + notificationToken);
		}
		
		static private function onTokenSentToServer(phpRespond:PHPRespond):void	{
			if (phpRespond.error == true)
				echo("PushNotificationsNative", "onTokenSentToServer", "Error: " + phpRespond.errorMsg);
		}
		
		private static function registerFailedHandler(event:RegistrationEvent):void {
			echo("PushNotificationsNative", "registerFailedHandler", event.data);
		}
		
		private static function errorHandler(event:RegistrationEvent):void{
			echo("PushNotificationsNative", "errorHandler", event.data);
		}
		
		private static function notificationHandler(event:PushNotificationEvent):void {
			echo("PushNotificationsNative", "notificationHandler", event.payload);
			try {
				notificationData = JSON.parse(event.payload);
			} catch (e:Error) {
				echo("PushNotificationsNative", "notificationHandler", "ERROR: -> can't parse payload");
				return;
			}
			followNotification = true;
			readNotifications();
		}
		
		static private function readNotifications():void {
			if (Config.PLATFORM_APPLE == true && MobileGui.dce != null) {
				readAppleNotifications();
				
			} else if (Config.PLATFORM_ANDROID){
				readAndroidNootifications();
			//	handleRemoteNotification();
			}
			else
			{
				handleRemoteNotification();
			}
		}
		
		static private function readAndroidNootifications():void {
			var messagesDataString:String = MobileGui.androidExtension.getNotificationsData();
			var clicked:Boolean = NativeExtensionController.isNotificationClicked();
		//	MobileGui.dce.removeMessagesFromNotifications();
			if (messagesDataString != null && messagesDataString.toString() != "null") {
				
				if (messagesDataString.indexOf("open_chat_") != -1 && clicked == true)
				{
					messagesDataString.replace("open_chat_", "");
				}
				
				
				/*if (messagesDataString.indexOf("open_chat_") != -1 && clicked == true)
				{
					//local notificatin dispatched from application clicked;
					if (checkApplicationStatus(true) == true)
					{
						var chatUID:String = messagesDataString.slice("open_chat_".length);
						if (chatUID != null && chatUID != "")
						{
							if ((MobileGui.centerScreen.currentScreenClass == ChatScreen || MobileGui.centerScreen.currentScreenClass == VIChatScreen) && 
								ChatManager.getCurrentChat() != null && 
								ChatManager.getCurrentChat().uid == chatUID) {
									ChatManager.activateChat();
							} else {
								if (clicked)
								{
									var chatScreenData:ChatScreenData = new ChatScreenData();
									chatScreenData.chatUID = chatUID;
									chatScreenData.type = ChatInitType.CHAT;
									MobileGui.showChatScreen(chatScreenData);
								}
							}
						}
					}
				}
				else
				{*/
					currentMessagesArray = null;
					try {
						currentMessagesArray = JSON.parse(messagesDataString) as Array;
						var l:int = currentMessagesArray.length;
						for (var i:int = 0; i < l; i++) {
							currentMessagesArray[i] = JSON.parse(currentMessagesArray[i]);
						}
					} catch (e:Error) {
						//!TODO: обработать ошибку;
					//	handleRemoteNotification();
					}
					if (currentMessagesArray != null && currentMessagesArray.length > 0) {
						if (clicked)
						{
							followNotification = true;
						}
						saveNotificationsMessages(currentMessagesArray);
					} else {
						handleRemoteNotification();
					}
			//	}
			} else {
				handleRemoteNotification();
			}
		}
		
		static private function readAppleNotifications():void {
			var messagesDataString:String = MobileGui.dce.messagesFromNotifications();
			
			echo("PushNotificaionsNative", "readAppleNootifications", messagesDataString);

			MobileGui.dce.removeMessagesFromNotifications();
			if (messagesDataString != null && messagesDataString.toString() != "null") {
			
				currentMessagesArray = null;
				try {
					currentMessagesArray = JSON.parse(messagesDataString) as Array;
					echo("PushNotificaionsNative", "readAppleNootifications", "Process messages: "+currentMessagesArray.length);
					var l:int = currentMessagesArray.length;
					for (var i:int = 0; i < l; i++) {
						currentMessagesArray[i] = JSON.parse(currentMessagesArray[i]);
					}
				} catch (e:Error) {
					//!TODO: обработать ошибку;
					echo("PushNotificaionsNative", "readAppleNootifications", "Can't parse msg data");
					handleRemoteNotification();
				}
				if (currentMessagesArray != null && currentMessagesArray.length > 0) {
					saveNotificationsMessages(currentMessagesArray);
				} else {
					handleRemoteNotification();
				}
			} else {
				handleRemoteNotification();
			}
		}
		
		static private function saveNotificationsMessages(messagesData:Array):void {
			echo("PushNotificationsNative","saveNotificationsMessages","calling width messagesData, length: "+messagesData.length);
			updatedChats = new Array();
			updatedChatsNum = 0;
			newNotificationMessages = new Array();
			if (messagesData != null && messagesData.length > 0) {
				var messages:Array = new Array();
				var messageData:Object = new Object();
				var l:int = messagesData.length;
				var date:Date = new Date();
				for (var i:int = 0; i < l; i++) {
					if ("type" in messagesData[i] && messagesData[i].type == "call") {
						continue;
					}
					messageData = createMessageFromNotification(messagesData[i], date);
					messages.push(messageData);
					newNotificationMessages.push(messageData);
					if ((messagesData[i].chatUID in updatedChats) == false) {
						updatedChats[messagesData[i].chatUID] = messagesData[i].chatUID;
						updatedChatsNum ++;
					}
					if (newUnreadedMessages == null) {
						newUnreadedMessages = new Array();
					}
					if ((messagesData[i].chatUID in newUnreadedMessages) == false) {
						newUnreadedMessages[messagesData[i].chatUID] = messageData;
					} else {
						if (newUnreadedMessages[messagesData[i].chatUID] != null && messageData.num > newUnreadedMessages[messagesData[i].chatUID].num) {
							newUnreadedMessages[messagesData[i].chatUID] = messageData;
						}
					}
				}
				if (messages.length > 0) {
					saveMessagesToDatabase(messages);
				} else {
					echo("PushNotificationsNative","saveNotificationsMessages","messages length <= 0");
					handleRemoteNotification();
				}
			} else {
				handleRemoteNotification();
			}
		}
		
		static private function createMessageFromNotification(notification:Object, date:Date):Object 
		{
			var messageData:Object = new Object();
			messageData.status = "created";
			if ("id" in notification)
				messageData.id = notification.id;
			
			if ("chatUID" in notification)
				messageData.chat_uid = notification.chatUID;
			
			if ("num" in notification)
				messageData.num = notification.num;
			
			messageData.created = 0;
			if ("created" in notification && !isNaN(Number(notification.created)))
				messageData.created = Math.round(Number(notification.created));
			
			if ("text" in notification)
				messageData.text = notification.text;
			
			if ("userUid" in notification)
				messageData.user_uid = notification.userUid;
			
			if ("messageFrom" in notification)
				messageData.user_name = notification.messageFrom;
			
			if (messageData.created == 0)
			{
				messageData.created = Math.round(date.getTime() / 1000);
			}
			
			messageData.reaction = "";
			if ("avatar" in notification) {
				messageData.user_avatar = notification.avatar;
			}
			return messageData;
		}
		
		static private function saveMessagesToDatabase(messages:Array):void {
			if (SQLite.isReady) {
				SQLite.call_makeMessages(onMessagesSaved, messages);
			} else {
				messagesToSave = messages;
				SQLite.S_READY.add(onDatabaseReady);
			}
		}
		
		static private function onDatabaseReady():void {
			SQLite.S_READY.remove(onDatabaseReady);
			if (messagesToSave != null) {
				saveMessagesToDatabase(messagesToSave);
			}
		}
		
		static private function onMessagesSaved(r:SQLRespond = null):void {
			var result:Boolean = checkApplicationStatus(true);
			echo("PushNotificationsNative", "onMessagesSaved", "result: "+result);
			
			if (!result){
				notificationData = null;
				return;
			}
			
			echo("PushNotificationsNative", "onMessagesSaved", "num: "+updatedChatsNum);
			
			if (updatedChatsNum == 0) {
				handleRemoteNotification();
				notificationData = null;
				return;
			}


			var isChatScreenOpened:Boolean=MobileGui.centerScreen.currentScreenClass == ChatScreen || MobileGui.centerScreen.currentScreenClass == VIChatScreen;

				if (ChatManager.isLoadedFromStore() == false) {
					
					ChatManager.S_LATEST.add(onLatestChatsLoaded);
					
					if (ChatManager.isLoadingFromStore() == false)
						ChatManager.getChats();

					echo("PushNotificationsNative", "onMessagesSaved", "is loaded from store = false, is loading ="+ChatManager.isLoadingFromStore() +" returning");

					return;

				} else {
					echo("PushNotificationsNative", "onMessagesSaved", "latest no loaded from store");
					checkForChatsExistance();
					processUnreadedMessages();
				}

				echo("PushNotificationsNative", "onMessagesSaved", "go deeper");

				if (updatedChatsNum == 1 || (notificationData != null && notificationData.chatUID != null)) {
					var chatUID:String;
					
					echo("PushNotificationsNative", "onMessagesSaved", "go deeper");
					
					if (notificationData != null && notificationData.chatUID != null) {
						chatUID = notificationData.chatUID;
					} else {
						for each(var chat:String in updatedChats) {
							chatUID = chat;
						}
					}

					if (isChatScreenOpened && ChatManager.getCurrentChat().uid == chatUID) {
							echo("PushNotificationsNative", "onMessagesSaved", "activate chat")
							ChatManager.activateChat();
					} else {
						echo("PushNotificationsNative", "onMessagesSaved", "no opened chat. followNotification: "+followNotification)
						if (followNotification == true) {
							var chatScreenData:ChatScreenData = new ChatScreenData();
							chatScreenData.chatUID = chatUID;
							chatScreenData.type = ChatInitType.CHAT;
							var chatVO:ChatVO = ChatManager.getChatByUID(chatUID);
							if (chatVO == null){
								chatVO = ChatManager.getLocalChatByUID(chatUID);
							}
							chatScreenData.chatVO = chatVO;
							MobileGui.showChatScreen(chatScreenData);
						}
					}
				} else {

					
					if(isChatScreenOpened && ChatManager.getCurrentChat() != null){
						// TODO: check if current chat uid exists in updatedChats
						ChatManager.activateChat();
						echo("PushNotificationsNative", "onMessagesSaved", "Update current chat screen ")
					}else{
						echo("PushNotificationsNative", "onMessagesSaved", "change to root screen: "+followNotification);
						if (followNotification == true) {
							resortLatests();
							MobileGui.changeMainScreen(RootScreen, null);
						}
					}

				}
				
				notificationData = null;
		}
		
		static private function resortLatests():void 
		{
			ChatManager.resortLatests();
		}
		
		static private function checkForChatsExistance():void 
		{

			echo("PushNotificationsNative", "checkForChatsExistance", "1");

			if (newNotificationMessages != null)
			{
				var l:int = newNotificationMessages.length;
				
				var chat:ChatVO;
				var chatsNum:int = 0;
				var lastMessage:Object;
				for (var i:int = 0; i < l; i++) 
				{
					if ("chat_uid" in newNotificationMessages[i] && newNotificationMessages[i].chat_uid != null && newNotificationMessages[i].chat_uid != "")
					{
						chat = ChatManager.getChatByUID(newNotificationMessages[i].chat_uid);
						
						if (chat == null)
						{
							chat = ChatManager.getLocalChat(newNotificationMessages[i]);
							lastMessage = newNotificationMessages[i];
							ChatManager.needToUpdate = true;
							chatsNum ++;
						}
					}
				}
				if (ChatManager.needToUpdate == true && NetworkManager.isConnected == true)
				{
					if (chatsNum == 1 && chat != null)
					{
						var additionalData:String = "";
						if (chat.uid == null && lastMessage != null)
						{
							for (var key:String in lastMessage) 
							{
								additionalData += key + "=" + lastMessage[key] + "|";
							}
						}
						
						ChatManager.loadChatFromPHP(chat.uid, false, "checkForChatsExistance|" + additionalData);
					}
					else
					{
						ChatManager.reloadLatests();
					}
				}
				
				newNotificationMessages = null;
				echo("PushNotificationsNative", "checkForChatsExistance", "2");
			}
		}
		
		static private function processUnreadedMessages():void {
			echo("PushNotificationsNative", "processUnreadedMessages", "1");
			var chatsChanged:Boolean = false;
			var chat:ChatVO;
			if (newUnreadedMessages != null) {
				if (ChatManager.isLoadedFromStore() == true) {
					for (var uid:String in newUnreadedMessages) {
						if (newUnreadedMessages[uid] != null) {
							chat = ChatManager.getChatByUID(uid);
							if (chat != null) {
								if (chat.messageVO != null) {
									if (chat.messageVO.num < newUnreadedMessages[uid].num) {
										chatsChanged = true;
										chat.setNewUreadedMessage(newUnreadedMessages[uid], false);
									}
								} else {
									chatsChanged = true;
									chat.setNewUreadedMessage(newUnreadedMessages[uid], false);
								}
							}
						}
					}
					newUnreadedMessages = null;
					NewMessageNotifier.dispatchUpdateLater();
					if (chatsChanged) {
						ChatManager.updateLatestsInStore();
					}
				} else {
					ChatManager.S_LATEST.add(onLatestChatsLoaded);
				}
			}
			echo("PushNotificationsNative", "processUnreadedMessages", "2");
		}
		
		static private function onActivate(e:Event):void {
			WSClient.call_sleepMode(false);
			sleepMode = false;
		}
		
		static private function onDeactivate(e:Event):void {
			invoked = false;
			WSClient.call_sleepMode(true);
			sleepMode = true;
		}
		
		static private function onInvoke(e:InvokeEvent):void {
			echo("PushNotificationsNative", "onInvoke",e.reason);
			if (e.reason == InvokeEventReason.OPEN_URL) {
				if (e.arguments && e.arguments.length > 0) {
					var msk:String = "dukascopy://";
					var url:String = String(e.arguments[0]).substr(String(e.arguments[0]).indexOf(msk) + msk.length);
					var parsedParams:Array = url.split("/");
					if (parsedParams != null) {

						if (parsedParams[0] == 'user') {

							if (parsedParams[1] == null)
								return;
							notificationData = { };
							notificationData.type = TYPE_URL;
							notificationData.fxID = uint(parsedParams[1]);
							notificationData.screen = 'chat';
							handleRemoteNotification();
							parsedParams = null;

						} else if (parsedParams[0] == 'payments') {

							parsedParams = null;
							notificationData = { };
							notificationData.type = TYPE_URL;
							notificationData.screen = 'payments';
							handleRemoteNotification();

						} else if (parsedParams[0] == 'support') {

							if (parsedParams[1] == null)
								return;
							notificationData = { pid:int(parsedParams[1]) };
							notificationData.type = TYPE_URL;
							notificationData.screen = 'support';
							handleRemoteNotification();
							parsedParams = null;

						} else if (parsedParams[0] == 'conv') {
							if (parsedParams[1] == null)
								return;
							notificationData = { };
							notificationData.type = TYPE_TEXT;
							notificationData.screen = 'chat';
							notificationData.chatUID = parsedParams[1];
							handleRemoteNotification();
							parsedParams = null;
						} 
					}
				}

				//uid = "I6DzDaWqWKWE"

			} else if (e.reason == InvokeEventReason.NOTIFICATION) {
			} else {
				TweenMax.delayedCall(1, checkPendingNotifications, null, true);
			}
		}
		
		static private function checkPendingNotifications():void 
		{
			echo("PushNotificationsNative", "checkPendingNotifications");
			if (invoked == true)
				return;
			
			// считываем нотификации при обычном запуске приложения;
			followNotification = false;
			readNotifications();
			invoked = true;
		}
		
		static private function onLatestChatsLoaded():void {
			if (ChatManager.isLoadedFromStore() == true) {
				ChatManager.S_LATEST.remove(onLatestChatsLoaded);
			//	saveNotificationsMessages(currentMessagesArray);
				
				onMessagesSaved();
				
				/*if (newUnreadedMessages != null)
				{
					processUnreadedMessages();
				}*/
			}
		}
		
		static public function handleRemoteNotification(ignoreAuthScreen:Boolean = false):Boolean {
			echo("PushNotificationsNative","handleRemoteNotification","ignoreAuthScreen: "+ignoreAuthScreen);
			var result:Boolean = checkApplicationStatus(false, ignoreAuthScreen);
			if (result == false)
				return false;
			if (notificationData == null)
				return false;
			var chatScreenData:ChatScreenData;
			switch (notificationData.type) {
				case TYPE_CHANNEL:
				case TYPE_TEXT:
				case TYPE_CHALLENGE:
					if (notificationData.chatUID == null) {
						notificationData = null;
						_invokedByNotification = false;
						return false;
					}
					chatScreenData = new ChatScreenData();
					chatScreenData.chatUID = notificationData.chatUID;
					chatScreenData.type = ChatInitType.CHAT;
					MobileGui.doNotOpenScreenOnStart();
					MobileGui.showChatScreen(chatScreenData);
					notificationData = null;
					_invokedByNotification = false;
					return true;
				break;	
				case NEW_PHONE:
					if (notificationData.phone == null) {
						notificationData = null;
						_invokedByNotification = false;
						return false;
					}
					PhonebookManager.updateUserByPhone(notificationData.phone);
					notificationData = null;
					_invokedByNotification = false;
				break;
				case TYPE_URL:
					if (notificationData.screen && notificationData.screen == 'payments') {
						MobileGui.doNotOpenScreenOnStart();
						MobileGui.openMyAccountIfExist();
						notificationData = null;
						_invokedByNotification = false;
						return true;
					}
					if (notificationData.screen && notificationData.screen == 'chat') {
						if (notificationData.fxID == null) {
							notificationData = null;
							_invokedByNotification = false;
							return false;
						}
						chatScreenData = new ChatScreenData();
						chatScreenData.fxid = int(notificationData.fxID);
						chatScreenData.type = ChatInitType.FXID;
						MobileGui.doNotOpenScreenOnStart();
						MobileGui.showChatScreen(chatScreenData);
						notificationData = null;
						return true;
					}
					if (notificationData.screen && notificationData.screen == 'support'){
						if (notificationData.pid == null) {
							notificationData = null;
							_invokedByNotification = false;
							return false;
						}
						chatScreenData = new ChatScreenData();
						chatScreenData.pid = notificationData.pid;
						chatScreenData.type = ChatInitType.SUPPORT;
						MobileGui.doNotOpenScreenOnStart();
						MobileGui.showChatScreen(chatScreenData);
						ServiceScreenManager.closeView();
						notificationData = null;
						return true;
					}
					notificationData = null;
					_invokedByNotification = false;
				break;
				default:
					echo("PushNotificationsNative", "handleRemoteNotification", notificationData.type + " is not handeled");
				break;
			}
			return false;
		}
		
		static private function checkApplicationStatus(ignoreCurrentNotificationDataStatus:Boolean = false, ignoreAuthScreen:Boolean = false):Boolean 
		{
			if (notificationData == null && ignoreCurrentNotificationDataStatus == false) {
				_invokedByNotification = false;
				return false;
			}
			if (notificationData != null && notificationData.type == TYPE_PHASE) {
				Auth.updateAfterPhasePush();
				notificationData = null;
				return false;
			}
			if (MobileGui.dialogShowed == true)
				DialogManager.closeDialog();
			if (MobileGui.centerScreen == null)
				return false;
			if (ignoreAuthScreen == false && MobileGui.centerScreen.currentScreenClass == LoginScreen) {
				//notificationData = null;
				return false;
			}
			
			return true;
		}
		
		static public function setNotificationDataForSupport(val:int):void {
			notificationData = { pid:val };
			notificationData.type = TYPE_URL;
			notificationData.screen = 'support';
			handleRemoteNotification();
		}
		
		static public function setToken(token:String):void 
		{
			notificationToken = token;
			saveToken();
		}
		
		static public function get invokedByNotification():Boolean { return _invokedByNotification; }
		static public function set invokedByNotification(value:Boolean):void {
			_invokedByNotification = value;
		}
	}
}