package com.dukascopy.connect.sys.chatManager {

	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.ChatSettingsModel;
	import com.dukascopy.connect.data.LocalSoundFileData;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.data.MessageData;
	import com.dukascopy.connect.data.RemoteSoundFileData;
	import com.dukascopy.connect.data.ResponseResolver;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.data.paidChat.PaidChatData;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.data.screenAction.customActions.SendMessageToUserAction;
	import com.dukascopy.connect.data.screenAction.customActions.SendVoiceToChatAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.sys.GlobalDate;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.applicationShop.parser.ShopProductDataParser;
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.chat.RichMessageDetector;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.contactsManager.ContactsManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.geolocation.GeolocationManager;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.imageManager.ImageUploader;
	import com.dukascopy.connect.sys.latestManager.LatestsManager;
	import com.dukascopy.connect.sys.messagesController.MessagesController;
	import com.dukascopy.connect.sys.network.DocumentUploader;
	import com.dukascopy.connect.sys.notificationManager.InnerNotificationManager;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.sqlite.SQLRespond;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.video.VideoUploader;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.sys.ws.WSMethodType;
	import com.dukascopy.connect.type.ActionType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.connect.vo.chat.ChatMessageReaction;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	
	//import com.milkmangames.nativeextensions.CMNetworkType;
	
	import com.telefision.sys.signals.Signal;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.system.Capabilities;
	import gibberishAES.AESCrypter;

	/**
	 * @author Igor Bloom
	 */

	public class ChatManager {
		
		static public var S_LATEST:Signal = new Signal('ChatManager.S_LATEST');
		static public var S_LATEST_OVERRIDE:Signal = new Signal('ChatManager.S_LATEST_OVERRIDE');
		static public var S_LATEST_REPOSITION:Signal = new Signal('ChatManager.S_LATEST_REPOSITION');
		static public var S_CHAT_OPENED:Signal = new Signal('ChatManager.S_CHAT_OPENED');
		static public var S_CHAT_UPDATED:Signal = new Signal('ChatManager.S_CHAT_UPDATED');
		static public var S_CHAT_UNREADED_UPDATED:Signal = new Signal('ChatManager.S_CHAT_UNREADED_UPDATED');
		static public var S_CHAT_STAT_CHANGED:Signal = new Signal('ChatManager.S_CHAT_STAT_CHANGED');
		static public var S_CHAT_USERS_CHANGED:Signal = new Signal('ChatManager.S_CHAT_USERS_CHANGED');
		static public var S_USER_WRITING:Signal = new Signal('ChatManager.S_USER_WRITING');
		static public var S_MESSAGES:Signal = new Signal('ChatManager.S_MESSAGES');
		static public var S_HISTORICAL_MESSAGES:Signal = new Signal('ChatManager.S_HISTORICAL_MESSAGES');
		static public var S_MESSAGES_LOADING_FROM_PHP:Signal = new Signal('ChatManager.S_MESSAGES_LOADING_FROM_PHP');
		static public var S_REMOTE_MESSAGES_STOP_LOADING:Signal = new Signal('ChatManager.S_REMOTE_MESSAGES_STOP_LOADING');
		static public var S_MESSAGE:Signal = new Signal('ChatManager.S_MESSAGE');
		static public var S_MESSAGE_UPDATED:Signal = new Signal('ChatManager.S_MESSAGE_UPDATED');
		static public var S_STREAMS:Signal = new Signal('ChatManager.S_STREAMS');
		static public var S_PIN:Signal = new Signal('ChatManager.S_PIN');
		static public var S_ERROR_CANT_OPEN_CHAT:Signal = new Signal('ChatManager.S_ERROR_CANT_OPEN_CHAT');
		static public var S_USER_REMOVED_FROM_CHAT:Signal = new Signal('ChatManager.S_USER_REMOVED_FROM_CHAT');
		static public var S_USER_ADDED_TO_CHAT:Signal = new Signal('ChatManager.S_USER_ADDED_TO_CHAT');
		static public var S_BANNED_IN_CHAT:Signal = new Signal('ChatManager.S_BANNED_IN_CHAT');
		static public var S_UNBANNED_IN_CHAT:Signal = new Signal('ChatManager.S_UNBANNED_IN_CHAT');
		
		static public var UPDATE_CHAT_BACKGROUND:Signal = new Signal('ChatManager.UPDATE_CHAT_BACKGROUND');
		static public var S_TITLE_CHANGE:Signal = new Signal('ChatManager.S_TITLE_CHANGE');
		static public var S_AVATAR_CHANGE:Signal = new Signal('ChatManager.S_AVATAR_CHANGE');
		static public var S_SERVER_DATA_LOAD_START:Signal = new Signal('ChatManager.S_SERVER_DATA_LOAD_START');
		static public var S_SERVER_DATA_LOAD_END:Signal = new Signal('ChatManager.S_SERVER_DATA_LOAD_END');
		static public var S_CHAT_READY:Signal = new Signal('ChatManager.S_CHAT_READY');
		static public var S_CHAT_PREPARED:Signal = new Signal('ChatManager.S_CHAT_PREPARED');
		static public var S_CHAT_PREPARED_FAIL:Signal = new Signal('ChatManager.S_CHAT_PREPARED_FAIL');
		static public var S_EDIT_MESSAGE:Signal = new Signal('ChatManager.S_EDIT_MESSAGE');
		
		static public var S_LOAD_START:Signal = new Signal('ChatManager.S_LOAD_START');
		static public var S_LOAD_STOP:Signal = new Signal('ChatManager.S_LOAD_STOP');
		
		static private var currentChat:ChatVO = null;
		static private var currentChatHash10:String = null;
		static private var currentChatHash50:String = null;
		
		static private var lastGettedChats:Array/*ChatVO*/ = null;
		
		static private var chatsToLoad:Array/*String*/;
		static private var chatsLoading:Array/*String*/;
		static private var latestChatsLoading:Boolean;
		static private var latestChatsLoaded:Boolean;
		static private var latestChats:Array/*ChatVO*/;
		
		static private var wasInited:Boolean = false;
		static private var currentDataVersion:int = 2;
		static private var latestChatsHash:String = '';
		static private var latestWasNull:Boolean = false;
		static private var isLocalChatsLoaded:Boolean = false;
		static public var needToUpdate:Boolean = false;
		
		static private var chatsSettings:Vector.<ChatSettingsModel> = new Vector.<ChatSettingsModel>();
		static private var _inChat:Boolean = false;
		static private var localChatSyncronizer:LocalChatsSynchronizer;
		
		//TODO: сделать менеджер для текущего чата и хранить там;
		static private var _chatUsersCollection:ChatUsersCollection;
		
		static private var lastGettedChatsCount:int = 3;
		static private var _notApproved:Boolean;
		static private var hmLoadedFromPHPAndSavedToSQL:Boolean = false;
		
		static private var geoMessage:ChatMessageVO;
		
		public function ChatManager() { }
		
		static public function init():void {
			if (wasInited)
				return;
			wasInited = true;
			
			AnswersManager.init();
			
			_chatUsersCollection = new ChatUsersCollection();
			
			localChatSyncronizer = new LocalChatsSynchronizer();
			
			Auth.S_PHAZE_CHANGE.add(onAccountPhaseChanged);
			
			// IGNORE NETWORK MANAGER ON IOS
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);



			WS.S_CONNECTED.add(onWSConnected);
			WS.S_DISCONNECTED.add(onWSDisconnected);
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
			WSClient.S_CHAT_USER_ENTER.add(onChatUserEnter);
			WSClient.S_CHAT_USER_REMOVE.add(onChatUserRemoved);
			WSClient.S_CHAT_USERS_ADD.add(onChatUsersAdded);
			WSClient.S_CHAT_MSG.add(onChatMessage);
			WSClient.S_CHAT_MSG_UPDATED.add(onChatMessageUpdated);
			WSClient.S_CHAT_MSG_REMOVED.add(onChatMessageRemoved);
			WSClient.S_PUSH_CHAT_STATUS.add(onChatPushStatusChanged);
			WSClient.S_USER_WRITING.add(onUserWriting);
			WSClient.S_CHAT_TITLE_CHANGE.add(onWSChatTitleChanged);
			WSClient.S_CHAT_AVATAR_CHANGE.add(onWSChatAvatarChanged);
			WSClient.S_DUPLICATED_MESSAGE.add(onMessageSentDuplicateError);
			WSClient.S_BLOCKED_MESSAGE.add(onMessageSentBlockedError);
			WSClient.S_REMOVE_MESSAGE.add(onMessageSentRemoveError);
			WSClient.S_BLOCKED_NO_SLOTS_MESSAGE.add(onMessageSentBlockedNoSlotsError);
			WSClient.S_MESSAGE_REACTION.add(onMessageReaction);
			GlobalDate.S_NEW_DATE.add(invokeLatestOverride);
			ImageUploader.S_FILE_UPLOADED.add(sendFileMessage);
			VideoUploader.S_FILE_UPLOADED.add(sendVideoMessage);
			VideoUploader.S_FILE_UPLOADED_FINISH.add(sendVideoMessageFinish);
			VideoUploader.S_FILE_UPLOADED_PROGRESS.add(sendVideoMessageProgress);
			WSClient.S_LOYALTY_CHANGE.add(onLoyaltyChanged);
			GD.S_ESCROW_INSTRUMENTS.add(onEscrowInstruments);
			
			S_CHAT_OPENED.add(onChatOpened);
		}
		
		static private function onEscrowInstruments(...rest):void {
			TweenMax.delayedCall(1, function():void {
				if (currentChat == null)
					return;
				if (currentChat.getQuestion() == null)
					return;
				currentChat.regenerateQuestionMessage();
				S_MESSAGE_UPDATED.invoke(currentChat.messages[0]);
			}, null, true);
		}
		
		private static function onLoyaltyChanged(loyalty:String):void
		{
			if (loyalty == "gold")
			{
				sendFastTrackRequest();
			}
		}
		
		static private function onAccountPhaseChanged(realChange:Boolean = true):void{
			if (realChange == true)
			{
				S_LATEST_OVERRIDE.invoke();
			}
			
			if (currentChat != null && currentChat.addCompanyMessage(true) == true)
				S_MESSAGES.invoke();
		}
		
		static private function onChatOpened():void {
			if (getCurrentChat() != null && getCurrentChat().type == ChatRoomType.CHANNEL) {
				if (getCurrentChat().settings == null || getCurrentChat().settings.dataReady == false || getCurrentChat().type == ChatRoomType.CHANNEL) {
					var resolver:ResponseResolver = new ResponseResolver();
					resolver.callback = onChatSettingsChanged;
					resolver.data = getCurrentChat();
					ChannelsManager.getChannelSettingsFromServer(getCurrentChat().uid, resolver);
				}
			}
			/*if (getCurrentChat() != null && getCurrentChat().type == ChatRoomType.COMPANY)
			{
				var chat:ChatVO = getChatByPID(getCurrentChat().pid);
				if (chat != null && chat.uid == null)
				{
					chat.setData(getCurrentChat().getRawData());
				}
			}*/
		}
		
		static private function onChatSettingsChanged(success:Boolean, chatVO:ChatVO):void {
			if (success == true) {
				ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.invoke(ChannelsManager.EVENT_AVATAR_CHANGED, chatVO.uid);
				ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.invoke(ChannelsManager.EVENT_BACKGROUND_CHANGED, chatVO.uid);
				ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.invoke(ChannelsManager.EVENT_MODE_CHANGED, chatVO.uid);
			}
		}
		
		static private function onConnectionChanged():void {
			if (NetworkManager.isConnected == false)
			{
				echo("conection", "disconnect");
				needToUpdate = true;
				_inChat = false;
			}
			else if (currentChat != null && currentChat.isLocal() == false)
			{
				if (currentChat.incomeLocal == true && NetworkManager.isConnected == true)
				{
					
				}
				else
				{
					loadChatMessages(true);
				}
			}
			
			if (NetworkManager.isConnected == true)
			{
				echo("conection", "connected. needToUpdate: " + needToUpdate);
				
				if (needToUpdate == true)
				{
					needToUpdate = false;
					getChatsFromPHP(false);
				}
				else
				{
					if (latestChats != null)
					{
						var l:int = latestChats.length;
						for (var i:int = 0; i < l; i++) 
						{
							if (latestChats[i].isIncomingLocalChat())
							{
								getChatsFromPHP(false);
								break;
							}
						}
					}
				}
			}
		}
		
		static private function onWSConnected():void {
			if (currentChat != null && currentChat.uid != null && currentChat.isLocal() == false) {
				chatEnter(currentChat.uid);
				loadChatFromPHP(currentChat.uid, false, "onWSConnected");
				loadChatMessages(true);
			}
		}
		
		static private function onWSDisconnected():void {
			chatsLoadingFromPHP = false;
			chatsLoadedFromPHP = false;
		}
		
		static private function onAuthNeeded():void {
			closeChat();
			clearLocalChats();
		}
		
		static private function invokeLatestOverride(date:int):void {
			S_LATEST_OVERRIDE.invoke();
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  OPEN CHAT BY ...  -->  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		static public function openChatByUID(chatUID:String):void {
			var existingChat:ChatVO = getChatByUID(chatUID);
			if (existingChat != null && existingChat.uid != null && existingChat.uid.length != 0) {
				openChatByVO(existingChat);
				return;
			}
			loadChatFromPHP(chatUID, true, "openChatByUID");
		}
		
		static public function openChatByUserUIDs(userUIDs:Array, createChatOnly:Boolean = false, caller:String = null):void {
			var existingChat:ChatVO = getChatWithUsersList(userUIDs);
			if (existingChat != null && existingChat.uid != null && existingChat.uid.length != 0) {
				openChatByVO(existingChat, createChatOnly);
				return;
			}
			PHP.chat_start(onChatLoadedFromPHPAndOpen, userUIDs, createChatOnly, caller);
		}
		
		static public function openChatByFXID(fxid:uint):void {
			var existingChat:ChatVO = getChatWithFXUser(fxid);
			if (existingChat != null && existingChat.uid != null && existingChat.uid.length != 0) {
				openChatByVO(existingChat);
				return;
			}
			PHP.call_chatCreateFX(onChatLoadedFromPHPAndOpen, fxid);
		}
		
		static public function openChatByPID(id:int):void {
			var existingChat:ChatVO = getChatByPID(id);
			if (existingChat != null && existingChat.uid != null && existingChat.uid.length != 0) {
				existingChat.updateSecurityKey(LatestsManager.dukascopySecurityKey);
				openChatByVO(existingChat);
				return;
			}
			PHP.company_startChat(onChatLoadedFromPHPAndOpen, id);
		}
		
		static public function openGuestSupportChat(guestUID:String, ep:int):void {
			PHP.company_startChat_guest(onChatLoadedFromPHPAndOpen, guestUID, ep);
		}
		
		/**
		 * Get company chat by PointID
		 * @param	callback	Function with chatVO
		 * @param	id	pointID
		 */
		static public function getCompanyChatByPID(callback:Function, id:int):void{
			var cvo:ChatVO = getChatByPID(id);
			if (cvo != null && cvo.uid != null && cvo.uid.length != 0) {
				cvo.updateSecurityKey(LatestsManager.dukascopySecurityKey);
				if (callback != null)
					callback(cvo);
				return;
			}
			
			// no chat, load from server
			PHP.company_startChat(function(respond:PHPRespond):void{
				if(respond.error){
					callback(null);
					return;
				}
				
				// parse chat, add to collection
				var c:ChatVO = getChatByUID(respond.data.uid);
				if (c == null) {
					c = new ChatVO(respond.data);
					addChatToLatest(c, false);
				}else
					c.setData(respond.data);
				
				if (c.type == ChatRoomType.COMPANY)
					c.updateSecurityKey(LatestsManager.dukascopySecurityKey);
				
				// update chats in store
				updateLatestsInStore();
				
				if(callback!=null)
					callback(c);
				
			}, id);
		}
		
		static private function onChatLoadedFromPHPAndOpen(phpRespond:PHPRespond):void {
			echo("ChatManager", "onChatLoadedFromPHPAndOpen");
 			if (phpRespond.error == true) {
				
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.04') != -1) {
					
					//"chat.04 No access - no ACC or phone record"
					
					closeChat();
					S_ERROR_CANT_OPEN_CHAT.invoke(phpRespond.errorMsg.substr(7));
					phpRespond.dispose();
					return;
				}
				
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.24') != -1) {
					// wrong transaction;
					ToastMessage.display("wrong transaction ID");
					
					phpRespond.dispose();
					return;
				}
				
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.23') != -1) {
					
					if (phpRespond.data != null && phpRespond.data.data != null)
					{
						var paidChatData:PaidChatData = new PaidChatData(phpRespond.data.data);
						if (phpRespond.additionalData != null && "usetUIDs" in phpRespond.additionalData && phpRespond.additionalData.usetUIDs != null &&
							phpRespond.additionalData.usetUIDs is Array && (phpRespond.additionalData.usetUIDs as Array).length > 0)
						{
							paidChatData.userUid = phpRespond.additionalData.usetUIDs[0];
						}
						else
						{
							ApplicationErrors.add("no data");
						}
						
						Shop.buyPaidChat(paidChatData);
					}
					else
					{
						ApplicationErrors.add();
					}
					
					phpRespond.dispose();
					return;
				}
				
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.22') != -1) {
					var parser:ShopProductDataParser = new ShopProductDataParser();
					var product:ShopProduct = parser.parse(phpRespond.data.data, new ProductType(ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION));
					if (product != null) {
						var chatUID:String;
						if (currentChat != null)
							chatUID = currentChat.uid;
						else
							chatUID = product.chatUID;
						Shop.buyChannelAccess(chatUID, product);
					}
					else
					{
						closeChat();
						S_ERROR_CANT_OPEN_CHAT.invoke(phpRespond.errorMsg);
					}
					
					phpRespond.dispose();
					return;
				}
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.03') != -1) {
					phpRespond.dispose();
					return;
				}
				if (phpRespond.errorMsg.toLowerCase() == PHP.NETWORK_ERROR) {
					if (phpRespond.additionalData != null && "createLocal" in phpRespond.additionalData && phpRespond.additionalData.createLocal == true) {
						if ("userUIDs" in phpRespond.additionalData && phpRespond.additionalData.userUIDs != null && phpRespond.additionalData.userUIDs.length == 1) {
							openChatByVO(localChatSyncronizer.addLocalChat(phpRespond.additionalData.userUIDs[0]));
							phpRespond.dispose();
							return;
						}
					}
					closeChat();
					S_ERROR_CANT_OPEN_CHAT.invoke(phpRespond.errorMsg);
					phpRespond.dispose();
					return;
				} else {
					closeChat();
					S_ERROR_CANT_OPEN_CHAT.invoke(phpRespond.errorMsg);
					phpRespond.dispose();
					return;
				}
			} else if (phpRespond.data == null) {
				closeChat();
				S_ERROR_CANT_OPEN_CHAT.invoke("");
				phpRespond.dispose();
				return;
			}
			echo("ChatManager", "onChatLoadedFromPHPAndOpen", "CHAT DATA EXISTS");
			
			//////////////////////////
			if (phpRespond.additionalData != null && "usetUIDs" in phpRespond.additionalData && phpRespond.additionalData.usetUIDs != null &&
							phpRespond.additionalData.usetUIDs is Array && (phpRespond.additionalData.usetUIDs as Array).length == 1)
			{
				if (Shop.getPendingTransaction((phpRespond.additionalData.usetUIDs as Array)[0]) != null)
				{
					Shop.clearPendingTransaction((phpRespond.additionalData.usetUIDs as Array)[0]);
				}
			}
			//////////////////////////
			
			var c:ChatVO;
			if ("uid" in phpRespond.data)
				c = getChatByUID(phpRespond.data.uid);
			if (c == null) {
				c = new ChatVO(phpRespond.data);
				addChatToLatest(c, false);
			} else
				c.setData(phpRespond.data);
			if (c.type == ChatRoomType.COMPANY)
				c.updateSecurityKey(LatestsManager.dukascopySecurityKey);
			
			updateLatestsInStore();
			
			var createChatOnly:Boolean = false;
			if (phpRespond.additionalData != null && "createChatOnly" in phpRespond.additionalData && phpRespond.additionalData.createChatOnly == true) {
				createChatOnly = true;
			}
			openChatByVO(c, createChatOnly);
			phpRespond.dispose();
		}
		
		static public function openChatByQuestionUID(quid:String):void {
			if (quid == "") {
				S_ERROR_CANT_OPEN_CHAT.invoke(ActionType.CHAT_CLOSE_ON_ERROR);
				return;
			}
			var cVO:ChatVO = AnswersManager.getChatByQuestionUID(quid, true);
			openChatByVO(cVO);
		}
		
		static public function openChatByVO(cVO:ChatVO, createChatOnly:Boolean = false):void {
			if (cVO == null)
				return;
			if (createChatOnly) {
				S_CHAT_READY.invoke(cVO);
				return;
			}
			
			if (currentChat == cVO) {
				currentChat.addCompanyMessage(true);
				S_CHAT_OPENED.invoke();
				currentChat.resetUnreaded();
				S_MESSAGES.invoke();
				chatEnter(cVO.uid);
				return;
			}
			closeChat();
			setCurrentChat(cVO);
			currentChat.resetUnreaded();
			S_CHAT_UNREADED_UPDATED.invoke(currentChat);
			if (currentChat.uid != null)
				PHP.chat_updateUnreadedMessages(currentChat.uid);
			if (currentChat.type == ChatRoomType.QUESTION || (currentChat.questionID != null && currentChat.questionID != "")) {
				echo("ChatManager", "openChatByVO", currentChat.questionID);
				currentChat.setQuestion(QuestionsManager.getQuestionByUID(currentChat.questionID));
				if (currentChat.uid == null) {
					S_MESSAGES.invoke();
					return;
				}
			}
			var onlyFromPHP:Boolean = false;
			if (Auth.key == "web")
			{
				onlyFromPHP = true;
			}
			loadChatMessages(onlyFromPHP);
		}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  OPEN CHAT BY ... || GET CHAT BY  -->  ///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		static public function getChatByUID(uid:String):ChatVO {
			if (currentChat != null && currentChat.uid == uid)
				return currentChat;
			var i:int;
			var l:int;
			if (lastGettedChats != null) {
				i = 0;
				l = lastGettedChats.length;
				for (i; i < l; i++) {
					if (lastGettedChats[i] != null && lastGettedChats[i].uid == uid) {
						if (i != 0)
							lastGettedChats.unshift(lastGettedChats[i]);
						if (lastGettedChats.length > lastGettedChatsCount)
							lastGettedChats.pop();
						return lastGettedChats[0];
					}
				}
			}
			echo("ChatManager", "getChatByUID", "chat uid: "+uid);
			lastGettedChats ||= [];
			var cvo:ChatVO;
			if (latestChats != null) {
				i = 0;
				l = latestChats.length;
				for (i; i < l; i++) {
					if (latestChats[i] != null && latestChats[i].uid == uid) {
						cvo = latestChats[i];
					}
				}
			}
			if (cvo == null)
				cvo = ChannelsManager.getChannel(uid);
			if (cvo == null)
				cvo = AnswersManager.getAnswer(uid);
			if (cvo != null) {
				lastGettedChats.unshift(cvo);
				if (lastGettedChats.length > lastGettedChatsCount)
					lastGettedChats.pop();
			}
			return cvo;
		}
		
		static public function getChatWithUsersList(userUIDs:Array):ChatVO {
			if (userUIDs == null || userUIDs.length == 0)
				return null;
			if (latestChats == null)
				return null;
			var privateChat:Boolean = userUIDs.length == 1;
			var n:int = 0;
			var l:int = latestChats.length;
			var cvo:ChatVO = null;
			for (n; n < l; n++) {
				cvo = latestChats[n];
				if (privateChat == true) {
					if (cvo.type == "private" && cvo.users != null && cvo.users.length == 1 && cvo.users[0].uid == userUIDs[0])
						return cvo;
					continue;
				}
				if (cvo.users != null && cvo.users.length == userUIDs.length) {
					var i:int = 0;
					var k:int = 0;
					var j:int = cvo.users.length;
					var equals:int = 0;
					for (i; i < j; i++) {
						for (k; k < j; k++) {
							if (cvo.users[i] != null && ('uid' in cvo.users[i]) && cvo.users[i].uid == userUIDs[k]) {
								equals++;
								break;
							}
						}
					}
					if (equals == j)
						return cvo;
				}
			}
			return null;
		}
		
		static public function getChatWithFXUser(userFXID:int = 0):ChatVO {
			if (userFXID == 0)
				return null;
			if (latestChats == null)
				return null;
			var n:int = 0;
			var l:int = latestChats.length;
			var cvo:ChatVO = null;
			for (n; n < l; n++) {
				cvo = latestChats[n];
				if (cvo.type == "private" && cvo.users != null && cvo.users.length == 1 && cvo.users[0].fxId == userFXID)
					return cvo;
			}
			return null;
		}
		
		static private function getChatByPID(pid:int):ChatVO {
			if (latestChats == null)
				return null;
			var m:int = 0;
			var l:int = latestChats.length;
			for (m; m < l; m++){
				if(latestChats[m]!=null && latestChats[m].pid==pid)
					return latestChats[m];
			}
			return null;
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  GET CHAT BY  ||  CURRENT CHAT  -->  /////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function closeChat(chat:ChatVO = null):void {
			var selectedChat:ChatVO;
			if (chat != null) {
				selectedChat = chat;
			} else {
				selectedChat = currentChat;
				setCurrentChat(null);
			}
			if (selectedChat == null)
				return;
			WSClient.call_chatUserExit(selectedChat.uid);
			_inChat = false;
			if (selectedChat.type == ChatRoomType.CHANNEL)
				ChannelsManager.onChannelClosed(selectedChat.uid);
			selectedChat.disposeMessages();
			selectedChat.setQuestion(null);
			//selectedChat.messagesHash = "";
			selectedChat = null;
		}
		
		static public function setCurrentChat(value:ChatVO):void {
			GeolocationManager.S_LOCATION.remove(onLocationFromContinueAnswerByGeo);
			if (currentChat == value)
				return;
			currentChatHash10 = null;
			currentChatHash50 = null;
			if (currentChat && currentChat != value && currentChat.settings && currentChat.settings.background) {
				ImageManager.unloadImage(currentChat.settings.backgroundURL);
				ImageManager.unloadImage(currentChat.settings.backgroundThumbURL);
			}
			currentChat = value;
			_chatUsersCollection.setChat(currentChat);
			
			
			if(ChatManager.getCurrentChat() != null
				&& ChatManager.getCurrentChat().type == ChatRoomType.COMPANY
				&& ChatManager.getCurrentChat().pid == Config.EP_VI_DEF){
					PHP.call_statVI("videoChatOpened", Config.EP_VI_DEF + "");
			}
			
		}
		
		static public function getCurrentChat():ChatVO {
			return currentChat;
		}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  CURRENT CHAT  ||  WORK WITH CHAT USERS  -->  ////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Add user(s) to chat
		 * @param	chatUID	String chat uid
		 * @param	users
		 * @param	requestId
		 */
		static public function addUsersToChat(chatUID:String, users:Array, requestId:String = null):void{
			if (chatUID == null || chatUID.length == 0)
				return;
			if (users == null || users.length == 0)
				return;
			PHP.addUsersToChat(chatUID, users, onUserAddedToChat, requestId);
		}
		
		static private function onUserAddedToChat(phpRespond:PHPRespond):void {
			var requestID:String;
			var users:Array;
			if (phpRespond.additionalData != null) {
				if ("requestID" in phpRespond.additionalData == true)
					requestID = phpRespond.additionalData.requestID;
				if ("users" in phpRespond.additionalData == true)
					users = phpRespond.additionalData.users;
			}
			
			if (phpRespond.error == true) {
				DialogManager.alert(Lang.textWarning, Lang.cantAddUsersToChat + '\n' + phpRespond.errorMsg);
				S_USER_ADDED_TO_CHAT.invoke( { success:false, requestId:requestID } );
				phpRespond.dispose();
				return;
			}
			var cVO:ChatVO;
			if ("chatUID" in phpRespond.data == true) {
				if ("users" in phpRespond.data)
					cVO = updateUsersInChat(phpRespond.data.chatUID, phpRespond.data.users);
				S_USER_ADDED_TO_CHAT.invoke( { success:true, requestId:requestID } );
				WSClient.call_chatUserAdd(cVO.uid, users);
			} else {
				cVO = prepareLoadedChat(phpRespond);
				S_USER_ADDED_TO_CHAT.invoke( { success:true, requestId:requestID, newChat:true, chatUID:cVO.uid } );
			}
			phpRespond.dispose();
			
			if (cVO == null)
				return;
			
			sentUserActionNotification(cVO.uid, users, true);
		}
		
		static private function updateUsersInChat(chatUID:String, users:Array):ChatVO {
			var chatVO:ChatVO = getChatByUID(chatUID);
			if (chatVO == null)
				return null;
			var exist:Boolean;
			var existingUsersNum:int = chatVO.users.length;
			var newUsersLength:int = users.length;
			for (var i:int = 0; i < newUsersLength; i++){
				exist = false;
				for (var j:int = 0; j < existingUsersNum; j++) {
					if (users[i].uid == chatVO.users[j].uid) {
						exist = true;
						break;
					}
				}
				if (exist == false) {
					chatVO.users.push(new ChatUserVO(users[i]));
					chatVO.updateTitle();
				}
			}
			S_CHAT_UPDATED.invoke(chatVO);
			return chatVO;
		}
		
		static public function removeUser(chatUID:String, userUID:String = null):void {
			if (chatUID == null || chatUID.length == 0)
				return;
			var cVO:ChatVO = getChatByUID(chatUID);
			if (cVO == null)
				return;
			if (userUID == null || userUID.length == 0)
				userUID = Auth.uid;
			if (userUID != Auth.uid) {
				if (cVO.ownerUID != Auth.uid) {
					DialogManager.alert(Lang.textWarning, Lang.cantRemoveUsersFromGroupChat);
					return;
				}
			} else {
				if (cVO.type == ChatRoomType.QUESTION && cVO.ownerUID != userUID) {
					var qVO:QuestionVO = cVO.getQuestion();
					if (qVO != null) {
						var incognito:Boolean = (qVO.userUID == Auth.uid && qVO.incognito == true);
						QuestionsManager.complain(cVO.questionID, cVO.uid, cVO.chatSecurityKey, QuestionsManager.COMPLAIN_STOP, "chat", incognito, isNaN(qVO.tipsAmount) == false);
					}
				}
			}
			if (cVO.isLocal() == true)
				removeLocalChat(cVO);
			else
				PHP.call_chatRemove(chatUID, userUID, onUserRemovedFromChat, { chatUID:chatUID, userUID:userUID } );
		}
		
		static private function onUserRemovedFromChat(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				S_USER_REMOVED_FROM_CHAT.invoke( { success:false, chatUID:phpRespond.additionalData.chatUID, userUID:phpRespond.additionalData.userUID } );
				echo("ChatManager", "onUserRemoved", phpRespond.errorMsg);
				DialogManager.alert(Lang.textWarning, Lang.alertErrorRemoveUserFromChat);
				phpRespond.dispose();
				return;
			}
			
			ToastMessage.display(Lang.userRemoved);
			
			if (phpRespond.additionalData.userUID == Auth.uid) {
				removeChatFromCurrents(phpRespond.additionalData.chatUID);
			} else {
				var chatVO:ChatVO = getChatByUID(phpRespond.additionalData.chatUID);
				if (chatVO != null && chatVO.users != null) {
					var l:int = chatVO.users.length;
					for (var i:int = 0; i < l; i++) {
						if (chatVO.users[i].uid == phpRespond.additionalData.userUID) {
							chatVO.users.splice(i, 1);
							chatVO.updateTitle();
							S_CHAT_UPDATED.invoke(chatVO);
							break;
						}
					}
					sentUserActionNotification(chatVO.uid, [ phpRespond.additionalData.userUID ], false);
				}
			}
			
			WSClient.call_chatUserRemove(phpRespond.additionalData.chatUID, phpRespond.additionalData.userUID);
			S_USER_REMOVED_FROM_CHAT.invoke( { success:true, chatUID:phpRespond.additionalData.chatUID, userUID:phpRespond.additionalData.userUID } );
			phpRespond.dispose();
		}
		
		static private function sentUserActionNotification(chatUID:String, userUIDs:Array, action:Boolean):void {
			if (chatUID == null || chatUID.length == 0)
				return;
			if (userUIDs == null || userUIDs.length == 0)
				return;
			var message:Object = new Object();
			message.additionalData = JSON.stringify(userUIDs);
			
			var userNames:String = "";
			var l:int = userUIDs.length;
			for (var i:int = 0; i < l; i++) {
				var upVO:UserVO = UsersManager.getFullUserData(userUIDs[i], false);
				if (upVO == null)
					continue;
				if (userNames.length > 0)
					userNames += ", ";
				userNames += upVO.getDisplayName();
			}
			
			var messageText:String = TextUtils.checkForNumber(Auth.username) + " ";
			if (action == true) {
				message.method = ChatSystemMsgVO.METHOD_USER_ADD;
				if (userNames.length != 0) {
					messageText += Lang.textAdded + " " + userNames + " " + Lang.toThisChat;
				} else {
					messageText += Lang.addedUserToChat;
				}
			} else {
				message.method = ChatSystemMsgVO.METHOD_USER_REMOVE;
				if (userNames.length != 0) {
					messageText += Lang.textRemoved + " " + userNames + " " + Lang.fromThisChat;
				} else {
					messageText += Lang.removedUsed;
				}
			}
			
			message.title = messageText;
			message.type = ChatSystemMsgVO.TYPE_CHAT_SYSTEM;
			
			sendMessage(Config.BOUNDS + JSON.stringify(message), chatUID);
		}
		
		static private function onChatUsersAdded(data:Object):void {
			if (data == null)
				return;
			if ("my" in data && data.my == true)
				return;
			if ("chatUID" in data && data.chatUID != null) {
				var chatVO:ChatVO = getChatByUID(data.chatUID);
				if (chatVO == null)
					return;
				if ("username" in data == false || data.username == null && data.username is Array == false)
					return;
				if ("userUid" in data == false || data.userUid == null || data.userUid is Array == false)
					return;
				var user:ChatUserVO;
				var l:int = Math.min((data.username as Array).length, (data.userUid as Array).length);
				for (var i:int = 0; i < l; i++) {
					user = new ChatUserVO( {
						username:(data.username as Array)[i],
						name:(data.username as Array)[i],
						uid:(data.userUid as Array)[i]
					} );
					chatVO.addUser(user);
				}
				S_CHAT_USERS_CHANGED.invoke(chatVO.uid);
			}
		}
		
		static private function onChatUserRemoved(data:Object):void{
			if (data == null)
				return;
			if (!("chatUID" in data))
				return;
			if (!("userUid" in data))
				return;
			if (data.userUid == Auth.uid) {
				removeChatFromCurrents(data.chatUID);
				return;
			}
			var cvo:ChatVO = getChatByUID(data.chatUID);
			if (cvo != null) {
				cvo.removeUser(data.userUid);
				S_CHAT_UPDATED.invoke(cvo);
				S_CHAT_USERS_CHANGED.invoke(cvo.uid);
			}
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  WORK WITH CHAT USERS ||  SEND MESSAGE ERRRORS  -->  /////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static private function onMessageSentBlockedNoSlotsError(messageData:MessageData):void {
			var chatVO:ChatVO = getChatByUID(messageData.chatUID);
			if (chatVO == null)
				return;
			var messageDeleted:Boolean = chatVO.deleteMessage( -messageData.mid);
			if (currentChat != null && currentChat.uid == chatVO.uid && messageDeleted == true)
				S_MESSAGES.invoke();
		}
		
		static private function onMessageSentRemoveError(messageData:MessageData):void {
			var chatVO:ChatVO = getChatByUID(messageData.chatUID);
			if (chatVO == null)
				return;
			var messageDeleted:Boolean = chatVO.deleteMessage( -messageData.mid);
			if (currentChat != null && currentChat.uid == chatVO.uid && messageDeleted == true) {
				S_MESSAGES.invoke();
				S_LATEST.invoke();
			}
		}
		
		static private function onMessageSentBlockedError(messageData:MessageData):void {
			/*var chatVO:ChatVO = getChatByUID(messageData.chatUID);
			if (chatVO == null)
				return;
			var messageDeleted:Boolean = chatVO.deleteMessage( -messageData.mid);
			if (currentChat != null && currentChat.uid == chatVO.uid && messageDeleted == true) {
				S_MESSAGES.invoke();
				S_LATEST.invoke();
			}*/
		}
		
		static private function onMessageSentDuplicateError(messageData:MessageData):void {
			/*var chatVO:ChatVO = getChatByUID(messageData.chatUID);
			if (chatVO == null)
				return;
			//TODO: нет полной информации про сообщения - статуса, даты!;
			var chatMessageVO:ChatMessageVO = chatVO.getMessageById(-messageData.mid);
			if (chatMessageVO == null)
				return;
			chatMessageVO.setId(messageData.id);
			chatMessageVO.setStatus(ChatMessageStatus.SENT);
			if (currentChat != null && currentChat.uid == chatVO.uid)
				S_MESSAGE_UPDATED.invoke();*/
		}
		
		/**
		 * If baraban canceled, timestamp should be -1
		 * @param	barabanTimestamp
		 * @param	chatUID if null, will send to default chat (Config.EP_VI_DEF)
		 */
		static public function sendBarabanRequest(barabanTimestamp:Number,chatUID:String=null):void{
			
			if (chatUID == null){
				ChatManager.getCompanyChatByPID(function(cvo:ChatVO):void{
					if (cvo == null || cvo.uid==null)
						return;
					sendBarabanRequest(barabanTimestamp, cvo.uid);
				},Config.EP_VI_DEF);
				return;
			}
			
			try{
				var msg:String = JSON.stringify( { title:Lang.barabanRequest, additionalData:{phone:Auth.phone,lang:LangManager.model.getCurrentLanguageID(),device:Config.PLATFORM+" "+Capabilities.os,timestamp:barabanTimestamp,version:Config.VERSION}, type:"calendar", method:"VI" } );
				msg = Config.BOUNDS + msg;
				sendMessage(msg, chatUID, null, false, -1, null, true);
			}catch(e:Error){}
		}
		
		/**
		 * Send success fast track to chat
		 * @param	chatUID if null, will send to default chat (Config.EP_VI_DEF)
		 */
		static public function sendFastTrackRequest(chatUID:String=null):void{
			
			if (chatUID == null){
				ChatManager.getCompanyChatByPID(function(cvo:ChatVO):void{
					if (cvo == null || cvo.uid==null)
						return;
					sendFastTrackRequest(cvo.uid);
				},Config.EP_VI_DEF);
				return;
			}
			
			try{
				var msg:String = JSON.stringify( { title:Lang.fastTrack, additionalData:{phone:Auth.phone,lang:LangManager.model.getCurrentLanguageID(),device:Config.PLATFORM+" "+Capabilities.os,fasttrack:1,version:Config.VERSION}, type:"fasttrack", method:"VI" } );
				msg = Config.BOUNDS + msg;
				sendMessage(msg, chatUID, null, false, -1, null, true);
			}catch(e:Error){}
		}
		
		static private function sendCredentials():void{
			if (currentChat == null)
				return;
			
			var network:String = "unknown";
			var nt:int = NetworkManager.getNetworkType();
			if(nt>-1){
				if (nt == 0)
					network = "none";
				else if (nt == 2)
					network = "mobile";
				else if (nt == 1)
					network = "wi-fi";
			}
			
			var camPer:String = "unknown";
			var micPer:String = camPer;
			try{
				camPer=Camera.permissionStatus
				micPer=Microphone.permissionStatus
			}catch(e:Error){}
			
			var msg:String = JSON.stringify( { title:Lang.waitingForVideoID, additionalData:{phone:Auth.phone,lang:LangManager.model.getCurrentLanguageID(),device:Config.PLATFORM+" "+Capabilities.os,network:network,camera:camPer,microphone:micPer,version:Config.VERSION}, type:"credentials", method:"VI" } );
			msg = Config.BOUNDS + msg;
			sendMessage(msg, currentChat.uid,null,false,-1,null,true);
		}
		
		static private function sendMessageLecDoItLater():void{
			if (currentChat == null)
				return;
			
			var msg:String = JSON.stringify( { title:Lang.letsDoVerificationLater, additionalData:{phone:Auth.phone,lang:LangManager.model.getCurrentLanguageID(),device:Config.PLATFORM+" "+Capabilities.os,version:Config.VERSION}, type:"credentials", method:"VI_LATER" } );
			msg = Config.BOUNDS + msg;
			sendMessage(msg, currentChat.uid,null,false,-1,null,true);
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  SEND MESSAGE ERRRORS  ||  LOAD MESSAGES & HISTORY  -->  /////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static private function loadChatMessages(onlyFromPHP:Boolean = false):void {
			
			echo("ChatManager", "loadChatMessages", 'start, only from php: '+onlyFromPHP);
			if (currentChat == null || currentChat.uid == null)
				return;

			if (currentChat.pin == null) {
				getChatPin();
				return;
			}

			_notApproved = checkForNewContact();
			
			S_CHAT_OPENED.invoke();

			if (_notApproved == true) {
				S_MESSAGES.invoke();
				return;
			}

			chatEnter(currentChat.uid);
			if (currentChat.type == ChatRoomType.COMPANY) {
				if (currentChat.pid == Config.EP_VI_DEF || currentChat.pid == Config.EP_VI_EUR || currentChat.pid == Config.EP_VI_PAY) {
					//WSClient.call_entryPointStart(currentChat.pid, currentChat.uid, "");
				}
			}
			
			if (onlyFromPHP == true) {
				echo("ChatManager", "loadChatMessages", 'Loading from php');
				loadMessagesFromPHP(false);
			}else {
				echo("ChatManager", "loadChatMessages", 'Loading from sql');
			//	trace("dukascopy.test", "loadChatMessages.onlyFromPHP currentChat=", currentChat.uid);
				SQLite.call_getMessages(onMessagesLoadedFromSQLite, currentChat.uid);
			}
		}
		
		static private function onMessagesLoadedFromSQLite(sqlRespond:SQLRespond):void {
			if (currentChat == null || currentChat.uid == null)
			{
				return;
			}
			if (sqlRespond != null && sqlRespond.error == false) {
				currentChat.setMessages(sqlRespond.data);
				S_MESSAGES.invoke();
			}
			loadMessagesFromPHP(false);
		}
		
		static private function onMessagesLoadedFromSQLite1(sqlRespond:SQLRespond):void {
			if (currentChat == null || currentChat.uid == null)
				return;
			if (sqlRespond.error != true) {
				currentChat.setMessages(sqlRespond.data);
				S_MESSAGES.invoke();
			}
			loadMessagesFromPHP(false);
		}
		
		static private function loadMessagesFromPHP(firstTime:Boolean = true):void {
			if (currentChat == null || currentChat.isDisposed == true)
				return;
			S_MESSAGES_LOADING_FROM_PHP.invoke();
			PHP.chat_getMessages(onMessagesLoaded, currentChat.uid, (firstTime == true) ? currentChatHash10 : currentChatHash50, 0, currentChat.type, firstTime);
		}
		
		/**
		 * Messages loaded from server
		 * @param	r - PHPRespond
		 */
		static private function onMessagesLoaded(r:PHPRespond):void {
			echo("ChatManager", "onMessagesLoaded", "START");
			S_REMOTE_MESSAGES_STOP_LOADING.invoke();
			if (currentChat == null || currentChat.uid == null) {
				r.dispose();
				echo("ChatManager", "onMessagesLoaded", "CURRENT CHAT IS NULL");
				return;
			}
			if (r.error == true) {
				if (r.errorMsg.toLowerCase().indexOf('chat.22') != -1) {
					var parser:ShopProductDataParser = new ShopProductDataParser();
					var product:ShopProduct = parser.parse(r.data.data, new ProductType(ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION));
					if (product != null) {
						Shop.buyChannelAccess(currentChat.uid, product);
					}
					r.dispose();
					return;
				}
				if (r.errorMsg.toLowerCase().indexOf('irc..04') != -1) {
					echo("ChatManager", "onMessagesLoaded", "PHP ERROR (BANNED)");
					if ("data" in r.data == true
						&& r.data.data != null
						&& "banInfo" in r.data.data
						&& r.data.data.banInfo != null) {
							var banData:UserBanData = new UserBanData();
							banData.banEndTime = r.data.data.banInfo.canceled;
							banData.banCreatedTime = r.data.data.banInfo.created;
							banData.moderator = r.data.data.banInfo.moderator;
							banData.reason = r.data.data.banInfo.reason;
							S_BANNED_IN_CHAT.invoke(currentChat.uid, banData);
							Auth.addBan(currentChat.uid, banData);
					}
					r.dispose();
					return;
				}
				r.dispose();
				echo("ChatManager", "onMessagesLoaded", "PHP ERROR (" + r.errorMsg + ")");
				return;
			}
			if (r.data == null) {
				r.dispose();
				echo("ChatManager", "onMessagesLoaded", "PHP DATA IS NULL");
				return;
			}
			if ('hash' in r.data == false) {
				r.dispose();
				echo("ChatManager", "onMessagesLoaded", "NO HASH IN PHP DATA");
				return;
			}
			if ("messages" in r.data && r.data.messages == null) {
				r.dispose();
				echo("ChatManager", "onMessagesLoaded", "NO MESSAGES IN PHP DATA");
				return;
			}
			echo("ChatManager", "onMessagesLoaded", "NEW MESSAGES EXISTS");
			if ("que" in r.data.messages)
				currentChat.addQuestionData(r.data.messages.que);
			if ("stat" in r.data.messages)
				currentChat.addStat(r.data.messages.stat);
			echo("ChatManager", "onMessagesLoaded", "CHECK FOR HASH");
			if (r.additionalData.firstTime == true && r.data.hash == currentChatHash10) {
				r.dispose();
				echo("ChatManager", "onMessagesLoaded", "SAME HASH");
				return;
			} else if (r.additionalData.firstTime == false && r.data.hash == currentChatHash50) {
				r.dispose();
				echo("ChatManager", "onMessagesLoaded", "SAME HASH");
				return;
			}
			
			if (Auth.key != "web")
			{
				echo("ChatManager", "onMessagesLoaded", "TRY TO ADD MESSAGES TO SQL");
				SQLite.call_makeMessages((r.additionalData.firstTime == true) ? onMessagesSavedToSQLite1 : onMessagesSavedToSQLite, r.data.messages.messages);
			}
			else
			{
				currentChat.setMessages(r.data.messages.messages);
				S_MESSAGES.invoke();
			}
			
			if (r.additionalData.firstTime == true)
				currentChatHash10 = r.data.hash;
			else
				currentChatHash50 = r.data.hash;
			if (Auth.key != "web")
			{
				updateLatestsInStore();
			}
			
			r.dispose();
			
			if (currentChat != null &&
				currentChat.type == ChatRoomType.QUESTION &&
				currentChat.getQuestion() != null &&
				currentChat.getQuestion().geo == true &&
				currentChat.hasQuestionAnswer == false &&
				currentChat.ownerUID == Auth.uid)
					DialogManager.alert(Lang.information, Lang.needGeoForAnswer, continueAnswerByGeo, "OK", "CANCEL");
			echo("ChatManager", "onMessagesLoaded", "END");
		}
		
		static private function continueAnswerByGeo(val:int):void {
			if (val != 1)
				return;
			GeolocationManager.S_LOCATION.remove(onLocationFromContinueAnswerByGeo);
			if (GeolocationManager.getMyLocation() == null) {
				GeolocationManager.S_LOCATION.add(onLocationFromContinueAnswerByGeo);
				GeolocationManager.getLocation();
				return;
			}
			var tmp:Object = {
				title:"My position: ",
				additionalData: GeolocationManager.getMyLocation().latitude + "," + GeolocationManager.getMyLocation().longitude,
				type:ChatSystemMsgVO.TYPE_911,
				method:ChatSystemMsgVO.METHOD_911_GEO
			}
			sendMessage(Config.BOUNDS + JSON.stringify(tmp));
			tmp = null;
		}
		
		static private function onLocationFromContinueAnswerByGeo(location:Location):void {
			continueAnswerByGeo(1);
		}
		
		static private function onMessagesSavedToSQLite(sqlRespond:SQLRespond):void {
			if (sqlRespond != null && sqlRespond.error == true)
				return;
			if (currentChat != null)
				SQLite.call_getMessages(onLatestMessagesLoadedFromSQLite, currentChat.uid);
		}
		
		static private function onMessagesSavedToSQLite1(sqlRespond:SQLRespond):void {
			if (sqlRespond != null && sqlRespond.error == true)
				return;
			if (currentChat != null)
				SQLite.call_getMessages(onMessagesLoadedFromSQLite1, currentChat.uid);
		}
		
		static private function onLatestMessagesLoadedFromSQLite(sqlRespond:SQLRespond):void {
			if (sqlRespond != null && sqlRespond.error == true)
				return;
			if (currentChat == null)
				return;
			var result:Boolean = currentChat.setMessages(sqlRespond.data);
			S_MESSAGES.invoke();
		}
		
		static public function loadChatHistorycalMessages(firstTime:Boolean = true):void {
			echo("ChatManager","loadChatHistorycalMessages",'ChatManager -> Load historical messages ');
			if (currentChat == null || currentChat.uid == null)
				return;
			if (currentChat.messages && currentChat.messages.length > 0 && currentChat.messages[0].num == 1)
				return;
			if (firstTime == true)
				hmLoadedFromPHPAndSavedToSQL = false;
			if (Auth.key != "web")
			{
				SQLite.call_getMessages(onHistoricalMessagesLoadedFromSQLite, currentChat.uid, currentChat.lattestMsgID);
			}
			else
			{
				var chatType:String;
				if (currentChat != null)
					chatType = currentChat.type;
			//	S_MESSAGES_LOADING_FROM_PHP.invoke();
				PHP.chat_getMessages(onHistoricalMessagesLoaded, currentChat.uid, "", currentChat.lattestMsgID, chatType);
			}
		}
		
		static private function onHistoricalMessagesLoadedFromSQLite(sqlRespond:SQLRespond):void {
			if (currentChat == null || currentChat.uid == null)
				return;
			if (sqlRespond.error == true)
				return;
			var trueCount:Boolean = (currentChat.messages[0].num < 101 && sqlRespond.data.length == currentChat.messages[0].num - 1);
			trueCount = (trueCount || (sqlRespond.data.length > 0 && sqlRespond.data[sqlRespond.data.length - 1].num == currentChat.messages[0].num - 100));

			if (trueCount || hmLoadedFromPHPAndSavedToSQL) {
				currentChat.addMessages(sqlRespond.data);
				S_HISTORICAL_MESSAGES.invoke();
				return;
			}
			var chatType:String;
			if (currentChat != null)
				chatType = currentChat.type;
			PHP.chat_getMessages(onHistoricalMessagesLoaded, currentChat.uid, "", currentChat.lattestMsgID, chatType);
		}
		
		static private function onHistoricalMessagesLoaded(r:PHPRespond):void {
			S_REMOTE_MESSAGES_STOP_LOADING.invoke();
			if (currentChat == null || currentChat.uid == null) {
				echo("ChatManager", "onHistoricalMessagesLoaded", 'Messages loaded but no chat');
				//TODO: Добавить сообщения в базу если они есть, но после добавления больше ничего не делать!
				S_HISTORICAL_MESSAGES.invoke();
				r.dispose();
				return;
			}
			if (r.error) {
				// TODO - do something
				echo("ChatManager", "onHistoricalMessagesLoaded", 'Messages not loaded from php ' + r.errorMsg);
				S_HISTORICAL_MESSAGES.invoke();
				r.dispose();
				return;
			}
			if (r.data == null) {
				echo("ChatManager", "onHistoricalMessagesLoaded", 'No new messages on server');
				S_HISTORICAL_MESSAGES.invoke();
				r.dispose();
				return;
			}
			if("messages" in r.data && r.data.messages == null) {
				r.dispose();
				S_HISTORICAL_MESSAGES.invoke();
				return;
			}
			try {
				if (Auth.key != "web")
				{
					SQLite.call_makeMessages(onHistoricalMessagesSavedToSQLite, r.data.messages);
				}
				else
				{
					currentChat.addMessages(r.data.messages);
					S_HISTORICAL_MESSAGES.invoke();
					hmLoadedFromPHPAndSavedToSQL = true;
				}
				
			} catch (e:Error) {
				S_HISTORICAL_MESSAGES.invoke();
			}
			r.dispose();
		}
		
		static private function onHistoricalMessagesSavedToSQLite(sqlRespond:SQLRespond):void {
			hmLoadedFromPHPAndSavedToSQL = true;
			loadChatHistorycalMessages(false);
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <--  LOAD MESSAGES & HISTORY || LATEST  -->  /////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		static private var chatsLoadingFromStore:Boolean = false;
		static private var chatsLoadingFromPHP:Boolean = false;
		static private var chatsLoadedFromStore:Boolean = false;
		static private var chatsLoadedFromPHP:Boolean = false;
		static private var chatsHash10:String;
		static private var chatsHash50:String;
		
		static public function isLoadingFromStore():Boolean
		{
			return chatsLoadingFromStore;
		}
		
		static public function getChats():void {
			getChatsFromStore();
		}
		
		static private function getChatsFromStore():void {
			if (chatsLoadingFromStore == true)
				return;
			if (chatsLoadedFromStore == true) {
				if (getChatsFromPHP() == false)
					S_LATEST.invoke();
				return;
			}
			chatsLoadingFromStore = true;
			Store.load(Store.VAR_CHATS, onChatsLoadedFromStore);
		}
		
		static private function onChatsLoadedFromStore(data:Object, err:Boolean):void {
			chatsLoadingFromStore = false;
			chatsLoadedFromStore = true;
		//	trace("processUnreadedMessages 2", data);
			
			if (err == false && data != null)
			{
				createUpdateChats(data);
			}
			getChatsFromPHP();
		}
		
		static private function getChatsFromPHP(firstTime:Boolean = true):Boolean {
			
			if (chatsLoadingFromPHP == true)
				return false;
			if (firstTime == true && chatsLoadedFromPHP == true) {
				S_LATEST.invoke();
				return true;
			}
			chatsLoadingFromPHP = true;
			S_SERVER_DATA_LOAD_START.invoke();
		//	PHP.chat_getLatest(onChatsLoadedFromPHP, (firstTime == true) ? chatsHash10 : chatsHash50, "public", firstTime);
			PHP.chat_getLatest(onChatsLoadedFromPHP, (firstTime == true) ? chatsHash10 : chatsHash50, "que,public", firstTime)
			return false;
		}
		
		static public function reloadLatests():void{
			getChatsFromPHP();
		}
		
		static private function onChatsLoadedFromPHP(phpRespond:PHPRespond):void {
			latestChatsLoaded = true;
			S_SERVER_DATA_LOAD_END.invoke();
			chatsLoadingFromPHP = false;
			if (phpRespond.error) {
				phpRespond.dispose();
				return;
			}
			chatsLoadedFromPHP = true;
			if (phpRespond.additionalData.firstTime == true)
				getChatsFromPHP(false);
			if (phpRespond.data == null) {
				phpRespond.dispose();
				return;
			}
			createUpdateChats(phpRespond.data, true, phpRespond.additionalData.firstTime);
			if (phpRespond.additionalData.firstTime == true) {
				chatsHash10 = phpRespond.data.hash;
			} else {
				chatsHash50 = phpRespond.data.hash;
				Store.save(Store.VAR_CHATS, phpRespond.data);
			}
			phpRespond.dispose();
		}
		
		static private function createUpdateChats(data:Object, fromPHP:Boolean = false, firstTime:Boolean = false):void {
			latestChats ||= [];
			var dataLatest:Array = data.latest;
			if (dataLatest == null || dataLatest.length == 0) {
				S_LATEST.invoke();
				return;
			}
			if (fromPHP == true)
				dataLatest = dataLatest.slice();
			var i:int;
			var j:int;
			var cVO:ChatVO;
			var latestChatsLength:int = latestChats.length;
			var dataChatsLength:int = dataLatest.length;
		//	var messagesInRecrypting:Boolean = false;
			for (i = latestChatsLength; i > 0; i--) {
				cVO = latestChats[i - 1];
				dataChatsLength = dataLatest.length;
				for (j = 0; j < dataChatsLength; j++) {
				//	messagesInRecrypting = false;
					if (cVO.uid != dataLatest[j].uid)
						continue;
					var needUpdateMessages:Boolean = false;
					if (fromPHP && cVO.incomeLocal || cVO.isIncomingLocalChat())
					{
						needUpdateMessages = true;
						/*if (NetworkManager.isConnected == true)
						{
							messagesInRecrypting = true;
							recryptOutcomeMessages(cVO.securityKey, dataLatest[j].securityKey, (currentChat != null && currentChat.uid == (dataLatest[j] as ChatVO).uid));
						}*/
					}	
					
					cVO.setData(dataLatest[j]);
					
					if (needUpdateMessages == true)
					{
						cVO.incomeLocal = false;
						cVO.setMessages(null);
						if (currentChat != null && currentChat.uid == dataLatest[j].uid)
						{
							loadChatMessages();
						}
					}
					
					if (cVO.type == ChatRoomType.COMPANY)
						cVO.updateSecurityKey(LatestsManager.dukascopySecurityKey);
					dataLatest.splice(j, 1);
					break;
				}
				if (firstTime == true)
					continue;
				if (j == dataChatsLength) {
					if (cVO == currentChat)
						continue;
					cVO.dispose();
					latestChats.splice(i - 1, 1);
					continue;
				}
			}
			if (dataLatest.length != 0) {
				dataChatsLength = dataLatest.length;
				for (i = 0; i < dataChatsLength; i++) {
					cVO = new ChatVO(dataLatest[i]);
					if (cVO.type == ChatRoomType.COMPANY)
						cVO.updateSecurityKey(LatestsManager.dukascopySecurityKey);
					latestChats.push(cVO);
				}
			}
			dataLatest = null;
			
			
			//----------------
			NewMessageNotifier.setInitialData(NewMessageNotifier.type_LATEST, latestChats, fromPHP, firstTime);
			//----------------
			
			S_LATEST.invoke();
			echo("ChatManager", "createUpdateChats", "END");
		}
		
		static public function addChatToLatest(cvo:ChatVO, needInvoke:Boolean = true):void {
			if (cvo == null)
				return;
			if (cvo.type == ChatRoomType.CHANNEL) {
				ChannelsManager.addNewChannel(cvo);
			} else if (cvo.type == ChatRoomType.QUESTION) {
				AnswersManager.addNewAnswer(cvo);
			} else {
				var c:ChatVO = getChatByUID(cvo.uid);
				if (c == null) {
					// CHAT NOT FOUNDED IN MEMORY, ADD
					if (latestChats == null)
						latestChats = [];
					latestChats.unshift(cvo);
					S_LATEST_OVERRIDE.invoke();
				}
				if (needInvoke == true && cvo.unreaded > 0)
					InnerNotificationManager.S_NOTIFICATION_NEED.invoke();
			}
		}
		
		static public function updateLatestsInStore():void {
			echo("ChatManager", "updateLatestsInStore", "START!");
		//	trace("processUnreadedMessages 0", isLoadedFromStore(), latestChats);
			

			echo("ChatManager", "updateLatestsInStore", "1");

			if (isLoadedFromStore() == false){
				echo("ChatManager", "updateLatestsInStore", "isLoadedFromStore == false");
				return;
			}

			echo("ChatManager", "updateLatestsInStore", "2");

			if (latestChats == null){
				echo("ChatManager", "updateLatestsInStore", "latestChats is null");
				return;
			}

			echo("ChatManager", "updateLatestsInStore", "3");

			var latestsChatsRawDataArray:Array = [];
			var l:int = latestChats.length;

			echo("ChatManager", "updateLatestsInStore", "4");

			for (var i:int = 0; i < l; i++){
				if(latestChats[i]==null){
					echo("ChatManager","updateLatestsInStore","latest chat item null");
					continue;
				}
				var rawData:Object=null;
				try{
					rawData=(latestChats[i] as ChatVO).getRawData();
				}catch(e:Error){
					echo("ChatManager","updateLatestsInStore","can't gete raw data");
					continue;
				}
				latestsChatsRawDataArray.push(rawData);
			}

			echo("ChatManager", "updateLatestsInStore", "6");

			var hash:String = null;
			try{
				hash=MD5.hash(JSON.stringify(latestsChatsRawDataArray));
				echo("ChatManager", "updateLatestsInStore", "7");
			}catch(e:Error){
				echo("ChatManager", "updateLatestsInStore", "Can't create hash, stringiy error");	
				return;
			}

			echo("ChatManager", "updateLatestsInStore", "Start saving latest");
			Store.save(Store.VAR_CHATS, { hash:hash, latest:latestsChatsRawDataArray, ver:currentDataVersion } );
			echo("ChatManager", "updateLatestsInStore", "END");
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <-- PHP AND STORE LATEST ||  GET LATEST  /////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function get allChats():Array {
			if (latestChats == null)
				return null;
			latestChats.sort(sortByDate);
			return latestChats;
		}
		
		static public function getLatestChatsAndDatesFilter(param:String = ChatRoomType.PRIVATE):Array {
			if (latestChats == null)
				return null;
			latestChats.sort(sortByDate);
			var res:Array = [];
			var l:int = latestChats.length;
			if (param != null && param.indexOf(ChatRoomType.PRIVATE) != -1) {
				var localChats:Array = localChatSyncronizer.getLocalChats();
				if (localChats != null && localChats.length > 0)
					res = localChats.slice();
			}
			var i:int = 0;
			for (i; i < l; i++) {
				if (param == ChatRoomType.ALL)
					res.push(latestChats[i]);
				else {
					if (param.indexOf(latestChats[i].type) != -1) {
						if (latestChats[i].pid != null && latestChats[i].pid > 0)
							continue;
						res.push(latestChats[i]);
					}
				}
			}
			if (param != null) {
				if (param.indexOf(ChatRoomType.COMPANY) != -1 || param == ChatRoomType.ALL) {
					res.sort(sortByDate);
					addSupportChats(res);
				} else {
					addBankChats(res);
					res.sort(sortByDate);
				}
			}
			return res;
		}
		
		static private function addBankChats(chats:Array):void {
			var wasPhase:Boolean = false;
			// SETUP BANK
			if (Auth.bank_phase != "EMPTY" && Auth.bank_phase != "UNKNOWN") {
				wasPhase = true;
				chats.push(getSupportChatVO(Config.EP_VI_DEF, Lang.chatWithBankTitle));
			}
			
			if (Auth.bank_phase != "ACC_APPROVED")
				chats.push(getSupportChatVO( -5, Lang.payWithCard));
			
			// SETUP EUROPEAN TRADING PHASE
			if (Auth.eu_phase  != "EMPTY" && Auth.eu_phase != "UNKNOWN") {
				wasPhase = true;
				chats.push(getSupportChatVO(Config.EP_VI_EUR, Lang.chatWithBankEUTitle));
			}
			
			if (wasPhase == false)
				chats.push(getSupportChatVO(Config.EP_MAIN, Lang.chatWithBankTitle));
			
			var cVO:ChatVO = getChatByPID(142);
			if (cVO != null && cVO.messageVO != null && cVO.messageVO.created > int(new Date().getTime() / 1000) - 60 * 60 * 24)
				chats.push(cVO);
		}
		
		static private function addSupportChats(chats:Array):void {
			var wasPhase:Boolean = false;
			// SETUP BANK
			if (Auth.bank_phase != "EMPTY" && Auth.bank_phase != "UNKNOWN") {
				wasPhase = true;
				chats.push(getSupportChatVO(Config.EP_VI_DEF, Lang.chatWithBankTitle));
				if (Auth.bank_phase == "ACC_APPROVED") {
					chats.push(getSupportChatVO( -1, Lang.myAccount));
					chats.push(getSupportChatVO( -3, Lang.bankBot));
					chats.push(getSupportChatVO( -4, Lang.dukascoinMarketplace));
				}
			} else {
				chats.unshift(getSupportChatVO( -2, Lang.openAccount));
			}
			if (Auth.bank_phase != "ACC_APPROVED")
				chats.push(getSupportChatVO( -5, Lang.payWithCard));
			//else
				//chats.push(getSupportChatVO(Config.EP_TRADING, "911 Trading Channel"));
			// SETUP EUROPEAN TRADING PHASE
			if (Auth.eu_phase  != "EMPTY" && Auth.eu_phase != "UNKNOWN") {
				wasPhase = true;
				chats.push(getSupportChatVO(Config.EP_VI_EUR, Lang.chatWithBankEUTitle));
			}
			// SETUP SUHOBOKOV
			if (Auth.ch_phase  != "EMPTY" && Auth.ch_phase != "UNKNOWN") {
				wasPhase = true;
				chats.push(getSupportChatVO(Config.EP_VI_PAY, Lang.chatWithPayEUTitle));
			}
			if (wasPhase == false)
				chats.push(getSupportChatVO(Config.EP_MAIN, Lang.chatWithBankTitle));
			var cVO:ChatVO = getChatByPID(142);
			if (cVO != null && cVO.messageVO != null && cVO.messageVO.created > int(new Date().getTime() / 1000) - 60 * 60 * 24)
				chats.push(cVO);
		}
		
		static private function getSupportChatVO(pid:int, title:String):ChatVO {
			if (pid != -1) {
				var chat:ChatVO = getChatByPID(pid);
				if (chat != null) {
					chat.title = title;
					return chat;
				}
			}
			var chatData:Object = new Object();
			chatData.pointID = pid;
			chatData.title = title;
			chatData.type = ChatRoomType.COMPANY;
			return new ChatVO(chatData);
		}
		
		static private function sortByDate(a:ChatVO, b:ChatVO):int {
			if (a.pid == Config.EP_MAIN)
				return -1;
			if (a.pid == Config.EP_VI_DEF)
				return -1;
			if (b.pid == Config.EP_VI_DEF)
				return 1;
			if (b.pid == Config.EP_MAIN)
				return 1;
			if (a.pid == -5)
				return -1;
			if (b.pid == -5)
				return 1;
			/*if (a.getUser(Config.DUKASCOPY_INFO_SERVICE_UID) != null)
				return -1;
			if (b.getUser(Config.DUKASCOPY_INFO_SERVICE_UID) != null)
				return 1;*/
			if (a.getTime() < b.getTime())
				return 1;
			if (a.getTime() > b.getTime())
				return -1;
			return 0;
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <-- GET LATEST  ||  ACTIONS WITH MESSAGE  -->  ///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static private var localMessagesInDeleteProcess:Array;
		static private var firstMsgsCount:Number = 10;
		static private var firstChatsCount:Number = 10;
		
		/*static public function sendTetATetMessage(txt:String, chatUID:String, userUID:String):void {
			txt = "^" + userUID + "^" + cryptTXT(txt);
			WSClient.call_sendTextMessage(chatUID, txt, -1, true, null, false, userUID);
		}*/
		
		static public function sendBotActionMessage(action:String, textToRead:String, actionData:Object = null, chatUID:String = "", userUID:String = ""):void {
			var msg:String = "";
			msg = JSON.stringify( {
				method:ChatSystemMsgVO.METHOD_BOT_COMMAND,
				type:ChatSystemMsgVO.TYPE_CHAT_SYSTEM,
				title:textToRead,
				action:action,
				actionData:actionData
			} );
			msg = Config.BOUNDS + msg;
			var textToSend:String = "^" + userUID + "^" + cryptTXT(msg);
			
			
			WSClient.call_sendTextMessage(chatUID, textToSend, -1, true, null, false, userUID,null,function(success:Boolean):void{
				if (success && currentChat != null && currentChat.type == ChatRoomType.COMPANY && currentChat.pid > 0) {
				WSClient.call_entryPointStart(currentChat.pid, currentChat.uid, textToSend);
			}
			});

			
		}
		
		static public function sendMessage(
			txt:String,
			chatUID:String = null,
			senderId:String = null,
			doNotSendToWS:Boolean = false,
			msgID:Number = -1,
			notSendCallback:Function = null,
			credentials:Boolean = false,
			callback:/*messageID:Number*/Function=null):void{
				
				if (txt == null || txt.length == 0){
					if(callback!=null)
						callback(-1)
					return;
				}
					
				var chatVO:ChatVO;
				if (chatUID == null)
					chatVO = currentChat;
				else
					chatVO = getChatByUID(chatUID);

				if (chatVO == null){
					if(callback!=null)
						callback(-1)
					return;
				}
					
				var isAnswer:Boolean = false;
				if (chatVO.type == ChatRoomType.QUESTION) {
					isAnswer = true;
				}

				if (isAnswer == true) {
					var qVO:QuestionVO = chatVO.getQuestion();
					if (chatVO.hasQuestionAnswer == false && qVO != null && qVO.answersCount >= qVO.answersMaxCount) {
						DialogManager.alert(Lang.textWarning, Lang.questionToManyAnswers);
						if(callback!=null)
							callback(-1)
						return;
					}
				}
				var isCommand:Boolean = false;
				var text:String = cryptTXT(txt, chatVO.chatSecurityKey, chatVO.pin);
				if (txt.charAt(0) == "/" && txt.indexOf(" ") == -1 && txt.length < 10) {
					msgID = 0;
					text = "/" + text;
				}
				var messageId:Object = new Object();
				
				
				WSClient.call_sendTextMessage(chatVO.uid, text, msgID, !isAnswer, senderId, doNotSendToWS, null, messageId,function(networkSendResult:Boolean):void{

					if (networkSendResult == false && isAnswer == true && doNotSendToWS == false) {
					ToastMessage.display(Lang.sendMessageFail);
					if (notSendCallback != null)
						notSendCallback();
					if(callback)
						callback(-1)
				}

				if (networkSendResult == true && chatVO.type == ChatRoomType.COMPANY && chatVO.pid > 0) {
					WSClient.call_entryPointStart(chatVO.pid, chatVO.uid, text);
				}
				
				var messageIdResult:Number = -1;
				if (messageId != null && "id" in messageId)
				{
					messageIdResult = messageId.id;
				}


				if(callback)
					callback(messageIdResult);

				});
				
				
		}
		
		static public function sendMessagePuzzle(txt:String, chatUID:String = null, senderId:String = null, doNotSendToWS:Boolean = false, msgID:Number = -1):void {
			if (txt == null)
				return;
			var chatVO:ChatVO;
			if (chatUID == null)
				chatVO = currentChat;
			else
				chatVO = getChatByUID(chatUID);
			if (chatVO == null)
				return;
			var isAnswer:Boolean = false;
			if (chatVO.type == ChatRoomType.QUESTION || chatVO.questionID != null && chatVO.questionID != "") {
				isAnswer = true;
			}
			if (isAnswer == true) {
				var qVO:QuestionVO = chatVO.getQuestion();
				if (chatVO.hasQuestionAnswer == false && qVO != null && qVO.answersCount >= qVO.answersMaxCount) {
					DialogManager.alert(Lang.textWarning, Lang.questionToManyAnswers);
					return;
				}
			}
			var text:String = Config.BOUNDS_INVOICE + cryptTXT(txt, chatVO.chatSecurityKey, chatVO.pin);
			WSClient.call_sendTextMessage(chatVO.uid, text, msgID, !isAnswer, senderId, doNotSendToWS,null,null,function(networkSendResult:Boolean):void{
				if (networkSendResult == false && isAnswer == true && doNotSendToWS == false) {
					DialogManager.alert(Lang.textAttention, Lang.alertProvideInternetConnection);
					return;
				}
			});
			
		}
		
		static public function sendMessageToOtherChat(txt:String, cuid:String, csk:String, incognito:Boolean):void {
			var text:String = Crypter.crypt(txt, csk);
			WSClient.call_sendQMessage(cuid, text, incognito);
		}
		
		static public function sendInvoiceByData(data:ChatMessageInvoiceData):void {
			if (currentChat == null || currentChat.uid == null)
				return;
			var text:String = data.toJsonString();
			WSClient.call_sendTextMessage(currentChat.uid, Config.BOUNDS_INVOICE + cryptTXT(text));
		}
		
		static public function sendVideoMessage(iu:VideoUploader, data:MediaFileData):void {
			var cvo:ChatVO = getChatByUID(iu.chatUID);
			if (cvo == null || cvo.chatSecurityKey == null)
				return;
			var msg:String = JSON.stringify( { method:ChatSystemMsgVO.METHOD_FILE_START_SEND,
				title:data.name,
				type:ChatSystemMsgVO.TYPE_FILE,
				size:data.size,
				fileType:ChatSystemMsgVO.FILETYPE_VIDEO,
				videoData:{
					thumbWidth:data.thumbWidth,
					thumbHeight:data.thumbHeight,
					loaded:data.loaded,
					rejected:data.rejected,
					error:data.error,
					title:data.name,
					duration:data.duration,
					localResource:data.localResource,
					size:data.size,
					encodeProgress:data.encodeProgress,
					percent:data.percent
				},
				additionalData:data.thumbUID
			} );
			sendMessage(Config.BOUNDS + msg, cvo.uid, data.id.toString(), true);
		}

		static public function sendVideoMessageProgress(iu:VideoUploader, data:MediaFileData):void {
			var cvo:ChatVO = getChatByUID(iu.chatUID);
			if (cvo == null || cvo.chatSecurityKey == null)
				return;
			var msg:String = JSON.stringify( { method:ChatSystemMsgVO.METHOD_FILE_SENDING,
				title:data.name,
				type:ChatSystemMsgVO.TYPE_FILE,
				size:data.size,
				fileType:ChatSystemMsgVO.FILETYPE_VIDEO,
				videoData:{
					thumbWidth:data.thumbWidth,
					thumbHeight:data.thumbHeight,
					loaded:data.loaded,
					error:data.error,
					title:data.name,
					duration:data.duration,
					rejected:data.rejected,
					localResource:data.localResource,
					size:data.size,
					encodeProgress:data.encodeProgress,
					percent:data.percent
				},
				additionalData:data.thumbUID
			} );
			var res:Boolean = updateMessage(Config.BOUNDS + msg, iu.messageID, cvo.uid, true);
		}
		
		static public function sendVideoMessageFinish(iu:VideoUploader, data:MediaFileData):void {
			var cvo:ChatVO = getChatByUID(iu.chatUID);
			if (cvo == null || cvo.chatSecurityKey == null)
				return;
			var msg:String = JSON.stringify( { method:ChatSystemMsgVO.METHOD_FILE_SENDED,
				title:data.name,
				type:ChatSystemMsgVO.TYPE_FILE,
				size:data.size,
				fileType:ChatSystemMsgVO.FILETYPE_VIDEO,
				videoData:{
					thumbWidth:data.thumbWidth,
					thumbHeight:data.thumbHeight,
					loaded:data.loaded,
					size:data.size,
					title:data.name,
					error:data.error,
					duration:data.duration,
					rejected:data.rejected,
					localResource:data.localResource,
					encodeProgress:data.encodeProgress,
					percent:data.percent
				},
				additionalData:data.thumbUID
			} );
			sendMessage(Config.BOUNDS + msg, iu.chatUID, cvo.uid, false, -iu.messageID);
		}

		static private function sendFileMessage(iu:ImageUploader, data:Object):void {
			var cVO:ChatVO = getChatByUID(iu.chatUID);
				if (cVO == null || cVO.uid == null)
					return;
			var msg:String;
			if (iu.puzzleData != null) {
				msg = JSON.stringify( {
					method:ChatSystemMsgVO.METHOD_FILE_SENDED,
					type:ChatSystemMsgVO.TYPE_FILE,
					title:data.name,
					fileType:ChatSystemMsgVO.FILETYPE_PUZZLE_CRYPTED,
					additionalData:data.uid + ',' + data.width + ',' + data.height,
					puzzleData:iu.puzzleData
				} );
				sendMessagePuzzle(Config.BOUNDS + msg, cVO.uid);
			} else {
				msg = JSON.stringify( {
					method:ChatSystemMsgVO.METHOD_FILE_SENDED,
					type:ChatSystemMsgVO.TYPE_FILE,
					title:data.name,
					fileType:ChatSystemMsgVO.FILETYPE_IMG_CRYPTED,
					additionalData:data.uid + ',' + data.width + ',' + data.height
				} );
				sendMessage(Config.BOUNDS + msg, cVO.uid);
			}
		}

		static public function cryptTXT(txt:String, customKey:String = null, customPin:String = null):String {
			echo("ChatManager", "cryptTXT", "START");
			if (customKey == null && currentChat == null) {
				echo("ChatManager", "cryptTXT", "no chat security key and no chatVO",true);
				return "";
			}
			if (customKey == null) {
				customKey = currentChat.chatSecurityKey;
				customPin = currentChat.pin;
			}
			var addDot:Boolean = false;
			if (customPin != null && customPin != "----") {
				echo("ChatManager", "cryptTXT", "AES CRYPT");
				addDot = true;
				txt = AESCrypter.enc(txt, customPin);
			}
			if (customKey == null || customKey.length < 32 && currentChat.type == ChatRoomType.COMPANY) {
				customKey = LatestsManager.dukascopySecurityKey;
			}
			txt = Crypter.crypt(txt, customKey);
			if (addDot == true)
				txt = "!" + txt;
			echo("ChatManager", "cryptTXT", "END");
			return txt;
		}

		static public function updateInvoce(txt:String, msgID:int):Boolean {
			var text:String = Config.BOUNDS_INVOICE + cryptTXT(txt);
			if (currentChat != null)
				return WSClient.call_updateTextMessage(currentChat.uid, text, msgID);
			return false;
		}

		static public function updatePuzzle(txt:String, msgID:int, chatUID:String):Boolean {
			var text:String = Config.BOUNDS_INVOICE + cryptTXT(txt);
			if (currentChat != null)
				return WSClient.call_updateTextMessage(chatUID, text, msgID);
			return false;
		}

		static public function updateMessage(txt:String, msgID:Number, chatUID:String = null, updateLocaly:Boolean = false):Boolean {
			var chatVO:ChatVO;
			if (chatUID == null)
				chatVO = currentChat;
			else
				chatVO = getChatByUID(chatUID);
			if (chatVO == null)
				return false;
			var text:String = cryptTXT(txt, chatVO.chatSecurityKey, chatVO.pin);
			return WSClient.call_updateTextMessage(chatVO.uid, text, msgID, updateLocaly);
		}
		
		static public function removeMessage(msg:ChatMessageVO):void {
			if (msg != null) {
				if (msg.systemMessageVO != null &&
					msg.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO &&
					msg.systemMessageVO.videoVO != null &&
					msg.systemMessageVO.videoVO.thumbUID != null &&
					msg.systemMessageVO.videoVO.thumbUID != "")
						PHP.call_eraseFile(msg.systemMessageVO.videoVO.thumbUID);
				var msgID:Number = msg.id;
				if (currentChat != null) {
					if (msgID < 0) {
						var request:String = (new Date()).getTime().toString();
						if (localMessagesInDeleteProcess == null)
							localMessagesInDeleteProcess = new Array();
						localMessagesInDeleteProcess.push( {
							msgID:msgID,
							chatUID:currentChat.uid,
							request:request
						} );
						SQLite.call_removeMessage(onLocalMessageRemoved, msgID, currentChat.uid, request);
					} else {
						WSClient.call_removeMessage(currentChat.uid, msgID);
					}
				}
			}
		}
		
		static private function onLocalMessageRemoved(response:SQLRespond):void {
			if (response.error == false) {
				if (response.id != "" && response.id != null && localMessagesInDeleteProcess != null) {
					var l:int = localMessagesInDeleteProcess.length;
					for (var i:int = 0; i < l; i++) {
						if (localMessagesInDeleteProcess[i].request == response.id) {
							if (currentChat != null && currentChat.uid == localMessagesInDeleteProcess[i].chatUID) {
								if (currentChat.deleteMessage(localMessagesInDeleteProcess[i].msgID) == true)
									S_MESSAGES.invoke();
								if (localMessagesInDeleteProcess[i].msgID == currentChat.messageID)
									S_LATEST_OVERRIDE.invoke();
							}
							localMessagesInDeleteProcess.splice(i, 1);
							if (localMessagesInDeleteProcess.length == 0)
								localMessagesInDeleteProcess = null;
							return;
						}
					}
				}
			}
		}
		
		static public function resendMessage(message:ChatMessageVO):void {
			if (message != null && message.rawObject != null && "text" in message.rawObject && message.rawObject.text != null) {
				WSClient.call_sendTextMessage(message.chatUID, message.rawObject.text, -message.id, false);
			}
		}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <-- SEND MESSAGES  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		static private function onChatPushStatusChanged(data:Object):void {
			if ("chatUID" in data == false)
				return;
			var cVO:ChatVO = getChatByUID(data.chatUID);
			if (cVO == null)
				return;
			if ("status" in data == true)
				cVO.setPushAllowed(Boolean(data.status));
		}
		
		static private function onWSChatTitleChanged(data:Object):void {
			var chatModel:ChatVO = getChatByUID(data.chatUID);
			if (chatModel) {
				chatModel.title = Crypter.decrypt(data.title, chatModel.securityKey);
				S_TITLE_CHANGE.invoke( { success:true } );
				S_LATEST.invoke();
			}
		}
		
		static private function onWSChatAvatarChanged(data:Object):void {
			var chatModel:ChatVO = getChatByUID(data.chatUID);
			if (chatModel) {
				chatModel.avatar = data.avatar;
				S_AVATAR_CHANGE.invoke( { success:true } );
				S_LATEST.invoke();
			}
		}
		
		static public function chatExit(uid:String):void {
			_inChat = false;
			WSClient.call_chatUserExit(uid);
		}
		
		static public function chatEnter(uid:String):void {
			_inChat = true;
			WSClient.call_chatUserEnter(uid);
		}
		
		static private function onChatUserEnter(data:Object):void {
			if (currentChat == null || currentChat.uid == null || currentChat.uid == "")
				return;
			if (data == null)
				return;
			if (data.chatUID != currentChat.uid)
				return;
			if (data.userUid == Auth.uid) {
				_inChat = true;
			}
			if (currentChat.addStat(data.stat))
				S_CHAT_STAT_CHANGED.invoke(currentChat);
		}
		
		static private function onUserWriting(data:Object):void {
			if (currentChat == null || currentChat.uid == "")
				return;
			if (data.chatUID != currentChat.uid)
				return;
			if (data.userUID == Auth.uid)
				return;
			S_USER_WRITING.invoke(data);
		}
		
		static private function onMessageReaction(data:Object):void {
			if (data != null) {
				if ("error" in data && data.error == true) {
					
				} else {
					var reaction:ChatMessageReaction = new ChatMessageReaction(data);
					if (reaction.chatUID != null) {
						var chat:ChatVO;
						var needUpdateChatView:Boolean = false;
						if (getCurrentChat() != null && getCurrentChat().uid == reaction.chatUID) {
							needUpdateChatView = true;
							chat = getCurrentChat();
						} else {
							chat = getChatByUID(reaction.chatUID);
						}
						if (chat != null) {
							var message:ChatMessageVO = chat.getMessageById(reaction.id);
							if (message != null) {
								if (data.reaction == false) {
									message.removeReaction(reaction);
								} else {
									message.addReaction(reaction);
								}
								if (needUpdateChatView == true)
									S_MESSAGE_UPDATED.invoke(message);
							}
						}
					}
				}
			}
		}
		
		static public function clearLocalChats():void {
			lastGettedChats = null;
			if (latestChats != null)
				while (latestChats.length != 0)
					latestChats.shift().dispose();
			latestChats = null;
			chatsSettings = null;
			latestChatsHash = '';
			isLocalChatsLoaded = false;
			latestWasNull = false;
			latestChatsLoaded = false;
			chatsLoadingFromStore = false;
			chatsLoadingFromPHP = false;
			chatsLoadedFromStore = false;
			chatsLoadedFromPHP = false;
			chatsHash10 = null;
			chatsHash50 = null;
		}
		
		static private function onDummyImageMessage(data:Object):void {
			if (!('chatUID' in data))
				return;
			var chatVO:ChatVO = getChatByUID(data.chatUID);
			if (chatVO != null) {
				var oldDate:Date = chatVO.getDate();
				chatVO.setNewUreadedMessage(data, false);
				S_CHAT_UPDATED.invoke(chatVO);
				var newDate:Date = chatVO.getDate();
				if (latestChats[0] != chatVO) {
					latestChats.splice(latestChats.indexOf(chatVO), 1);
					latestChats.unshift(chatVO);
					if (oldDate.getFullYear() != newDate.getFullYear() || oldDate.getMonth() != newDate.getMonth() || oldDate.getDate() != newDate.getDate())
						S_LATEST_OVERRIDE.invoke();
				}
				S_CHAT_UPDATED.invoke(chatVO);
			}
			var isMine:Boolean = data.user_uid == Auth.uid;
			var mid:Number=0;
			if (("mid" in data) && !isNaN(Number(data.mid)))
				mid = data.mid;
			S_MESSAGE.invoke(currentChat.messages[currentChat.messages.push(new ChatMessageVO(data)) - 1]);
		}
		
		static private function onChatMessage(data:Object):void {
			trace("NEW MESSAGE WEB SOCKET RECEIVED")
			if (!('chatUID' in data))
				return;
			
			if (data.nsws == true) {
				data.text = "|" + data.text;
				SQLite.call_makeMessage(null, data);
				data.text = String(data.text).substr(1);
			} else if ((data.id != 0 || data.mid != 0) && Auth.key != "web")
				SQLite.call_makeMessage(null, data);
			var isMine:Boolean = data.user_uid == Auth.uid;
			var chatVO:ChatVO = getChatByUID(data.chatUID);
			GD.S_DEBUG_WS.invoke("CM: Trying to show message");
			
			if (chatVO == null) {
				if (data.num == 1) {
					NewMessageNotifier.onNewMessagePrivate(data.chatUID);
				}
				loadChatFromPHP(data.chatUID, false, "onChatMessage");
			} else {
				var oldDate:Date = chatVO.getDate();
				
				chatVO.setNewUreadedMessage(data, currentChat == null || (currentChat.uid != data.chatUID) || !(MobileGui.centerScreen.currentScreen is ChatScreen));
				NewMessageNotifier.onNewMessage(data.num, chatVO);
				var newDate:Date = chatVO.getDate();
				if (chatVO.type == ChatRoomType.QUESTION || (chatVO.type == ChatRoomType.CHANNEL && chatVO.questionID != null && chatVO.questionID != "")) {
					if (data.num == 1 && isMine == true) {
						AnswersManager.sendToTop(chatVO, oldDate, newDate);
						WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_UPDATED, { quid:chatVO.questionID, action:"take", chatUID:chatVO.uid } );
					}
				} else {
					if (chatVO.type != ChatRoomType.CHANNEL && chatVO.type != ChatRoomType.QUESTION) {
						if (ChatManager.getCurrentChat() == null || ChatManager.getCurrentChat().uid != chatVO.uid)
							InnerNotificationManager.S_NOTIFICATION_NEED.invoke();
						else if (ChatManager.getCurrentChat().uid != chatVO.uid)
							InnerNotificationManager.S_NOTIFICATION_NEED.invoke();
						else if (MobileGui.centerScreen.currentScreenClass != ChatScreen)
							InnerNotificationManager.S_NOTIFICATION_NEED.invoke();
					}
					if (latestChats != null && latestChats[0] != chatVO) {
						if (chatVO.type != ChatRoomType.CHANNEL) {
							latestChats.splice(latestChats.indexOf(chatVO), 1);
							latestChats.unshift(chatVO);
						}
						if (oldDate.getFullYear() != newDate.getFullYear() || oldDate.getMonth() != newDate.getMonth() || oldDate.getDate() != newDate.getDate())
							S_LATEST_OVERRIDE.invoke();
						else
							S_LATEST_REPOSITION.invoke();
					}
				}
				if ("stat" in data)
					if (chatVO.addStat(data.stat))
						S_CHAT_STAT_CHANGED.invoke(chatVO);
				S_CHAT_UPDATED.invoke(chatVO);
			}
			var mid:Number = 0;
			if (("mid" in data) && !isNaN(Number(data.mid)))
				mid = data.mid;
			if (Number(data.id) >= 0 && mid != 0 && isMine) {
				MessagesController.newRemoteMessage(data.mid);
			}
			if (isMine && mid > 0) {
				VideoUploader.checkMessage(data, mid);
			}

			if (currentChat == null) {
				if (CallManager.isActive() == false && data.id > 0 && !("mid" in data))
					SoundController.playChatMessageNotification();
				return;
			}

			if (currentChat.uid != data.chatUID) {
				if (CallManager.isActive() == false && data.id > 0)
					SoundController.playChatMessageNotification();
				return;
			}

			if (isMine && mid > 0) {
				var updatedMsg:ChatMessageVO = currentChat.updateMessage(data, true);
				
				if (updatedMsg != null) {
					if ("mid" in data)
					{
						RichMessageDetector.newMessage(updatedMsg, currentChat, data.mid);
					}
					
					S_MESSAGE_UPDATED.invoke(updatedMsg);
					updatedMsg = null;
					return;
				}
			}

			if (isMine) {
				if (Config.PLATFORM_APPLE == false)
					SoundController.playChatMessageSent();
			}else{
				SoundController.playChatMessageReceive();
			}
			trace("CHECK APPROVED");
			if (_notApproved == false) {
				trace("APPROVED");
				var message:ChatMessageVO = new ChatMessageVO(data);
				if (message.userVO != null) {
					trace("APPROVED -> " + message.userVO.type + "; " + message.userVO.uid);
				} else {
					trace("APPROVED -> " + message.userUID);
				}
				//if (message.userVO != null && message.userVO.type == UserType.BOT){
				if (message.userUID == ConfigManager.config.supportBotUID) {
					trace("FROM BOT");
					message.checkForImmediatelyMessage = true;
				}
				var userAvatar:String = currentChat.getUserAvatar(message.userUID);
				if (userAvatar)
					message.avatar = userAvatar;
				if (currentChat.messages != null)
					S_MESSAGE.invoke(currentChat.messages[currentChat.messages.push(message) - 1]);
				if(isMine)
					GD.S_DEBUG_WS.invoke("CM: message must be shown!");
			}else{
				trace("NOT APPROVED");
				GD.S_DEBUG_WS.invoke("CM: message not shown! mine:"+isMine)
			}
		}
		
		static private function onChatMessageUpdated(data:Object):void {
			if (data && ("error" in data) && data.error == true) {
				return;
			}
			if (data.nsws == true) {
				data.text = "|" + data.text;
				SQLite.call_updateMessage(null, data.id, data.text);
				data.text = String(data.text).substr(1);
			} else
				SQLite.call_updateMessage(null, data.id, data.text);
			if (currentChat != null && currentChat.uid == data.chatUID) {
				var updatedMsg:ChatMessageVO = currentChat.updateMessage(data);
				if (updatedMsg != null)
					S_MESSAGE_UPDATED.invoke(updatedMsg);
				updatedMsg = null;
				if (data.id == currentChat.messageID)
					S_LATEST_OVERRIDE.invoke();
				return;
			}
		}
		
		static private function onChatMessageRemoved(data:Object):void {
			SQLite.call_removeMessage(null, data.id);
			if (currentChat != null && currentChat.uid == data.chatUID) {
				var updatedMsg:ChatMessageVO = currentChat.updateMessage(data);
				if (updatedMsg != null)
					S_MESSAGE_UPDATED.invoke(updatedMsg);
				updatedMsg = null;
				if (data.id == currentChat.messageID)
					S_LATEST_OVERRIDE.invoke();
				return;
			}
		}
		
		static public function loadChatFromPHP(chatUID:String, openAfterLoad:Boolean = false, reason:String = ""):void {
			echo("ChatManager", "loadChatFromPHP");
			PHP.chat_get((openAfterLoad == true) ? onChatLoadedFromPHPAndOpen : onChatLoadedFromPHP, chatUID, true, true, "loadChatFromPHP." + reason, chatUID);
		}
		
		static private function onChatLoadedFromPHP(phpRespond:PHPRespond):void {
			var chatVO:ChatVO = prepareLoadedChat(phpRespond);
			if (chatVO == null)
			{
				S_CHAT_PREPARED_FAIL.invoke(phpRespond.additionalData);
			}
			phpRespond.dispose();
		}
		
		//TODO - ADD MESSAGES TO UPLOAD!
		static private function prepareLoadedChat(phpRespond:PHPRespond):ChatVO {
			echo("ChatManager", "prepareLoadedChat");
			if (phpRespond.error) {
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.22') != -1) {
					var parser:ShopProductDataParser = new ShopProductDataParser();
					var product:ShopProduct = parser.parse(phpRespond.data.data, new ProductType(ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION));
					if (product != null)
						Shop.buyChannelAccess(currentChat.uid, product);
					phpRespond.dispose();
					return null;
				}
				echo("ChatManager", "prepareLoadedChat", "ERROR: " + phpRespond.errorMsg);
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.03') != -1) {
					return null;
				}
			}
			if ("data" in phpRespond && phpRespond.data == null) {
				echo("ChatManager", "prepareLoadedChat", "ERROR: Data is null");
				return null;
			}
			var cVO:ChatVO = getChatByUID(phpRespond.data.uid);
			if (cVO == null) {
				cVO = new ChatVO(phpRespond.data);
				addChatToLatest(cVO);
				NewMessageNotifier.addNewChat(cVO);
			} else
				cVO.setData(phpRespond.data);
			S_CHAT_PREPARED.invoke(cVO);
			updateLatestsInStore();
			return cVO;
		}
		
		static private function checkForNewContact():Boolean{
			if (currentChat.type != ChatRoomType.PRIVATE)
				return false;
			if (currentChat.ownerUID == Auth.uid)
				return false;
			if (currentChat.ownerUID == Config.NOTEBOOK_USER_UID || currentChat.ownerUID == Config.DUKASCOPY_INFO_SERVICE_UID)
				return false;
			if (ContactsManager.getUserModelByUserUID(currentChat.ownerUID) != null)
				return false;
			if (PhonebookManager.getUserModelByUserUID(currentChat.ownerUID) != null)
				return false;
			return !ChatUsersManager.checkForApproved(currentChat.ownerUID);
		}
		
		static private function getChatPin():void {
			Store.load('paranoic_' + currentChat.uid, function(data:Object, error:Boolean):void {
				if (error && currentChat != null) { // Alexey added check for null
					currentChat.setPin("----");
				}
				if (data != null) {
					if (currentChat != null) // Alexey added
						currentChat.setPin(Crypter.decrypt(data as String, "123"));
				} else {
					if (currentChat != null) // Alexey added
						currentChat.setPin('----');
				}
				loadChatMessages();
			});
		}
		
		static public function addPin(val:String, chat:ChatVO = null):void {
			var selectedChat:ChatVO;
			if (chat)
				selectedChat = chat;
			else
				selectedChat = currentChat;
			if (selectedChat) {
				selectedChat.setPin(val);
				DialogManager.alert(Lang.textAlert, Lang.alertConfirmSetPIN, function(alertVal:int):void {
					if (alertVal == 1)
						Store.save("paranoic_" + selectedChat.uid, Crypter.crypt(val + '', "123"));
				}, Lang.textYes.toUpperCase(), Lang.textNo.toUpperCase());
				S_PIN.invoke(true);
			}
		}
		
		static public function removePin(chat:ChatVO = null):void {
			var selectedChat:ChatVO;
			if (chat)
				selectedChat = chat;
			else
				selectedChat = currentChat;
			if (selectedChat) {
				selectedChat.setPin("----");
				Store.remove("paranoic_" + selectedChat.uid);
				S_PIN.invoke(false);
			}
		}
		
		static public function get latestsResponded():Boolean{
			return latestChatsLoaded;
		}
		
		static public function get inChat():Boolean{
			return _inChat;
		}
		
		static public function onExitChat(chat:ChatVO = null):void {
			var selectedChat:ChatVO;
			if (chat) {
				selectedChat = chat;
			} else {
				selectedChat = currentChat;
			}
			if (selectedChat == null)
				return;
			WSClient.call_chatUserExit(selectedChat.uid);
		}
		
		static public function getChatBackground(uid:String, callback:Function = null):void{
			getChatSettingsModel(uid,
				function(settingsModel:ChatSettingsModel):void {
					var backId:String;
					if (settingsModel)
						backId = settingsModel.chatBackId;
					UPDATE_CHAT_BACKGROUND.invoke( { chatUID:uid, id:backId } );
					if (callback != null)
						callback(backId);
				}
			);
		}
		
		static public function getChatSettingsModel(uid:String, onSettingsGained:Function):void {
			var model:ChatSettingsModel = getCachedChatSettingsModel(uid);
			if (model)
				onSettingsGained(model);
			else {
				Store.load(Store.CHAT_SETTINGS + uid,
					function(dataString:String, error:Boolean):void {
						var data:Object;
						if (dataString != null)
						{
							try {
								data = JSON.parse(dataString)
							} catch (e:Error) { }
						}
					
						model = addChatSettingsModelToCache(data, uid);
						onSettingsGained(model);
					}
				);
			}
		}
		
		static public function addChatSettingsModelToCache(chatSettingsData:Object, uid:String):ChatSettingsModel {
			var model:ChatSettingsModel;
			if (!chatsSettings)
				chatsSettings = new Vector.<ChatSettingsModel>();
			if (!chatSettingsData) {
				model = new ChatSettingsModel();
				model.chatId = uid;
				chatsSettings.push(model);
				return model;
			}
			var l:int = chatsSettings.length;
			for (var i:int = 0; i < l; i++) {
				if (chatsSettings[i].chatId == chatSettingsData[ChatSettingsModel.CHAT_ID_FIELD])
					return chatsSettings[i];
			}
			model = new ChatSettingsModel();
			model.chatId = chatSettingsData[ChatSettingsModel.CHAT_ID_FIELD];
			model.chatBackId = chatSettingsData[ChatSettingsModel.BACKGROUND_ID_FIELD];
			chatsSettings.push(model);
			return model;
		}
		
		static private function getCachedChatSettingsModel(uid:String):ChatSettingsModel {
			if (!chatsSettings)
				chatsSettings = new Vector.<ChatSettingsModel>();
			var l:int = chatsSettings.length;
			for (var i:int = 0; i < l; i++) {
				if (chatsSettings[i].chatId == uid)
					return chatsSettings[i];
			}
			return null;
		}
		
		static public function setBackgroundImage(uid:String, id:String):void {
			getChatSettingsModel(uid, function(settingsModel:ChatSettingsModel):void {
				settingsModel.chatBackId = id;
				saveChatModel(settingsModel, function():void {
					UPDATE_CHAT_BACKGROUND.invoke( { chatUID:uid, id:id } );
				});
			});
		}
		
		static private function removeLocalChat(cVO:ChatVO):void {
			if (localChatSyncronizer != null) {
				localChatSyncronizer.removeChat(cVO);
			}
			removeChatFromCurrents(cVO.uid);
		}
		
		static public function changeChatTitle(uid:String, value:String, securityKey:String):void {
			var cryptedValue:String = "!" + Crypter.crypt(value, securityKey);
			PHP.changeChatTitle(uid, cryptedValue, onChatTitleChanged, { chatUID:uid, value:value } );
		}
		
		static private function onChatTitleChanged(phpRespond:PHPRespond):void {
			if (phpRespond.error) {
				S_TITLE_CHANGE.invoke( { success:false } );
				DialogManager.alert(Lang.textWarning, Lang.alertChangeChatTitle + "\n" + phpRespond.errorMsg);
				phpRespond.dispose();
				return;
			}
			var chatModel:ChatVO = getChatByUID(phpRespond.additionalData.chatUID);
			if (chatModel) {
				chatModel.title = phpRespond.additionalData.value;
			} else {
				ApplicationErrors.add("No chat model");
			}
			S_LATEST.invoke();
			WSClient.call_chatTitleChanged(getChatUsersIDs(chatModel), chatModel.uid, Crypter.crypt(chatModel.title, chatModel.securityKey))
			S_TITLE_CHANGE.invoke( { success:true } );
			phpRespond.dispose();
		}
		
		static private function getChatUsersIDs(chatModel:ChatVO):Array {
			var usersIds:Array = new Array();
			var l:int = chatModel.users.length;
			for (var i:int = 0; i < l; i++)
				usersIds.push(chatModel.users[i].uid);
			return usersIds;
		}
		
		static public function changeChatAvatar(uid:String, image:String, deleteAvatarRequest:String):void{
			var __onRespond:Function = function(phpRespond:PHPRespond):void{
				if (phpRespond.error) {
					S_AVATAR_CHANGE.invoke({success:false});
					DialogManager.alert(Lang.textWarning, Lang.alertChangeChatAvatar + "\n" + phpRespond.errorMsg);
					phpRespond.dispose();
					return;
				}
				var chatModel:ChatVO = getChatByUID(uid);
				if (chatModel != null && phpRespond.data != null){
					chatModel.avatar = phpRespond.data.toString();
				} else {
					ApplicationErrors.add("wrong data");
				}
				WSClient.call_chatAvatarChanged(getChatUsersIDs(chatModel), chatModel.uid, chatModel.avatar);
				S_AVATAR_CHANGE.invoke( { success:true } );
				phpRespond.dispose();
			}
			PHP.changeChatAvatar(uid, image, __onRespond);
		}
		
		static public function changeChatPushNotificationsStatus(uid:String, value:Boolean):void {
			WSClient.call_changeNotoficationsMode(value, uid);
		}
		
		static public function getFirstChatWithUser(userUID:String):ChatVO {
			if (!latestChats)
				return null;
			var l:int = latestChats.length;
			var users:Vector.<ChatUserVO>;
			for (var m:int = 0; m < l; m++) {
				if (latestChats[m] != null) {
					users = (latestChats[m] as ChatVO).users;
					if (users == null) {
						continue; // Alexey added check for null, because it causes error without check
					}
					for (var i:int = 0; i < (latestChats[m] as ChatVO).users.length; i++) {
						if (users[i] != null && users[i].uid == userUID) {
							users = null;
							return (latestChats[m] as ChatVO);
						}
					}
				}
			}
			users = null;
			return null;
		}
		
		static public function getChatByQuestionUID(quid:String):ChatVO {
			if (latestChats == null)
				return null;
			for (var i:int = 0; i < latestChats.length; i++) {
				if (latestChats[i].questionID == quid)
					return latestChats[i];
			}
			return null;
		}
		
		static public function callToChatUser():void {
			/*if (WS.connected == false) {
				DialogManager.alert(Lang.textAttention, Lang.checkNetworkStatus);
				return;
			}*/
			if (currentChat != null &&
				currentChat.type == "private" &&
				currentChat.users != null &&
				currentChat.users.length == 1 &&
				currentChat.users[0].uid != null &&
				currentChat.users[0].uid != "") {
					if (currentChat.users[0].secretMode == true) {
						return;
					}
					CallManager.place(currentChat.users[0].uid,
						MobileGui.centerScreen.currentScreenClass,
						MobileGui.centerScreen.currentScreen.data,
						(currentChat.users[0].name != null) ? currentChat.users[0].name : "",
						UsersManager.getAvatarImage(currentChat.users[0], currentChat.avatar, int(Config.FINGER_SIZE * 1.54) * 2)
					);
			}
		}
		
		static public function sendVoice(soundFile:LocalSoundFileData):void {
			if (currentChat == null)
				return;
			if ("pid" in currentChat && currentChat.pid>0){
				ToastMessage.display(Lang.cantSendVoiceToSupport);
				return;
			}
			var filePath:String = soundFile.path;
			var successAction:IAction = new SendVoiceToChatAction();
			var uploader:DocumentUploader = new DocumentUploader(new RemoteSoundFileData(null, soundFile.duration), successAction, null);
			uploader.start(filePath, Config.URL_PHP_CORE_SERVER_FILE + "?chatUID=" + currentChat.uid + "&method=files.addDoc&key=" + Auth.key);
		}
		
		static private function removeChatFromCurrents(chatUID:String):void {
			if (currentChat && currentChat.uid == chatUID)
				closeChat();
			if (AnswersManager.removeAnswer(chatUID) == true)
				return;
			if (ChannelsManager.removeChannel(chatUID) == true)
				return;
			if (latestChats == null)
				return;
			var removedChat:ChatVO;
			var l:int = latestChats.length;
			for (var m:int = 0; m < l; m++) {
				if (latestChats[m] != null && latestChats[m].uid == chatUID) {
					removedChat = latestChats.removeAt(m);
					S_LATEST.invoke();
					break;
				}
			}
			if (removedChat != null) {
				removedChat.dispose();
				updateLatestsInStore();
			}
			removedChat = null;
		}
	
		static private function saveChatModel(settingsModel:ChatSettingsModel, callback:Function):void {
			var a:String = JSON.stringify(settingsModel);
			Store.save(Store.CHAT_SETTINGS + settingsModel.chatId, JSON.stringify(settingsModel), function(data:Object, error:Boolean):void {
				if (!error)
				callback(data);
			} );
		}
		
		static public function get chatUsersCollection():ChatUsersCollection {
			return _chatUsersCollection;
		}
		
		static public function get currentChatApproveStatus():Boolean {
			return _notApproved;
		}
		
		static public function getOnlineUsersNum(chatUID:String):int {
			return _chatUsersCollection.getOnlineUsersNum(chatUID);
		}
		
		static public function getOnlineUsers(chatUID:String):Array {
			return _chatUsersCollection.getUsersArray(chatUID);
		}
		
		static public function activateChat():void {
			if (currentChat == null)
				return;
			loadChatMessages();
		}
		
		static public function isAnon(chatUID:String):Boolean {
			var chatVO:ChatVO;
			if (currentChat != null && currentChat.uid == chatUID) {
				chatVO = currentChat;
			} else {
				chatVO = getChatByUID(chatUID);
			}
			var qVO:QuestionVO;
			if (chatVO != null) {
				if (chatVO.type == ChatRoomType.QUESTION || (chatVO.questionID != null && chatVO.questionID != "")) {
					qVO = chatVO.getQuestion();
					if (qVO == null)
						qVO = QuestionsManager.getQuestionByUID(chatVO.questionID, false);
					if (qVO != null) {
						if (qVO.userUID == Auth.uid && qVO.incognito == true)
							return true;
						return false;
					} else {
						return false;
					}
				}
			}
			return false;
		}
		
		static public function addMessageReaction(message:ChatMessageVO, uid:String, reaction:String):void {
			var data:Object = new Object();
			data.chatUID = message.chatUID;
			data.id = message.id;
			data.reaction = reaction;
			WSClient.call_addMessageReaction(data);
		}
		
		static public function removeMessageReaction(message:ChatMessageVO, uid:String, reaction:String):void {
			var data:Object = new Object();
			data.chatUID = message.chatUID;
			data.id = message.id;
			data.reaction = null;
			WSClient.call_removeMessageReaction(data);
		}
		
		static public function getFirstMsgsCount():Number { return firstMsgsCount; }
		static public function setFirstMsgsCount(val:Number):void {
			firstMsgsCount = val;
		}
		
		static public function getFirstChatsCount():Number { return firstChatsCount; }
		static public function setFirstChatsCount(val:Number):void {
			firstChatsCount = val;
		}
		
		static public function editChatMessage(msgVO:ChatMessageVO):void {
			S_EDIT_MESSAGE.invoke(msgVO);
		}
		
		static public function readyForQueue(callback:Function):void {
			/*// НА сервере обязательно менять фазу на VIDID_QUEUE
			/*PHP.api_setupQueue(
				function(phpRespond:PHPRespond):void {
					callback(!phpRespond.error);
				},
				currentChat.pid
			);*/
		}
		
		static public function cancelQueue(callback:Function):void {
			// НА сервере обязательно менять фазу на VIDID
			/*PHP.api_cancelQueue(
				function(phpRespond:PHPRespond):void {
					callback(!phpRespond.error);
				},
				currentChat.pid
			);*/
		}
		
		static public function readyForVIDID(callback:Function):void {
			sendCredentials();
			PHP.api_readyForVIDID(
				function(phpRespond:PHPRespond):void {
					PHP.call_statVI("vidid_device",Auth.devID);
					callback(!phpRespond.error);
				},
				currentChat.pid
			);
		}
		
		static public function cancelVIDID(callback:Function):void {
			var type:String = null;
			var epid:int = currentChat.pid;
			if (epid == 133)
				type = "BANK";
			if (epid == 135)
				type = "EU";
			if (epid == 136)
				type = "PAY";
			PHP.api_yiPhase(
				"VIDID",
				type,
				function(phpRespond:PHPRespond):void {
					if(!phpRespond.error){
						sendMessageLecDoItLater();
					}
					callback(!phpRespond.error);
				}
			);
		}
		
		static public function sendMessageToUser(uid:String, message:String):void {
			var task:SendMessageToUserAction = new SendMessageToUserAction(message, uid);
			task.execute();
		}
		
		static public function initGeo(messageData:ChatMessageVO):void {
			if (currentChat == null || currentChat.getQuestion() == null)
				return;
			if (messageData.systemMessageVO.geolocation == null || currentChat.getQuestion().geolocation == null)
				return;
			if (GeolocationManager.getMyLocation() == null) {
				geoMessage = messageData;
				GeolocationManager.S_LOCATION.add(onLocationFromInitGeo);
				GeolocationManager.getLocation();
				return;
			}
			var distance:Number = GeolocationManager.getDistanceFromLatLonInKm(
				currentChat.getQuestion().geolocation.latitude,
				currentChat.getQuestion().geolocation.longitude,
				messageData.systemMessageVO.geolocation.latitude,
				messageData.systemMessageVO.geolocation.longitude
			);
			messageData.systemMessageVO.setLocationString(
				"I'm " + distance.toFixed(2) + " km from you"
			);
		}
		
		static private var myGroup:Object;
		static private var myGroupTS:Number;
		static private var k:int = 0;
		
		static public function checkForQueueMax(current:int, callback:Function):void {
			if (myGroup != null && myGroupTS > new Date().getTime() - 5 * 60 * 1000) {
				if (current < myGroup.lineMax) {
					callback(true);
					return;
				}
				callback(false);
				return;
			}
			PHP.countryGroup_getMy(function(phpRespond:PHPRespond):void {
				myGroupTS = new Date().getTime();
				if (phpRespond.error == true) {
					callback(false);
					return;
				}
				myGroup = phpRespond.data;
				if (current < phpRespond.data.lineMax) {
					callback(true);
					return;
				}
				callback(false);
			});
		}
		
		static private function onLocationFromInitGeo(location:Location):void {
			GeolocationManager.S_LOCATION.remove(onLocationFromInitGeo);
			S_MESSAGE_UPDATED.invoke(geoMessage);
			geoMessage = null;
		}
		
		public static function isLoadedFromStore():Boolean {
			return chatsLoadedFromStore;
		}
		
		static public function createTemporaryIncomingChat(object:Object):void {
			
		}
		
		static public function getLocalChat(messageData:Object):ChatVO {
			return localChatSyncronizer.getLocalChatFromMessage(messageData);
		}
		
		static public function getLocalChatByUID(chatUID:String):ChatVO {
			return localChatSyncronizer.getLocalChatByUID(chatUID);
		}
		
		static public function resortLatests():void {
			if (latestChats != null) {
				latestChats.sort(sortByDate);
				S_LATEST.invoke();
			}
		}
	}
}