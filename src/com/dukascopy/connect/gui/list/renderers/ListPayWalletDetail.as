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
	public class ListPayWalletDetail extends BaseRenderer implements IListRenderer {
		
		private var tfLabel:TextField;
		private var tfInteger:TextField;
		private var tfFraction:TextField;
		private var tfCurrency:TextField;
		private var tfDateTime:TextField;
		private var tfAmount:TextField;
		private var tfRate:TextField;
		
		private var sepHeight:int = Config.FINGER_SIZE * .05;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat("Tahoma", itemHeight * .28);
		
		private var iconSize:int = Config.FINGER_SIZE * .4; //Config.FINGER_SIZE - Config.DOUBLE_MARGIN;
		
		// icons
		//private static var depositIcon:Sprite;
		//private static var internalTransferIcon:Sprite;
		//private static var incommingTransferIcon:Sprite;
		//private static var outgoingTransferIcon:Sprite;
		//private static var feeIcon:Sprite;
		//private static var canceledIcon:Sprite;
		//private static var withdrawalIcon:SWFPayWithdrawalIcon;
		//private static var prepaidCardIcon:SWFPayPrepaidCardIcon;
		//private static var transactionFeeIcon:SWFPayTransferFeeIcon;
		//
		private var iconBitmap:Bitmap;
		
		public function ListPayWalletDetail() {
			
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
			addChild(tfFraction);
			addChild(tfCurrency);
			addChild(tfDateTime);
			addChild(tfAmount);
			addChild(tfRate);
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
				tfLabel.width = width - tfLabel.x - padding - iconSize;
				tfLabel.text = Lang.textDescription + ": " + ((data.data.description == null || data.data.description.length == 0) ? Lang.textEmpty : data.data.description);
				return tfLabel.textHeight + 4 + Config.MARGIN + sepHeight;
			}
			tfLabel.width = tfDateTime.x - tfLabel.x - padding;
			
			if (data.data.itype == "transaction") {
				return setTransactionTexts(data, width);
			}
			return itemHeight;
		}
		
		private function setTransactionTexts(li:ListItem, w:int):int {
			tfInteger.visible = true;
			tfFraction.visible = true;
			tfCurrency.visible = true;
			tfDateTime.visible = true;
			tfAmount.visible = true;
			tfLabel.multiline = true;
			tfLabel.wordWrap = true;
			
			tfLabel.text = li.data.TYPE;
			var balance:String =  li.data.AMOUNT;
			
			var type:String = li.data.TYPE.toUpperCase();
			
			//color of currency 
			var balanceColor:uint = /*type == "INTERNAL TRANSFER" ? AppTheme.GREY_MEDIUM : */AppTheme.GREEN_MEDIUM;
			if (balance.charAt(0) == "-") {
				balanceColor = AppTheme.RED_MEDIUM;
			}
			
			//tfInteger.textColor = tfFraction.textColor = tfCurrency.textColor = balanceColor;
				
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
					rightNum = balance.substring(dotIndex + 1, balance.length) + " " + CurrencyHelpers.getCurrencyByKey(li.data.CURRENCY);
					stringAmount = UI.getCurrencyTextHTML(leftNum + ".", rightNum, Config.FINGER_SIZE*.42, Config.FINGER_SIZE*.3,balanceColorString,balanceColorString);
				}else{				
					if(CurrencyHelpers.getMaxDecimalCount(li.data.CURRENCY)>0){
						leftNum = balance+".";
						rightNum = CurrencyHelpers.getZerosForCurrency(li.data.CURRENCY) +" "+ CurrencyHelpers.getCurrencyByKey(li.data.CURRENCY);
					}else{
						leftNum = balance;
						rightNum = " " +CurrencyHelpers.getCurrencyByKey(li.data.CURRENCY);
					}							
					stringAmount = UI.getCurrencyTextHTML(leftNum + "", rightNum, Config.FINGER_SIZE * .42, Config.FINGER_SIZE*.3, balanceColorString, balanceColorString);
				}
			// END Format Amount ========================
			
			tfInteger.htmlText = stringAmount;
			//tfInteger.text = balance.substring(0, balance.indexOf("."));
			//tfInteger.text = balance.substring(0, balance.indexOf("."));
			
			tfFraction.text = "";// balance.substr(balance.length - 3);
			tfCurrency.text = "";// li.data.CURRENCY;
			tfInteger.x = w - Config.DOUBLE_MARGIN -  tfInteger.width;
			
			tfCurrency.x = w - Config.DOUBLE_MARGIN - tfCurrency.width;
			tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
			//tfInteger.x = tfFraction.x - tfInteger.width + 2;
			
			tfDateTime.text = createDateString(li.data.TS * 1000);
			tfDateTime.x = w - Config.DOUBLE_MARGIN - tfDateTime.width;
			
			// TODO vinesti formatirovanie texta v UI ili utilsi 
			// TODO AMOUNT pomenjatj s BALANCE 
			if (li.data.ORIG_AMOUNT == "") {
				tfAmount.text = "";
			} else {
				tfAmount.text = ((li.data.ORIG_AMOUNT.charAt(0) != "-" && li.data.AMOUNT.charAt(0) == "-") ? "-" : "") + li.data.ORIG_AMOUNT + " " + li.data.ORIG_CURRENCY + " → " + li.data.AMOUNT + " " + li.data.CURRENCY;
			}
			
			var rateDetails:String = li.data.RATE_DETAILS;
			if (rateDetails != "") {
				tfRate.text = rateDetails;
			} else {
				tfRate.text = "";
			}
			
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.x = iconSize + Config.DOUBLE_MARGIN * 2;
			tfLabel.y = tfInteger.y + tfInteger.getLineMetrics(0).ascent - tfLabel.getLineMetrics(0).ascent;
			var trueX:int = (tfDateTime.x < tfInteger.x) ? tfDateTime.x : tfInteger.x;
			tfLabel.width = trueX - tfLabel.x - padding;
			tfAmount.y = int(tfLabel.y + tfLabel.height + Config.FINGER_SIZE * .05);
			tfRate.y = tfAmount.y + tfAmount.height;
			tfRate.width = w - tfRate.x - padding;
			
			if (tfRate.text == "")
				return tfLabel.y * 2 + tfLabel.height;
			else
				return tfRate.y + tfRate.height + Config.MARGIN;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var data:Object = li.data;
			UI.disposeBMD(iconBitmap.bitmapData);
			
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
			if (li.data.itype == "wallet") {
				tfInteger.visible = true;
				tfFraction.visible = true;
				tfCurrency.visible = true;
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				
				balance =  data.balance;
				
				if (balance == "0") {
					tfInteger.text = "0";
					tfFraction.text = ".00";
					tfCurrency.text = data.currency;
				} else {
					var dotIndex:int = balance.indexOf(".");
					if(dotIndex!=-1){ 
						// DECIMAL 
						var integerText:String = balance.substr(0, dotIndex);					
						var fractionText:String = balance.substring(dotIndex + 1, balance.length);
						
						if (fractionText != "") {					
							if (fractionText.length < 2) {
								fractionText = fractionText + "0";
							}
						}else {
							fractionText = "00";
						}
						tfInteger.text = (integerText != "") ? integerText : "0";
						tfFraction.text = "." + fractionText;
						tfCurrency.text = data.currency;
					}else {
						// NOT DECIMAL BALANCE
						tfInteger.text = balance;
						tfFraction.text = ".00";
						tfCurrency.text = data.currency;
					}
				}
				
				tfInteger.textColor = tfFraction.textColor = tfCurrency.textColor = AppTheme.GREY_DARK;
				tfCurrency.x = width - Config.DOUBLE_MARGIN - tfCurrency.width;
				tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
				tfInteger.x = tfFraction.x - tfInteger.width + 2;
				
				var accountNumber:String = data.walletID;
				tfLabel.text = Lang.textBalance + ":";
				tfLabel.width = width - tfLabel.x - padding;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
				
			} else if (li.data.itype == "description") {
				tfInteger.visible = false;
				tfFraction.visible = false;
				tfCurrency.visible = false;
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
				tfFraction.visible = false;
				tfCurrency.visible = false;
				
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				tfLabel.text = li.data.data;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
				
			} else if (li.data.itype == "transaction") {
				setTransactionTexts(li, width);
				
				// Icon 			
				var iconAsset:Sprite = UI.getIconByType(data.TYPE.toUpperCase());
				iconBitmap.bitmapData = UI.renderAsset(iconAsset, iconSize, iconSize, false, "ListPayWalletDetail.iconBitmap");
				iconBitmap.x = padding;
				iconBitmap.y = (h - iconBitmap.height) * .5;
				
				graphics.beginFill(0, .2);
				graphics.drawRect(0, h - 1, width, 1);
				graphics.endFill();
			}
			
			return this;
		}
		
		private function createDateString(val:Number):String {
			var date:Date = new Date();
			date.setTime(val);
			return ((date.getDate() < 10) ? "0" : "") + date.getDate() + "/" + ((date.getMonth() + 1 < 10) ? "0" : "") + (date.getMonth() + 1) + "/" + date.getFullYear() + " " + ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":" + ((date.getMinutes() < 10) ? "0" : "") + date.getMinutes() + ":" + ((date.getSeconds() < 10) ? "0" : "") + date.getSeconds();
		}
		
		public function dispose():void {
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