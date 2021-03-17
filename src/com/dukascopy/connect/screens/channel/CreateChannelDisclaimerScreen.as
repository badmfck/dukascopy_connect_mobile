package com.dukascopy.connect.screens.channel {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.chat.ChannelCreateSettingsScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PayServer;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class CreateChannelDisclaimerScreen extends BaseScreen {
		
		static public const STATE_LOAD_USER_STATUS:String = "stateLoadUserStatus";
		static public const STATE_NEED_PAYMENTS:String = "stateNeedPayments";
		static public const STATE_DISCLAMER:String = "stateDisclamer";
		
		private var topBar:TopBarScreen;
		
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		private var scrollPanel:ScrollPanel;
		private var preloader:Preloader;
		private var locked:Boolean;
		private var okButton:RoundedButton;
		private var contentBitmaps:Vector.<Bitmap>;
		private var background:Sprite;
		private var state:String;
		private var cancelButton:RoundedButton;
		
		public function CreateChannelDisclaimerScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.title = 'Create channel disclaimer screen';
			_params.doDisposeAfterClose = true;
			
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height - topBar.trueHeight);
			background.y = topBar.trueHeight;
			
			//drawHeader();
			topBar.setData(Lang.newChannel, true);
			
			cancelButton.setSizeLimits((_width - Config.MARGIN * 4), (_width - Config.MARGIN * 4));
			drawButtonCancel(Lang.textBack);
			
			scrollPanel.view.y = topBar.trueHeight;
			scrollPanel.setWidthAndHeight(_width - Config.MARGIN * 4, _height - topBar.trueHeight - cancelButton.getHeight() - Config.MARGIN * 2 - Config.APPLE_BOTTOM_OFFSET, false);
			
			drawText(Lang.connecting);
			
			state = STATE_LOAD_USER_STATUS;
			
			if (Auth.bank_phase == "ACC_APPROVED") {
				resultUserCheck(false, true);
			} else {
				resultUserCheck(false, false);
			}
		}
		
		private function resultUserCheck(requestError:Boolean, accountExist:Boolean):void {
			if (requestError == true) {
				drawText(Lang.somethingWentWrong + " " + Lang.pleaseTryLater);
				okButton.hide();
				return;
			}
			var btnSize:int = (_width - Config.MARGIN * 6) * .5;
			cancelButton.setSizeLimits(btnSize, btnSize);
			drawButtonCancel(Lang.textBack);
			okButton.setSizeLimits(btnSize, btnSize);
			if (accountExist == false) {
				drawText(Lang.needPaymentAccount);
				state = STATE_NEED_PAYMENTS;
				drawButtonOK(Lang.textProceed);
				return;
			} else {
				state = STATE_DISCLAMER;
				drawText(Lang.channelDisclaimer);
				drawButtonOK(Lang.iAgree);
			}
			okButton.x = cancelButton.x + cancelButton.getWidth() + Config.MARGIN * 2;
			okButton.show();
		}
		
		private function drawButtonCancel(text:String):void {
			cancelButton.setValue(text);
			cancelButton.draw();
			cancelButton.y = _height - Config.MARGIN - cancelButton.getHeight() - Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function drawButtonOK(text:String):void {
			okButton.setValue(text);
			okButton.draw();
			okButton.y = _height - Config.MARGIN - okButton.getHeight() - Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function drawText(text:String):void {
			if (contentBitmaps) {
				clearTextBitmaps();
				scrollPanel.removeAllObjects();
			}
			var maxTextHeight:int = Math.min(1500, 16777000 / (_width - Config.MARGIN * 4));
			var contentBitmapDatas:Vector.<ImageBitmapData> = new Vector.<ImageBitmapData>();
			if (text) {
				contentBitmapDatas = TextUtils.createTextFieldImage(
					text,
					_width - Config.MARGIN * 4, 
					1,
					true, 
					TextFormatAlign.LEFT,
					TextFieldAutoSize.LEFT,
					Config.FINGER_SIZE * 0.30,
					true,
					MainColors.DARK_BLUE,
					MainColors.WHITE,
					true,
					data.htmlText,
					maxTextHeight,
					false
				);
			}
			contentBitmaps = new Vector.<Bitmap>();
			var length:int = contentBitmapDatas.length;
			var bitmap:Bitmap;
			var i:int;
			for (i = 0; i < length; i++) {
				bitmap = new Bitmap(contentBitmapDatas[i]);
				bitmap.smoothing = true;
				bitmap.y = scrollPanel.itemsHeight + Config.MARGIN * 2;
				scrollPanel.addObject(bitmap);
				contentBitmaps.push(bitmap);
			}
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			//scroller component;
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = MainColors.WHITE;
			_view.addChild(scrollPanel.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);

			preloader = new Preloader();
			_view.addChild(preloader);
			
			preloader.hide();
			preloader.visible = false;
			
			okButton = new RoundedButton("", 0x7BC247, 0x7BC247, null, Config.FINGER_SIZE*.1, 0, Config.FINGER_SIZE, Config.FINGER_SIZE*.38);
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.cancelOnVerticalMovement = true;
			okButton.tapCallback = onButtonOkClick;
			_view.addChild(okButton);
			
			cancelButton = new RoundedButton("", 0x93A2AE, 0x93A2AE, null, Config.FINGER_SIZE*.1, 0, Config.FINGER_SIZE, Config.FINGER_SIZE*.38);
			cancelButton.setStandartButtonParams();
			cancelButton.setDownScale(1);
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.tapCallback = onButtonCancelClick;
			_view.addChild(cancelButton);
			
			scrollPanel.view.x = Config.MARGIN * 2;
			
			cancelButton.x = Config.MARGIN * 2;
		}
		
		private function onButtonCancelClick():void {
			if (state == STATE_LOAD_USER_STATUS)
					MobileGui.S_BACK_PRESSED.invoke();
			else if (state == STATE_DISCLAMER)
				MobileGui.S_BACK_PRESSED.invoke();
			else if (state == STATE_NEED_PAYMENTS)
				MobileGui.S_BACK_PRESSED.invoke();
		}
		
		private function onButtonOkClick():void {
			switch(state) {
				case STATE_LOAD_USER_STATUS: {
					break;
				}
				case STATE_DISCLAMER: {
					var backScreenData:Object;
					var backScreen:Class;
					if (this.data != null && this.data.backScreenData != null && this.data.backScreen != null) {
						backScreenData = this.data.backScreenData;
						backScreen = this.data.backScreen;
					} else {
						backScreenData = this.data;
						backScreen = CreateChannelDisclaimerScreen;
					}
					MobileGui.changeMainScreen(
						ChannelCreateSettingsScreen,
						{
							backScreen: backScreen,
							backScreenData: backScreenData, 
							data: null
						}
					);
					break;
				}
				case STATE_NEED_PAYMENTS: {
					DialogManager.alert(
						Lang.textConfirm,
						Lang.alertConfirmNavigateToPaymentRegistration,
						function (val:int):void {
							if (val == 1) {
								MobileGui.showRoadMap();
								MobileGui.S_BACK_PRESSED.invoke();
							}
						},
						Lang.textOk,
						Lang.textCancel.toUpperCase()
					);
					break;
				}
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
		
		private function clearTextBitmaps():void {
			var i:int;
			var length:int = contentBitmaps.length;
			for (i = 0; i < length; i++) {
				UI.destroy(contentBitmaps[i]);
				contentBitmaps[i] = null;
			}
			contentBitmaps = null;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			if (locked == true)
				return;
			if (topBar != null)
				topBar.activate();
			if (okButton != null)
				okButton.activate();
			if (cancelButton != null)
				cancelButton.activate();
			if (scrollPanel != null)
				scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			if (topBar != null)
				topBar.deactivate();
			if (okButton != null)
				okButton.deactivate();
			if (cancelButton != null)
				cancelButton.deactivate();
			if (scrollPanel != null)
				scrollPanel.disable();
		}
		
		override public function dispose():void {
			super.dispose();
			clearTextBitmaps();
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (okButton != null)
				okButton.dispose();
			okButton = null;
			if (cancelButton != null)
				cancelButton.dispose();
			cancelButton = null;
			if (background != null)
				UI.destroy(background);
			background = null;
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
		}
	}
}