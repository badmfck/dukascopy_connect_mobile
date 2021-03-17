package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.screens.payments.card.CardCommon;
	import com.dukascopy.connect.screens.payments.card.CardStatic;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.langs.Lang;
	import com.telefision.shapes.BlikBox;
	import com.telefision.shapes.PatternShapeBox;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListPayCardAdvanced extends BaseRenderer implements IListPayCardAdvanced {
		
		//private var tfLabel:TextField;
		//private var tfStatus:TextField;
		//private var tfInteger:TextField;
		private var tfFraction:TextField;
		private var tfCurrency:TextField;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		private var innerPadding:int = Config.FINGER_SIZE * .5;
		
		private var itemHeight:int = Config.FINGER_SIZE * 4;
		//private var format:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .42);
		
		private var tfLabelY0:int;
		private var tfLabelY1:int;
		private var fontSizeX:int = 26;
		private var roundBg:PatternShapeBox;
		private var bgOverlay:BlikBox;
		private static var BMD:BitmapData = Assets.getAsset(Assets.BG_CARD);
		private static var BMD_LIGHT:BitmapData = Assets.getAsset(Assets.BG_CARD_LIGHT);
		private static var BMD_RED:BitmapData = Assets.getAsset(Assets.BG_CARD_RED);
		
		private var cardTitleCanvas:Bitmap;
		private var cardNumberCanvas:Bitmap;
		private var cardCurencyCanvas:Bitmap;
		private var cardValidUntilCanvas:Bitmap;
		private var cardValidTitleCanvas:Bitmap;
		//private var cvvCanvas:Bitmap;
		private var balanceCanvas:Bitmap;
		private var logoCanvas:Bitmap;
		private var dcLogoCanvas:Bitmap;
		
		private static var dcLogoBlack:SWFDCCardLogoBlack;
		private static var dcLogoWhite:SWFDCCardLogoWhite;
		
		
		// TODO make card size by the smallest edge of viewport  
		// card proportions 85x53
		public function ListPayCardAdvanced() {
			roundBg = new PatternShapeBox(BMD, width, itemHeight);
			bgOverlay = new BlikBox(0xcccccc, width, itemHeight);
			bgOverlay.alpha = .21;
			roundBg.radius = Config.FINGER_SIZE * .3;
			//bgOverlay.radius = Config.FINGER_SIZE * .3;			
			addChild(roundBg);
			addChild(bgOverlay);
			
			var hh:int = Config.FINGER_SIZE * .9;
			fontSizeX = hh * .7 - Config.MARGIN * 2;
			tfLabelY1 = Math.round((itemHeight - (fontSizeX + fontSizeX + 8)) * .5);

			
			cardTitleCanvas = new Bitmap();
			cardNumberCanvas = new Bitmap();
			cardCurencyCanvas = new Bitmap();
			cardValidUntilCanvas = new Bitmap();
			cardValidTitleCanvas = new Bitmap();
			//cvvCanvas = new Bitmap();
			balanceCanvas = new Bitmap();
			logoCanvas = new Bitmap();
			//logoCanvas.bitmapData = Assets.getAsset(Assets.PAYMENT_ICON_MASTERCARD);			
			//logoCanvas.bitmapData = Assets.getAsset(Assets.PAYMENT_ICON_VISA);
			
			dcLogoCanvas = new Bitmap();
			cardTitleCanvas.y = int(tfLabelY1 - fontSizeX - 10);
			
			addChild(dcLogoCanvas);
			addChild(logoCanvas);
			addChild(cardTitleCanvas);
			addChild(cardNumberCanvas);
			addChild(cardValidTitleCanvas);
			addChild(cardValidUntilCanvas);
			//addChild(cvvCanvas);
			addChild(cardCurencyCanvas);
			addChild(balanceCanvas);
		
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var data:Object = li.data;
			
			graphics.clear();
			
			// NUMBER 
			cardNumberCanvas.y = tfLabelY1;
			cardNumberCanvas.x = padding + innerPadding;
			if (cardNumberCanvas.bitmapData != null) {
				cardNumberCanvas.bitmapData.dispose();
				cardNumberCanvas.bitmapData = null;
			}
			
			UI.disposeBMD(cardNumberCanvas.bitmapData);
			UI.disposeBMD(cardTitleCanvas.bitmapData);
			UI.disposeBMD(cardValidTitleCanvas.bitmapData);
			UI.disposeBMD(cardValidUntilCanvas.bitmapData);
			UI.disposeBMD(balanceCanvas.bitmapData);
			UI.disposeBMD(cardCurencyCanvas.bitmapData);
			//UI.disposeBMD(cvvCanvas.bitmapData);
			UI.disposeBMD(logoCanvas.bitmapData);
			UI.disposeBMD(dcLogoCanvas.bitmapData);
			
			
			// TITLE 
			cardTitleCanvas.x = padding + innerPadding;
			cardTitleCanvas.y = int(tfLabelY1 - fontSizeX - 10);
			
			var balance:String = data.available!=null? data.available: "";
			//var cardType:String = ("type" in data)? data.type.toLowerCase(): Lang.TEXT_MY_CARDS;
			var cardType:String = ("programme" in data)? data.programme.toLowerCase(): Lang.TEXT_MY_CARDS;
			//var accountNumber:String = data.number; 
			//var accountNumber:String =  ("masked" in data) ? data.masked : ("number" in data) ? data.number: "XXX";
			var accountNumber:String =  ("number" in data &&  data.number!=null) ? data.number:("masked" in data &&  data.masked!=null) ? data.masked :  "XXX";
			var formatedAccountNumber:String = accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8, 4) + " " + accountNumber.substr(12);
			
			var FONT_COLOR:uint = cardType == "virtual" ?  0x000000:0xffffff;
			var FONT_SHADOW_COLOR:uint = cardType == "virtual" ? 0xe1e1e1  : 0x000000;
			var logoAsset:DisplayObject = cardType == "virtual" ? getBlackLogoAsset() : getWhiteLogoAsset();
			var BG_BMD:BitmapData =cardType == "virtual" ?  BMD_LIGHT:  BMD;
			if (cardType=="plastic"){
				FONT_COLOR = 0xffffff ;
				FONT_SHADOW_COLOR = 0x4e1717;
				logoAsset = getWhiteLogoAsset();
				BG_BMD =  BMD_RED;
			}
			
			//trace("CARD TYPE ===>>>>"+cardType);
			cardNumberCanvas.bitmapData = UI.renderTextShadowed(formatedAccountNumber, width - (padding + innerPadding) * 2, fontSizeX + 6, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX + 6, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true);
			cardTitleCanvas.bitmapData = UI.renderTextShadowed(data.status_name + " " + cardType+ " card", width - (padding + innerPadding) * 2, fontSizeX, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true);
			
			// Valid until or created Date if orderd
			var createTime:String = data.created;
			var validThruTitle:String = data.status == CardStatic.STATUS_ORDERED?"ORDER DATE:\n"+createTime:"VALID\nTHRU";
			cardValidTitleCanvas.bitmapData = UI.renderTextShadowed(validThruTitle, (padding + innerPadding) * 2, fontSizeX * .45, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX * .45, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true);
			cardValidTitleCanvas.x = padding + innerPadding + fontSizeX * .1;
			cardValidTitleCanvas.y = cardNumberCanvas.y + cardNumberCanvas.height;
			
			
			cardValidUntilCanvas.bitmapData = UI.renderTextShadowed("valid" in data ? data.valid: "", (padding + innerPadding) * 2, fontSizeX, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true);
			cardValidUntilCanvas.y = cardValidTitleCanvas.y - fontSizeX * .1;
			//cardValidUntilCanvas.x = padding + innerPadding; 
			cardValidUntilCanvas.x = cardValidTitleCanvas.x + cardValidTitleCanvas.width + fontSizeX * .5;
			
			// balance+
			balanceCanvas.bitmapData = UI.renderTextShadowed(balance, width - (padding + innerPadding) * 2, fontSizeX, false, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true, -2);
			balanceCanvas.x = padding + innerPadding;
			balanceCanvas.y = itemHeight - padding - innerPadding - balanceCanvas.height;
			
			// currency 
			cardCurencyCanvas.bitmapData = UI.renderTextShadowed("currency" in data ? data.currency : "ccy" in data ? data.ccy: "" , width - (padding + innerPadding) * 2, fontSizeX, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true, -2);
			cardCurencyCanvas.x = balanceCanvas.x + balanceCanvas.width; // innerPadding; 
			cardCurencyCanvas.y = itemHeight - padding - innerPadding - cardCurencyCanvas.height;
			
			// cvv
			//if (!("showCVV" in data)) {
				data.showCVV = false;
			//}
			
		
			//if (cardType == "virtual card") {
				//var cvvString:String = data.showCVV ? " " + (data.code ? data.code:"") + " " : " cvv ";
				//cvvCanvas.bitmapData = UI.renderTextShadowed(cvvString, width - (padding + innerPadding) * 2, fontSizeX, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, 0xffffff, 0xeeeeee, 0x000000, false, -2);
				//cvvCanvas.x = width - padding - innerPadding - cvvCanvas.width;
				//cvvCanvas.y = cardTitleCanvas.y;
			//} else {
				//cvvCanvas.bitmapData = null;
			//}
			
			//logo			
			logoCanvas.bitmapData = CardCommon.getBitmapDataCardByNumberCard(accountNumber);
			logoCanvas.x = width - padding * 2 - logoCanvas.width;
			logoCanvas.y = itemHeight - padding * 2 - logoCanvas.height;
			
			//dcLogoCanvas
			// TODO create mechanism for allowing later remove asset instead of creating new in each list item every time
			dcLogoCanvas.bitmapData = UI.renderAsset(logoAsset, width * .6 - padding * 2,Config.FINGER_SIZE*2, true, "ListPayCardAdvanced.dcLogoCanvas");
			dcLogoCanvas.x = padding + innerPadding; // width - padding * 2 - dcLogoCanvas.width;
			dcLogoCanvas.y = padding;
			
			// background 
			roundBg.x = padding;
			roundBg.width = width - padding * 2;
			roundBg.height = itemHeight - padding;						
			roundBg.bitmapData = BG_BMD;// cardType == "virtual" ?  BMD_LIGHT:  BMD;
			
			// overlay 
			bgOverlay.x = padding;
			bgOverlay.width = width - padding * 2;
			bgOverlay.height = itemHeight - padding;
			bgOverlay.visible = cardType == "virtual" ? true : false;
			
			// hit zones
			var offsetBounds:int = 20; // to make hitzone bigger for tap
			
			//var hitZones:Array = [{type: HitZoneType.CVV, x: cvvCanvas.x - offsetBounds, y: cvvCanvas.y - offsetBounds, width: cvvCanvas.width + offsetBounds * 2, height: cvvCanvas.height + offsetBounds * 2}];
			//li.setHitZones(hitZones);
			
			return this;
		}
		
		
		
		public function fillWithData(data:Object, width:int,  highlight:Boolean = false):void {
			graphics.clear();
			
			var verticaPadding:int = padding;
			//padding = 0;
			
			// NUMBER 
			cardNumberCanvas.y = tfLabelY1;
			cardNumberCanvas.x =  innerPadding;
			if (cardNumberCanvas.bitmapData != null) {
				cardNumberCanvas.bitmapData.dispose();
				cardNumberCanvas.bitmapData = null;
			}
			
			// TITLE 
			cardTitleCanvas.x =  innerPadding;
			cardTitleCanvas.y = int(tfLabelY1 - fontSizeX - 10);
			
			var balance:String = data.available!=null? data.available : "";
			//var cardType:String = ("type" in data)? data.type.toLowerCase(): Lang.TEXT_MY_CARDS;
			var cardType:String = ("programme" in data)? data.programme.toLowerCase(): Lang.TEXT_MY_CARDS;
			//var accountNumber:String ="";
			//var formatedAccountNumber:String= "";
			 //if("number" in data){
				 //accountNumber = data.number;
				 //formatedAccountNumber = accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8, 4) + " " + accountNumber.substr(12)
			 //}
			var accountNumber:String =  ("number" in data &&  data.number!=null) ? data.number:("masked" in data &&  data.masked!=null) ? data.masked :  "XXX";
			//var accountNumber:String =  ("number" in data ) ? data.number:("masked" in data) ? data.masked :  "XXX";
			var formatedAccountNumber:String = accountNumber.substr(0, 4) + " " + accountNumber.substr(4, 4) + " " + accountNumber.substr(8, 4) + " " + accountNumber.substr(12);
		
			//var FONT_COLOR:uint = cardType == "virtual card" ?  0x000000:0xffffff;
			//var FONT_SHADOW_COLOR:uint = cardType == "virtual card" ? 0xe1e1e1  : 0x000000;
			//var logoAsset:DisplayObject = cardType == "virtual card" ? getBlackLogoAsset() : getWhiteLogoAsset();
			
			var FONT_COLOR:uint = cardType == "virtual" ?  0x000000:0xffffff;
			var FONT_SHADOW_COLOR:uint = cardType == "virtual" ? 0xe1e1e1  : 0x000000;
			var logoAsset:DisplayObject = cardType == "virtual" ? getBlackLogoAsset() : getWhiteLogoAsset();
			var BG_BMD:BitmapData =cardType == "virtual" ?  BMD_LIGHT:  BMD;
			if (cardType == "plastic"){
				FONT_COLOR =0xffffff ;
				FONT_SHADOW_COLOR = 0x4e1717;
				logoAsset = getWhiteLogoAsset();
				BG_BMD =  BMD_RED;
			}
			
			UI.disposeBMD(cardNumberCanvas.bitmapData);
			UI.disposeBMD(cardTitleCanvas.bitmapData);
			UI.disposeBMD(cardValidTitleCanvas.bitmapData);
			UI.disposeBMD(cardValidUntilCanvas.bitmapData);
			UI.disposeBMD(balanceCanvas.bitmapData);
			UI.disposeBMD(cardCurencyCanvas.bitmapData);
			//UI.disposeBMD(cvvCanvas.bitmapData);
			UI.disposeBMD(logoCanvas.bitmapData);
			UI.disposeBMD(dcLogoCanvas.bitmapData);
			
			//trace("CARD TYPE ===>>>>"+cardType);
			cardNumberCanvas.bitmapData = UI.renderTextShadowed(formatedAccountNumber, width - ( innerPadding) * 2, fontSizeX + 6, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX + 6, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true);
			cardTitleCanvas.bitmapData = UI.renderTextShadowed(data.status_name + " " + cardType +" card", width - ( innerPadding) * 2, fontSizeX, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true);
			
			// Valid until 
			var createTime:String = data.created;
			var validThruTitle:String = data.status == CardStatic.STATUS_ORDERED?"ORDER DATE:\n"+createTime:"VALID\nTHRU";			
			cardValidTitleCanvas.bitmapData = UI.renderTextShadowed(validThruTitle, ( innerPadding) * 2, fontSizeX * .45, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX * .45, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true);
			cardValidTitleCanvas.x =  innerPadding + fontSizeX * .1;
			cardValidTitleCanvas.y = cardNumberCanvas.y + cardNumberCanvas.height;
			
			cardValidUntilCanvas.bitmapData = UI.renderTextShadowed("valid" in data ? data.valid: "", ( innerPadding) * 2, fontSizeX, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true);
			cardValidUntilCanvas.y = cardValidTitleCanvas.y - fontSizeX * .1;
			//cardValidUntilCanvas.x = padding + innerPadding; 
			cardValidUntilCanvas.x = cardValidTitleCanvas.x + cardValidTitleCanvas.width + fontSizeX * .5;
			
			// balance+
			balanceCanvas.bitmapData = UI.renderTextShadowed(balance, width - ( innerPadding) * 2, fontSizeX, false, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true, -2);
			balanceCanvas.x =  innerPadding;
			balanceCanvas.y = itemHeight - verticaPadding - innerPadding - balanceCanvas.height;
			
			// currency 
			cardCurencyCanvas.bitmapData = UI.renderTextShadowed("currency" in data ? data.currency : "ccy" in data ? data.ccy: "", width - (innerPadding) * 2, fontSizeX, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, FONT_SHADOW_COLOR, FONT_SHADOW_COLOR, FONT_COLOR, true, -2);
			cardCurencyCanvas.x = balanceCanvas.x + balanceCanvas.width; // innerPadding; 
			cardCurencyCanvas.y = itemHeight - verticaPadding - innerPadding - cardCurencyCanvas.height;
			
			// cvv
			//if (!("showCVV" in data)) {
				data.showCVV = false;
			//}
			
			//if (cardType == "virtual card") {
				//var cvvString:String = data.showCVV ? " " + data.code + " " : " cvv ";
				//cvvCanvas.bitmapData = UI.renderTextShadowed(cvvString, width - ( innerPadding) * 2, fontSizeX, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSizeX, false, 0xffffff, 0xeeeeee, 0x000000, false, -2);
				//cvvCanvas.x = width -  innerPadding - cvvCanvas.width;
				//cvvCanvas.y = cardTitleCanvas.y;
			//} else {
				//cvvCanvas.bitmapData = null;
			//}
			
			//logo	VISA - MASTERCARD - VISA ELECTRON - MAESTRO
			logoCanvas.bitmapData = CardCommon.getBitmapDataCardByNumberCard(accountNumber);
			logoCanvas.x = width - verticaPadding * 2 - logoCanvas.width;
			logoCanvas.y = itemHeight - verticaPadding * 2 - logoCanvas.height;

			
			//dcLogoCanvas
			// TODO create mechanism for allowing later remove asset instead of creating new in each list item every time
			dcLogoCanvas.bitmapData = UI.renderAsset(logoAsset, width * .6 ,Config.FINGER_SIZE*2, true, "ListPayCardAdvanced.dcLogoCanvas");
			dcLogoCanvas.x =  innerPadding; // width - padding * 2 - dcLogoCanvas.width;
			dcLogoCanvas.y = verticaPadding;
			
			// background 
			roundBg.x = 0;// padding;
			roundBg.width = width;
			roundBg.height = itemHeight - verticaPadding;
			roundBg.bitmapData = BG_BMD;// cardType == "virtual" ?  BMD_LIGHT:  BMD;
			
			// overlay 
			bgOverlay.x = padding;
			bgOverlay.width = width;
			bgOverlay.height = itemHeight - verticaPadding;
			bgOverlay.visible = cardType == "virtual" ? true : false;
		}
		
		
		
		private function getBlackLogoAsset():DisplayObject 	{
			if (dcLogoBlack == null) {
				dcLogoBlack = new SWFDCCardLogoBlack();
			}
			return dcLogoBlack;			
		}
		
		
		private function getWhiteLogoAsset():DisplayObject	{
			if (dcLogoWhite == null) {
				dcLogoWhite = new SWFDCCardLogoWhite();
			}
			return dcLogoWhite;
		}
		
		public function dispose():void {
			graphics.clear();
			//trace("\nDISPOES CARD ITEM >>>> *******************>>>  ");
			if (roundBg) {
				roundBg.graphics.clear();
				UI.safeRemoveChild(roundBg);
				roundBg = null;
			}
			
			if (bgOverlay) {
				bgOverlay.graphics.clear();
				UI.safeRemoveChild(bgOverlay);
				bgOverlay = null;
			}
		
			UI.destroy(cardNumberCanvas);
			cardNumberCanvas = null;
			
			UI.destroy(cardTitleCanvas);
			cardTitleCanvas = null;
			
			UI.destroy(cardValidTitleCanvas);
			cardValidTitleCanvas = null;
			
			UI.destroy(cardValidUntilCanvas);
			cardValidUntilCanvas = null;
			
			UI.destroy(cardCurencyCanvas);
			cardCurencyCanvas = null;
			
			//UI.destroy(cvvCanvas);
			//cvvCanvas = null;
			
			UI.destroy(balanceCanvas);
			balanceCanvas = null;
			
			UI.destroy(logoCanvas);
			logoCanvas = null;
			
			UI.destroy(dcLogoCanvas);
			dcLogoCanvas = null;		
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}