package com.dukascopy.connect.screens.channel
{
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PayServer;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class CreateChannelSettingsScreen extends BaseScreen
	{
		private var title:Bitmap;
		private var bgHeader:Bitmap;
		private var backButton:BitmapButton;
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		private var iconSize:Number;
		private var iconArrowSize:Number;
		private var buttonPaddingLeft:int;
		private var FIT_WIDTH:int;
		private var headerSize:int;
		private var scrollPanel:ScrollPanel;
		private var preloader:Preloader;
		private var locked:Boolean;
		private var okButton:RoundedButton;
		private var background:Sprite;
		
		public function CreateChannelSettingsScreen()
		{
		
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			_params = new ScreenParams('Main content screen', ScreenParams.TOP_BAR_HIDE);
			_params.doDisposeAfterClose = true;
			
			FIT_WIDTH = _width - buttonPaddingLeft * 2;
			
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height - Config.APPLE_TOP_OFFSET - headerSize);
			background.y = headerSize + Config.APPLE_TOP_OFFSET;
			
			drawHeader();
			
			cancelButton.setSizeLimits((_width - Config.MARGIN * 4), (_width - Config.MARGIN * 4));
			drawButtonCancel(Lang.textBack);
			
			scrollPanel.view.y = headerSize + Config.APPLE_TOP_OFFSET;
			scrollPanel.setWidthAndHeight(_width, _height - headerSize - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET, false);
		}
		
		private function drawButtonCancel(text:String):void
		{
			cancelButton.setValue(text);
			cancelButton.draw();
			cancelButton.y = _height - Config.MARGIN * 2 - okButton.getHeight() - Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function drawButtonOK(text:String):void
		{
			okButton.setValue(text);
			okButton.draw();
			okButton.y = _height - Config.MARGIN * 2 - okButton.getHeight() - Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function drawText(text:String):void 
		{
			if (contentBitmaps)
			{
				clearTextBitmaps();
				
				scrollPanel.removeAllObjects();
			}
			
			var maxTextHeight:int = Math.min(1500, 16777000 / (_width - Config.MARGIN * 4));
			
			var contentBitmapDatas:Vector.<ImageBitmapData> = new Vector.<ImageBitmapData>();
			if (text)
			{
				contentBitmapDatas = TextUtils.createTextFieldImage(text, _width - Config.MARGIN * 4, 1, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.30, true, MainColors.DARK_BLUE, MainColors.WHITE, true, data.htmlText, maxTextHeight, false);
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
		
		private function drawHeader():void
		{
			var iconSize:int = Config.FINGER_SIZE * 0.36;
			
			if (bgHeader.bitmapData)
			{
				UI.disposeBMD(bgHeader.bitmapData);
				bgHeader.bitmapData = null;
			}
			
			bgHeader.bitmapData = UI.getTopBarLayeredBitmapData(_width, Config.FINGER_SIZE * .85, Config.APPLE_TOP_OFFSET, 0, AppTheme.RED_MEDIUM, AppTheme.RED_DARK, AppTheme.RED_MEDIUM);
			
			title.bitmapData = UI.renderText(Lang.newChannel, _width - Config.FINGER_SIZE, Config.FINGER_SIZE, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .38, false, 0xffffff, 0, true, "CreateChannelDisclaimerScreen.title");
			title.y = Config.APPLE_TOP_OFFSET + int((Config.FINGER_SIZE * .85 - title.height) * .5);
			title.x = int(Config.FINGER_SIZE);
		}
		
		override public function onBack(e:Event = null):void
		{
			if (data && data.backScreen != undefined && data.backScreen != null)
			{
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function createView():void
		{
			super.createView();
			//size variables;
			
			background = new Sprite();
			view.addChild(background);
			
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
			backButton.setOverflow(btnOffset, btnOffset, Config.FINGER_SIZE * .6, btnOffset + Config.FINGER_SIZE * .1);
			UI.destroy(icoBack);
			icoBack = null;
			
			//header title;
			title = new Bitmap(null, "auto", true);
			_view.addChild(title);
			
			//scroller component;
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = MainColors.WHITE;
			_view.addChild(scrollPanel.view);
			
			preloader = new Preloader();
			_view.addChild(preloader);
			
			preloader.hide();
			preloader.visible = false;
			
			okButton = new RoundedButton("", 0x7BC247, 0x7BC247, null, Config.FINGER_SIZE * .1, 0, Config.FINGER_SIZE, Config.FINGER_SIZE * .38);
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.cancelOnVerticalMovement = true;
			okButton.tapCallback = onButtonOkClick;
			_view.addChild(okButton);
			
			cancelButton = new RoundedButton("", 0x93A2AE, 0x93A2AE, null, Config.FINGER_SIZE * .1, 0, Config.FINGER_SIZE, Config.FINGER_SIZE * .38);
			cancelButton.setStandartButtonParams();
			cancelButton.setDownScale(1);
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.tapCallback = onButtonCancelClick;
			_view.addChild(cancelButton);
			
			scrollPanel.view.x = Config.MARGIN * 2;
			
			cancelButton.x = Config.MARGIN * 2;
		}
		
		private function onButtonCancelClick():void
		{
			switch (state)
			{
			case STATE_LOAD_USER_STATUS: 
			{
				onBack();
				break;
			}
			case STATE_DISCLAMER: 
			{
				onBack();
				break;
			}
			case STATE_NEED_PAYMENTS: 
			{
				onBack();
				break;
			}
			}
		}
	
		private function onButtonOkClick():void
		{
			switch (state)
			{
			case STATE_LOAD_USER_STATUS: 
			{
				
				break;
			}
			case STATE_DISCLAMER: 
			{
				
				break;
			}
			case STATE_NEED_PAYMENTS: 
			{
				DialogManager.alert(Lang.textConfirm, Lang.alertConfirmNavigateToPaymentRegistration, function(val:int):void
				{
					if (val == 1)
					{
						MobileGui.showRoadMap();
						onBack();
					}
				}, Lang.textOk, Lang.textCancel.toUpperCase());
				
				break;
			}
			}
		}
		
		private function lockScreen():void
		{
			locked = true;
			displayPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void
		{
			locked = false;
			hidePreloader();
			activateScreen();
		}
		
		private function displayPreloader():void
		{
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			preloader.visible = true;
			preloader.show();
		}
		
		private function hidePreloader():void
		{
			preloader.hide();
		}
		
		override protected function drawView():void
		{
			scrollPanel.update();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (title)
			{
				UI.destroy(title);
				title = null;
			}
			
			UI.destroy(bgHeader);
			bgHeader = null;
			
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			
			if (bgHeader)
			{
				UI.destroy(bgHeader);
				bgHeader = null;
			}
			
			clearTextBitmaps();
			
			if (scrollPanel)
			{
				scrollPanel.dispose();
				scrollPanel = null;
			}
		}
		
		private function clearTextBitmaps():void
		{
			var i:int;
			var length:int = contentBitmaps.length;
			for (i = 0; i < length; i++)
			{
				UI.destroy(contentBitmaps[i]);
				contentBitmaps[i] = null;
			}
			contentBitmaps = null;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			;
			if (_isDisposed)
			{
				return;
			}
			
			if (locked)
			{
				return;
			}
			
			okButton.activate();
			cancelButton.activate();
			
			if (backButton != null)
			{
				backButton.activate();
			}
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed)
				return;
			
			okButton.deactivate();
			cancelButton.deactivate();
			
			if (backButton != null)
			{
				backButton.deactivate();
			}
		}
	}
}