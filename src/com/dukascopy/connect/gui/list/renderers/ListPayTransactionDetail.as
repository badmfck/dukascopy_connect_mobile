package com.dukascopy.connect.gui.list.renderers {

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.TransferType;
	import com.dukascopy.langs.Lang;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListPayTransactionDetail extends BaseRenderer implements IListRenderer {

		private var tfLabelMega:MegaText;
		private var tfLabel:TextField;
		private var tfLabel1:TextField;
		private var tfInteger:TextField;
		private var tfFraction:TextField;
		private var tfCurrency:TextField;
		private var tfDateTime:TextField;
		private var tfAmount:TextField;
		private var tfRate:TextField;
		private var btnRepeat:BitmapButton;

		private var sepHeight:int = Config.FINGER_SIZE * .05;

		private var padding:int = Config.FINGER_SIZE * .3;

		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat("Tahoma", itemHeight * .28);

		private var iconSize:int = Config.FINGER_SIZE * .4;// Config.FINGER_SIZE - Config.DOUBLE_MARGIN;

		private var COLOR_DESCRIPTION_TITLE:String = "#93a2ae";
		private var COLOR_DESCRIPTION_BODY:String = "#3e4756";

		private var btnType:String = "";
		private var iconBitmap:Bitmap;

		private var _isSecureCode:Boolean;

		
		
		
	/** @CONSTRUCTOR **/	
	public function ListPayTransactionDetail() {

			iconBitmap = new Bitmap();
			addChild(iconBitmap);

			btnRepeat = new BitmapButton();
			btnRepeat.setStandartButtonParams();
			btnRepeat.usePreventOnDown = false;
			btnRepeat.cancelOnVerticalMovement = true;
//			btnRepeat.tapCallback = onRepeat;
			btnRepeat.visible = false;

			tfLabelMega = new MegaText();
			tfLabelMega.x = padding;

			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = padding;

			tfLabel1 = new TextField();
			tfLabel1.autoSize = TextFieldAutoSize.LEFT;
			tfLabel1.defaultTextFormat = format;
			tfLabel1.text = "Pp";
			tfLabel1.multiline = true;
			tfLabel1.wordWrap = true;
			tfLabel1.x = padding;

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
			//tfAmount.border = true;
			//tfAmount.y = int((itemHeight - tfAmount.height - tfLabel.height) * .5 + tfLabel.height);
			tfAmount.y = tfLabel.y + tfLabel.textHeight * 1.8;
			tfAmount.x = iconSize + Config.DOUBLE_MARGIN * 2;

			tfRate = new TextField();
			tfRate.textColor = 0x999999;
			tfRate.autoSize = TextFieldAutoSize.LEFT;
			tfRate.defaultTextFormat = format;
			tfRate.text = "Pp";
			tfRate.multiline = true;
			tfRate.wordWrap = true;
			//tfRate.y = int((itemHeight - tfAmount.height - tfLabel.height) * .5 + tfLabel.height)+ tfAmount.height;
			tfRate.y = tfLabel.y + tfLabel.textHeight * 1.3;
			tfRate.x = iconSize + Config.DOUBLE_MARGIN * 2;

			addChild(tfLabel);
			addChild(tfLabelMega);
			addChild(tfLabel1);
			addChild(tfInteger);
			addChild(tfFraction);
			addChild(tfCurrency);
			addChild(tfDateTime);
			addChild(tfAmount);
			addChild(tfRate);
			addChild(btnRepeat);
	}

		
		
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {

			tfLabel.multiline = false;
			tfLabel.wordWrap = false;

			tfRate.multiline = false;
			tfRate.wordWrap = false;

			if (data == null) return itemHeight;
			
			if (data.data.itype == "operation")
				return itemHeight;
				
			if (data.data.itype == "description") {
				var value:int = 0;

				if ("btnType" in data.data) {
					value = 0;//int(padding * .5) ;
					btnType = data.data["btnType"] as String;
					var str:String;
					var bool:Boolean = data.data["code"] as Boolean;
					if (bool) {
						str = Lang.enterSecurityCode;
						isSecureCode = true;
					} else if ("Incoming Transfer" == btnType) {
						str = Lang.sendBack;
					} else {
						str = Lang.TEXT_REPEAT;
					}
					var bitmapPlane2:BitmapData = UI.renderButton(str, width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, 0xffffff, AppTheme.RED_MEDIUM, AppTheme.RED_DARK, AppTheme.BUTTON_CORNER_RADIUS);
					btnRepeat.setBitmapData(bitmapPlane2, true);
					btnRepeat.setOverflow(10, Config.FINGER_SIZE, Config.FINGER_SIZE, 10);
					btnRepeat.show(.3, .5);
					btnRepeat.x = int((width - btnRepeat.width) * .5);

					value = padding;
				} else {
					value = setDescriptionText(data, width) + ((data.data.isLast) ? padding : int(padding * .5))
				}

				if (data.data.isLast) {
					value = value + Config.FINGER_SIZE;
				}
				return value;
			}
			
			
			if (data.data.itype == "transaction") {
				return setTransactionTexts(data, width);
			}

			
			if (data.data.itype == "title")
				return itemHeight * .8;

				
			return itemHeight;
		}
		
		
		
		// get View 

		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var data:Object = li.data;
			if (data == null) {
				return this;
			}
			btnRepeat.visible = false;
			tfLabel1.visible = false;
			tfLabelMega.visible = false;

			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			graphics.clear();
			UI.disposeBMD(iconBitmap.bitmapData);
			tfRate.text = "";

			if (highlight && li.data.itype == "transaction") {
				graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
				tfLabel.textColor = AppTheme.GREY_DARK;
			} else {
				tfLabel.textColor = AppTheme.GREY_DARK;
			}
			tfLabel.x = padding;
			tfLabelMega.x = padding;

			var balance:String;
			tfDateTime.visible = false;
			tfAmount.visible = false;
			if (li.data.itype == "operation") {
				
				tfInteger.visible = true;
				tfFraction.visible = true;
				tfCurrency.visible = true;
				tfLabel.multiline = false;
				tfLabel.wordWrap = false;


				tfLabel.visible = true;
				tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5); // TODO

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

				if (data.isLast != null && data.isLast == true) {
					/*if(btnRepeat != null ){
					 btnRepeat.activate();
					 }*/
					tfLabel.visible = false;
					tfDateTime.visible = false;
					tfAmount.visible = false;
					tfRate.visible = false;
					tfInteger.visible = false;
					tfFraction.visible = false;
					tfCurrency.visible = false;

					btnRepeat.visible = true;

					graphics.beginFill(0xEF4231);
					graphics.drawRect(0, h - sepHeight, width, sepHeight);
					graphics.endFill();
				} else {
					setDescriptionText(li, width);
				}
			} else if (li.data.itype == "title") {
				tfInteger.visible = false;
				tfFraction.visible = false;
				tfCurrency.visible = false;

				tfLabel.multiline = false;
				tfLabel.wordWrap = false;
				tfLabel.visible = true;
				tfLabel.htmlText = "<font color='" + COLOR_DESCRIPTION_TITLE + "' size='" + Config.FINGER_SIZE * .25 + "'>" + li.data.data + "</font>";
				tfLabel.width = width - tfLabel.x - padding;
				tfLabel.y = Math.round((h - tfLabel.textHeight) * .5);
			} else if (li.data.itype == "transaction") {
				setTransactionTexts(li, width);

				var type:String = data.TYPE.toUpperCase();
				// Icon 			
				var iconAsset:Sprite = UI.getIconByType(type);
				iconBitmap.bitmapData = UI.renderAsset(iconAsset, iconSize, iconSize, false, "ListPayTransactionDetail.iconBitmap");
				iconBitmap.x = padding;
				iconBitmap.y = (h - iconBitmap.height) * .5;

				graphics.beginFill(0, .2);
				graphics.drawRect(0, h - 1, width, 1);
				graphics.endFill();
			}
			return this;
		}


		
		/**
		 * Set Description Text 
		 * @param	li
		 * @param	w
		 * @return
		 */
		private function setDescriptionText(li:ListItem, w:int):int {
			tfLabel1.visible = false;
			tfLabelMega.visible = false;
			tfInteger.visible = false;
			tfFraction.visible = false;
			tfCurrency.visible = false;

			tfLabel.multiline = true;
			tfLabel.wordWrap = true;

			tfLabel.visible = true;
			tfLabel.y = 0;
			if (li.data.data == null) {
				tfLabel.visible = false;
				return tfLabel.y;
			}
			if (li.data.data != null && li.data.data.length == 2) {
				tfLabel1.visible = true;
				tfLabel.width = tfLabel1.width = int((w - padding * 3) * .5);
			}
			else {
				tfLabel.width = w - padding * 2;
			}
			var isMega:Boolean;
			var isWasSmile:Boolean;


			var key:String = (li.data.data[0].key == null || li.data.data[0].key.length == 0) ? "Empty" : li.data.data[0].key;
			var description:String = ((li.data.data[0].description == null || li.data.data[0].description.length == 0) ? "N/A" : li.data.data[0].description);
			//
			if (key == "Message:") {
				if ("wasSmile" in li.data.data[0]) {
					if (li.data.data[0].wasSmile == 2) {
						isMega = true;
						isWasSmile = true;
					} else {
						isMega = false;
					}
				}else{
					isMega = true;
				}
			}

			if (isMega) {//TODO:
				tfLabelMega.visible = true;
				tfLabel.htmlText = "<font color='" + COLOR_DESCRIPTION_TITLE + "' size='" + Config.FINGER_SIZE * .25 + "'>" + key + "</font>" + "\n"
				tfLabel1.x = int(padding * 2 + tfLabel.width);
				//tfLabelMega.x = tfLabel1.x;
				var h:int = tfLabelMega.setText(tfLabel.width, description, 0x3e4756, Config.FINGER_SIZE * .25, "#77C043", 1.5, 0);
				if(isWasSmile == false)
				{
					li.data.data[0].wasSmile = tfLabelMega.getWasSmile() ? 2 : 1;
				}
				tfLabelMega.y =  tfLabel.height;
				tfLabelMega.render();
				return h + tfLabel.height;
			} else {
				tfLabel1.x = int(padding * 2 + tfLabel.width);
				tfLabel.htmlText = "<font color='" + COLOR_DESCRIPTION_TITLE + "' size='" + Config.FINGER_SIZE * .25 + "'>" + key + "</font>" + "\n" +
						"<font color='" + COLOR_DESCRIPTION_BODY + "'>" + description + "</font>";
				if (li.data.data.length == 2) {
					key = (li.data.data[1].key == null || li.data.data[1].key.length == 0) ? "Empty" : li.data.data[1].key;
					description = ((li.data.data[1].description == null || li.data.data[1].description.length == 0) ? "N/A" : li.data.data[1].description);
					tfLabel1.htmlText = "<font color='" + COLOR_DESCRIPTION_TITLE + "' size='" + Config.FINGER_SIZE * .25 + "'>" + key + "</font>" + "\n" +
							"<font color='" + COLOR_DESCRIPTION_BODY + "'>" + description + "</font>";
				}
				return (tfLabel.height < tfLabel1.height) ? tfLabel1.height : tfLabel.height;
			}
		}

		
		/** 
		 * Set Transaction texts  
		 **/
		private function setTransactionTexts(li:ListItem, w:int):int {
			tfInteger.visible = true;
			tfFraction.visible = true;
			tfCurrency.visible = true;
			tfDateTime.visible = true;
			tfAmount.visible = true;
//			tfRate.visible = true;
//			tfLabel1.visible = true;

			tfLabel.visible = true;
			tfLabel.multiline = true;
			tfLabel.wordWrap = true;

			tfLabel.text = TransferType.getTextByType(li.data.TYPE);
			
			var balance:String = li.data.AMOUNT;

			var type:String = li.data.TYPE.toUpperCase();

			//color of currency 
			var balanceColor:uint = AppTheme.GREEN_MEDIUM;
			if (balance.charAt(0) == "-") {
				balanceColor = AppTheme.RED_DARK;
			}
			tfInteger.textColor = tfFraction.textColor = tfCurrency.textColor = balanceColor;

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
			tfFraction.text = "";// balance.substr(balance.length - 3);
			tfCurrency.text = "";// li.data.CURRENCY;

			tfCurrency.x = w - Config.DOUBLE_MARGIN - tfCurrency.width;
			tfFraction.x = tfCurrency.x - Config.MARGIN - tfFraction.width;
			//tfInteger.x = tfFraction.x - tfInteger.width + 2;
			tfInteger.x = w - Config.DOUBLE_MARGIN -  tfInteger.width;
			
			
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

		
		private function createDateString(val:Number):String {
			var date:Date = new Date();
			date.setTime(val);
			return ((date.getDate() < 10) ? "0" : "") + date.getDate() + "/" + ((date.getMonth() + 1 < 10) ? "0" : "") + (date.getMonth() + 1) + "/" + date.getFullYear() + " " + ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":" + ((date.getMinutes() < 10) ? "0" : "") + date.getMinutes() + ":" + ((date.getSeconds() < 10) ? "0" : "") + date.getSeconds();
		}

		
		
		

		// Dispose 
		public function dispose():void {
			graphics.clear();
			UI.destroy(iconBitmap);
			iconBitmap = null;
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			if (tfLabel1 != null)
				tfLabel1.text = "";
			tfLabel1 = null;
			if (tfLabelMega != null)
				tfLabelMega.dispose();
			tfLabelMega = null;
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
			if (btnRepeat != null)
				btnRepeat.dispose();
			btnRepeat = null;
		}

		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}

		public function get isSecureCode():Boolean {
			return _isSecureCode;
		}

		public function set isSecureCode(value:Boolean):void {
			_isSecureCode = value;
		}

	}
}