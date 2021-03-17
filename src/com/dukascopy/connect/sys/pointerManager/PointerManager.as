package com.dukascopy.connect.sys.pointerManager {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class PointerManager {
		
		private static var mDown:String;
		private static var mUp:String;
		private static var mOut:String;
		private static var mMove:String;
		private static var mClick:String;
        private static var mWheel:String;
		
		static private var inited:Boolean = false;
		
		static private var tapWatchers:/*TapWatcher*/Array = [];
		
		public function PointerManager() {
		
		}
		
		static private function init():void {
			if (inited)
				return;
			inited = true;
			
			mDown = MouseEvent.MOUSE_DOWN;
			mUp = MouseEvent.MOUSE_UP;
			mMove = MouseEvent.MOUSE_MOVE;
			mClick = MouseEvent.CLICK;
            mWheel = MouseEvent.MOUSE_WHEEL;
            mOut = MouseEvent.RELEASE_OUTSIDE;
			
			/*if(!Config.PLATFORM_WINDOWS){
				mDown = TouchEvent.TOUCH_BEGIN;
				mUp =TouchEvent.TOUCH_END;
				mMove = TouchEvent.TOUCH_MOVE;
				mClick = TouchEvent.TOUCH_TAP;
			}*/
		}
		
		static public function addTap(target:DisplayObject,onTapped:Function):void{
			init();
			var n:int = 0;
			var l:int = tapWatchers.length;
			for (n; n < l; n++) {
				if (tapWatchers[n].callBack == onTapped && tapWatchers[n].target == target) {
					tapWatchers[n].dispose();
					tapWatchers.splice(n, 1);
					break;
				}
			}
			tapWatchers.push(new TapWatcher(target, onTapped,mDown,mUp,mMove));
		}
		
		static public function removeTap(target:EventDispatcher, onTapped:Function):void {
			init();
			if (target == null) {
				trace('can`t remove tap - target is null');
				return;
			}
			
			var n:int = 0;
			var l:int = tapWatchers.length;
			for (n; n < l; n++) {
				if (tapWatchers[n].callBack == onTapped && tapWatchers[n].target == target) {
					tapWatchers[n].dispose();
					tapWatchers.splice(n, 1);
					return;
				}
			}
		}
		
		static public function addDown(target:EventDispatcher, onTapped:Function,useCapture:Boolean=false, priority:int = 0):void {
			init();
			if (target == null) {
				trace('3:PointerManager -> addDown() -> Error -> target is null');
				return;
			}
			
			target.addEventListener(mDown, onTapped,useCapture, priority);
		}
		
		static public function addUp(target:EventDispatcher, onTapped:Function):void {
			if (MobileGui.isActive == false)
				return;
			init();
			target.addEventListener(mUp, onTapped);
		}
		
		static public function addOut(target:EventDispatcher, onTapped:Function):void {
			if (MobileGui.isActive == false)
				return;
			init();
			target.addEventListener(mOut, onTapped);
		}
		
		static public function addMove(target:EventDispatcher, onTapped:Function):void {
			init();
			target.addEventListener(mMove, onTapped);
		}

        /**
         * Windows
         */
        static public function addWheel(target:EventDispatcher, onTapped:Function):void{
            init();
            target.addEventListener(mWheel, onTapped);
        }
				
		static public function removeDown(target:EventDispatcher, onTapped:Function,useCapture:Boolean=false):void {
			init();
			if (target == null)
				return;
			target.removeEventListener(mDown, onTapped,useCapture);
		}
		
		static public function removeUp(target:EventDispatcher,  onTapped:Function):void {
			init();
			if (target == null)
				return;
			target.removeEventListener(mUp, onTapped);
		}
		
		static public function removeOut(target:EventDispatcher,  onTapped:Function):void {
			init();
			if (target == null)
				return;
			target.removeEventListener(mOut, onTapped);
		}
		
		static public function removeMove(target:EventDispatcher,  onTapped:Function):void {
			init();
			if (target == null)
				return;
			target.removeEventListener(mMove, onTapped);
		}

        /**
         * Windows
         */
        static public function removeWheel(target:EventDispatcher, onTapped:Function):void{
            init();
			if (target == null)
				return;
            target.removeEventListener(mWheel, onTapped);
        }
	}
}
import com.dukascopy.connect.Config;
import com.dukascopy.connect.utils.Debug.BloomDebugger;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
class TapWatcher {
	
	private var mup:String;
	private var mmove:String;
	private var mdown:String;
	private var _target:DisplayObject;
	private var _callBack:Function;
	private var wasMoved:Boolean;
	private var startX:Number;
	private var startY:Number;
	private var stage:Stage;
	
	public function TapWatcher(target:DisplayObject, callBack:Function,mdown:String,mup:String,mmove:String) {
		this._callBack = callBack;
		this._target = target;
		this.mdown = mdown;
		this.mmove = mmove;
		this.mup = mup;
		if (target)
		{
			target.addEventListener(mdown, onMDown);
		}
	}
	
	private function onMDown(e:Event):void {
		if (mmove == null || mup==null)
			return;
		stage = target.stage;
		if (stage == null)
			return;
		stage.addEventListener(mup, onMouseUp);
		stage.addEventListener(mmove, onMouseMove);
		startX = stage.mouseX;
		startY = stage.mouseY;
	}
	
	private function onMouseMove(e:Event):void {
		if (stage==null)
			return;
		if (wasMoved == true)
			return;
		var a:int = startX - stage.mouseX;
		var b:int = startY - stage.mouseY;
		var l:Number = Math.sqrt(a * a + b * b);
		if (l > Config.FINGER_SIZE)
			wasMoved = true;
	}
	
	private function onMouseUp(e:Event):void {
		if (stage!=null){
			stage.removeEventListener(mup, onMouseUp);
			stage.removeEventListener(mmove, onMouseMove);
		}
		if (callBack != null && wasMoved == false)
			callBack(e);
		wasMoved = false;
	}
	
	public function dispose():void {
		if (target != null){
			target.removeEventListener(mdown,onMDown);
		}
		if (stage!=null){
			stage.removeEventListener(mup, onMouseUp);
			stage.removeEventListener(mmove, onMouseMove);
		}
		wasMoved = false;
		_target = null;
		_callBack = null;
		mdown = null;
		mup = null;
		mmove = null;
		stage = null;
	}
	
	public function get target():DisplayObject {
		return _target;
	}
	
	public function get callBack():Function {
		return _callBack;
	}
	
}