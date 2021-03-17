package com.dukascopy.connect.screens.dialogs.paymentDialogs
{
	import assets.CoinIcon;
	import assets.WalletIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class WalletChangeInfoClip extends Sprite
	{
		private var wallet:Bitmap;
		private var amountEnd:Bitmap;
		private var amountStart:Bitmap;
		private var icon:Bitmap;
		private var difference:Bitmap;
		private var walletData:Object;
		private var itemWidth:int;
		private var differenceValue:Number;
		private var textWidth:Number;
		private var currency:String;
		private var color:uint;
		
		public function WalletChangeInfoClip()
		{
			wallet = new Bitmap();
			addChild(wallet);
			
			icon = new Bitmap();
			addChild(icon);
			
			amountStart = new Bitmap();
			addChild(amountStart);
			
			amountEnd = new Bitmap();
			addChild(amountEnd);
			
			difference = new Bitmap();
			addChild(difference);
		}
		
		public function draw(walletData:Object, differenceValue:Number, itemWidth:int):void
		{
			this.walletData = walletData;
			this.itemWidth = itemWidth;
			this.differenceValue = differenceValue;
			
			textWidth = itemWidth * .5 - Config.MARGIN * 2;
			
			if ("COIN" in walletData)
			{
				currency = walletData.COIN;
			}
			else
			{
				currency = "EUR";
			}
			
			if (differenceValue > 0)
			{
				color = 0xE6EEE0;
			}
			else
			{
				color = 0xEEDCDA;
			}
			
			drawIcon();
			drawWallet();
			drawAmountStart();
			drawAmountEnd();
			drawDifference();
			
			var r:int = Config.FINGER_SIZE * .1;
			
			graphics.beginFill(0xF0F0F0);
			graphics.drawRoundRectComplex(0, 0, itemWidth * .5, Config.FINGER_SIZE * 1, r, 0, r, 0);
			graphics.endFill();
			graphics.beginFill(color);
			graphics.drawRoundRectComplex(itemWidth * .5, 0, itemWidth * .5, Config.FINGER_SIZE * 1, 0, r, 0, r);
			graphics.endFill();
			
			icon.x = int(Config.FINGER_SIZE * .2);
			amountStart.x = int(Config.FINGER_SIZE * .2);
			wallet.x = int(icon.x + icon.width + Config.FINGER_SIZE * .2);
			difference.x = int(itemWidth - Config.FINGER_SIZE * .2 - difference.width);
			amountEnd.x = int(itemWidth - Config.FINGER_SIZE * .2 - amountEnd.width);
			
			icon.y = int(Config.FINGER_SIZE * .2);
			wallet.y = int(Config.FINGER_SIZE * .2);
			difference.y = int(Config.FINGER_SIZE * .2);
			
			amountStart.y = Config.FINGER_SIZE * .6;
			amountEnd.y = Config.FINGER_SIZE * .6;
		}
		
		private function drawDifference():void 
		{
			var currencyText:String = currency;
			if (Lang[currency] != null)
			{
				currencyText = Lang[currency];
			}
			
			var text:String = differenceValue.toString() + " " + currencyText;
			
			if (differenceValue > 0)
			{
				text = "+" + text;
			}
			
			if (differenceValue == 0)
			{
				text = "";
			}
			
			if (difference.bitmapData != null)
			{
				difference.bitmapData.dispose();
				difference.bitmapData = null;
			}
			difference.bitmapData = TextUtils.createTextFieldData(text, textWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.35, false, 0x5F6D79, color, false, true);
		}
		
		private function drawAmountEnd():void 
		{
			var value:Number = parseFloat(walletData.BALANCE) + differenceValue;
			
			var currencyText:String = currency;
			if (Lang[currency] != null)
			{
				currencyText = Lang[currency];
			}
			
			var text:String = "= " + value.toFixed(5) + " " + currencyText;
			
			if (amountEnd.bitmapData != null)
			{
				amountEnd.bitmapData.dispose();
				amountEnd.bitmapData = null;
			}
			amountEnd.bitmapData = TextUtils.createTextFieldData(text, textWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.22, false, 0x5F6D79, color, false, true);
		}
		
		private function drawAmountStart():void 
		{
			var currencyText:String = currency;
			if (Lang[currency] != null)
			{
				currencyText = Lang[currency];
			}
			
			var text:String = walletData.BALANCE.toString() + " " + currencyText;
			
			if (amountStart.bitmapData != null)
			{
				amountStart.bitmapData.dispose();
				amountStart.bitmapData = null;
			}
			amountStart.bitmapData = TextUtils.createTextFieldData(text, textWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.3, false, 0x5F6D79, 0xF0F0F0, false, true);
		}
		
		private function drawWallet():void 
		{
			var text:String = walletData.ACCOUNT_NUMBER;
			
			if (text.length > 4)
			{
				text = "**** " + text.substr(text.length - 4);
			}
			
			if (wallet.bitmapData != null)
			{
				wallet.bitmapData.dispose();
				wallet.bitmapData = null;
			}
			wallet.bitmapData = TextUtils.createTextFieldData(text, textWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.22, false, 0x8E8E8E, 0xF0F0F0, false, true);
		}
		
		private function drawIcon():void 
		{
			if (icon.bitmapData != null)
			{
				icon.bitmapData.dispose();
				icon.bitmapData = null;
			}
			
			var iconClip:Sprite;
			if ("COIN" in walletData)
			{
				iconClip = new CoinIcon;
			}
			else
			{
				iconClip = new WalletIcon();
			}
			UI.scaleToFit(iconClip, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			
			icon.bitmapData = UI.getSnapshot(iconClip);
		}
		
		public function dispose():void
		{
			graphics.clear();
			
			UI.destroy(wallet);
			UI.destroy(amountEnd);
			UI.destroy(amountStart);
			UI.destroy(icon);
			UI.destroy(difference);
			
			wallet = null;
			amountEnd = null;
			amountStart = null;
			icon = null;
			difference = null;
		}
	}
}