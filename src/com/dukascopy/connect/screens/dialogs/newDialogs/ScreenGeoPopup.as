package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.sys.categories.CategoryManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.langs.Lang;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision Team RIGA.
	 */
	
	public class ScreenGeoPopup extends DialogBaseScreen {
		
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		
		private var btnAnonim:OptionSwitcher;
		private var tfDisclaimer:TextField;
		
		private var btnOk:RoundedButton;
		private var btnCancel:RoundedButton;
		
		private var onOKFunction:Function;
		
		public function ScreenGeoPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			btnCancel = new RoundedButton(Lang.textCancel.toUpperCase(), MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, null);
			btnCancel.setStandartButtonParams();
			btnCancel.setDownScale(1);
			btnCancel.cancelOnVerticalMovement = true;
			btnCancel.tapCallback = onCloseTap;
			btnCancel.hide();
			btnCancel.draw();
			container.addChild(btnCancel);
			
			btnOk = new RoundedButton(Lang.textOk.toUpperCase(), MainColors.RED, MainColors.RED_DARK, null);
			btnOk.setStandartButtonParams();
			btnOk.setDownScale(1);
			btnOk.cancelOnVerticalMovement = true;
			btnOk.tapCallback = onOK;
			btnOk.setSizeLimits(btnCancel.width, btnCancel.width);
			btnOk.hide();
			btnOk.draw();
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
				btnAnonim.create(componentsWidth - scrollPanel.getScrollBarWidth() - Config.MARGIN, OPTION_LINE_HEIGHT, null, Lang.textGeo, QuestionsManager.getQuestionSecretMode(), true, -1, NaN, 0);
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
			tFormat.color = MainColors.DARK_BLUE;
			
			tfDisclaimer = new TextField();
			tfDisclaimer.defaultTextFormat = tFormat;
			tfDisclaimer.text = Lang.categoryDatingDisclaimer;
			tfDisclaimer.cacheAsBitmap = true;
			tfDisclaimer.multiline = true;
			tfDisclaimer.wordWrap = true;
			tfDisclaimer.selectable = false;
			tfDisclaimer.y = btnAnonim.y + btnAnonim.height + Config.DOUBLE_MARGIN;
			tfDisclaimer.width = componentsWidth - scrollPanel.getScrollBarWidth() - Config.MARGIN;
			tfDisclaimer.height = tfDisclaimer.textHeight + 4;
			addDisclaimerTF();
		}
		
		private function addDisclaimerTF():void {
			scrollPanel.addObject(tfDisclaimer);
			drawView();
			btnOk.setValue(Lang.iAgree.toUpperCase());
		}
		
		private function hideDisclaimer():void {
			var needToRemoveDisclaimer:Boolean = true;
			if (tfDisclaimer == null || tfDisclaimer.parent == null)
				needToRemoveDisclaimer = false;
			if (needToRemoveDisclaimer == false)
				return;
			scrollPanel.removeObject(tfDisclaimer);
			drawView();
			btnOk.setValue(Lang.textOk.toUpperCase());
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			onOKFunction = data.onOKFunction;
			
			showAnonim();
			preShowDisclaimer();
			
			btnCancel.x = _width * .5 - btnCancel.width - Config.MARGIN;
			btnOk.x = _width * .5 + Config.MARGIN;
		}
		
		override protected function drawView():void {
			super.drawView();
			
			btnCancel.y = scrollPanel.view.y + scrollPanel.height + Config.DOUBLE_MARGIN;
			btnOk.y = btnCancel.y;
			
			scrollPanel.update();
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - Config.DOUBLE_MARGIN * 2 - btnOk.height;
		}
		
		override protected function calculateBGHeight():int {
			return scrollPanel.view.y + scrollPanel.height + Config.DOUBLE_MARGIN * 2 + btnOk.height;
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
		}
	}
}