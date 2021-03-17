package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAOtherAccSection extends Sprite {
		
		private var tfColorSelected:uint = 0x2B5FAB;
		private var tfColorBase:uint = 0x22546B;
		private var tfSizeSelected:int = Config.FINGER_SIZE * .23;
		private var tfSizeBase:int = Config.FINGER_SIZE * .2;
		
		private var tfNumber:TextField;
		private var tfAmount:TextField;
		private var tfAmountInCurrency:TextField;
		
		private var trueWidth:int;
		private var trueHeight:int;
		public var isTotal:Boolean = false;
		public var isLast:Boolean = false;
		private var data:Object;
		private var _isDisposed:Boolean = false;
		
		private var flagIcon:Bitmap;
		private var ICON_SIZE:int = Config.FINGER_SIZE * .45;
		
		public function BAOtherAccSection() {
			tfNumber = new TextField();
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase);
			tfNumber.multiline = false;
			tfNumber.wordWrap = false;
			tfNumber.text = "|";
			tfNumber.height = tfNumber.textHeight + 4;
			tfNumber.x = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			tfNumber.y = Config.MARGIN;
			addChild(tfNumber);
			
			tfAmount = new TextField();
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .25, 0x444444);
			tfAmount.multiline = true;
			tfAmount.wordWrap = true;
			tfAmount.y = int(tfNumber.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			tfAmount.x = tfNumber.x;
			addChild(tfAmount);
			
			tfAmountInCurrency = new TextField();
			tfAmountInCurrency.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .25);
			tfAmountInCurrency.multiline = false;
			tfAmountInCurrency.wordWrap = false;
			tfAmountInCurrency.autoSize = TextFieldAutoSize.LEFT;
			tfAmountInCurrency.text = "|";
			tfAmountInCurrency.height = tfAmount.textHeight + 4;
			tfAmountInCurrency.x = tfNumber.x;
			addChild(tfAmountInCurrency);
			
			flagIcon = new Bitmap();
			addChild(flagIcon);
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			if (_isDisposed == true)
				return;
			this.data = data;
			var leftX:int =  Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			var iban:String = data.IBAN;
			if (iban.indexOf("CH") == 0) {
				iban = iban.substr(0, 2) + " " + iban.substr(2);
				if (MobileGui.stage.stageWidth > 640)
					iban = iban.substr(0, 7) + " " + iban.substr(7, 4) + " " + iban.substr(11, 4) + " " + iban.substr(15, 4) + " " + iban.substr(19);
				else
					iban = iban.substr(0, 7) + " … " + iban.substr(iban.length - 4);
			}
			tfNumber.text = iban;
			if (MobileGui.stage.stageWidth <= 640)
				leftX = Config.FINGER_SIZE_DOT_25 + Config.MARGIN*.5;
			else
				leftX = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			tfNumber.x = leftX;
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			tfAmount.text = Lang.otherAccTypes[data.TYPE];
			var index:int = tfAmount.text.length;
			if (data.IS_ETHEREUM_FUNDING == "1")
				tfAmount.text += "\n" + Lang.textFundedByETH;
			else if (data.IS_BITCOIN_FUNDING == "1")
				tfAmount.text += "\n" + Lang.textFundedByBTC;
			else if (data.IS_DUKASCOINS_FUNDING == "1")
				tfAmount.text += "\n" + Lang.textFundedByDUK;
			if (index < tfAmount.text.length)
				tfAmount.setTextFormat(new TextFormat("Tahoma", Config.FINGER_SIZE * .21, 0x222222), index, tfAmount.text.length);
			tfAmount.width = w - tfAmount.x - Config.MARGIN;
			tfAmount.height = tfAmount.textHeight + 5;
			if (data.BALANCE != null) {
				var stringAmount:String = String(data.BALANCE);
				var dotIndex:int = stringAmount.indexOf(".");
				var fullPart:String;
				var decimalPart:String;
				if (dotIndex == -1) {
					fullPart = stringAmount + ".";
					decimalPart = String(Math.pow(10, CurrencyHelpers.getMaxDecimalCount(data.CURRENCY))).substr(1);
				} else {
					fullPart = stringAmount.substr(0, dotIndex + 1);
					decimalPart = stringAmount.substr(dotIndex + 1);
					decimalPart += String(Math.pow(10, (CurrencyHelpers.getMaxDecimalCount(data.CURRENCY) - decimalPart.length))).substr(1);
				}
				tfAmountInCurrency.htmlText = UI.renderCurrency(
					fullPart,
					decimalPart,
					data.CURRENCY,
					Config.FINGER_SIZE * .25,
					Config.FINGER_SIZE * .19
				);			
				tfAmountInCurrency.y = tfAmount.y + tfAmount.height;
			} else {
				tfAmountInCurrency.text = "";
			}
			UI.disposeBMD(flagIcon.bitmapData);
			if (data.INSTRUMENT != "" && data.type != "total") {
				flagIcon.visible = true;
				var flagAsset:Sprite = UI.getFlagByCurrency(data.CURRENCY);
				flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "BAInvestmentSection.flagIcon");
				if (data.CONSOLIDATE_BALANCE == null) {
					tfAmount.width = w -Config.DOUBLE_MARGIN * 4 - ICON_SIZE;
					tfAmount.htmlText = UI.renderCurrency(
						Lang.approveTerms,
						"",
						" ",
						Config.FINGER_SIZE * .25,
						Config.FINGER_SIZE * .19
					);		
				}
				flagIcon.x = leftX;
				tfAmount.x = leftX + Config.FINGER_SIZE*.5;
				tfAmountInCurrency.x = leftX + Config.FINGER_SIZE * .5;
			} else {
				flagIcon.visible = false;
				tfAmount.x = leftX;
				tfAmountInCurrency.x = leftX;
			}
			
			trueHeight = tfAmountInCurrency.y + tfAmountInCurrency.height + Config.MARGIN;
			trueWidth = w;
			
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			graphics.endFill();
			
			flagIcon.y = int((trueHeight - tfAmount.y - ICON_SIZE - Config.MARGIN) * .5 + tfAmount.y);
		}
		
		public function getAmountAscent():int {
			return tfAmount.getLineMetrics(0).ascent;
		}
		
		public function getAmountHeight():int {
			return tfAmount.height;
		}
		
		public function getWidth():int {
			return trueWidth;
		}
		
		public function getTrueWidth():int {
			if (_isDisposed)
				return 1;
			return Math.max(tfAmount.width, tfNumber.width);
		}
		
		public function dispose():void {
			if (_isDisposed)
				return;
			_isDisposed = true;
			graphics.clear();
			UI.destroy(tfNumber);
			UI.destroy(tfAmount)
			UI.destroy(tfAmountInCurrency);
			UI.destroy(flagIcon);
			tfAmount = null;
			tfAmountInCurrency = null;
			tfAmountInCurrency = null;
			tfNumber = null;
			flagIcon = null;
		}
		
		public function clearGraphics():void {
			graphics.clear();
		}
		
		public function getData():Object {
			return data;
		}
	}
}