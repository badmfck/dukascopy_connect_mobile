package com.dukascopy.connect.gui.components.ratesPanel 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RatePanelItem extends Sprite
	{
		private var textField:TextField;
		private var icon:Sprite;
		private var iconSize:int;
		
		public function RatePanelItem() 
		{
			iconSize = Config.FINGER_SIZE * .3;
		}
		
		public function draw(escrowInstrument:EscrowInstrument, itemHeight:int):Bitmap 
		{
			if (textField == null)
			{
				textField = new TextField();
				addChild(textField);
				var tf:TextFormat = new TextFormat();
				tf.size = FontSize.CAPTION_1;
				tf.color = Style.color(Style.COLOR_BACKGROUND);
				tf.font = Config.defaultFontName;
				textField.defaultTextFormat = tf;
				textField.multiline = false;
				textField.wordWrap = false;
				textField.text = "T/W";
				textField.height = textField.textHeight + 4;
				textField.text = "";
			}
			if (icon != null)
			{
				UI.destroy(icon);
				if (contains(icon))
				{
					removeChild(icon);
				}
				icon = null;
			}
			var iconClass:Class = UI.getCryptoIconClass(escrowInstrument.code);
			if (iconClass != null)
			{
				icon = new iconClass() as Sprite;
			}
			var position:int = 0;
			if (icon != null)
			{
				UI.scaleToFit(icon, iconSize, iconSize);
				addChild(icon);
				icon.y = int(itemHeight * .5 - icon.height * .5);
				position += icon.x + icon.width + Config.FINGER_SIZE * .12;
			}
			
			var padding:int = 1;
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, width + padding * 2, height + padding * 2);
			
			textField.x = position;
			
			var code:String = escrowInstrument.code;
			if (Lang[code] != null)
			{
				code = Lang[code];
			}
			var price:String;
			if (escrowInstrument.price != null && escrowInstrument.price.length > 0)
			{
				price = escrowInstrument.price[0].name + " " + escrowInstrument.price[0].value.toString();
			}
			textField.text = code + "/" + price;
			textField.width = textField.textWidth + 4;
			textField.y = int(itemHeight * .5 - textField.height * .5);
			
			icon.y += padding;
			icon.x += padding;
			textField.x += padding;
			textField.y += padding;
			
			var bitmap:Bitmap = new Bitmap(null, PixelSnapping.ALWAYS, true);
			var bd:BitmapData = new BitmapData(this.width, this.height, false, Style.color(Style.COLOR_ACCENT_PANEL));
			bd.drawWithQuality(this, null, null, null, null, false, StageQuality.BEST);
			bitmap.bitmapData = bd;
			return bitmap;
		}
	}
}