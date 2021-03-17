package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListPayHistoryDetail extends Sprite implements IListRenderer {
		
		private var tfLabel:TextField;
		private var tfInteger:TextField;
		private var tfFraction:TextField;
		private var tfCurrency:TextField;
		private var tfDateTime:TextField;
		private var tfAmount:TextField;
		
		private var sepHeight:int = Config.FINGER_SIZE * .05;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat("Tahoma", itemHeight * .28);
		
		private var iconSize:int = Config.FINGER_SIZE - Config.DOUBLE_MARGIN;
		
		public function ListPayHistoryDetail() {
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.NONE;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.border = false;
			tfLabel.x = padding;
			tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
			
			format.size = itemHeight * .40;
			//format.bold = true;
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
			
			format.size = itemHeight * .2;
			tfDateTime = new TextField();
			tfDateTime.textColor = 0x999999;
			tfDateTime.autoSize = TextFieldAutoSize.LEFT;
			tfDateTime.defaultTextFormat = format;
			tfDateTime.text = "Pp";
			tfDateTime.multiline = false;
			tfDateTime.wordWrap = false;
			tfDateTime.y = Config.MARGIN * 0.2;
			
			tfAmount = new TextField();
			tfAmount.textColor = 0x999999;
			tfAmount.autoSize = TextFieldAutoSize.LEFT;
			tfAmount.defaultTextFormat = format;
			tfAmount.text = "Pp";
			tfAmount.multiline = false;
			tfAmount.wordWrap = false;
			tfAmount.y = int((itemHeight - tfAmount.height - tfLabel.height) * .5 + tfLabel.height);
			tfAmount.x = Config.FINGER_SIZE + Config.DOUBLE_MARGIN;
			
			addChild(tfLabel);
			addChild(tfInteger);
			addChild(tfFraction);
			addChild(tfCurrency);
			addChild(tfDateTime);
			addChild(tfAmount);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			if (data.data.itype == "operation")
				return itemHeight;
			if (data.data.itype == "description") {
				tfLabel.multiline = true;
				tfLabel.wordWrap = true;
				tfLabel.width = width - tfLabel.x - padding;
				var key:String = (data.data.key == null || data.data.key.length == 0) ? "Empty" : data.data.key;
				var description:String = ((data.data.description == null || data.data.description.length == 0) ? "Empty" : data.data.description);
				tfLabel.text = key + description;
				return tfLabel.textHeight + 4 + Config.MARGIN + sepHeight;
			}
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
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
			tfLabel.x = padding;
			var balance:String;
			tfDateTime.visible = false;
			tfAmount.visible = false;
			if (li.data.itype == "operation") {
				tfInteger.visible = true;
				tfFraction.visible = true;
				tfCurrency.visible = true;
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
				
				balance = data.balance;
				tfInteger.text = balance.substring(0, balance.indexOf("."));
				tfFraction.text = balance.substr(balance.length - 3);
				tfCurrency.text = data.currency;
				
				tfCurrency.x = width - Config.DOUBLE_MARGIN - tfCurrency.width;
				tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
				tfInteger.x = tfFraction.x - tfInteger.width + 2;
				
				var accountNumber:String = data.walletID;
				tfLabel.text = "Nr.: " + accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8);
				tfLabel.width = width - tfLabel.x - padding;
			} else if (li.data.itype == "description") {
				tfInteger.visible = false;
				tfFraction.visible = false;
				tfCurrency.visible = false;
				tfLabel.multiline = true;
				tfLabel.wordWrap = true;
				
				tfLabel.y = 0;
				var key:String = (li.data.key == null || li.data.key.length == 0) ? "Empty" : li.data.key;
				var description:String = ((li.data.description == null || li.data.description.length == 0) ? "No information" : li.data.description);
				tfLabel.text = key + description;				
				tfLabel.width = width - tfLabel.x - padding;
				
				if(data.isLast!=null && data.isLast==true){
					graphics.beginFill(0xEF4231);
					graphics.drawRect(0, h - sepHeight, width, sepHeight);
					graphics.endFill();
				}
				
			} else if (li.data.itype == "title") {
				tfInteger.visible = false;
				tfFraction.visible = false;
				tfCurrency.visible = false;
				
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
				
				tfLabel.text = li.data.data;
			} else if (li.data.itype == "transaction") {
				tfInteger.visible = true;
				tfFraction.visible = true;
				tfCurrency.visible = true;
				tfDateTime.visible = true;
				tfAmount.visible = true;
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				tfLabel.y = tfAmount.y - tfLabel.height;
				tfLabel.x = Config.FINGER_SIZE + Config.DOUBLE_MARGIN;
				
				tfLabel.text = li.data.TYPE;
				
				balance = data.BALANCE;
				tfInteger.text = balance.substring(0, balance.indexOf("."));
				tfFraction.text = balance.substr(balance.length - 3);
				tfCurrency.text = data.CURRENCY;
				
				tfCurrency.x = width - Config.DOUBLE_MARGIN - tfCurrency.width;
				tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
				tfInteger.x = tfFraction.x - tfInteger.width + 2;
				
				tfDateTime.text = createDateString(data.TS * 1000);
				tfDateTime.x = width - Config.DOUBLE_MARGIN - tfDateTime.width;
				
				if (li.data.ORIG_AMOUNT == "") {
					tfAmount.text = li.data.AMOUNT + " " + li.data.CURRENCY;
				} else {
					tfAmount.text = ((li.data.ORIG_AMOUNT.charAt(0) != "-" && li.data.AMOUNT.charAt(0) == "-") ? "-" : "") + li.data.ORIG_AMOUNT + " " + li.data.ORIG_CURRENCY + " → " + li.data.AMOUNT + " " + li.data.CURRENCY;
				}
				
				var type:String = data.TYPE.toUpperCase();
				var ibmd:ImageBitmapData;
				if (type == "DEPOSIT") {
					ibmd = Assets.getAsset(Assets.PAYMENT_ICON_DEPOSIT_FUNDS);
				} else if (type == "INTERNAL TRANSFER") {
					ibmd = Assets.getAsset(Assets.PAYMENT_ICON_TRANSFER);
				} else if (type == "WITHDRAWAL") {
					ibmd = Assets.getAsset(Assets.PAYMENT_ICON_WITHDRAWAL);
				} else if (type == "OUTGOING TRANSFER") {
					ibmd = Assets.getAsset(Assets.PAYMENT_ICON_OUTGOING_TRANSFER);
				} else if (type == "INCOMING TRANSFER") {
					ibmd = Assets.getAsset(Assets.PAYMENT_ICON_INCOMING_TRANSFER);
				} else if (type == "TRANSFER FEE") {
					ibmd = Assets.getAsset(Assets.PAYMENT_ICON_FEE);
				}else {
					ibmd = Assets.getAsset(Assets.PAYMENT_ICON_CREDIT);
				}
				ImageManager.drawGraphicImage(graphics, Config.DOUBLE_MARGIN, Config.MARGIN, iconSize, iconSize, ibmd);
				
				graphics.beginFill(0, .2);
				graphics.drawRect(0, h - 1, width, 1);
				graphics.endFill();
			}
			
			return this;
		}
		
		private function createDateString(val:Number):String {
			var date:Date = new Date();
			date.setTime(val);
			return ((date.getDate() < 10) ? "0" : "") + date.getDate() + "/" + ((date.getMonth() + 1 < 10) ? "0" : "") + (date.getMonth() + 1) + "/"  + date.getFullYear() + " " + ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":" + ((date.getMinutes() < 10) ? "0" : "") + date.getMinutes() + ":" + ((date.getSeconds() < 10) ? "0" : "") + date.getSeconds();
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
			if (tfDateTime != null)
				tfDateTime.text = "";
			tfDateTime = null;
			if (tfAmount != null)
				tfAmount.text = "";
			tfAmount = null;
			format = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}