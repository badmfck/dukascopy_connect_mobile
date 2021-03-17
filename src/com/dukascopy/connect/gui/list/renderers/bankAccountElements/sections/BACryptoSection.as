package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BACryptoSection extends BAWalletSection {
		
		private var tfReserved:TextField;
		
		public function BACryptoSection() {
			super();
			
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2, 0);
			
			tfReserved = new TextField();
			tfReserved.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .2);
			tfReserved.multiline = false;
			tfReserved.wordWrap = false;
			tfReserved.text = "|";
			tfReserved.height = tfReserved.textHeight + 4;
			tfReserved.y = tfAmount.y + tfAmount.height;
			addChild(tfReserved);
		}
		
		override public function setData(data:Object, w:int):void {
			this.data = data;
			
			var tfNumberWidth:int = w - tfNumber.x * 2;
			
			var startIndex:int;
			var iban:String = "";
			if ("ACCOUNT_NUMBER" in data) {
				iban = Lang.textInBank + " " + data.ACCOUNT_NUMBER;
				startIndex = Lang.textInBank.length + 1;
			} else if ("ADDRESS" in data) {
				iban = Lang.textInBlockchain + " " + data.ADDRESS;
				startIndex = Lang.textInBlockchain.length + 1;
			}
			tfNumber.text = iban;
			if (tfNumber.textWidth + 4 > tfNumberWidth) {
				if ("ACCOUNT_NUMBER" in data)
					iban = iban.substr(0, 13) + " ... " + iban.substr(iban.length - 4, 4);
				else if ("ADDRESS" in data)
					iban = iban.substr(0, 22) + " ... " + iban.substr(iban.length - 4, 4);
				tfNumber.text = iban;
			}
			tfNumber.width = tfNumberWidth;
			tfNumber.setTextFormat(new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase), startIndex, iban.length);
			
			tfAmount.htmlText = UI.renderCurrencyAdvanced(data.BALANCE, data.COIN, Config.FINGER_SIZE * .25, Config.FINGER_SIZE * .19);
			tfAmount.width = tfAmount.textWidth + 4;
			
			if ("RESERVED" in data) {
				tfReserved.visible = true;
				tfReserved.text = Lang.textBlockedForStaking + " " + parseFloat(Number(data.RESERVED).toFixed(CurrencyHelpers.getMaxDecimalCount("DCO"))) + " DUK+";
				tfReserved.setTextFormat(new TextFormat("Tahoma", Config.FINGER_SIZE * .2, tfColorBase), Lang.textBlockedForStaking.length, tfReserved.text.length);
				trueHeight = tfReserved.y + tfReserved.height + Config.MARGIN * 2;
			} else {
				tfReserved.visible = false;
				trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN * 2;
			}
			
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
			if (data.COIN != "") {
				flagIcon.visible = true;
				var iconName:String = ("ADDRESS" in data == false) ? data.COIN : "BLOCKCHAIN";
				var flagAsset:Sprite = UI.getInvestIconByInstrument(iconName);
				flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "BACryptoSection.flagIcon");
				flagIcon.y = int((trueHeight - flagIcon.height) * .5);
				flagIcon.x = Config.FINGER_SIZE_DOT_25 - 2;
				tfNumber.x = flagIcon.x + Config.FINGER_SIZE * .5;
				tfAmount.x = flagIcon.x + Config.FINGER_SIZE * .5;
				tfReserved.x = tfAmount.x;
				tfReserved.width = w - tfReserved.x - Config.FINGER_SIZE_DOT_25;
			} else {
				flagIcon.visible = false;
				tfNumber.x = Config.FINGER_SIZE_DOT_25 - 2;
				tfAmount.x = tfNumber.x;
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
	}
}