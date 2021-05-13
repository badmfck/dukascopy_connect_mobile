package com.dukascopy.connect.screens.serviceScreen {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsers;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.screens.dialogs.bottom.SearchListSelectionPopup;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class SelectContactExtendedScreen extends SearchListSelectionPopup {
		
		private var users:Array;
		
		public function SelectContactExtendedScreen() { }

		override public function initScreen(data:Object = null):void {
			super.initScreen(data);

			PhonebookManager.S_PHONES.add(onPhonesLoaded);
			PhonebookManager.getPhones();
		}

		override public function dispose():void {
			super.dispose();
			
			ChatManager.S_LATEST.remove(onLatestLoaded);
			PhonebookManager.S_PHONES.remove(onPhonesLoaded);

			clearUsers();
		}
		
		override protected function getSelectedData(item:Object):Object
		{
			if (item is ChatUserlistModel)
			{
				return (item as ChatUserlistModel).contact;
			}
			else if (item is ChatVO && (item as ChatVO).users != null && (item as ChatVO).users.length > 0)
			{
				return (item as ChatVO).users[0].userVO;
			}

			return item;
		}

		override protected function getHeight():int
		{
			return _height - Config.FINGER_SIZE * .5;
		}
		
		private function onLatestLoaded():void {
			var privateData:Array = ChatManager.getLatestChatsAndDatesFilter(ChatRoomType.PRIVATE);
			if (privateData == null)
				return;
			var chats:Array = new Array();
			var chatsLength:int = privateData.length;
			var user:UserVO;
			for (var k:int = 0; k < chatsLength; k++) 
			{
				if (privateData[k].users != null && privateData[k].users.length > 0)
				{
					user = privateData[k].users[0].userVO;
					if (!(user is BotVO) && user.uid != Config.NOTEBOOK_USER_UID)
					{
						chats.push(privateData[k]);
					}
				}
			}
			chatsLength = chats.length;
			
			list.setData(chats, ListConversation, ['avatarURL'], null);
			var l:int = users.length;
			
			
			for (var i:int = 0; i < l; i++) 
			{
				for (var j:int = 0; j < chatsLength; j++) 
				{
					if (chats[j].users != null && chats[j].users.length > 0)
					{
						user = chats[j].users[0].userVO;
						if (users[i] is ChatUserlistModel && user.uid == users[i].contact.uid)
						{
							continue;
						}
					}
				}
				list.appendItem(users[i], ListChatUsers, null, true);
			}
			updateListSize();
		}
		
		private function onPhonesLoaded():void {
			clearUsers();
			var oldDelimiter:String = "";
			var newDelimiter:String = "";
			var cData:Array = PhonebookManager.getConnectContacts(true, true);
			cData.sort(sortUsers);
			var cDataNew:Array = [];
			var listItemModel:ChatUserlistModel;
			var contactsNum:int = cData.length;
			for (var i:int = 0; i < contactsNum; i++) {
				newDelimiter = String(cData[i].userVO.getDisplayName()).substr(0, 1).toUpperCase();
				if (newDelimiter != oldDelimiter) {
					oldDelimiter = newDelimiter;
					cDataNew.push([oldDelimiter.toLowerCase(), oldDelimiter]);
				}
				listItemModel = new ChatUserlistModel();
				listItemModel.contact = cData[i].userVO;
				listItemModel.status = UserStatusType.UNSELECTED;
				cDataNew.push(listItemModel);
			}
			users = cDataNew;
		//	list.setData(users, ListChatUsers);
			cDataNew = null;
			cData = null;
			
			ChatManager.S_LATEST.add(onLatestLoaded);
			ChatManager.getChats();
		}
		
		private function clearUsers():void {
			if (users == null)
				return;
			var count:int = users.length;
			for (var i:int = 0; i < count; i++) {
				if (users[i] is ChatUserlistModel)
					users[i].dispose();
			}
			users = null;
		}
		
		private function sortUsers(a:Object, b:Object):int {
			if (a.userVO.getDisplayName() < b.userVO.getDisplayName())
				return -1;
			else if (a.userVO.getDisplayName() > b.userVO.getDisplayName())
				return 1;
			return 0;
		}
		
		override protected function doSearch(value:String = ""):void {
			if (list == null)
				return;
			var data:Array = list.data as Array;
			if (data == null || value == null)
				return;
			
			var contact:UserVO;
			for (var i:int = 0; i < data.length; i++) {
				if (data[i] is Array) {
					if(data[i][0].indexOf(value.toLowerCase()) == 0) {
						list.navigateToItem(i);
						return;
					}
					continue;
				}
				else if (data[i] is ChatVO)
				{
					if ((data[i] as ChatVO).users != null && (data[i] as ChatVO).users[0] != null)
					{
						contact = (data[i] as ChatVO).users[0].userVO;
						
						//trace(contact.getDisplayName(), contact.getDisplayName().indexOf(value.toLowerCase()));
						
						if (contact != null && contact.getDisplayName().toLowerCase().indexOf(value.toLowerCase()) == 0)
						{
							list.navigateToItem(i);
							return;
						}
					}
				}
				else if (data[i].contact.getDisplayName().toLowerCase().indexOf(value.toLowerCase()) == 0) {
					list.navigateToItem(i);
					return;
				}
			}
		}
	}
}