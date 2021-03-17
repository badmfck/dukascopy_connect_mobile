package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.screens.payments.card.CardCommon;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BACardSection extends Sprite {
		
		private var tfColorSelected:uint = 0x2B5FAB;
		private var tfColorBase:uint = 0x22546B;
		private var tfSizeSelected:int = Config.FINGER_SIZE * .23;
		private var tfSizeBase:int = Config.FINGER_SIZE * .22;
		private var statusR:int = Config.FINGER_SIZE * .07;
		
		private var cardIconVisa:Sprite;
		private var cardIconVisaE:Sprite;
		private var cardIconMaster:Sprite;
		private var cardIconMaestro:Sprite;
		private var cardIconAmex:Sprite;
		
		protected var status:Shape;
		
		private var iconTriangle:Bitmap;
		private var iconTriangleIcon:SWFTriangleGreen;
		protected var iconCard:Sprite;
		protected var tfNumber:TextField;
		protected var tfAmount:TextField;
		protected var tfType:TextField;
		
		private var trueWidth:int;
		protected var trueHeight:int;
		
		private var data:Object;
		
		public function BACardSection() {
			iconTriangleIcon = new SWFTriangleGreen();
			var asset:BitmapData = UI.drawAssetToRoundRect(iconTriangleIcon, Config.FINGER_SIZE_DOT_5, true, "BACArdSection.swissIcon");
			iconTriangle = new Bitmap(asset);
			iconTriangle.x = -Config.FINGER_SIZE_DOT_25;
			
			tfNumber = new TextField();
			tfNumber.defaultTextFormat = new TextFormat("Tahoma", tfSizeBase, tfColorBase);
			tfNumber.multiline = false;
			tfNumber.wordWrap = false;
			tfNumber.text = "|";
			tfNumber.height = tfNumber.textHeight + 4;
			tfNumber.y = Config.MARGIN;
			addChild(tfNumber);
			
			tfAmount = new TextField();
			tfAmount.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .27);
			tfAmount.multiline = false;
			tfAmount.wordWrap = false;
			tfAmount.text = "|";
			tfAmount.height = tfAmount.textHeight + 4;
			tfAmount.x = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			tfAmount.y = int(tfNumber.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			addChild(tfAmount);
			
			tfType = new TextField();
			tfType.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .21, 0x8EA1B3);
			tfType.multiline = false;
			tfType.wordWrap = false;
			tfType.text = "|";
			tfType.height = tfType.textHeight + 4;
			addChild(tfType);
			
			status = new Shape();
			status.y = int(tfNumber.y + (tfNumber.textHeight - statusR * 2) * .5 + 2);
			addChild(status);
			
			trueHeight = tfAmount.y + tfAmount.height + Config.MARGIN;
			iconTriangle.y = int((trueHeight - iconTriangle.height) * .5);
		}
		
		public function getHeight():int {
			return trueHeight;
		}
		
		public function setData(data:Object, w:int):void {
			this.data = data;
			
			if (iconCard != null) {
				removeChild(iconCard);
				iconCard = null;
			}
			
			var cardNumber:String = data.masked.substr(0, 4) + " " + data.masked.substr(4, 4) + " " + data.masked.substr(8, 4) + " " + data.masked.substr(12);
			
			var leftX:int =  Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			
			if (MobileGui.stage.stageWidth <= 640){	
				leftX = Config.FINGER_SIZE_DOT_25 + Config.MARGIN*.5;
			}else{
				leftX = Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN - 2;
			}
			
			// short version
			if (MobileGui.stage.stageWidth <= 640){
				cardNumber =  data.masked.substr(0, 4) + " ... " + data.masked.substr(12);
			}
			tfNumber.text = (data.ordered == true) ? Lang.textOrdered + " " + cardNumber : cardNumber;
			
			var fitHeight:int = tfNumber.height;
			var ctype:String = CardCommon.getCardTypeByNumber(data.masked);
			switch (ctype) {
				case CardCommon.TYPE_VISA: {
					if (cardIconVisa == null)
						cardIconVisa = CardCommon.getCardIconByType(ctype);
					iconCard = cardIconVisa;
					fitHeight = tfNumber.textHeight * .8;
					break;
				}
				case CardCommon.TYPE_VISA_ELECTRON: {
					if (cardIconVisaE == null)
						cardIconVisaE = CardCommon.getCardIconByType(ctype);
					iconCard = cardIconVisaE;
					break;
				}
				case CardCommon.TYPE_MASTERCARD: {
					if (cardIconMaster == null)
						cardIconMaster = CardCommon.getCardIconByType(ctype);
					iconCard = cardIconMaster;
					break;
				}
				case CardCommon.TYPE_MAESTRO: {
					if (cardIconMaestro == null)
						cardIconMaestro = CardCommon.getCardIconByType(ctype);
					iconCard = cardIconMaestro;
					break;
				}
				case CardCommon.TYPE_AMEX: {
					if (cardIconAmex == null)
						cardIconAmex = CardCommon.getCardIconByType(ctype);
					iconCard = cardIconAmex;
					break;
				}
			}
			
			var numberX:int = leftX;// Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN;
			
			if (iconCard != null) {
				UI.scaleToFit(iconCard, Config.FINGER_SIZE, fitHeight);
				iconCard.y = int((tfNumber.height - iconCard.height) * .5) + Config.MARGIN;
				iconCard.x = leftX;// Config.FINGER_SIZE_DOT_25 + Config.DOUBLE_MARGIN;
				addChild(iconCard);
				numberX = iconCard.x + Config.FINGER_SIZE * .7 + Config.MARGIN - 2;
			}
			
			if (w < tfNumber.textWidth + 4)
				tfNumber.width = w;
			else
				tfNumber.width = tfNumber.textWidth + 4;
			tfNumber.x = numberX;
			
			var isLinked:Boolean = false;
			if (("linked" in data && data.linked == true) || (data.programme == "linked")) {
				isLinked = true;
				if ("ccy" in data)
				{
					tfAmount.htmlText = UI.renderCurrency(
						"",
						"",
						data.ccy,
						Config.FINGER_SIZE * .27,
						Config.FINGER_SIZE * .20
					);
				}
				else
				{
					tfAmount.htmlText = "";
				}
				
			} else {
				tfAmount.htmlText = UI.renderCurrencyAdvanced(
					data.available,
					data.currency,
					Config.FINGER_SIZE * .27,
					Config.FINGER_SIZE * .20
				);
			}
			tfAmount.x = leftX;
			tfAmount.width = tfAmount.textWidth + 4;
			if (data.programme == "virtual")
				tfType.text = Lang.TEXT_VIRTUAL.toUpperCase();
			else if (data.programme == "linked") {
				if ("bankName" in data == true) {
					tfType.text = data.bankName.substr(0, 30);
					if (tfType.text != data.bankName)
						tfType.text += "…";
				} else
					tfType.text = Lang.TEXT_LINKED.toUpperCase();
			} else
				tfType.text = Lang.TEXT_PLASTIC.toUpperCase();
			tfType.width = tfType.textWidth + 4;
			
			if (isLinked == false)
			{
				tfType.x = tfAmount.x + tfAmount.width + Config.MARGIN;
			}
			else if ("ccy" in data)
			{
				tfType.x = tfAmount.x + tfAmount.width + Config.MARGIN;
			}
			else
			{
				tfType.x = leftX;
			}
			if (BankManager.getIsCardHistory() == true && BankManager.getHistoryAccount() == data.number && MobileGui.centerScreen.currentScreenClass != BankBotChatScreen) {
				tfAmount.textColor = tfColorSelected;
				if (iconTriangle != null && iconTriangle.parent == null)
					addChild(iconTriangle);
			} else {
				tfAmount.textColor = 0;
				if (iconTriangle != null && iconTriangle.parent != null)
					removeChild(iconTriangle);
			}
			
			tfAmount.y = int(tfNumber.height + Config.FINGER_SIZE * .02) + Config.MARGIN;
			tfType.y = tfAmount.y + tfAmount.getLineMetrics(0).ascent - tfType.getLineMetrics(0).ascent;
			
			trueWidth = w;
			
			status.graphics.clear();
			if (iconCard != null) {
				if (data.status == "S" || data.status == "NL")
					status.graphics.beginFill(0xAAAAAA);
				else if (data.status == "H" || data.status == "EL" || data.status == "E")
					status.graphics.beginFill(0xFF0000);
				else if (data.status == "P")
					status.graphics.beginFill(0);
				else
					status.graphics.beginFill(0x00A200);
				status.graphics.drawCircle(statusR, statusR, statusR);
				status.graphics.endFill();
				status.x = tfNumber.x + tfNumber.textWidth + 4 + Config.MARGIN;
			}
			
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
		
		public function getTrueWidth():int {
			return Math.max(tfAmount.width, tfNumber.width);
		}
		
		public function clearGraphics():void {
			graphics.clear();
		}
		
		public function dispose():void {
			
			if (cardIconVisa != null)
			{
				UI.destroy(cardIconVisa);
				cardIconVisa = null;
			}
			if (cardIconVisaE != null)
			{
				UI.destroy(cardIconVisaE);
				cardIconVisaE = null;
			}
			if (cardIconMaster != null)
			{
				UI.destroy(cardIconMaster);
				cardIconMaster = null;
			}
			if (cardIconMaestro != null)
			{
				UI.destroy(cardIconMaestro);
				cardIconMaestro = null;
			}
			if (cardIconAmex != null)
			{
				UI.destroy(cardIconAmex);
				cardIconAmex = null;
			}
			if (status != null)
			{
				UI.destroy(status);
				status = null;
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
			if (iconCard != null)
			{
				UI.destroy(iconCard);
				iconCard = null;
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
			
			data = null;
		}
		
		public function getWidth():int {
			return trueWidth;
		}
		
		public function getData():Object {
			return data;
		}
	}
}