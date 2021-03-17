package com.dukascopy.connect.screens.roadMap 
{
	import assets.CardIllustration;
	import assets.MastercardClip;
	import assets.TypePlastic;
	import assets.TypeVirtual;
	import assets.VisaClipWhite;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
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
	public class CardClip extends Sprite
	{
		static public const TYPE_VISA:String = "typeVisa";
		static public const TYPE_MASTERCARD:String = "typeMastercard";
		
		static public const TYPE_VIRTUAL:String = "virtual";
		static public const TYPE_PLASTIC:String = "plastic";
		
		private var card:CardIllustration;
		private var padding:int;
		private var typeClip:Sprite;
		private var typeVirtualClip:Bitmap;
		private var currencyClip:Bitmap;
		private var valid:Bitmap;
		
		public function CardClip(itemWidth:int) 
		{
			padding = Config.DIALOG_MARGIN;
			card = new CardIllustration();
			UI.scaleToFit(card, itemWidth - padding * 2, Config.FINGER_SIZE * 20);
			addChild(card);
			card.x = padding;
			card.y = padding;
			
			graphics.beginFill(Style.color(Style.COLOR_SEPARATOR));
			graphics.drawRect(0, 0, itemWidth, card.height + padding * 2);
			graphics.endFill();
			
			currencyClip = new Bitmap();
			addChild(currencyClip);
			
			drawTexts();
		}
		
		private function drawTexts():void 
		{
			valid = new Bitmap();
			valid.smoothing = true;
			addChild(valid);
			if (Lang.textValidThru != null)
			{
				drawText(valid, Lang.textValidThru.toUpperCase());
			}
			valid.x = int(card.x + card.width * .088);
			valid.y = int(card.y + card.height * .73);
			valid.alpha = 0.5;
		}
		
		public function setCurrency(currency:String):void
		{
			if (currencyClip.bitmapData != null)
			{
				currencyClip.bitmapData.dispose();
				currencyClip.bitmapData = null;
			}
			currencyClip.bitmapData = TextUtils.createTextFieldData(currency, Config.FINGER_SIZE * 2, 10, 
																	false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .33, false, Color.WHITE, 0x650401, true);
			currencyClip.x = int(card.x + card.width - Config.FINGER_SIZE * .4 - currencyClip.width);
			currencyClip.y = int(card.y + Config.FINGER_SIZE * .4);
		}
		
		public function setType(type:String):void
		{
			if (typeClip != null)
			{
				if (contains(typeClip))
				{
					removeChild(typeClip);
				}
				UI.destroy(typeClip);
				typeClip = null;
			}
			switch(type)
			{
				case TYPE_VISA:
				{
					typeClip = new VisaClipWhite();
					UI.scaleToFit(typeClip, card.width * .23, Config.FINGER_SIZE * 45);
					break;
				}
				case TYPE_MASTERCARD:
				{
					typeClip = new MastercardClip();
					UI.scaleToFit(typeClip, card.width * .23, Config.FINGER_SIZE * 3);
					break;
				}
			}
			if (typeClip != null)
			{
				
				addChild(typeClip);
				typeClip.x = int(card.x + card.width - Config.FINGER_SIZE * .4 - typeClip.width);
				typeClip.y = int(card.y + card.height - Config.FINGER_SIZE * .45 - typeClip.height);
			}
		}
		
		public function dispose():void
		{
			graphics.clear();
			if (card != null)
			{
				UI.destroy(card);
				card = null;
			}
			if (typeClip != null)
			{
				UI.destroy(typeClip);
				typeClip = null;
			}
			if (typeVirtualClip != null)
			{
				UI.destroy(typeVirtualClip);
				typeVirtualClip = null;
			}
			if (currencyClip != null)
			{
				UI.destroy(currencyClip);
				currencyClip = null;
			}
			if (valid != null)
			{
				UI.destroy(valid);
				valid = null;
			}
		}
		
		public function setVirtualType(type:String):void 
		{
			if (typeVirtualClip != null)
			{
				if (contains(typeVirtualClip))
				{
					removeChild(typeVirtualClip);
				}
				UI.destroy(typeVirtualClip);
				typeVirtualClip = null;
			}
			switch(type)
			{
				case TYPE_VIRTUAL:
				{
					typeVirtualClip = new Bitmap();
					if (Lang.virtual != null)
					{
						drawText(typeVirtualClip, Lang.virtual.toUpperCase());
					}
					
					UI.scaleToFit(typeVirtualClip, Config.FINGER_SIZE * 4, Config.FINGER_SIZE * .14);
					break;
				}
				case TYPE_PLASTIC:
				{
					typeVirtualClip = new Bitmap();
					if (Lang.plastic != null)
					{
						drawText(typeVirtualClip, Lang.plastic.toUpperCase());
					}
					
					UI.scaleToFit(typeVirtualClip, Config.FINGER_SIZE * 4, Config.FINGER_SIZE * .14);
					break;
				}
			}
			if (typeVirtualClip != null)
			{
				typeVirtualClip.smoothing = true;
				addChild(typeVirtualClip);
				typeVirtualClip.x = int(card.x + card.width * .09);
				typeVirtualClip.y = int(card.y + card.height * .33);
			}
		}
		
		private function drawText(target:Bitmap, text:String):void 
		{
			target.bitmapData = TextUtils.createTextFieldData(text, Config.FINGER_SIZE * 2, 10, 
																	false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .22, false, Color.WHITE, 0xE27D80, true);
		}
	}
}