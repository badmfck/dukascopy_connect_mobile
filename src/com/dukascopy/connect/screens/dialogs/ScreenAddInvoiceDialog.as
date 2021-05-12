package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.textedit.PayMessagePreviewBox;
	import com.dukascopy.connect.gui.textedit.TextComposer;
	import com.dukascopy.connect.screens.dialogs.loader.DotLoader;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	

	public class ScreenAddInvoiceDialog extends ScreenAlertDialog {
		
		static private var paramsObjTemp:Object; 
		
		private var labelBitmapAmount:Bitmap;
		private var iAmount:Input;
		private var labelBitmapCurrency:Bitmap;
		private var iCurrency:DDFieldButton;
		private var descriptionBox:PayMessagePreviewBox;
		private var labelBitmapFullName:Bitmap;
		private var dotLoader:DotLoader;
		
		private var messageComposer:TextComposer;
		
		private var paramsObj:Object = { };
		
		public function ScreenAddInvoiceDialog() { }
		
		override protected function createView():void {
			super.createView();
			labelBitmapAmount = new Bitmap();
			content.addObject(labelBitmapAmount);
			iAmount = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmount.S_CHANGED.add(onChangeInputValue);
			iAmount.setRoundBG(false);
			iAmount.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			iAmount.setRoundRectangleRadius(0);
			iAmount.inUse = true;
			content.addObject(iAmount.view);
			labelBitmapCurrency = new Bitmap();
			content.addObject(labelBitmapCurrency);
			iCurrency = new DDFieldButton(selectCurrency);
			descriptionBox = new PayMessagePreviewBox();
			descriptionBox.emptyLabelText = Lang.addYourDescription;
			descriptionBox.init();
			content.addObject(descriptionBox);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if (data != null && "additionalData" in data == true && data.additionalData != null) {
				if ("amount" in data.additionalData == true && data.additionalData.amount != null && !isNaN(Number(data.additionalData.amount))) {
					paramsObj.amount = data.additionalData.amount;
					iAmount.value = paramsObj.amount;
				}
				if ("currency" in data.additionalData == true && data.additionalData.currency != null) {
					paramsObj.currency = data.additionalData.currency;
					iCurrency.setValue(paramsObj.currency);
				}
				if ("message" in data.additionalData == true && data.additionalData.message != null) {
					paramsObj.message = data.additionalData.message;
					descriptionBox.textValue = paramsObj.message;
				}
			}
			if ("currency" in paramsObj == false) {
				if (dotLoader == null) {
					dotLoader = new DotLoader();
					dotLoader.startAnim();
				}
				content.addObject(dotLoader);
				PayManager.callGetSystemOptions(onSystemOptions);
			} else
				content.addObject(iCurrency);
			if (data.thirdparty == true) {
				labelBitmapFullName = new Bitmap();
				content.addObject(labelBitmapFullName);
			}
			checkStateForBtn();
		}
		
		private function onSystemOptions():void {
			if (_isDisposed == true)
				return;
			if (PayManager.systemOptions == null)
				return;
			if (PayManager.systemOptions.currencyList == null || PayManager.systemOptions.currencyList.length == 0)
				return;
			if (dotLoader != null) {
				dotLoader.stopAnim();
				content.removeObject(dotLoader);
			}
			content.addObject(iCurrency);
			paramsObj.currency = PayManager.systemOptions.currencyList[0];
			iCurrency.setValue(paramsObj.currency);
			checkStateForBtn();
		}
		
		private function onChangeInputValue():void {
			var amount:Number = Number(iAmount.value);
			if (isNaN(amount) == true)
				return;
			paramsObj.amount = amount;
			checkStateForBtn();
		}
		
		private function selectCurrency(e:Event = null):void {
			paramsObjTemp = paramsObj;
			var currencies:Array = PayManager.systemOptions.currencyList.concat();
			if (data.thirdparty != true)
				currencies.unshift(TypeCurrency.DCO);
			DialogManager.showDialog(ScreenPayDialog, { callback:callBackSelectCurrency, data:currencies, itemClass:ListPayCurrency, label:Lang.selectCurrency } );
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (currency != null)
				paramsObjTemp.currency = currency;
			_data.additionalData = null;
			DialogManager.showAddInvoice(null, _data, paramsObjTemp);
			paramsObjTemp = null;
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void {
			var callBackFunction:Function = callback;
			callback = null;
			if ("message" in paramsObj == false || paramsObj.message == null)
				paramsObj.message = "";
			if (value != 1)
				callBackFunction(value, null);
			else
				callBackFunction(value, paramsObj);
		}
		
		override protected function updateContentHeight():void {
			if (_data.thirdparty == true)
				contentHeight = headerHeight + padding * 3.6 + labelBitmapFullName.y + labelBitmapFullName.height + buttonsAreaHeight;
			else
				contentHeight = headerHeight + padding * 3.6 + descriptionBox.y + descriptionBox.height + buttonsAreaHeight;
		}
		
		override protected function recreateContent(padding:Number):void {
			var contentWidth:int = _width - padding * 2;
			var trueWidth:int = int((contentWidth - Config.DOUBLE_MARGIN) * .5);
			
			if (labelBitmapAmount.bitmapData == null)
				labelBitmapAmount.bitmapData = createLabel(Lang.textAmount, trueWidth);
			if (labelBitmapCurrency.bitmapData == null)
				labelBitmapCurrency.bitmapData = createLabel(Lang.textCurrency, trueWidth);
			if (labelBitmapFullName != null && labelBitmapFullName.bitmapData == null)
				labelBitmapFullName.bitmapData = createLabel(Lang.textFullNameInvoice, contentWidth, Config.FINGER_SIZE_DOT_25, 0);
			
			iAmount.width = trueWidth;
			iAmount.view.y = int(labelBitmapAmount.y + labelBitmapAmount.height);
			
			labelBitmapCurrency.x = trueWidth + Config.DOUBLE_MARGIN;
			
			iCurrency.setSize(trueWidth, Config.FINGER_SIZE * .8);
			iCurrency.x = labelBitmapCurrency.x;
			iCurrency.y = iAmount.view.y;
			
			descriptionBox.viewWidth = contentWidth;
			descriptionBox.y = iAmount.view.y + iAmount.view.height + Config.DOUBLE_MARGIN;
			
			if (labelBitmapFullName != null)
				labelBitmapFullName.y = descriptionBox.y + descriptionBox.height + Config.MARGIN;
			
			if (dotLoader != null && dotLoader.parent != null) {
				dotLoader.y = iAmount.view.y + Config.DOUBLE_MARGIN;
				dotLoader.x = labelBitmapCurrency.x;
			}
		}
		
		private function createLabel(txt:String, w:int, fontSize:int = 0, color:uint = AppTheme.GREY_MEDIUM):ImageBitmapData {
			if (fontSize == 0)
				fontSize = Config.FINGER_SIZE * .21;
			return UI.renderTextShadowed(
				txt,
				w,
				Config.FINGER_SIZE,
				false,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				fontSize,
				false,
				0xffffff,
				0x000000,
				color,
				true,
				1,
				false
			);
		}
		
		private function onAddMessageClick(e:Event = null):void {
			deactivateScreen();
			if (messageComposer == null) {
				messageComposer = new TextComposer();
				messageComposer.MAX_CHARS = 256;
			}
			messageComposer.setSize(
				MobileGui.stage.stageWidth,
				MobileGui.stage.stageHeight
			);
			MobileGui.stage.addChild(messageComposer);
			messageComposer.show(
				onMessageComposeComplete,
				Lang.TEXT_COMPOSE_MESSAGE,
				(paramsObj.message != null) ? paramsObj.message : ""
			);
		}
		
		private function onMessageComposeComplete(isOk:Boolean, result:String = "", dataObject:Object = null):void {
			if (isOk) {
				paramsObj.message = result;
				descriptionBox.textValue = result;
				messageComposer.hide(true);
			} else {
				messageComposer.hide();
			}
			activateScreen();
			drawView();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			var locked:Boolean = false;
			if (data != null && "additionalData" in data == true && data.additionalData != null) {
				if ("block" in data.additionalData == true && data.additionalData.block == true) {
					locked = true;
				}
			}
			
			if (locked == false)
			{
				if (iAmount != null) {
					iAmount.activate();
					iAmount.S_CHANGED.add(onChangeInputValue);
				}
				if (iCurrency != null)
					iCurrency.activate();
				if (descriptionBox != null)
					PointerManager.addTap(descriptionBox, onAddMessageClick);
			}
			
			checkStateForBtn();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (iAmount != null) {
				if (iAmount.value == "")
					iAmount.forceFocusOut();
				iAmount.deactivate();
				iAmount.S_CHANGED.remove(onChangeInputValue);
			}
			if (iCurrency != null)
				iCurrency.deactivate();
			if (descriptionBox != null)
				PointerManager.removeTap(descriptionBox, onAddMessageClick);
		}
		
		private function checkStateForBtn():void {
			if (_isDisposed == true)
				return;
			if (button0 == null)
				return;
			var needActivate:Boolean = false;
			if ("amount" in paramsObj == true &&
				paramsObj.amount != 0 &&
				"currency" in paramsObj == true)
					needActivate = true;
			if (needActivate == true) {
				if (_isActivated == true) {
					button0.alpha = 1;
					button0.activate();
				}
			} else {
				button0.alpha = .7;
				button0.deactivate();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			if (dotLoader)
				dotLoader.dispose();
			dotLoader = null;
			if (descriptionBox != null) {
				UI.safeRemoveChild(descriptionBox);
				descriptionBox.dispose();
			}
			descriptionBox = null;
			if (messageComposer != null) {
				UI.safeRemoveChild(messageComposer);
				messageComposer.dispose();
			}
			messageComposer = null;
			if (labelBitmapAmount != null)
				UI.destroy(labelBitmapAmount);
			labelBitmapAmount = null;
			if (labelBitmapCurrency != null)
				UI.destroy(labelBitmapCurrency);
			labelBitmapCurrency = null;
			if (labelBitmapFullName != null)
				UI.destroy(labelBitmapFullName);
			labelBitmapFullName = null;
			if (iCurrency != null)
				iCurrency.dispose();
			iCurrency = null;
			if (iAmount != null)
				iAmount.deactivate();
			iAmount = null;
			paramsObj = null;
		}
	}
}