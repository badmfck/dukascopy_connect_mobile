package com.dukascopy.connect.screens.requestPermissionScreens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class BaseRequestPermissionScreen extends BaseScreen {
		
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		
		private var FIT_WIDTH:Number;
		private var requestPermissionsButton:RoundedButton;
		private var backButton:BitmapButton;
		private var txtComment1BitmapData:ImageBitmapData;
		private var txtComment2BitmapData:ImageBitmapData;
		private var txtComment1Bitmap:Bitmap;
		private var txtComment2Bitmap:Bitmap;
		private var optionSwitcher:OptionSwitcher;
		private var _lastWidth:int = 0;
		private var _lastHeight:int = 0;
		private var _lastCommentText1:String = "";
		private var _lastCommentText2:String = "";
		
		protected var _isNeverAskAgain:Boolean = false;
		protected var _isCloseOnTapContinue:Boolean = false;
		protected var commentsTextsColor:int = AppTheme.WHITE;
		protected var backGround:Sprite;
		
		protected function onTapRequest():void {
			//must be overrided
		}
		
		protected function onTapBack():void	{
			//must be overrided
		}
		
		override public function initScreen(data:Object = null):void {
			if (_isDisposed == true)
				return;
 			super.initScreen();
			
			_params.title = "";
			_params.doDisposeAfterClose = true;
			
			FIT_WIDTH = _width - Config.MARGIN;
			
			var headerSize:int = Config.TOP_BAR_HEIGHT;
			var iconArrowSize:int = Config.FINGER_SIZE * .30;
			var btnSize:int = headerSize * .38;
			var btnY:int = (headerSize - btnSize) * .5;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1.3);
			backButton.setDownColor(0xFFFFFF);
			backButton.tapCallback = onTapBack;
			backButton.disposeBitmapOnDestroy = true;
				var icoBack:IconBack = new IconBack();
				icoBack.width = icoBack.height = btnSize;
			backButton.setBitmapData(UI.getSnapshot(icoBack, StageQuality.HIGH, "BaseRequestPermissionScreen.buttonBack"), true);
			backButton.x = btnOffset;
			backButton.y = btnY + Config.APPLE_TOP_OFFSET;
			backButton.setOverflow(btnOffset, btnOffset, Config.FINGER_SIZE, btnOffset + Config.FINGER_SIZE * .3);
			backButton.hide();
			_view.addChild(backButton);
			
			optionSwitcher = new OptionSwitcher();
			optionSwitcher.create(_width - Config.FINGER_SIZE, OPTION_LINE_HEIGHT, null, Lang.doNotShowAgain, false, true, commentsTextsColor);
			optionSwitcher.onSwitchCallback =  onTapNeverAskAgain;
			optionSwitcher.x = int(Config.FINGER_SIZE / 2);
			optionSwitcher.y = int(_height - Config.FINGER_SIZE);
			_view.addChild(optionSwitcher);
			
			requestPermissionsButton = new RoundedButton(Lang.BTN_CONTINUE, AppTheme.RED_MEDIUM, AppTheme.RED_DARK, null);
			requestPermissionsButton.setStandartButtonParams();
			requestPermissionsButton.setDownScale(1);
			requestPermissionsButton.cancelOnVerticalMovement = true;
			requestPermissionsButton.tapCallback =  onTapRequest;
			requestPermissionsButton.setSizeLimits(_width - Config.FINGER_SIZE, _width - Config.FINGER_SIZE);
			requestPermissionsButton.draw();
			requestPermissionsButton.x = int((_width - requestPermissionsButton.width) / 2);
			requestPermissionsButton.y = int(optionSwitcher.y - requestPermissionsButton.height * 1.2);
			requestPermissionsButton.hide();
			_view.addChild(requestPermissionsButton);
		}
		
		protected function onTapNeverAskAgain(state:Boolean):void {
			_isNeverAskAgain = state;
		}
		
		protected function setTexts(text1:String, text2:String):void {
			if (_isDisposed == true)
				return;
			var isRedrawText1:Boolean = text1 != _lastCommentText1;
			if (isRedrawText1 == true)
				_lastCommentText1 = text1;
			var isRedrawText2:Boolean = text2 != _lastCommentText2;
			if (isRedrawText2 == true)
				_lastCommentText2 = text2;
			drawTexts(isRedrawText1, isRedrawText2);
		}
		
		private function drawTexts(isDrawText1:Boolean = true, isDrawText2:Boolean = true):void {
			if (isDrawText1 == true) {
				if (txtComment1BitmapData != null)
					UI.disposeBMD(txtComment1BitmapData);
				txtComment1BitmapData = UI.renderText(
					_lastCommentText1,
					FIT_WIDTH - Config.FINGER_SIZE,
					1,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.CENTER,
					Config.FINGER_SIZE * .3,
					true,
					commentsTextsColor,
					0x000000,
					true
				);
				if (txtComment1Bitmap == null) {
					txtComment1Bitmap = new Bitmap();
					txtComment1Bitmap.x = int(Config.FINGER_SIZE / 2);
				}
				txtComment1Bitmap.bitmapData = txtComment1BitmapData;
				txtComment1Bitmap.y = int(requestPermissionsButton.y - Config.FINGER_SIZE_DOT_25 - txtComment1Bitmap.height);
				if (txtComment1Bitmap.parent == null)
					_view.addChild(txtComment1Bitmap);
			}
			if (isDrawText2 == true) {
				if (txtComment2BitmapData != null)
					UI.disposeBMD(txtComment2BitmapData);
				txtComment2BitmapData = UI.renderText(
					_lastCommentText2,
					FIT_WIDTH - Config.FINGER_SIZE,
					1,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.CENTER,
					Config.FINGER_SIZE * .4,
					true,
					commentsTextsColor,
					0x000000,
					true
				);
				if (txtComment2Bitmap == null) {
					txtComment2Bitmap = new Bitmap();
					txtComment2Bitmap.x = Config.FINGER_SIZE / 2;
				}
				txtComment2Bitmap.bitmapData = txtComment2BitmapData;
				txtComment2Bitmap.y = txtComment1Bitmap.y - Config.FINGER_SIZE_DOT_25 - txtComment2Bitmap.height;
				if (txtComment2Bitmap.parent == null)
					_view.addChild(txtComment2Bitmap);
			}
		}
		
		private function clearCommentTexts():void {
			if (txtComment1Bitmap != null)
				UI.destroy(txtComment1Bitmap);
			if (txtComment2Bitmap != null)
				UI.destroy(txtComment2Bitmap);
			if (txtComment2BitmapData != null)
				UI.disposeBMD(txtComment2BitmapData);
			if (txtComment1BitmapData != null)
				UI.disposeBMD(txtComment1BitmapData);
		}
		
		protected function initBackground():void {
			//must be overrided;
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			if (backGround == null) {
				initBackground();
				_lastHeight = 0;
				_lastWidth = 0;
			}
			if (_width == _lastWidth && _height == _lastHeight)
				return;
			if (_width != _lastWidth)
				drawTexts();
			_lastWidth = _width;
			_lastHeight = _height;
			UI.fillAndCentrate(backGround, _width, _height);
			backGround.x = 0;
			backGround.y = 0;
			_view.addChildAt(backGround, 0);
			_view.cacheAsBitmap = false;
		}
		
		protected function onPermissionDenied():void {
			setTexts("", Lang.textYouCanChangeYourChoice);
			_isCloseOnTapContinue = true;
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			requestPermissionsButton.dispose();
			requestPermissionsButton = null;
			backButton.dispose();
			backButton = null;
			UI.destroy(backGround);
			backGround = null;
			txtComment1BitmapData.disposeNow();
			txtComment1BitmapData = null;
			txtComment2BitmapData.disposeNow();
			txtComment2BitmapData = null;
			UI.destroy(txtComment1Bitmap);
			txtComment1Bitmap = null;
			UI.destroy(txtComment2Bitmap);
			txtComment2Bitmap = null;
			optionSwitcher.dispose();
			optionSwitcher = null;
			_lastCommentText1 = "";
			_lastCommentText2 = "";
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			backButton.show(.1, .3, true, .9, 0);
			requestPermissionsButton.show(.1, .4, true, .9, 0);
			requestPermissionsButton.activate();
			backButton.activate();
			optionSwitcher.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			requestPermissionsButton.deactivate();
			backButton.deactivate();
			optionSwitcher.deactivate();
		}
	}
}