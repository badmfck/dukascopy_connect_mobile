package com.dukascopy.connect.gui.chat 
{
	import assets.LinkIcon2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.presets.Color;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin

	 */
	public class BotLinkItem extends Sprite 
	{
		
		private var _text:String;
		private var _bgColor:uint = Color.GREY_SUPER_LIGHT;
		private var _viewWidth:int = 100;
		
		private var textFormat:TextFormat;
		private var textField:TextField;
		
		private var _isDisposed:Boolean = false;
		private var _isCreated:Boolean = false;
		private var RADIUS:Number = Config.FINGER_SIZE * 0.2;
		
		private var PADDING:Number = Math.ceil(Config.FINGER_SIZE * .03);
		private var PADDING_V:Number = Math.ceil(Config.FINGER_SIZE * .02);
		
		private static var _instancesCount:int  = 0;
		private var vTextMargin:Number;
		private var icon:LinkIcon2;
		
		public function BotLinkItem() {
			
			PADDING = Math.ceil(Config.FINGER_SIZE * .1);
			_instancesCount ++;
			icon = new LinkIcon2();
			addChild(icon);
			UI.scaleToFit(icon, Config.FINGER_SIZE * .19, Config.FINGER_SIZE * .19);
		}
		
		public function create(width:int, text:String):void
		{
			if (_isDisposed) return;			
			_isCreated = true;
			_viewWidth  = width;		
			_text = text;		
			setupTextField();
			
			updateViewPort();
		}
		
		private function setupTextField():void
		{
			var fontSize:int = Config.FINGER_SIZE * .24;
			if (fontSize < 9)
				fontSize = 9;
			
			textFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = fontSize;		
			textFormat.align = TextFormatAlign.LEFT;
			
			textField ||= new TextField();
			textField.defaultTextFormat = textFormat;
			textField.text = "";
			textField.wordWrap = true;
			textField.multiline = true;
			textField.mouseEnabled = false;
			textField.textColor  = Color.GREY;
			//textField.border = true;
			textField.autoSize = TextFieldAutoSize.LEFT;
			addChild(textField);
		}
		
		public function setSize(width:int):void {
			_viewWidth = width;
			updateViewPort();
		}
		
		private function updateViewPort():void
		{
			textField.x = PADDING;
			textField.width = _viewWidth - PADDING * 3 - icon.width;
			textField.height = 4;
			textField.text = _text;
			textField.width = textField.textWidth + 6;
			textField.y = PADDING_V;
			
			UI.drawRoundRect(this.graphics, _bgColor, textField.width + PADDING * 3 + icon.width, textField.height + PADDING_V * 2, RADIUS, RADIUS, RADIUS, RADIUS, 0, 0x000);
			icon.x = int(textField.width + PADDING * 2 - Config.FINGER_SIZE * .05);
			icon.y = int(textField.y + textField.height * .5 - icon.height * .5);
		}
		
		public function dispose():void {
			if (_isDisposed) return;
			_isDisposed = true;
			if (textField != null){
				textField.text = "";
				UI.safeRemoveChild(textField);
				textField = null;
			}
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			textFormat = null;
			UI.destroy(this);
			
			_instancesCount --;
		}
		
		public function get viewHeight():int {
			return textField.height + PADDING_V * 2;
		}
	}
}