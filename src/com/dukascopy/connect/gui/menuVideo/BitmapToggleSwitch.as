package com.dukascopy.connect.gui.menuVideo {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quint;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.ScrollRectPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TransformMatrixPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.telefision.utils.Loop;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class BitmapToggleSwitch extends Sprite {
		
		private static var tempPoint:Point = new Point();
		private static var tempRect:Rectangle = new Rectangle();
		
		private var ON_COLOR:uint = Color.GREEN;
		private var ON_COLOR_DOWN:uint = 0x599230;		
		private var OFF_COLOR:uint = Style.color(Style.TOGGLER_UNSELECTED);
		private var OFF_COLOR_DOWN:uint = Style.color(Style.TOGGLER_UNSELECTED_DOWN);
		
		private var DOWN_SCALE:Number = 1.3;		
		private var HOVER_TIME:Number = .3;
		
		private var COLOR_DOWN:uint = 0xff0000;
		private var COLOR_ALPHA_DOWN:Number = .5;
		
		private var COLOR_UP:uint = 0xff0000;
		private var COLOR_ALPHA_UP:Number = 0;
		
		private var COLOR_BLINK:uint = 0xff0000;
		private var COLOR_ALPHA_BLINK:Number = .7;
		
		private var currentBackgroundBitmapData:BitmapData;
		private var backgroundBitmap:Bitmap;
		private var togglerBitmap:Bitmap;
		
		private var stageRef:Stage;
		public var tapCallback:Function;
		public var usePreventOnDown:Boolean = true;	
		
		public var VERTICAL_MOVE_SENSITIVITY:int = Config.FINGER_SIZE*.5;
		public var HORIZONTAL_MOVE_SENSITIVITY:int = Config.FINGER_SIZE * .5;
		
		public var cancelOnVerticalMovement:Boolean = false;
		public var cancelOnHorizontalMovement:Boolean = false;
		
		private var _isBlinking:Boolean = false;
		private var downPressed:Boolean = false;
		private var isDisposed:Boolean = false;
		public var disposeBitmapOnDestroy:Boolean  = true;
		
		private var isShown:Boolean = true;
		
		private var HITZONE_OVERFLOW:int = 20;
	
		public var TOP_OVERFLOW:int = 0;
		public var LEFT_OVERFLOW:int = 0;
		public var RIGHT_OVERFLOW:int = 0;
		public var BOTTOM_OVERFLOW:int = 0;
		
		private var _hitzoneWidth:int = 0;
		private var _hitzoneHeight:int = 0;
		private var downX:int = 0;
		private var downY:int = 0;
		
		private var _isSelected:Boolean = false;
		
		public function BitmapToggleSwitch() {
			TweenPlugin.activate([TransformMatrixPlugin, ScrollRectPlugin, TintPlugin, ColorTransformPlugin]);
			createView();	
		}
		
		public function createView():void {
			backgroundBitmap ||= new Bitmap();			
			addChild(backgroundBitmap);
			togglerBitmap ||= new Bitmap(new ImageBitmapData("BitmapToggleSwitch.togglerBitmap", 20, 20, false, 0xff0000));
			addChild(togglerBitmap);
			stageRef = MobileGui.stage;
		}
		
		public function activate():void {		
			PointerManager.addDown(this,onDown);
			this.mouseChildren = false;
			this.mouseEnabled = true;
		}
		
		public function deactivate():void {
			Loop.remove(checkForMoved);
			lastTouchID = -1;
			PointerManager.removeUp(stageRef,onStageUp);
			PointerManager.removeDown(this,onDown);
			this.mouseChildren = false;
			this.mouseEnabled = false;
			if(_wasDown == true) {
				upState();
				_wasDown = false;
			}
		}
		
		public function toTop():void {
			if (this.parent != null)
				this.parent.addChild(this);
		}
		
		public function setDesignBitmapDatas(bgBitmapData:BitmapData, togglerBitmapData:BitmapData, disposePrevious:Boolean = false, autoHitzone:Boolean = true):void {
			backgroundBitmap.bitmapData = null;
			if (disposePrevious && currentBackgroundBitmapData != null) {				
				currentBackgroundBitmapData.dispose();
				currentBackgroundBitmapData = null;
			}			
			currentBackgroundBitmapData = bgBitmapData;
			backgroundBitmap.bitmapData = bgBitmapData;
			if (autoHitzone) {
				if(currentBackgroundBitmapData!=null ){
					setHitZone(currentBackgroundBitmapData.width, currentBackgroundBitmapData.height);
				}
			}		
			if (disposePrevious && togglerBitmap.bitmapData != null) {				
				togglerBitmap.bitmapData.dispose();
				togglerBitmap.bitmapData = null;
			}			
			togglerBitmap.bitmapData = togglerBitmapData;	
			togglerBitmap.y = (backgroundBitmap.height - togglerBitmap.height) * .5;
			updateSelectionState();
		}
		
		private var _wasDown:Boolean = false;
		private var lastTouchID:int =-1;
		// POINTER EVENTS===============================================
		private function onDown(e:Event = null):void {
			_wasDown = true;
			downPressed = true;
			wasToggleMovedWhileDown = false;
			if(usePreventOnDown){
				e.preventDefault();
				e.stopImmediatePropagation();
			}
			if (e is TouchEvent) {
				 lastTouchID = (e as TouchEvent).touchPointID;
			}
			downX =  MobileGui.stage.mouseX;
			downY = MobileGui.stage.mouseY;
			Loop.add(checkForMoved);
			downState();			
			PointerManager.addUp(stageRef, onStageUp);		
		}
		
		private var wasToggleMovedWhileDown:Boolean = false;
		private function checkForMoved():void {
			var DIRECTION_SENSITIVITY:int =Config.FINGER_SIZE_DOT_25 ;	
			
			var horizontalMovement:Number = MobileGui.stage.mouseX - downX;
			var verticalMovement:Number =  MobileGui.stage.mouseY-downY ;
			var movedVertical:Boolean = abs(verticalMovement) > VERTICAL_MOVE_SENSITIVITY;
			var movedHorizontal:Boolean = abs(horizontalMovement) > HORIZONTAL_MOVE_SENSITIVITY;
			
			if (abs(horizontalMovement)< DIRECTION_SENSITIVITY) return;
				wasToggleMovedWhileDown = true;
			if (horizontalMovement<0)
				setSelectionState(false,true);				
			else
				setSelectionState(true,true);				
		}
		
		public function setSelectionState(value:Boolean, useAnimation:Boolean = false):void	{
			if (_isSelected == value)
				return;
			_isSelected = value;
			updateSelectionState(useAnimation);
			echo("BitmappToggleSwitch", "setSelectionState", "Selection changed: " + value);
		}
		
		private function updateSelectionState(useAnimation:Boolean = false):void {
			var bgStateColor:uint;
			if (downPressed)
				bgStateColor = _isSelected?ON_COLOR_DOWN:OFF_COLOR_DOWN;
			else
				bgStateColor = _isSelected?ON_COLOR:OFF_COLOR;
			TweenMax.killTweensOf(backgroundBitmap);
			var saturation:Number  = 1;
			var colorAlpha:Number  = 1;
			TweenMax.to(
				backgroundBitmap,
				0,
				{
					transformMatrix: {
						scaleX:1,
						scaleY:1,
						x:0,
						y:0
					}, 
					colorTransform: {
						tint:bgStateColor,
						tintAmount:colorAlpha
					} 
				}
			);		
			if (togglerBitmap == null) return;
			var bound:int = togglerBitmap.y;
			TweenMax.killTweensOf(togglerBitmap);
			var destX:Number =_isSelected? width - togglerBitmap.width-bound:bound;
			if (useAnimation == true)
				TweenMax.to(togglerBitmap, .2, {x:destX,ease:Quint.easeOut } );
			else
				togglerBitmap.x = destX;
		}
		
		private function onStageUp(e:Event = null):void {
			downPressed = false;
			Loop.remove(checkForMoved);				
			PointerManager.removeUp(stageRef, onStageUp);			
			if (e!=null && e is TouchEvent) {
				var newID:int = (e as TouchEvent).touchPointID;
				if (newID != lastTouchID) {
					upState();
					_wasDown =  false;
					return;
				}
			}
			upState();
			if (_wasDown == true) {
				var isOverButton:Boolean = 	buttonHitTest(this, MobileGui.stage, MobileGui.stage.mouseX, MobileGui.stage.mouseY);
				if (isOverButton) { 
					if (!wasToggleMovedWhileDown)					
						setSelectionState(!_isSelected, true);
					if (tapCallback != null)
						tapCallback();
				}else if (wasToggleMovedWhileDown && tapCallback != null){
					tapCallback();
				}
			}
			_wasDown =  false;
		}
		
		public function containsCords(x:int, y:int):Boolean {
			return buttonHitTest(this, MobileGui.stage, x, y);
		}
		
		private function downState():void {
			updateSelectionState(true);
		}
		
		private function upState():void {			
			updateSelectionState(true);
		}		
		
		public function dispose():void	{
			if (isDisposed) return;
			isDisposed = true;		
			if (togglerBitmap != null)
				TweenMax.killTweensOf(togglerBitmap);
			if (backgroundBitmap != null)
				TweenMax.killTweensOf(backgroundBitmap);
			
				
			this.graphics.clear();			
			deactivate();
			
			tapCallback = null;
			if (this.parent) {
				this.parent.removeChild(this);
			}
			
			if (disposeBitmapOnDestroy) {
				UI.destroy(togglerBitmap);
				togglerBitmap = null;
				UI.destroy(backgroundBitmap);
				backgroundBitmap = null;					
				UI.disposeBMD(currentBackgroundBitmapData);
				currentBackgroundBitmapData = null;
				
			}else {
				togglerBitmap.bitmapData = null;
				backgroundBitmap.bitmapData = null;				
				currentBackgroundBitmapData = null;
				UI.destroy(backgroundBitmap);
				UI.destroy(togglerBitmap);
			}
			
			stageRef = null;	
		}
		
		override public function set visible(value:Boolean):void {
			if (value == super.visible ) return;
			super.visible = value;
		}
		
		public function show(_time:Number=0, _delay:Number=0, overrideAnimation:Boolean= true):void
		{
			if (isShown) return;
			isShown = true;
			super.visible = true;
			
			TweenMax.killTweensOf(backgroundBitmap);
			
			if(overrideAnimation){
				backgroundBitmap.scaleX = backgroundBitmap.scaleY = 0;
				backgroundBitmap.rotation = 0;
			}
			
			var deltaX:Number ;
			var deltaY:Number ;
			if (currentBackgroundBitmapData != null) {
				deltaX = currentBackgroundBitmapData.width * .5 - (currentBackgroundBitmapData.width ) * .5  ;
				deltaY = currentBackgroundBitmapData.height * .5 - (currentBackgroundBitmapData.height ) * .5  ;
				if(overrideAnimation){
					backgroundBitmap.x  = currentBackgroundBitmapData.width * .5;
					backgroundBitmap.y = currentBackgroundBitmapData.height * .5;
				}
			}else {
				deltaX = backgroundBitmap.width * .5 - (backgroundBitmap.width ) * .5;
				deltaY = backgroundBitmap.height * .5 - (backgroundBitmap.height ) * .5;
				if(overrideAnimation){
					backgroundBitmap.x  = backgroundBitmap.width * .5;
					backgroundBitmap.y =  backgroundBitmap.height * .5;
				}
			}
			
			TweenMax.to(backgroundBitmap, _time, {rotation:0,  transformMatrix: { scaleX:1, scaleY:1, x:deltaX, y:deltaY }, delay:_delay, ease:Back.easeOut } );
		}
		
		public function hide(_time:Number=0, _delay:Number=0) :void{
			if (!isShown) return;
			isShown = false;
			TweenMax.killTweensOf(backgroundBitmap);
			TweenMax.killTweensOf(togglerBitmap);
			var deltaX:Number ;
			var deltaY:Number ;
			if (currentBackgroundBitmapData != null) {
				deltaX= currentBackgroundBitmapData.width*.5 ;
				deltaY= currentBackgroundBitmapData.height*.5 ;
			}else {
				deltaX= backgroundBitmap.width*.5  ;
				deltaY= backgroundBitmap.height*.5  ;
			}			
			TweenMax.to(backgroundBitmap, _time, { rotation:0,  
													transformMatrix: { scaleX:0, scaleY:0, x:deltaX, y:deltaY }, 
													delay:_delay, ease:Quint.easeOut, onComplete:onHideComplete } );	
		}
		
		
		public function setHitZone(w:int, h:int):void {
			_hitzoneWidth = w;
			_hitzoneHeight = h;
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(0xff0000, 0);
			g.drawRect(-LEFT_OVERFLOW, -TOP_OVERFLOW, w+LEFT_OVERFLOW+RIGHT_OVERFLOW, h+TOP_OVERFLOW+BOTTOM_OVERFLOW);
			g.endFill();
		}
		
		private function onHideComplete():void {
			this.visible = false;
		}
		
		public function setDownScale(value:Number):void {
			DOWN_SCALE = value;
		}
		
		public function setDownTime(value:Number):void {
			HOVER_TIME = value;
		}
			
	
		public function setDownAlpha(value:Number):void {
			COLOR_ALPHA_DOWN = value;
		}
		
		public function setDownColor(value:uint):void {
			COLOR_DOWN = value;
		}
		
		public function setStandartButtonParams():void {
			DOWN_SCALE = .95;
			HOVER_TIME = .1;
			COLOR_ALPHA_DOWN = .2;
			COLOR_DOWN = 0x000000;
		}
		
		public function setOverflow(top:int = 0, left:int = 0, right:int = 0, bottom:int = 0):void {
			TOP_OVERFLOW = top;
			LEFT_OVERFLOW = left;
			RIGHT_OVERFLOW = right;
			BOTTOM_OVERFLOW = bottom;
			setHitZone(_hitzoneWidth, _hitzoneHeight);
		}
		
		override public function get width():Number	{
			if (currentBackgroundBitmapData != null)
				return currentBackgroundBitmapData.width;
			else
				return 0;
		}
		
		public function get fullWidth():Number {
			return (width + LEFT_OVERFLOW + RIGHT_OVERFLOW);
		}
		
		override public function get height():Number {
			if (currentBackgroundBitmapData != null)
				return currentBackgroundBitmapData.height;
			else
				return 0;
		}
		
		public function get fullHeight():Number {
			return (height + TOP_OVERFLOW + BOTTOM_OVERFLOW);
		}
		
		public function get isSelected():Boolean { return _isSelected; }
		public function set isSelected(value:Boolean):void {
			if (value == _isSelected)
				return;
			_isSelected = value;
			updateSelectionState(false);
		}
		
		public function setAlphaBlink(val:Number):void {
			COLOR_ALPHA_BLINK = val;
		}
		
		private static function buttonHitTest(obj:DisplayObject, stage:Stage, x:Number = 0, y:Number = 0):Boolean {
			var result:Boolean  = false;
			tempPoint.x = 0;
			tempPoint.y = 0;
			var coord:Point =  obj.localToGlobal(tempPoint);
			var rectX:int = coord.x - obj['LEFT_OVERFLOW'];
			var rectY:int =  coord.y- obj['TOP_OVERFLOW'];
			var rectWidth:int = obj['fullWidth'];
			var rectHeight:int = obj['fullHeight'];
			tempRect.x = rectX;
			tempRect.y = rectY;
			tempRect.width = rectWidth;
			tempRect.height = rectHeight;
			var hitRect:Rectangle = tempRect;
			tempPoint.x = x;
			tempPoint.y = y;
			result = hitRect.containsPoint( tempPoint);
			hitRect = null;
			coord = null;
			return result;
		}
		
		private static function abs( value:Number ):Number {
			return (value ^ (value >> 31)) - (value >> 31);
		}
	}
}