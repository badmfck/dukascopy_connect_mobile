package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.categories.CategoryManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision Team RIGA.
	 */
	
	public class ScreenSecretPopup extends DialogBaseScreen {
		
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		
		private var btnAnonim:OptionSwitcher;
		private var tfDisclaimer:TextField;
		
		private var btnOk:BitmapButton;
		private var btnCancel:BitmapButton;
		
		private var onOKFunction:Function;
		private var buttonWidth:int;
		
		public function ScreenSecretPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			btnCancel = new BitmapButton();
			btnCancel.setStandartButtonParams();
			btnCancel.cancelOnVerticalMovement = true;
			btnCancel.setDownScale(1);
			btnCancel.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			btnCancel.setDownColor(0);
			btnCancel.tapCallback = onCloseTap;
			btnCancel.disposeBitmapOnDestroy = true;
			btnCancel.hide();
			container.addChild(btnCancel);
			
			btnOk = new BitmapButton();
			btnOk.setStandartButtonParams();
			btnOk.cancelOnVerticalMovement = true;
			btnOk.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			btnOk.setDownScale(1);
			btnOk.setDownColor(0);
			btnOk.hide();
			btnOk.tapCallback = onOK;
			btnOk.disposeBitmapOnDestroy = true;
			container.addChild(btnOk);
		}
		
		public function preShowDisclaimer():void {
			deactivateScreen();
			CategoryManager.getNeedDisclaimer(onNeedDisclaimerLoaded);
		}
		
		private function onNeedDisclaimerLoaded(data:Object, err:Boolean):void {
			if (_isDisposed == true)
				return;
			if (err == true) {
				showDisclaimer();
				return;
			}
			if (data == true) {
				CategoryManager.setNeedDisclaimer();
				activateScreen();
				return;
			}
			showDisclaimer();
		}
		
		private function showAnonim():void {
			if (btnAnonim == null) {
				btnAnonim = new OptionSwitcher();
				btnAnonim.x = hPadding;
				btnAnonim.create(componentsWidth, OPTION_LINE_HEIGHT, null, Lang.textIncognito, QuestionsManager.getQuestionSecretMode(), true, -1, NaN, 0);
				btnAnonim.onSwitchCallback = onAnonimTap;
			}
			scrollPanel.addObject(btnAnonim);
		}
		
		public function showDisclaimer():void {
			activateScreen();
			createDisclaimerTF();
		}
		
		private function createDisclaimerTF():void {
			if (tfDisclaimer != null) {
				if (tfDisclaimer.parent == null)
					addDisclaimerTF();
				return;
			}
			var tFormat:TextFormat = new TextFormat();
			tFormat.font = Config.defaultFontName;
			tFormat.size = Config.FINGER_SIZE * .3;
			tFormat.color = 0x7B8C9F;
			
			tfDisclaimer = new TextField();
			tfDisclaimer.x = hPadding;
			tfDisclaimer.textColor = 0x47515B;
			tfDisclaimer.defaultTextFormat = tFormat;
			tfDisclaimer.text = Lang.categoryDatingDisclaimer;
			tfDisclaimer.cacheAsBitmap = true;
			tfDisclaimer.multiline = true;
			tfDisclaimer.wordWrap = true;
			tfDisclaimer.selectable = false;
			tfDisclaimer.y = btnAnonim.y + btnAnonim.height + Config.DOUBLE_MARGIN;
			tfDisclaimer.width = componentsWidth;
			tfDisclaimer.height = tfDisclaimer.textHeight + 4;
			addDisclaimerTF();
		}
		
		private function addDisclaimerTF():void {
			scrollPanel.addObject(tfDisclaimer);
			drawView();
			
			var textSettings_ok:TextFieldSettings = new TextFieldSettings(Lang.iAgree.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_ok:ImageBitmapData = TextUtils.createbutton(textSettings_ok, Color.GREEN, 1, -1, NaN, buttonWidth);
			btnOk.setBitmapData(buttonBitmap_ok, true);
			
			scrollPanel.hideScrollBar();
		}
		
		private function hideDisclaimer():void {
			var needToRemoveDisclaimer:Boolean = true;
			if (tfDisclaimer == null || tfDisclaimer.parent == null)
				needToRemoveDisclaimer = false;
			if (needToRemoveDisclaimer == false)
				return;
			scrollPanel.removeObject(tfDisclaimer);
			drawView();
			
			var textSettings_ok:TextFieldSettings = new TextFieldSettings(Lang.textOk.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_ok:ImageBitmapData = TextUtils.createbutton(textSettings_ok, Color.GREEN, 1, -1, NaN, buttonWidth);
			btnOk.setBitmapData(buttonBitmap_ok, true);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			onOKFunction = data.onOKFunction;
			
			showAnonim();
			preShowDisclaimer();
			
			buttonWidth = (_width - hPadding * 2 - Config.MARGIN * 2) * .5;
			
			var textSettings_ok:TextFieldSettings = new TextFieldSettings(Lang.textOk.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_ok:ImageBitmapData = TextUtils.createbutton(textSettings_ok, Color.GREEN, 1, -1, NaN, buttonWidth);
			btnOk.setBitmapData(buttonBitmap_ok, true);
			
			var textSettings_cancel:TextFieldSettings = new TextFieldSettings(Lang.textCancel, 0x5D6A77, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_cancel:ImageBitmapData = TextUtils.createbutton(textSettings_cancel, 0x6B7A8A, 0, -1, 0x999999, buttonWidth);
			btnCancel.setBitmapData(buttonBitmap_cancel, true);
			
			btnCancel.x = _width * .5 - btnCancel.width - Config.MARGIN;
			btnOk.x = _width * .5 + Config.MARGIN;
		}
		
		override protected function drawView():void {
			super.drawView();
			
			btnCancel.y = scrollPanel.view.y + scrollPanel.height + vPadding;
			btnOk.y = btnCancel.y;
			
			scrollPanel.update();
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - vPadding * 2 - btnOk.height;
		}
		
		override protected function calculateBGHeight():int {
			return scrollPanel.view.y + scrollPanel.height + vPadding * 2 + btnOk.height;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			if (btnCancel != null) {
				if (btnCancel.getIsShown() == false)
					btnCancel.show(.3, 0, true, 0.9, 0);
				btnCancel.activate();
				btnCancel.alpha = 1;
			}
			if (btnOk != null) {
				if (btnOk.getIsShown() == false)
					btnOk.show(.3, .15, true, 0.9, 0);
				btnOk.activate();
				btnOk.alpha = 1;
			}
			if (btnAnonim != null)
				btnAnonim.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (btnCancel != null) {
				btnCancel.deactivate();
				btnCancel.alpha = .7;
			}
			if (btnOk != null) {
				btnOk.deactivate();
				btnOk.alpha = .7;
			}
			if (btnAnonim != null)
				btnAnonim.deactivate();
		}
		
		static private function onAnonimTap(value:Boolean):void {
			echo("ScreenCategoriesPopup", "onAnonimTap");
		}
		
		private function onOK():void {
			if (onOKFunction != null) {
				if (btnAnonim != null)
					onOKFunction(btnAnonim.isSelected);
			}
			if (tfDisclaimer != null && tfDisclaimer.parent != null) {
				CategoryManager.setNeedDisclaimer();
			}
			onCloseTap();
		}
		
		override public function dispose():void {
			super.dispose();
			if (btnCancel != null)
				btnCancel.dispose();
			btnCancel = null;
			if (btnOk != null)
				btnOk.dispose();
			btnOk = null;
			if (tfDisclaimer != null)
				tfDisclaimer.text = "";
			tfDisclaimer = null;
			if (btnAnonim != null) {
				if (btnAnonim.parent != null)
					btnAnonim.parent.removeChild(btnAnonim);
				btnAnonim.dispose();
			}
			btnAnonim = null;
			
			onOKFunction = null;
			
			Overlay.removeCurrent();
		}
	}
}