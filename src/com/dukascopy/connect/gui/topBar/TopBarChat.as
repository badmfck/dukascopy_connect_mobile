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
			
			status = new Sprite();
			status.visible = false;
			statusTxt = new Bitmap(null, "auto", true);
			status.addChild(statusTxt);
			_view.addChild(status);
			
			
			
			
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
			
			if (infoButton != null)
				infoButton.dispose();
			infoButton = null;
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
	}
}