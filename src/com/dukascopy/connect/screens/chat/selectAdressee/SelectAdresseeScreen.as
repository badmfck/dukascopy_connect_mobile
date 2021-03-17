package com.dukascopy.connect.screens.chat.selectAdressee {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.RectangleButton;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.chat.selectAdressee.ListChatsItemModel;
	import com.dukascopy.connect.screens.chat.selectAdressee.ListUsersItemModel;
	import com.dukascopy.connect.screens.chat.selectAdressee.SelectAresseeScreenDataVO;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.ForwardingManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import flash.events.Event;
	
	/**
	 *	@author David Gnatkivskij. Telefision TEAM Kiev.
	 * 
	 * screen to select multiple chats or users
	 * In the future may replace SelectContactsScreen
	 */
	
	public class SelectAdresseeScreen extends BaseScreen {
		
		private const selectContactsTabID:String = "selectContacts";
		private const selectChatTabID:String = "selectChat";
		
		private var topBar:TopBarScreen;
		private var tabs:FilterTabs;
		private var list:List;
		private var addButton:RectangleButton;
		
		private var addUsersRequestId:String;
		
		private var usersToShow:Vector.<IContactsChatsSelectionListItem>;
		private var chatsToShow:Vector.<IContactsChatsSelectionListItem>;
		
		private var dataVO:SelectAresseeScreenDataVO;
		
		private var selectedFilter:String = selectChatTabID;
		
		public function SelectAdresseeScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			tabs = new FilterTabs();
			tabs.add(Lang.textChats, selectChatTabID, true, "l");
			tabs.add(Lang.textContacts, selectContactsTabID, false, "r");
			_view.addChild(tabs.view);
			
			list = new List("SelectAdresseeScreen.contactsList");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.setMask(true);
			list.background = true;
			_view.addChild(list.view);
			
			updateDisplayingList();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if (data == null)
				return;
			topBar.setData(getScreenTitle(), true);
			dataVO = _data as SelectAresseeScreenDataVO;
 			_params.title = 'Select adressee screen';
			_params.doDisposeAfterClose = true;
			if (dataVO.selectAdresseeType == SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_BOTH || dataVO.selectAdresseeType == SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_CONTACTS) {
				PhonebookManager.S_PHONES.add(onLoaded);
				PhonebookManager.getPhones();
			}
			if (dataVO.selectAdresseeType == SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_BOTH || dataVO.selectAdresseeType == SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_CONTACTS) {
				ChatManager.S_LATEST.add(onLoaded);
				//ChatManager.getLatest();
				ChatManager.getChats();
			}
			if (dataVO.selectAdresseeType != SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_BOTH) {
				switch(dataVO.selectAdresseeType) {
					case SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_CONTACTS:
						selectedFilter = selectContactsTabID;
						break;
					case SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_CHATS:
						selectedFilter = selectChatTabID;
						break;
					default:
						break;
				}
			}
			if (dataVO.isSelectSingleAdressee == false) {
				addButton = new RectangleButton(Lang.textOk, AppTheme.RED_MEDIUM);
				addButton.setStandartButtonParams();
				addButton.setDownScale(1);
				addButton.setDownColor(0);
				addButton.tapCallback =  onFinishSelection;
				addButton.disposeBitmapOnDestroy = true;
				addButton.show();
				_view.addChild(addButton);
			}
			updateLists();
			updateDisplayingList();
		}
		
		override protected function drawView():void {
			var isShowTabs:Boolean = true;
			if (dataVO != null) {
				if (dataVO.selectAdresseeType != SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_BOTH)
					isShowTabs = false;
			}
			var currentYDrawPosition:int = 0;
			topBar.drawView(_width);
			
			
			var listPositionY:int;
			var listHeight:int;
			var addButtonHeight:int = 0;
			if (dataVO.isSelectSingleAdressee == true) {
				if (addButton != null) {
					if (addButton.parent == view)
						view.removeChild(addButton);
				}
			} else {
				addButton.setWidth(_width);
				addButton.y = _height - addButton.getHeight();
				view.addChild(addButton);
				addButtonHeight = addButton.getHeight();
			}
			if (isShowTabs == true) {
				_view.addChild(tabs.view);
				tabs.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
				tabs.view.y = topBar.trueHeight;
				listPositionY = tabs.view.y + tabs.view.height;
				listHeight = _height - topBar.trueHeight - addButtonHeight - tabs.view.height;
			} else {
				if (tabs.view.parent == view)
					view.removeChild(tabs.view);
				listPositionY =  topBar.trueHeight;
				listHeight = _height - topBar.trueHeight - addButtonHeight;
			}
			
			list.view.y = listPositionY;
			list.setWidthAndHeight(_width, listHeight);
			
			initScreen();
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			if (topBar != null)
				topBar.activate();
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			if (addButton != null)
				addButton.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (topBar != null)
				topBar.deactivate();
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (addButton != null)
				addButton.deactivate();
		}
		
		override public function onBack(e:Event = null):void {
			ForwardingManager.clearForwardingMessage();
			if (dataVO.backScreen != null) {
				if (dataVO.backScreen != ChatScreen) {
					MobileGui.changeMainScreen(dataVO.backScreen, dataVO.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
					return;
				} else {
					var chatScreenData:ChatScreenData = new ChatScreenData();
					chatScreenData.chatUID = dataVO.backScreenData as String;
					chatScreenData.type = ChatInitType.CHAT;
					MobileGui.showChatScreen(chatScreenData);
					return;
				}
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override public function clearView():void {
			super.clearView();
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			if (list != null)
				list.dispose();
			list = null;
			if (addButton != null)
				addButton.dispose();
			addButton = null;
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			if (dataVO != null)
				dataVO.dispose();
			PhonebookManager.S_PHONES.remove(onLoaded);
			ChatManager.S_LATEST.remove(onLoaded);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			
			var curr:IContactsChatsSelectionListItem;
			if (usersToShow != null)
				for each (curr in usersToShow)
					curr.dispose();
			usersToShow = null;
			if (chatsToShow != null)
				for each (curr in chatsToShow)
					curr.dispose();
			chatsToShow = null;
		}
		
		private function getScreenTitle():String {
			if (dataVO != null && dataVO.title)
				return dataVO.title;
			return Lang.selectUsers;
		}
		
		private function onFinishSelection():void {
			var selectedUsersUids:Vector.<String> = new Vector.<String>();
			var selectedChatIds:Vector.<String> = new Vector.<String>();
			var currUID:String;
			var currListUserItemModel:ListUsersItemModel;
			var currListChatItemModel:ListChatsItemModel;
			
			if (usersToShow != null) {
				for each(currListUserItemModel in usersToShow) {
					if (currListUserItemModel.status == UserStatusType.SELECTED) {
						currUID = currListUserItemModel.contact.uid;
						if (currUID != null && currUID != "") {
							selectedUsersUids.push(currUID);
						}
					}
				}
			}
			if (chatsToShow != null) {
				for each(currListChatItemModel in chatsToShow) {
					if (currListChatItemModel.status == UserStatusType.SELECTED) {
						currUID = currListChatItemModel.chatVO.uid;
						if (currUID != null && currUID != "") {
							selectedChatIds.push(currUID);
						}
					}
				}
			}
			
			var res:SelectAdresseeResultVO = new SelectAdresseeResultVO(selectedUsersUids, selectedChatIds);
			
			if (res.isAnyAdresseeSelected == true)
				dataVO.executeCallback(res);
			else
				onBack();
		}
		
		private function showChatsList():void {
			list.setData(chatsToShow, ListItemSelectableChatsOrContacts);
		}
		
		private function showUsersList():void {
			list.setData(usersToShow, ListItemSelectableChatsOrContacts);
		}
		
		private function onTabItemSelected(id:String):void {
			selectedFilter = id;
			updateDisplayingList();
		}
		
		private function onItemTap(data:Object, n:int):void {
			var typizedData:IContactsChatsSelectionListItem = data as IContactsChatsSelectionListItem;
			typizedData.status = (typizedData.status == UserStatusType.SELECTED)?UserStatusType.UNSELECTED:UserStatusType.SELECTED;
			if (dataVO.isSelectSingleAdressee == false)
				list.updateItemByIndex(n);
			if (dataVO.isSelectSingleAdressee == true)
				onFinishSelection();
		}
		
		private function updateDisplayingList():void {
			switch (selectedFilter) {
				case selectChatTabID:
					showChatsList();
					break;
				case selectContactsTabID:
					showUsersList();
					break;
				default:
					break;
			}
		}
	
		private function onLoaded():void {
			updateLists();
			updateDisplayingList();
		}
	
		private function updateLists():void {
			setContactsListData();
			setChatListData();
		}
	
		private function setChatListData():void {
			if (dataVO.selectAdresseeType != SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_BOTH && dataVO.selectAdresseeType != SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_CHATS) {
				return;
			}
			var allChats:Array = ChatManager.allChats;
			var channels:Array = ChannelsManager.allChannels;
			if (allChats != null && channels != null)
			{
				allChats = allChats.concat(channels);
			}
			if (allChats == null)
				return;
			chatsToShow = new Vector.<IContactsChatsSelectionListItem>();
			
			var isIgnoreCurrentChat:Boolean;
			var currentChatListElementModel:ListChatsItemModel;
			for each (var currChatVO:ChatVO in allChats) {
				isIgnoreCurrentChat = false;
				if (dataVO.ignoringChatIDs == true) {
					for each (var currIgnoringChatID:String in dataVO.ignoringChatIDs) {
						if (currChatVO.uid == currIgnoringChatID) {
							isIgnoreCurrentChat = true;
							break;
						}
					}
				}
				if (!isIgnoreCurrentChat == true) {
					currentChatListElementModel = new ListChatsItemModel(currChatVO,false);
					chatsToShow.push(currentChatListElementModel)
				}
			}			
		}
	
		private function setContactsListData():void {
			if (dataVO.selectAdresseeType != SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_BOTH && dataVO.selectAdresseeType != SelectAresseeScreenDataVO.SELECT_ADRESSEE_TYPE_CONTACTS) {
				return;
			}
			usersToShow = new Vector.<IContactsChatsSelectionListItem>();
			var contacts:Array = PhonebookManager.getConnectContacts();	
			var isIgnoreCurrentUser:Boolean;
			var listItemModel:ListUsersItemModel;
				
			for each(var currContact:Object in contacts) {
				isIgnoreCurrentUser = false;
				if (dataVO.ignoringUserIDs !=null) {
					for each(var currIgnoringUserID:String in dataVO.ignoringUserIDs) {
						if ("uid" in currContact && currIgnoringUserID == currContact.uid) {
							isIgnoreCurrentUser = true;
							break;
						}
					}
				}
				if (!isIgnoreCurrentUser && (currContact is ContactVO || currContact is PhonebookUserVO)) {
					listItemModel = new ListUsersItemModel(currContact, false);
					listItemModel.status = UserStatusType.UNSELECTED;
					usersToShow.push(listItemModel);
				}
			}
			list.setData(usersToShow, ListItemSelectableChatsOrContacts);
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus):void  {
			//!TODO: possible massive refresh calls due to change online status in many models at one time;
			//!TODO: its maybe overload to refresh list in case of one item olnine status changed;
			if (list != null)
				list.refresh();
		}
	}
}