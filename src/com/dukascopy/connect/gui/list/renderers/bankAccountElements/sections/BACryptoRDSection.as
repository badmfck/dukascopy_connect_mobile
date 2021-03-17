package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.sys.bankManager.BankBotController;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BACryptoRDSection extends Sprite {
		
		protected var tfColorSelected:uint = 0x2B5FAB;
		protected var tfColorBase:uint = 0x22546B;
		private var tfSizeSelected:int = Config.FINGER_SIZE * .23;
		private var tfSizeBase:int = Config.FINGER_SIZE * .2;
		
		protected var tfStorage:TextField;
		protected var tfNumber:TextField;
		protected var tfAmount:TextField;
		protected var tfType:TextField;
		protected var tfRef:TextField;
		protected var iconTriangle:Bitmap;
		private var iconTriangleIcon:SWFTriangleGreen;
		protected var status:Bitmap;
		
		public var data:Object;
		
		protected var trueWidth:int;
		protected var trueHeight:int;
		
		public var isTotal:Boolean = false;
		
		protected var flagIcon:Bitmap;
		protected var ICON_SIZE:int = Config.FINGER_SIZE * .45;
		
		public function BACryptoRDSection() {
			iconTriangleIcon = new SWFTriangleGreen();
			var asset:BitmapData = UI.drawAssetToRoundRect(iconTriangleIcon, Config.FINGER_SIZE_DOT_5, true, "BACryptoRDSection.swissIcon");
			iconTriangle = new Bitmap(asset);
			iconTriangle.x = -Config.FINGER_SIZE_DOT_25;
			
			flagIcon = new Bitmap();
			addChild(flagIcon);
			
			tfStorage = new TextField();
			tfStorage.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .18);
			tfStorage.multiline = false;
			tfStorage.wordWrap = false;
			tfStorage.text = "|";
			tfStorage.height = tfStorage.textHeight + 4;
			tfStorage.y = Config.MARGIN;
			addChild(tfStorage);
			
			tfAmount = new TextField();
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24);
			tfAmount.multiline = false;
			tfAmount.wordWrap = false;
			tfAmount.text = "|";
			tfAmount.height = tfAmount.textHeight + 4;
			tfAmount.y = int(tfStorage.y + tfStorage.height);
			addChild(tfAmount);
			
			tfType = new TextField();
			tfType.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24, tfColorBase);
			tfType.multiline = false;
			tfType.wordWrap = false;
			tfType.text = "|";
			tfType.height = tfType.textHeight + 4;
			tfType.y = int(tfAmount.y + tfAmount.height);
			addChild(tfType);
			
			tfNumber = new TextField();
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24, tfColorBase);
			tfNumber.multiline = false;
			tfNumber.wordWrap = false;
			tfNumber.text = "|";
			tfNumber.height = tfNumber.textHeight + 4;
			tfNumber.y = int(tfType.y + tfType.height);
			addChild(tfNumber);
			
			tfRef = new TextField();
			tfRef.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24, tfColorBase);
			tfRef.multiline = false;
			tfRef.wordWrap = false;
			tfRef.text = "|";
			tfRef.height = tfRef.textHeight + 4;
			tfRef.y = int(tfNumber.y + tfNumber.height);
			addChild(tfRef);
			
			status = new Bitmap();
			status.y = int(tfRef.y + tfRef.height);
			addChild(status);
			
			trueHeight = tfRef.y + tfRef.height + Config.MARGIN + Config.FINGER_SIZE_DOT_35;
			iconTriangle.y = int((trueHeight - iconTriangle.height) * .5);
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			this.data = data;
			
			if (data.storage_type == "BLOCKCHAIN")
				tfStorage.text = Lang.textInBlockchain;
			else
				tfStorage.text = Lang.textInBank;
			tfStorage.width = tfStorage.textWidth + 4;
			
			var expired:String = Lang.textExpires + " ";
			if ("termination" in data == true && isNaN(Number(data.termination)) == false) {
				var dt:Date = new Date();
				dt.setTime(Number(data.termination) * 1000);
				expired += DateUtils.getTimeString(dt, true);
			}
			tfNumber.text = expired;
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			
			var amountStr:String = Number(data.deposit) + "";
			var amountParts:Array = amountStr.split(".");
			if (amountParts.length == 2) {
				amountParts[1] = amountParts[1].substr(0, 4)
			}
			tfAmount.htmlText = UI.renderCurrency(
				amountParts[0] + ((amountParts.length == 2) ? "." : ""),
				((amountParts.length == 2) ? amountParts[1] : ""),
				"DUK+",
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			tfAmount.width = tfAmount.textWidth + 4;
			var amount:Number = parseFloat(data.amount);
			if (data.reward_currency != "DCO")
				tfType.text = Lang.textFiatReward + " " + Number(data.reward) + " " + data.reward_currency;
			else
				tfType.text = Lang.textCoinReward + " " + Number(data.reward) + " DUK+";
			tfType.width = tfType.textWidth + 4;
			
			tfRef.text = "ID: " + data.code;
			tfRef.alpha = .6;
			if (w < tfRef.textWidth + 4)
				tfRef.width = w;
			else
				tfRef.width = tfRef.textWidth + 4;
			
			UI.disposeBMD(flagIcon.bitmapData);
			
			flagIcon.visible = true;
			var flagAsset:Sprite;
			if (data.storage_type == "DUKASCOPY")
				flagAsset = UI.getInvestIconByInstrument("DCO");
			else if (data.storage_type == "BLOCKCHAIN")
				flagAsset = UI.getInvestIconByInstrument("BLOCKCHAIN");
			flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "BACryptoRDSection.flagIcon");
			flagIcon.y = int((trueHeight - flagIcon.height) * .5);
			flagIcon.x = Config.MARGIN;
			tfStorage.x = ICON_SIZE + Config.DOUBLE_MARGIN;
			tfAmount.x = tfStorage.x;
			tfRef.x = tfStorage.x;
			tfType.x = tfStorage.x;
			tfNumber.x = tfStorage.x;
			status.x = tfStorage.x + 2;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(
				Lang.rdStatuses[data.status.toLowerCase()],
				0xFFFFFF,
				Config.FINGER_SIZE * .17,
				TextFormatAlign.CENTER
			);
			if (textSettings.text == null)
				textSettings.text = "";
			var statusColor:uint = 0x5EC268;
			if (data.status == "CLOSED")
				statusColor = 0x954880;
			else if (data.status == "CANCELLED")
				statusColor = 0x7E94A9;
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(
				textSettings,
				statusColor,
				1,
				Config.FINGER_SIZE * .05,
				NaN,
				-1,
				1,
				Config.FINGER_SIZE * .25
			);
			status.bitmapData = buttonBitmap;
			
			trueWidth = w;
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			graphics.endFill();
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
			return Math.max(tfAmount.width, tfNumber.width);
		}
		
		public function dispose():void {
			if (flagIcon != null){
				UI.disposeBMD(flagIcon.bitmapData);
				flagIcon = null;
			}
			if (tfNumber != null)
			{
				UI.destroy(tfNumber);
				tfNumber = null;
			}
			if (tfAmount != null)
			{
				UI.destroy(tfAmount);
				tfAmount = null;
			}
			if (tfType != null)
			{
				UI.destroy(tfType);
				tfType = null;
			}
			if (iconTriangle != null)
			{
				UI.destroy(iconTriangle);
				iconTriangle = null;
			}
			if (iconTriangleIcon != null)
			{
				UI.destroy(iconTriangleIcon);
				iconTriangleIcon = null;
			}
			data = null;
		}
		
		public function clearGraphics():void {
			graphics.clear();
			if ("type" in data && data.type == "total") {
				graphics.beginFill(0x8F8F8F, 1);
				graphics.drawRect(0, 0, trueWidth, 1);
				graphics.endFill();
			}
		}
	}
}