package com.dukascopy.connect.gui.payments {
	
	import com.dukascopy.connect.Config;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class PayAccountSelector extends PaySelector {
		
		private var tfInteger:TextField;
		private var tfFraction:TextField;
		private var tfCurrency:TextField;
		private var _data:Object;
		
		public function PayAccountSelector() {
			super();
			
			defaultFormat.size = h * .40;
			defaultFormat.bold = true;
			tfInteger = new TextField();
			tfInteger.autoSize = TextFieldAutoSize.LEFT;
			tfInteger.defaultTextFormat = defaultFormat;
			tfInteger.text = "";
			tfInteger.multiline = false;
			tfInteger.wordWrap = false;
			
			defaultFormat.size = h * .28;
			tfFraction = new TextField();
			tfFraction.autoSize = TextFieldAutoSize.LEFT;
			tfFraction.defaultTextFormat = defaultFormat;
			tfFraction.text = "";
			tfFraction.multiline = false;
			tfFraction.wordWrap = false;
			
			defaultFormat.bold = false;
			tfCurrency = new TextField();
			tfCurrency.autoSize = TextFieldAutoSize.LEFT;
			tfCurrency.defaultTextFormat = defaultFormat;
			tfCurrency.text = "";
			tfCurrency.multiline = false;
			tfCurrency.wordWrap = false;
			
			addChild(tfInteger);
			addChild(tfFraction);
			addChild(tfCurrency);
		}
		
		override protected function positionateTFs():void {
			if (tfInteger.visible == false) {
				tfLabel.width = w - tfLabel.x - Config.DOUBLE_MARGIN;
				return;
			}
			tfCurrency.x = w - arrowCathetus * 2 - Config.DOUBLE_MARGIN * 2 - tfCurrency.width;
			tfCurrency.y = int((h - tfCurrency.height) * .5);
			tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
			tfFraction.y = int((h - tfFraction.height) * .5);
			tfInteger.x = tfFraction.x - tfInteger.width + 2;
			tfInteger.y = int((h - tfInteger.height) * .5) - 1;
			tfLabel.y = int((h - tfLabel.height) * .5);
			tfLabel.width = tfInteger.x - tfLabel.x - Config.DOUBLE_MARGIN;
		}
		
		override public function setData(data:Object = null):void {
			_data = data;
			if (data == null) {
				tfInteger.visible = false;
				tfFraction.visible = false;
				tfCurrency.visible = false;
				tfLabel.text = defaultText;
				positionateTFs();
				return;
			}
			var balance:String = data.BALANCE;
			tfInteger.visible = true;
			tfInteger.text = balance.substring(0, balance.indexOf("."));;
			tfFraction.visible = true;
			tfFraction.text = balance.substr(balance.length - 3);
			tfCurrency.visible = true;
			tfCurrency.text = data.CURRENCY;
			var accountNumber:String = data.ACCOUNT_NUMBER;
			tfLabel.text = accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8);
			positionateTFs();
		}
		
		override public function update():void {
			setData(_data);
		}
		
		override public function dispose():void {
			super.dispose();
			if (tfInteger != null)
				tfInteger.text = "";
			tfInteger = null;
			if (tfFraction != null)
				tfFraction.text = "";
			tfFraction = null;
			if (tfCurrency != null)
				tfCurrency.text = "";
			tfCurrency = null;
			_data = null;
		}
	}
}