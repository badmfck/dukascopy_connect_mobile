package com.dukascopy.connect.screens.chat {
	
		import com.dukascopy.connect.Config;
		import com.dukascopy.connect.MobileGui;
		import com.dukascopy.connect.gui.lightbox.UI;
		import com.dukascopy.connect.gui.list.List;
		import com.dukascopy.connect.gui.list.renderers.ChannelUserListRenderer;
		import com.dukascopy.connect.gui.menuVideo.BitmapButton;
		import com.dukascopy.connect.gui.menuVideo.OptionSwitcherCustomLayout;
		import com.dukascopy.connect.gui.tabs.FilterTabs;
		import com.dukascopy.connect.screens.ChatScreen;
		import com.dukascopy.connect.screens.RootScreen;
		import com.dukascopy.connect.screens.UserProfileScreen;
		import com.dukascopy.connect.screens.base.BaseScreen;
		import com.dukascopy.connect.screens.base.ScreenManager;
		import com.dukascopy.connect.sys.auth.Auth;
		import com.dukascopy.connect.sys.chatManager.ChatManager;
		import com.dukascopy.connect.sys.chatManager.ChatUsersCollection;
		import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
		import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
		import com.dukascopy.connect.sys.dialogManager.DialogManager;
		import com.dukascopy.connect.sys.echo.echo;
		import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
		import com.dukascopy.connect.sys.pointerManager.PointerManager;
		import com.dukascopy.connect.sys.style.Style;
		import com.dukascopy.connect.sys.theme.AppTheme;
		import com.dukascopy.connect.utils.TextUtils;
		import com.dukascopy.connect.vo.ChatVO;
		import com.dukascopy.connect.vo.users.UserVO;
		import com.dukascopy.connect.vo.users.adds.ChatUserVO;
		import com.dukascopy.langs.Lang;
		import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.display.Sprite;
		import flash.display.StageQuality;
		import flash.events.Event;
		import flash.text.TextFieldAutoSize;
		import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class ChannelInfoScreen extends BaseScreen
	{
		private var title:Bitmap;
		private var bgHeader:Bitmap;
		private var backButton:BitmapButton;
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
		private var line1:Bitmap;
		private var textAbout:Bitmap;
		private var about:Bitmap;
		private var optionNotifications:OptionSwitcherCustomLayout;
		private var uid:String;
		
		private var mainBack:Sprite;
		private var tabs:FilterTabs;
		private var list:List;
		
		private static const IN_CHAT:String = "In chat";
		private static const MODERATORS:String = "connect";
		private var onlineUsers:Array;
		private var moderatorsData:Array;
		private var selectedFilter:String;
		private var aboutContainer:Sprite;
		private var infoText:String;
		
		public function ChannelInfoScreen() { }
		
		override public function initScreen(data:Object = null):void {
			if ("data" in data && "chatId" in data.data)
				uid = data.data.chatId;
			if (uid == null && ChatManager.getCurrentChat() != null)
				uid = ChatManager.getCurrentChat().uid;
			if (uid == null) {
				MobileGui.centerScreen.show(RootScreen);
				return;
			}
			
			selectedFilter = MODERATORS;
			
			chatModel = ChannelsManager.getChannel(uid);
			if (chatModel == null) {
				chatModel = AnswersManager.getAnswer(uid);
			}
			
			if (chatModel == null) {
				onBack();
				return;
			}
			
			super.initScreen(data);
			
			_params.title = 'Channel info screen';
			_params.doDisposeAfterClose = true;
			
			var iconSize:int = Config.FINGER_SIZE * 0.36;
			backgroundIconHeight = Config.FINGER_SIZE * .5;
			settingsIconPosition = int(backgroundIconHeight * .5);
			settingsTextPosition = int(backgroundIconHeight + Config.MARGIN);
			FIT_WIDTH = _width - buttonPaddingLeft*2;
			
			var currentYDrawPosition:int = 0;
			
			if (bgHeader.bitmapData)
			{
				UI.disposeBMD(bgHeader.bitmapData);
				bgHeader.bitmapData = null;
			}
			
			bgHeader.bitmapData = UI.getTopBarLayeredBitmapData(
														_width, 
														Config.FINGER_SIZE * .85, 
														Config.APPLE_TOP_OFFSET, 
														0,
														AppTheme.RED_MEDIUM,
														AppTheme.RED_MEDIUM,
														AppTheme.RED_MEDIUM);
			drawTitle();
			
			title.y = Config.APPLE_TOP_OFFSET + int((Config.FINGER_SIZE * .85 - title.height) * .5);
			title.x = int(Config.FINGER_SIZE);
			
			
			var position:int = bgHeader.y + bgHeader.height + Config.MARGIN * 2;
			
			if (chatModel.settings.info && chatModel.settings.info != "")
			{
				var textAboutBD:BitmapData = TextUtils.createTextFieldData(
												Lang.aboutChannel, 
												_width - buttonPaddingLeft*2, 
												10, 
												false, 
												TextFormatAlign.LEFT, 
												TextFieldAutoSize.LEFT, 
												Config.FINGER_SIZE * .26, 
												false, 
												0x93A2AE, 
												0xFFFFFF, 
												true);
				textAbout.bitmapData = textAboutBD;
				textAbout.y = position;
				textAbout.x = buttonPaddingLeft;
				position += textAbout.height + Config.MARGIN;
				
				line1.width = _width;
				line1.y = position;
				position += Config.MARGIN;
				
				infoText = chatModel.settings.info;
				
				if (infoText.length > 150)
				{
					infoText = infoText.substr(0, 150) + "...";
				}
				
				var aboutBD:BitmapData = TextUtils.createTextFieldData(
													infoText, 
													_width - buttonPaddingLeft*2, 
													10, 
													true, 
													TextFormatAlign.JUSTIFY, 
													TextFieldAutoSize.LEFT, 
													Config.FINGER_SIZE * .26, 
													true, 
													AppTheme.GREY_DARK, 
													0xFFFFFF, 
													true);
				about.bitmapData = aboutBD;
				aboutContainer.y = position;
				aboutContainer.x = buttonPaddingLeft;
				position += about.height + Config.MARGIN * 1.5;
			}
			
			if (chatModel.channelData.subscribed || (chatModel.questionID != null && chatModel.questionID != "")) {
				optionNotifications.iconPosition = settingsIconPosition;
				optionNotifications.textPosition = settingsTextPosition;
				var notificationIconBD:ImageBitmapData = UI.renderAsset(UI.colorize(new SWFSettingsIcon_notification(),0x6e92af), iconSize, iconSize, true, "ChatSettingsScreen.NotificationsControlIcon");
				optionNotifications.create(FIT_WIDTH, OPTION_LINE_HEIGHT, notificationIconBD, Lang.textNotifications, chatModel.getPushAllowed());
				optionNotifications.y = position;
				optionNotifications.x = buttonPaddingLeft;
				notificationIconBD = null;
				position += OPTION_LINE_HEIGHT + Config.MARGIN * .5;
			}
			
			tabs.view.y = position;
			tabs.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
			list.view.y = tabs.view.y + tabs.height;
			list.setWidthAndHeight(_width, _height - list.view.y);
			
			mainBack.width = _width;
			mainBack.height = _height;
			
			ChatUsersCollection.S_USERLIST_CHANGED.add(onlineUserlistChanged);
			ChannelsManager.S_CHANNEL_MODERATORS_UPDATED.add(onChannelChanged);
			ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.add(onChannelChanged);
			
			ChatManager.chatEnter(chatModel.uid);
		}
		
		private function drawTitle():void 
		{
			if (title.bitmapData)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			var titleText:String;
			
			titleText = Lang.settings;
			
			title.bitmapData = UI.renderText(titleText, 
											_width - Config.FINGER_SIZE, 
											Config.FINGER_SIZE, 
											false, 
											TextFormatAlign.CENTER, 
											TextFieldAutoSize.LEFT, 
											Config.FINGER_SIZE * .38,
											false,
											0xffffff,
											0,
											true, "ChatSettingsScreen.title");
			title.y = Config.APPLE_TOP_OFFSET + int((Config.FINGER_SIZE * .85 - title.height) * .5);
			title.x = int(Config.FINGER_SIZE);
		}
		
		private function onlineUserlistChanged():void 
		{
			onlineUsers = null;
			if (selectedFilter == IN_CHAT)
			{
				setListData();
			}
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
					MobileGui.changeMainScreen(ChannelInfoModeratorScreen, { data:{ chatId:chatModel.uid, chatSettings:this.data.chatSettings },
															backScreen:ChatScreen,
															backScreenData:this.data.backScreenData },
															ScreenManager.DIRECTION_RIGHT_LEFT);
					
					break;
				}
				case ChannelsManager.EVENT_REMOVED_FROM_MODERATORS:
				{
					
					break;
				}
				case ChannelsManager.EVENT_TITLE_CHANGED:
				{
					drawTitle();
					break;
				}
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
			var btnSize:int = headerSize * .38;
			var btnY:int = (headerSize - btnSize) * .5;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			//header background;
			bgHeader = new Bitmap();
			_view.addChild(bgHeader);
			
			
			//back header button;
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1.3);
			backButton.setDownColor(0xFFFFFF);
			backButton.tapCallback = onBack;
			backButton.disposeBitmapOnDestroy = true;
			backButton.show();
			_view.addChild(backButton);
			var icoBack:IconBack = new IconBack();
			icoBack.width = icoBack.height = btnSize;
			backButton.setBitmapData(UI.getSnapshot(icoBack, StageQuality.HIGH, "ChatSettingsScreen.backButton"), true);
			backButton.x = btnOffset;
			backButton.y = btnY + Config.APPLE_TOP_OFFSET;
			backButton.setOverflow(btnOffset, btnOffset, Config.FINGER_SIZE*.6, btnOffset + Config.FINGER_SIZE*.1);
			UI.destroy(icoBack);
			icoBack = null;
			
			
			//header title;
			title = new Bitmap(null, "auto", true);
			_view.addChild(title);
			
			optionNotifications = new OptionSwitcherCustomLayout();
			view.addChild(optionNotifications);
			optionNotifications.onSwitchCallback = changePushNotifications;
			
			var hLineBitmapData:ImageBitmapData = new ImageBitmapData("ChatSettingsScreen.hLine", 1, 1, false, AppTheme.GREY_LIGHT);
			line1 = new Bitmap(hLineBitmapData);
			line1.visible = false;
			view.addChild(line1);
			hLineBitmapData = null;
			
			about = new Bitmap();
			aboutContainer = new Sprite();
			view.addChild(aboutContainer);
			aboutContainer.addChild(about);
			
			textAbout = new Bitmap();
			view.addChild(textAbout);
			
			list = new List("Contacts");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			list.view.y = Config.FINGER_SIZE*1.2;
			_view.addChild(list.view);
			
			tabs = new FilterTabs();
		//	tabs.add(Lang.inChat, IN_CHAT, true, "l");
			tabs.add(Lang.textModerators, MODERATORS, false);
			_view.addChild(tabs.view);
			tabs.setSelection(MODERATORS);
		}
		
		private function changePushNotifications(value:Boolean):void 
		{
			ChatManager.changeChatPushNotificationsStatus(chatModel.uid, value);
		}
		
		override protected function drawView():void
		{
			
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (optionNotifications)
			{
				optionNotifications.dispose();
				optionNotifications = null;
			}
			ChatManager.chatExit(chatModel.uid);
			chatModel = null;
			
			UI.destroy(title);
			title = null;
			
			UI.destroy(bgHeader);
			bgHeader = null;
			
			if (backButton != null) 
				backButton.dispose();
			backButton = null;
			
			if (mainBack != null) 
				UI.destroy(mainBack);
			mainBack = null;
			
			if (about != null) 
				UI.destroy(about);
			about = null;
			
			UI.destroy(line1);
			line1 = null;
			
			UI.destroy(textAbout);
			textAbout = null;
			
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (list != null)
				list.dispose();
			list = null;
			
			onlineUsers = null;
			moderatorsData = null;
			
			if (aboutContainer)
			{
				UI.destroy(aboutContainer);
				aboutContainer = null;
			}
			
			ChatUsersCollection.S_USERLIST_CHANGED.remove(onlineUserlistChanged);
			ChannelsManager.S_CHANNEL_MODERATORS_UPDATED.remove(onChannelChanged);
			ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.remove(onChannelChanged);
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed)
				return;
				
			if (backButton != null)
			backButton.activate();
			
			optionNotifications.activate();
			
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}	
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			
			if (infoText && chatModel.settings.info != null && chatModel.settings.info.length != infoText.length)
			{
				PointerManager.addTap(aboutContainer, showFullInfo);
			}
			
			setListData();
		}
		
		private function showFullInfo(e:Event):void 
		{
			DialogManager.alert(Lang.aboutChannel,  chatModel.settings.info, function(value:int):void
			{
				
			},Lang.textOk);
		}
		
		private function onItemTap(data:Object, n:int):void
		{
			if (data is ChatUserVO && (data as ChatUserVO).secretMode == false)
			{
				if ((data as ChatUserVO).uid == Auth.uid || (data as ChatUserVO).userVO.type == UserVO.TYPE_BOT)
				{
					return;
				}
				
				MobileGui.changeMainScreen(UserProfileScreen, {data:(data as ChatUserVO).userVO, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:this.data});
			}
		}
		
		private function onTabItemSelected(id:String):void {
			echo("InnerContactScreen", "onTabItemSelected", "");
			selectedFilter = id;
			setListData();
		}
		
		private function setListData():void
		{
			echo("InnerContactScreen", "setListData", "");
			if (selectedFilter == IN_CHAT)
			{
				if (onlineUsers == null)
				{
					onlineUsers = createOnlineUsersArray();
				}
				list.setData(onlineUsers, ChannelUserListRenderer);
			}
			else if (selectedFilter == MODERATORS)
			{
				if (moderatorsData == null)
				{
					moderatorsData = createModeratorsArray();
				}
				list.setData(moderatorsData, ChannelUserListRenderer);
			}
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
				if (chatModel.users[i].isChatModerator() || chatModel.users[i].isChatOwner())
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
				
			if (backButton != null)
			
			optionNotifications.deactivate();
			
			if (list != null)
			{
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			
			PointerManager.removeTap(aboutContainer, showFullInfo);
		}
	}
}