package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey
	 */
	public class ListPayInvestmentDetail extends BaseRenderer implements IListRenderer {
		
		private var tfLabel:TextField;
		private var tfInteger:TextField;
		//private var tfFraction:TextField;
		//private var tfCurrency:TextField;
		private var tfDateTime:TextField;
		private var tfAmount:TextField;
		private var tfRate:TextField;
		
		private var sepHeight:int = Config.FINGER_SIZE * .05;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat("Tahoma", itemHeight * .28);
		
		private var iconSize:int = Config.FINGER_SIZE * .4; //Config.FINGER_SIZE - Config.DOUBLE_MARGIN;
		
		
		// Icons 
		private var iconAsset:DisplayObject;
		private var iconBuy:DisplayObject;
		private var iconSell:DisplayObject;
		private var iconSend:DisplayObject;

		
		private var iconBitmap:Bitmap;
		
		
		public function ListPayInvestmentDetail() {
			
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
			//tfInteger.y = Math.round((itemHeight - tfInteger.textHeight) * .5);
			tfInteger.y = Config.MARGIN + Config.FINGER_SIZE_DOT_25;// Math.round((itemHeight - tfInteger.textHeight) * .5);
				
			format.size = itemHeight * .28;
			//tfFraction = new TextField();
			//tfFraction.autoSize = TextFieldAutoSize.LEFT;
			//tfFraction.defaultTextFormat = format;
			//tfFraction.text = "Pp";
			//tfFraction.multiline = false;
			//tfFraction.wordWrap = false;
			//tfFraction.y = Math.round((itemHeight - tfFraction.textHeight) * .5);
			//
			//format.bold = false;
			//tfCurrency = new TextField();
			//tfCurrency.autoSize = TextFieldAutoSize.LEFT;
			//tfCurrency.defaultTextFormat = format;
			//tfCurrency.text = "Pp";
			//tfCurrency.multiline = false;
			//tfCurrency.wordWrap = false;
			//tfCurrency.y = Math.round((itemHeight - tfCurrency.textHeight) * .5);
			//
			format.size = itemHeight * .2;
			tfDateTime = new TextField();
			tfDateTime.textColor = 0x999999;
			tfDateTime.autoSize = TextFieldAutoSize.LEFT;
			tfDateTime.defaultTextFormat = format;
			tfDateTime.text = "Pp";
			tfDateTime.multiline = false;
			tfDateTime.wordWrap = false;
			tfDateTime.y = Config.MARGIN ;// * 0.2;
			
			tfAmount = new TextField();
			tfAmount.textColor = 0x999999;
			tfAmount.autoSize = TextFieldAutoSize.LEFT;
			tfAmount.defaultTextFormat = format;
			tfAmount.text = "Pp";
			tfAmount.multiline = false;
			tfAmount.wordWrap = false;
			tfAmount.y = int((itemHeight - tfAmount.height - tfLabel.height) * .5 + tfLabel.height);
			tfAmount.x = iconSize + Config.DOUBLE_MARGIN * 2; // Config.FINGER_SIZE + Config.DOUBLE_MARGIN;//
			
			tfRate = new TextField();
			tfRate.textColor = 0x999999;
			tfRate.autoSize = TextFieldAutoSize.LEFT;
			tfRate.defaultTextFormat = format;
			tfRate.text = "Pp";
			tfRate.multiline = false;
			tfRate.wordWrap = false;
			tfRate.y = int((itemHeight - tfAmount.height - tfLabel.height) * .5 + tfLabel.height) + tfAmount.height;
			tfRate.x = iconSize + Config.DOUBLE_MARGIN * 2; //Config.FINGER_SIZE + Config.DOUBLE_MARGIN;
			
			addChild(tfLabel);
			addChild(tfInteger);
			//addChild(tfFraction);
			//addChild(tfCurrency);
			addChild(tfDateTime);
			addChild(tfAmount);
			addChild(tfRate);
		}
		
		
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			
			if (data.data.itype == "investment")
				return itemHeight;
				
			if (data.data.itype == "description") {
				tfLabel.multiline = true;
				tfLabel.wordWrap = true;
				tfLabel.width = width - tfLabel.x - padding - iconSize;
				tfLabel.text = Lang.textDescription + ": " + ((data.data.description == null || data.data.description.length == 0) ? Lang.textEmpty : data.data.description);
				return tfLabel.textHeight + 4 + Config.MARGIN + sepHeight;
			}
			tfLabel.width = tfDateTime.x - tfLabel.x - padding;
			
			if (data.data.itype == "transaction") {
				return setTransactionTexts(data, width);
			}
			if (data.data.itype == "detail"){
				
			}
			return itemHeight;
		}
		
		

		
		
		
		
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var data:Object = li.data;
			UI.disposeBMD(iconBitmap.bitmapData);
			
			if (iconAsset != null){
				iconAsset.visible = false;
			}	
				
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfRate.text = "";
			graphics.clear();
			if (data == null)
				return this;
			
			if (highlight && li.data.itype == "transaction") {
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
			
			tfInteger.y = Config.MARGIN + Config.FINGER_SIZE_DOT_25;
			
			if (li.data.itype == "investment") { // INVESTMENT 
				
				tfInteger.visible = true;
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;				
				balance =  data.balance;
		
			
				// Format AMOUNT =============================
				var balanceColorString:String = "#77c043";
				if (balance.charAt(0) == "-") {
					balanceColorString = "#cd3f43";			
				}	
				var dotIndex:int = balance.indexOf(".");
				var leftNum:String = "";
				var rightNum:String = "";
				var stringAmount:String = "";
				if (dotIndex != -1){
					leftNum = balance.substring(0, dotIndex);
					if (leftNum == ""){
						leftNum = "0";
					}
					rightNum = balance.substring(dotIndex + 1, balance.length) + " " + CurrencyHelpers.getCurrencyByKey(li.data.currency);
					stringAmount = UI.getCurrencyTextHTML(leftNum + ".", rightNum, Config.FINGER_SIZE*.42, Config.FINGER_SIZE*.3,balanceColorString,balanceColorString);
				}else{	
					
					if(CurrencyHelpers.getMaxDecimalCount(li.data.currency)>0){
						leftNum = balance+".";
						rightNum = CurrencyHelpers.getZerosForCurrency(li.data.currency) +" "+ CurrencyHelpers.getCurrencyByKey(li.data.currency);
					}else{
						leftNum = balance;
						rightNum = " " +CurrencyHelpers.getCurrencyByKey(li.data.currency);
					}							
					stringAmount = UI.getCurrencyTextHTML(leftNum + "", rightNum, Config.FINGER_SIZE * .42, Config.FINGER_SIZE*.3, balanceColorString, balanceColorString);
				}
				// END Format Amount ========================
					
				//tfInteger.border = true;
				tfInteger.htmlText = stringAmount;
				tfInteger.x = width - Config.DOUBLE_MARGIN -  tfInteger.width;
				//tfInteger.x = padding;
				tfInteger.y = Math.round((itemHeight - tfInteger.textHeight) * .5);
		
			
				tfLabel.text =  data.title;
				tfLabel.width = width - tfLabel.x - padding;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
				
			} else if (li.data.itype == "detail") {  // DETAIL
				
				tfInteger.visible = true;
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				
				balance =  data.quantity;
				
				var balanceColorString1:String = "#77c043";
				if (balance.charAt(0) == "-") {
					balanceColorString1 = "#cd3f43";			
				}		
			
				// Format AMOUNT
				var dotIndex1:int = balance.indexOf(".");
				var leftNum1:String = "";
				var rightNum1:String = "";
				var stringAmount1:String = "";
				//trace("B:" + balance);
				if (dotIndex1 != -1){
					leftNum1 = balance.substring(0, dotIndex1);
					
					if (leftNum1 == ""){
						leftNum1 = "0";
					}
					rightNum1 = balance.substring(dotIndex1 + 1, balance.length) + " " + CurrencyHelpers.getCurrencyByKey(data.currency);
					stringAmount1 = UI.getCurrencyTextHTML(leftNum1 + ".", rightNum1, Config.FINGER_SIZE*.42, Config.FINGER_SIZE*.3,balanceColorString1,balanceColorString1);
				
					
				}else{				
								
					if(CurrencyHelpers.getMaxDecimalCount(data.currency) != 0){
						leftNum1 = balance+".";
						rightNum1 = CurrencyHelpers.getZerosForCurrency(data.currency) +" "+ CurrencyHelpers.getCurrencyByKey(data.currency);
					}else{
						leftNum1 = balance;
						rightNum1 = " " +CurrencyHelpers.getCurrencyByKey(data.currency);
					}		
					
					stringAmount1 = UI.getCurrencyTextHTML(leftNum1 + "", rightNum1, Config.FINGER_SIZE * .42, Config.FINGER_SIZE*.3, balanceColorString1, balanceColorString1);
				}
				
				

				
					
				tfInteger.htmlText = stringAmount1;
				tfInteger.x = width - Config.DOUBLE_MARGIN -  tfInteger.width;
				//tfInteger.x = padding;
				tfInteger.y = Math.round((itemHeight - tfInteger.textHeight) * .5);
		
			
				tfLabel.text = data.title;
				tfLabel.width = width - tfLabel.x - padding;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
				
			} else if (li.data.itype == "description") { // DESCRIPTION 
				tfInteger.visible = false;
				tfLabel.multiline = true;
				tfLabel.wordWrap = true;
				
				tfLabel.y = 0;
				tfLabel.text = Lang.textDescription + ": " + ((li.data.description == null || li.data.description.length == 0) ? Lang.textEmpty : li.data.description);
				tfLabel.width = width - tfLabel.x - padding - iconSize;
				
				iconBitmap.bitmapData = UI.getIconByFrame(17, iconSize, iconSize);
				iconBitmap.x = width - iconBitmap.width - padding;
				iconBitmap.y = 0;
				
				graphics.beginFill(0xEF4231);
				graphics.drawRect(0, h - sepHeight, width, sepHeight);
				graphics.endFill();
				
			} else if (li.data.itype == "title") {
				
				tfInteger.visible = false;
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				tfLabel.text = li.data.data;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
				
				graphics.beginFill(0xEF4231);
				graphics.drawRect(0, h - sepHeight, width, sepHeight);
				graphics.endFill();
				
			} else if (li.data.itype == "transaction") { // TRANSACTION
				setTransactionTexts(li, width);
				
				
				// Add Icon Asset
				var icon:DisplayObject = getAssetByType(data.type.toUpperCase());
				if (icon != null){
					if (iconAsset != null){
						iconAsset.visible = false;
					}			
					
					iconAsset = icon as DisplayObject;					
					iconAsset.visible  = true;
					UI.scaleToFit(iconAsset, iconSize, iconSize);
					addChild(iconAsset);
					iconAsset.x = padding;
					iconAsset.y = (h - iconAsset.height) * .5;
					
				}else{
					if (iconAsset != null){
						iconAsset.visible = false;
					}			
				}
				
				
				
				// Icon 			
				//var iconAsset:Sprite = UI.getIconByType(data.type.toUpperCase());
				//iconBitmap.bitmapData = UI.renderAsset(iconAsset, iconSize, iconSize, false, "ListPayInvestmentDetail.iconBitmap");
				//iconBitmap.x = padding;
				//iconBitmap.y = (h - iconBitmap.height) * .5;
				
				graphics.beginFill(0, .2);
				graphics.drawRect(0, h - 1, width, 1);
				graphics.endFill();
			}
			
			return this;
		}
		
		
		
		
		
		
		// Generate ICON 
		private function getAssetByType(type:String):DisplayObject {
			if (type == "SELL"){
				iconSell ||= new SWFSellInvestmentIcon();
				return iconSell;
			}
			if (type == "BUY"){
				iconBuy ||= new SWFBuyInvestmentIcon();
				return iconBuy;
			}
			
			if(type == "TRANSFER"){
				iconSend ||= new SWFSendInvestmentIcon();
				return iconSend;
			}
			
			return null;
		
		}
		
		
		
		// Draw Transaction 
		private function setTransactionTexts(li:ListItem, w:int):int {
			tfInteger.visible = true;
			//tfFraction.visible = true;
			//tfCurrency.visible = true;
			tfDateTime.visible = true;
			tfAmount.visible = true;
			tfLabel.multiline = true;
			tfLabel.wordWrap = true;
			
			tfLabel.text = li.data.type;
			
			var prevY:int = 0;
			
			var instrumentString:String = li.data.instrument;
			var currencyString:String = li.data.currency;
			var profitString:String = li.data.pl;
			var priceString:String = li.data.price;
			var quantityString:String = li.data.quantity;
			var referenceUIDString:String = li.data.uid;
			
			var balance:String =  li.data.quantity;
			
			var type:String = li.data.type.toUpperCase();
			var overallDescriptionString:String = "";
			
			
			// format price
			priceString = Number(priceString).toFixed(CurrencyHelpers.getMaxDecimalCount(currencyString))+"";
			
			//color of currency 
			var balanceColor:uint = /*type == "INTERNAL TRANSFER" ? AppTheme.GREY_MEDIUM : */AppTheme.GREEN_MEDIUM;
			var balanceColorString:String = "#77c043";
			if (balance.charAt(0) == "-") {
				balanceColorString = "#cd3f43";
				balanceColor = AppTheme.RED_MEDIUM;
			}		
			tfInteger.textColor = balanceColor;
			
			
			// Format AMOUNT
			var dotIndex:int = balance.indexOf(".");
			var leftNum:String = "";
			var rightNum:String = "";
			var stringAmount:String = "";
			if (dotIndex != -1){
				leftNum = balance.substring(0, dotIndex);
				if (leftNum == ""){
					leftNum = "0";
				}
				
				rightNum = balance.substring(dotIndex+1, balance.length) + " "+CurrencyHelpers.getCurrencyByKey(instrumentString);// li.data.CURRENCY;
				stringAmount = UI.getCurrencyTextHTML(leftNum + ".", rightNum, Config.FINGER_SIZE*.36, Config.FINGER_SIZE*.26,balanceColorString,balanceColorString);
			}else{				
				//leftNum = balance+".";
				//rightNum = "00 " + CurrencyHelpers.getCurrencyByKey(instrumentString); // count of number depending on currency 
				//stringAmount = UI.getCurrencyTextHTML(leftNum + " ", rightNum, Config.FINGER_SIZE * .36, Config.FINGER_SIZE*.28, balanceColorString, balanceColorString);
				if(CurrencyHelpers.getMaxDecimalCount(li.data.currency)>0){
					leftNum = balance+".";
					rightNum = CurrencyHelpers.getZerosForCurrency(li.data.currency) +" "+ CurrencyHelpers.getCurrencyByKey(li.data.currency);
				}else{
					leftNum = balance;
					rightNum = " " +CurrencyHelpers.getCurrencyByKey(li.data.currency);
				}	
				stringAmount = UI.getCurrencyTextHTML(leftNum + " ", rightNum, Config.FINGER_SIZE * .42, Config.FINGER_SIZE * .3, balanceColorString, balanceColorString);
			}
			
			
								
					
			tfInteger.htmlText = stringAmount;
					
			
			//tfCurrency.x = w - Config.DOUBLE_MARGIN - tfCurrency.width;
			//tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
			//tfInteger.x = tfFraction.x - tfInteger.width + 2;
			tfInteger.x = w - Config.DOUBLE_MARGIN -  tfInteger.width ;			
			tfDateTime.text = createDateString(li.data.ts * 1000);
			tfDateTime.x = w - Config.DOUBLE_MARGIN - tfDateTime.width;
			
			
			
			
			if (profitString != ""){				
				if (profitString.indexOf("-") != -1){
					overallDescriptionString = "Loss: " +profitString +" "+ currencyString +"\n";		
				}else{
					overallDescriptionString = "Profit: " +profitString +" "+ currencyString +"\n";
				}	
			}
			
			overallDescriptionString += "Price: " + priceString +" "+ currencyString +"\n";
			overallDescriptionString += "Reference: " + referenceUIDString ;
					
			tfAmount.text = overallDescriptionString;
			
			
			// UID 
			var rateDetails:String = li.data.uid;
			if (rateDetails != "") {
				tfRate.text = "";// rateDetails;
			} else {
				tfRate.text = "";
			}
		
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.x = iconSize + Config.DOUBLE_MARGIN * 2;
			//tfLabel.y = tfInteger.y + tfInteger.getLineMetrics(0).ascent - tfLabel.getLineMetrics(0).ascent;
			tfLabel.y = Config.MARGIN;
			var trueX:int = (tfDateTime.x < tfInteger.x) ? tfDateTime.x : tfInteger.x;
			tfLabel.width = trueX - tfLabel.x - padding;
			tfAmount.y = int(tfLabel.y + tfLabel.height + Config.FINGER_SIZE * .05);
			tfRate.y = tfAmount.y + tfAmount.height;
			tfRate.width = w - tfRate.x - padding;
			
			
			prevY =  tfAmount.y + tfAmount.height + Config.DOUBLE_MARGIN;
			
			//tfInteger.y = Math.round((prevY - tfInteger.textHeight) * .5);
			return prevY ;
			
			
			//if (tfRate.text == "")
				//return tfLabel.y * 2 + tfLabel.height;
			//else
				//return tfRate.y + tfRate.height + Config.MARGIN;
		}
		
		
		
		
		
		private function createDateString(val:Number):String {
			var date:Date = new Date();
			date.setTime(val);
			return ((date.getDate() < 10) ? "0" : "") + date.getDate() + "/" + ((date.getMonth() + 1 < 10) ? "0" : "") + (date.getMonth() + 1) + "/" + date.getFullYear() + " " + ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":" + ((date.getMinutes() < 10) ? "0" : "") + date.getMinutes() + ":" + ((date.getSeconds() < 10) ? "0" : "") + date.getSeconds();
		}
		
		
		
		// 
		public function dispose():void {
			UI.destroy(iconAsset);
			iconAsset = null;
			
			UI.destroy(iconSell);
			iconSell = null;
			
			UI.destroy(iconBuy);
			iconBuy  = null;
			
			UI.destroy(iconSend);
			iconSend = null;
			
			graphics.clear();
			
			UI.destroy(iconBitmap);
			iconBitmap = null;
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			if (tfInteger != null)
				tfInteger.text = "";
			tfInteger = null;
			
			if (tfDateTime != null)
				tfDateTime.text = "";
			tfDateTime = null;
			if (tfAmount != null)
				tfAmount.text = "";
			tfAmount = null;
			if (tfRate != null)
				tfRate.text = "";
			tfRate = null;
			format = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}