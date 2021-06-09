package com.dukascopy.connect.screens.payments.settings {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.layout.ScrollScreen;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import flash.text.TextFormatAlign;
	
	public class PaymentsSettingsVerificationLimitsScreen extends ScrollScreen {
		
		private var _vectItems:Vector.<ItemVerificationLimit>;
		private var btnIncrease:BitmapButton;
		
		public function PaymentsSettingsVerificationLimitsScreen() {
			
		}
		
		override protected function createView():void {
			super.createView();
			
			createButton();
		}
		
		private function createButton():void {
			btnIncrease = new BitmapButton(Lang.increaseLimits);
			btnIncrease.x = Config.DIALOG_MARGIN;
			btnIncrease.setStandartButtonParams();
			btnIncrease.setDownScale(1);
			btnIncrease.setOverlay(HitZoneType.BUTTON);
			btnIncrease.tapCallback = onIncreaseButtonClick;
			btnIncrease.disposeBitmapOnDestroy = true;
			btnIncrease.alpha = .7;
			view.addChild(btnIncrease);
		}
		
		private function drawButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(
				Lang.increaseLimits.toUpperCase(),
				Color.WHITE,
				FontSize.BODY,
				TextFormatAlign.CENTER
			);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(
				textSettings,
				Color.GREEN,
				1,
				int(Config.FINGER_SIZE * .4),
				NaN,
				_width - Config.DIALOG_MARGIN * 2,
				int(Config.FINGER_SIZE * .26),
				Style.size(Style.SIZE_BUTTON_CORNER)
			);
			btnIncrease.setBitmapData(buttonBitmap, true);
			btnIncrease.y = _height - Config.APPLE_BOTTOM_OFFSET - btnIncrease.height - Config.DIALOG_MARGIN;
		}
		
		private function onIncreaseButtonClick():void {
			MobileGui.changeMainScreen(
				PaymentsSettingsIncreaseLimitsScreen,
				{
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:data
				}
			);
		}
		
		override protected function drawView():void {
			super.drawView();
			btnIncrease.y = _height - Config.APPLE_BOTTOM_OFFSET - btnIncrease.height - Config.DIALOG_MARGIN;
		}
		
		override protected function getBottomConfigHeight():int 
		{
			return btnIncrease.height + Config.DIALOG_MARGIN * 2;
		}
		
		override public function initScreen(data:Object = null):void {
			
			if (data == null) {
				data = new Object();
			}
			if ("title" in data == false || data.title == null) {
				data.title = Lang.verificationLimits;
			}
			super.initScreen(data);
			
			drawButton();
			
			PaymentsManager.activate();
			//if (PayManager.accountInfo == null) {
				showPreloader();
				PayManager.callGetAccountInfo(fillData);
			/*} else {
				fillData();
			}*/
			drawView();
		}
		
		private function fillData():void {
			if (_isDisposed == true)
				return;
			hidePreloader();
			if (PayManager.accountInfo == null) {
				onBack();
				return;
			}
			if (PayManager.accountInfo.limitsIncreaseRequest == true) {
				if (btnIncrease != null) {
					btnIncrease.activate();
					btnIncrease.alpha = 1;
				}
			}
			_vectItems = new <ItemVerificationLimit>[];
			var itemVL:ItemVerificationLimit;
			for (var i:int = 0; i < PayManager.accountInfo.limits.length; i++) {
				itemVL = new ItemVerificationLimit(PayManager.accountInfo.limits[i]);
				itemVL.setWidthAndHeight(_width);
				if (_vectItems.length > 0)
					itemVL.y = _vectItems[_vectItems.length - 1].y + _vectItems[_vectItems.length - 1].height + Config.DIALOG_MARGIN * 3;
				_vectItems.push(itemVL);
				addObject(itemVL);
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
		}
		
		override public function dispose():void {
			super.dispose();
			PaymentsManager.deactivate();
			if (_vectItems != null && _vectItems.length > 0) {
				while (_vectItems.length != 0)
					_vectItems.shift().dispose();
			}
			_vectItems = null;
			if (btnIncrease != null)
				btnIncrease.dispose();
			btnIncrease = null;
		}
	}
}