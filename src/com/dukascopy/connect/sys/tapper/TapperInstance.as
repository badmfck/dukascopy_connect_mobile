package com.dukascopy.connect.sys.tapper {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	
	/**
	 * @author Igor Bloom
	 */
	
	public class TapperInstance {
		
		private var downTime:Number;
		private var maxSwipeTime:int=300;
		private var movingCallback:Function;
		private var startMovingObjectCoord:int;
		private var startmouseY:int;
		private var startmouseX:int;
		private var tapCallback:Function;
		private var holdCallback:Function;
		private var swipeCallBack:Function;
		private var tapEnable:Boolean;
		private var boundWidth:int=-1;
		private var boundHeight:int=-1;
		private var boundX:int=-1;
		private var boundY:int = -1;
		
		private var movingHeight:int;
		private var bounds:Shape;
		private var isBoundsShows:Boolean=true;
		private var downPoint:Array=[0,0];
		private var speed:Number=0;
		public var isFrame:Boolean;
		private var isActive:Boolean;
		private var pointerDownListenerAdded:Boolean;
		
		private var movingObject:DisplayObject;
		private var onMovement:Function;
		private var wasHold:Boolean;
		private var holdTimer:Timer;
		private var downTimer:Timer;
		private var swipeSpeed:Number;
		private var axis:String;
		private var mouseAxis:String;
		private var mouseOtherAxis:String;
		private var downPointMainAxisIndex:int = 1;
		private var downPointOtherAxisIndex:int = 0;
		private var wasStopped:Boolean;
		private var fading:Boolean;
		private var _wasDown:Boolean;
		private var _isDisposed:Boolean;
		private var stage:Stage;
		
		public var S_MOVING_OPPOSITE:Signal = new Signal('List.S_MOVING_OPPOSITE');
		
		private static var __rr:Rectangle = null;
		public var neadMove:Boolean = true;
		private static function __rectangle(x:int, y:int, w:int, h:int):Rectangle{
			if (__rr == null){
				__rr = new Rectangle(x, y, w, h);
				return __rr;
			}
			__rr.x = x;
			__rr.y = y;
			__rr.width = w;
			__rr.height = h;
			return __rr;
		}
		
		private var size:Array;
		private var id:int;
		private static var __pp:Point = null;
		private var wasMovedBefore:Boolean=false;
		private var tapOffset:int = Config.FINGER_SIZE * .8;
		private var loopReseted:Boolean = false;
		private var isOppositeMovingLIstenNeeded:Boolean = false;
		private var mouseOppositeAxis:String;
		private var oppositeMoving:Boolean;
		private var axisOpposite:String;
		private var downCallback:Function;
		private var startMovingObjectCoordOppositeAxis:int;
		private var moveLocked:Boolean = false;
		private var upCallback:Function;
		private var _fadingKoef:Number = .9;
		
		public function set fadingKoef(value:Number):void 
		{
			_fadingKoef = value;
		}
		
		private static function __point(x:int, y:int):Point{
			if (__pp == null){
				__pp = new Point(x, y);
				return __pp;
			}
			__pp.x = x;
			__pp.y = y;
			return __pp;
		}
		
		public function TapperInstance(stage:Stage,movingObject:DisplayObject, onMovement:Function = null, size:Array = null,axis:String='y',fading:Boolean=true) {
			this.stage = stage;
			this.fading = fading;
			this.axis = axis.toLowerCase();
			mouseAxis = 'mouseY';
			mouseOtherAxis = 'mouseX';
			if (this.axis == 'x'){
				mouseAxis = 'mouseX';
				mouseOtherAxis = 'mouseY';
				downPointMainAxisIndex = 0;
				downPointOtherAxisIndex = 1;
			}
			
			isBoundsShows = Capabilities.isDebugger;
			isBoundsShows = false;
			this.onMovement = onMovement;
			this.movingObject = movingObject;
			setBounds(size);
		}
		
		public function activate():void {
			if (_isDisposed) {
				return;
			}
			if (stage == null) {
				
				return;
			}
			isActive = true;
			addActivationEvents();
			showBounds();
		}
		
		private function addActivationEvents():void{
			PointerManager.addDown(stage, onDown);
            if (Config.PLATFORM_WINDOWS && neadMove)
				PointerManager.addWheel(stage, onWheel);
		}
		
		public function deactivate():void {
			if (_isDisposed == true)
				return;
			isActive = false;
			PointerManager.removeDown(stage, onDown);
			PointerManager.removeMove(stage, onMove);
			PointerManager.removeUp(stage, onUp);
			if (Config.PLATFORM_WINDOWS)
				PointerManager.removeWheel(stage, onWheel);
			if (isFrame) {
				Loop.remove(onFrame);
				isFrame = false;
			}
			if (bounds != null)
				bounds.graphics.clear();
		}
		
		public function dispose():void {
			if (_isDisposed == true)
				return;
			
			deactivate();
			
			_isDisposed = true;
			
			if (S_MOVING_OPPOSITE != null)
				S_MOVING_OPPOSITE.dispose();
			S_MOVING_OPPOSITE = null;
			
			movingCallback = null;
			tapCallback = null;
			holdCallback = null;
			swipeCallBack = null;
			onMovement = null;
			downCallback = null;
			upCallback = null;
			
			bounds = null;
			movingObject = null;
			
			if (downPoint != null)
				downPoint.length = 0;
			downPoint = null;
			if (size != null)
				size.length = 0;
			size = null;
			__pp = null;
			
			stage = null;
			
			if (holdTimer != null)
				holdTimer.stop();
			holdTimer = null;
			
			if (downTimer != null)
				downTimer.stop();
			downTimer = null;
		}
		
		public function setMovingObject(movingObject:DisplayObject):void {
			if (_isDisposed) {
				return;
			}
			this.movingObject = movingObject;
		}
		
		public function setMoveCallback(val:Function):void {
			if (_isDisposed) {
				return;
			}
			onMovement = val;
		}
		
		public function setTapCallback(val:Function):void {
			if (_isDisposed) {
				return;
			}
			tapCallback = val;
		}
		
		public function setSwipeCallBack(val:Function):void {
			if (_isDisposed) {
				return;
			}
			swipeCallBack = val;
		}
		
		public function setHoldCallback(val:Function):void {
			if (_isDisposed) {
				return;
			}
			holdCallback = val;
		}
		
		private function onDown(e:Event):void {
			if (stage == null) {
				return;
			}
			if (boundWidth==-1 || !__rectangle(boundX, boundY, boundWidth, boundHeight).containsPoint(__point(stage.mouseX, stage.mouseY)))
				return;
			if (isFrame) {
				Loop.remove(onFrame);
				isFrame = false;
			}
			wasStopped = false;
			_wasDown = true;
			wasMovedBefore = false;
			tapEnable = true;
			
			// Если тап херово работает - увелчить скорость до 0.2 ... 0.3 или вообще убрать
			// нужно для того, чтоб можно было останавливать прокрутку без отстреливания ТАП сигнала
			if (Math.abs(speed) > 0.16)
				wasMovedBefore = true;
			
			downTime = new Date().getTime();
			downPoint = [stage.mouseX, stage.mouseY];
			if (downTimer == null) {
				downTimer = new Timer(300,1);
				downTimer.addEventListener(TimerEvent.TIMER, onDownTimer);
			}
			downTimer.start();
			
			
			PointerManager.addMove(stage, onMove);
			PointerManager.addUp(stage, onUp);
			
			startmouseY = stage.mouseY;
			startmouseX = stage.mouseX;
			
			if (movingObject)
			{
				startMovingObjectCoord = movingObject[axis];
				if (isOppositeMovingLIstenNeeded)
				{
					if (axis == "x")
					{
						startMovingObjectCoordOppositeAxis = downPoint[1];
					}
					else {
						startMovingObjectCoordOppositeAxis = downPoint[0];
					}
				}
			}
			
			wasHold = false;
			if(holdCallback!=null){
				if (holdTimer) {
					holdTimer.start();
				} else {
					holdTimer ||= new Timer(600, 1);
					holdTimer.addEventListener(TimerEvent.TIMER_COMPLETE, invokeHoldSignal);
					holdTimer.start();
				}
			}
			if (downCallback)
			{
				if (downCallback.length == 1)
				{
					downCallback(e);
				}
				else 
				{
					downCallback.call();
				}
			}
		//	e.stopPropagation();
		//	e.stopImmediatePropagation();
		}
		
		private function onDownTimer(e:TimerEvent):void {
			downTime = new Date().getTime();
			downPoint = [stage.mouseX, stage.mouseY];
			downTimer.reset();
			downTimer.start();
		}
		
		private function invokeHoldSignal(e:TimerEvent):void {
			if (holdCallback == null)
				return;
			wasHold = true;
			onUp(e);
		}
		
		private function onMove(e:Event):void {
			checkDownTime();
			if (tapEnable)
			{
				var movingDelta:Number = Math.abs(this['start' + mouseAxis] - stage[mouseAxis]);
				var movingOppositeDelta:Number;
				if (isOppositeMovingLIstenNeeded && mouseOppositeAxis)
				{
					movingOppositeDelta = Math.abs(this['start' + mouseOppositeAxis] - stage[mouseOppositeAxis]);
					if (movingOppositeDelta > movingDelta)
					{
						movingDelta = movingOppositeDelta;
						oppositeMoving = true;
					}
					else
					{
						oppositeMoving = false;
					}
				}
				
				if (movingDelta > tapOffset)
				{
					if (isOppositeMovingLIstenNeeded && oppositeMoving)
					{
						this['start' + mouseOppositeAxis] = stage[mouseOppositeAxis];
					}
					else {
						this['start' + mouseAxis] = stage[mouseAxis];
					}
					
					tapEnable = false;
				}
			}
			
			if (tapEnable == false) {
				if (movingObject)
				{
					if (oppositeMoving)
					{
						
					}
					else {
						if (!moveLocked)
						{
							movingObject[axis] = startMovingObjectCoord - (this['start' + mouseAxis] - stage[mouseAxis]);
						}
					}
				}
				callMovingCallBack();
			}
		}
		
		private function onUp(e:Event = null):void {
			if (e is TimerEvent)
				if (tapEnable == false)
					return;
			PointerManager.removeMove(stage, onMove);
			PointerManager.removeUp(stage, onUp);
			
			if (isDisposed)
				return;
				
			downTimer.reset();
			downTimer.stop();
			
			if (holdTimer!=null)
				holdTimer.reset();
				
			if (_wasDown == false) {
				return;
			}
			_wasDown = false;
			
			if (upCallback)
			{
				upCallback();
			}
			
			if (tapEnable == true)
			{
				if (wasHold && holdCallback != null)
				{
					holdCallback();
				}
				else if (tapCallback != null)
				{
					tapCallback(e);
				}
				return;
			}
			
			var a:int = startmouseX - stage.mouseX;
			var b:int = startmouseY - stage.mouseY;
			var l:int = Math.sqrt(a * a + b * b) ;
			var offset:int = Config.FINGER_SIZE * .8;
			
			checkDownTime();
			
			calcSpeed();
			
			var mbspeed:Number = speed * ((speed < 0)? -1:1);
			var mbspeedX:Number = swipeSpeed * ((swipeSpeed < 0)? -1:1);
			
			if (mbspeed > .7 && !oppositeMoving) {
				if (!isFrame && !wasStopped && fading) {
					Loop.add(onFrame);
					isFrame = true;
				}
				return;
				if (!fading)
					callMovingCallBack(true);
			} else {
				if (!isFrame)
					callMovingCallBack(true);
			}
			
			// Watch for swipe
			var razn:Number = mbspeedX - mbspeed;
			var wasSwipe:Boolean = false;
			if (mbspeedX>mbspeed && razn>3 && wasHold==false) {
				if (swipeCallBack != null){
					swipeCallBack(swipeSpeed);
					wasSwipe = true;
				}
			}
			oppositeMoving = false;
		}

        private function onWheel(e:MouseEvent):void{
            if (isDisposed && neadMove == false)
                return;
            speed = -1 * e.delta;
            var mbspeed:Number = Math.abs(speed);
            var wasFade:Boolean = false;
            if ( mbspeed > .3) {
                if (!isFrame && !wasStopped && fading) {
                    Loop.add(onFrame);
                    isFrame = true;
                }
                if (fading)
                    wasFade = true;
                else
                    callMovingCallBack(true); /////////////////////////////////////// if !fading callMovingCallBack(true)
            } else {
                if (!isFrame)
                    callMovingCallBack(true);
            }
        }
		
		public function stop():void {
			if (_isDisposed) {
				return;
			}
			
			if (isFrame) {
				isFrame = false;
				Loop.remove(onFrame);
			}
			wasStopped = true;
			_wasDown = false;
		}
		
		/**
		 * 
		 * @param	size Array - 0 width, 1 - height
		 * 
		 */
		public function setBounds(s:Array = null):void {
			if (s != null)
				this.size = s;
			if (_isDisposed) {
				return;
			}
			if (s == null && size == null) {
				boundWidth = -1;
				boundHeight = -1;
				boundX = -1;
				boundY = -1;
				return;
			}
			var x:int = 0;
			var y:int = 0;
			if(size[2]==null && size[3]==null){
				if (movingObject && movingObject.parent && movingObject.parent.parent){
					x = movingObject.parent.parent.localToGlobal(__point(movingObject.parent.x, movingObject.parent.y)).x;
					y = movingObject.parent.parent.localToGlobal(__point(movingObject.parent.x, movingObject.parent.y)).y;
				}else {
					if (movingObject != null) {
						var __onAddedToStage:Function = function(e:Event):void {
							movingObject.removeEventListener(Event.ADDED_TO_STAGE, __onAddedToStage);
							if (_isDisposed)
								return;
							setBounds(size);
							stage = movingObject.stage;
							activate();
						}
						movingObject.addEventListener(Event.ADDED_TO_STAGE, __onAddedToStage);
					}
				}
			}else {
				x = size[2];
				y = size[3];
			}
			boundWidth = size[0];
			boundHeight = size[1];
			boundX = x;
			boundY = y;
			showBounds();
		}
		
		private function showBounds():void{
			if (!isBoundsShows)
				return;
			bounds ||= new Shape();
			bounds.graphics.clear();
			bounds.graphics.lineStyle(3, 0x00FF00, .5);
			if (!isActive)
			{
				return;
			}
			bounds.graphics.drawRect(boundX, boundY, boundWidth, boundHeight);
			if (stage)
				stage.addChild(bounds);
		}
			
		private function checkDownTime():void {
			var curTime:Number = downTime-new Date().getTime();
			if (curTime > maxSwipeTime) {
				downTime = new Date().getTime();
				downPoint = [stage.mouseX, stage.mouseY];
			}
		}
		
		private function calcSpeed():void {
			var t:int = new Date().getTime() - downTime;
			var l:int = Math.abs(downPoint[downPointMainAxisIndex] - stage[mouseAxis]);
			speed = (l / (t)) * ((downPoint[downPointMainAxisIndex] > stage[mouseAxis])? 1: -1);
			var lx:int = Math.abs(downPoint[downPointOtherAxisIndex] - stage[mouseOtherAxis]);
			swipeSpeed = (lx / (t)) * ((downPoint[downPointOtherAxisIndex] > stage[mouseOtherAxis])? 1: -1);
			swipeSpeed *= 4;
			speed *= 4;
		}
		
		private function onFrame():void {
			speed *= _fadingKoef;
			if (movingObject == null) {
				Loop.remove(onFrame);
				isFrame = false;
				return;
			}
			if (moveLocked) {
				Loop.remove(onFrame);
				speed = 0;
				return;
			}
			movingObject[axis] -= 10 * speed;
			if (speed > 0) {
				if (speed < 0.05) {
					callMovingCallBack(true);
					Loop.remove(onFrame);
					isFrame = false;
					return;
				}
			} else {
				if (speed > -0.05) {
					callMovingCallBack(true);
					Loop.remove(onFrame);
					isFrame = false;
					return;
				}
			}
			callMovingCallBack();
		}
		
		public function get primarySpeed():Number {
			if (_isDisposed) {
				return 0;
			}
			return speed;
		}
		
		public function get secondarySpeed():Number {
			if (_isDisposed) {
				return 0;
			}
			return swipeSpeed;
		}
		
		public function get isDisposed():Boolean {
			return _isDisposed;
		}
		
		private function callMovingCallBack(stopped:Boolean = false):void {
			
			if (isOppositeMovingLIstenNeeded && oppositeMoving)
			{
				S_MOVING_OPPOSITE.invoke((this['start' + mouseOppositeAxis] - stage[mouseOppositeAxis]), stopped);
			}
			else {
				if (onMovement != null)
					onMovement(stopped);
			}
		}
		
		public function resetLoop():void {
			/*loopReseted = true;
			Loop.remove(onFrame);
			speed = 0;*/
		}
		
		public function listenOppositeMoving(isOppositeMovingLIstenNeeded:Boolean):void 
		{
			this.isOppositeMovingLIstenNeeded = isOppositeMovingLIstenNeeded;
			if (isOppositeMovingLIstenNeeded)
			{
				if (mouseAxis == 'mouseY')
				{
					mouseOppositeAxis = "mouseX";
					axisOpposite = "x";
				}
				else if (mouseAxis == 'mouseX')
				{
					mouseOppositeAxis = "mouseY";
					axisOpposite = "y";
				}
			}
		}
		
		public function setDownCallback(callback:Function):void 
		{
			downCallback = callback;
		}
		
		public function setLockMove(value:Boolean):void 
		{
			if (!value)
			{
				wasStopped = true;
				Loop.remove(onFrame);
				speed = 0;
				oppositeMoving = false;
			}
			
			moveLocked = value;
		}
		
		public function setUpCallback(callback:Function):void 
		{
			upCallback = callback;
		}
		
		public function get wasDown():Boolean {
			return _wasDown;
		}
	}
}