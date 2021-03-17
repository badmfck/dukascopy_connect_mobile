package com.dukascopy.connect.gui.topBar {
	
	import assets.HeartFill;
	import assets.HeartIcon;
	import assets.IconArrowWhiteLeft;
	import assets.IconInfoClip;
	import assets.OwnerIcon;
	import assets.StartStreamIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.chat.ChannelInfoModeratorScreen;
	import com.dukascopy.connect.screens.chat.ChannelInfoScreen;
	import com.dukascopy.connect.screens.chat.ChatSettingsScreen;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.ChatUsersCollection;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	/**
	 * Используется в ChatScreen
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class TopBarChat extends MobileClip {
		
		private var _height:int;
		private var _width:int;
		private var _circleStatusHeight:int;
		private var _maxTextWidth:int;
		
		private var icoBack:MovieClip = new (Style.icon(Style.ICON_BACK));
		private var icoSettings:MovieClip = new (Style.icon(Style.ICON_SETTINGS));
		private var icoCall:MovieClip = new (Style.icon(Style.ICON_CALLS));
		private var icoInfo:MovieClip = new IconInfoClip() as MovieClip;
		private var icoStream:MovieClip = new StartStreamIcon() as MovieClip;
		
		private var icoSubscribe:MovieClip = new ownerIconOutline() as MovieClip;
		private var icoUnsubscribe:MovieClip = new OwnerIcon() as MovieClip;
		
		private var bg:Bitmap;
		private var bgBMD:BitmapData;
		private var bgRect:Rectangle;
		
		private var title:Bitmap;
		private var status:Sprite;
		private var statusTxt:Bitmap;
		
		private var settingsButton:BitmapButton;
		private var callButton:BitmapButton;
		private var backButton:BitmapButton;
		private var lockButton:BitmapButton;
		private var infoButton:BitmapButton;
		
		private var _lockButtonLockedBitmap:BitmapData;
		private var _lockButtonUnlockedBitmap:BitmapData;
		
		private var trueH:int;
		private var btnY:int;
		private var btnSize:int = 0;
		private var btnOffsetH:Number;
		private var btnOffsetW:Number;
		private var titleHeight:int;
		
		private var screen:ChatScreen = null;
		private var callCallback:Function;
		
		private var lastTitleValue:String;
		private var rightOffset:int;
		private var subscribeButton:BitmapButton;
		private var unsubscribeButton:BitmapButton;
		private var firstTime:Boolean;
		private var startStreamButton:BitmapButton;
		private var startStreamCallback:Function;
		
		public function TopBarChat() {
			createView();
			firstTime = true;
		}
		
		private function createView():void {
			var ct2:ColorTransform = new ColorTransform();
			ct2.color = 0xFFFFFF;
			icoUnsubscribe.transform.colorTransform = ct2;
			
			_view = new Sprite();
			bgRect = new Rectangle(0, 0, 1, Config.APPLE_TOP_OFFSET);
			bg = new Bitmap();
			_view.addChild(bg);
			
			backButton = new BitmapButton();
			backButton.listenNativeClickEvents(true);
			backButton.setStandartButtonParams();
			backButton.setDownScale(1.3);
			backButton.setDownColor(0xFFFFFF);
			backButton.tapCallback = onBtnBackTap;
			backButton.disposeBitmapOnDestroy = true;
			backButton.show();
			_view.addChild(backButton);
			
			title = new Bitmap(null, "auto", true);
			_view.addChild(title);
			
			status = new Sprite();
			status.visible = false;
			statusTxt = new Bitmap(null, "auto", true);
			status.addChild(statusTxt);
			_view.addChild(status);
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeativate);
			ChatManager.S_CHAT_UPDATED.add(onChatUpdated);
			UsersManager.USER_BLOCK_CHANGED.add(onUserBlockStatusChanged);
			ChatUsersCollection.S_USERLIST_CHANGED.add(channelUsersChanged);
		}
		
		private function channelUsersChanged():void {
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				if (statusTxt.bitmapData != null) {
					statusTxt.bitmapData.dispose();
					statusTxt.bitmapData = null;
				}
				statusTxt.x = 0;
				statusTxt.bitmapData = UI.renderText(
					ChatManager.getOnlineUsersNum(ChatManager.getCurrentChat().uid).toString() + " " + Lang.textOnline,
					_maxTextWidth,
					Config.FINGER_SIZE_DOT_25,
					false,
					TextFormatAlign.LEFT,
					TextFieldAutoSize.LEFT,
					trueH * .25,
					false,
					Style.color(Style.TOP_BAR_ICON_COLOR),
					0,
					true,
					"ChatTop.status"
				);
				displayUserStatus();
			}
		}
		
		private function onActivate(e:Event):void {
			if (screen.isActivated == true)
				activate();
		}
		
		private function onDeativate(e:Event):void {
			deactivate();
		}
		
		public function activate():void {
			echo("ChatTop", "activate", "");
			if (backButton != null)
				backButton.activate();
			if (infoButton)
				infoButton.activate();
			if (settingsButton != null)
				settingsButton.activate();
			if (callButton != null)
				callButton.activate();
			if (lockButton != null)
				lockButton.activate();
		}
		
		public function deactivate():void {
			echo("ChatTop", "deactivate", "");
			if (backButton != null)
				backButton.deactivate();
			if (settingsButton != null)
				settingsButton.deactivate();
			if (callButton != null)
				callButton.deactivate();
			if (lockButton != null)
				lockButton.deactivate();
			if (infoButton)
				infoButton.deactivate();
		}
		
		public function setWidthAndHeight(w:int, h:int):void {
			echo("ChatTop", "setWidthAndHeight", "");
			if (h == 0)
				return;
			
			_height = h;
			_width = w;
			
			bgRect.width = _width;
			
			if (bgBMD != null)
				bgBMD.dispose();
			bgBMD = new ImageBitmapData("ChatTop.BG", _width, _height, false, Style.color(Style.TOP_BAR));
			if (bgRect.height > 0)
				bgBMD.fillRect(bgRect, Style.color(Style.TOP_BAR));
			bg.bitmapData = bgBMD;
			
			trueH = h - Config.APPLE_TOP_OFFSET;
			
			btnSize = trueH * Style.size(Style.CHAT_TOP_ICON_SIZE);
			btnY = (trueH - btnSize) * .5;
			btnOffsetH = (trueH - btnSize) * .5;
			btnOffsetW = btnOffsetH * .7;
			
			_circleStatusHeight = Config.FINGER_SIZE * .08;
			
			UI.scaleToFit(icoBack, btnSize, btnSize);
		//	icoBack.width = icoBack.height = btnSize;
			UI.colorize(icoBack, Style.color(Style.TOP_BAR_ICON_COLOR));
			backButton.setBitmapData(UI.getSnapshot(icoBack, StageQuality.HIGH, "ChatTop.backButon"), true);
			backButton.x = btnOffsetH;
			backButton.y = btnY + Config.APPLE_TOP_OFFSET;
			backButton.setOverflow(btnOffsetH, btnOffsetH, btnOffsetH, btnOffsetH);
			
			redrawTitle();
			
			title.y = int((trueH - title.height) * .5 + Config.APPLE_TOP_OFFSET);
			title.x = int(Config.FINGER_SIZE * .65);
			status.x = (title.x + Config.FINGER_SIZE * .05);
			statusTxt.x = _circleStatusHeight + Config.MARGIN;
		}
		
		private function onChatUpdated(chatVO:ChatVO):void {
			echo("ChatTop", "onChatUpdated", "")
			if (!(ChatManager.getCurrentChat() != null && chatVO != null && chatVO.uid == ChatManager.getCurrentChat().uid)) {
				return;
			}
			redrawTitle();
			onLockValueChanged();
		}
		
		public function redrawTitle():void {
			echo("ChatTop", "redrawTitle", value);
			var value:String = getTitleValue();
			if (rightOffset == 0)
				_maxTextWidth = _width - Config.MARGIN;
			else
				_maxTextWidth = rightOffset;
			_maxTextWidth -= title.x; 
			if (_maxTextWidth < 1)
				return;
			if (lastTitleValue == value && title.bitmapData && title.bitmapData.width == _maxTextWidth)
				return;
			UI.disposeBMD(title.bitmapData);
			if (value == null || value.length == 0)
				value = " ";
			lastTitleValue = value;
			title.bitmapData = UI.renderText(value, _maxTextWidth, 1, false, TextFormatAlign.LEFT, TextFieldAutoSize.NONE, trueH * .45, false, Style.color(Style.TOP_BAR_TEXT_COLOR), 0, true, "ChatTop.title", false, true);
		}
		
		private function getTitleValue():String {
			if (screen != null)
				return screen.getTitleValue();
			return "";
		}
		
		public function update():void {
			firstTime = true;
			statusTxt.alpha = 1;
			if (ChatManager.getCurrentChat() == null)
				return;
			
			var chat:ChatVO = ChatManager.getCurrentChat();
			
			
			if (chat.type == ChatRoomType.PRIVATE ||
				chat.type == ChatRoomType.QUESTION)
					displayUserStatus();
			if (chat.type == ChatRoomType.QUESTION)
				showInfoButton();
				
			var needShowSettingsButton:Boolean = true;
			if (chat.type == ChatRoomType.COMPANY) {
				needShowSettingsButton = false;
			}
			if (chat.isLocalIncomeChat())
			{
				needShowSettingsButton = false;
			}
			if (needShowSettingsButton == true)
				showSettingsButton();
			if (chat.type == ChatRoomType.CHANNEL && chat.channelData != null/* && 
				(ChatManager.getCurrentChat().questionID == null || ChatManager.getCurrentChat().questionID == "")*/) {
					if (!chat.isModerator(Auth.uid) && !chat.isOwner(Auth.uid)) {
						if (chat.channelData.subscribed) {
							showUnsubscribeButton();
						} else {
							showSubscribeButton();
						}
					}
					else{
						hideSubscribeButton();
						hideUnsubscribeButton();
					}
			}
			if (chat.type != ChatRoomType.COMPANY &&
				chat.isLocalIncomeChat() == false &&
				chat.type != ChatRoomType.QUESTION &&
				chat.type != ChatRoomType.CHANNEL)
					showLockButton();					
			if (chat.type == ChatRoomType.PRIVATE) {
				var user:ChatUserVO = UsersManager.getInterlocutor(chat);	
				if (user != null && user.userVO != null && user.userVO.type == UserVO.TYPE_BOT){
					// Dobarin style because less of text logic ))) 
				}else{
					if (!chat.isLocalIncomeChat() && (!user || user.uid != Config.NOTEBOOK_USER_UID)) {
						showCallButton();
					}
				}		
			}
			
			/*if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL && ChatManager.getCurrentChat().ownerUID == Auth.uid && Config.isAdmin())
			{
				showStartStreamButton();
			}
			else */
			/*if(Auth.uid == "I6DzDaWqWKWE" || Auth.uid == "WdW6DJI1WbWo")
			{
				showStartStreamButton();
			}*/
			
			updateButtonsPositions();
			channelUsersChanged();
			
			if (ChatManager.getCurrentChat().type == ChatRoomType.COMPANY)
				drawChatUID();
		}
		
		public function updateButtonsPositions():void {
			echo("ChatTop", "updateButtonsPositions", "");
			var trueX:int = _width;
			if (settingsButton != null) {
				trueX = trueX - trueH + btnOffsetH;
				settingsButton.x = trueX;
			}
			if (lockButton != null) {
				trueX = trueX - btnSize - btnOffsetW * 2;
				lockButton.x = trueX;
			}
			if (callButton != null) {
				trueX = trueX - btnSize - btnOffsetW * 2;
				callButton.x = trueX;
			}
			if (infoButton != null) {
				trueX = trueX - btnSize - btnOffsetW * 2;
				infoButton.x = trueX;
			}
			if (subscribeButton != null) {
				trueX = trueX - btnSize - btnOffsetW * 2;
				subscribeButton.x = trueX;
			}
			if (unsubscribeButton != null) {
				trueX = trueX - btnSize - btnOffsetW * 2;
				unsubscribeButton.x = trueX;
			}
			if (startStreamButton != null) {
				trueX = trueX - btnSize - btnOffsetW * 2;
				startStreamButton.x = trueX;
			}
			rightOffset = trueX - btnOffsetH;
			redrawTitle();
		}
		
		public function showSettingsButton():void {
			if (settingsButton != null)
				return;
			icoSettings.width = icoSettings.height = btnSize;
			
			settingsButton = new BitmapButton();
			settingsButton.setStandartButtonParams();
			settingsButton.setDownScale(1.3);
			settingsButton.setDownColor(0xFFFFFF);
			settingsButton.tapCallback = onBtnSettingsTap;
			settingsButton.disposeBitmapOnDestroy = true;
			UI.colorize(icoSettings, Style.color(Style.TOP_BAR_ICON_COLOR));
			settingsButton.setBitmapData(UI.getSnapshot(icoSettings, StageQuality.HIGH, "ChatTop.settingsButton"), true);
			settingsButton.y = btnY + Config.APPLE_TOP_OFFSET;
			settingsButton.setOverflow(btnOffsetH, btnOffsetW, btnOffsetW, btnOffsetH);
			
			_view.addChild(settingsButton);
			settingsButton.hide();
			settingsButton.show(.3);
			settingsButton.activate();
		}
		
		public function showSubscribeButton():void {
			
			hideUnsubscribeButton();
			
			if (subscribeButton == null)
			{
				icoSubscribe.width = icoSubscribe.height = btnSize;
				
				subscribeButton = new BitmapButton();
				subscribeButton.setStandartButtonParams();
				subscribeButton.setDownScale(1.3);
				subscribeButton.setDownColor(0xFFFFFF);
				subscribeButton.tapCallback = onBtnSubscribeTap;
				subscribeButton.disposeBitmapOnDestroy = true;
				UI.colorize(icoSubscribe, Style.color(Style.TOP_BAR_ICON_COLOR));
				subscribeButton.setBitmapData(UI.getSnapshot(icoSubscribe, StageQuality.HIGH, "ChatTop.subscribeButton"), true);
				subscribeButton.y = btnY + Config.APPLE_TOP_OFFSET;
				subscribeButton.setOverflow(btnOffsetH, btnOffsetW, btnOffsetW, btnOffsetH);
				
				_view.addChild(subscribeButton);
				subscribeButton.hide();
			}
			
			subscribeButton.show(.3);
			subscribeButton.activate();
		}
		
		private function onBtnSubscribeTap(e:Event = null):void 
		{
			showUnsubscribeButton();
			updateButtonsPositions();
			
			screen.subscribe();
		}
		
		private function hideSubscribeButton():void 
		{
			if (subscribeButton != null)
			{
				subscribeButton.dispose();
				if (_view != null && _view.contains(subscribeButton))
				{
					_view.removeChild(subscribeButton);
				}
				subscribeButton = null;
			}
		}
		
		public function showUnsubscribeButton():void {
			
			hideSubscribeButton();
			
			if (unsubscribeButton == null)
			{
				icoUnsubscribe.width = icoUnsubscribe.height = btnSize;
				
				unsubscribeButton = new BitmapButton();
				unsubscribeButton.setStandartButtonParams();
				unsubscribeButton.setDownScale(1.3);
				unsubscribeButton.setDownColor(0xFFFFFF);
				unsubscribeButton.tapCallback = onBtnUnsubscribeTap;
				unsubscribeButton.disposeBitmapOnDestroy = true;
				unsubscribeButton.setBitmapData(UI.getSnapshot(icoUnsubscribe, StageQuality.HIGH, "ChatTop.subscribeButton"), true);
				unsubscribeButton.y = btnY + Config.APPLE_TOP_OFFSET;
				unsubscribeButton.setOverflow(btnOffsetH, btnOffsetW, btnOffsetW, btnOffsetH);
				
				_view.addChild(unsubscribeButton);
				unsubscribeButton.hide();
			}
			
			unsubscribeButton.show(.3);
			unsubscribeButton.activate();
		}
		
		private function onBtnUnsubscribeTap(e:Event = null):void 
		{
			showSubscribeButton();
			updateButtonsPositions();
			
			screen.unsubscribe();
		}
		
		private function hideUnsubscribeButton():void 
		{
			if (unsubscribeButton != null)
			{
				unsubscribeButton.dispose();
				if (_view != null && _view.contains(unsubscribeButton))
				{
					_view.removeChild(unsubscribeButton);
				}
				unsubscribeButton = null;
			}
		}
		
		public function showStartStreamButton():void {
			if (startStreamButton != null)
				return;
			icoStream.width = icoStream.height = btnSize;
			
			startStreamButton = new BitmapButton();
			startStreamButton.setStandartButtonParams();
			startStreamButton.setDownScale(1.3);
			startStreamButton.setDownColor(0xFFFFFF);
			startStreamButton.tapCallback = onBtnStartStreamTap;
			startStreamButton.disposeBitmapOnDestroy = true;
			UI.colorize(icoStream, Style.color(Style.TOP_BAR_ICON_COLOR));
			startStreamButton.setBitmapData(UI.getSnapshot(icoStream, StageQuality.HIGH, "ChatTop.startStreamButton"), true);
			startStreamButton.y = btnY + Config.APPLE_TOP_OFFSET;
			startStreamButton.setOverflow(btnOffsetH, btnOffsetW, btnOffsetW, btnOffsetH);
			
			_view.addChild(startStreamButton);

			startStreamButton.hide();
			startStreamButton.show(.3);
			startStreamButton.activate();
		}
		
		public function showCallButton():void {
			if (callButton != null)
				return;
			icoCall.width = icoCall.height = btnSize;
			
			callButton = new BitmapButton();
			callButton.setStandartButtonParams();
			callButton.setDownScale(1.3);
			callButton.setDownColor(0xFFFFFF);
			callButton.tapCallback = onBtnCallTap;
			callButton.disposeBitmapOnDestroy = true;
			UI.colorize(icoCall, Style.color(Style.TOP_BAR_ICON_COLOR));
			callButton.setBitmapData(UI.getSnapshot(icoCall, StageQuality.HIGH, "ChatTop.settingsButton"), true);
			callButton.y = btnY + Config.APPLE_TOP_OFFSET;
			callButton.setOverflow(btnOffsetH, btnOffsetW, btnOffsetW, btnOffsetH);
			
			_view.addChild(callButton);
			callButton.hide();
			callButton.show(.3);
			callButton.activate();
		}
		
		public function showLockButton():void {
			if (lockButton != null)
				return;
			lockButton = new BitmapButton();
			lockButton.setStandartButtonParams();
			lockButton.setDownScale(1.3);
			lockButton.setDownColor(0xFFFFFF);
			lockButton.tapCallback = onLockButtonTap;
			lockButton.disposeBitmapOnDestroy = true;
			onLockValueChanged();
			lockButton.y = btnY + Config.APPLE_TOP_OFFSET;
			lockButton.setOverflow(btnOffsetH, btnOffsetW, btnOffsetW, btnOffsetH);
			
			_view.addChild(lockButton);
			lockButton.hide();
			lockButton.show(.3);
			lockButton.activate();
		}
		
		public function showInfoButton():void {
			if (infoButton != null)
				return;
			icoInfo.width = icoInfo.height = btnSize;
			
			infoButton = new BitmapButton();
			infoButton.setStandartButtonParams();
			infoButton.setDownScale(1.3);
			infoButton.setDownColor(0xFFFFFF);
			infoButton.tapCallback = onBtnInfoTap;
			infoButton.disposeBitmapOnDestroy = true;
			UI.colorize(icoInfo, Style.color(Style.TOP_BAR_ICON_COLOR));
			infoButton.setBitmapData(UI.getSnapshot(icoInfo, StageQuality.HIGH, "ChatTop.settingsButton"), true);
			infoButton.y = btnY + Config.APPLE_TOP_OFFSET;
			infoButton.setOverflow(btnOffsetH, btnOffsetW, btnOffsetW, btnOffsetH);
			
			_view.addChild(infoButton);
			infoButton.hide();
			infoButton.show(.3);
			infoButton.activate();
		}
		
		private function onBtnInfoTap():void {
			echo("ChatTop", "onBtnInfoTap", "");
			screen.showInfo();
		}
		
		private function onBtnBackTap(e:Event = null):void {
			echo("ChatTop", "onBtnBackTap", "");
			screen.onBack();
		}
		
		private function onBtnCallTap(e:Event = null):void {
			echo("ChatTop", "onBtnCallTap", "");
			callCallback();
		}
		
		private function onBtnStartStreamTap(e:Event = null):void {
			echo("TopBarChat", "onBtnStartStreamTap", "");
			if (startStreamCallback != null)
				startStreamCallback();
		}
		
		private function onBtnSettingsTap(e:Event = null):void {
			echo("ChatTop", "onBtnSettingsTap", "");
			var screenClass:Class = ChatSettingsScreen;
			if (ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				if (ChatManager.getCurrentChat().isOwner(Auth.uid) || ChatManager.getCurrentChat().isModerator(Auth.uid) || Config.ADMIN_UIDS.indexOf(Auth.uid) != -1)
					screenClass = ChannelInfoModeratorScreen;
				else
					screenClass = ChannelInfoScreen;
			}
			MobileGui.changeMainScreen(
				screenClass,
				{
					data:
						{
							chatId:ChatManager.getCurrentChat().uid,
							chatSettings:screen.data.settings
						},
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:screen.data
				},
				ScreenManager.DIRECTION_RIGHT_LEFT
			);
		}
		
		public function onLockButtonTap():void {
			echo("ChatTop", "onLockClicked", "");	
			if (ChatManager.getCurrentChat() != null) {
				if (ChatManager.getCurrentChat().locked)
					showDoUnlockAlert();
				else 
					showDoLockAlert();
			}
		}
		
		private function showDoLockAlert():void	{
			echo("ChatTop", "showDoLockAlert");
			DialogManager.showPin(function(val:int, pin:String):void {
				if (val != 1)
					return;
				if (pin.length == 0)
					return;
				TweenMax.delayedCall(1, function():void {
					echo("ChatTop","showDoLockAlert", "TweenMax.delayedCall");
					ChatManager.addPin(pin);
					onLockValueChanged();
				}, null, true);
			} );
		}
		
		private function showDoUnlockAlert():void {
			echo("ChatTop", "showDoUnlockAlert");
			DialogManager.alert(Lang.textAlert, Lang.areYouSureRemovePin, function(val:int):void {
				if (val != 1)
					return;
				ChatManager.removePin();
				onLockValueChanged();
			}, Lang.textYes.toUpperCase(), Lang.textCancel.toUpperCase());
		}
		
		private function onLockValueChanged():void {
			echo("ChatTop", "onLockValueChange", "");
			if (ChatManager.getCurrentChat() == null)
				return;
			if (lockButton == null)
				return;
			if (ChatManager.getCurrentChat().pin != null && ChatManager.getCurrentChat().pin != "----") {	
				lockButton.setBitmapData(lockButtonLockedBitmap);
				if (screen != null)
					screen.showLockButton();
			} else {
				lockButton.setBitmapData(lockButtonUnlockedBitmap);
				if (screen != null)
					screen.hideLockButton();
			}
		}
		
		public function updateUserStatus():void {
			if (ChatManager.getCurrentChat() != null && (ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE || ChatManager.getCurrentChat().type == ChatRoomType.QUESTION)) {
				UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
				if (ChatManager.getCurrentChat().users == null ||
					ChatManager.getCurrentChat().users.length == 0 ||
					ChatManager.getCurrentChat().users[0].uid == "")
						return;
				onUserOnlineStatusChanged(UsersManager.isOnline(ChatManager.getCurrentChat().users[0].uid), null);
			}
		}
		
		private function onUserBlockStatusChanged(data:Object):void {
			updateUserStatus();
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
			if (m == null) {
				drawStatus(false, Lang.textOffline + blockStatus);
				return;
			}
			if (m.uid != ChatManager.getCurrentChat().users[0].uid)
				return;
			if (m.uid == Config.NOTEBOOK_USER_UID) {
				drawStatus(true, Lang.textOnline);
				return;
			}
			if (m.online == false) {
				drawStatus(false, Lang.textOffline+blockStatus);
				return;
			}
			drawStatus(true, Lang.textOnline+blockStatus);
		}
		
		private function drawStatus(val:Boolean, txt:String):void {
			if (statusTxt.bitmapData != null)
				statusTxt.bitmapData.dispose();
			statusTxt.bitmapData = UI.renderText(txt, _maxTextWidth, Config.FINGER_SIZE_DOT_25, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, trueH * .25, false, Style.color(Style.TOP_BAR_ICON_COLOR), 0, true, "ChatTop.status");
			var metrics:TextLineMetrics = UI.getTextField().getLineMetrics(0);
			var _circleCenterY:Number = UI.getTextField().textHeight - metrics.descent - _circleStatusHeight + 2;
			metrics = null;
			status.graphics.clear();
			status.graphics.beginFill((val) ? 0x65BF37 : Style.color(Style.TOP_BAR_ICON_COLOR));
			status.graphics.drawCircle(_circleStatusHeight, _circleCenterY, _circleStatusHeight);
		}
		
		private function drawChatUID():void {
			if (statusTxt.bitmapData != null)
				statusTxt.bitmapData.dispose();
			statusTxt.bitmapData = UI.renderText(
				ChatManager.getCurrentChat().uid,
				_maxTextWidth,
				Config.FINGER_SIZE_DOT_25,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				trueH * .25,
				false,
				Style.color(Style.TOP_BAR_ICON_COLOR),
				0,
				true,
				"ChatTop.status"
			);
			statusTxt.alpha = .4;
			statusTxt.x = 0;
			var metrics:TextLineMetrics = UI.getTextField().getLineMetrics(0);
			var _circleCenterY:Number = UI.getTextField().textHeight - metrics.descent - _circleStatusHeight + 2;
			metrics = null;
			displayUserStatus();
		}
		
		override public function dispose():void {
			echo("ChatTop", "dispose", "");
			
			hideSubscribeButton();
			hideUnsubscribeButton();
			
			super.dispose();
			
			TweenMax.killTweensOf(status);
			TweenMax.killTweensOf(title);
			TweenMax.killTweensOf(bg);
			
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, onDeativate);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			ChatManager.S_CHAT_UPDATED.remove(onChatUpdated);
			ChatUsersCollection.S_USERLIST_CHANGED.remove(channelUsersChanged);
			
			screen = null;
			
			_height = 0;
			_width = 0;
			
			if (bgRect != null)
				bgRect.setEmpty();
			bgRect = null;
			
			if (bgBMD != null)
				bgBMD.dispose();
			bgBMD = null;
			
			UI.destroy(bg)
			bg = null;
			
			UI.destroy(title)
			title = null;
			
			UI.destroy(statusTxt);
			statusTxt = null;
			
			if (status != null) {
				while (status.numChildren != 0)
					status.removeChild(status.getChildAt(0));
				if (status.parent != null)
					status.parent.removeChild(status);
				status.graphics.clear();
			}
			status = null;
			
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			
			if (infoButton != null)
				infoButton.dispose();
			infoButton = null;
			
			if (lockButton != null)
				lockButton.dispose();
			lockButton = null;
			
			if (settingsButton != null)
				settingsButton.dispose();
			settingsButton = null;
			
			if (callButton != null)
				callButton.dispose();
			callButton = null;
			
			callCallback = null;
			
			icoCall = null;
			icoBack = null;
			icoSettings = null;
			icoInfo = null
			icoBack = null;
			
			UI.disposeBMD(_lockButtonLockedBitmap);
			_lockButtonLockedBitmap = null;
			UI.disposeBMD(_lockButtonUnlockedBitmap);
			_lockButtonUnlockedBitmap = null;
			
			screen = null;
		}
		
		public function setChatScreen(chatScreen:ChatScreen):void {
			screen = chatScreen;
		}
		
		public function setCallCallback(callCallback:Function):void {
			this.callCallback = callCallback;
		}
		
		public function setStartStreamCallback(startStreamCallback:Function):void {
			this.startStreamCallback = startStreamCallback;
		}
		
		private function displayUserStatus():void {
			updateUserStatus();
			if (firstTime == false)
				return;
			firstTime = false;
			status.alpha = 0;
			TweenMax.killTweensOf(status);
			TweenMax.to(status, 0.7, { alpha:1, delay:1 } );
			status.visible = true;
			updateTitleVerticalPosition();
		}
		
		public function updateTitleVerticalPosition():void {
			var space:int = (trueH - title.height - status.height) * .33;
			var newPosition:int = Config.APPLE_TOP_OFFSET + space;
			TweenMax.killTweensOf(title);
			TweenMax.to(title, 0.7, { y:newPosition, delay:1 } );
			status.y = title.y + title.height - space;
			TweenMax.to(status, 0.7, { y:(newPosition + title.height - space), delay:1 } );
		}
		
		public function hide(time:Number = 0.5):void {
			TweenMax.to(bg, time, { alpha:0.3, delay:time * 2 } );
		}
		
		public function show():void {
			bg.alpha = 1;
		}
		
		private function get lockButtonLockedBitmap():BitmapData {
			if (_lockButtonLockedBitmap == null)
				_lockButtonLockedBitmap = UI.renderLockButton(btnSize, btnSize);
			return _lockButtonLockedBitmap;
		}
		
		private function get lockButtonUnlockedBitmap():BitmapData {
			if (_lockButtonUnlockedBitmap == null)
				_lockButtonUnlockedBitmap = UI.renderUnlockButton(btnSize, btnSize);
			return _lockButtonUnlockedBitmap;
		}
		
		public function get height():int {
			return _height;
		}
		
		private function get width():int {
			return _width;
		}
	}
}