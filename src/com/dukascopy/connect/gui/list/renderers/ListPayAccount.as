package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListPayAccount extends Sprite implements IListRenderer{
		
		private var tfLabel:TextField;
		private var tfInteger:TextField;
		private var tfFraction:TextField;
		private var tfCurrency:TextField;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat=new TextFormat("Tahoma", itemHeight * .28);
		
		public function ListPayAccount() {
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = padding;
			tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
			
			format.size = itemHeight * .40;
			format.bold = true;
			tfInteger = new TextField();
			tfInteger.autoSize = TextFieldAutoSize.LEFT;
			tfInteger.defaultTextFormat = format;
			tfInteger.text = "Pp";
			tfInteger.multiline = false;
			tfInteger.wordWrap = false;
			tfInteger.y = Math.round((itemHeight - tfInteger.textHeight) * .5);
			
			format.size = itemHeight * .28;
			tfFraction = new TextField();
			tfFraction.autoSize = TextFieldAutoSize.LEFT;
			tfFraction.defaultTextFormat = format;
			tfFraction.text = "Pp";
			tfFraction.multiline = false;
			tfFraction.wordWrap = false;
			tfFraction.y = Math.round((itemHeight - tfFraction.textHeight) * .5);
			
			format.bold = false;
			tfCurrency = new TextField();
			tfCurrency.autoSize = TextFieldAutoSize.LEFT;
			tfCurrency.defaultTextFormat = format;
			tfCurrency.text = "Pp";
			tfCurrency.multiline = false;
			tfCurrency.wordWrap = false;
			tfCurrency.y = Math.round((itemHeight - tfCurrency.textHeight) * .5);
			
			addChild(tfLabel);
			addChild(tfInteger);
			addChild(tfFraction);
			addChild(tfCurrency);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = li.data;
			
			graphics.clear();
			if (highlight) {
				graphics.beginFill(AppTheme.RED_MEDIUM);
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
				tfLabel.textColor = 0xFFFFFF;
			} else {
				tfLabel.textColor = 0;
			}
			
			var balance:String = data.BALANCE;
			tfInteger.text = balance.substring(0, balance.indexOf("."));
			tfFraction.text = balance.substr(balance.length - 3);
			tfCurrency.text = data.CURRENCY;
			
			tfCurrency.x = width - Config.DOUBLE_MARGIN - tfCurrency.width;
			tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
			tfInteger.x = tfFraction.x - tfInteger.width + 2;
			
			graphics.beginFill(0, .2);
			graphics.drawRect(0, h - 1, width, 1);
			graphics.endFill();
			var accountNumber:String = data.ACCOUNT_NUMBER;
			if (width < 380) {
				tfLabel.text = accountNumber.substr(0, 4) + "..." + accountNumber.substr(8);
			}else {
				tfLabel.text = accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8);
			}
			
			tfLabel.width = width - tfLabel.x - padding;
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			if (tfInteger != null)
				tfInteger.text = "";
			tfInteger = null;
			if (tfFraction != null)
				tfFraction.text = "";
			tfFraction = null;
			if (tfCurrency != null)
				tfCurrency.text = "";
			tfCurrency = null;
			format = null
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}