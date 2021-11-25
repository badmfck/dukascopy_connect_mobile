package com.dukascopy.connect.gui.menuVideo {

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quint;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.ScrollRectPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TransformMatrixPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.profiler.showRedrawRegions;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class BitmapButton extends Sprite {
		
		static public var S_CLICK:Signal = new Signal("BitmapButton.S_CLICK");
		
		// helpers do not dispose them, they are static 
		private static var tempPoint:Point = new Point();
		private static var tempRect:Rectangle = new Rectangle();
		
		protected var DOWN_SCALE:Number = 1.3;
		protected var BLINK_SCALE:Number = 1.3;
		
		private var BOUNCE_TIME:Number = .5;
		private var HOVER_TIME:Number = .3;
		
		private var COLOR_DOWN:Number = 0xff0000;
		private var COLOR_ALPHA_DOWN:Number = .5;
		
		private var COLOR_UP:uint = 0xff0000;
		private var COLOR_ALPHA_UP:Number = 0;
		
		private var COLOR_BLINK:uint = 0xff0000;
		private var COLOR_ALPHA_BLINK:Number = .7;
		private var COLOR_ALPHA_BLINK_OFF:Number = 0;

		public var currentBitmapData:BitmapData;
		protected var iconBitmap:Bitmap;
		private var stageRef:Stage;
		public var tapCallback:Function;
		public var usePreventOnDown:Boolean = true;	
		
		public var VERTICAL_MOVE_SENSITIVITY:int = Config.FINGER_SIZE*.5;
		public var HORIZONTAL_MOVE_SENSITIVITY:int = Config.FINGER_SIZE*.5;
		public var cancelOnVerticalMovement:Boolean = false;
		public var cancelOnHorizontalMovement:Boolean = false;
		
		private var _isBlinking:Boolean = false;
		private var downPressed:Boolean = false;
		private var isDisposed:Boolean = false;
		public var disposeBitmapOnDestroy:Boolean  = true;
		private var _desatureted:Boolean = false;
		
		
		private var isShown:Boolean = true;
		
		
		//
		private var HITZONE_OVERFLOW:int = 20; // ramki vokrug hitzone kotorie z4itivajut tap, dlja togo chtob palci popadali po knopkam 
		public var TOP_OVERFLOW:int = 0;
		public var LEFT_OVERFLOW:int = 0;
		public var RIGHT_OVERFLOW:int = 0;
		public var BOTTOM_OVERFLOW:int = 0;
		
		public var BLINK_INTERVAL:Number = 0;
		public var MAX_BLINK_COUNT:int = -1;
		public var currentBlinkCount:int = 0;
		
		private var _hitzoneWidth:int = 0;
		private var _hitzoneHeight:int = 0;
		private var downX:int = 0;
		private var downY:int = 0;
		
		private static var _instanceCount:int = 0;
		public var callbackParam:Object = "";
		public var rotationAdded:Number = 0;
		public var preventOnMove:Boolean = false;
		public var ignoreHittest:Boolean = false;
		public var downCallback:Function;
		public var upCallback:Function;
	
		
		/**@constructor */
		public function BitmapButton(title:String = null) {
			_title = title;
			_instanceCount++;
			TweenPlugin.activate([TransformMatrixPlugin, ScrollRectPlugin, TintPlugin, ColorTransformPlugin]);
			createView();
			//flash.profiler.showRedrawRegions(true)
			overlayPadding = Config.MARGIN;
		}
		
		public function set smoothing(value:Boolean):void
		{
			if (iconBitmap != null)
			{
				iconBitmap.smoothing = value;
			}
		}
		
		public function createView():void {
			iconBitmap ||= new Bitmap();
			addChild(iconBitmap);
			
			iconBitmapUp ||= new Bitmap();
			addChild(iconBitmapUp);
			iconBitmapUp.visible = false;
			stageRef = MobileGui.stage;
		}
		
		public  function activate():void {
			PointerManager.addDown(this, onDown);
			if (allowListenNativeClickEvents && MobileGui.dce != null)
				MobileGui.dce.addEventListener(StatusEvent.STATUS, statusHandler);
			this.mouseChildren = false;
			this.mouseEnabled = true;
		}
		
		private function statusHandler(e:StatusEvent):void {
			if (e.code == "didTapOnView") {
				e.stopImmediatePropagation();
				e.preventDefault();
				var obj:Object = JSON.parse(e.level);
				if (buttonHitTest(this, null, obj.x, obj.y)) {
					//e.preventDefault();
					//e.stopImmediatePropagation();
					if (tapCallback != null) {
						if (callbackParam != "")
							tapCallback(callbackParam);
						else
							tapCallback();
					}
				}
			}
		}
		
		public function deactivate():void {
			Loop.remove(checkForMoved);
			lastTouchID = -1;
			PointerManager.removeUp(stageRef, onStageUp);
			PointerManager.removeDown(this, onDown);
			//PointerManager.removeTap(this,onTap);
			this.mouseChildren = false;
			this.mouseEnabled = false;
			if(_wasDown){
				upState();
				_wasDown = false;
			}
			if (MobileGui.dce != null)
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandler);
		}
		
		public function toTop():void {
			if (this.parent!=null) {
				this.parent.addChild(this);
			}
		}
		
		public function setBitmapData(bmd:BitmapData, disposePrevious:Boolean = false, autoHitzone:Boolean = true):void	{
			iconBitmap.bitmapData = null;
			if (disposePrevious && currentBitmapData != null) {
				currentBitmapData.dispose();
				currentBitmapData = null;
			}			
			currentBitmapData = bmd;
			iconBitmap.bitmapData = bmd;
			iconBitmap.smoothing = true;
			
			if (autoHitzone) {
				if(currentBitmapData!=null){
					setHitZone(currentBitmapData.width, currentBitmapData.height);
				}
			}
		}
		
		private var _wasDown:Boolean = false;
		private var lastTouchID:int =-1;
		private var allowListenNativeClickEvents:Boolean = false;
		private var iconBitmapUp:Bitmap;
		private var useCustomBitmapOnDown:Boolean;
		private var _title:String;
		private var overlayHitzone:String;
		private var overlayPadding:Number;
		private var overlayRadius:Number = NaN;
		private var touchPosition:Point;
		// POINTER EVENTS===============================================
		private function onDown(e:Event = null):void {
			_wasDown = true;
			downPressed = true;
			
			if(usePreventOnDown){
				e.preventDefault();
				e.stopImmediatePropagation();
			}
			if (e is TouchEvent) {
				lastTouchID = (e as TouchEvent).touchPointID;
			}
			
			downX =  MobileGui.stage.mouseX;
			downY = MobileGui.stage.mouseY;
			if (cancelOnVerticalMovement || cancelOnHorizontalMovement) {				
				Loop.add(checkForMoved);
			}
			downState();
			PointerManager.addUp(stageRef, onStageUp);
			
			if (overlayHitzone != null)
			{
				makeOverlay(downX, downY);
			}
			if (preventOnMove == true)
			{
				touchPosition = localToGlobal(new Point(x, y));
			}
			if (downCallback != null)
			{
				downCallback();
			}
		}
		
		private function makeOverlay(downX:Number, downY:Number):void 
		{
			if (parent != null)
			{
				var data:HitZoneData = new HitZoneData();
				var startZonePoint:Point = new Point(this.x, this.y);
				startZonePoint = parent.localToGlobal(startZonePoint);
				if (overlayHitzone == HitZoneType.MENU_MIDDLE_ELEMENT)
				{
					data.x = startZonePoint.x - LEFT_OVERFLOW;
					data.y = startZonePoint.y - TOP_OVERFLOW;
					data.width = width + LEFT_OVERFLOW + RIGHT_OVERFLOW;
					data.height = height + TOP_OVERFLOW + BOTTOM_OVERFLOW;
				}
				else if (overlayHitzone == HitZoneType.BUTTON)
				{
					data.x = startZonePoint.x;
					data.y = startZonePoint.y;
					data.width = width;
					data.height = height;
				}
				else{
					data.x = startZonePoint.x - overlayPadding;
					data.y = startZonePoint.y - overlayPadding;
					data.width = width + overlayPadding * 2;
					data.height = height + overlayPadding * 2;
				}
				
				data.radius = height * .5 + overlayPadding;
				if (!isNaN(overlayRadius))
				{
					data.radius = overlayRadius;
				}
				data.type = overlayHitzone;
				data.touchPoint = new Point(downX, downY);
				Overlay.displayTouch(data);
			}
		}
		
		private function checkForMoved():void 
		{
			var horizontalMovement:Number = MobileGui.stage.mouseX - downX;
			var verticalMovement:Number =  MobileGui.stage.mouseY-downY ;
			var movedVertical:Boolean = abs(verticalMovement) > VERTICAL_MOVE_SENSITIVITY;
			var movedHorizontal:Boolean = abs(horizontalMovement) > HORIZONTAL_MOVE_SENSITIVITY;
		
			if (movedVertical && cancelOnVerticalMovement) {
				Loop.remove(checkForMoved);
				PointerManager.removeUp(stageRef, onStageUp);
				upState();
				_wasDown =  false;
				lastTouchID = -1;
				if (upCallback != null)
				{
					upCallback();
				}
				return;
			}
			
			if (movedHorizontal && cancelOnHorizontalMovement) {	
				Loop.remove(checkForMoved);
				PointerManager.removeUp(stageRef, onStageUp);
				upState();
				_wasDown =  false;
				lastTouchID = -1;
				if (upCallback != null)
				{
					upCallback();
				}
				return;
			}
		}
		
		private function onStageUp(e:Event = null):void {
			PointerManager.removeUp(stageRef, onStageUp);
			if (upCallback != null)
			{
				upCallback();
			}
			if (e!=null && e is TouchEvent) {
				var newID:int = (e as TouchEvent).touchPointID;
				if(newID == lastTouchID){
					//DialogManager.alert("tapped", e.toString());	
				}else {
					upState();
					_wasDown =  false;
					return; // you touched with another finger 	
				}
			}
			upState();
			
			if (preventOnMove == true && touchPosition != null)
			{
				var endPoint:Point = localToGlobal(new Point(x, y));
				if (endPoint.x != touchPosition.x || endPoint.y != touchPosition.y)
				{
					_wasDown = false;
				}
			}
			
			if (_wasDown) {
				// hittest 
				var isOverButton:Boolean = 	buttonHitTest(this, MobileGui.stage, MobileGui.stage.mouseX, MobileGui.stage.mouseY, rotationAdded);
				if (isOverButton || ignoreHittest) {
					if (_title != null)
					{
						onClick();
						S_CLICK.invoke(_title);
					}
					if (tapCallback != null) {
						if (callbackParam != "") {
							tapCallback(callbackParam);
						}else{
							tapCallback();
						}
					}			
				}
			}
			_wasDown =  false;
		}
		
		protected function onClick():void 
		{
			
		}
		
		public function containsCords(x:int, y:int):Boolean
		{
			return buttonHitTest(this, MobileGui.stage, x, y, rotationAdded);
		}
		private function onTap(e:Event = null):void {
			e.preventDefault();
			e.stopImmediatePropagation();
			if (tapCallback != null) {
				if (callbackParam != "") {
					tapCallback(callbackParam);
				}else{
					tapCallback();
				}
			}
		}
		
		//  STATES ====================================================
		private function downState():void	{
			TweenMax.killTweensOf(iconBitmap);
			if (useCustomBitmapOnDown) {
				iconBitmapUp.visible = true;
				return;
			}
			var deltaX:Number ;
			var deltaY:Number ;
			if (currentBitmapData != null) {
				 deltaX= currentBitmapData.width*.5- (currentBitmapData.width * DOWN_SCALE)*.5  ;
				 deltaY= currentBitmapData.height*.5- (currentBitmapData.height * DOWN_SCALE)*.5  ;
			}else {
				 deltaX= iconBitmap.width*.5- (iconBitmap.width * DOWN_SCALE)*.5  ;
				 deltaY= iconBitmap.height*.5- (iconBitmap.height * DOWN_SCALE)*.5  ;
			}
			
			if (!isNaN(COLOR_DOWN))
			{
				TweenMax.to(iconBitmap, HOVER_TIME, { transformMatrix: { scaleX:DOWN_SCALE, scaleY:DOWN_SCALE, x:deltaX, y:deltaY },colorTransform:{tint:COLOR_DOWN, tintAmount:COLOR_ALPHA_DOWN},ease:Back.easeOut} );	
			}
			else
			{
				TweenMax.to(iconBitmap, HOVER_TIME, { transformMatrix: { scaleX:DOWN_SCALE, scaleY:DOWN_SCALE, x:deltaX, y:deltaY },ease:Back.easeOut} );	
			}
		}
		
		private function upState():void	{
			if (_isBlinking)
				startBlink();
			else
				stopBlink();
			if (useCustomBitmapOnDown)
				iconBitmapUp.visible = false;
		}		
		
		private function startBlink():void{
			// Костыль!
			// currentBitmapData - NULL!!!
			
			if (MAX_BLINK_COUNT != -1){		
				if (currentBlinkCount >= MAX_BLINK_COUNT){
					_isBlinking = false;
					return;					
				}
				currentBlinkCount++;				
			}
			
			try{
				var color:uint = 0xff0000;
				TweenMax.killTweensOf(iconBitmap);
				var delta:Number ;
				var deltaX:Number ;
				var deltaY:Number ;
				
				if (currentBitmapData != null) {
					 deltaX= currentBitmapData.width*.5- (currentBitmapData.width * BLINK_SCALE)*.5  ;
					 deltaY= currentBitmapData.height*.5- (currentBitmapData.height * BLINK_SCALE)*.5  ;
					 //delta= currentBitmapData.width*.5- (currentBitmapData.width * BLINK_SCALE)*.5  ;
				}else {
					 deltaX= iconBitmap.width*.5- (iconBitmap.width * BLINK_SCALE)*.5  ;
					 deltaY= iconBitmap.height*.5- (iconBitmap.height * BLINK_SCALE)*.5  ;
					 //delta= iconBitmap.width*.5- (iconBitmap.width * BLINK_SCALE)*.5  ;
				}
				var saturation:Number  = _desatureted?0:1;
				TweenMax.to(iconBitmap, BOUNCE_TIME, { transformMatrix: { scaleX:BLINK_SCALE, scaleY:BLINK_SCALE, x:deltaX, y:deltaY },colorTransform:{tint:COLOR_BLINK, tintAmount:COLOR_ALPHA_BLINK},  colorMatrixFilter:{saturation:saturation}, ease:Back.easeOut} );		
				TweenMax.to(iconBitmap, BOUNCE_TIME, { transformMatrix: { scaleX:1, scaleY:1, x:0, y:0 }, delay:BOUNCE_TIME, colorTransform:{tint:COLOR_BLINK, tintAmount:COLOR_ALPHA_BLINK_OFF}, onComplete:onBlinkComplete, ease:Back.easeOut} );		
			}catch (e:Error){
				TweenMax.killTweensOf(iconBitmap);
				echo("BitmapButon", "startBlink", " bitmap error!: " + e.message, true);
			}
		}
		
		private function onBlinkComplete():void
		{
			if (BLINK_INTERVAL == 0) {
				startBlink();
			}else{
				TweenMax.killDelayedCallsTo(startBlink);
				TweenMax.delayedCall(BLINK_INTERVAL, startBlink);
			}
		}
		
		private function stopBlink():void		{
			TweenMax.killDelayedCallsTo(startBlink);
			TweenMax.killTweensOf(iconBitmap);
			var saturation:Number  = _desatureted?0:1;
			TweenMax.to(iconBitmap, HOVER_TIME, { transformMatrix: { scaleX:1, scaleY:1, x:0, y:0 }, colorTransform: { tint:COLOR_UP, tintAmount:COLOR_ALPHA_UP } , colorMatrixFilter:{saturation:saturation}, ease:Back.easeOut, onComplete:uoStateFinish } );
		}	
		
		private function uoStateFinish():void 
		{
			
		}
		
		public function dispose():void	{
			if (isDisposed) return;
			isDisposed = true;		
			
			downCallback = null;
			upCallback = null;
			
			TweenMax.killDelayedCallsTo(startBlink);
			_instanceCount--;			
			
			this.graphics.clear();
			deactivate();
			tapCallback = null;
			callbackParam = "";
			if (this.parent) {
				this.parent.removeChild(this);
			}
			if (disposeBitmapOnDestroy) {
				UI.destroy(iconBitmap);
				
			}else {
				iconBitmap.bitmapData = null;
				UI.destroy(iconBitmap);
			}
			if (currentBitmapData)
			{
				currentBitmapData.dispose();
			}
			
			if (iconBitmapUp) {
				UI.destroy(iconBitmapUp);
				iconBitmapUp = null;
			}
			currentBitmapData = null;
			
			TweenMax.killTweensOf(iconBitmap);
			
			stageRef = null;	
		}
		
		public function get isBlinking():Boolean 	{		return _isBlinking;		}		
		public function set isBlinking(value:Boolean):void 
		{
			if (value == _isBlinking) return;
			_isBlinking = value;
			currentBlinkCount = 0;
			upState();
		}
	
		
		override public function set visible(value:Boolean):void {
			if (value == super.visible ) return;
			if (!value) {
				if (_isBlinking) {
					stopBlink();
				}
			}else {
				if (_isBlinking) {
					startBlink();
				}
			}
			super.visible = value;
		}
		
		public function get desatureted():Boolean 	{		return _desatureted;	}		
		public function set desatureted(value:Boolean):void 	{
			if (value == _desatureted) return;
			_desatureted = value;
			
			if (_isBlinking) {
				startBlink();
			}else {
					TweenMax.killTweensOf(iconBitmap);
					var saturation:Number  = _desatureted?0:1;
					TweenMax.to(iconBitmap, 0, { transformMatrix: { scaleX:1, scaleY:1, x:0, y:0 }, colorTransform: { tint:COLOR_UP, tintAmount:COLOR_ALPHA_UP } , colorMatrixFilter:{saturation:saturation}, ease:Back.easeOut } );		
			}
		}
		
		public function show(_time:Number=0, _delay:Number=0, overrideAnimation:Boolean= true, startScale:Number = 0, startAlpha:Number = 1):void
		{
			if (isShown) return;
			isShown = true;
			super.visible = true;
			
			TweenMax.killTweensOf(iconBitmap);
			
			if(overrideAnimation){
				iconBitmap.scaleX = iconBitmap.scaleY = startScale;
				iconBitmap.rotation = 0;
			}
			
			var deltaX:Number;
			var deltaY:Number;
			if (currentBitmapData != null) {				
				if (currentBitmapData is ImageBitmapData && (currentBitmapData as ImageBitmapData).isDisposed == true){	
					deltaX = 0;
					deltaY = 0;
				}else{					
					deltaX = currentBitmapData.width * .5 - (currentBitmapData.width ) * .5  ;
					deltaY = currentBitmapData.height * .5 - (currentBitmapData.height ) * .5  ;
					if(overrideAnimation){
						iconBitmap.x  = currentBitmapData.width * .5 * (1 - startScale);
						iconBitmap.y = currentBitmapData.height * .5 * (1 - startScale);
						iconBitmap.alpha = startAlpha;
					}				
				}
			}else {
				deltaX = iconBitmap.width * .5 - (iconBitmap.width ) * .5;
				deltaY = iconBitmap.height * .5 - (iconBitmap.height ) * .5;
				if(overrideAnimation){
					iconBitmap.x  = iconBitmap.width * .5 * (1 - startScale);
					iconBitmap.y =  iconBitmap.height * .5 * (1 - startScale);
					iconBitmap.alpha = startAlpha;
				}
			}
			
			TweenMax.to(iconBitmap, _time, {alpha: 1, rotation:0,  transformMatrix: { scaleX:1, scaleY:1, x:deltaX, y:deltaY }, delay:_delay, ease:Back.easeOut, onComplete:onShowComplete } );		
		}
		
		private function onShowComplete():void {
			echo("BitmapButton", "onShowComplete");
			isShown = true;
			if (_isBlinking)
				startBlink();
		}
		
		public function hide(_time:Number = 0, _delay:Number = 0):void {
			if (!isShown) return;
			isShown = false;
			TweenMax.killTweensOf(iconBitmap);
			var deltaX:Number ;
			var deltaY:Number ;
			if (currentBitmapData != null) {
				deltaX = currentBitmapData.width * .5;
				deltaY = currentBitmapData.height * .5;
			} else {
				deltaX = iconBitmap.width * .5;
				deltaY = iconBitmap.height * .5;
			}
			TweenMax.to(iconBitmap, _time, {rotation:0,
											transformMatrix: { scaleX:0, scaleY:0, x:deltaX, y:deltaY },
											colorTransform: { tint:COLOR_BLINK, tintAmount:0 },
											delay:_delay,
											ease:Quint.easeOut,
											onComplete:onHideComplete }
			);	
		}
		
		public function setHitZone(w:int, h:int):void {
			_hitzoneWidth = w;
			_hitzoneHeight = h;
			//return;
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(0x00FF00, 0);
			g.drawRect(-LEFT_OVERFLOW, -TOP_OVERFLOW, w + LEFT_OVERFLOW+RIGHT_OVERFLOW, h+TOP_OVERFLOW+BOTTOM_OVERFLOW);
			g.endFill();
		}
		
		private function onHideComplete():void {
			this.visible = false;
			isShown = false;
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
		
		public function setDownColor(value:Number):void
		{
			COLOR_DOWN = value;
		}	
		
		public function setBlinkColor(value:uint):void
		{
			COLOR_BLINK = value;
		}
		
		public function setStandartButtonParams():void
		{
			DOWN_SCALE = .95;
			HOVER_TIME = .1;
			COLOR_ALPHA_DOWN = .2;	
			COLOR_DOWN = 0x000000;				
		}
		
		public function setOverflow(top:int = 0, left:int = 0, right:int = 0, bottom:int = 0):void
		{
			TOP_OVERFLOW = top;
			LEFT_OVERFLOW = left;
			RIGHT_OVERFLOW = right;
			BOTTOM_OVERFLOW = bottom;
			setHitZone(_hitzoneWidth, _hitzoneHeight);			
		}
		
		// Overraidim wirinu chtobi uchitivatj Hitzonu knopki
		override public function get width():Number	{
			if (currentBitmapData != null) {
				return currentBitmapData.width;
			}else {
				return 0;	
			}
		}
		
		override public function get height():Number{
			if (currentBitmapData != null)
				return currentBitmapData.height;
			else
				return 0;
		}
		
		// returns width including overflow 
		public function get fullWidth():Number	{
			return (width + LEFT_OVERFLOW + RIGHT_OVERFLOW);
		}
		
		// returns height including overflow 
		public function get fullHeight():Number	{
			return (height + TOP_OVERFLOW + BOTTOM_OVERFLOW);
		}
		
		public function setAlphaBlink(val:Number):void {
			COLOR_ALPHA_BLINK = val;
		}		
		public function setAlphaBlinkOff(val:Number):void {
			COLOR_ALPHA_BLINK_OFF = val;
		}
	
		public function getIsShown():Boolean {
			return isShown;
		}
		
		/** HIT TEST */
		public static function buttonHitTest(obj:DisplayObject, stage:Stage, x:Number = 0, y:Number = 0, rotationAdded:Number = 0):Boolean {
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
			
			tempPoint.x -= coord.x;
			tempPoint.y -= coord.y;
			
			var sin:Number = Math.sin( -rotationAdded * Math.PI / 180);
			var cos:Number = Math.cos( -rotationAdded * Math.PI / 180);
			
			var xNew:Number = (tempPoint.x) * cos - (tempPoint.y) * sin;
			var yNew:Number = tempPoint.y * cos + tempPoint.x * sin;
			
			tempPoint.x = xNew + coord.x;
			tempPoint.y = yNew + coord.y;
			
			result = hitRect.containsPoint( tempPoint);
			hitRect = null;
			coord = null;
			return result;
		}
		
		public static function abs( value:Number ):Number {
			return 	(value ^ (value >> 31)) - (value >> 31);
		}
		
		public function setScaleBlink(val:Number):void {
			BLINK_SCALE = val;
		}
		
		public function listenNativeClickEvents(value:Boolean):void 
		{
			allowListenNativeClickEvents = value;
		}
		
		public function setUpState(upStateBitmapData:ImageBitmapData):void 
		{
			if (iconBitmapUp.bitmapData)
			{
				iconBitmapUp.bitmapData.dispose();
				iconBitmapUp.bitmapData = null;
			}
			iconBitmapUp.bitmapData = upStateBitmapData;
			useCustomBitmapOnDown = true;
		}
		
		public function setOverlay(value:String):void 
		{
			overlayHitzone = value;
		}
		
		public function setOverlayPadding(value:Number):void 
		{
			overlayPadding = value;
		}
		
		public function setOverlayRadius(value:Number):void 
		{
			overlayRadius = value;
		}
		
		public function get viewHeight():Number { return height; }
		public function set viewHeight(val:Number):void { }
	}
}