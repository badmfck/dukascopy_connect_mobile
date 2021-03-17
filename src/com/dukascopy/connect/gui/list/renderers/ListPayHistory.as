package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
import com.dukascopy.connect.sys.payments.CurrencyHelpers;
import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.TransferType;
	import com.hurlant.util.der.Type;

	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import assets.LockClosedGrey;
	import assets.LockClosedWhite;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListPayHistory extends BaseRenderer implements IListRenderer {
		
		private var tfType:TextField;
		private var tfStatus:TextField;
		private var tfInteger:TextField;
		private var tfFraction:TextField;
		private var tfCurrency:TextField;
		private var tfDateTime:TextField;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat("Tahoma", itemHeight * .28);
		
		private var iconSize:int = Config.FINGER_SIZE * .4;// - Config.DOUBLE_MARGIN;
		
		private var itemHeightDEA:int;
		
		private var ct:ColorTransform = new ColorTransform();
		
		private var iconBitmap:Bitmap;
		private var secureCodeBitmap:Bitmap;

		public function ListPayHistory() {
			iconBitmap = new Bitmap();
			addChild(iconBitmap);	
			
			tfType = new TextField();
			tfType.autoSize = TextFieldAutoSize.NONE;
			tfType.defaultTextFormat = format;
			tfType.text = "Pp";
			tfType.multiline = false;
			tfType.wordWrap = false;
			//tfType.border = true;
			tfType.height = tfType.textHeight + 4;
			tfType.textColor = AppTheme.GREY_DARK;
			tfType.x = iconSize + Config.DOUBLE_MARGIN*2;
			tfType.y = Config.MARGIN;
			addChild(tfType);
			
			format.size = itemHeight * .20;
			tfDateTime = new TextField();
			tfDateTime.autoSize = TextFieldAutoSize.LEFT;
			tfDateTime.defaultTextFormat = format;
			tfDateTime.textColor = 0x999999;
			tfDateTime.text = "Pp";
			tfDateTime.multiline = false;
			tfDateTime.wordWrap = false;
			tfDateTime.y = tfType.y + tfType.height - tfDateTime.height - 1;
			addChild(tfDateTime);
			
			format.size = itemHeight * .23;
			tfStatus = new TextField();
			tfStatus.autoSize = TextFieldAutoSize.LEFT;
			tfStatus.defaultTextFormat = format;
			tfStatus.textColor = 0x999999;
			tfStatus.text = "Pp";
			tfStatus.multiline = true;
			tfStatus.wordWrap = true;
			tfStatus.x = iconSize + Config.DOUBLE_MARGIN*2;
			addChild(tfStatus);
			
			format.size = itemHeight * .40;
			//format.bold = true;
			tfInteger = new TextField();
			tfInteger.autoSize = TextFieldAutoSize.LEFT;
			tfInteger.defaultTextFormat = format;
			tfInteger.text = "Pp";
			tfInteger.multiline = false;
			tfInteger.wordWrap = false;
			tfInteger.textColor = AppTheme.GREEN_MEDIUM;
			tfInteger.y = int(tfDateTime.y + tfDateTime.height);
			itemHeightDEA = tfInteger.y + tfInteger.textHeight + 4 + Config.DOUBLE_MARGIN;
			
			format.size = itemHeight * .28;
			tfFraction = new TextField();
			tfFraction.autoSize = TextFieldAutoSize.LEFT;
			tfFraction.defaultTextFormat = format;
			tfFraction.text = "Pp";
			tfFraction.multiline = false;
			tfFraction.wordWrap = false;
			tfFraction.textColor = AppTheme.GREEN_MEDIUM;
			tfFraction.y = tfInteger.y + int((tfInteger.height - tfFraction.height) * .5);
			
			format.bold = false;
			tfCurrency = new TextField();
			tfCurrency.autoSize = TextFieldAutoSize.LEFT;
			tfCurrency.defaultTextFormat = format;
			tfCurrency.text = "Pp";
			tfCurrency.multiline = false;
			tfCurrency.wordWrap = false;
			tfCurrency.textColor = AppTheme.GREEN_MEDIUM;
			tfCurrency.y = tfInteger.y + int((tfInteger.height - tfCurrency.height) * .5);


			secureCodeBitmap = new Bitmap();
			secureCodeBitmap.visible = false;
			//secureCodeBitmap.y = itemHeightDEA + Config.DOUBLE_MARGIN;
			//itemHeightDEA = itemHeightDEA + Config.DOUBLE_MARGIN ;
			
			addChild(tfInteger);
			addChild(tfFraction);
			addChild(tfCurrency);
			addChild(secureCodeBitmap);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			var resultValue:int;
			if (data.data.DESCRIPTION == null) {
				if (data.data.AMOUNT != "0.00")
				{
//					resultValue = itemHeightDEA - Config.DOUBLE_MARGIN;
					resultValue = itemHeightDEA - Config.MARGIN;
				}else{
					resultValue = itemHeight;
				}
			}else{
				var status:String = data.data.STATUS;
				var canFill:Boolean;

				switch(status.toLocaleLowerCase()){
					case "pending":
					case "completed":{
						canFill = true;
						break;
					}
				}

				var trueHeight:int = addText(data.data, width);
				var type:String = data.data.TYPE;
				trueHeight += tfStatus.y + Config.MARGIN;

				if (trueHeight < itemHeight){
					resultValue = itemHeight;
				}else{
					resultValue = trueHeight;
				}
				
				
				
				if(canFill && data.data.CODE_SECURED != null &&  data.data.CODE_SECURED == true)
				{
					resultValue += Config.FINGER_SIZE * 0.2 + 8 ;//+ Config.MARGIN;// secureCodeBitmap.height;
				}
			}
			return resultValue;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = li.data;
			
			graphics.clear();
			if (highlight) {
				graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
				tfType.textColor = AppTheme.GREY_DARK;
			} else {
				tfType.textColor = AppTheme.GREY_DARK;
			}
			graphics.beginFill(0, 0.2);
			graphics.drawRect(0, h - 1, width, 1);
			
			var type:String = data.TYPE;
			var status:String = data.STATUS;
			// Icon		
			var iconAsset:Sprite = UI.getIconByType(type);
			UI.disposeBMD(secureCodeBitmap.bitmapData);
			var icon:Bitmap;
			var iconClass:Class;
			var bgColor:uint = 0xffffff;
			var txtColor:uint = 0xffffff;
			var doFill:Boolean;
			
			switch(status.toLowerCase()){
				case "cancelled":{
					ct.color = AppTheme.RED_MEDIUM;
					break;
				}
				case "pending":{
					ct.color = 0xFFC600;
					//SC
					iconClass = LockClosedWhite;
					bgColor = AppTheme.GREEN_MEDIUM;
					txtColor = 0xffffff;
					doFill = true;
					break;
				}
				case "completed":{
					//SC
					iconClass = LockClosedGrey;
					bgColor = 0xffffff;
					txtColor = AppTheme.GREY_MEDIUM;
					doFill = true;
					break;
				}
				case "":{//all
					
					break;
				}
			}

			//
			UI.disposeBMD(iconBitmap.bitmapData);
			iconBitmap.bitmapData = UI.renderAsset(iconAsset, iconSize, iconSize, false, "ListPayHistory.iconBitmap");
			iconBitmap.x = padding;
			iconBitmap.y = (h - iconBitmap.height) * .5;
			if (status.toLowerCase() != "completed")
				iconBitmap.bitmapData.colorTransform(iconBitmap.bitmapData.rect, ct);
			
			tfType.y = Config.MARGIN;
			
			addText(data, width);
			
			
			if (li.data.DESCRIPTION == null || li.data.DESCRIPTION.length == 0)
			{
				tfType.y = int((h - tfType.height) * .5);
			}

			type = data.TYPE;
			if(doFill &&  /*( type== "INCOMING TRANSFER" || type == "OUTGOING TRANSFER")&&*/ data.CODE_SECURED != null &&  data.CODE_SECURED == true)
			{
				secureCodeBitmap.visible = true;
				if (icon != null){
					UI.disposeBMD(icon.bitmapData);
				}
				icon = new Bitmap(UI.getSnapshot(new iconClass as MovieClip, StageQuality.HIGH, "ImageFrames.frame"));
				
				icon = new Bitmap(UI.scaleManual(icon.bitmapData, (Config.FINGER_SIZE * 0.2) / icon.height, true));
				UI.disposeBMD(secureCodeBitmap.bitmapData);
				secureCodeBitmap.bitmapData = UI.renderTextPlane(status, 1, 1,false,TextFormatAlign.CENTER,TextFieldAutoSize.CENTER,Config.FINGER_SIZE * 0.2,false,txtColor,bgColor,bgColor,6,0,4,4,icon,true);
				secureCodeBitmap.x = tfType.x;
				secureCodeBitmap.y = tfStatus.y + tfStatus.height;
			}else{
				secureCodeBitmap.visible = false;
			}
			return this;
		}
		
		private function addText(data:Object, w:int):int {
			tfDateTime.text = createDateString(data.CREATED_TS * 1000);
			tfDateTime.x = w - Config.DOUBLE_MARGIN - tfDateTime.width;
			
			var type:String = data.TYPE;
			if (type.toUpperCase() == TransferType.ORDER_OF_PREPAID_CARD)
			{
				type = TransferType.PREPAID_CARD_ORDER;
			}
			var label:String = type.charAt(0) + type.substr(1).toLowerCase();
			tfType.text = /*label*/ TransferType.getTextByType(label);
			tfType.width = tfDateTime.x - tfType.x - padding;
			
			var balanceColor:uint = type == "INTERNAL TRANSFER" ? AppTheme.GREY_MEDIUM : AppTheme.GREEN_MEDIUM;
			var balance:String = data.AMOUNT;
			//if (balance != "0.00" ) {
				//if (balance.charAt(0) == "-") {
					//balanceColor = AppTheme.RED_MEDIUM;
				//}
				//tfInteger.textColor = tfFraction.textColor = tfCurrency.textColor = balanceColor;
				//tfInteger.text = balance.substring(0, balance.indexOf("."));
				//tfFraction.text = balance.substr(balance.length - 3);
				//tfCurrency.text = data.CURRENCY;
			//} else {
				//tfInteger.text = "";
				//tfFraction.text = "";
				//tfCurrency.text = "";
			//}
			
			
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
					rightNum = balance.substring(dotIndex + 1, balance.length) + " " + CurrencyHelpers.getCurrencyByKey(data.CURRENCY);
					stringAmount = UI.getCurrencyTextHTML(leftNum + ".", rightNum, Config.FINGER_SIZE*.42, Config.FINGER_SIZE*.3,balanceColorString,balanceColorString);
				}else{				
							
					if(CurrencyHelpers.getMaxDecimalCount(data.CURRENCY)>0){
						leftNum = balance+".";
						rightNum = CurrencyHelpers.getZerosForCurrency(data.CURRENCY) +" "+ CurrencyHelpers.getCurrencyByKey(data.CURRENCY);
					}else{
						leftNum = balance;
						rightNum = " " +CurrencyHelpers.getCurrencyByKey(data.CURRENCY);
					}					
					stringAmount = UI.getCurrencyTextHTML(leftNum + "", rightNum, Config.FINGER_SIZE * .42, Config.FINGER_SIZE*.3, balanceColorString, balanceColorString);
				}
				// END Format Amount ========================
					
				//tfInteger.border = true;
				tfInteger.htmlText = stringAmount;
				
				
			
			tfCurrency.text = "";// w - Config.DOUBLE_MARGIN - tfCurrency.width;
			tfFraction.text = "";// tfCurrency.x - Config.MARGIN - tfFraction.width;
			//tfInteger.x = tfFraction.x - tfInteger.width + 2;
			tfInteger.x = w - Config.DOUBLE_MARGIN -  tfInteger.width;
			
			tfDateTime.text = createDateString(data.CREATED_TS * 1000);
			tfDateTime.x = w - Config.DOUBLE_MARGIN - tfDateTime.width;
			
			var minX:int = Math.min(tfDateTime.x, tfInteger.x);
			tfType.width = minX - Config.MARGIN - tfType.x;
			
			var descr:String = "";
			if (data.DESCRIPTION != null && data.DESCRIPTION.length > 0)
				descr = data.DESCRIPTION;
			
			var trueWidth:int = (tfInteger.x < tfDateTime.x) ? tfInteger.x : tfDateTime.x;
			
			tfStatus.y = tfType.y + tfType.height;
			tfStatus.text = descr;
			tfStatus.width = trueWidth - tfStatus.x - padding;//tfStatus.textHeight;tfStatus.textWidth;
			
			var returnBiggestHeight:int = Math.max(tfStatus.height, tfInteger.height);
			return returnBiggestHeight;
		}
		
		private function createDateString(val:Number):String {
			var date:Date = new Date();
			date.setTime(val);
			return ((date.getDate() < 10) ? "0" : "") + date.getDate() + "/" + ((date.getMonth() + 1 < 10) ? "0" : "") + (date.getMonth() + 1) + "/"  + date.getFullYear() + " " + ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":" + ((date.getMinutes() < 10) ? "0" : "") + date.getMinutes() + ":" + ((date.getSeconds() < 10) ? "0" : "") + date.getSeconds();
		}
		
		public function dispose():void {
			graphics.clear();
			UI.destroy(iconBitmap);
			iconBitmap = null;
			if (tfType != null)
				tfType.text = "";
			tfType = null;
			if (tfStatus != null)
				tfStatus.text = "";
			tfStatus = null;
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
			format = null;
			if ( iconBitmap!= null){
				UI.disposeBMD(iconBitmap.bitmapData);
			}
			if (secureCodeBitmap != null){
				UI.disposeBMD(secureCodeBitmap.bitmapData);
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}