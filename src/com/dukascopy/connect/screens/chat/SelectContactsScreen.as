package com.dukascopy.connect.screens.chat {
	
	import com.adobe.crypto.MD5;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ChatSettingsModel;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.RectangleButton;
	import com.dukascopy.connect.gui.input.SearchBar;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsersSelect;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class SelectContactsScreen extends BaseScreen {
		private var topBar:TopBarScreen;
		
		private var list:List;
		private var usersToAdd:Array;
		private var addButton:BitmapButton;
		private var addUsersRequestId:String;
		private var createdChatUID:String;
		
		public function SelectContactsScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = 'Select contacts screen';
			_params.doDisposeAfterClose = true;
			
			drawButton(Lang.textProceed);
			
			PhonebookManager.S_PHONES.add(onPhonesLoaded);
			PhonebookManager.getPhones();
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
			topBar.setData(getScreenTitle(), true);
			topBar.addSearch();
			setListData();
		}
		
		private function setListData():void {
			var contacts:Array = PhonebookManager.getConnectContacts(true);
			
			usersToAdd = new Array();
			
			var existingUsers:Vector.<ChatUserVO> = getChatUsers(data.data as String);
			
			var listItemModel:ChatUserlistModel;
			var contsctsNum:int = contacts.length;
			
			var existInChat:Boolean;
			
			for (var i:int = 0; i < contsctsNum; i++) 
			{
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
				
				if (!existInChat && (contacts[i] is ContactVO || contacts[i] is PhonebookUserVO)  && contacts[i].uid != "" && contacts[i].uid != Config.NOTEBOOK_USER_UID && "userVO" in contacts[i])
				{
					listItemModel = new ChatUserlistModel();
					listItemModel.contact = contacts[i].userVO;
					listItemModel.status = UserStatusType.UNSELECTED;
					usersToAdd.push(listItemModel);
				}
			}
			
			displayUserlist(usersToAdd);
		}
		
		private function displayUserlist(users:Array):void 
		{
			list.setData(users, ListChatUsersSelect);
		}
		
		private function getChatUsers(chatUID:String):Vector.<ChatUserVO> {
			var chatModel:ChatVO;
			if (chatUID)
			{
				chatModel = ChatManager.getChatByUID(chatUID);
			}
			
			if (chatModel)
			{
				return chatModel.users;
			}
			return null;
		}
		
		override protected function createView():void {
			super.createView();
			
			list = new List("SelectContactsScreen.list");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.setMask(true);
			list.background = true;
			_view.addChild(list.view);
			
			addButton = new BitmapButton();
			addButton.setStandartButtonParams();
			addButton.tapCallback = addUsers;
			addButton.disposeBitmapOnDestroy = true;
			addButton.setDownScale(1);
			addButton.setOverlay(HitZoneType.BUTTON);
			view.addChild(addButton);
			addButton.show();
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
		}
		
		private function drawButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, _width - Config.DIALOG_MARGIN * 2, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			addButton.setBitmapData(buttonBitmap, true);
			addButton.y = _height - Config.APPLE_BOTTOM_OFFSET - addButton.height - Config.DIALOG_MARGIN;
			addButton.x = (_width * .5 - addButton.width * .5);
		}
		
		private function addUsers():void {
			var usersIdToAdd:Array = new Array();
			
			if (usersToAdd.length == 0)
				return;
			
			var userListNum:int = usersToAdd.length;
			for (var i:int = 0; i < userListNum; i++)
				if ((usersToAdd[i] as ChatUserlistModel).status == UserStatusType.SELECTED)
					usersIdToAdd.push((usersToAdd[i] as ChatUserlistModel).contact.uid);
			if (usersIdToAdd.length > 0) {
				lockScreen();
				ChatManager.S_USER_ADDED_TO_CHAT.add(onUsersAdded);
				addUsersRequestId = MD5.hash(getTimer().toString());
				if (isAddToExistingChat())
					ChatManager.addUsersToChat(data.data.toString(), usersIdToAdd, addUsersRequestId);
				else {
					var chatScreenModel:ChatScreenData = new ChatScreenData();
							chatScreenModel.usersUIDs = usersIdToAdd;
							chatScreenModel.type = ChatInitType.USERS_IDS;
					MobileGui.showChatScreen(chatScreenModel);
				}
			}
		}
		
		private function isAddToExistingChat():Boolean {
			return data.data != null;
		}
		
		private function lockScreen():void {
			addButton.deactivate();
			list.deactivate();
		}
		
		private function onUsersAdded(responseData:Object):void {
			if (responseData.requestId != addUsersRequestId)
				return;
			ChatManager.S_USER_ADDED_TO_CHAT.remove(onUsersAdded);
			if (isDisposed)
				return;
			if (isActivated)
				unlockScreen();
			
			addUsersRequestId = null;
			
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
			addButton.activate();
			list.activate();
		}
		
		override protected function drawView():void {
			topBar.drawView(_width);
			
			list.view.y = topBar.trueHeight;
			list.setWidthAndHeight(_width, addButton.y - topBar.trueHeight - Config.DIALOG_MARGIN);
		}
		
		private function getScreenTitle():String {
			if (data !=null && data.title != null)
				return data.title;
			return Lang.selectUsers;
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (data is ChatUserlistModel){
				(data as ChatUserlistModel).status = ((data as ChatUserlistModel).status == UserStatusType.SELECTED)?UserStatusType.UNSELECTED:UserStatusType.SELECTED;
				list.updateItemByIndex(n);
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
			
			if (addButton != null) 
				addButton.dispose();
			addButton = null;
			
			if (list != null)
				list.dispose();
			list = null;
			ChatManager.S_USER_ADDED_TO_CHAT.remove(onUsersAdded);
			PhonebookManager.S_PHONES.remove(onPhonesLoaded);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			
			usersToAdd = null;
		}
		
		private function onUserlistOnlineStatusChanged():void {
			if (list)
			{
				list.refresh();
			}
		}
		
		private function onAllUsersOffline():void {
			if (list)
			{
				list.refresh();
			}
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void {
			if (isDisposed || list == null)
			{
				return;
			}
			
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS)
			{
				var item:ListItem;
				var itemData:ChatUserlistModel;
				var l:int = list.getStock().length;
				
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) 
				{
					item = list.getItemByNum(j);
					if (item && item.liView && item.liView.visible)
					{
						if (item.data is ChatUserlistModel)
						{
							itemData = item.data as ChatUserlistModel;
							if (itemData.contact && itemData.contact.uid == status.uid)
							{
								if (list.getScrolling())
								{
									list.refresh();
								}
								else
								{
									item.draw(list.width, !list.getScrolling());
								}
								break;
							}
						}
					}
					else
					{
						break;
					}
				}
				itemData = null;
				item = null;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
				
			if (topBar != null)
				topBar.activate();
			
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			addButton.activate();
			SearchBar.S_CHANGED.add(onSearchContact);
		}
		
		private function onSearchContact(searchBar:SearchBar):void {
			
			if (searchBar.text.length > 2) {
				var filteredList:Array = PhonebookManager.filterByName(usersToAdd, StringUtil.trim(searchBar.text));
				
				displayUserlist(filteredList);
			}
			else if (searchBar.text == "")
			{
				displayUserlist(usersToAdd);
			}
		}
		
		private function onPhonesLoaded():void {
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
			addButton.deactivate();
			SearchBar.S_CHANGED.remove(onSearchContact);
		}
	}
}