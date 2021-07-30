package com.dukascopy.connect.screens.promocodes
{
	
	import assets.StatusCompleteIcon;
	import assets.StatusPendingIcon;
	import assets.StatusRejectcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.ReferralInvitesListScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.BottomAlertPopup;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.BaseGraphicsUtils;
	import com.dukascopy.connect.utils.DashedLine;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.LocationChangeEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class ReferralProgramScreen extends BaseScreen
	{
		private var actions:Array = [ { id:"refreshBtn", img:SWFPaymentsRefreshIcon, callback:onRefresh } ];
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
		private var preloader:Preloader;
		private var locked:Boolean;
		private var background:Sprite;
		private var text:Bitmap;
		private var codeClip:Sprite;
		private var codeText:Bitmap;
	//	private var tapText:Bitmap;
		private var hLine1:Bitmap;
		private var hLine2:Bitmap;
		private var hLine3:Bitmap;
		private var vLine1:Bitmap;
		private var earnings:Bitmap;
		private var shareButton:RoundedButton;
		private var attractedValue:Bitmap;
		private var attractedText:Bitmap;
		private var invitesValue:Bitmap;
		private var invitesText:Bitmap;
		private var invitesClip:Sprite;
		private var avatars:Array;
		private var allFriendsButton:BitmapButton;
		private var _waiting:Boolean;
		private var okButton:RoundedButton;
		private var cancelButton:RoundedButton;
		private var webView:StageWebView;
		private var needShowAgreement:Boolean;
		private var expected:Bitmap;
		private var topClip:Sprite;
		private var bottomClip:Sprite;
		private var infoButton:BitmapButton;
		
		public function ReferralProgramScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height - topBar.trueHeight);
			background.y = topBar.trueHeight;
			
			topBar.setData(Lang.referralProgram, true);
			
			getAgreementStatus();
			
			scrollPanel.view.y = topBar.trueHeight;
		}
		
		private function getAgreementStatus():void {
			if (ReferralProgram.agreementAccepted == true) {
				drawReferralProgram();
			}
			else {
				Store.load(Store.REFERRAL_PROGRAM_AGREEMENT_ACCEPTED, onAgreementStatusLoaded);
			}
		}
		
		private function onAgreementStatusLoaded(data:Object, error:Boolean = false):void {
			if (error == false && data == true) {
				ReferralProgram.agreementAccepted = true;
				drawReferralProgram();
			}
			else {
				if (Lang.referralProgramAgreement != null && Lang.referralProgramAgreement != "") {
					drawAgreement();
				}
				else{
					drawReferralProgram();
				}
			}
		}
		
		private function drawAgreement():void {
			if (okButton == null) {
				okButton = new RoundedButton(Lang.textAccept, 0x7BC247, 0x7BC247, null, Config.FINGER_SIZE*.1, 0, Config.FINGER_SIZE, Config.FINGER_SIZE*.38);
				okButton.setStandartButtonParams();
				okButton.setDownScale(1);
				okButton.cancelOnVerticalMovement = true;
				okButton.tapCallback = onButtonOkClick;
				_view.addChild(okButton);
			}
			
			if (cancelButton == null) {
				cancelButton = new RoundedButton(Lang.textBack, 0x93A2AE, 0x93A2AE, null, Config.FINGER_SIZE*.1, 0, Config.FINGER_SIZE, Config.FINGER_SIZE*.38);
				cancelButton.setStandartButtonParams();
				cancelButton.setDownScale(1);
				cancelButton.cancelOnVerticalMovement = true;
				cancelButton.tapCallback = onButtonCancelClick;
				_view.addChild(cancelButton);
				cancelButton.x = Config.MARGIN * 2;
			}
			
			okButton.setSizeLimits((_width - Config.MARGIN * 5)*.5, (_width - Config.MARGIN * 5)*.5);
			cancelButton.setSizeLimits((_width - Config.MARGIN * 5)*.5, (_width - Config.MARGIN * 5)*.5);
			
			okButton.show();
			cancelButton.show();
			
			okButton.draw();
			cancelButton.draw();
			
			if (_isActivated == true){
				cancelButton.activate();
				okButton.activate();
			}
			
			okButton.y = _height - Config.MARGIN - okButton.getHeight();
			cancelButton.y = _height - Config.MARGIN - cancelButton.getHeight();
			
			cancelButton.x = Config.MARGIN * 2;
			okButton.x = cancelButton.x + cancelButton.width + Config.MARGIN;
			
			scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight - okButton.height - Config.MARGIN * 2, false);
			
			text.x = int(scrollPanel.getWidth() * .5 - text.width * .5);
			
			showWebView();
		}
		
		private function onButtonCancelClick():void {
			destroyWebView();
			onBack();
		}
		
		private function onButtonOkClick():void {
			ReferralProgram.agreementAccepted = true;
			Store.save(Store.REFERRAL_PROGRAM_AGREEMENT_ACCEPTED, true);
			okButton.hide();
			cancelButton.hide();
			drawReferralProgram();
		}
		
		private function drawReferralProgram():void {
			topBar.setActions(actions);
			
			destroyWebView();
			
			if (text.bitmapData != null){
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
			
			text.bitmapData = TextUtils.createTextFieldData(Lang.sendYourReferralCode, _width - Config.MARGIN * 4, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .35, true, 0x000000, 0xFFFFFF);
			
			drawCode();
			drawShareButton();
			drawStat();
			drawInvites();
			
		//	tapText.bitmapData = TextUtils.createTextFieldData(Lang.tapToCopy, _width - Config.MARGIN * 4, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, true, 0x96A4B0, 0xFFFFFF);
			
			hLine1.width = _width;
			hLine2.width = _width;
			hLine3.width = _width;
			
			var scrollPanelHeight:int = _height - topBar.trueHeight - Config.APPLE_BOTTOM_OFFSET;;
			scrollPanel.setWidthAndHeight(_width, scrollPanelHeight, false);
			updateItemsPositions();
			
			text.x = int(scrollPanel.getWidth() * .5 - text.width * .5);
			
			ReferralProgram.S_UPDATED.add(onDataUpdated);
			if (isNaN(ReferralProgram.myPromoData.lastLoadTime) || (new Date()).getTime() - ReferralProgram.myPromoData.lastLoadTime > 5 * 60 * 1000) {
				lockScreen();
				ReferralProgram.update();
			}
		}
		
		private function drawShareButton():void 
		{
			shareButton.setSizeLimits(_width - Config.MARGIN * 4, _width - Config.MARGIN * 4);
			shareButton.draw();
		}
		
		private function onRefresh():void {
			if (_waiting)
				return;
			topBar.showAnimationOverButton("refreshBtn");
			lockScreen();
			_waiting = true;
			ReferralProgram.update();
		}
		
		private function onDataUpdated(success:Boolean, errorMessage:String = null):void {
			_waiting = false;
			unlockScreen();
			
			if (success == false){
				if (errorMessage != null){
					ToastMessage.display(errorMessage);
				}
			}
			else{
				drawCode();
				drawShareButton();
				drawStat();
				drawInvites();
				
				updateItemsPositions();
			}
		}
		
		private function drawInvites():void {
			var l:int = Math.min(ReferralProgram.myPromoData.invites.length, Math.floor((_width - Config.MARGIN*4)/(Config.FINGER_SIZE + Config.MARGIN*1.5)), 5);
			var inviteClip:Sprite;
			var avatar:CircleAvatar;
			
			cleanAvatars();
			
			if (invitesClip == null) {
				invitesClip = new Sprite();
				scrollPanel.addObject(invitesClip);
			}
			
			avatars = new Array();
			var icon:Sprite;
			for (var i:int = 0; i < l; i++) 
			{
				inviteClip = new Sprite();
				invitesClip.addChild(inviteClip);
				avatar = new CircleAvatar(false);
				inviteClip.addChild(avatar);
				
				if (ReferralProgram.myPromoData.invites[i].status == ReferralProgram.INVITE_STATUS_COMPLETED)
					icon = new StatusCompleteIcon();
				else if(ReferralProgram.myPromoData.invites[i].status == ReferralProgram.INVITE_STATUS_REJECTED)
					icon = new StatusRejectcon();
				else
					icon = new StatusPendingIcon();
				
				UI.scaleToFit(icon, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
				inviteClip.addChild(icon);
				icon.x = int(Config.FINGER_SIZE * .65);
				icon.y = int(Config.FINGER_SIZE * .65);
				avatar.setData(ReferralProgram.myPromoData.invites[i].user, Config.FINGER_SIZE * .5);
				inviteClip.x = (Config.FINGER_SIZE + Config.MARGIN*1.5) * i;
				avatars.push(avatar);
			}
			
			if (avatars.length > 0 && allFriendsButton == null){
				allFriendsButton = new BitmapButton();
				allFriendsButton.setStandartButtonParams();
				allFriendsButton.setDownScale(1);
				allFriendsButton.cancelOnVerticalMovement = true;
				allFriendsButton.tapCallback = onButtonFriendsClick;
				scrollPanel.addObject(allFriendsButton);
				var buttonText:TextFieldSettings = new TextFieldSettings(Lang.seeAllFriends, 0x9BA8B3, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
				allFriendsButton.setBitmapData(TextUtils.createbutton(buttonText, 0, 0, -1, 0xBDC0CD, -1));
				allFriendsButton.activate();
				allFriendsButton.show();
			}
			scrollPanel.update();
		}
		
		private function onButtonFriendsClick():void {
			MobileGui.changeMainScreen(ReferralInvitesListScreen, { 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:data }, 
										ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		private function cleanAvatars():void {
			if (avatars != null) {
				var l:int = avatars.length;
				for (var i:int = 0; i < l; i++) 
				{
					(avatars[i] as CircleAvatar).dispose();
				}
				avatars = null;
			}
			if (invitesClip != null) {
				UI.destroy(invitesClip);
				invitesClip = null;
			}
		}
		
		private function drawStat():void {
			
			var moneyExpected:Number = ReferralProgram.myPromoData.totalInvites * 5;
			
			var textExpected:String = "<font size='" + Config.FINGER_SIZE*.26 + "' color='#9BA8B3'>" + Lang.expectedIncome + ": " + "</font><font size='" + Config.FINGER_SIZE*.5 + "' color='#96A4B0'>" + Math.floor(moneyExpected).toString() + "" + ".</font><font size='" + Config.FINGER_SIZE*.40 + "' color='#96A4B0'>" + ((moneyExpected - Math.floor(moneyExpected))*100).toString() + "</font><font size='" + Config.FINGER_SIZE*.40 + "' color='#96A4B0'> DUK+</font>";
			
			if (expected.bitmapData != null) {
				expected.bitmapData.dispose();
				expected.bitmapData = null;
			}
			expected.bitmapData = TextUtils.createTextFieldData(textExpected, _width - Config.MARGIN * 4, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .5, false, 0x000000, 0xFFFFFF, false, true);
			
			
			var money:Number = ReferralProgram.myPromoData.money;
			var text1:String = "<font size='" + Config.FINGER_SIZE*.26 + "' color='#9BA8B3'>" + Lang.totalEarnings + ": " + "</font><font size='" + Config.FINGER_SIZE*.5 + "' color='#96A4B0'>" + Math.floor(money).toString() + "" + ".</font><font size='" + Config.FINGER_SIZE*.40 + "' color='#96A4B0'>" + ((money - Math.floor(money))*100).toString() + "</font><font size='" + Config.FINGER_SIZE*.40 + "' color='#96A4B0'> DUK+</font>";
			
			if (earnings.bitmapData != null) {
				earnings.bitmapData.dispose();
				earnings.bitmapData = null;
			}
			earnings.bitmapData = TextUtils.createTextFieldData(text1, _width - Config.MARGIN * 4, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .5, false, 0x000000, 0xFFFFFF, false, true);
			
			var blockWidth:int = (_width - Config.MARGIN * 4) * .5;
			
			if (invitesValue.bitmapData != null){
				invitesValue.bitmapData.dispose();
				invitesValue.bitmapData = null;
			}
			invitesValue.bitmapData = TextUtils.createTextFieldData(ReferralProgram.myPromoData.totalInvites.toString(), blockWidth*.5, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .5, false, 0x000000, 0xFFFFFF)
			
			if (invitesText.bitmapData != null){
				invitesText.bitmapData.dispose();
				invitesText.bitmapData = null;
			}
			invitesText.bitmapData = TextUtils.createTextFieldData(Lang.friendsEnteredYourCode + ":", blockWidth - invitesValue.width - Config.MARGIN * 3, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, true, 0x96A4B0, 0xFFFFFF)
			
			
			if (attractedValue.bitmapData != null){
				attractedValue.bitmapData.dispose();
				attractedValue.bitmapData = null;
			}
			attractedValue.bitmapData = TextUtils.createTextFieldData(ReferralProgram.myPromoData.totalCompleted.toString(), blockWidth*.5, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .5, false, 0x000000, 0xFFFFFF)
			
			
			if (attractedText.bitmapData != null){
				attractedText.bitmapData.dispose();
				attractedText.bitmapData = null;
			}
			attractedText.bitmapData = TextUtils.createTextFieldData(Lang.totalAttractedFriends + ":", blockWidth - attractedValue.width - Config.MARGIN * 3, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, true, 0x96A4B0, 0xFFFFFF)
		}
		
		private function updateItemsPositions():void 
		{
			codeClip.y = int(text.y + text.height + Config.MARGIN * 3);
			codeClip.x = int(Config.MARGIN * 2);
			
			shareButton.x = int(_width * .5 - shareButton.width * .5);
			shareButton.y = int(codeClip.y + codeClip.height + Config.FINGER_SIZE * .2);
			
			infoButton.x = int(_width * .5 - infoButton.width * .5);
			infoButton.y = int(shareButton.y + shareButton.height + Config.FINGER_SIZE * .15);
			
		//	tapText.x = int(scrollPanel.getWidth() * .5 - tapText.width * .5);
		//	tapText.y = int(shareButton.y + codeClip.height + Config.MARGIN * 3);
			hLine1.y = int(infoButton.y + infoButton.height + Config.FINGER_SIZE * .2);
			expected.x = int(scrollPanel.getWidth() * .5 - expected.width * .5);
			earnings.x = int(expected.x + expected.width - earnings.width);
			earnings.y = int(hLine1.y + Config.MARGIN * 3);
			expected.y = int(earnings.y + earnings.height + Config.MARGIN * 1.5);
			hLine2.y = int(expected.y + expected.height + Config.MARGIN * 3);
			
			var maxHeight:int = Math.max(invitesText.height, invitesValue.height, attractedText.height, attractedValue.height);
			
			invitesText.x = int(Config.MARGIN * 2);
			invitesText.y = int(hLine2.y + Config.MARGIN * 2 + maxHeight * .5 - invitesText.height * .5);
			
			invitesValue.x = int(_width * .5 - invitesValue.width - Config.MARGIN * 2);
			invitesValue.y = int(hLine2.y + Config.MARGIN * 2 + maxHeight * .5 - invitesValue.height * .5);
			
			attractedText.x = int(_width * .5 + Config.MARGIN * 2);
			attractedText.y = int(hLine2.y + Config.MARGIN * 2 + maxHeight * .5 - attractedText.height * .5);
			
			attractedValue.x = int(_width - Config.MARGIN * 2 - attractedValue.width);
			attractedValue.y = int(hLine2.y + Config.MARGIN * 2 + maxHeight * .5 - attractedValue.height * .5);
			
			vLine1.x = int(_width * .5);
			vLine1.y = hLine2.y + hLine2.height;
			vLine1.height = maxHeight + Config.MARGIN * 4;
			
			hLine3.y = int(vLine1.y + vLine1.height);
			
			if (invitesClip != null){
				invitesClip.y = int(hLine3.y + Config.MARGIN * 4);
				invitesClip.x = int(_width * .5 - (Config.FINGER_SIZE * avatars.length + Config.MARGIN * 1.5 * (avatars.length - 1)) * .5);
				if (allFriendsButton != null){
					allFriendsButton.x = int(scrollPanel.getWidth() * .5 - allFriendsButton.width * .5);
					allFriendsButton.y = int(invitesClip.y + Config.FINGER_SIZE + Config.MARGIN * 3);
					
					bottomClip.y = allFriendsButton.y + allFriendsButton.height + Config.DIALOG_MARGIN;
				}
			}
			
			scrollPanel.update();
		}
		
		private function drawCode():void {
			var value:String = ReferralProgram.myPromoData.code;
			
			if (codeText.bitmapData != null){
				codeText.bitmapData.dispose();
				codeText.bitmapData = null;
			}
			codeText.bitmapData = TextUtils.createTextFieldData(value, _width - Config.MARGIN * 4, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .5, false, Color.GREEN, 0xE4F2D9);
			
			codeClip.graphics.clear();
			codeClip.graphics.beginFill(0xE4F2D9, 1);
			codeClip.graphics.drawRoundRect(0, 0, _width - Config.MARGIN * 4, Config.FINGER_SIZE, Config.FINGER_SIZE * .1, Config.FINGER_SIZE * .1);
			codeClip.graphics.endFill();
			
			var dl:DashedLine = new DashedLine(codeClip, Config.FINGER_SIZE * .12, Config.FINGER_SIZE * .08);
			dl.lineStyle(Math.max(2, Config.FINGER_SIZE * .03), Color.GREEN, 1);
			
			BaseGraphicsUtils.curvedBox(dl, 0, 0, _width - Config.MARGIN * 4, Config.FINGER_SIZE, Config.FINGER_SIZE * .1);
			
			codeText.x = int((_width - Config.MARGIN * 4 - codeText.width) * .5);
			codeText.y = int(Config.FINGER_SIZE * .5 - codeText.height * .5);
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			_view.addChild(scrollPanel.view);
			scrollPanel.view.x = 0;
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			preloader = new Preloader();
			_view.addChild(preloader);
			preloader.hide();
			preloader.visible = false;
			
			text = new Bitmap();
			scrollPanel.addObject(text);
			text.y = Config.MARGIN * 3;
			
			var textFormatCode:TextFormat = new TextFormat();
			textFormatCode.size = Config.FINGER_SIZE * .45;
			textFormatCode.align = TextFormatAlign.CENTER;
			
			codeClip = new Sprite();
			scrollPanel.addObject(codeClip);
			
			codeText = new Bitmap();
			codeClip.addChild(codeText);
			
			hLine1 = new Bitmap();
			scrollPanel.addObject(hLine1);
			
			hLine2 = new Bitmap();
			scrollPanel.addObject(hLine2);
			
			hLine3 = new Bitmap();
			scrollPanel.addObject(hLine3);
			
			hLine1.bitmapData = hLine2.bitmapData = hLine3.bitmapData = UI.getHorizontalLine(2, 0xEEF1F4);
			
			vLine1 = new Bitmap();
			scrollPanel.addObject(vLine1);
			
			vLine1.bitmapData = UI.getVerticalLine(2, 0xEEF1F4);
			
			earnings = new Bitmap();
			scrollPanel.addObject(earnings);
			
			expected = new Bitmap();
			scrollPanel.addObject(expected);
			
			invitesText = new Bitmap();
			scrollPanel.addObject(invitesText);
			
			invitesValue = new Bitmap();
			scrollPanel.addObject(invitesValue);
			
			attractedText = new Bitmap();
			scrollPanel.addObject(attractedText);
			
			attractedValue = new Bitmap();
			scrollPanel.addObject(attractedValue);
			
			shareButton = new RoundedButton(Lang.inviteYourFriend, Color.GREEN, Color.GREEN, null, Config.FINGER_SIZE * .15, 0, Config.FINGER_SIZE * .93, Config.FINGER_SIZE * .32);
			shareButton.setStandartButtonParams();
			shareButton.setDownScale(1);
			shareButton.setDownColor(0);
			shareButton.tapCallback = callShare;
			shareButton.disposeBitmapOnDestroy = true;
			shareButton.show();
			scrollPanel.addObject(shareButton);
			
			topClip = new Sprite();
			topClip.graphics.beginFill(0xFFFFFF);
			topClip.graphics.drawRect(0, 0, 1, 1);
			topClip.graphics.endFill();
			scrollPanel.addObject(topClip);
			
			bottomClip = new Sprite();
			bottomClip.graphics.beginFill(0xFFFFFF);
			bottomClip.graphics.drawRect(0, 0, 1, 1);
			bottomClip.graphics.endFill();
			scrollPanel.addObject(bottomClip);
			
			infoButton = new BitmapButton();
			infoButton.setStandartButtonParams();
			infoButton.setDownScale(1);
			infoButton.setDownColor(0);
			infoButton.tapCallback = onInfoClick;
			infoButton.disposeBitmapOnDestroy = true;
			infoButton.show();
			scrollPanel.addObject(infoButton);
			
			var icon:Sprite = new (Style.icon(Style.ICON_INFO))();
			UI.colorize(icon, Color.RED);
			var iconSize:int = Config.FINGER_SIZE * .35;
			UI.scaleToFit(icon, iconSize, iconSize);
			
			
			var clip:Sprite = new Sprite();
			clip.addChild(icon);
			icon.x = int(Config.FINGER_SIZE * .2);
			icon.y = int(Config.FINGER_SIZE * .5 * .5 - icon.height * .5);
			
			var textBitmap:ImageBitmapData = TextUtils.createTextFieldData(
				Lang.сonditions,
				Config.FINGER_SIZE * 4,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.SUBHEAD,
				true,
				Style.color(Style.COLOR_SUBTITLE),
				Style.color(Style.COLOR_BACKGROUND)
			);
			
			clip.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			clip.graphics.drawRoundRect(0, 0, 
										int(icon.x + icon.width + Config.FINGER_SIZE * .2 + Config.FINGER_SIZE * .2 + textBitmap.width), 
										int(Config.FINGER_SIZE * .5), 
										int(Config.FINGER_SIZE * .5), 
										int(Config.FINGER_SIZE * .5));
			clip.graphics.endFill();
			var resultBD:ImageBitmapData = UI.getSnapshot(clip);
			resultBD.copyPixels(textBitmap, textBitmap.rect, new Point(int(icon.x + icon.width + Config.FINGER_SIZE*.2), int(clip.height*.5 - textBitmap.height*.5)), null, null, true);
			textBitmap.dispose();
			textBitmap = null;
			UI.destroy(icon);
			UI.destroy(clip);
			infoButton.setBitmapData(resultBD, true);
		}
		
		private function onInfoClick():void 
		{
			ServiceScreenManager.showScreen(
				ServiceScreenManager.TYPE_SCREEN,
				BottomAlertPopup,
				{
					title:Lang.referralProgram,
					message:Lang.referralBonusDetails
				}
			);
		}
		
		private function callShare():void{
			
			if (ReferralProgram.myPromoData.loaded == true){
				var message:String = Lang.invitePromocodeMessage;
				message = LangManager.replace(Lang.regExtValue, message, ReferralProgram.myPromoData.code);
				message = LangManager.replace(Lang.regExtValue, message, ReferralProgram.myPromoData.code);
				var lang:String = LangManager.model.getCurrentLanguageID();
				if (lang != 'ru')
					lang = "en";
				message += "&lang=" + lang;
				NativeExtensionController.shareText(message);
			}
		}
		
		private function lockScreen():void {
			locked = true;
			displayPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void {
			locked = false;
			hidePreloader();
			activateScreen();
		}
		
		private function displayPreloader():void {
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			preloader.visible = true;
			preloader.show();
		}
		
		private function hidePreloader():void {
			preloader.hide();
		}
		
		override protected function drawView():void {
			topBar.drawView(_width);
			scrollPanel.update();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			destroyWebView();
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (scrollPanel != null) {
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (preloader != null) {
				preloader.dispose();
				preloader = null;
			}
			if (background != null) {
				UI.destroy(background);
				background = null;
			}
			if (text != null) {
				UI.destroy(text);
				text = null;
			}
			if (codeClip != null) {
				UI.destroy(codeClip);
				codeClip = null;
			}
			if (codeText != null) {
				UI.destroy(codeText);
				codeText = null;
			}
			/*if (tapText != null) {
				UI.destroy(tapText);
				tapText = null;
			}*/
			if (hLine1 != null) {
				UI.destroy(hLine1);
				hLine1 = null;
			}
			if (hLine2 != null) {
				UI.destroy(hLine2);
				hLine2 = null;
			}
			if (hLine3 != null) {
				UI.destroy(hLine3);
				hLine3 = null;
			}
			if (vLine1 != null) {
				UI.destroy(vLine1);
				vLine1 = null;
			}
			if (earnings != null) {
				UI.destroy(earnings);
				earnings = null;
			}
			if (expected != null) {
				UI.destroy(expected);
				expected = null;
			}
			if (shareButton != null) {
				shareButton.dispose();
				shareButton = null;
			}
			if (attractedValue != null) {
				UI.destroy(attractedValue);
				attractedValue = null;
			}
			if (attractedText != null) {
				UI.destroy(attractedText);
				attractedText = null;
			}
			if (invitesValue != null) {
				UI.destroy(invitesValue);
				invitesValue = null;
			}
			if (invitesText != null) {
				UI.destroy(invitesText);
				invitesText = null;
			}
			if (allFriendsButton != null) {
				allFriendsButton.dispose();
				allFriendsButton = null;
			}
			if (cancelButton != null) {
				cancelButton.dispose();
				cancelButton = null;
			}
			if (okButton != null) {
				okButton.dispose();
				okButton = null;
			}
			if (infoButton != null) {
				infoButton.dispose();
				infoButton = null;
			}
			if (topClip != null) {
				UI.destroy(topClip);
				topClip = null;
			}
			if (bottomClip != null) {
				UI.destroy(bottomClip);
				bottomClip = null;
			}
			
			cleanAvatars();
			actions = null;
			ReferralProgram.S_UPDATED.remove(onDataUpdated);
		}
		
		private function copyCode(e:MouseEvent = null):void {
			if (ReferralProgram.myPromoData.loaded == true) {
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, ReferralProgram.myPromoData.code);
				ToastMessage.display(Lang.copied);
			}
		}
		
		private function checkLocation(e:LocationChangeEvent):void {
			if (e.location != "about:blank") {
				navigateToURL(new URLRequest(e.location));
			//	destroyWebView();
				
			}
			e.stopImmediatePropagation();
			e.preventDefault();
			e.stopPropagation();
		}
		
		private function showWebView():void {
			if (_isActivated == false){
				needShowAgreement = true;
				return;
			}
			needShowAgreement = false;
			if (webView == null) {
				webView = new StageWebView();
				
				var tempRect:Rectangle = new Rectangle();
				tempRect.x = 0;
				tempRect.y = topBar.y + topBar.trueHeight;
				
				tempRect.width = _width;
				tempRect.height = _height - tempRect.y - okButton.height - Config.DOUBLE_MARGIN;
				
				webView.viewPort = tempRect;
				webView.stage = MobileGui.stage;
				webView.loadString(TextUtils.getHTMLTemplate(Lang.referralProgramAgreement));
				
			//	webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, checkLocation);
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, checkLocation);
			//	webView.addEventListener(Event.COMPLETE, checkLocation);
			}
		}
		
		public function destroyWebView():Boolean {
			var res:Boolean = false;
			if (webView != null) {
				res = true;
				webView.stage = null;
				webView.viewPort = null;
				webView.dispose();
			}
			webView = null;
			return res;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			if (needShowAgreement == true) {
				showWebView();
			}
			
			if (_isDisposed)
				return;
			
			if (locked)
				return;
			
			if (topBar != null)
				topBar.activate();
			scrollPanel.enable();
			
			if (allFriendsButton != null) {
				allFriendsButton.activate();
			}
			
			if (cancelButton != null){
				cancelButton.activate();
			}
			
			if (okButton != null){
				okButton.activate();
			}
			
			if (infoButton != null){
				infoButton.activate();
			}
			
			shareButton.activate();
			
			PointerManager.addTap(codeClip, copyCode);
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (topBar != null)
				topBar.deactivate();		
			scrollPanel.disable();
			
			shareButton.deactivate();
			
			if (allFriendsButton != null){
				allFriendsButton.deactivate();
			}
			
			if (infoButton != null){
				infoButton.deactivate();
			}
			
			if (cancelButton != null){
				cancelButton.deactivate();
			}
			
			if (okButton != null){
				okButton.deactivate();
			}
			
			PointerManager.addTap(codeClip, copyCode);
		}
	}
}