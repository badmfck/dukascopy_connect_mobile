package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCryptoWallet;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayLimits;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision Team RIGA.
	 */
	
	public class ScreenExtraTipsPopup extends DialogBaseScreen {
		
		private var labelAmount:Bitmap;
		private var inputAmount:Input;
		private var labelCurrency:Bitmap;
		private var inputCurrency:DDFieldButton;
		
		private var btnOk:BitmapButton;
		
		private var inputWidth:int;
		private var selectedInstrument:EscrowInstrument;
		
		public function ScreenExtraTipsPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			labelAmount = new Bitmap();
			scrollPanel.addObject(labelAmount);
			labelAmount.x = hPadding;
			
			inputAmount = new Input(Input.MODE_DIGIT_DECIMAL);
			inputAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			inputAmount.setDecimals(2);
			inputAmount.setRoundBG(false);
			inputAmount.setTextColor(0x5D6A77);
			inputAmount.setRoundRectangleRadius(0);
			inputAmount.inUse = true;
			scrollPanel.addObject(inputAmount.view);
			
			labelCurrency = new Bitmap();
			scrollPanel.addObject(labelCurrency);
			
			inputCurrency = new DDFieldButton(selectCurrency);
			scrollPanel.addObject(inputCurrency);
			
			btnOk = new BitmapButton();
			btnOk.setStandartButtonParams();
			btnOk.cancelOnVerticalMovement = true;
			btnOk.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			btnOk.setDownScale(1);
			btnOk.setDownColor(0);
			btnOk.alpha = .6;
			btnOk.hide();
			btnOk.tapCallback = onOK;
			btnOk.disposeBitmapOnDestroy = true;
			container.addChild(btnOk);
		}
		
		private function checkDataValid():void {
			var tipsLimitMax:int = int.MAX_VALUE;
			var tipsLimitMin:Number = 0
			var tipsAmount:Number = Number(inputAmount.value);
			if (isNaN(tipsAmount) == true)
				inputAmount.setIncorrect(true);
			else if (tipsAmount > tipsLimitMax)
				inputAmount.setIncorrect(true);
			else if (tipsAmount < tipsLimitMin) 
				inputAmount.setIncorrect(true);
			else
				inputAmount.setIncorrect(false);
			if (_isActivated == true && 
				inputAmount.getIncorrect() == false &&
				selectedInstrument != null) {
					btnOk.activate();
					btnOk.alpha = 1;
			} else {
				btnOk.deactivate();
				btnOk.alpha = 0.5;
			}
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			inputWidth = (componentsWidth - Config.MARGIN) * .5;
			
			if (labelAmount.bitmapData == null)
				labelAmount.bitmapData = createLabel(Lang.textAmount);
			if (labelCurrency.bitmapData == null)
				labelCurrency.bitmapData = createLabel(Lang.textCurrency);
			if (isNaN(QuestionsManager.getTipsAmount()) == false && QuestionsManager.getTipsAmount() != 0) {
				inputAmount.value = QuestionsManager.getTipsAmount().toString();
				inputAmount.setIncorrect(false);
			}
			inputAmount.width = inputWidth;
			inputAmount.view.x = labelAmount.x;
			inputAmount.view.y = int(labelAmount.y + labelAmount.height + Config.MARGIN);
			
			labelCurrency.x = labelAmount.x + inputWidth + Config.MARGIN;
			
			inputCurrency.setSize(inputWidth, inputAmount.height);
			inputCurrency.x = labelCurrency.x;
			inputCurrency.y = inputAmount.view.y;
			if (QuestionsManager.getTipsCurrency())
				callBackSelectCurrency(QuestionsManager.getTipsCurrency());
			
			var tipsLimitMax:int = int.MAX_VALUE;
			var tipsLimitMin:Number = 0;
			inputAmount.setMaxValue(tipsLimitMax);
			inputAmount.setMinValue(tipsLimitMin);
			
			var textSettings_ok:TextFieldSettings = new TextFieldSettings(Lang.textOk.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_ok:ImageBitmapData = TextUtils.createbutton(textSettings_ok, Color.GREEN, 1);
			btnOk.setBitmapData(buttonBitmap_ok, true);
			btnOk.x = int(_width * .5 - btnOk.width * .5);
		}
		
		override protected function drawView():void {
			super.drawView();
			btnOk.y = scrollPanel.view.y + scrollPanel.height + vPadding;
		}
		
		private function createLabel(val:String):ImageBitmapData {
			var ibmd:ImageBitmapData = UI.renderTextShadowed(
				val,
				inputWidth,
				Config.FINGER_SIZE,
				false,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .23,
				false,
				0xFFFFFF,
				0x000000,
				AppTheme.GREY_MEDIUM,
				true,
				1,
				false
			);
			return ibmd;
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
			if (inputAmount != null) {
				inputAmount.activate();
				if (inputAmount.S_CHANGED != null)
					inputAmount.S_CHANGED.add(onChangeInputValue);
			}
			if (inputCurrency != null)
				inputCurrency.activate();
			if (btnOk.getIsShown() == false)
				btnOk.show(.3, .15, true, 0.9, 0);
			SoftKeyboard.S_KEY.add(changeBtnOKState);
			checkDataValid();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (inputAmount != null) {
				if (inputAmount.value == "")
					inputAmount.forceFocusOut();
				if (inputAmount.S_CHANGED != null)
					inputAmount.S_CHANGED.remove(onChangeInputValue);
				inputAmount.deactivate();
			}
			if (inputCurrency != null)
				inputCurrency.deactivate();
			SoftKeyboard.S_KEY.remove(changeBtnOKState);
		}
		
		private function changeBtnOKState(...rest):void {
			if (_isDisposed == true)
				return;
			checkDataValid();
		}
		
		private function onChangeInputValue():void {
			checkDataValid();
		}
		
		private function selectCurrency():void {
			GD.S_ESCROW_INSTRUMENTS.add(onResult);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
		}
		
		private function onResult(instruments:Vector.<EscrowInstrument>):void {
			GD.S_ESCROW_INSTRUMENTS.remove(onResult);
			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:instruments,
					title:Lang.selectCurrency,
					renderer:ListCryptoWallet,
					callback:callBackSelectCurrency
				},
				DialogManager.TYPE_SCREEN
			);
		}
		
		private function callBackSelectCurrency(ei:EscrowInstrument):void {
			selectedInstrument = ei;
			if (!isDisposed) {
				inputCurrency.setValueExtend(ei.name, selectCurrency, UI.getInvestIconByInstrument(ei.code));
				checkDataValid();
			}
		}
		
		private function onOK():void {
			var currency:String = selectedInstrument.code;
			if (currency == "DUK+") {
				currency = "DCO";
			}
			QuestionsManager.saveTipsForCurrentQuestion(Number(inputAmount.value), selectedInstrument, true);
			if (QuestionsManager.getCurrentQuestion() != null)
				QuestionsManager.editQuestion(QuestionsManager.getCurrentQuestion().uid, null);
			onCloseTap();
		}
		
		override protected function onCloseTap():void {
			if (QuestionsManager.getTipsSetted() != true)
				QuestionsManager.resetTips();
			if (_isDisposed == true)
				return;
			if (data.callback != null)
				data.callback(0);
			ServiceScreenManager.closeView();
		}
		
		override public function dispose():void {
			super.dispose();
			UI.destroy(labelAmount);
			labelAmount = null;
			if (inputAmount != null)
				inputAmount.dispose();
			inputAmount = null;
			UI.destroy(labelCurrency);
			if (inputCurrency != null)
				inputCurrency.dispose();
			inputCurrency = null;;
			if (btnOk != null)
				btnOk.dispose();
			btnOk = null;
			Overlay.removeCurrent();
			selectedInstrument = null;
		}
	}
}