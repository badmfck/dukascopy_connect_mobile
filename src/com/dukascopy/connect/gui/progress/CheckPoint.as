package com.dukascopy.connect.gui.progress 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quint;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey
	 */
	public class CheckPoint extends Sprite 
	{
		
		public static const STATE_UNCHECKED:int = 0;
		public static const STATE_CURRENT:int = 1;
		public static const STATE_CHECKED:int = 2;
		
		public var index:int = -1;
		
		
		private var _currentState:int = -1;
		
		private var state:int = 0;// 0 idle, 1 - current , 2- checked <
		public var checked:Boolean = false;
		public var unchecked:Boolean = false;
		public var current:Boolean = false;
		
		private var ct:ColorTransform = new ColorTransform();
		private var bitmap:Bitmap;
		private var roundBitmap:Bitmap;
		
		private static var bgIcon:SWFStep;
		public static var SIZE:int = Config.FINGER_SIZE * .6;
		
		
		public function CheckPoint() 
		{
			super();
			//this.graphics.clear();
			//this.graphics.beginFill(0xff0000, 1);
			//this.graphics.drawCircle(0, 0, 10);
			//this.graphics.endFill();
			
			roundBitmap = new Bitmap();
			addChild(roundBitmap);
			roundBitmap.alpha = 0;
			bgIcon ||= new SWFStep();
			
			roundBitmap.bitmapData = UI.renderAsset(bgIcon, SIZE, SIZE, false);
			roundBitmap.x = - roundBitmap.width *.5;
			roundBitmap.y = - roundBitmap.height *.5;
			
				
			
		}
		
		public function setState(value:int, useAnimation:Boolean = false ):void
		{
			if (value == _currentState) return;
			_currentState = value;
			updateState(useAnimation);
			
		}
		private function resetColorTransform():void
		{
			if (ct != null) {
				ct.redMultiplier = 1;
				ct.greenMultiplier = 1;
				ct.blueMultiplier = 1;
				ct.redOffset = 0;
				ct.greenOffset = 0;
				ct.blueOffset = 0;
			}
		}
		
		public function updateState( useAnimation:Boolean = false):void
		{
			var isCurrent:Boolean =  _currentState == STATE_CURRENT;
			
			// TODO create animations for state transitions 
			var bgColor:uint = _currentState == STATE_CURRENT? 0x222533:_currentState == STATE_CHECKED?0x222533:0x78C043;
			
			var textColor:uint = _currentState == STATE_CURRENT?0xffffff:_currentState == STATE_CHECKED?0x616473:0x5cff01;
			
			var radius:int = Config.FINGER_SIZE * .2;
			var bgAlpha:Number = _currentState == STATE_CURRENT?1:0;
			roundBitmap.alpha  = bgAlpha;
			
			if (useAnimation) {
				TweenMax.killTweensOf(this);
				//roundBitmap.alpha  = bgAlpha;
				
				var hideTime:Number = isCurrent?.1: .2;
				var hideDelay:Number = isCurrent?.3: 0;
				var hideScale:Number = isCurrent?1:1;
				
				var destScale:Number = isCurrent?1:1;
				var easeType:Object = isCurrent?Back.easeOut:Back.easeInOut;
				
				
				function onHideComplete():void	{
					// redraw
					
					//if (isCurrent) {						
						//resetColorTransform();
						//roundBitmap.transform.colorTransform = ct;					
					//}else {
						//ct.color = bgColor;
						//roundBitmap.transform.colorTransform  = ct;
					//}
					
				
				}				
				
					ct.color = textColor;
					bitmap.transform.colorTransform = ct;
				TweenMax.to(this,hideTime, {scaleX:hideScale, scaleY:hideScale, onComplete:onHideComplete,delay:hideDelay, ease:Back.easeOut } );
				TweenMax.to(this, .3, {scaleX:destScale, scaleY:destScale, ease:easeType, delay:hideTime+hideDelay} );
			}else {
				TweenMax.killTweensOf(this);
				//if (isCurrent) {						
					//resetColorTransform();
					//roundBitmap.transform.colorTransform = ct;					
				//}else {
					//ct.color = bgColor;
					//roundBitmap.transform.colorTransform  = ct;
				//}
					// todo check for null 
				ct.color = textColor;
				bitmap.transform.colorTransform = ct;
					
				//roundBitmap.alpha  = bgAlpha;
			}
		}
		
		public function renderIndex():void
		{
			bitmap ||= new Bitmap();
			UI.disposeBMD(bitmap.bitmapData);
			bitmap.bitmapData = UI.renderText(index+1+"",
											Config.FINGER_SIZE * .4, 
											Config.FINGER_SIZE * .4, 
											false,
											TextFormatAlign.LEFT, 
											TextFieldAutoSize.LEFT, 
											Config.FINGER_SIZE * .34,
											false,
											0xffffff,
											0xffffff,
											true);
			addChild(bitmap);
			bitmap.x = -bitmap.width * .5;
			bitmap.y = -bitmap.height * .5;
		}
	
		public function show():void
		{
			
		}
		
		
		public function hide():void
		{
			
		}
		
		public function reset():void
		{
			
			index =-1;
			_currentState = -1;
			TweenMax.killTweensOf(this);
			this.scaleX = this.scaleY = 1;
			UI.destroy(bitmap);
			bitmap = null;
		}
		
		public function dispose():void
		{
			TweenMax.killTweensOf(this);
			UI.destroy(bitmap);
			bitmap = null;
			this.graphics.clear();	
			ct = null;
			
			UI.destroy(roundBitmap);
			roundBitmap = null;
			
			
		}
	
		
	}

}