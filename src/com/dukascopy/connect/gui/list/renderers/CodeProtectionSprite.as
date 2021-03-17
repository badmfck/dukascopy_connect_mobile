package com.dukascopy.connect.gui.list.renderers 
{
	import assets.Llockicon2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CodeProtectionSprite extends Sprite
	{
		protected const FONT_SIZE_NORMAL:int = Config.FINGER_SIZE * .29;
		private var textFormat:TextFormat;
		private var icon:assets.Llockicon2;
		protected var textField:TextField;
		private var itemWidth:int;
		
		public function setText(value:String, color:Number):void 
		{
			update(color);
		}
		
		private function update(color:Number):void 
		{
			textField.x = int(icon.width + Config.FINGER_SIZE * .15);
			
			textField.width = itemWidth - textField.x;
			textField.text = Lang.enterProtectionCode;
			textField.textColor = color;
			textField.height = textField.textHeight + 4;
			icon.y = int(textField.y + textField.height*.5 - icon.height*.5);
		}
		
		public function CodeProtectionSprite(itemWidth:int) 
		{
			this.itemWidth = itemWidth;
			textFormat = new TextFormat();
			textFormat.font = "Tahoma";
			textFormat.size = FONT_SIZE_NORMAL;
			textFormat.align = TextFormatAlign.LEFT;
			textFormat.color = 0xCD3E44;
			
			textField = new TextField();
			textField.defaultTextFormat = textFormat;
			textField.multiline = true;
			textField.wordWrap = true;
			addChild(textField);
			
			icon = new Llockicon2();
			UI.colorize(icon, 0xCD3E44);
			UI.scaleToFit(icon, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			addChild(icon);
		}
		
		public function dispose():void 
		{
			textFormat = null;
			
			UI.destroy(textField);
			textField = null;
			
			UI.destroy(icon);
			icon = null;
			
			UI.destroy(this);
		}
		
		public function getHeight():int 
		{
			return textField.y + textField.height;
		}
	}
}