package com.dukascopy.connect.screens.chat {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ChatSettingsModel;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListBotRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsers;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.bot.BotInfoPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.bot.BotManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.langs.Lang;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class SelectBotScreen extends BaseScreen {
		private var topBar:TopBarScreen;
		
		private var list:List;
		private var addBotRequestId:String;
		private var createdChatUID:String;
		private var chatModel:ChatVO;
		private var screenLocked:Boolean;
		
		public function SelectBotScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = 'Select contacts screen';
			_params.doDisposeAfterClose = true;
			
			chatModel = data.chatModel;
			
			topBar.setData(getScreenTitle(), true);
			
			BotManager.S_BOTS.add(onBotsLoaded);
			setListData();
		}
		
		private function setListData():void {
			var contacts:Array = BotManager.getAllBots(false);
			
			var usersToAdd:Array = new Array();
			
			var existingUsers:Vector.<ChatUserVO> = chatModel.users;
			
			var listItemModel:ChatUserlistModel;
			
			var existInChat:Boolean;
			if (contacts != null)
			{
				for (var i:int = 0; i < contacts.length; i++) {
					existInChat = false;
					if (existingUsers)
					{
						var usersInChatNum:int = existingUsers.length;
						
						for (var j:int = 0; j < usersInChatNum; j++) 
						{
							if (("uid" in contacts[i]) && existingUsers[j].uid == contacts[i].uid)
							{
								existInChat = true;
							}
						}
					}
					
					if (!existInChat)
					{
					//	listItemModel = new ChatUserlistModel();
					//	listItemModel.contact = contacts[i] as UserVO;
					//	listItemModel.status = UserStatusType.UNSELECTED;
						usersToAdd.push(contacts[i]);
					}
				}
			}
			
		//	list.setData(usersToAdd, ListChatUsers, ["avatarURL"]);
			list.setData(usersToAdd, ListBotRenderer, ["avatarURL"]);
		}
		
		override protected function createView():void {
			super.createView();
			
			list = new List("SelectContactsScreen.list");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.setMask(true);
			list.background = true;
			_view.addChild(list.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
		}
		
		private function addBot(bot:BotVO):void {
			lockScreen();
			
			if (chatModel != null) {
				addBotRequestId = MD5.hash(getTimer().toString());
				
				if (chatModel.type == ChatRoomType.CHANNEL) {
					BotManager.S_BOT_ADDED_TO_CHAT.add(onBotAddedToChannel);
					BotManager.addBotToChannel(chatModel.uid, bot.uid, addBotRequestId);
				}
				else {
					ChatManager.S_USER_ADDED_TO_CHAT.add(onUsersAdded);
					ChatManager.addUsersToChat(chatModel.uid, [bot.uid], addBotRequestId);
				}
			}
			else {
				ApplicationErrors.add("empty data");
			}
		}
		
		private function onBotAddedToChannel(response:Object):void {
			unlockScreen();
			if (response.requestId == addBotRequestId) {
				addBotRequestId = null;
				
				if (response.success == true) {
					ToastMessage.display(Lang.botAdded);
					onBack();
				} else {
					ToastMessage.display(Lang.cantAddUsersToChat);
				}
			}
		}
		
		private function lockScreen():void {
			screenLocked = true;
			list.deactivate();
		}
		
		private function isAddToExistingChat():Boolean {
			return data.data != null;
		}
		
		private function onUsersAdded(responseData:Object):void {
			if (responseData.requestId != addBotRequestId)
				return;
			ChatManager.S_USER_ADDED_TO_CHAT.remove(onUsersAdded);
			if (isDisposed)
				return;
			if (isActivated)
				unlockScreen();
			
			addBotRequestId = null;
			
			if (responseData.success) {
				if ("newChat" in responseData && responseData.newChat) {
					createdChatUID = responseData.chatUID;
					if (data.backScreen != undefined && data.backScreen != null && data.backScreen == ChatSettingsScreen && data.backScreenData != null) {
						ChatManager.getChatSettingsModel(createdChatUID, onChatSettingsReady);
						return;
					}
				}
			}
			onBack();
		}
		
		private function onChatSettingsReady(chatSettings:ChatSettingsModel):void {
			if (data.backScreen != undefined && data.backScreen != null && data.backScreen == ChatSettingsScreen && data.backScreenData != null) {
				if (data.backScreenData.backScreen == ChatScreen && data.backScreenData.backScreenData != null && data.backScreenData.backScreenData is ChatScreenData) {
					var chatScreenData:ChatScreenData = data.backScreenData.backScreenData as ChatScreenData;
					chatScreenData.chatUID = createdChatUID;
					chatScreenData.type = ChatInitType.CHAT;
					chatScreenData.settings = chatSettings;
					chatScreenData.chatVO = ChatManager.getChatByUID(createdChatUID);
				}
				
				data.backScreenData.data = { };
				data.backScreenData.data.chatId = createdChatUID;
				data.backScreenData.data.chatSettings = chatSettings;
			}
			
			onBack();
		}
		
		private function unlockScreen():void {
			if (list != null) {
				list.activate();
			}
		}
		
		override protected function drawView():void {
			topBar.drawView(_width);
			
			list.view.y = topBar.trueHeight;
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
		}
		
		private function getScreenTitle():String {
			if (data !=null && data.title != null)
				return data.title;
			return Lang.addBot;
		}
		
		private function onItemTap(data:Object, n:int):void {
			
			var item:ListItem;
			if (data is BotVO) {
				
				item = list.getItemByNum(n);
				var itemHitZone:String;
				if (item != null)
					itemHitZone = item.getLastHitZone();
					
				if (itemHitZone == HitZoneType.BOT_INFO) {
					DialogManager.showDialog(BotInfoPopup, data);
					return;
				}
				
				addBot(data as BotVO);
			}
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (list != null)
				list.dispose();
			list = null;
			
			BotManager.S_BOTS.remove(onBotsLoaded);
			ChatManager.S_USER_ADDED_TO_CHAT.remove(onUsersAdded);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			
			if (topBar != null)
				topBar.activate();
			
			if (screenLocked == true) {
				return;
			}
			
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
		}
		
		private function onBotsLoaded():void {
			setListData();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
				
			if (topBar != null)
				topBar.deactivate();		

			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
		}
	}
}