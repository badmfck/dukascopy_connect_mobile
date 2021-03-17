package com.dukascopy.connect.screens.dialogs.bottom {
	
	import assets.FreeCoinsIcon;
	import assets.NewCopyIcon;
	import assets.ReservedCoinsIcon;
	import assets.TotalCoinsIcon;
	import com.d_project.qrcode.ErrorCorrectLevel;
	import com.d_project.qrcode.QRCode;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.SaveImageAction;
	import com.dukascopy.connect.gui.components.QRCodeImage;
	import com.dukascopy.connect.gui.components.WhiteToastSmall;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.IBitmapProvider;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CoinsBalancePopup extends BottomPopup {
		
		private var totalCoinsIcon:Bitmap;
		private var reservedCoinsIcon:Bitmap;
		private var freeCoinsIcon:Bitmap;
		
		private var coinsText_1:Bitmap;
		private var coinsText_2:Bitmap;
		private var coinsText_3:Bitmap;
		
		private var moneyText_1:Bitmap;
		private var moneyText_2:Bitmap;
		private var moneyText_3:Bitmap;
		
		private var totalCoins:Bitmap;
		private var reservedCoins:Bitmap;
		private var freeCoins:Bitmap;
		
		private var totalMoney:Bitmap;
		private var reservedMoney:Bitmap;
		private var freeMoney:Bitmap;
		
		private var coinsOrders:Bitmap;
		private var moneyOrders:Bitmap;
		
		private var totalText:Bitmap;
		private var reservedText:Bitmap;
		private var freeText:Bitmap;
		
		private var closeButton:BitmapButton;
		private var iconSize:int;
		private var startPosition:int;
		
		public function CoinsBalancePopup() { }
		
		override protected function createView():void {
			super.createView();
			
			totalText = new Bitmap();
			container.addChild(totalText);
			
			reservedText = new Bitmap();
			container.addChild(reservedText);
			
			freeText = new Bitmap();
			container.addChild(freeText);
			
			coinsOrders = new Bitmap();
			container.addChild(coinsOrders);
			
			moneyOrders = new Bitmap();
			container.addChild(moneyOrders);
			
			totalCoins = new Bitmap();
			container.addChild(totalCoins);
			
			reservedCoins = new Bitmap();
			container.addChild(reservedCoins);
			
			freeCoins = new Bitmap();
			container.addChild(freeCoins);
			
			totalMoney = new Bitmap();
			container.addChild(totalMoney);
			
			reservedMoney = new Bitmap();
			container.addChild(reservedMoney);
			
			freeMoney = new Bitmap();
			container.addChild(freeMoney);
			
			totalCoinsIcon = new Bitmap();
			container.addChild(totalCoinsIcon);
			
			reservedCoinsIcon = new Bitmap();
			container.addChild(reservedCoinsIcon);
			
			freeCoinsIcon = new Bitmap();
			container.addChild(freeCoinsIcon);
			
			coinsText_1 = new Bitmap();
			container.addChild(coinsText_1);
			
			coinsText_2 = new Bitmap();
			container.addChild(coinsText_2);
			
			coinsText_3 = new Bitmap();
			container.addChild(coinsText_3);
			
			moneyText_1 = new Bitmap();
			container.addChild(moneyText_1);
			
			moneyText_2 = new Bitmap();
			container.addChild(moneyText_2);
			
			moneyText_3 = new Bitmap();
			container.addChild(moneyText_3);
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.setDownColor(NaN);
			closeButton.setDownScale(1);
			closeButton.setOverlay(HitZoneType.BUTTON);
			closeButton.cancelOnVerticalMovement = true;
			closeButton.tapCallback = onButtonCloseClick;
			container.addChild(closeButton);
			
			iconSize = Config.FINGER_SIZE * .85;
			var icon:Sprite = new TotalCoinsIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			totalCoinsIcon.bitmapData = UI.getSnapshot(UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS)));
			UI.destroy(icon);
			
			icon = new ReservedCoinsIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			reservedCoinsIcon.bitmapData = UI.getSnapshot(UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS)));
			UI.destroy(icon);
			
			icon = new FreeCoinsIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			freeCoinsIcon.bitmapData = UI.getSnapshot(UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS)));
			UI.destroy(icon);
		}
		
		override protected function getHeight():int 
		{
			return startPosition + container.height + Config.FINGER_SIZE * .4 + Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function onButtonCloseClick():void 
		{
			close();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			var sellSum:Number = 0;
			var buySum:Number = 0;
			var moneyBalance:Number = 0;
			var coinBalance:Number = 0;
			var moneyOrdersNum:int = 0;
			var coinOrders:int = 0;
			
			if (data != null)
			{
				if ("sellSum" in data)
				{
					sellSum = data.sellSum;
				}
				if ("buySum" in data)
				{
					buySum = data.buySum;
				}
				if ("moneyBalance" in data)
				{
					moneyBalance = data.moneyBalance;
				}
				if ("coinBalance" in data)
				{
					coinBalance = data.coinBalance;
				}
				if ("moneyOrders" in data)
				{
					moneyOrdersNum = data.moneyOrders;
				}
				if ("coinOrders" in data)
				{
					coinOrders = data.coinOrders;
				}
			}
			
			drawCloseButton();
			
			totalText.bitmapData = TextUtils.createTextFieldData(Lang.textTotal, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			reservedText.bitmapData = TextUtils.createTextFieldData(Lang.textReserved, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			freeText.bitmapData = TextUtils.createTextFieldData(Lang.textFree, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			coinsText_1.bitmapData = TextUtils.createTextFieldData(Lang.textDukascoin, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			coinsText_2.bitmapData = TextUtils.createTextFieldData(Lang.textDukascoin, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			coinsText_3.bitmapData = TextUtils.createTextFieldData(Lang.textDukascoin, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			moneyText_1.bitmapData = TextUtils.createTextFieldData(Lang.textEuro, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			moneyText_2.bitmapData = TextUtils.createTextFieldData(Lang.textEuro, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			moneyText_3.bitmapData = TextUtils.createTextFieldData(Lang.textEuro, _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			totalCoins.bitmapData = TextUtils.createTextFieldData(formatNum(coinBalance, 4), _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			reservedCoins.bitmapData = TextUtils.createTextFieldData(formatNum(sellSum, 4), _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			freeCoins.bitmapData = TextUtils.createTextFieldData(formatNum(coinBalance - sellSum, 4), _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			totalMoney.bitmapData = TextUtils.createTextFieldData(formatNum(moneyBalance, 2), _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			reservedMoney.bitmapData = TextUtils.createTextFieldData(formatNum(buySum, 2), _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			freeMoney.bitmapData = TextUtils.createTextFieldData(formatNum(moneyBalance - buySum, 2), _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			coinsOrders.bitmapData = TextUtils.createTextFieldData(getOrdersText(coinOrders), _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			moneyOrders.bitmapData = TextUtils.createTextFieldData(getOrdersText(moneyOrdersNum), _width*.3, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
													
			
			var iconDistance:int = (_width - iconSize * 3) / 5;
			
			startPosition = Config.FINGER_SIZE * .4;
			var position:int = startPosition;
			
			totalCoinsIcon.y = position;
			reservedCoinsIcon.y = position;
			freeCoinsIcon.y = position;
			
			totalCoinsIcon.x = iconDistance;
			reservedCoinsIcon.x = int(_width * .5 - reservedCoinsIcon.width * .5);
			freeCoinsIcon.x = _width - iconDistance - iconSize;
			
			position += iconSize + Config.FINGER_SIZE * .03;
			
			totalText.y = position;
			reservedText.y = position;
			freeText.y = position;
			
			totalText.x = int(totalCoinsIcon.x + totalCoinsIcon.width * .5 - totalText.width * .5);
			reservedText.x = int(reservedCoinsIcon.x + reservedCoinsIcon.width * .5 - reservedText.width * .5);
			freeText.x = int(freeCoinsIcon.x + freeCoinsIcon.width * .5 - freeText.width * .5);
			
			position += Math.max(totalText.height, reservedText.height, freeText.height) + Config.FINGER_SIZE * .45;
			
			coinsText_1.y = position;
			coinsText_2.y = position;
			coinsText_3.y = position;
			position += coinsText_1.height + Config.FINGER_SIZE * .2;
			
			totalCoins.y = position;
			reservedCoins.y = position;
			freeCoins.y = position;
			
			position += Math.max(totalCoins.height, reservedCoins.height, freeCoins.height) + Config.FINGER_SIZE * .1;
			
			coinsOrders.y = position;
			position += coinsOrders.height + Config.FINGER_SIZE * .4;
			
			moneyText_1.y = position;
			moneyText_2.y = position;
			moneyText_3.y = position;
			position += moneyText_1.height + Config.FINGER_SIZE * .2;
			
			totalMoney.y = position;
			reservedMoney.y = position;
			freeMoney.y = position;
			
			position += Math.max(totalMoney.height, reservedMoney.height, freeMoney.height) + Config.FINGER_SIZE * .1;
			
			moneyOrders.y = position;
			position += moneyOrders.height + Config.FINGER_SIZE * .45;
			
			closeButton.y = position;
			closeButton.x = int(_width * .5 - closeButton.width * .5);
			
			var firstColumnWidth:int = Math.max(moneyText_1.width, coinsText_1.width, totalCoins.width, totalMoney.width);
			var positionX:int = Math.max(Config.DIALOG_MARGIN, iconSize * .5 + iconDistance - firstColumnWidth * .5);
			
			moneyText_1.x = positionX;
			coinsText_1.x = positionX;
			totalCoins.x = positionX;
			totalMoney.x = positionX;
			
			reservedCoins.x = int(_width * .5 - reservedCoins.width * .5);
			reservedMoney.x = int(_width * .5 - reservedMoney.width * .5);
			
			reservedCoins.x = reservedMoney.x = Math.min(reservedCoins.x, reservedMoney.x);
			moneyText_2.x = coinsText_2.x = coinsOrders.x = moneyOrders.x = reservedCoins.x;
			
		//	coinsOrders.x = int(_width * .5 - coinsOrders.width * .5);
		//	moneyOrders.x = int(_width * .5 - moneyOrders.width * .5);
			
			freeCoins.x = Math.min(_width - iconSize * .5 - iconDistance - freeCoins.width * .5, _width - freeCoins.width - Config.DIALOG_MARGIN);
			freeMoney.x = Math.min(_width - iconSize * .5 - iconDistance - freeMoney.width * .5, _width - freeMoney.width - Config.DIALOG_MARGIN);
			
			freeCoins.x = freeMoney.x = Math.min(freeCoins.x, freeMoney.x);
			moneyText_3.x = coinsText_3.x = freeCoins.x;
		}
		
		private function getOrdersText(value:int):String 
		{
			return value.toString() + " " + Lang.textOrders;
		}
		
		private function formatNum(value:Number, decimals:int):String 
		{
			var realPart:String = (Math.floor(value)).toString();
			var decimalPart:String = (value - Math.floor(value)).toPrecision(decimals);
			decimalPart = decimalPart.slice(decimalPart.indexOf("."));
			if (decimalPart.length < decimals)
			{
				while (decimalPart.length < decimals)
				{
					decimalPart += "0";
				}
			}
			var result:String = realPart;
			
			return realPart += "<font size='" + FontSize.BODY*.7 + "'>" + decimalPart + "</font>";
		}
		
		private function drawCloseButton():void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textOk, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_LIGHT), -1, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			closeButton.setBitmapData(buttonBitmap, true);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			closeButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			closeButton.deactivate();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (totalCoinsIcon != null)
			{
				UI.destroy(totalCoinsIcon);
				totalCoinsIcon = null;
			}
			if (reservedCoinsIcon != null)
			{
				UI.destroy(reservedCoinsIcon);
				reservedCoinsIcon = null;
			}
			if (freeCoinsIcon != null)
			{
				UI.destroy(freeCoinsIcon);
				freeCoinsIcon = null;
			}
			if (coinsText_1 != null)
			{
				UI.destroy(coinsText_1);
				coinsText_1 = null;
			}
			if (coinsText_2 != null)
			{
				UI.destroy(coinsText_2);
				coinsText_2 = null;
			}
			if (coinsText_3 != null)
			{
				UI.destroy(coinsText_3);
				coinsText_3 = null;
			}
			if (moneyText_1 != null)
			{
				UI.destroy(moneyText_1);
				moneyText_1 = null;
			}
			if (moneyText_2 != null)
			{
				UI.destroy(moneyText_2);
				moneyText_2 = null;
			}
			if (moneyText_3 != null)
			{
				UI.destroy(moneyText_3);
				moneyText_3 = null;
			}
			if (totalCoins != null)
			{
				UI.destroy(totalCoins);
				totalCoins = null;
			}
			if (reservedCoins != null)
			{
				UI.destroy(reservedCoins);
				reservedCoins = null;
			}
			if (freeCoins != null)
			{
				UI.destroy(freeCoins);
				freeCoins = null;
			}
			if (totalMoney != null)
			{
				UI.destroy(totalMoney);
				totalMoney = null;
			}
			if (reservedMoney != null)
			{
				UI.destroy(reservedMoney);
				reservedMoney = null;
			}
			if (freeMoney != null)
			{
				UI.destroy(freeMoney);
				freeMoney = null;
			}
			if (coinsOrders != null)
			{
				UI.destroy(coinsOrders);
				coinsOrders = null;
			}
			if (moneyOrders != null)
			{
				UI.destroy(moneyOrders);
				moneyOrders = null;
			}
			if (totalText != null)
			{
				UI.destroy(totalText);
				totalText = null;
			}
			if (reservedText != null)
			{
				UI.destroy(reservedText);
				reservedText = null;
			}
			if (freeText != null)
			{
				UI.destroy(freeText);
				freeText = null;
			}
			if (closeButton != null)
			{
				closeButton.dispose();
				closeButton = null;
			}
		}
	}
}