package com.dukascopy.connect.gui.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BubbleButton extends BitmapButton
	{
		private var back:Sprite;
		private var backColor:Number = 0xffffff;
		
		private var textColor:uint = 0x0051ca;
		private var bgColor:uint = 0xc4def1;
		private var borderColor:uint = 0x0051ca;
		private var borderThickness:int = 2;
		private var bgOpacity:Number = 1;
		private var borderRadius:Number = Config.FINGER_SIZE_DOT_25;
		private var vPadding:int = Config.MARGIN;
		private var hPadding:int = Config.MARGIN * 2;
		private var textAlign:String  =  TextFormatAlign.LEFT;
		
		public function BubbleButton() 
		{
			
		}
		public function setParams(_textColor:uint = 0x0051ca, _bgColor:uint = 0xffffff, _bgOpacity:Number = 0.1, _borderColor:uint = 0x0051ca, _borderThickness:int = 1, _textAlign:String =  TextFormatAlign.LEFT):void{
			textColor = _textColor;
			bgColor = _bgColor;
			borderColor= _borderColor;
			borderThickness= _borderThickness;
			bgOpacity = _bgOpacity;
			textAlign = _textAlign;
		}
		
		override public function createView():void
		{
			super.createView();
			//back = new Sprite();
			//addChild(back);
		}
		
		
		public function setText(txt:String, w:int):void
		{
			//var tempBmd:BitmapData =  UI.renderTextPlane(txt , w, 8, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.28, true, 0x0051ca, 0x9cd0fa, 0x9cd0fa, 0, Config.DOUBLE_MARGIN, Config.FINGER_SIZE_DOT_25,null,false,true);
			var tempBmd:BitmapData =  UI.renderTextPlane(txt , w, 8, true, textAlign, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.28, true, textColor,bgColor, borderColor, borderRadius,borderThickness, hPadding,vPadding,null,false,true);
			super.setBitmapData(tempBmd, true, true);
		}
		
		
		
		
		//override public function setBitmapData(bmd:BitmapData, disposePrevious:Boolean = false, autoHitzone:Boolean = true, _fitToWidth:int = -1):void
		//{
			
		
			//super.setBitmapData(tempBmd, disposePrevious, autoHitzone);
			
			//iconBitmap.x = Config.MARGIN;
			//iconBitmap.y = Config.MARGIN;
			
			//back.graphics.clear();
			//back.graphics.beginFill(backColor);
			//if(_fitToWidth==-1){
				//back.graphics.drawRoundRect(0, 0, bmd.width + Config.MARGIN * 2, bmd.height + Config.MARGIN * 2, Config.MARGIN * 2, Config.MARGIN * 2);
				//back.x = -Config.MARGIN;
				//back.y = -Config.MARGIN;				
			//}else{
				//back.graphics.drawRect(0, 0, _fitToWidth, bmd.height + Config.MARGIN * 2);
				//back.x = 0;
				//back.y = 0;
				//
				//
			//}
			//setChildIndex(back, 0);
			
		
		//}
		
		override public function dispose():void
		{
			super.dispose();
			//if (back)
			//{
				//UI.destroy(back);
				//back = null;
			//}
		}
	}
}