package com.dukascopy.connect.screens.chat {
	
		import assets.DeleteIcon;
		import assets.KickIcon;
		import assets.ModeratorIcon;
		import assets.ModeretorRemoveIcon;
		import com.dukascopy.connect.Config;
		import com.dukascopy.connect.MobileGui;
		import com.dukascopy.connect.data.TextFieldSettings;
		import com.dukascopy.connect.data.UserBanData;
		import com.dukascopy.connect.data.UserPopupData;
		import com.dukascopy.connect.gui.lightbox.UI;
		import com.dukascopy.connect.gui.list.List;
		import com.dukascopy.connect.gui.list.ListItem;
		import com.dukascopy.connect.gui.list.renderers.ChannelBannedUserListRenderer;
		import com.dukascopy.connect.gui.list.renderers.ChannelUserListRenderer;
		import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
		import com.dukascopy.connect.gui.menuVideo.BitmapButton;
		import com.dukascopy.connect.gui.tabs.FilterTabs;
		import com.dukascopy.connect.gui.topBar.TopBarScreen;
		import com.dukascopy.connect.screens.ChatScreen;
		import com.dukascopy.connect.screens.RootScreen;
		import com.dukascopy.connect.screens.UserProfileScreen;
		import com.dukascopy.connect.screens.base.BaseScreen;
		import com.dukascopy.connect.screens.base.ScreenManager;
		import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
		import com.dukascopy.connect.screens.dialogs.userPopup.BanUserPopup;
		import com.dukascopy.connect.screens.dialogs.userPopup.KickUserPopup;
		import com.dukascopy.connect.screens.dialogs.userPopup.RemoveModeratorUserPopup;
		import com.dukascopy.connect.screens.dialogs.userPopup.SetModeratorUserPopup;
		import com.dukascopy.connect.screens.dialogs.userPopup.UnbanUserPopup;
		import com.dukascopy.connect.screens.dialogs.userPopup.UserPopup;
		import com.dukascopy.connect.sys.auth.Auth;
		import com.dukascopy.connect.sys.bot.BotManager;
		import com.dukascopy.connect.sys.chatManager.ChatManager;
		import com.dukascopy.connect.sys.chatManager.ChatUsersCollection;
		import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
		import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
		import com.dukascopy.connect.sys.dialogManager.DialogManager;
		import com.dukascopy.connect.sys.echo.echo;
		import com.dukascopy.connect.sys.style.Style;
		import com.dukascopy.connect.sys.theme.AppTheme;
		import com.dukascopy.connect.sys.usersManager.OnlineStatus;
		import com.dukascopy.connect.sys.usersManager.UsersManager;
		import com.dukascopy.connect.type.HitZoneType;
		import com.dukascopy.connect.type.UserType;
		import com.dukascopy.connect.vo.ChatVO;
		import com.dukascopy.connect.vo.users.adds.ChatUserVO;
		import com.dukascopy.langs.Lang;
		import flash.display.Sprite;
		import flash.events.Event;
		import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class ChannelInfoModeratorScreen extends BaseScreen
	{
		private var topBar:TopBarScreen;

		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private var iconSize:Number;
		private var iconArrowSize:Number;
		private var buttonPaddingLeft:int;
		private var FIT_WIDTH:int;
		private var headerSize:int;
		private var backgroundIconHeight:Number;
		private var chatModel:ChatVO;
		private var settingsTextPosition:int;
		private var settingsIconPosition:int;
		private var uid:String;
		
		private var mainBack:Sprite;
		private var tabs:FilterTabs;
		private var list:List;
		
		private static const IN_CHAT:String = "In chat";
		private static const MODERATORS:String = "connect";
		private static const BANNED:String = "banned";
		
		private var onlineUsers:Array;
		private var moderatorsData:Array;
		private var banned:Array;
		
		private var selectedFilter:String;
		private var settingsButton:BitmapButton;
		
		public function ChannelInfoModeratorScreen()
		{
			
		}
		
		override public function initScreen(data:Object = null):void {
			if ("data" in data && "chatId" in data.data) {
				uid = data.data.chatId;
			}
			
			if (uid == null && ChatManager.getCurrentChat() != null) {
				uid = ChatManager.getCurrentChat().uid;
			}
				
			if (uid == null) {
				MobileGui.centerScreen.show(RootScreen);
				return;
			}
			
			selectedFilter = IN_CHAT;
			
			chatModel = ChannelsManager.getChannel(uid);
			
			if (chatModel == null) {
				chatModel = AnswersManager.getAnswer(uid);
			}
			
			if (chatModel == null) {
				chatModel = ChatManager.getChatByUID(uid);
			}
			
			if (chatModel == null) {
				onBack();
				return;
			}
			
			ChannelsManager.S_BANS_LIST_UPDATE.add(onBansListUpdated);
			ChannelsManager.S_CHANNEL_MODERATORS_UPDATED.add(onChannelChanged);
			ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.add(onChannelChanged);
			ChatUsersCollection.S_USERLIST_CHANGED.add(onlineUserlistChanged);
			
			super.initScreen(data);
			
			_params.title = 'Channel info moderator screen';
			_params.doDisposeAfterClose = true;
			
			
			var iconSize:int = Config.FINGER_SIZE * 0.4;
			backgroundIconHeight = Config.FINGER_SIZE * .5;
			settingsIconPosition = int(backgroundIconHeight * .5);
			settingsTextPosition = int(backgroundIconHeight + Config.MARGIN);
			FIT_WIDTH = _width - buttonPaddingLeft*2;
			
			var currentYDrawPosition:int = 0;
			
			
			var titleText:String;
			
			titleText = Lang.settings;
			
			topBar.setData(titleText, true);
			
			var position:int = topBar.trueHeight + Config.DOUBLE_MARGIN;
			
		//	if (chatModel.questionID == null || chatModel.questionID == "") {
				var icon:IconSettingsGrey = new IconSettingsGrey();
				UI.scaleToFit(icon, iconSize, iconSize);
				settingsButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																				FIT_WIDTH, 
																				OPTION_LINE_HEIGHT, 
																				new TextFieldSettings(Lang.channelSettings, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																				null,
																				null, 
																				settingsIconPosition, 
																				settingsTextPosition, 
																				icon, 
																				null), true);
				settingsButton.x = buttonPaddingLeft;
				settingsButton.y = position;
				UI.destroy(icon);
				icon = null;
				position += OPTION_LINE_HEIGHT + Config.MARGIN * .5;
		//	}
			
			
			tabs.view.y = position;
			tabs.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
			list.view.y = tabs.view.y + tabs.height;
			list.setWidthAndHeight(_width, _height - list.view.y);
			
			mainBack.width = _width;
			mainBack.height = _height;
			
			ChatManager.chatEnter(chatModel.uid);
		}
		
		private function onChannelChanged(eventType:String, channelUID:String):void 
		{
			if (channelUID != chatModel.uid)
			{
				return;
			}
			
			switch(eventType)
			{
				case ChannelsManager.EVENT_MODERATOR_ADDED:
				{
					moderatorsData = null;
					onlineUsers = null;
					setListData();
					break;
				}
				case ChannelsManager.EVENT_MODERATOR_REMOVED:
				{
					moderatorsData = null;
					onlineUsers = null;
					setListData();
					break;
				}
				case ChannelsManager.EVENT_ADDED_TO_MODERATORS:
				{
					
					break;
				}
				case ChannelsManager.EVENT_REMOVED_FROM_MODERATORS:
				{
					
					MobileGui.changeMainScreen(ChannelInfoScreen, { data:{ chatId:chatModel.uid, chatSettings:this.data.chatSettings },
															backScreen:ChatScreen,
															backScreenData:this.data.backScreenData },
															ScreenManager.DIRECTION_RIGHT_LEFT);
					
					break;
				}
				case ChannelsManager.EVENT_TITLE_CHANGED:
				{
					topBar.updateTitle(chatModel.title);
					break;
				}
			}
		}
		
		private function onBansListUpdated(channelUID:String, bans:Array = null):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (channelUID == chatModel.uid)
			{
				if (bans)
				{
					banned = bans;
					setListData();
				}
				else
				{
					banned = null;
					
					if (selectedFilter == BANNED)
					{
						setListData();
					}
				}
			}
		}
		
		private function onlineUserlistChanged():void 
		{
			onlineUsers = null;
			if (selectedFilter == IN_CHAT)
			{
				setListData();
			}
		}
		
		override public function onBack(e:Event = null):void{
			
			if (data && data.backScreen != undefined && data.backScreen != null) {
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function createView():void
		{
			super.createView();
			//size variables;
			
			mainBack = new Sprite();
			mainBack.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			mainBack.graphics.drawRect(0, 0, 10, 10);
			mainBack.graphics.endFill();
			_view.addChild(mainBack);
			
			headerSize = int(Config.FINGER_SIZE * .85);
			iconSize = Config.FINGER_SIZE * 0.4;
			iconArrowSize = Config.FINGER_SIZE * 0.30;
			buttonPaddingLeft = Config.MARGIN * 2;
			
			settingsButton = new BitmapButton();
			settingsButton.setStandartButtonParams();
			settingsButton.setDownScale(1);
			settingsButton.setDownColor(0xFFFFFF);
			settingsButton.tapCallback = showSettings;
			settingsButton.disposeBitmapOnDestroy = true;
			settingsButton.usePreventOnDown = false;
			settingsButton.cancelOnVerticalMovement = true;
			settingsButton.show();
			_view.addChild(settingsButton);
			
			list = new List("Contacts");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.setContextAvaliable(true);
			list.background = true;
			list.view.y = Config.FINGER_SIZE*1.2;
			_view.addChild(list.view);
			
			tabs = new FilterTabs();
			tabs.add(Lang.inChat, IN_CHAT, true, "l");
			tabs.add(Lang.textModerators, MODERATORS);
			tabs.add(Lang.textBanned, BANNED, false, "r");
			_view.addChild(tabs.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
		}
		
		private function showSettings():void 
		{
			MobileGui.changeMainScreen(ChannelSettingsScreen, { data:{ chatId:chatModel.uid, chatSettings:this.data.chatSettings },
															backScreen:ChannelInfoModeratorScreen,
															backScreenData:data },
															ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		private function changePushNotifications(value:Boolean):void 
		{
			ChatManager.changeChatPushNotificationsStatus(chatModel.uid, value);
		}
		
		override protected function drawView():void
		{
			topBar.drawView(_width);
		}
		
		private function onUserlistOnlineStatusChanged():void 
		{
			if (list)
			{
				list.refresh();
			}
		}
		
		private function onAllUsersOffline():void
		{
			if (list)
			{
				list.refresh();
			}
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void 
		{
			echo("ChannelInfoModeratorScreen", "onUserOnlineStatusChanged", "");
			
			if (isDisposed || list == null)
			{
				return;
			}
			
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS)
			{
				var item:ListItem;
				var itemData:ChatUserVO;
				var l:int = list.getStock().length;
				
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) 
				{
					item = list.getItemByNum(j);
					if (item && item.liView && item.liView.visible)
					{
						if (item.data is ChatUserVO)
						{
							itemData = item.data as ChatUserVO;
							
							if (itemData.uid == status.uid)
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
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			ChatManager.chatExit(chatModel.uid);
			chatModel = null;

			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (mainBack != null) 
				UI.destroy(mainBack);
			mainBack = null;
			
			if (settingsButton)
			{
				settingsButton.dispose()
				settingsButton = null;
			}
			
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (list != null)
				list.dispose();
			list = null;
			
			onlineUsers = null;
			moderatorsData = null;
			banned = null;
			
			ChatUsersCollection.S_USERLIST_CHANGED.remove(onlineUserlistChanged);
			ChannelsManager.S_BANS_LIST_UPDATE.remove(onBansListUpdated);
			ChannelsManager.S_CHANNEL_MODERATORS_UPDATED.remove(onChannelChanged);
			ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.remove(onChannelChanged);	
		}
		
		private function onItemHold(data:Object, n:int):void
		{
			if (!(data is ChatUserVO))
				return;
			var menuItems:Array = [];
			var userVO:ChatUserVO = data as ChatUserVO;
			
			if (userVO.uid == Auth.uid)
			{
				return;
			}
			
			if (userVO.isChatOwner())
			{
				return;
			}
			
			if (userVO.banned)
			{
				menuItems.push( { fullLink:Lang.removeBan, id:5, icon:DeleteIcon, userModel:userVO } );
			}
			else
			{
				if (userVO.isChatModerator())
				{
					menuItems.push( { fullLink:Lang.removeModerator, id:2, icon:ModeretorRemoveIcon, userModel:userVO } );
				}
				else
				{
					menuItems.push( { fullLink:Lang.textModerator, id:1, icon:ModeratorIcon, userModel:userVO } );
				}
				
				menuItems.push( { fullLink:Lang.textBan, id:3, icon:KickIcon, userModel:userVO } );
				menuItems.push( { fullLink:Lang.textKick, id:4, icon:DeleteIcon, userModel:userVO } );
			}
			
			
			DialogManager.showDialog(ScreenLinksDialog, {  callback:holdDialogResponse, data:menuItems, itemClass:ListLinkWithIcon, title:userVO.name, multilineTitle:true } );
		}
		
		private function holdDialogResponse(data:Object):void
		{
			if (data.userModel)
			{
				var userPopupData:UserPopupData = new UserPopupData();
				userPopupData.data = (data.userModel as ChatUserVO).userVO;
				
				if (data.id == 1)
				{					
					userPopupData.callback = onModeratorPopupResponse;
					DialogManager.showDialog(SetModeratorUserPopup, userPopupData);
				}
				if (data.id == 2)
				{
					userPopupData.callback = onModeratorRemovePopupResponse;
					DialogManager.showDialog(RemoveModeratorUserPopup, userPopupData);
				}
				if (data.id == 3)
				{
					userPopupData.resultData = new UserBanData();
					userPopupData.callback = onBanPopupResponse;
					DialogManager.showDialog(BanUserPopup, userPopupData);
				}
				if (data.id == 4)
				{
					userPopupData.callback = onKickPopupResponse;
					DialogManager.showDialog(KickUserPopup, userPopupData);
				}
				if (data.id == 4)
				{
					userPopupData.callback = onUnbanPopupResponse;
					DialogManager.showDialog(UnbanUserPopup, userPopupData);
				}
			}
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed)
				return;

			if (topBar != null)
				topBar.activate();
			
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
			
			if (list != null)
			{
				list.activate();
				list.S_ITEM_HOLD.add(onItemHold);
				list.S_ITEM_TAP.add(onItemTap);
			}
			
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			
			settingsButton.activate();
			
			setListData();
		}
		
		private function onItemTap(data:Object, n:int):void
		{
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			
			if (item)
			{
				itemHitZone = item.getLastHitZone();
			}
			
			if (data is ChatUserVO)
			{
				if ((data as ChatUserVO).uid == Auth.uid)
				{
					return;
				}
				
				var userPopupData:UserPopupData = new UserPopupData();
				userPopupData.data = (data as ChatUserVO).userVO;
				
				if (itemHitZone != null)
				{
					if (itemHitZone == HitZoneType.MODERATOR)
					{
						userPopupData.callback = onModeratorPopupResponse;
						DialogManager.showDialog(SetModeratorUserPopup, userPopupData);
						return;
					}
					if (itemHitZone == HitZoneType.MODERATOR_REMOVE)
					{
						userPopupData.callback = onModeratorRemovePopupResponse;
						DialogManager.showDialog(RemoveModeratorUserPopup, userPopupData);
						return;
					}
					if (itemHitZone == HitZoneType.DELETE)
					{
						if ((data as ChatUserVO).userVO != null && (data as ChatUserVO).userVO.type == UserType.BOT) {
							chatModel.removeUser((data as ChatUserVO).userVO.uid);
							BotManager.removeBotFromChannel(chatModel.uid, (data as ChatUserVO).userVO.uid);
							moderatorsData = null;
							setListData();
						}
						return;
					}
					if (itemHitZone == HitZoneType.KICK)
					{
						userPopupData.callback = onKickPopupResponse;
						DialogManager.showDialog(KickUserPopup, userPopupData);
						return;
					}
					if (itemHitZone == HitZoneType.BAN)
					{
						userPopupData.resultData = new UserBanData();
						userPopupData.callback = onBanPopupResponse;
						DialogManager.showDialog(BanUserPopup, userPopupData);
						return;
					}
					if (itemHitZone == HitZoneType.UNBAN)
					{
						userPopupData.callback = onUnbanPopupResponse;
						userPopupData.additionalData = (data as ChatUserVO).banData;
						DialogManager.showDialog(UnbanUserPopup, userPopupData);
						return;
					}
				}
				
				if ((data as ChatUserVO).banned) {
					userPopupData.callback = onUnbanPopupResponse;
					userPopupData.additionalData = (data as ChatUserVO).banData;
					DialogManager.showDialog(UnbanUserPopup, userPopupData);
				}
				else {
					if ((data as ChatUserVO).userVO != null && (data as ChatUserVO).userVO.type != UserType.BOT) {
						MobileGui.changeMainScreen(UserProfileScreen, {data:(data as ChatUserVO).userVO, 
															backScreen:ChannelInfoModeratorScreen, 
															backScreenData:this.data});
					}
				}
			}
		}
		
		private function onBanPopupResponse(response:String, userPopupData:UserPopupData = null):void 
		{
			if (response == UserPopup.RESPONSE_ACCEPT)
			{
				ChannelsManager.banUser(chatModel.uid, userPopupData.data.uid, userPopupData.resultData as UserBanData);
			}
			userPopupData.dispose();
		}
		
		private function onUnbanPopupResponse(response:String, userPopupData:UserPopupData = null):void 
		{
			if (response == UserPopup.RESPONSE_ACCEPT)
			{
				ChannelsManager.unbanUser(chatModel.uid, userPopupData.data.uid);
			}
			userPopupData.dispose();
		}
		
		private function onKickPopupResponse(response:String, userPopupData:UserPopupData = null):void 
		{
			if (response == UserPopup.RESPONSE_ACCEPT)
			{
				ChannelsManager.kickUser(chatModel.uid, userPopupData.data.uid);
			//	onlineUsers.removeAt(onlineUsers.indexOf(userPopupData));
			}
			userPopupData.dispose();
		}
		
		private function onModeratorPopupResponse(response:String, userPopupData:UserPopupData = null):void 
		{
			if (response == UserPopup.RESPONSE_ACCEPT)
			{
				/*var responseResolver:ResponseResolver = new ResponseResolver();
				responseResolver.callback = onAddModeratorResult;
				responseResolver.data = { };
				responseResolver.data.userUID = userPopupData.data.uid;
				responseResolver.data.channelUID = chatModel.uid;*/
				
				ChannelsManager.addModerator(chatModel.uid, userPopupData.data.uid);
			}
			userPopupData.dispose();
		}
		
		/*private function onAddModeratorResult(success:Boolean, requestData:Object = null):void
		{
			if (_isDisposed)
			{
				return;
			}
			
			if (success)
			{
				if (requestData && requestData.channelUID && requestData.channelUID == chatModel.uid)
				{
					moderatorsData = null;
					onlineUsers = null;
					setListData();
				}
			}
			else
			{
				ToastMessage.display(Lang.failedAddModerator);
			}
		}*/
		
		private function onModeratorRemovePopupResponse(response:String, userPopupData:UserPopupData = null):void 
		{
			if (response == UserPopup.RESPONSE_ACCEPT)
			{
				/*var responseResolver:ResponseResolver = new ResponseResolver();
				responseResolver.callback = onRemoveModeratorResult;
				responseResolver.data = { };
				responseResolver.data.userUID = userPopupData.data.uid;
				responseResolver.data.channelUID = chatModel.uid;*/
				
				ChannelsManager.removeModerator(chatModel.uid, userPopupData.data.uid);
			}
			userPopupData.dispose();
		}
		
		/*private function onRemoveModeratorResult(success:Boolean, requestData:Object = null):void
		{
			if (_isDisposed)
			{
				return;
			}
			
			if (success)
			{
				if (requestData && requestData.channelUID && requestData.channelUID == chatModel.uid)
				{
					moderatorsData = null;
					onlineUsers = null;
					setListData();
				}
			}
			else
			{
				ToastMessage.display(Lang.failedRemoveModerator);
			}
		}*/
		
		private function onTabItemSelected(id:String):void
		{
			echo("ChannelInfoModeratorScreen", "onTabItemSelected", "");
			selectedFilter = id;
			setListData();
		}
		
		private function setListData():void
		{
			echo("ChannelInfoModeratorScreen", "setListData", "");
			if (selectedFilter == IN_CHAT)
			{
				if (onlineUsers == null)
				{
					onlineUsers = createOnlineUsersArray();
				}
				list.setData(onlineUsers, ChannelUserListRenderer, ["avatarURL"]);
			}
			else if (selectedFilter == MODERATORS)
			{
				if (moderatorsData == null)
				{
					moderatorsData = createModeratorsArray();
				}
				list.setData(moderatorsData, ChannelUserListRenderer, ["avatarURL"]);
			}
			else if (selectedFilter == BANNED)
			{
				if (banned == null)
				{
					getBannedUsers();
					list.setData(null, null);
				}
				else
				{
					list.setData(banned, ChannelBannedUserListRenderer, ["avatarURL"]);
				}
			}
		}
		
		private function getBannedUsers():void 
		{
			ChannelsManager.getBannedUsers(chatModel.uid);
		}
		
		private function createOnlineUsersArray():Array 
		{
			var array:Array = ChatManager.getOnlineUsers(chatModel.uid);
			if (moderatorsData == null)
			{
				moderatorsData = createModeratorsArray();
			}
			var l:int = array.length;
			var moderatorsOnlineIndexes:Array = new Array();
			
			for (var i:int = 0; i < l; i++) 
			{
				for (var j:int = 0; j < moderatorsData.length; j++) 
				{
					if ((moderatorsData[j] as ChatUserVO).uid == (array[i] as ChatUserVO).uid)
					{
						moderatorsOnlineIndexes.push(i);
						array.splice(i, 1);
						array.unshift(moderatorsData[j]);
						break;
					}
				}
			}
			return array;
		}
		
		private function createModeratorsArray():Array 
		{
			var moderators:Array = new Array();
			var l:int = chatModel.users.length;
			for (var i:int = 0; i < l; i++) 
			{
				if (chatModel.users[i].isChatOwner() || chatModel.users[i].isChatModerator() || chatModel.users[i].userVO.type == UserType.BOT)
				{
					moderators.push(chatModel.users[i]);
				}
			}
			return moderators;
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed)
				return;
				
			if (topBar != null)
				topBar.deactivate();		
			
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			
			if (list != null)
			{
				list.deactivate();
				list.S_ITEM_HOLD.add(onItemHold);
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			
			settingsButton.deactivate();
		}
	}
}