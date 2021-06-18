package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Alexey
	 */
	public class ListPayWalletItem extends BaseRenderer implements IListRenderer{
		
		protected var label:TextField;
		protected var walletName:TextField;
		private var amount:TextField;
		private var currency:TextField;
		protected var padding:int = Config.FINGER_SIZE * .2;
		protected var itemHeight:int = Config.FINGER_SIZE;
		protected var ICON_SIZE:int = Config.FINGER_SIZE * .5;
		protected var format:TextFormat=new TextFormat(Config.defaultFontName, FontSize.BODY, Style.color(Style.COLOR_TEXT));
		private var icon:Bitmap;
		
		public function ListPayWalletItem() {
			
			icon = new Bitmap();
			
			format.size = FontSize.CAPTION_1;
			label = new TextField();
			label.autoSize = TextFieldAutoSize.LEFT;
			label.defaultTextFormat = format;
			label.text = "Pp";
			label.multiline = false;
			label.wordWrap = false;
			label.x = ICON_SIZE + padding * 2;
			label.textColor = Style.color(Style.COLOR_SUBTITLE);
			label.y = Math.round((itemHeight - label.textHeight) * .5);
			
			format.size = FontSize.SUBHEAD;
			walletName = new TextField();
			walletName.autoSize = TextFieldAutoSize.LEFT;
			walletName.defaultTextFormat = format;
			walletName.text = "Pp";
			walletName.multiline = false;
			walletName.wordWrap = false;
			walletName.x = ICON_SIZE + padding * 2;
			walletName.textColor = Style.color(Style.COLOR_TEXT);
			walletName.y = Math.round((itemHeight - walletName.textHeight) * .5);
			
			format.size = FontSize.TITLE_2;
			format.bold = false;
			amount = new TextField();
			amount.autoSize = TextFieldAutoSize.LEFT;
			amount.defaultTextFormat = format;
			amount.text = "Pp";
			amount.multiline = false;
			amount.wordWrap = false;
			amount.y = Math.round((itemHeight - amount.textHeight) * .5);
			amount.textColor = Style.color(Style.COLOR_TEXT)
			
			format.bold = false;
			format.size = FontSize.TITLE_2;
			currency = new TextField();
			currency.autoSize = TextFieldAutoSize.LEFT;
			currency.defaultTextFormat = format;
			currency.text = "Pp";
			currency.multiline = false;
			currency.wordWrap = false;
			currency.textColor = Style.color(Style.COLOR_TEXT);
			currency.y = Math.round((itemHeight - currency.textHeight) * .5);
			
			addChild(icon);
			addChild(label);
			addChild(amount);
			addChild(currency);
			addChild(walletName);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, w:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = li.data;
			
			drawBack(highlight, h, w);
			drawIcon(li.data);
			drawAmount(li.data);
			drawAccount(li.data);
			drawName(li.data);
			
			position(w);
			
			return this;
		}
		
		private function drawName(data:Object):void 
		{
			var text:String = getAccountName(data);
			if (text != null) {
				walletName.text = text;
			} else {
				walletName.text = "";
			}
		}
		
		protected function getAccountName(data:Object):String 
		{
			var result:String;
			if ("TYPE" in data && data.TYPE != null && Lang.otherAccTypes[data.TYPE] != null)
			{
				result = Lang.otherAccTypes[data.TYPE];
			}
			return result;
		}
		
		private function position(w:int):void 
		{
			currency.x = (w - Config.DOUBLE_MARGIN - currency.width);
			amount.x = int(currency.x - amount.width - Config.FINGER_SIZE * .2);
			
			label.width = w - label.x - padding * 2 - ICON_SIZE;
			
			if (label.x + label.width > amount.x) {
				label.visible = false;			
			}else {
				label.visible = true;
			}
			
			if (walletName.text == "")
			{
				label.y = Math.round((itemHeight - label.textHeight) * .5);
			}
			else
			{
				walletName.y = Math.round(itemHeight * .5 - walletName.height - Config.FINGER_SIZE * .02);
				label.y = Math.round(itemHeight * .5 + Config.FINGER_SIZE * .02);
			}
		}
		
		protected function drawAccount(data:Object):void {
			var text:String = getAccountText(data);
			if (text != null) {
				label.text = text;
			} else {
				label.text = "";
			}
		}
		
		protected function getAccountText(data:Object):String {
			var result:String;
			var accountNumber:String = data.ACCOUNT_NUMBER;
			var accountDescrition:String = data.DESCRIPTION;
			if (data.IBAN != null && getAccountName(data) == null) {
				if ("IBAN" in data)
				{
					accountNumber  = data.IBAN;
				}
				else if ("ADDRESS" in data)
				{
					accountNumber  = data.ADDRESS;
				}
				else
				{
					accountNumber = "**** **** ****";
				}
			//	result = accountNumber.substr(0, 4) + "...." + accountNumber.substr(accountNumber.length - 4, 4);
				result = accountNumber;
			} else {
				result = accountNumber;
				
				/*if (accountNumber != null && accountNumber.length > 3) {
					result = "**** " + accountNumber.substr(8);
				} else {
					if (accountNumber != null)
					{
						result = accountNumber;
					}
					else
					{
						result = "";
					}
				}*/
			}
			/*if (getAccountName(data) != null)
			{
				if (result != null && result.length > 3)
				{
					result = result.substr(0, result.length - 3);
				}
			}*/
			return result;
		}
		
		private function drawAmount(data:Object):void {
			var textAmount:String = getAmountText(data);
			var textCurrency:String = getCurrencyText(data);
			
			if (textAmount != null) {
				amount.htmlText = textAmount;
			}
			else
			{
				amount.text = "";
			}
			
			if (textCurrency != null)
			{
				currency.text = textCurrency;
			}
			else
			{
				currency.text = "";
			}
		}
		
		protected function getCurrencyText(data:Object):String 
		{
			var currency:String = getCurrency(data);
			
			var currencyText:String = currency;
			if (Lang[currencyText] != null)
			{
				currencyText = Lang[currencyText];
			}
			return currencyText;
		}
		
		private function getCurrency(data:Object):String 
		{
			var result:String;
			if ("CURRENCY" in data)
			{
				result = data.CURRENCY;
			}
			else if ("COIN" in data)
			{
				result = data.COIN;
			}
			return result;
		}
		
		protected function getAmountText(data:Object):String 
		{
			var result:String;
			
			if ("BALANCE" in data && data.BALANCE != null)
			{
				var balance:String = data.BALANCE;
				var baseSize:Number = FontSize.TITLE_2;
				var captionSize:Number = FontSize.SUBHEAD;
				var color:String = "#" + Style.color(Style.COLOR_TEXT).toString(16);
				
				if (!isNaN(parseFloat(balance)))
				{
					balance = parseFloat(balance).toString()
				}
				
				if (balance.indexOf(".") != -1)
				{
					result = "<font color='" + color + "' size='" + baseSize + "'>" + balance.substring(0, balance.indexOf(".")) + "</font>" + "<font color='" + color + "' size='" + captionSize + "'>" + balance.substr(balance.indexOf(".")) + "</font>";
				}
				else
				{
					result = "<font color='" + color + "' size='" + baseSize + "'>" + balance + "</font>";
				}
			}
			
			return result;
		}
		
		private function drawBack(highlight:Boolean, h:int, w:int):void 
		{
			graphics.clear();
			
			if (highlight) {
				graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
				graphics.drawRect(0, 0, w, h);
				graphics.endFill();
			}
			
			graphics.beginFill(Style.color(Style.COLOR_LINE_SSL));
			graphics.drawRect(0, itemHeight - 1, w, 1);
			graphics.endFill();
		}
		
		private function drawIcon(data:Object):void 
		{
			var iconSource:Sprite = getIcon(data);
			if (iconSource != null)
			{
				icon.bitmapData = UI.renderAsset(iconSource, ICON_SIZE, ICON_SIZE, false, "ListPayWalletItem.flagIcon");
				icon.x = padding;
				icon.y = (itemHeight - icon.height) * .5;
			}
			else
			{
				icon.bitmapData = null;
			}
		}
		
		protected function getIcon(data:Object):Sprite 
		{
			var flagAsset:Sprite = UI.getFlagByCurrency(getCurrency(data));
			UI.disposeBMD(icon.bitmapData);
			return flagAsset;
		}
		
		public function dispose():void {
			graphics.clear();
			
			UI.destroy(icon);
			icon = null;
			if (label != null)
				label.text = "";
			label = null;
			if (amount != null)
				amount.text = "";
			amount = null;
			if (currency != null)
				currency.text = "";
			currency = null;
			if (walletName != null)
				walletName.text = "";
			walletName = null;
			format = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}