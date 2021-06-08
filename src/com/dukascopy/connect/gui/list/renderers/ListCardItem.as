package com.dukascopy.connect.gui.list.renderers {
	
	import assets.LinksIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections.BACardSection;
	import com.dukascopy.connect.screens.payments.card.CardCommon;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	
	public class ListCardItem extends ListPayWalletItem implements IListRenderer{
		
		private var cardIconVisa:Sprite;
		private var cardIconVisaE:Sprite;
		private var cardIconMaster:Sprite;
		private var cardIconMaestro:Sprite;
		private var cardIconAmex:Sprite;
		private var status:Shape;
		private var type:TextField;
		
		public function ListCardItem() {
			super();
			
			status = new Shape();
			addChild(status);
			
			format.size = FontSize.CAPTION_1;
			type = new TextField();
			type.autoSize = TextFieldAutoSize.LEFT;
			type.defaultTextFormat = format;
			type.text = "Pp";
			type.multiline = false;
			type.wordWrap = false;
			type.x = ICON_SIZE + padding * 2;
			type.textColor = Style.color(Style.COLOR_SUBTITLE);
			addChild(type);
			
			label.y = int(itemHeight * .5 - label.height - Config.FINGER_SIZE * .00);
			type.y =  int(itemHeight * .5 + Config.FINGER_SIZE * .00);
		}
		
		override protected function getAccountText(data:Object):String 
		{
			var result:String;
			var cardNumber:String = "";
			
			if ("masked" in data && data.masked != null)
			{
			//	cardNumber = data.masked.substr(0, 4) + " " + data.masked.substr(4, 4) + " " + data.masked.substr(8, 4) + " " + data.masked.substr(12);
				cardNumber = data.masked.substr(0, 4) + " .... " + data.masked.substr(12);
			}
			else if ("number" in data && data.number != null && data.number is String)
			{
			//	cardNumber = data.number.substr(0, 4) + " " + data.number.substr(4, 4) + " " + data.number.substr(8, 4) + " " + data.number.substr(12);
				cardNumber = data.number.substr(0, 4) + " .... " + data.number.substr(12);
			}
			
			if ("ordered" in data && data.ordered == true)
			{
				result = Lang.textOrdered + " " + cardNumber;
			}
			else
			{
				result = cardNumber;
			}
			
			return result;
		}
		
		override protected function getCurrencyText(data:Object):String 
		{
			var result:String;
			
			if ("currency" in data)
			{
				result = data.currency;
			}
			else if ("ccy" in data && data.ccy != null)
			{
				result = data.ccy;
			}
			
			return result;
		}
		
		override protected function getAmountText(data:Object):String 
		{
			var result:String;
			var balanceNum:Number = NaN;
			if ("available" in data && data.available != null)
			{
				var balance:String = data.available;
				balanceNum = Number(balance);
				if (balance == "0")
				{
					balance = "0.0";
				}
				
				var baseSize:Number = FontSize.TITLE_2;
				var captionSize:Number = FontSize.SUBHEAD;
				var color:String = "#" + Style.color(Style.COLOR_TEXT).toString(16);
				if (balanceNum == Math.round(balanceNum))
				{
					result = "<font color='" + color + "' size='" + baseSize + "'>" + balance + "</font>";
				}
				else
				{
					result = "<font color='" + color + "' size='" + baseSize + "'>" + balance.substring(0, balance.indexOf(".")) + "</font>" + "<font color='" + color + "' size='" + captionSize + "'>" + balance.substr(balance.indexOf(".")) + "</font>";
				}
			}
			
			if ("programme" in data && data.programme == "linked" && (isNaN(balanceNum) || balanceNum == 0))
			{
				result = null;
			}
			
			return result;
		}
		
		override protected function getIcon(data:Object):Sprite 
		{
			var result:Sprite;
			
			var number:String;
			if ("masked" in data)
			{
				number = data.masked;
			}
			else if ("number" in data)
			{
				number = data.number;
			}
			
			var ctype:String = CardCommon.getCardTypeByNumber(number);
			
			switch (ctype) {
				case CardCommon.TYPE_VISA: {
					if (cardIconVisa == null)
						cardIconVisa = CardCommon.getCardIconByType(ctype);
					result = cardIconVisa;
					break;
				}
				case CardCommon.TYPE_VISA_ELECTRON: {
					if (cardIconVisaE == null)
						cardIconVisaE = CardCommon.getCardIconByType(ctype);
					result = cardIconVisaE;
					break;
				}
				case CardCommon.TYPE_MASTERCARD: {
					if (cardIconMaster == null)
						cardIconMaster = CardCommon.getCardIconByType(ctype);
					result = cardIconMaster;
					break;
				}
				case CardCommon.TYPE_MAESTRO: {
					if (cardIconMaestro == null)
						cardIconMaestro = CardCommon.getCardIconByType(ctype);
					result = cardIconMaestro;
					break;
				}
				case CardCommon.TYPE_AMEX: {
					if (cardIconAmex == null)
						cardIconAmex = CardCommon.getCardIconByType(ctype);
					result = cardIconAmex;
					break;
				}
			}
			
			return result;
		}
		
		override public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			super.getView(li, h, width, highlight);
			
			drawType(li.data);
			drawStatus(li.data);
			
			status.x = int(label.x + label.textWidth + 4 + Config.MARGIN);
			status.y = int(label.y + label.height * .5 - status.height * .5);
			
			return this;
		}
		
		private function drawType(data:Object):void 
		{
			var text:String = "";
			if ("programme" in data)
			{
				if (data.programme == "virtual")
					text = Lang.TEXT_VIRTUAL.toUpperCase();
				else if (data.programme == "linked")
				{
					if ("bankName" in data && data.bankName != null && data.bankName != "")
					{
						text = data.bankName;
					}
					else
					{
						text = Lang.TEXT_LINKED.toUpperCase();
					}
				}
				else
					text = Lang.TEXT_PLASTIC.toUpperCase();
			}
			
			type.text = text;
		}
		
		private function drawStatus(data:Object):void 
		{
			status.graphics.clear();
			if ("status" in data && data.status != null)
			{
				var statusR:int = Config.FINGER_SIZE * .07;
				if (data.status == "S" || data.status == "NL")
					status.graphics.beginFill(Style.color(Style.CONTROL_INACTIVE));
				else if (data.status == "H" || data.status == "EL" || data.status == "E")
					status.graphics.beginFill(Color.RED);
				else if (data.status == "P")
					status.graphics.beginFill(Style.color(Style.COLOR_TEXT));
				else
					status.graphics.beginFill(Color.GREEN);
				status.graphics.drawCircle(statusR, statusR, statusR);
				status.graphics.endFill();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
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
			if (type != null)
			{
				UI.destroy(type);
				type = null;
			}
		}
	}
}