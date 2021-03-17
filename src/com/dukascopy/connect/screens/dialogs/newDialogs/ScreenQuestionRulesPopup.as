package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.UserQuestionsStatScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision Team RIGA.
	 */
	
	public class ScreenQuestionRulesPopup extends DialogBaseScreen {
		
		private var btnPayments:BitmapButton;
		private var btnStatistics:BitmapButton;
		private var tfDescription:TextField;
		private var btnOk:BitmapButton;
		private var btnTerms:BitmapButton;
		private var preloader:Preloader;
		
		private var paymentsReady:Boolean = false;
		private var inputWidth:int;
		
		public function ScreenQuestionRulesPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			scrollPanel.view.visible = false;
			
			preloader = new Preloader();
			preloader.show();
			_view.addChild(preloader);
			
			var tFormat:TextFormat = new TextFormat();
			tFormat.font = Config.defaultFontName;
			tFormat.size = Config.FINGER_SIZE * .3;
			tFormat.color = Style.color(Style.COLOR_TEXT);
			
			btnStatistics = new BitmapButton();
			btnStatistics.setStandartButtonParams();
			btnStatistics.setDownScale(1);
			btnStatistics.cancelOnVerticalMovement = true;
			btnStatistics.tapCallback = on911SectionTap;
			btnStatistics.show();
			container.addChild(btnStatistics);
			
			tfDescription = new TextField();
			tfDescription.x = hPadding;
			tfDescription.defaultTextFormat = tFormat;
			tfDescription.text = Lang.questionRulesDialogText;
			tfDescription.textColor = 0x7B8C9F;
			
		//  on iphone > 6 leads to display bug;
		//	tfDescription.cacheAsBitmap = true;
			
			tfDescription.multiline = true;
			tfDescription.wordWrap = true;
			tfDescription.selectable = false;
			scrollPanel.addObject(tfDescription);
			
			btnTerms = new BitmapButton();
			btnTerms.setStandartButtonParams();
			btnTerms.cancelOnVerticalMovement = true;
			btnTerms.setDownScale(1);
			btnTerms.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			btnTerms.setDownColor(0);
			btnTerms.tapCallback = onCancel;
			btnTerms.disposeBitmapOnDestroy = true;
			btnTerms.hide();
			container.addChild(btnTerms);
			
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
			
			btnStatistics.setBitmapData(
				TextUtils.createTextFieldData(
					"<u>" + Lang.section911My + "</u>",
					componentsWidth,
					10,
					true,
					TextFormatAlign.LEFT,
					TextFieldAutoSize.LEFT,
					Config.FINGER_SIZE * .3,
					true,
					0x0000FF,
					0xFFFFFF,
					true,
					true
				),
				true
			);
			
			btnStatistics.x = hPadding;
			
			tfDescription.width = componentsWidth;
			tfDescription.height = tfDescription.textHeight + 4;
			scrollPanel.view.y = btnStatistics.y + btnStatistics.height + Config.MARGIN;
			
			scrollPanel.update();
			preloader.x = int((componentsWidth - preloader.width) * .5) + scrollPanel.view.x;
			
			
			var textSettings_terms:TextFieldSettings = new TextFieldSettings(Lang.TEXT_TERMS_CONDITIONS, 0x5D6A77, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_terms:ImageBitmapData = TextUtils.createbutton(textSettings_terms, 0x6B7A8A, 0, -1, 0x999999);
			btnTerms.setBitmapData(buttonBitmap_terms, true);
			
			var textSettings_ok:TextFieldSettings = new TextFieldSettings(Lang.close, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_ok:ImageBitmapData = TextUtils.createbutton(textSettings_ok, Color.GREEN, 1, -1, NaN, buttonBitmap_terms.width);
			btnOk.setBitmapData(buttonBitmap_ok, true);
			
			
			btnTerms.x = btnOk.x = int((_width - btnTerms.width) * .5);
		}
		
		override protected function drawView():void {
			super.drawView();
			
			btnStatistics.y = topBar.trueHeight + Config.DOUBLE_MARGIN;
			var scrollPanelPosition:int;
			if (btnPayments != null){
				scrollPanel.view.y = btnPayments.y + btnPayments.height + Config.MARGIN;
			}else{
				scrollPanel.view.y = btnStatistics.y + btnStatistics.height + Config.MARGIN;
			}
			
			preloader.y = int((scrollPanel.height - preloader.height) * .5) + scrollPanel.view.y;
			
			btnTerms.y = scrollPanel.view.y + scrollPanel.height + vPadding;
			btnOk.y = btnTerms.y + btnTerms.height + vPadding;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			if (btnTerms.getIsShown() == false)
				btnTerms.show(.3, 0, true, 0.9, 0);
			btnTerms.activate();
			if (btnOk.getIsShown() == false)
				btnOk.show(.3, .15, true, 0.9, 0);
			btnOk.activate();
			if (btnPayments != null)
				btnPayments.activate();
			if (btnStatistics != null)
				btnStatistics.activate();
			onPayStatus();
		}
		
		private function onPayStatus():void {
			preloader.hide();
			scrollPanel.view.visible = true;
			if (PayAPIManager.hasSwissAccount == true)
				addPaymentsButton();
		}
		
		private function addPaymentsButton():void {
			btnPayments = new BitmapButton();
			btnPayments.setStandartButtonParams();
			btnPayments.setDownScale(1);
			btnPayments.cancelOnVerticalMovement = true;
			btnPayments.tapCallback = onPayments;
			btnPayments.show();
			btnPayments.setBitmapData(
				TextUtils.createTextFieldData(
					"<u>" + Lang.openAccountAndGetRewards + "</u>",
					componentsWidth,
					10,
					true,
					TextFormatAlign.LEFT,
					TextFieldAutoSize.LEFT,
					Config.FINGER_SIZE * .3,
					true,
					0x0000FF,
					0xFFFFFF,
					true,
					true
				),
				true
			);
			btnPayments.x = hPadding;
			btnPayments.y = btnStatistics.y + btnStatistics.height + Config.MARGIN;
			container.addChild(btnPayments);
			drawView();
			if (btnPayments != null)
				btnPayments.activate();
		}
		
		private function onPayments():void {
			MobileGui.showRoadMap();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			btnTerms.deactivate();
			btnOk.deactivate();
			if (btnPayments != null)
				btnPayments.deactivate();
		}
		
		override protected function getMaxContentHeight():int {
			var value:int = _height - scrollPanel.view.y - vPadding * 3 - btnOk.height * 2;
			if (btnStatistics != null){
				value -= btnStatistics.height + Config.MARGIN;
			}
			if (btnPayments != null){
				value -= btnPayments.height + Config.MARGIN;
			}
			return value;
		}
		
		override protected function calculateBGHeight():int {
			var value:int = scrollPanel.view.y + scrollPanel.height + vPadding * 3 + btnOk.height * 2;
			if (btnStatistics != null){
				value += btnStatistics.height + Config.MARGIN;
			}
			if (btnPayments != null){
				value += btnPayments.height + Config.MARGIN;
			}
			return value;
		}
		
		private function on911SectionTap():void {
			var data:Object = { };
			data.backScreen = MobileGui.centerScreen.currentScreenClass;
			data.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.changeMainScreen(UserQuestionsStatScreen, data);
			onCloseTap();
		}
		
		private function onCancel():void {
			navigateToURL(new URLRequest("https://www.dukascopy.com/media/pdf/911/terms_and_conditions.pdf"));
			onCloseTap();
		}
		
		override public function dispose():void {
			super.dispose();
			if (btnTerms != null)
				btnTerms.dispose();
			btnTerms = null;
			if (btnOk != null)
				btnOk.dispose();
			btnOk = null;
			if (btnPayments != null)
				btnPayments.dispose();
			btnPayments = null;
			if (btnStatistics != null)
				btnStatistics.dispose();
			btnStatistics = null;
			if (tfDescription != null) {
				tfDescription.text = "";
				if (tfDescription.parent != null)
					tfDescription.parent.removeChild(tfDescription);
			}
			tfDescription = null;
			
			Overlay.removeCurrent();
		}
	}
}