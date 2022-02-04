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
	
	public class BACryptoSwapSection extends Sprite {
		
		private var tfColorBase:uint = 0x22546B;
		
		private var tfCryptoAmount:TextField;
		private var tfReceivedAmount:TextField;
		private var tfBuybackAmount:TextField;
		private var tfBuybackDate:TextField;
		private var tfCode:TextField;
		private var flagIcon:Bitmap;
		private var status:Bitmap;
		
		public var data:Object;
		
		private var trueWidth:int;
		private var trueHeight:int;
		
		private var ICON_SIZE:int = Config.FINGER_SIZE * .45;
		
		public function BACryptoSwapSection() {
			flagIcon = new Bitmap();
			addChild(flagIcon);
			
			tfCryptoAmount = new TextField();
			tfCryptoAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24);
			tfCryptoAmount.multiline = false;
			tfCryptoAmount.wordWrap = false;
			tfCryptoAmount.text = "|";
			tfCryptoAmount.height = tfCryptoAmount.textHeight + 4;
			tfCryptoAmount.y = Config.MARGIN;
			addChild(tfCryptoAmount);
			
			tfReceivedAmount = new TextField();
			tfReceivedAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24, tfColorBase);
			tfReceivedAmount.multiline = false;
			tfReceivedAmount.wordWrap = false;
			tfReceivedAmount.text = "|";
			tfReceivedAmount.height = tfReceivedAmount.textHeight + 4;
			tfReceivedAmount.y = int(tfCryptoAmount.y + tfCryptoAmount.height);
			addChild(tfReceivedAmount);
			
			tfBuybackAmount = new TextField();
			tfBuybackAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24, tfColorBase);
			tfBuybackAmount.multiline = false;
			tfBuybackAmount.wordWrap = false;
			tfBuybackAmount.text = "|";
			tfBuybackAmount.height = tfBuybackAmount.textHeight + 4;
			tfBuybackAmount.y = int(tfReceivedAmount.y + tfReceivedAmount.height);
			addChild(tfBuybackAmount);
			
			tfBuybackDate = new TextField();
			tfBuybackDate.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24, tfColorBase);
			tfBuybackDate.multiline = false;
			tfBuybackDate.wordWrap = false;
			tfBuybackDate.text = "|";
			tfBuybackDate.height = tfBuybackDate.textHeight + 4;
			tfBuybackDate.y = int(tfBuybackAmount.y + tfBuybackAmount.height);
			addChild(tfBuybackDate);
			
			tfCode = new TextField();
			tfCode.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .24, tfColorBase);
			tfCode.multiline = false;
			tfCode.wordWrap = false;
			tfCode.text = "|";
			tfCode.height = tfCode.textHeight + 4;
			tfCode.y = int(tfBuybackDate.y + tfBuybackDate.height);
			addChild(tfCode);
			
			status = new Bitmap();
			status.y = int(tfCode.y + tfCode.height);
			addChild(status);
			
			trueHeight = tfCode.y + tfCode.height + Config.MARGIN + Config.FINGER_SIZE_DOT_35;
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			this.data = data;
			// CRYPTO AMOUNT
			var amountStr:String = Number(data.coin_amount.amount) + "";
			var amountParts:Array = amountStr.split(".");
			if (amountParts.length == 2) {
				amountParts[1] = amountParts[1].substr(0, 4)
			}
			tfCryptoAmount.htmlText = UI.renderCurrency(
				amountParts[0] + ((amountParts.length == 2) ? "." : ""),
				((amountParts.length == 2) ? amountParts[1] : ""),
				"DUK+",
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			if (w < tfCryptoAmount.textWidth + 4)
				tfCryptoAmount.width = w;
			else
				tfCryptoAmount.width = tfCryptoAmount.textWidth + 4;
			// RECEIVED AMOUNT
			var lbl:String = Lang.textReceivedAmount + " ";
			amountStr = Number(data.swap_amount.amount) + "";
			amountParts = amountStr.split(".");
			if (amountParts.length == 2) {
				amountParts[1] = amountParts[1].substr(0, 4)
			}
			lbl += UI.renderCurrency(
				amountParts[0] + ((amountParts.length == 2) ? "." : ""),
				((amountParts.length == 2) ? amountParts[1] : ""),
				data.swap_amount.ccy_code,
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			tfReceivedAmount.htmlText = lbl;
			if (w < tfReceivedAmount.textWidth + 4)
				tfReceivedAmount.width = w;
			else
				tfReceivedAmount.width = tfReceivedAmount.textWidth + 4;
			// BUYBACK AMOUNT
			lbl = Lang.textBuybackAmount + " ";
			amountStr = Number(data.buyback_amount.amount) + "";
			amountParts = amountStr.split(".");
			if (amountParts.length == 2) {
				amountParts[1] = amountParts[1].substr(0, 4)
			}
			lbl += UI.renderCurrency(
				amountParts[0] + ((amountParts.length == 2) ? "." : ""),
				((amountParts.length == 2) ? amountParts[1] : ""),
				data.buyback_amount.ccy_code,
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			tfBuybackAmount.htmlText = lbl;
			if (w < tfBuybackAmount.textWidth + 4)
				tfBuybackAmount.width = w;
			else
				tfBuybackAmount.width = tfBuybackAmount.textWidth + 4;
			// BUYBACK DATE
			lbl = Lang.textBuybackDate + " ";
			if ("termination" in data == true && isNaN(Number(data.termination)) == false) {
				var dt:Date = new Date();
				dt.setTime(Number(data.termination) * 1000);
				lbl += DateUtils.getTimeString(dt, true);
			}
			tfBuybackDate.text = lbl;
			if (w < tfBuybackDate.textWidth + 4)
				tfBuybackDate.width = w;
			else
				tfBuybackDate.width = tfBuybackDate.textWidth + 4;
			// SWAP ID
			tfCode.text = "ID: " + data.code;
			tfCode.alpha = .6;
			if (w < tfCode.textWidth + 4)
				tfCode.width = w;
			else
				tfCode.width = tfCode.textWidth + 4;
			
			UI.disposeBMD(flagIcon.bitmapData);
			
			flagIcon.visible = true;
			var flagAsset:Sprite;
			flagAsset = UI.getFlagByCurrency(data.buyback_amount.ccy_code);
			flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "BACryptoRDSection.flagIcon");
			flagIcon.y = int((trueHeight - flagIcon.height) * .5);
			flagIcon.x = Config.MARGIN;
			tfCryptoAmount.x = ICON_SIZE + Config.DOUBLE_MARGIN;
			tfReceivedAmount.x = tfCryptoAmount.x;
			tfBuybackAmount.x = tfCryptoAmount.x;
			tfBuybackDate.x = tfCryptoAmount.x;
			tfCode.x = tfCryptoAmount.x;
			status.x = tfCryptoAmount.x + 2;
			
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
			else if (data.status == "ON_HOLD")
				statusColor = 0xFFCC00;
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
			
			graphics.clear();
			graphics.beginFill(0, .1);
			graphics.drawRect(0, trueHeight - 1, w, 1);
			graphics.endFill();
			
			trueWidth = w;
		}
		
		public function clearGraphics():void {
			graphics.clear();
		}
		
		public function getWidth():int {
			return trueWidth;
		}
		
		public function getTrueWidth():int {
			return trueWidth;
		}
		
		public function dispose():void {
			if (flagIcon != null)
				UI.disposeBMD(flagIcon.bitmapData);
			flagIcon = null;
			if (status != null)
				UI.disposeBMD(status.bitmapData);
			status = null;
			if (tfCryptoAmount != null)
				UI.destroy(tfCryptoAmount);
			tfCryptoAmount = null;
			if (tfReceivedAmount != null)
				UI.destroy(tfReceivedAmount);
			tfReceivedAmount = null;
			if (tfBuybackAmount != null)
				UI.destroy(tfBuybackAmount);
			tfBuybackAmount = null;
			if (tfBuybackDate != null)
				UI.destroy(tfBuybackDate);
			tfBuybackDate = null;
			if (tfCode != null)
				UI.destroy(tfCode);
			tfCode = null;
			data = null;
		}
	}
}