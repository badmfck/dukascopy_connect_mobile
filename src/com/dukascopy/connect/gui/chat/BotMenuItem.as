package com.dukascopy.connect.gui.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey Skuryat

	 */
	public class BotMenuItem extends Sprite 
	{
		
		private var _text:String;
		private var _bgColor:uint = 0xff0000;
		private var _viewWidth:int = 100;
		private var _viewHeight:int = 40;
		
		private	var tl:int = 0;
		private	var tr:int = 0;
		private	var bl:int = 0;
		private	var br:int = 0;
		private var isFirst:Boolean = false;
		private var isLast:Boolean = false;
			
		private var textFormat:TextFormat;
		private var textField:TextField;

		private var _isDisposed:Boolean = false;
		private var _isCreated:Boolean = false;
		//private var RADIUS:Number = Math.ceil(Config.FINGER_SIZE * .2);
		private var RADIUS:Number = Config.FINGER_SIZE / 2.5;
		
		//private var RADIUS:Number = Math.ceil(Config.FINGER_SIZE * .1);
		private var PADDING:Number = Math.ceil(Config.FINGER_SIZE * .25);
		//private var PADDING:Number = Math.ceil(Config.FINGER_SIZE * .35);
		
		
		private static var _instancesCount:int  = 0;
		private var vTextMargin:Number;
		
		private var _disabled:Boolean = false;
		private var lineHeight:Number = 1;
		
		public function BotMenuItem() {
			
			PADDING = Math.ceil(Config.FINGER_SIZE * .22);
			_instancesCount ++;
			
			lineHeight = Config.FINGER_SIZE * .03;
			if (lineHeight == 0)
				lineHeight = 1;
				
			//trace("BotMenuItems count---> "+_instancesCount);
			
		}
		
		
		public function create(width:int, height:int, text:String, bgColor:uint = 0xff0000, topRouded:Boolean = false, bottomRounded:Boolean = false, isDisabled:Boolean = false):void
		{
			if (_isDisposed) return;			
			_isCreated = true;
			_disabled = isDisabled;
			_viewWidth  = width;
			_viewHeight  = height;			
			_text = text;
			_bgColor = bgColor;			
			setupTextField();
			
			var opacity:Number = _disabled? .4:1; 
			var opacityLine:Number = _disabled? .02:.1; 
			
			textField.alpha = opacity;
			textField.x = PADDING;
			textField.width = _viewWidth-PADDING*2;
			textField.height = 4;
			textField.text = _text;			
			//if (textField.height > _viewHeight){			
			textField.y = PADDING;
			_viewHeight = textField.height + PADDING * 2;
				
			//}else{
				//textField.y = (_viewHeight - textField.height) * .5;
			//}
			
			isFirst = topRouded;
			isLast = bottomRounded;
			tl = topRouded?RADIUS:0;
			tr = topRouded?RADIUS:0;
			bl = bottomRounded?RADIUS:0;
			br = bottomRounded?RADIUS:0;			
			
			
			UI.drawRoundRect(this.graphics, _bgColor, _viewWidth, _viewHeight, tl, tr, bl, br, 0, 0x000, opacity);
			//UI.drawRoundRect(this.graphics, _bgColor, _viewWidth, _viewHeight, tl, tr, bl, br, 0, 0x000,1);
			
			if (isFirst && isLast) return;// we have only one item in menu
			if (!isFirst ){
				//this.graphics.clear();
				//this.graphics.beginFill(0xe2eff8, 1);
				//this.graphics.beginFill(0xe8e8e8, opacity);
				this.graphics.beginFill(0x000000, opacityLine);
				this.graphics.drawRect(0, 0, _viewWidth, lineHeight);
				this.graphics.endFill();
			}
		}
		
		
		
		private function setupTextField():void
		{
			//var fontSize:int = Math.ceil(Config.FINGER_SIZE * .28);
			var fontSize:int = Config.FINGER_SIZE * .26;
			if (fontSize < 9)
				fontSize = 9;
				
				
			textFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = fontSize;		
			textFormat.align = TextFormatAlign.CENTER;
			
			textField ||= new TextField();
			textField.defaultTextFormat = textFormat;
			textField.text = "";
			textField.wordWrap = true;
			textField.multiline = true;
			textField.mouseEnabled = false;
			textField.textColor  = 0xcd3f43;
			//textField.border = true;
			textField.autoSize = TextFieldAutoSize.CENTER;
			addChild(textField);
		}
		
		
		
		public function setSize(width:int, height:int):void {
			if (_viewWidth == width && _viewHeight == height){
				_viewWidth = width;
				_viewHeight = height;
				updateViewPort();
			}
		}
		
		private function updateViewPort():void
		{
			var opacity:Number = _disabled? .4:1; 
			var opacityLine:Number = _disabled? .02:.1; 
				textField.alpha = opacity;
				textField.text = _text;				
				textField.x = PADDING;
				textField.width = _viewWidth-PADDING*2;
				textField.height = 4;
				
				//if (textField.height > _viewHeight){
					textField.y = PADDING;
					_viewHeight = textField.height + PADDING*2;
				//}else{
					//textField.y = (_viewHeight - textField.height) * .5;
				//}
			
				
				UI.drawRoundRect(this.graphics, _bgColor, _viewWidth, _viewHeight, tl, tr, bl, br, 0, 0x000,opacity);
				if (isFirst && isLast) return;// we have only one item in menu
				
				if(!isFirst){
					//this.graphics.clear();
					//this.graphics.beginFill(0xe2eff8, 1);
					//this.graphics.beginFill(0xe8e8e8, opacity);
					this.graphics.beginFill(0x000000,opacityLine);
					this.graphics.drawRect(0, 0, _viewWidth, lineHeight);
					this.graphics.endFill();
				}
		}
		
		
		public function dispose():void {
			if (_isDisposed) return;
			_isDisposed = true;
			if (textField != null){
				textField.text = "";
				UI.safeRemoveChild(textField);
				textField = null;
			}			
			textFormat = null;
			UI.destroy(this);
			
			_instancesCount --;
			//trace("BotMenuItems count destroy---> "+_instancesCount);
			// TODO kill all stuff
		}
		
		public function get viewHeight():int {
			return _viewHeight;
		}
		
		public function set disabled(value:Boolean):void {
			_disabled = value;
			updateViewPort();			
		}
	}

}