package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BACardSection;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
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
	
	public class ListPayCard extends BaseRenderer implements IListRenderer{
		
		private var tfLabel:TextField;
		private var tfStatus:TextField;
		protected var tfInteger:TextField;
		protected var tfFraction:TextField;
		protected var tfCurrency:TextField;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat("Tahoma", itemHeight * .28);
		
		private var tfLabelY0:int;
		private var tfLabelY1:int;
		
		public function ListPayCard() {
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = padding;
			tfLabelY0 = Math.round((itemHeight - tfLabel.textHeight) * .5);
			
			format.size = itemHeight * .24;
			format.italic = true;
			tfStatus = new TextField();
			tfStatus.autoSize = TextFieldAutoSize.LEFT;
			tfStatus.defaultTextFormat = format;
			tfStatus.text = "Pp";
			tfStatus.multiline = false;
			tfStatus.wordWrap = false;
			tfStatus.x = padding;
			tfStatus.textColor = 0x999999;
			
			tfLabelY1 = Math.round((itemHeight - (tfLabel.textHeight + tfStatus.textHeight + 8)) * .5);
			tfStatus.y = int(tfLabelY1 + tfLabel.textHeight + 4);
			
			format.size = itemHeight * .40;
			format.bold = true;
			format.italic = false;
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
			addChild(tfStatus);
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
				graphics.beginFill(AppTheme.RED_MEDIUM/*0xEE4131*/);
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
				tfLabel.textColor = 0xFFFFFF;
			} else {
				tfLabel.textColor = 0;
			}
			
			graphics.beginFill(0, .2);
			graphics.drawRect(0, h - 1, width, 1);
			graphics.endFill();
			
			tfInteger.visible = true;
			tfFraction.visible = true;
			tfCurrency.visible = true;
			tfStatus.visible = true;
			
			
			if (data.number == 0) {
				tfLabel.text = Lang.issueNewPrepaidCard;//"Issue New Prepaid Card";
				tfInteger.visible = false;
				tfFraction.visible = false;
				tfCurrency.visible = false;
				tfStatus.visible = false;
				tfLabel.y = tfLabelY0;
				return this;
			}
			tfLabel.y = tfLabelY1;
			
			var balance:String = data.available || "";
			var dotIndex:int = balance.indexOf(".");
			var balanceLeft:String = "";
			var balanceRight:String = "";
			if(dotIndex!=-1){
				var rightPartLength:int  = balance.length - dotIndex;
				 balanceLeft = balance.substring(0, dotIndex);
				 balanceRight = balance.substr(dotIndex, rightPartLength);
			}else{
				balanceLeft = balance==""?"0":balance;
				balanceRight = ".00";
			}
			
			tfInteger.text = balanceLeft;			
			tfFraction.text = balanceRight;
			
			
			var isLinked:Boolean;
			if("currency" in data){
				isLinked = false;
				tfCurrency.text = data.currency || "";
			}else{
				tfCurrency.text = "";//ListPayMyCard.as
			}
			//tfInteger.border = true;
			
			tfCurrency.x = width - Config.DOUBLE_MARGIN - tfCurrency.width;
			tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
			tfInteger.x = tfFraction.x - tfInteger.width + 2;
			
			var accountNumber:String = data.masked !=null? data.masked:data.number ;// number;
			var fullAccountNumber:String  = accountNumber;
			var shortAccountNumber:String = accountNumber;
			
			if(accountNumber.length>=16){
				var first:String = accountNumber.substr(0, 4);
				var second:String = accountNumber.substr(4, 4);
				var third:String = accountNumber.substr(8, 4);
				var fourth:String = accountNumber.substr(12, 4);
				fullAccountNumber  =  first +" " + second + " " + third + " " + fourth;
				shortAccountNumber = ".... " + fourth;
			}
			
			tfLabel.text = isLinked ? fullAccountNumber :shortAccountNumber;
			
			// Proverka zalazit li summa 
			if (tfInteger.x < tfLabel.x + tfLabel.width) {
				//tfInteger.border = true;
				tfInteger.visible = false;
				tfFraction.visible = false;
				
				// Proverka zalazit li valjuta
				if(tfCurrency.x<tfLabel.x + tfLabel.width){
					tfCurrency.y =  Math.round((itemHeight - (tfCurrency.textHeight + 8)));
				}else {
					tfCurrency.y = Math.round((itemHeight - tfCurrency.textHeight) * .5);
				}		
				
			}else {
				//tfInteger.border = false;
				tfInteger.visible = true;
				tfFraction.visible = true;
				tfCurrency.y = Math.round((itemHeight - tfCurrency.textHeight) * .5);
			}
			
			
			//if (tfLabel.x + tfLabel.textWidth + 4 + Config.MARGIN >= tfInteger.x)
			//{
				//tfLabel.text = shortAccountNumber;
			//}			
			//tfLabel.border = true;		
			
			/*if (width < 470) { // calculate by fingersize not by size 
				tfLabel.text = shortAccountNumber;
			}else {
				tfLabel.text = fullAccountNumber;
			}*/
			
			//var isShorten:Boolean = width < 400;		
			//var labelText:String = isShorten? "**** **** " + accountNumber.substr(12):accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8, 4) + " " + accountNumber.substr(12);
			//tfLabel.text = labelText;// accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8, 4) + " " + accountNumber.substr(12);
			tfLabel.width = width - tfLabel.x - padding;
			if("type" in data){
				tfStatus.text = data.status_name + " " + data.type.toLowerCase() + "   ";
			}else{
				tfStatus.text = data.status_name + "   ";
			}
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