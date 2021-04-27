package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAWalletSection extends Sprite {
		
		protected var tfColorSelected:uint = 0x2B5FAB;
		protected var tfColorBase:uint = 0x22546B;
		private var tfSizeSelected:int = Config.FINGER_SIZE * .23;
		private var tfSizeBase:int = Config.FINGER_SIZE * .2;
		
		protected var tfNumber:TextField;
		protected var tfAmount:TextField;
		protected var iconTriangle:Bitmap;
		private var iconTriangleIcon:SWFTriangleGreen;
		private var sdkBugFix:Number;
		public var data:Object;
		
		protected var trueWidth:int;
		protected var trueHeight:int;
		
		public var isTotal:Boolean = false;
		
		protected var flagIcon:Bitmap;
		protected var ICON_SIZE:int = Config.FINGER_SIZE * .45;
		
		public function BAWalletSection() {
			iconTriangleIcon = new SWFTriangleGreen();
			var asset:BitmapData = UI.drawAssetToRoundRect(iconTriangleIcon, Config.FINGER_SIZE_DOT_5, true, "BAWalletSection.swissIcon");
			iconTriangle = new Bitmap(asset);
			iconTriangle.x = -Config.FINGER_SIZE_DOT_25;
			
			flagIcon = new Bitmap();
			addChild(flagIcon);
			
			tfNumber = new TextField();
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase);
			tfNumber.multiline = false;
			tfNumber.wordWrap = false;
			tfNumber.text = "|";
			tfNumber.height = tfNumber.textHeight + 4;
			tfNumber.x = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			tfNumber.y = Config.MARGIN;
			addChild(tfNumber);
			
			tfAmount = new TextField();
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .25);
			tfAmount.multiline = false;
			tfAmount.wordWrap = false;
			tfAmount.text = "|";
			tfAmount.height = tfAmount.textHeight + 4;
			tfAmount.y = int(tfNumber.height + Config.FINGER_SIZE * .12) + Config.MARGIN;
			tfAmount.x = tfNumber.x;
			addChild(tfAmount);
			
			trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN*2;
			iconTriangle.y = int((trueHeight - iconTriangle.height) * .5);
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			this.data = data;
			var iban:String = "";
			if (data.type == "total") {
				iban = data.IBAN;
			} else {
				if ("IBAN" in data == false) {
					if ("ACCOUNT_NUMBER" in data == true)
						iban = data.ACCOUNT_NUMBER;
				} else {
					iban = data.IBAN;
					if (iban.indexOf("CH") == 0) {
						iban = iban.substr(0, 2) + " " + iban.substr(2);
						if (MobileGui.stage.stageWidth > 640)
							iban = iban.substr(0, 7) + " " + iban.substr(7, 4) + " " + iban.substr(11, 4) + " " + iban.substr(15, 4) + " " + iban.substr(19);
					} else
						iban = data.IBAN;
				}
				if (MobileGui.stage.stageWidth <= 640) {
					if (iban.indexOf("CH") == 0)
						iban = iban.substr(0, 7) + " … " + iban.substr(iban.length - 4);
					else
						iban = iban.substr(0, 4) + " … " + iban.substr(iban.length - 4);
				}
			}
			tfNumber.text = iban;
			var leftX:int =  Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			
			if (MobileGui.stage.stageWidth <= 640)
				leftX = Config.FINGER_SIZE_DOT_25 + Config.MARGIN*.5;
			else
				leftX = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			tfNumber.x = leftX;
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			var values:Array = String(data.BALANCE).split(".");
			if (values.length == 1)
				values.push("00");
			if (values[1].length == 1)
				values[1] += "0";
			if ("CURRENCY" in data == true)
				tfAmount.htmlText = UI.renderCurrencyAdvanced(data.BALANCE, data.CURRENCY, Config.FINGER_SIZE * .25, Config.FINGER_SIZE * .19);
			else if ("COIN" in data == true)
				tfAmount.htmlText = UI.renderCurrencyAdvanced(data.BALANCE, data.COIN, Config.FINGER_SIZE * .25, Config.FINGER_SIZE * .19);
			tfAmount.width = tfAmount.textWidth + 4;
			sdkBugFix = tfAmount.textWidth;
			if (BankManager.getHistoryAccount() == data.ACCOUNT_NUMBER && MobileGui.centerScreen.currentScreenClass != BankBotChatScreen) {
				tfAmount.textColor = tfColorSelected;
				if (iconTriangle != null && iconTriangle.parent == null)
					addChild(iconTriangle);
			} else {
				tfAmount.textColor = 0;
				if (iconTriangle != null && iconTriangle.parent != null)
					removeChild(iconTriangle);
			}
			UI.disposeBMD(flagIcon.bitmapData);
			if (data.CURRENCY != "") {
				flagIcon.visible = true;
				var flagAsset:Sprite;
				if ("CURRENCY" in data == true)
					flagAsset = UI.getFlagByCurrency(data.CURRENCY);
				else if ("COIN" in data == true)
					flagAsset = UI.getInvestIconByInstrument(data.COIN);
				flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "BAWalletSection.flagIcon");
				flagIcon.y = tfAmount.y - Config.FINGER_SIZE*.035;
				flagIcon.x = leftX;
				tfAmount.x = leftX + Config.FINGER_SIZE*.5;
			} else {
				flagIcon.visible = false;
				tfAmount.x = leftX;
			}
			trueWidth = w;
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			if ("type" in data && data.type == "total") {
				graphics.beginFill(0x8F8F8F, 1);
				graphics.drawRect(0, 0, w, 1);
			}
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
		
		public function getData():Object {
			return data;
		}
		
		public function dispose():void {
			if (flagIcon != null){
				UI.disposeBMD(flagIcon.bitmapData);
				flagIcon = null;
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