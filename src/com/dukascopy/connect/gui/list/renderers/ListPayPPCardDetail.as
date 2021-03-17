package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
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
	public class ListPayPPCardDetail extends BaseRenderer implements IListRenderer {
		
		private var _isDisposed:Boolean = false;
		private var tfLabel:TextField;
		private var tfInteger:TextField;
		private var tfFraction:TextField;
		private var tfCurrency:TextField;
		
		private var tfInteger2:TextField;
		private var tfFraction2:TextField;
		private var tfCurrency2:TextField;
		
		private var tfDateTime:TextField;
		private var tfAmount:TextField;
		
		private var sepHeight:int = Config.FINGER_SIZE * .05;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat("Tahoma", itemHeight * .28);
		
		private var iconSize:int = Config.FINGER_SIZE * .4;// Config.FINGER_SIZE - Config.DOUBLE_MARGIN;
		
		private var iconBitmap:Bitmap;
		
		
		
		public function ListPayPPCardDetail() {
			
			iconBitmap = new Bitmap();
			addChild(iconBitmap);
			
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
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
			
			//format.bold = true;
			tfInteger2 = new TextField();
			tfInteger2.autoSize = TextFieldAutoSize.LEFT;
			tfInteger2.defaultTextFormat = format;
			tfInteger2.border = false;
			tfInteger2.text = "Pp";
			tfInteger2.multiline = false;
			tfInteger2.wordWrap = false;
			tfInteger2.y = Math.round((itemHeight - tfInteger2.textHeight) * .5);
			
			format.size = itemHeight * .28;
			tfFraction = new TextField();
			tfFraction.autoSize = TextFieldAutoSize.LEFT;
			tfFraction.defaultTextFormat = format;
			tfFraction.text = "Pp";
			tfFraction.multiline = false;
			tfFraction.wordWrap = false;
			tfFraction.y = Math.round((itemHeight - tfFraction.textHeight) * .5);
			
			tfFraction2 = new TextField();
			tfFraction2.autoSize = TextFieldAutoSize.LEFT;
			tfFraction2.defaultTextFormat = format;
			tfFraction2.text = "Pp";
			tfFraction2.multiline = false;
			tfFraction2.wordWrap = false;
			tfFraction2.y = Math.round((itemHeight - tfFraction2.textHeight) * .5);
			
			format.bold = false;
			tfCurrency = new TextField();
			tfCurrency.autoSize = TextFieldAutoSize.LEFT;
			tfCurrency.defaultTextFormat = format;
			tfCurrency.text = "Pp";
			tfCurrency.multiline = false;
			tfCurrency.wordWrap = false;
			tfCurrency.y = Math.round((itemHeight - tfCurrency.textHeight) * .5);
			
			
			tfCurrency2 = new TextField();
			tfCurrency2.autoSize = TextFieldAutoSize.LEFT;
			tfCurrency2.defaultTextFormat = format;
			tfCurrency2.text = "Pp";
			tfCurrency2.multiline = false;
			tfCurrency2.wordWrap = false;
			tfCurrency2.y = Math.round((itemHeight - tfCurrency2.textHeight) * .5);
			
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
			tfAmount.border = false;
			tfAmount.multiline = true;
			tfAmount.wordWrap = true;
			tfAmount.y = int((itemHeight - tfAmount.height - tfLabel.height) * .5 + tfLabel.height);
			tfAmount.x = Config.FINGER_SIZE + Config.DOUBLE_MARGIN;
			
			addChild(tfLabel);
			addChild(tfInteger);
			addChild(tfFraction);
			addChild(tfCurrency);
			
			addChild(tfInteger2);
			addChild(tfFraction2);
			addChild(tfCurrency2);
			
			addChild(tfDateTime);
			addChild(tfAmount);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			if (data.data.itype == "wallet")
				return itemHeight;
			if (data.data.itype == "description") {
				tfLabel.multiline = true;
				tfLabel.wordWrap = true;
				tfLabel.width = width - tfLabel.x - padding;
				tfLabel.text = Lang.textDescription + ": " + ((data.data.description == null || data.data.description.length == 0) ? Lang.textEmpty : data.data.description);
				return tfLabel.textHeight + 4 + Config.MARGIN + sepHeight;
			}
			if (data.data.itype == "transaction")
				return setTransactionTexts(data, width);
			
			// add check for 
			if (data.data.comment != null) {
				var fullDescription:String = "" +data.data.comment;
				//tfAmount.width = width - tfAmount.x - padding*2;
				tfAmount.text = fullDescription;
				return itemHeight +tfAmount.height;
			}
			
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var data:Object = li.data;
			
			graphics.clear();
			UI.disposeBMD(iconBitmap.bitmapData);
			
			if (highlight && li.data.itype=="transaction") {
				graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
				tfLabel.textColor = AppTheme.GREY_DARK;
			} else {
				tfLabel.textColor = AppTheme.GREY_DARK;
			}		
			tfLabel.x = padding;
			var balance:String;
			tfDateTime.visible = false;
			tfAmount.visible = false;
			if (li.data.itype == "wallet") {
				tfInteger.visible = true;
				tfFraction.visible = true;
				tfCurrency.visible = true;
				
				tfInteger2.visible = false;
				tfFraction2.visible = false;
				tfCurrency2.visible = false;
				
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
				
				tfInteger2.visible = false;
				tfFraction2.visible = false;
				tfCurrency2.visible = false;
				
				tfLabel.multiline = true;
				tfLabel.wordWrap = true;
				
				tfLabel.y = 0;
				tfLabel.text = Lang.textDescription + ": " + ((li.data.description == null || li.data.description.length == 0) ? Lang.textEmpty : li.data.description);
				tfLabel.width = width - tfLabel.x - padding;
				
				graphics.beginFill(0xEF4231);
				graphics.drawRect(0, h - sepHeight, width, sepHeight);
				graphics.endFill();
			} else if (li.data.itype == "title") {
				tfInteger.visible = false;
				tfFraction.visible = false;
				tfCurrency.visible = false;
				tfInteger2.visible = false;
				tfFraction2.visible = false;
				tfCurrency2.visible = false;
				
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
				
				tfLabel.text = li.data.data;
			} else if (li.data.itype == "transaction") {
				var itemH:int = setTransactionTexts(li, width);
				
				var type:String = data.type!=null?data.type.toUpperCase():data.itype.toUpperCase(); // tut type netu 
				
				// Icon 			
				var iconAsset:Sprite =  UI.getIconByType(type);			
				iconBitmap.bitmapData = UI.renderAsset(iconAsset, iconSize, iconSize, false);
				iconBitmap.x = padding;
				iconBitmap.y = (itemH - iconBitmap.height) * .5;
			}
			
			return this;
		}
		
		private function setTransactionTexts(li:ListItem, w:int):int {
			tfInteger.visible = true;
			tfFraction.visible = true;
			tfCurrency.visible = true;
			tfDateTime.visible = true;			
			tfAmount.visible = true;
			tfLabel.multiline = true;
			tfLabel.wordWrap = true;
			
			var type:String = "";
			var balance:String = "";			
			var currency:String = "";
			
			var transaction_balance:String = "";
			var transaction_currency:String = "";
			
			var comment:String  = "";
			var timestamp:Number  = 0;
			var isHolds:Boolean = false;
			
			if ("itype" in li.data && li.data.type==null ){// eto holds
				type = li.data.itype;
				balance = li.data.original_amount;
				currency =  li.data.original_currency;
				transaction_balance = li.data.transaction_amount;
				transaction_currency =  li.data.transaction_currency;
				
				comment = li.data.comment;
				timestamp = li.data.timestamp;
				isHolds = true;
				
			}else{   // eto tranzakciji vnutrennie
				type = li.data.type;
				balance = li.data.amount;	
				currency = li.data.currency;
				comment = li.data.comment;
				timestamp = li.data.timestamp;			
			}
			
			tfInteger2.visible = isHolds;
			tfFraction2.visible = isHolds;
			tfCurrency2.visible = isHolds;
			
			
			
			tfLabel.text = type;
			//var balance:String = li.data.amount;			
			//var type:String = li.data.type.toUpperCase();		
			
			//color of currency 
			var balanceColor:uint = type.toUpperCase() == "DEBIT" ? AppTheme.RED_MEDIUM : AppTheme.GREEN_MEDIUM;
			tfInteger.textColor = tfFraction.textColor = tfCurrency.textColor = balanceColor;
			
			tfInteger.text = balance.substring(0, balance.indexOf("."));
			tfFraction.text = balance.substr(balance.length - 3);
			tfCurrency.text = currency;// li.data.currency;
			
			tfCurrency.x = w - Config.DOUBLE_MARGIN - tfCurrency.width;
			tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
			tfInteger.x = tfFraction.x - tfInteger.width + 2;
			var aditionalHeight:int = 0;
			
			if (isHolds){
				balanceColor = type.toUpperCase() == "DEBIT" ? AppTheme.RED_MEDIUM : AppTheme.GREEN_MEDIUM;
				tfInteger2.textColor = tfFraction2.textColor = tfCurrency2.textColor = balanceColor;
			
				tfInteger2.text = transaction_balance.substring(0, transaction_balance.indexOf("."));
				tfFraction2.text = transaction_balance.substr(transaction_balance.length - 3);
				tfCurrency2.text = transaction_currency;
				tfCurrency2.x = w - Config.DOUBLE_MARGIN - tfCurrency2.width;
				tfFraction2.x = tfCurrency2.x - Config.MARGIN - tfFraction2.width;
				tfInteger2.x = tfFraction2.x - tfInteger2.width + 2; 			
				
				tfInteger2.y = Math.round(tfInteger.y + tfInteger.height);
				tfFraction2.y = Math.round(tfInteger2.y + tfInteger2.height*.5 - tfFraction2.height*.5);
				tfCurrency2.y = Math.round(tfInteger2.y + tfInteger2.height*.5 - tfCurrency2.height*.5);				
				tfAmount.width = tfInteger2.x - padding - (iconSize + Config.DOUBLE_MARGIN * 2);
				
				aditionalHeight = Config.FINGER_SIZE * .5;
				
			}else{
				tfAmount.width = w - tfAmount.x - padding;
			}
			
			tfDateTime.text = createDateString(timestamp * 1000);
			tfDateTime.x = w - Config.DOUBLE_MARGIN - tfDateTime.width;
			
			var fullDescription:String = comment;// li.data.comment;
			tfAmount.text = fullDescription;
			
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.x = tfAmount.x = iconSize + Config.DOUBLE_MARGIN * 2;
			tfLabel.y = tfInteger.y + tfInteger.getLineMetrics(0).ascent - tfLabel.getLineMetrics(0).ascent;
			var trueX:int = (tfDateTime.x < tfInteger.x) ? tfDateTime.x : tfInteger.x;
			tfLabel.width = trueX - tfLabel.x - padding;
			tfAmount.y = int(tfLabel.y + tfLabel.height + Config.FINGER_SIZE * .05);
			//tfAmount.width = w - tfAmount.x - padding;
						
			
			if (tfAmount.text == "")
				return tfLabel.y * 2 + tfLabel.height + aditionalHeight;
			else
				return tfAmount.y + tfAmount.height + Config.MARGIN+aditionalHeight;
		}
		
		private function createDateString(val:Number):String {
			var date:Date = new Date();
			date.setTime(val);
			return ((date.getDate() < 10) ? "0" : "") + date.getDate() + "/" + ((date.getMonth() + 1 < 10) ? "0" : "") + (date.getMonth() + 1) + "/"  + date.getFullYear() + " " + ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":" + ((date.getMinutes() < 10) ? "0" : "") + date.getMinutes() + ":" + ((date.getSeconds() < 10) ? "0" : "") + date.getSeconds();
		}
		
		public function dispose():void {
			if (_isDisposed) return;
			_isDisposed = true;
			graphics.clear();
			
			UI.destroy(iconBitmap);
			iconBitmap = null;
			
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
			if (tfInteger2 != null)
				tfInteger2.text = "";
			tfInteger2 = null;
			if (tfFraction2 != null)
				tfFraction2.text = "";
			tfFraction2 = null;
			if (tfCurrency2 != null)
				tfCurrency2.text = "";
			tfCurrency2 = null;
			if (tfDateTime != null)
				tfDateTime.text = "";
			tfDateTime = null;
			if (tfAmount != null)
				tfAmount.text = "";
			tfAmount = null;
			format = null;
			
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {	return true;	}
	}
}