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
	
	public class ScreenMissRulesPopup extends DialogBaseScreen {
		
		private var tfDescription:TextField;
		private var btnOk:BitmapButton;
		
		public function ScreenMissRulesPopup() {
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
			tfDescription.htmlText = Lang.missRulesDialogText;
			
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