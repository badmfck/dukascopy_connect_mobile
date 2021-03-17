package com.dukascopy.connect.gui.menuVideo 
{
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.shapes.BorderBox;
	import com.dukascopy.connect.gui.shapes.Box;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.ScrollRectPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TransformMatrixPlugin;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Alexey
	 */
	public class OnAirButton extends Sprite 
	{
		
		// sizes viewport to fit toggler
		private var _viewWidth:int = 280;
		private var _viewHeight:int = 200;
		
		// Backgrounds
		private var bgGreen:Bitmap = new Bitmap();
		private var bgRed:Bitmap = new Bitmap();
		private var togglerHolder:Sprite = new Sprite();
		
		// togler pins
		private var PIN_ON_BMD:BitmapData;
		private var PIN_OFF_BMD:BitmapData;		
		private var pinIcon:Bitmap = new Bitmap();
		
		// states
		static public const STATE_ON:int = 1;
		static public const STATE_OFF:int = 0;
		private var _state:int = 0;
		
		
		private var borderOffset:int = 5;
		private var _isActive:Boolean = false;
		public var tapCallback:Function;		
		private var _isDisposed:Boolean = false;
		
		/**
		 * @CONSTRUCTOR
		 */
		public function OnAirButton() {
			this.mouseChildren = false;
		
		}		
		
		private function createDesign():void {

			// green state bitmap 	
			bgGreen = new Bitmap();
			addChild(bgGreen);
			
			// red state bitmap
			bgRed = new Bitmap();
			addChild(bgRed);
			
			// toggler hand
			addChild(togglerHolder);
			(pinIcon) = new Bitmap();
			togglerHolder.addChild(pinIcon);
			generateIcons();	
			
			updateBackground();
			updateViewPort();
			
		}
		
		
		public function createWithSizes(w:int = 280, h:int = 300):void {
			if (_isDisposed) return;
			_viewWidth = w;
			_viewHeight = h;
			
			//if (w <= 100)
				borderOffset = 0;
			createDesign();
			updateViewPort();	
		}
		
		
			
		private function generateIcons():void		
		{
			// TODO DISPOSE PREVIOUS 
			UI.disposeBMD(PIN_OFF_BMD);
			UI.disposeBMD(PIN_ON_BMD);
			//
			var iconSize:Number = bgGreen.height - borderOffset * 2;
			PIN_OFF_BMD = UI.renderAsset(new SWFRecMicOff(), iconSize, iconSize);
			PIN_ON_BMD = UI.renderAsset(new SWFRecMicOn(), iconSize, iconSize);
			
		}
		
		
		/**
		 * 
		 */
		private function updateBackground():void {
			
			UI.disposeBMD(bgGreen.bitmapData);
			bgGreen.bitmapData = UI.renderAsset(new SWFRecBg(), _viewWidth, _viewHeight);	
			
			UI.disposeBMD(bgRed.bitmapData);
			bgRed.bitmapData = UI.renderAsset(new SWFRecBgRed(), _viewWidth, _viewHeight);
		}
		
	
		public function activate():void	{
			_isActive = true;
			PointerManager.addTap(this, onClick);
		}
		
		public function deactivate():void {
			_isActive = false;
			PointerManager.removeTap(this, onClick);
		}
		
		/**
		 *  On CLICK
		 * @param	e
		 */
		private function onClick(e:Event):void {
			if (!_isActive) return;
			if (tapCallback != null) 
				tapCallback();
		}
		
	
		
		/**
		 * 
		 * @param	time
		 */
		private function updateState(time:Number = 0):void 	{
			if (_isDisposed) return;			
			var pinX:int = _state == STATE_OFF?  _viewWidth- togglerHolder.width-borderOffset:borderOffset;
			var redAlpha:Number = _state == STATE_OFF? 1:0;		
			var curentStateIcon:BitmapData = _state == STATE_OFF?PIN_OFF_BMD:PIN_ON_BMD;
			pinIcon.bitmapData = curentStateIcon;			
			TweenMax.killTweensOf(togglerHolder);
			TweenMax.to(togglerHolder, time, { x:pinX, ease:Quint.easeOut } );
			TweenMax.killTweensOf(bgRed);
			TweenMax.to(bgRed, time, { autoAlpha:redAlpha, ease:Quint.easeOut } );		
		}
		
		
	
		
		/**
		 * 
		 */
		private function updateViewPort():void
		{
			if (_isDisposed) return;				
			// redraw pin 
			togglerHolder.y = borderOffset;				
			generateIcons();
			updateState(0);				
		}
		
		
		
		public function dispose():void
		{
			if (_isDisposed) return;
			_isDisposed = true;
			tapCallback = null;
			deactivate();
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
			TweenMax.killTweensOf(togglerHolder);
			TweenMax.killTweensOf(bgGreen);
			TweenMax.killTweensOf(bgRed);
			
			UI.destroy(bgGreen);
			bgGreen = null;
			
			UI.destroy(bgRed);
			bgRed = null;
			
			UI.destroy(pinIcon);
			pinIcon = null;
			
			UI.disposeBMD(PIN_OFF_BMD);
			UI.disposeBMD(PIN_ON_BMD);
			PIN_OFF_BMD = null;
			PIN_ON_BMD = null;
			
		}
		
		public function get state():int {		return _state;	}
		public  function setState(value:int, time:Number = 0):void	{
			if (value == _state) return;
			_state = value;
			updateState(time);			
		}
	}
}