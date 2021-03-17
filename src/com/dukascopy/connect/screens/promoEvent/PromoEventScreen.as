package com.dukascopy.connect.screens.promoEvent {
	
	import assets.ActiveUserIcon;
	import assets.DefaultAvatar;
	import assets.Event_type_1_header;
	import assets.Event_type_2_header;
	import assets.Event_type_3_header;
	import assets.Event_type_4_header;
	import assets.IconInfoClip;
	import assets.IllustrationLose;
	import assets.IllustrationWin;
	import assets.WinnersIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.promoEvent.PromoEvent;
	import com.dukascopy.connect.data.promoEvent.PromoEventWinner;
	import com.dukascopy.connect.gui.components.countdown.Countdown;
	import com.dukascopy.connect.gui.components.countdown.CountdownDisplay;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListPromoWinnerRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.promoEvents.PromoEvents;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	/**
	 * @author Sergey Dobarin.
	 */
	
	public class PromoEventScreen extends BaseScreen {
		
		private var actions:Array = [
			{ id:"info", img:IconInfoClip, callback:showInfo }
		];
		
		static public const STATE_IN_PROGRESS:String = "stateInProgress";
		static public const STATE_WIN:String = "stateWin";
		static public const STATE_WIN_NO_PAYMENTS:String = "stateWinNoPayments";
		static public const STATE_LOSE:String = "stateLose";
		static public const STATE_NEW:String = "stateNew";
		static public const STATE_NEED_ACCOUNT:String = "stateNeedAccount";
		static public const STATE_NEED_ACCOUNT_FRIENDS:String = "stateNeedAccountFriends";
		
		private var topBar:TopBarScreen;
		private var eventData:PromoEvent;
		private var image:Bitmap;
		private var title:Bitmap;
		private var text1:Bitmap;
		private var text2:Bitmap;
		private var text3:Bitmap;
		private var participateButton:BitmapButton;
		private var text4:Bitmap;
		private var illustration:Bitmap;
		private var countdown:Timer;
		private var line1:Bitmap;
		private var line2:Bitmap;
		private var headerTitle:Bitmap;
		private var headerValue:Bitmap;
		private var loading:Boolean;
		private var preloader:HorizontalPreloader;
		private var curentState:String;
		private var discussButton:BitmapButton;
		private var winnersButton:BitmapButton;
		private var list:List;
		private var scrollPanel:ScrollPanel;
		private var titleContainer:Sprite;
		private var text1Container:Sprite;
		private var text2Container:Sprite;
		private var text3Container:Sprite;
		private var text4Container:Sprite;
		private var line1Container:Sprite;
		private var illustrationContainer:Sprite;
		private var line2Container:Sprite;
		private var countdownClip:Countdown;
		private var usersNumClip:CountdownDisplay;
		private var openAccountButton:BitmapButton;
		private var inviteButton:BitmapButton;
		private var friend_1:Bitmap;
		private var friend_2:Bitmap;
		private var friend_3:Bitmap;
		
		public function PromoEventScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			scrollPanel = new ScrollPanel();
			view.addChild(scrollPanel.view);
			
			image = new Bitmap();
			scrollPanel.addObject(image);
			
			title = new Bitmap();
			titleContainer = new Sprite();
			titleContainer.addChild(title);
			scrollPanel.addObject(titleContainer);
			
			text1 = new Bitmap();
			text1Container = new Sprite();
			text1Container.addChild(text1);
			scrollPanel.addObject(text1Container);
			
			text2 = new Bitmap();
			text2Container = new Sprite();
			text2Container.addChild(text2);
			scrollPanel.addObject(text2Container);
			
			text3 = new Bitmap();
			text3Container = new Sprite();
			text3Container.addChild(text3);
			scrollPanel.addObject(text3Container);
			
			text4 = new Bitmap();
			text4Container = new Sprite();
			text4Container.addChild(text4);
			scrollPanel.addObject(text4Container);
			
			line1 = new Bitmap();
			line1.bitmapData = UI.getHorizontalLine(3, 0xCE4044);
			line1Container = new Sprite();
			line1Container.addChild(line1);
			scrollPanel.addObject(line1Container);
			
			line2 = new Bitmap();
			line2.bitmapData = UI.getHorizontalLine(3, 0xCE4044);
			line2Container = new Sprite();
			line2Container.addChild(line2);
			scrollPanel.addObject(line2Container);
			
			illustration = new Bitmap();
			illustrationContainer = new Sprite();
			illustrationContainer.addChild(illustration);
			scrollPanel.addObject(illustrationContainer);
			
			participateButton = new BitmapButton();
			participateButton.setStandartButtonParams();
			participateButton.setDownScale(1);
			participateButton.setDownColor(0);
			participateButton.tapCallback = participate;
			participateButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			participateButton.disposeBitmapOnDestroy = true;
			view.addChild(participateButton);
			
			inviteButton = new BitmapButton();
			inviteButton.setStandartButtonParams();
			inviteButton.setDownScale(1);
			inviteButton.setDownColor(0);
			inviteButton.tapCallback = invite;
			inviteButton.disposeBitmapOnDestroy = true;
			inviteButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			view.addChild(inviteButton);
			
			openAccountButton = new BitmapButton();
			openAccountButton.setStandartButtonParams();
			openAccountButton.setDownScale(1);
			openAccountButton.setDownColor(0);
			openAccountButton.tapCallback = openAccount;
			openAccountButton.disposeBitmapOnDestroy = true;
			openAccountButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			view.addChild(openAccountButton);
			
			discussButton = new BitmapButton();
			discussButton.setStandartButtonParams();
			discussButton.setDownScale(1);
			discussButton.setDownColor(0);
			discussButton.tapCallback = discuss;
			discussButton.disposeBitmapOnDestroy = true;
			view.addChild(discussButton);
			
			winnersButton = new BitmapButton();
			winnersButton.setStandartButtonParams();
			winnersButton.setDownScale(1);
			winnersButton.setDownColor(0);
			winnersButton.tapCallback = showWinners;
			winnersButton.disposeBitmapOnDestroy = true;
			view.addChild(winnersButton);
			
			headerTitle = new Bitmap();
			scrollPanel.addObject(headerTitle);
			
			headerValue = new Bitmap();
			scrollPanel.addObject(headerValue);
			
			preloader = new HorizontalPreloader(0xA72487);
			scrollPanel.addObject(preloader);
			
			countdownClip = new Countdown();
			scrollPanel.addObject(countdownClip);
			
			usersNumClip = new CountdownDisplay();
			scrollPanel.addObject(usersNumClip);
			
			friend_1 = new Bitmap();
			scrollPanel.addObject(friend_1);
			
			friend_2 = new Bitmap();
			scrollPanel.addObject(friend_2);
			
			friend_3 = new Bitmap();
			scrollPanel.addObject(friend_3);
		}
		
		private function invite():void 
		{
			PromoEvents.inviteFriends();
		}
		
		private function showInfo():void
		{
			PromoEvents.showRules();
		}
		
		private function showWinners():void 
		{
			scrollPanel.scrollToPosition(0);
			scrollPanel.disable();
			stopTimer();
			title.visible = false;
			text1.visible = false;
			text2.visible = false;
			text3.visible = false;
			text4.visible = false;
			line1.visible = false;
			line2.visible = false;
			
			drawNextButton(Lang.textBack);
			participateButton.tapCallback = onBackPressed;
			
			if (list == null)
			{
				list = new List("PromoEventScreen.winners");
				view.addChild(list.view);
				list.setWidthAndHeight(_width, participateButton.y - topBar.trueHeight - image.height - Config.MARGIN * 2);
				list.setMask(true);
				list.background = true;
				list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);;
				list.view.y = int(image.y + image.height + scrollPanel.view.y);
				
				view.setChildIndex(scrollPanel.view, view.numChildren - 1);
			}
			
			list.S_ITEM_TAP.add(onItemTap);
			list.activate();
			
			winnersButton.alpha = 0.5;
			winnersButton.deactivate();
			
			discussButton.activate();
			
			list.view.visible = true;
			list.view.alpha = 0;
			TweenMax.killTweensOf(list.view);
			TweenMax.to(list.view, 0.5, {alpha:1});
			view.setChildIndex(list.view, view.numChildren - 1);
			
			var winners:Vector.<PromoEventWinner> = PromoEvents.getWinners();
			if (winners != null)
			{
				view.setChildIndex(list.view, view.numChildren - 1);
				list.setData(winners, ListPromoWinnerRenderer);
			}
			else{
				showLoader();
				PromoEvents.loadResult();
			}
			view.setChildIndex(winnersButton, view.numChildren - 1);
			//trace(view.getChildAt(view.numChildren - 2));
		}
		
		private function onBackPressed():void 
		{
			scrollPanel.enable();
			winnersButton.alpha = 1;
			winnersButton.activate();
			
			TweenMax.killTweensOf(list.view);
			list.view.visible = false;
			
			switch(curentState)
			{
				case STATE_NEW:
				{
					curentState = null;
					drawState1();
					break;
				}
				case STATE_IN_PROGRESS:
				{
					curentState = null;
					drawState2();
					break;
				}
				case STATE_LOSE:
				{
					curentState = null;
					drawState5();
					break;
				}
				case STATE_WIN:
				{
					curentState = null;
					drawState3();
					break;
				}
				case STATE_WIN_NO_PAYMENTS:
				{
					curentState = null;
					drawState4();
					break;
				}
			}
		}
		
		private function discuss():void 
		{
			stopTimer();
			var channelId:String = eventData.getChannelId();
			if (channelId != null)
			{
				var chatScreenData:ChatScreenData = new ChatScreenData();
					chatScreenData.chatUID = channelId;
					chatScreenData.type = ChatInitType.CHAT;
					chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
					chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
				MobileGui.showChatScreen(chatScreenData);
			}
		}
		
		private function participate():void 
		{
			title.alpha = 0.3;
			text1.alpha = 0.3;
			text2.alpha = 0.3;
			text3.alpha = 0.3;
			line1.alpha = 0.3;
			line2.alpha = 0.3;
			illustration.alpha = 0.3;
			loading = true;
			participateButton.deactivate();
			winnersButton.deactivate();
			discussButton.deactivate();
			participateButton.alpha = 0.3;
			winnersButton.alpha = 0.3;
			discussButton.alpha = 0.3;
			showLoader();
			PromoEvents.participate(eventData.id);
		}
		
		override protected function drawView():void {
			topBar.drawView(_width);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			
			view.graphics.beginFill(0xFFFFFF);
			view.graphics.drawRect(0, 0, _width, _height);
			view.graphics.endFill();
			
			scrollPanel.view.y = topBar.trueHeight;
			
			image.y = 0;
			
			eventData = data.data as PromoEvent;
			topBar.setData(Lang.events, true, actions);
			preloader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			line1.visible = false;
			line2.visible = false;
			
			var bottomButton:DisplayObject = participateButton;
			
			if (eventData.participant == true) {
				drawState2();
			} else {
				if (eventData.lastResult == PromoEvent.RESULT_WIN) {
					if (PayAPIManager.hasSwissAccount == true) {
						drawState3();
					} else {
						drawState4();
					}
				} else if (eventData.lastResult == PromoEvent.RESULT_LOSE) {
					if (eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_ACCOUNT) {
						if (PayAPIManager.hasSwissAccount == true) {
							drawState5();
						} else {
							bottomButton = openAccountButton;
							drawState6();
						}
					} else if (eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_ACCOUNT_3_FRIENDS) {
						drawState7();
						bottomButton = openAccountButton;
					} else if (eventData.typeParticipate == PromoEvent.PARTICIPATE_FREE) {
						drawState5();
					}  else if (eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_AVATAR) {
						drawState5();
					} else {
						drawState1();
					}
				} else if (eventData.lastResult == PromoEvent.RESULT_NONE) {
					if (eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_ACCOUNT) {
						if (PayAPIManager.hasSwissAccount == true) {
							drawState1();
						} else {
							bottomButton = openAccountButton;
							drawState6();
						}
					} else if (eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_ACCOUNT_3_FRIENDS) {
						drawState7();
						bottomButton = openAccountButton;
					} else if (eventData.typeParticipate == PromoEvent.PARTICIPATE_FREE || eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_AVATAR) {
						drawState1();
					}
				}
			}
			
			preloader.y = Math.floor(image.y + image.height);
			
			PromoEvents.S_ADD.add(onParticipateResult);
			PromoEvents.S_LOAD_END.add(hidePreloader);
			PromoEvents.S_WINNERS.add(onWinners);
			
			scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight - Config.FINGER_SIZE * 1.7 - Config.APPLE_BOTTOM_OFFSET);
		}
		
		private function drawState7():void 
		{
			if (curentState == STATE_NEED_ACCOUNT_FRIENDS)
			{
				return;
			}
			scrollPanel.scrollToPosition(0);
			curentState = STATE_NEED_ACCOUNT_FRIENDS;
			line1.visible = false;
			line2.visible = false;
			
			drawHeader();
			drawTitle(Lang.youcantParticiparteInEventNeedAccountAndFriends);
			
			title.visible = true;
			
			titleContainer.y = image.y + image.height + Config.FINGER_SIZE;
			
			preloader.start();
			PromoEvents.getInvitesInfo(eventData.id);
			PromoEvents.S_ACCESS_RESULT.add(onAccessRespond);
			openAccountButton.y = _height - openAccountButton.height - Config.DOUBLE_MARGIN * 2;
		}
		
		private function onAccessRespond(id:String, success:Boolean, needAccount:Boolean, usersInvited:int):void 
		{
			if (isDisposed)
			{
				PromoEvents.S_ACCESS_RESULT.remove(onAccessRespond);
				return;
			}
			
			if (id == eventData.id)
			{
				PromoEvents.S_ACCESS_RESULT.remove(onAccessRespond);
				preloader.stop();
				
				if (success)
				{
					if (needAccount == false && success == true && usersInvited >= 3)
					{
						drawState1();
						return;
					}	
					
					var size:int = Config.FINGER_SIZE;
					var iconActive:ActiveUserIcon = new ActiveUserIcon();
					UI.scaleToFit(iconActive, size, size);
					
					var iconUnactive:DefaultAvatar = new DefaultAvatar();
					UI.scaleToFit(iconUnactive, size, size);
					
					if (friend_1.bitmapData != null)
					{
						friend_1.bitmapData.dispose();
						friend_1.bitmapData = null;
					}
					if (friend_2.bitmapData != null)
					{
						friend_2.bitmapData.dispose();
						friend_2.bitmapData = null;
					}
					if (friend_3.bitmapData != null)
					{
						friend_3.bitmapData.dispose();
						friend_3.bitmapData = null;
					}
					
					if (usersInvited > 0)
					{
						friend_1.bitmapData = UI.getSnapshot(iconActive, StageQuality.HIGH, "PromoEventScreen.avatar")
					}
					else
					{
						friend_1.bitmapData = UI.getSnapshot(iconUnactive, StageQuality.HIGH, "PromoEventScreen.avatar")
					}
					
					if (usersInvited > 1)
					{
						friend_2.bitmapData = UI.getSnapshot(iconActive, StageQuality.HIGH, "PromoEventScreen.avatar")
					}
					else
					{
						friend_2.bitmapData = UI.getSnapshot(iconUnactive, StageQuality.HIGH, "PromoEventScreen.avatar")
					}
					
					if (usersInvited > 2)
					{
						friend_3.bitmapData = UI.getSnapshot(iconActive, StageQuality.HIGH, "PromoEventScreen.avatar")
					}
					else
					{
						friend_3.bitmapData = UI.getSnapshot(iconUnactive, StageQuality.HIGH, "PromoEventScreen.avatar")
					}
					
					friend_2.x = int(_width * .5 - friend_2.width * .5);
					friend_1.x = int(friend_2.x - Config.FINGER_SIZE * .2 - friend_2.width);
					friend_3.x = int(friend_2.x + friend_2.width + Config.FINGER_SIZE * .2);
					
					var text:TextFieldSettings;
					var buttonBitmap:ImageBitmapData;
					if (needAccount)
					{
						text = new TextFieldSettings(Lang.openAccount, 0xFFFFFF, Config.FINGER_SIZE * .34, TextFormatAlign.CENTER);
						buttonBitmap = TextUtils.createbutton(text, 0x68B539, 1, Config.FINGER_SIZE * .6);
						if (buttonBitmap.width > _width - Config.DIALOG_MARGIN*2)
						{
							buttonBitmap.dispose();
							buttonBitmap = TextUtils.createbutton(text, 0x68B539, 1, -1, NaN, _width - Config.DIALOG_MARGIN * 2);
						}
					}
					else
					{
						text = new TextFieldSettings(Lang.accountOpened, 0x68B539, Config.FINGER_SIZE * .34, TextFormatAlign.CENTER);
						buttonBitmap = TextUtils.createbutton(text, 0x68B539, 0, Config.FINGER_SIZE * .6);
						if (buttonBitmap.width > _width - Config.DIALOG_MARGIN*2)
						{
							buttonBitmap.dispose();
							buttonBitmap = TextUtils.createbutton(text, 0x68B539, 0, -1, NaN, _width - Config.DIALOG_MARGIN * 2);
						}
					}
					openAccountButton.setBitmapData(buttonBitmap, true);
					openAccountButton.x = int((_width - openAccountButton.width) * .5);
					
					
					if (needAccount)
					{
						text = new TextFieldSettings(Lang.inviteFriends, 0xFFFFFF, Config.FINGER_SIZE * .34, TextFormatAlign.CENTER);
						buttonBitmap = TextUtils.createbutton(text, 0xC5D1DB, 1, Config.FINGER_SIZE * .6);
						if (buttonBitmap.width > _width - Config.DIALOG_MARGIN*2)
						{
							buttonBitmap.dispose();
							buttonBitmap = TextUtils.createbutton(text, 0xC5D1DB, 1, -1, NaN, _width - Config.DIALOG_MARGIN * 2);
						}
					}
					else
					{
						text = new TextFieldSettings(Lang.inviteFriends, 0xFFFFFF, Config.FINGER_SIZE * .34, TextFormatAlign.CENTER);
						buttonBitmap = TextUtils.createbutton(text, 0x68B539, 1, Config.FINGER_SIZE * .6);
						if (buttonBitmap.width > _width - Config.DIALOG_MARGIN*2)
						{
							buttonBitmap.dispose();
							buttonBitmap = TextUtils.createbutton(text, 0x68B539, 1, -1, NaN, _width - Config.DIALOG_MARGIN * 2);
						}
					}
					inviteButton.setBitmapData(buttonBitmap, true);
					inviteButton.x = int((_width - inviteButton.width) * .5);
					
					if (isActivated)
					{
						if (needAccount == true)
						{
							openAccountButton.activate();
						}
						else
						{
							inviteButton.visible = true;
							inviteButton.activate();
						}
					}
					inviteButton.y = _height - openAccountButton.height - Config.DOUBLE_MARGIN * 2;
					openAccountButton.y = inviteButton.y - inviteButton.height - Config.DOUBLE_MARGIN;
					
					title.visible = true;
					
					titleContainer.y = image.y + image.height + Config.FINGER_SIZE;
					
					friend_1.alpha = 0;
					friend_2.alpha = 0;
					friend_3.alpha = 0;
					
					TweenMax.to(friend_1, 0.3, {alpha:1, delay:0});
					TweenMax.to(friend_2, 0.3, {alpha:1, delay:0.1});
					TweenMax.to(friend_3, 0.3, {alpha:1, delay:0.2});
					
					friend_1.y = friend_2.y = friend_3.y = int(titleContainer.y + titleContainer.height + Config.FINGER_SIZE * .6);
				}
				else
				{
					ToastMessage.display(Lang.connectionError);
					onBack();
				}
			}
			scrollPanel.setWidthAndHeight(_width, inviteButton.y - topBar.trueHeight - Config.DOUBLE_MARGIN);
		}
		
		private function drawState6():void 
		{
			if (curentState == STATE_NEED_ACCOUNT)
			{
				return;
			}
			scrollPanel.scrollToPosition(0);
			curentState = STATE_NEED_ACCOUNT;
			line1.visible = false;
			line2.visible = false;
			
			drawHeader();
			drawTitle(Lang.youcantParticiparteInEventNoBankAccount);
			
			var text:TextFieldSettings = new TextFieldSettings(Lang.openAccount, 0xFFFFFF, Config.FINGER_SIZE * .34, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(text, 0x68B539, 1, Config.FINGER_SIZE * .6);
			if (buttonBitmap.width > _width - Config.DIALOG_MARGIN*2)
			{
				buttonBitmap.dispose();
				buttonBitmap = TextUtils.createbutton(text, 0x68B539, 1, -1, NaN, _width - Config.DIALOG_MARGIN*2);
			}
			openAccountButton.setBitmapData(buttonBitmap, true);
			openAccountButton.x = int((_width - openAccountButton.width) * .5);
			if (isActivated)
			{
				openAccountButton.activate();
			}
			openAccountButton.y = _height - openAccountButton.height - Config.DOUBLE_MARGIN * 2;			
			
			title.visible = true;
			
			titleContainer.y = int(image.y + image.height + (openAccountButton.y - image.y - image.height) * .5 - titleContainer.height * .5);
		}
		
		private function onWinners():void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (list != null && list.view.visible)
			{
				hidePreloader();
				var winners:Vector.<PromoEventWinner> = PromoEvents.getWinners();
				
				view.setChildIndex(list.view, view.numChildren - 1);
				list.setData(winners, ListPromoWinnerRenderer);
				return;
			}
			
			var eventWinner:PromoEventWinner = PromoEvents.getWinner(eventData.id);
			if (eventWinner != null)
			{
				PromoEvents.clearCurrent();
				if (eventWinner.userUID == Auth.uid)
				{
					if (PayAPIManager.hasSwissAccount == true)
					{
						drawState3(true);
					}
					else{
						drawState4(true);
					}
				}
				else{
					drawState5();
				}
			}
		}
		
		private function onParticipateResult(eventId:String, success:Boolean, message:String = null):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (eventData == null || eventData.id != eventId)
			{
				return;
			}
			hidePreloader();
			loading = false;
			if (success)
			{
				title.alpha = 1;
				illustration.alpha = 1;
				
				text1.alpha = 1;
				text2.alpha = 1;
				text3.alpha = 1;
				text4.alpha = 1;
				
				line1.alpha = 1;
				line2.alpha = 1;
				
				
				showButtons();
				
				drawState2();
			}
			else
			{
				title.alpha = 1;
				illustration.alpha = 1;
				
				text1.alpha = 1;
				text2.alpha = 1;
				text3.alpha = 1;
				text4.alpha = 1;
				
				line1.alpha = 1;
				line2.alpha = 1;
				showButtons();
				
				if (message != null)
				{
					ToastMessage.display(message);
				}
			}
		}
		
		private function showButtons():void 
		{
			participateButton.visible = true;
			winnersButton.visible = true;
			discussButton.visible = true;
			participateButton.activate();
			winnersButton.activate();
			discussButton.activate();
			participateButton.alpha = 1;
			winnersButton.alpha = 1;
			discussButton.alpha = 1;
		}
		
		private function drawState5(showBackButton:Boolean = false):void 
		{
			if (curentState == STATE_LOSE)
			{
				return;
			}
			scrollPanel.scrollToPosition(0);
			curentState = STATE_LOSE;
			
			illustration.visible = true;
			showButtons();
			title.visible = true;
			text1.visible = true;
			text2.visible = false;
			text3.visible = false;
			text4.visible = false;
			
			drawHeader();
			drawTitle(Lang.youLose);
			drawText1(Lang.tryAgain);
			if (showBackButton)
			{
				participateButton.tapCallback = onBack;
				drawNextButton(Lang.textBack);
			}
			else{
				participateButton.tapCallback = participate;
				drawNextButton(Lang.buttonJoin);
			}
			
			var position:int = image.y + image.height;
			position += Config.FINGER_SIZE * .5;
			
			titleContainer.y = position;
			position += title.height + Config.FINGER_SIZE * .5;
			
			text1Container.y = position;
			position += text1.height + Config.FINGER_SIZE * .5;
			
			drawIllustration(new IllustrationLose(), _height - position - Config.FINGER_SIZE*.7 - participateButton.height);
			illustrationContainer.y = position;
			illustration.x = int(_width * .5 - illustration.width * .5);
			
			position += illustration.height + Config.DOUBLE_MARGIN;
			
		//	participateButton.y = Math.min(position, _height - Config.APPLE_BOTTOM_OFFSET - participateButton.height - Config.DOUBLE_MARGIN);
			participateButton.y = _height - participateButton.height - Config.DOUBLE_MARGIN * 2;
			discussButton.y = winnersButton.y = participateButton.y;
		}
		
		private function drawState4(showBackButton:Boolean = false):void 
		{
			if (curentState == STATE_WIN_NO_PAYMENTS)
			{
				return;
			}
			scrollPanel.scrollToPosition(0);
			curentState = STATE_WIN_NO_PAYMENTS;
			
			illustration.visible = true;
			showButtons();
			title.visible = true;
			text1.visible = true;
			text2.visible = true;
			text2.visible = false;
			text3.visible = false;
			text4.visible = false;
			
			participateButton.tapCallback = openAccount;
			drawHeader();
			drawTitle(Lang.youWin);
			drawText1(Lang.openAccountToGet);
			if (showBackButton)
			{
				participateButton.tapCallback = onBack;
				drawNextButton(Lang.textBack);
			}
			else{
				participateButton.tapCallback = participate;
				drawNextButton(Lang.buttonJoin);
			}
			var position:int = image.y + image.height;
			position += Config.FINGER_SIZE * .5;
			
			titleContainer.y = position;
			position += title.height + Config.FINGER_SIZE * .5;
			
			text1Container.y = position;
			position += text1.height + Config.FINGER_SIZE * .5;
			
			drawIllustration(new IllustrationWin(), _height - position - Config.FINGER_SIZE * 1.2 - participateButton.height);
			illustrationContainer.y = position;
			illustration.x = int(_width * .5 - illustration.width * .5);
			
			position += illustration.height + Config.DOUBLE_MARGIN;
		//	participateButton.y = Math.min(position, _height - Config.APPLE_BOTTOM_OFFSET - participateButton.height - Config.DOUBLE_MARGIN);
			participateButton.y = _height - participateButton.height - Config.DOUBLE_MARGIN * 2;
			discussButton.y = winnersButton.y = participateButton.y;
		}
		
		private function openAccount():void 
		{
			MobileGui.showRoadMap();
		}
		
		private function drawState3(showBackButton:Boolean = false):void 
		{
			if (curentState == STATE_WIN)
			{
				return;
			}
			scrollPanel.scrollToPosition(0);
			curentState = STATE_WIN;
			
			illustration.visible = true;
			participateButton.visible = true;
			participateButton.alpha = 1;
			participateButton.activate();
			title.visible = true;
			text1.visible = true;
			text2.visible = false;
			text3.visible = false;
			text4.visible = false;
			
			drawHeader();
			drawTitle(Lang.youWin);
			if (eventData.type == PromoEvent.TYPE_IPHONE)
			{
				drawText1(Lang.weWillCallYou);
			}
			else if (eventData.type == PromoEvent.TYPE_MONEY)
			{
				drawText1(Lang.checkYourAccount);
			}
			if (showBackButton)
			{
				participateButton.tapCallback = onBack;
				drawNextButton(Lang.textBack);
			}
			else{
				participateButton.tapCallback = participate;
				drawNextButton(Lang.buttonJoin);
			}
			
			var position:int = image.y + image.height;
			position += Config.FINGER_SIZE * .5;
			
			titleContainer.y = position;
			position += title.height + Config.FINGER_SIZE * .5;
			
			text1Container.y = position;
			position += text1.height + Config.FINGER_SIZE * .5;
			
			drawIllustration(new IllustrationWin(), _height - position - Config.FINGER_SIZE * 1.2 - participateButton.height);
			illustrationContainer.y = position;
			illustration.x = int(_width * .5 - illustration.width * .5);
			
			position += illustration.height + Config.DOUBLE_MARGIN;
		//	participateButton.y = Math.min(position, _height - Config.APPLE_BOTTOM_OFFSET - participateButton.height - Config.DOUBLE_MARGIN);
			participateButton.y = _height - participateButton.height - Config.DOUBLE_MARGIN * 2;
			discussButton.y = winnersButton.y = participateButton.y;
		}
		
		private function drawIllustration(illustrationWin:Sprite, illustrationHeight:int):void 
		{
			UI.scaleToFit(illustrationWin, _width - Config.FINGER_SIZE*2, illustrationHeight);
			illustration.bitmapData = UI.getSnapshot(illustrationWin);
		}
		
		private function drawState2():void 
		{
			if (curentState == STATE_IN_PROGRESS)
			{
				return;
			}
			scrollPanel.scrollToPosition(0);
			scrollPanel.scrollToPosition(0);
			curentState = STATE_IN_PROGRESS;
			
			line1.visible = false;
			line2.visible = false;
			illustration.visible = false;
			
			title.visible = true;
			text1.visible = false;
			text2.visible = false;
			text3.visible = true;
			text4.visible = false;
			discussButton.visible = true;
			usersNumClip.visible = true;
			countdownClip.visible = true;
			
			countdownClip.setWidth(_width - Config.DIALOG_MARGIN * 3.5);
			countdownClip.x = int(_width * .5 - countdownClip.width * .5);
			
			usersNumClip.setHeight(Config.FINGER_SIZE * 1.5);
			usersNumClip.setValue(eventData.cnt, true);
			usersNumClip.x = int(_width * .5 - usersNumClip.width * .5);
			
			onTick();
			
			drawHeader();
			drawTitle(Lang.youAlreadyInEvent, false);
		//	drawText1(Lang.waitForResult);
			drawText3(Lang.usersInEventRegistered);
		//	drawText4("<b>" + eventData.cnt.toString() + "</b>", 0x000000, Config.FINGER_SIZE * .38);
			drawNextButton(Lang.discuss, false);
			participateButton.tapCallback = discuss;
			
			var position:int = image.y + image.height;
			position += Config.FINGER_SIZE * .4;
			
			titleContainer.y = position;
			position += title.height + Config.FINGER_SIZE * .4;
			
			countdownClip.y = position;
			position += countdownClip.height + Config.FINGER_SIZE * 0.4;
			
			usersNumClip.y = position;
			position += usersNumClip.height + Config.FINGER_SIZE * .25;
			
			text3Container.y = position;
			position += text3.height + Config.FINGER_SIZE * .5;
			
			text4Container.y = position;
			position += text4.height + Config.FINGER_SIZE * .5;
			
			participateButton.y = _height - participateButton.height - Config.DOUBLE_MARGIN * 2;
			discussButton.y = winnersButton.y = participateButton.y;
			
			scrollPanel.update();
			
			startTimer();
		}
		
		private function startTimer():void 
		{
			stopTimer();
			countdown = new Timer(1000, 0);
			countdown.addEventListener(TimerEvent.TIMER, onTick);
			countdown.start();
		}
		
		private function onTick(e:TimerEvent = null):void 
		{
			if (isDisposed)
			{
				stopTimer();
				return;
			}
			var timeToEnd:Number = calcTime();
			if (timeToEnd < 0)
			{
				stopTimer();
				countdownClip.setValue(0);
			//	drawText2("<b>" + "00:00:00" + "</b>", 0x000000, Config.FINGER_SIZE * .38, false);
				loadResult();
			}
			else{
				countdownClip.setValue(timeToEnd);
			//	drawText2("<b>" + DateUtils.getTimeInNumbers(timeToEnd) + "</b>", 0x000000, Config.FINGER_SIZE * .38, false);
			}
		}
		
		private function stopTimer():void 
		{
			if (countdown != null)
			{
				countdown.removeEventListener(TimerEvent.TIMER, onTick);
				countdown.stop();
			}
		}
		
		private function loadResult():void 
		{
			showLoader();
			PromoEvents.loadResult();
		}
		
		private function hidePreloader():void 
		{
			if (isDisposed)
			{
				return;
			}
			preloader.stop();
		}
		
		private function showLoader():void 
		{
			if (isDisposed)
			{
				return;
			}
			preloader.start();
		}
		
		private function calcTime():Number 
		{
			var current:Number = (new Date()).getTime() / 1000;
			return (eventData.stop - current) * 1000;
		}
		
		private function drawState1():void 
		{
			if (curentState == STATE_NEW)
			{
				return;
			}
			scrollPanel.scrollToPosition(0);
			curentState = STATE_NEW;
			line1.visible = true;
			line2.visible = true;
			
			drawHeader();
			
			var titleText:String;
			var text1_value:String;
			var text2_value:String;
			var text3_value:String;
			
			if (eventData.type == PromoEvent.TYPE_MONEY)
			{
				titleText = Lang.promoEventTitle;
				titleText = LangManager.replace(Lang.regExtValue, titleText, eventData.amount + " " + getCurrency());
				
				if (eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_ACCOUNT)
				{
					text1_value = Lang.promoEvent_type_money100_text_1;
					text2_value = Lang.promoEvent_type_money100_text_2;
					text3_value = Lang.promoEvent_type_money100_text_3;
				}
				else if (eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_ACCOUNT_3_FRIENDS)
				{
					text1_value = Lang.promoEvent_type_money200_text_1;
					text2_value = Lang.promoEvent_type_money200_text_2;
					text3_value = Lang.promoEvent_type_money200_text_3;
				}
				else if (eventData.typeParticipate == PromoEvent.PARTICIPATE_NEED_AVATAR)
				{
					text1_value = Lang.promoEvent_type_money5_text_1;
					text2_value = Lang.promoEvent_type_money5_text_2;
					text3_value = Lang.promoEvent_type_money5_text_3;
				}
				else if (eventData.typeParticipate == PromoEvent.PARTICIPATE_FREE)
				{
					text1_value = Lang.promoEvent_type_money_text_1;
					text2_value = Lang.promoEvent_type_money_text_2;
					text3_value = Lang.promoEvent_type_money_text_3;
				}
			}
			else{
				titleText = Lang.promoEventTitleIphone;
				
				text1_value = Lang.promoEvent_type_prize_text_1;
				text2_value = Lang.promoEvent_type_prize_text_2;
				text3_value = Lang.promoEvent_type_prize_text_3;
			}
			
			title.visible = true;
			text1.visible = true;
			text2.visible = true;
			text3.visible = true;
			
			drawTitle(titleText);
			
			drawText1(text1_value);
			drawText2(text2_value);
			drawText3(text3_value);
			drawNextButton(Lang.promoJoin);
			participateButton.tapCallback = participate;
			
			line1.width = int(Config.FINGER_SIZE * .7);
			line2.width = int(Config.FINGER_SIZE * .7);
			
			var position:int = image.y + image.height;
			position += Config.FINGER_SIZE * .7;
			
			line1.x = int(_width * .5 - line1.width * .5);
			line2.x = int(_width * .5 - line2.width * .5);
			
			titleContainer.y = position;
			position += title.height + Config.FINGER_SIZE * .6;
			
			text1Container.y = position;
			position += text1.height + Config.FINGER_SIZE * .6;
			
			line1Container.y = int(position - Config.FINGER_SIZE * .3);
			
			text2Container.y = position;
			position += text2.height + Config.FINGER_SIZE * .6;
			
			line2Container.y = int(position - Config.FINGER_SIZE * .3);
			
			text3Container.y = position;
			position += text3.height + Config.FINGER_SIZE * .6;
			
		//	participateButton.y = Math.min(position, _height - Config.APPLE_BOTTOM_OFFSET - participateButton.height - Config.DOUBLE_MARGIN);
			participateButton.y = _height - participateButton.height - Config.DOUBLE_MARGIN * 2;
			discussButton.y = winnersButton.y = participateButton.y;
			
			scrollPanel.update();
		}
		
		private function drawTitle(text:String, animate:Boolean = true):void 
		{
			TweenMax.killTweensOf(title);
			if (title.bitmapData != null) {
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(text, _width - Config.FINGER_SIZE, 10, 
															true, TextFormatAlign.CENTER, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .40, 
															true, 0x596269, 0xFFFFFF, true, true);
			title.x = int(_width * .5 - title.width * .5);
			if (animate)
			{
				title.alpha = 0;
				TweenMax.to(title, 0.5, {alpha:1, delay:0.5});
			}
		}
		
		private function drawText1(text:String, color:Number = 0x596269):void 
		{
			drawText(text1, text, false, color);
		}
		
		private function drawText2(text:String, color:Number = 0x596269, size:Number = NaN, animate:Boolean = true):void 
		{
			if (isNaN(size))
			{
				size = Config.FINGER_SIZE * .28;
			}
			drawText(text2, text, true, color, size, animate);
		}
		
		private function drawText3(text:String, color:Number = 0x596269):void 
		{
			drawText(text3, text, false, color);
		}
		
		private function drawText4(text:String, color:Number = 0x596269, size:Number = NaN):void 
		{
			if (isNaN(size))
			{
				size = Config.FINGER_SIZE * .28;
			}
			drawText(text4, text, true, color, size);
		}
		
		private function drawText(text:Bitmap, value:String, html:Boolean = false, color:Number = 0x596269, size:Number = NaN, animate:Boolean = true):void 
		{
			TweenMax.killTweensOf(text);
			if (isNaN(size))
			{
				size = Config.FINGER_SIZE * .30;
			}
			if (text.bitmapData != null) {
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
			
			text.bitmapData = TextUtils.createTextFieldData(value, _width - Config.FINGER_SIZE * 2, 10, 
															true, TextFormatAlign.CENTER, 
															TextFieldAutoSize.LEFT, size, 
															true, color, 0xFFFFFF, true, html);
			text.x = int(_width * .5 - text.width * .5);
			if (animate)
			{
				text.alpha = 0.5;
				TweenMax.to(text, 0.5, {alpha:1, delay:0.5});
			}
			else{
				text.alpha = 1;
			}
		}
		
		private function drawNextButton(text:String, drawDiscussButton:Boolean = true):void 
		{
			var textDone:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .34, TextFormatAlign.CENTER);
			
			var buttonHeight:int = Config.MARGIN * 2  + Config.FINGER_SIZE * .34 * 1.33 + 4;
			var maxWidth:int = _width - buttonHeight - Config.MARGIN * 3;
			if (drawDiscussButton)
			{
				maxWidth += buttonHeight + Config.MARGIN;
			}
			
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textDone, 0x68B539, 1, Config.FINGER_SIZE * .6);
			if (buttonBitmap.width > maxWidth)
			{
				buttonBitmap.dispose();
				buttonBitmap = TextUtils.createbutton(textDone, 0x68B539, 1, -1, NaN, maxWidth);
			}
			participateButton.setBitmapData(buttonBitmap, true);
			
			var buttonRadius:int = participateButton.height * .5;
			
			var clipDiscuss:Sprite = new Sprite();
			clipDiscuss.graphics.beginFill(0x68B539);
			clipDiscuss.graphics.drawCircle(buttonRadius, buttonRadius, buttonRadius);
			clipDiscuss.graphics.endFill();
			var iconDiscuss:IconChatsS = new IconChatsS();
			UI.scaleToFit(iconDiscuss, buttonRadius * 1.0, buttonRadius * 1.0);
			clipDiscuss.addChild(iconDiscuss);
			iconDiscuss.x = int(buttonRadius - iconDiscuss.width * .5);
			iconDiscuss.y = int(buttonRadius - iconDiscuss.height * .5);
			discussButton.setBitmapData(UI.getSnapshot(clipDiscuss, StageQuality.HIGH, "PromoEventScreen.discussButton"), true);
			discussButton.visible = drawDiscussButton;
			
			var clipWinner:Sprite = new Sprite();
			clipWinner.graphics.beginFill(0x68B539);
			clipWinner.graphics.drawCircle(buttonRadius, buttonRadius, buttonRadius);
			clipWinner.graphics.endFill();
			var iconWinner:WinnersIcon = new WinnersIcon();
			UI.scaleToFit(iconWinner, buttonRadius * 1.0, buttonRadius * 1.0);
			clipWinner.addChild(iconWinner);
			iconWinner.x = int(buttonRadius - iconWinner.width * .5);
			iconWinner.y = int(buttonRadius - iconWinner.height * .5);
			winnersButton.setBitmapData(UI.getSnapshot(clipWinner, StageQuality.HIGH, "PromoEventScreen.winnersButton"), true);
			
			var posX:int;
			if (drawDiscussButton)
			{
				posX = int((_width - participateButton.width - buttonRadius * 4 - Config.MARGIN * 2) * .5);
			}
			else{
				posX = int((_width - participateButton.width - buttonRadius * 2 - Config.MARGIN * 1) * .5);
			}
			
			participateButton.x = posX;
		//	participateButton.x = 0;
			winnersButton.x = int(participateButton.x + participateButton.width + Config.MARGIN);
			discussButton.x = int(winnersButton.x + winnersButton.width + Config.MARGIN);
		}
		
		private function drawHeader():void 
		{
			var source:Sprite;
			if (eventData.image == PromoEvent.IMAGE_TYPE_1)
			{
				source = new Event_type_1_header();
			}
			else if (eventData.image == PromoEvent.IMAGE_TYPE_2)
			{
				source = new Event_type_2_header();
			}
			else if (eventData.image == PromoEvent.IMAGE_TYPE_3)
			{
				source = new Event_type_3_header();
			}
			else if (eventData.image == PromoEvent.IMAGE_TYPE_4)
			{
				source = new Event_type_4_header();
			}
			else if (eventData.image == PromoEvent.IMAGE_TYPE_5)
			{
				source = new Event_type_5_header();
			}
			else if (eventData.image == PromoEvent.IMAGE_TYPE_6)
			{
				source = new Event_type_6_header();
			}
			else if (eventData.image == PromoEvent.IMAGE_TYPE_8)
			{
				source = new Event_type_7_header();
			}
			else if (eventData.image == PromoEvent.IMAGE_TYPE_9)
			{
				source = new Event_type_8_header();
			}
			
			if (source == null)
			{
				return;
			}
			
			source.width = _width;
			source.scaleY = source.scaleX;
			source.height = source.height;
			
			if (image.bitmapData != null)
			{
				image.bitmapData.dispose();
				image.bitmapData = null;
			}
			
			image.bitmapData = new ImageBitmapData("ListPromoEvent.header", source.width, Math.floor(source.height) - 2);
			image.bitmapData.drawWithQuality(source, source.transform.matrix, null, null, null, false, StageQuality.HIGH);
			
			if (headerTitle.bitmapData != null)
			{
				headerTitle.bitmapData.dispose();
				headerTitle.bitmapData = null;
			}
			
			if (headerValue.bitmapData != null)
			{
				headerValue.bitmapData.dispose();
				headerValue.bitmapData = null;
			}
			
			var size:int = Config.FINGER_SIZE * .8;
			if (eventData.type == PromoEvent.TYPE_MONEY)
			{
				size = Config.FINGER_SIZE * 1.6;
			}
			
			headerTitle.bitmapData = TextUtils.createTextFieldData(eventData.getDescription(), _width*.6, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .34, 
															true, 0xFFFFFF, 0xFFFFFF, true);
			
			var prizeText:String;
			if (eventData.type == PromoEvent.TYPE_MONEY)
			{
				prizeText = eventData.amount + getCurrency();
			}
			else if (eventData.type == PromoEvent.TYPE_IPHONE)
			{
				prizeText = Lang.iphoneX;
			}
			headerValue.bitmapData = TextUtils.createTextFieldData(prizeText, _width*1.3, 10, 
															false, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, size, 
															false, 0xFFFFFF, 0xFFFFFF, true, true);
			
			var xPos:int;
			
			if (headerValue.width > _width * .55)
			{
				headerValue.smoothing = true;
				headerValue.width = _width * .55;
				headerValue.scaleY = headerValue.scaleX;
			}
			
			if (eventData.image == PromoEvent.IMAGE_TYPE_1 || eventData.image == PromoEvent.IMAGE_TYPE_3 || eventData.image == PromoEvent.IMAGE_TYPE_5 || 
				eventData.image == PromoEvent.IMAGE_TYPE_6 || eventData.image == PromoEvent.IMAGE_TYPE_8 || eventData.image == PromoEvent.IMAGE_TYPE_9)
			{
				xPos = _width - headerTitle.width - Config.FINGER_SIZE * .3;
				headerValue.x = _width - headerValue.width - Config.FINGER_SIZE * .3;
			}
			else if (eventData.image == PromoEvent.IMAGE_TYPE_2 || eventData.image == PromoEvent.IMAGE_TYPE_4)
			{
				xPos = Config.FINGER_SIZE * .3;
				headerValue.x = xPos;
			}
			
			headerTitle.x = xPos;
			
		//	var margin:int = (image.height - headerTitle.height - headerValue.height) / 3;
			var margin:int = Config.FINGER_SIZE * .3;
			
			headerValue.y = image.y + image.height - headerValue.height - Config.MARGIN * 2;
			headerTitle.y = Math.max(headerValue.y - headerTitle.height - Config.MARGIN * 2, image.y + Config.MARGIN);
		}
		
		private function getCurrency():String 
		{
			if (eventData.currency == TypeCurrency.EUR)
			{
				return "€";
			}
			else if (eventData.currency == "DUK")
			{
				return " DUK+"
			}
			return eventData.currency;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			
			if (topBar != null)
				topBar.activate();
			if (participateButton.visible && loading == false)
			{
				participateButton.activate();
			}
			if (winnersButton.visible && loading == false)
			{
				winnersButton.activate();
			}
			if (discussButton.visible && loading == false)
			{
				discussButton.activate();
			}
			if (openAccountButton.visible && loading == false)
			{
				openAccountButton.activate();
			}
			if (inviteButton.visible && loading == false)
			{
				inviteButton.activate();
			}
			if (list != null && list.view.visible)
			{
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			if (list == null || list.view.visible == false)
			{
				scrollPanel.enable();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (topBar != null)
				topBar.deactivate();
			participateButton.deactivate();
			discussButton.deactivate();
			openAccountButton.deactivate();
			inviteButton.deactivate();
			winnersButton.deactivate();
			if (list != null)
			{
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			scrollPanel.disable();
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (data is PromoEventWinner) {
				
				if ((data as PromoEventWinner).userUID == Auth.uid)
				{
					return;
				}
				
				var user:UserVO = (data as PromoEventWinner).user;
				if (user == null)
				{
					user = UsersManager.getFullUserData((data as PromoEventWinner).userUID);
				}
				if (user != null)
				{
					MobileGui.changeMainScreen(UserProfileScreen, {data:user, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:this.data});
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (list != null)
			{
				TweenMax.killTweensOf(list.view);
			}
			
			TweenMax.killTweensOf(title);
			TweenMax.killTweensOf(text1);
			TweenMax.killTweensOf(text2);
			TweenMax.killTweensOf(text3);
			TweenMax.killTweensOf(text4);
			eventData = null;
			
			PromoEvents.S_ACCESS_RESULT.remove(onAccessRespond);
			PromoEvents.S_ADD.remove(onParticipateResult);
			PromoEvents.S_LOAD_END.remove(hidePreloader);
			PromoEvents.S_WINNERS.remove(onWinners);
			
			if (countdownClip != null)
				countdownClip.dispose();
			countdownClip = null;
			
			if (usersNumClip != null)
				usersNumClip.dispose();
			usersNumClip = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (image != null)
				UI.destroy(image);
			image = null;
			
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			
			if (title != null)
				UI.destroy(title);
			title = null;
			
			if (friend_1 != null)
			{
				TweenMax.killTweensOf(friend_1);
				UI.destroy(friend_1);
			}
			friend_1 = null;
			
			if (friend_2 != null)
			{
				TweenMax.killTweensOf(friend_2);
				UI.destroy(friend_2);
			}
			friend_2 = null;
			
			if (friend_3 != null)
			{
				TweenMax.killTweensOf(friend_3);
				UI.destroy(friend_3);
			}
			friend_3 = null;
			
			if (text1 != null)
				UI.destroy(text1);
			text1 = null;
			
			if (text2 != null)
				UI.destroy(text2);
			text2 = null;
			
			if (text3 != null)
				UI.destroy(text3);
			text3 = null;
			
			if (participateButton != null)
				participateButton.dispose();
			participateButton = null;
			
			if (discussButton != null)
				discussButton.dispose();
			discussButton = null;
			
			if (openAccountButton != null)
				openAccountButton.dispose();
			openAccountButton = null;
			
			if (inviteButton != null)
				inviteButton.dispose();
			inviteButton = null;
			
			if (winnersButton != null)
				winnersButton.dispose();
			winnersButton = null;
			
			if (text4 != null)
				UI.destroy(text4);
			text4 = null;
			
			if (illustration != null)
				UI.destroy(illustration);
			illustration = null;
			
			if (countdown != null)
			{
				try
				{
					countdown.stop();
				}
				catch (e:Error)
				{
					
				}
				countdown = null;
			};
			
			if (line1 != null)
				UI.destroy(line1);
			line1 = null;
			
			if (line2 != null)
				UI.destroy(line2);
			line2 = null;
			
			if (headerTitle != null)
				UI.destroy(headerTitle);
			headerTitle = null;
			
			if (headerValue != null)
				UI.destroy(headerValue);
			headerValue = null;
			
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			
			if (list != null)
				list.dispose();
			list = null;
		}
	}
}