package com.dukascopy.connect.gui.list.renderers.chatMessageElements
{
	import assets.LinksIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UrlClip extends Sprite
	{
		private var linkIcon:LinksIcon;
		private var padding:int;
		private var textField:TextField;
		private var disposed:Boolean;
		
		public function UrlClip()
		{
			create();
		}
		
		private function create():void
		{
			var tf:TextFormat = new TextFormat();
			tf.font = Config.defaultFontName;
			tf.color = 0x3498DB;
			tf.size = int(Config.FINGER_SIZE * .28);
			
			textField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = tf;
			textField.multiline = true;
			textField.wordWrap = true;
			addChild(textField);
			
			linkIcon = new LinksIcon();
			padding = Config.FINGER_SIZE * .16;
			UI.scaleToFit(linkIcon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .25);
			addChild(linkIcon);
			linkIcon.x = padding;
			linkIcon.y = padding * 1.1;
			
			textField.x = padding * 2 + linkIcon.width;
			textField.y = int(padding * .7);
		}
		
		public function draw(text:String, width:int, backgroundColor:Number = 0xE7F0FF):void
		{
			if (disposed == true)
			{
				return;
			}
			
			if (text == null)
			{
				ApplicationErrors.add();
				return;
			}
			
			textField.text = "";
			textField.width = width - padding * 3 - linkIcon.width;
			textField.height = textField.textHeight + 4;
			
			textField.text = text;
			textField.height = textField.textHeight + 4;
			textField.width = textField.textWidth + 4;
			textField.selectable = false;
			textField.mouseEnabled = false;
			
			graphics.clear();
			graphics.beginFill(backgroundColor);
			graphics.drawRoundRect(0, 0, textField.width + padding * 3 + linkIcon.width, int(Math.max(textField.height + padding * .7 * 2, linkIcon.height + padding * 2 * 1.1)), Config.FINGER_SIZE * .2);
			graphics.endFill();
		}
		
		public function dispose():void
		{
			disposed = true;
			
			if (linkIcon != null)
			{
				UI.destroy(linkIcon);
				linkIcon = null;
			}
			if (textField != null)
			{
				UI.destroy(textField);
				textField = null;
			}
			graphics.clear();
		}
	}
}