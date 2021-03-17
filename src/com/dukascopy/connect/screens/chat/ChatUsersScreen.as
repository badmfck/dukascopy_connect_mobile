package com.dukascopy.connect.screens.chat {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsers;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class ChatUsersScreen extends BaseScreen {
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var allUsers:Vector.<ChatUserVO>;
		private var chatUid:String;
		
		public function ChatUsersScreen() { }
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarScreen();
			
			list = new List("ChatUsersScreen.list");
			list.setContextAvaliable(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			list.view.y = topBar.trueHeight;
			_view.addChild(list.view);
			_view.addChild(topBar);
		}
		
		override protected function drawView():void { topBar.drawView(_width); }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(Lang.usersList, true);
			_params.title = 'Chat users screen';
			_params.doDisposeAfterClose = true;
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
			
			if (data != null && ("data" in data) && data.data != null) {
				if (("users" in data.data && (data.data.users is Vector.<ChatUserVO>))) {
					allUsers = data.data.users;
				}
				if (("chatUid" in data.data)) {
					chatUid = data.data.chatUid;
				}
			}
			ChatManager.S_USER_REMOVED_FROM_CHAT.add(onUserRemoved);
			ChatManager.S_CHAT_USERS_CHANGED.add(onChatUsersChanged);
			setListData();
		}
		
		private function onChatUsersChanged(chatUID:String):void 
		{
			if (chatUid != null && chatUID != null && chatUid == chatUID)
			{
				updateList();
			}
		}
		
		private function onUserRemoved(result:Object):void 
		{
			if (result != null && "chatUID" in result && result.chatUID == chatUid)
			{
				if ("success" in result && result.success == true)
				{
					updateList();
				}
			}
		}
		
		private function updateList():void 
		{
			if (isDisposed)
			{
				return;
			}
			setListData();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			if (topBar != null)
				topBar.activate();
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (topBar != null)
				topBar.deactivate();		
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
		}
		
		override public function dispose():void {
			super.dispose();
			if (topBar != null)
				topBar.dispose();
			topBar = null;

			if (list != null)
				list.dispose();
			list = null;
			
			allUsers = null;
			chatUid = null;
			
			ChatManager.S_USER_REMOVED_FROM_CHAT.remove(onUserRemoved);
		}
		
		private function setListData():void {
			var usersArray:Array = new Array();
			var blockedUsers:Array = new Array();
			
			if (allUsers == null)
			{
				return;
			}
			
			var chatUsersOverallNum:int = allUsers.length;
			var blocked:Boolean
			var blockedUsersIds:Array = Auth.blocked;
			var blockedNum:int = blockedUsersIds.length;
			
			var chatContactModel:ChatUserlistModel;
			
			for (var i:int = 0; i < chatUsersOverallNum; i++) {
				blocked = false;
				for (var j:int = 0; j < blockedNum; j++) {
					if (allUsers[i].uid == blockedUsersIds[j]) {
						blocked = true;
						break;
					}
				}
				//можно заменить
				chatContactModel = new ChatUserlistModel();
				chatContactModel.chatUid = chatUid;
				if (!blocked) {
					chatContactModel.status = UserStatusType.REGULAR;
					chatContactModel.statusText = "";
					chatContactModel.contact = allUsers[i].userVO;
					usersArray.push(chatContactModel);
				} else {
					chatContactModel.status = UserStatusType.BLOCKED;
					chatContactModel.statusText = Lang.textBlocked;
					chatContactModel.contact = allUsers[i].userVO;
					blockedUsers.push(chatContactModel);
				}
			}
			var resultArray:Array = new Array(); 
			if (usersArray.length > 0) {
				resultArray.push(usersArray.length + " " + Lang.usersInChat);
				resultArray = resultArray.concat(usersArray);
			}
			if (blockedUsers.length > 0) {
				resultArray.push(blockedUsers.length + " " + Lang.blockedUsers);
				resultArray = resultArray.concat(blockedUsers);
			}
			list.setData(resultArray, ListChatUsers);
		}
		
		private function onItemTap(data:Object, n:int):void {
			
			if (data == null || (data is ChatUserlistModel) == false)
				return;
			
			var user:ChatUserlistModel = data as ChatUserlistModel;
			
			if (user.contact == null || user.contact.uid == Auth.uid)
				return;
			
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			if (item)
				itemHitZone = item.getLastHitZone();
			if (itemHitZone) {
				if (itemHitZone == HitZoneType.DELETE) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmRemoveUser, function(val:int):void {
						if (val != 1)
							return;
						ChatManager.removeUser(user.chatUid, user.contact.uid);
					}, Lang.removeUser.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
			}
			
			if (user.contact.type != UserType.BOT) {
				MobileGui.changeMainScreen(UserProfileScreen, { data:user.contact, 
																backScreen:MobileGui.centerScreen.currentScreenClass, 
																backScreenData:this.data
				} );
			}
		}
		
		private function onUserlistOnlineStatusChanged():void {
			if (list)
				list.refresh();
		}
		
		private function onAllUsersOffline():void {
			if (list)
				list.refresh();
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void {
			if (isDisposed || list == null)
				return;
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS) {
				var item:ListItem;
				var l:int = list.getStock().length;
				var itemData:ChatUserlistModel;
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) {
					item = list.getItemByNum(j);
					if (item && item.liView && item.liView.visible) {
						if (item.data is ChatUserlistModel) {
							itemData = item.data as ChatUserlistModel;
							if (itemData.contact && itemData.contact.uid == status.uid) {
								if (list.getScrolling())
									list.refresh();
								else
									item.draw(list.width, !list.getScrolling());
								break;
							}
						}
					}
					else
						break;
				}
				itemData = null;
				item = null;
			}
		}
	}
}