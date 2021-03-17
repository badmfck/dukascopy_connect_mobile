package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class ScreenPromoRulesPopup extends DialogBaseScreen {
		
		private var tfDescription:TextField;
		private var btnOk:BitmapButton;
		
		public function ScreenPromoRulesPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			scrollPanel.view.visible = true;
			
			var tFormat:TextFormat = new TextFormat();
			tFormat.font = Config.defaultFontName;
			tFormat.size = Config.FINGER_SIZE * .28;
			tFormat.color = 0x7B8C9F;
			
			tfDescription = new TextField();
			tfDescription.defaultTextFormat = tFormat;
			tfDescription.multiline = true;
			tfDescription.wordWrap = true;
			tfDescription.htmlText = Lang.promoEventsRulesDialogText;
		//	tfDescription.text = "Daily contest.\n\nYou may take part in the Daily contest and win 10 € (hereinafter – the Daily Prize) even if you don’t have a Dukascopy Swiss bank account.\n\nEvery day the Daily Prize winner is selected randomly among those who participated in Daily contest. We will credit Daily Prize to your Dukascopy Swiss bank account or froze it until you open account.\n\nIn addition, we aware you that  Apple Inc. does not involve, participate, sponsor or otherwise endorse into any contest within Dukascopy Connect.\n\nMonthly contest.\n\nIf you have Dukascopy Swiss bank account you may take part in the Monthly contest and win the Monthly Prize.\n\nEvery month the Monthly Prize winner is selected randomly among those who participated in the Monthly contest.\n\nIf you do not have Dukascopy Swiss bank account you will be asked to open it before participating in the Monthly contest.\n\nDukascopy may ship Monthly Prize to you but is not obliged to do it.";
			
		//  on iphone > 6 leads to display bug;
		//	tfDescription.cacheAsBitmap = true;
			
			tfDescription.selectable = false;
			tfDescription.x = hPadding;
			scrollPanel.addObject(tfDescription);
			
			btnOk = new BitmapButton();
			btnOk.setStandartButtonParams();
			btnOk.cancelOnVerticalMovement = true;
			btnOk.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			btnOk.setDownScale(1);
			btnOk.setDownColor(0);
			btnOk.hide();
			btnOk.tapCallback = onCloseTap;
			btnOk.disposeBitmapOnDestroy = true;
			container.addChild(btnOk);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			tfDescription.width = componentsWidth;
			tfDescription.height = tfDescription.textHeight + 4;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textOk.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * 1.2);
			btnOk.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void {
			super.drawView();
			
			btnOk.y = scrollPanel.view.y + scrollPanel.height + vPadding;
			btnOk.x = int(_width * .5 - btnOk.width * .5);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			if (btnOk.getIsShown() == false)
				btnOk.show(.3, .15, true, 0.9, 0);
			btnOk.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			btnOk.deactivate();
		}
		
		override protected function getMaxContentHeight():int {
			var value:int = _height - scrollPanel.view.y - btnOk.height - vPadding * 2;
			return value;
		}
		
		override protected function calculateBGHeight():int {
			var value:int = scrollPanel.view.y + scrollPanel.height + vPadding * 2 + btnOk.height;
			return value;
		}
		
		private function onCancel():void {
			onCloseTap();
		}
		
		override public function dispose():void {
			super.dispose();
			if (btnOk != null)
				btnOk.dispose();
			btnOk = null;
			if (tfDescription != null) {
				tfDescription.htmlText = "";
				if (tfDescription.parent != null)
					tfDescription.parent.removeChild(tfDescription);
			}
			tfDescription = null;
			
			Overlay.removeCurrent();
		}
	}
}