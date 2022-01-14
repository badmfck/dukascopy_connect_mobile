package com.dukascopy.connect.gui.topBar.x.controller 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.ChatCallAction;
	import com.dukascopy.connect.data.screenAction.customActions.ChatLockAction;
	import com.dukascopy.connect.data.screenAction.customActions.ChatSettingsAction;
	import com.dukascopy.connect.data.screenAction.customActions.ChatSubscribeAction;
	import com.dukascopy.connect.data.screenAction.customActions.ChatUnSubscribeAction;
	import com.dukascopy.connect.data.screenAction.customActions.ExecuteAction;
	import com.dukascopy.connect.gui.topBar.x.TopBar;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TopBarChatController implements IBarController
	{
		private var view:TopBar;
		private var chatData:ChatScreenData;
		private var actionBack:ExecuteAction;
		private var buttons:Vector.<IScreenAction>;
		private var lastOnlineStatus:Boolean = true;
		
		public function TopBarChatController(chatData:ChatScreenData, actionBack:ExecuteAction) 
		{
			this.chatData = chatData;
			this.actionBack = actionBack;
			
			addListeners();
		}
		
		private function addListeners():void 
		{
			GD.CHAT_LOCK_CHANGED.add(onChatLockChanged);
			GD.CHAT_SUBSCRIBE_RESULT.add(onChatSubscribe);
			GD.CHAT_UNSUBSCRIBE_RESULT.add(onChatUnsubscribe);
			GD.S_WS_STATUS.add(onWSStatus);
			
			if (Config.PLATFORM_ANDROID)
			{
				NetworkManager.S_CONNECTION_CHANGED.add(onNetworkChanged);
			}
			
			ChatManager.S_CHAT_UPDATED.add(onChatUpdated);
			UsersManager.USER_BLOCK_CHANGED.add(onUserBlockStatusChanged);
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivateNative);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeativateNative);
		}
		
		private function onNetworkChanged():void {
			onWSStatus(NetworkManager.isConnected);
		}
		
		private function removeListeners():void 
		{
			GD.CHAT_LOCK_CHANGED.remove(onChatLockChanged);
			GD.CHAT_SUBSCRIBE_RESULT.remove(onChatSubscribe);
			GD.CHAT_UNSUBSCRIBE_RESULT.remove(onChatUnsubscribe);
			GD.S_WS_STATUS.remove(onWSStatus);
			
			NetworkManager.S_CONNECTION_CHANGED.remove(onNetworkChanged);
			
			ChatManager.S_CHAT_UPDATED.remove(onChatUpdated);
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged)
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivateNative);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, onDeativateNative);
		}
		
		private function onWSStatus(status:Boolean):void{
			lastOnlineStatus = status;
			updateSubtitle();
		}
		
		private function updateSubtitle():void 
		{
			if (lastOnlineStatus == false)
			{
				drawStatus(false, Lang.waiting_for_connection);
			}
			else
			{
				updateUserStatus();
			}
		}
		
		private function updateUserStatus():void {
			var chat:ChatVO = ChatManager.getCurrentChat();
			if (chat != null && (chat.type == ChatRoomType.PRIVATE || chat.type == ChatRoomType.QUESTION))
			{
				UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
				if (chat.users == null || chat.users.length == 0 ||	chat.users[0].uid == "")
				{
					drawStatus(true, null);
					return;
				}
				onUserOnlineStatusChanged(UsersManager.isOnline(chat.users[0].uid), null);
			}
			else
			{
				drawStatus(true, null);
			}
		}
		
		private function onUserBlockStatusChanged(data:Object):void {
			updateSubtitle();
		}
		
		private function onUserOnlineStatusChanged(m:OnlineStatus, method:String):void {
			if (ChatManager.getCurrentChat() == null || (ChatManager.getCurrentChat().type != ChatRoomType.PRIVATE && ChatManager.getCurrentChat().type != ChatRoomType.QUESTION)) {
				return;
			}
			
			if (ChatManager.getCurrentChat().users == null ||
				ChatManager.getCurrentChat().users.length == 0 ||
				ChatManager.getCurrentChat().users[0].uid == "") {
					return;
			}
			
			var blockStatus:String = "";	
			var userUID:String = ChatManager.getCurrentChat().users[0].uid;
			if (Auth.blocked != null && Auth.blocked.indexOf(userUID) !=-1){
				// user zablochen 
				blockStatus = "-" + Lang.textBlocked.toLowerCase();
			}
			
			var resultString:String = "";
			var resultOnline:Boolean = false;
			
			if (m == null) {
				resultString = Lang.textOffline + blockStatus
				resultOnline = false;
			}
			else if (m.uid != ChatManager.getCurrentChat().users[0].uid) {
				return;
			}
			else if (m.uid == Config.NOTEBOOK_USER_UID) {
				resultString = Lang.textOnline;
				resultOnline = true;
			}
			else if (m.online == false) {
				resultString = Lang.textOffline + blockStatus;
				resultOnline = false;
			}
			else
			{
				resultString = Lang.textOnline + blockStatus;
				resultOnline = true;
			}
			
			if (lastOnlineStatus == false)
			{
				drawStatus(false, Lang.waiting_for_connection);
			}
			else
			{
				drawStatus(resultOnline, resultString);
			}
		}
		
		private function drawStatus(boolean:Boolean, status:String):void 
		{
			if (status == "")
			{
				status = null;
			}
			if (view != null)
			{
				view.setSubtitle(status);
				view.updatePositions();
			}
		}
		
		private function onChatUpdated(chatVO:ChatVO):void {
			if (!(ChatManager.getCurrentChat() == null || chatVO == null || chatVO.uid != ChatManager.getCurrentChat().uid)) {
				return;
			}
			update();
		}
		
		private function onActivateNative(e:Event):void {
			if (view != null)
				view.activate();
		}
		
		private function onDeativateNative(e:Event):void {
			if (view != null)
				view.deactivate();
		}
		
		private function onChatUnsubscribe(success:Boolean, uid:String, message:String = null):void 
		{
			if (success)
			{
				update();
			}
		}
		
		private function onChatSubscribe(success:Boolean, uid:String, message:String = null):void 
		{
			if (success)
			{
				update();
			}
		}
		
		private function onChatLockChanged():void 
		{
			update();
		}
		
		public function setView(view:TopBar):void
		{
			this.view = view;
		}
		
		private function getTitleValue():String {
			var userModel:UserVO;
			var titleText:String;
			if (chatData != null) {
				var chatModel:ChatVO;
				if (ChatManager.getCurrentChat() != null) {
					chatModel = ChatManager.getCurrentChat();
				} else if (chatData.chatVO != null) {
					chatModel = chatData.chatVO;
				} else {
					if (chatData.chatUID != null) {
						chatModel = ChatManager.getChatByUID(chatData.chatUID);
					}
				}
				if (chatModel != null && 
					(chatModel.type == ChatRoomType.PRIVATE || chatModel.type == ChatRoomType.QUESTION) && 
					chatModel.users != null && chatModel.users.length > 0) {
						var user:ChatUserVO = chatModel.users[0];
						if (user != null) {
							if (user.secretMode == true)
								return Lang.textIncognito;
							userModel = user.userVO;
							if (userModel != null)
								titleText = userModel.getDisplayName();
							else
								titleText = chatModel.title;
						}
				}
				if (chatModel != null && 
					chatModel.type == ChatRoomType.CHANNEL && 
					chatModel.questionID != null && chatModel.questionID != "") {
						if (chatModel.getQuestion() != null && chatModel.getQuestion().user != null) {
							if (chatModel.getQuestion().incognito)
								return Lang.textIncognito;
							return chatModel.getQuestion().user.getDisplayName();
						} else
							return Lang.question;
				}
				if (chatData.type == ChatInitType.CHAT || chatData.type == ChatInitType.QUESTION) {
					if (chatModel != null) {
						if (chatModel.type == ChatRoomType.PRIVATE || chatModel.type == ChatRoomType.QUESTION) {
							if (chatModel.users && chatModel.users.length > 0) {
								userModel = chatModel.users[0].userVO;
								if (userModel != null)
									titleText = userModel.getDisplayName();
								else
									titleText = chatModel.title;
							} else
								titleText = chatModel.title;
						} else
							titleText = chatModel.title;
					} else {
						if (chatData.type == ChatInitType.QUESTION && chatData.question != null) {
							if (chatData.question.incognito == true)
								titleText = Lang.textIncognito;
							else
								titleText = chatData.question.title;
						}
					}
				} else if (chatData.type == ChatInitType.USERS_IDS) {
					if (chatData.usersUIDs) {
						if (chatData.usersUIDs.length == 1) {
							userModel = UsersManager.getFullUserData(chatData.usersUIDs[0]);
							
							if (userModel && userModel.getDisplayName() != "" && userModel.getDisplayName() != null) {
								titleText = userModel.getDisplayName();
							} else {
								if (chatModel) {
									titleText = chatModel.title;
								}
							}
						} else {
							//group chat;
							if (chatModel) {
								titleText = chatModel.title;
							} else {
								titleText = '';
								var userProfile:UserVO;
								for (var i:int = 0; i < chatData.usersUIDs.length; i++) {
									userProfile = UsersManager.getFullUserData(chatData.usersUIDs[i], false);
									if (userProfile && userProfile.getDisplayName() != null) {
										if (i > 0)
											titleText+= ', ';
										titleText += userProfile.getDisplayName();
									}
								}
							}
						}
					}
				} else if (chatData.type == ChatInitType.SUPPORT) {
					var pid:int = (chatData!=null && "pid" in chatData)?chatData.pid:-1;
					if (pid ==-1 && chatModel != null)
						pid = chatModel.pid;
					if (pid ==-1)
						titleText = Lang.standartSupportTitle;
					else if (pid == Config.EP_VI_DEF)
						titleText = Lang.chatWithBankTitle;
					else if (pid == Config.EP_VI_EUR)
						titleText = Lang.chatWithBankEUTitle;	
					else if (pid == Config.EP_VI_PAY)
						titleText = Lang.chatWithPayEUTitle;
					else if (chatModel != null)
						titleText = chatModel.title;
				}
			}
			
			if (titleText == null){
				titleText = "";
			}
			
			return titleText;
		}
		
		public function dispose():void
		{
			removeListeners();
			
			if (actionBack != null)
			{
				actionBack.dispose();
				actionBack = null;
			}
		}
		
		public function update():void
		{
			updateTitle();
			updateSubtitle();
			updateButtons();
				
			//	channelUsersChanged();
				
				/*if (ChatManager.getCurrentChat().type == ChatRoomType.COMPANY)
					drawChatUID();*/
			
			if (view != null)
			{
				view.updatePositions();
			}
		}
		
		private function updateButtons():void 
		{
			var newButtons:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			
			updateCallButton(newButtons);
			updateStreamButton(newButtons);
			updateLockButton(newButtons);
			updateSettingsButton(newButtons);
			updateSubscribeButton(newButtons);
			
			if (!isEqual(newButtons, buttons))
			{
				buttons = newButtons;
				if (view != null)
				{
					view.updateButtons(buttons);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
		}
		
		private function isEqual(a:Vector.<IScreenAction>, b:Vector.<IScreenAction>):Boolean 
		{
			if (a == null && b == null)
			{
				return true;
			}
			
			if (a == null)
			{
				return false;
			}
			
			if (b == null)
			{
				return false;
			}
			
			if (a.length != b.length)
			{
				return false;
			}
			
			for (var i:int = 0; i < a.length; i++) 
			{
				if (a[i].getAdditionalData != b[i].getAdditionalData)
				{
					return false;
				}
			}
			return true;
		}
		
		private function updateTitle():void 
		{
			view.drawTitle(getTitleValue());
		}
		
		public function onBack():void 
		{
			if (actionBack != null)
			{
				actionBack.execute();
			}
		}
		
		private function updateLockButton(newButtons:Vector.<IScreenAction>):void 
		{
			var chat:ChatVO = ChatManager.getCurrentChat();
			var chatType:String;
			
			if (chat != null)
			{
				chatType = chat.type;
				
				if (chat.isLocalIncomeChat() == false &&
					chatType != ChatRoomType.COMPANY &&
					chatType != ChatRoomType.QUESTION &&
					chatType != ChatRoomType.CHANNEL)
				{
					var button:IScreenAction = new ChatLockAction();
					button.setAdditionalData("ChatLockAction");
					if (newButtons != null)
					{
						newButtons.push(button);
					}
					else
					{
						ApplicationErrors.add();
					}
				}
			}
		}
		
		private function updateCallButton(newButtons:Vector.<IScreenAction>):void 
		{
			var chat:ChatVO = ChatManager.getCurrentChat();
			var chatType:String;
			
			if (chat != null)
			{
				chatType = chat.type;
				
				if (chatType == ChatRoomType.PRIVATE && !chat.isLocalIncomeChat())
				{
					var user:ChatUserVO = UsersManager.getInterlocutor(chat);
					
					if (user != null && user.uid != Config.NOTEBOOK_USER_UID && user.userVO != null && user.userVO.type != UserVO.TYPE_BOT)
					{
						var button:IScreenAction = new ChatCallAction();
						button.setAdditionalData("ChatCallAction");
						if (newButtons != null)
						{
							newButtons.push(button);
						}
						else
						{
							ApplicationErrors.add();
						}
					}
				}
			}
		}
		
		private function updateStreamButton(newButtons:Vector.<IScreenAction>):void 
		{
			// NOT USED !
			
			/*var chat:ChatVO = ChatManager.getCurrentChat();
			var chatType:String;
			
			if (chat != null)
			{
				chatType = chat.type;
				
				var button:IScreenAction = new ChatStreamAction();
				button.setAdditionalData("ChatStreamAction");
				if (newButtons != null)
				{
					newButtons.push(button);
				}
				else
				{
					ApplicationErrors.add();
				}
			}*/
		}
		
		private function updateSubscribeButton(newButtons:Vector.<IScreenAction>):void 
		{
			var chat:ChatVO = ChatManager.getCurrentChat();
			var chatType:String;
			
			if (chat != null)
			{
				chatType = chat.type;
				
				if (chatType == ChatRoomType.CHANNEL && chat.channelData != null) {
					if (!chat.isModerator(Auth.uid) && !chat.isOwner(Auth.uid)) {
						
						var button:IScreenAction;
						
						if (chat.channelData.subscribed) {
							button = new ChatUnSubscribeAction();
							button.setAdditionalData("ChatUnSubscribeAction");
						} else {
							button = new ChatSubscribeAction();
							button.setAdditionalData("ChatSubscribeAction");
						}
						if (newButtons != null)
						{
							newButtons.push(button);
						}
						else
						{
							ApplicationErrors.add();
						}
					}
				}
			}
		}
		
		private function updateSettingsButton(newButtons:Vector.<IScreenAction>):void 
		{
			var chat:ChatVO = ChatManager.getCurrentChat();
			var chatType:String;
			
			if (chat != null)
			{
				chatType = chat.type;
				if (chatType != ChatRoomType.COMPANY && !chat.isLocalIncomeChat())
				{
					var button:IScreenAction = new ChatSettingsAction();
					button.setAdditionalData("ChatSettingsAction");
					if (newButtons != null)
					{
						newButtons.push(button);
					}
					else
					{
						ApplicationErrors.add();
					}
				}
			}
		}
	}
}