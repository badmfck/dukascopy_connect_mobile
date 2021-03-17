package com.dukascopy.connect.sys.swiper {

	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.Config;
	import com.telefision.sys.signals.Signal;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	/**
	 * Helper class for detecting swipe events on stage 
	 * 
	 * @author Alexey
	 */
	
	public class Swiper {
		
		static public const DIRECTION_UP:String = "swipe_up";
		static public const DIRECTION_DOWN:String = "swipe_down";
		static public const DIRECTION_LEFT:String = "swipe_left";
		static public const DIRECTION_RIGHT:String = "swipe_right";
		
		public  var swapTreshold:int = Config.FINGER_SIZE;// 100; // minimal distance to detect swipe 
		public  var timeTreshold:Number = 1000;  // miliseconds in down state to cancel swipe
		
		private  static var stageRef:Stage;
		private  var downGlobalPoint:Point;
		private  var upGlobalPoint:Point;
		private  var downTime:Number  = 0;		
		public var S_ON_SWIPE:Signal;
		private var isDisposed:Boolean = false;
		private var _name:String;
		private var downTarget:DisplayObject;
		private var bounds:Rectangle;
		private var mousePoint:Point;
		
		private var boundsShape:Shape;
		
		private static var __pp:Point = null;
		private static function __point(x:int, y:int):Point {
			if (__pp == null){
				__pp = new Point(x, y);
				return __pp;
			}
			__pp.x = x;
			__pp.y = y;
			return __pp;
		}
		
		public function Swiper(name:String, downTarget:DisplayObject=null) {	
			this.downTarget = downTarget;
			_name = name;
			isDisposed = false;	
			downGlobalPoint = new Point();
			upGlobalPoint = new Point();
			S_ON_SWIPE = new Signal("on_swipe");
			echo("Swiper", "Swiper", "Swap treshold: " + swapTreshold);
		}
		
		public static function init(_stage:Stage):void {
			stageRef = _stage;		
		}
		
		
		public function activate():void	{
			if (stageRef)
				stageRef.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			else
				echo("Swiper", "activate", "Stage reference is null, can not activate");
			if (boundsShape != null)
				boundsShape.visible = true;
		}
		
		public  function deactivate():void {
			if (stageRef) {
				stageRef.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
				stageRef.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			} else
				echo("Swiper", "deactivate", "Stage reference is null, can not deactivate");
			if (boundsShape != null)
				boundsShape.visible = false;
		}
		
		public function dispose():void {
			if (isDisposed)
				return;
			isDisposed = true;
			deactivate();
			downGlobalPoint = null;
			upGlobalPoint = null;
			if (S_ON_SWIPE != null)
				S_ON_SWIPE.dispose();
			S_ON_SWIPE = null;
			if (boundsShape != null) {
				boundsShape.graphics.clear();
				if (boundsShape.parent != null)
					boundsShape.parent.removeChild(boundsShape);
			}
			boundsShape = null;
		}
		
		public function setBounds(width:int, height:int, hitTarget:DisplayObject, xOffset:int = 0,yOffset:int=0):void {
			if (bounds == null)
				bounds = new Rectangle();
			
			var x:int = 0;
			var y:int = 0;
			if (hitTarget && hitTarget.parent && hitTarget.parent.parent){
				x=hitTarget.parent.parent.localToGlobal(__point(hitTarget.parent.x, hitTarget.parent.y)).x;
				y = hitTarget.parent.parent.localToGlobal(__point(hitTarget.parent.x, hitTarget.parent.y)).y;
			}
			
			bounds.x = x+xOffset;
			bounds.y = y+yOffset;
			bounds.width = width;
			bounds.height = height;
			return;
			
			if (boundsShape == null) {
				boundsShape = new Shape();
				stageRef.addChild(boundsShape);
			}
			boundsShape.graphics.clear();
			boundsShape.graphics.lineStyle(2, 0xFF0000);
			boundsShape.graphics.drawRect(0, 0, bounds.width, bounds.height);
			boundsShape.x = bounds.x;
			boundsShape.y = bounds.y;
		}
		
		private  function onDown(e:MouseEvent):void {
			if (bounds != null) {
				if (mousePoint == null)
					mousePoint = new Point();
				mousePoint.x = stageRef.mouseX;
				mousePoint.y = stageRef.mouseY;
				if (!bounds.containsPoint(mousePoint)) {
					return;
				}
			}
			
			if (isDisposed) {
				if (stageRef != null)
					stageRef.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
				return;
			}
			
			// TODO if has targets check for hit test and dispatch them with signals on Up
			downGlobalPoint.x = stageRef.mouseX;
			downGlobalPoint.y = stageRef.mouseY;
			downTime = new Date().time;			
			stageRef.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		private  function onUp(e:MouseEvent):void {
			if (isDisposed) {
				if (stageRef != null)
					stageRef.addEventListener(MouseEvent.MOUSE_UP, onUp);
				return;
			}
			stageRef.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			var upTime:Number = new Date().time;
			var diff:Number  = upTime - downTime;
			if (diff > 1000) {
				//trace("SWIPE TIMEOUT");
			}else {
				var direction:String;
				upGlobalPoint.x = stageRef.mouseX;
				upGlobalPoint.y = stageRef.mouseY;
				var horizontalOffset:Number = upGlobalPoint.x - downGlobalPoint.x;
				var verticalOffset:Number = upGlobalPoint.y - downGlobalPoint.y;
				var absX:Number = Math.abs(horizontalOffset);
				var absY:Number  = Math.abs(verticalOffset);
				if (absX < swapTreshold && absY < swapTreshold)
					return;
				if (absX > absY) {
					direction = horizontalOffset > 0? DIRECTION_RIGHT:DIRECTION_LEFT;
					S_ON_SWIPE.invoke( direction);
				} else {
					direction = verticalOffset > 0? DIRECTION_DOWN:DIRECTION_UP;
					S_ON_SWIPE.invoke( direction);
				}
			}
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get startX():Number {
			return downGlobalPoint.x;
		}
	}
}