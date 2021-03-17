package com.dukascopy.connect.gui.scrollPanel {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;


	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class ScrollPanel extends MobileClip {
		
		static protected const scrollBarWidth:int = Config.FINGER_SIZE * .1;
		
		protected var tapper:TapperInstance;
		protected var box:Sprite;
		protected var _width:int=320;
		protected var _height:int = 240;
		private var _background:Boolean = true;
		private var _backgroundColor:uint = Style.color(Style.COLOR_BACKGROUND);
		private var _backgroundAlpha:Number = 1;
		protected var items:/*DisplayObject*/Array = [];
		private var msk:Shape;
		protected var scrollBar:Shape;
			
		public function ScrollPanel(){
			createView();
		}
		
		private function createView():void{
			_view = new Sprite();
			box = new Sprite();
			_view.addChild(box);
			//drawEnv();
			mask = true;
			
			scrollBar = new Shape();
			scrollBar.alpha = 0;
			_view.addChild(scrollBar);
		}
		
		private function drawEnv():void{
			_view.graphics.clear();
			if (background == false) {
				_view.graphics.beginFill(0, 0);
				_view.graphics.drawRect(0, 0, _width, _height);
			} else {
				_view.graphics.beginFill(_backgroundColor, _backgroundAlpha);
				_view.graphics.drawRect(0, 0, _width, _height);
			}
			if (msk != null) {
				msk.graphics.clear();
				msk.graphics.beginFill(0, 1);
				msk.graphics.drawRect(0, 0, _width, _height);
			}
		}
		
		public function addObject(obj:Object):void {
			if(obj is DisplayObject || obj is MobileClip) {
				if (obj in items)
					return;
				
				if (obj is DisplayObject) {
					box.addChild(obj as DisplayObject);
				}else {
					box.addChild(obj.view as DisplayObject);
				}
				
				items[items.length] = obj;
				setScrollBarSize();
				onMoved();
			}
		}
		
		public function updateObjects():void {
			setScrollBarSize();
			onMoved();
		}
		
		public function removeObject(obj:DisplayObject):void {
			if (_isDisposed)
				return;
			var m:int = items.length;
			while (m--) {
				if (items[m] == obj) {
					if(items[m] is DisplayObject){
						if (items[m].parent && items[m].parent == box){
							box.removeChild(items[m]);
						}
					}else {
						if (items[m].view.parent && items[m].view.parent == box){
							box.removeChild(items[m].view);
						}
					}
					//items.splice(1, m);
					items.splice(m, 1); // ILYA 19.06.2015
					return;
				}
			}
			setScrollBarSize();
			onMoved();
		}
		
		public function removeAllObjects():void {
			if (_isDisposed)
				return;
			if(items!=null){
				var m:int = items.length;
				while (m--) {
					if(items[m] is DisplayObject){
						if (items[m].parent && items[m].parent == box)
							box.removeChild(items[m]);
					}else {
						if (items[m].view.parent && items[m].view.parent == box)
							box.removeChild(items[m].view);
					}
				}
				items.length = 0;
			}
		}
		
		/**
		 * Установка маски на панель. если true - ставим
		 */
		public function set mask(val:Boolean):void {
			if (_isDisposed)
				return;
		
			if(val==true){
				if (msk == null)
					msk = new Shape();
				drawEnv();
				_view.addChild(msk);
				_view.mask = msk;
			}else {
				// remove mask
				if (msk != null) {
					msk.graphics.clear();
					if (msk.parent)
						msk.parent.removeChild(msk);
				}
				_view.mask = null;
			}
		}
		
		public function enable():void {
			if (_isDisposed)
				return;
			if (scrollBar != null)
				scrollBar.visible = true;
			if (tapper == null){
				tapper = new TapperInstance(MobileGui.stage, box, onMoved, [_width, _height]);
			}
			tapper.setTapCallback(onTap);
			tapper.activate();
		}
		
		protected function onTap(e:Event):void{
			
		}
		
		protected function onMoved(scrollStopped:Boolean = false):void {
			//echo("ScrollPanel", "onMoved");
			if (scrollStopped == false)
				scrollBar.alpha = 1;
			checkBoxBounds(scrollStopped);
			var l:int = items.length;
			for (var n:int = 0; n < l; n++) {
				var i:DisplayObject = (items[n] is MobileClip) ? items[n].view : items[n];
				var trueY:int = i.y + box.y;
				if (trueY + i.height > 0 && trueY < _height) {
					if (i.visible == false)
						i.visible = true;
				}else {
					if(i.visible==true && changeItemVisibility == true)
						i.visible = false;
				}
			}
			if (scrollCallbackFunction != null)
			{
				scrollCallbackFunction();
			}
			Overlay.removeCurrent();
		}
		
		protected function checkBoxBounds(scrollStopped:Boolean=false):void{
			var b:int = _height - box.height;
			if (box.height <= _height) {
				box.y = 0;
				scrollBar.alpha = 0;
			} else {
				if (scrollStopped) {
					if (box.y + box.height < _height) {
						TweenMax.to(box, 10, { useFrames:true, y:int(_height - box.height), 
						onUpdate:onMoved } );
					} else if (box.y > 0) {
						TweenMax.to(box, 10, { useFrames:true, y:0, 
						onUpdate:onMoved, onComplete:onTweenMovingComplete } );
					}
					TweenMax.to(scrollBar, 10, { useFrames:true, alpha:0});
				}else {
					if (box.y > 0){
						box.y -= int(box.y * .4);
					}else if (box.y + /*box.height */+box.height < _height) {
						box.y -= int((box.y-(_height - box.height)) * .4);
					}
				}
			}
			var razn:Number = -box.y / (box.height - _height);
			scrollBar.y = (_height - scrollBar.height) * razn;
		}
		
		protected function setScrollBarSize():void {
			var h:Number = (_height / box.height) * _height;
			scrollBar.graphics.clear();
			if (h < _height) {
				if (h < Config.FINGER_SIZE*.5)
					h = Config.FINGER_SIZE*.5;
				scrollBar.graphics.beginFill(0x7E95A8, .4);
				scrollBar.graphics.drawRect(0, 0, scrollBarWidth, h);
			}
			scrollBar.x = int( _width - scrollBarWidth);
		}
		
		protected function onTweenMovingComplete():void {
			echo("ScrollPanel", "onTweenMovingComplete");	
			onMoved(true);
		}
		
		public function disable():void {
			if (_isDisposed)
				return;
			if (scrollBar != null)
				scrollBar.visible = false;
			if (tapper) {
				tapper.deactivate();
				tapper.setTapCallback(null);
			}
		}
		
		public function getWidth():int { return _width; }
		public function getHeight():int { return _height; }
		
		public function setWidthAndHeight(w:int, h:int, needUpdate:Boolean = true, preventUpdate:Boolean = false):void {
			if (_isDisposed)
				return;
			if (needUpdate == false)
				if (_width != w || _height != h)
					needUpdate = true;
			_width = w;
			_height = h;
			if (needUpdate == true && preventUpdate == false)
				update();
		}
		
		private var __pt:Point = null;
		protected var changeItemVisibility:Boolean = true;
		protected var scrollCallbackFunction:Function;
		
		protected function __point(x:int, y:int):Point{
			if (__pt == null)
				__pt = new Point();
			__pt.x = x;
			__pt.y = y;
			return __pt;
		}
		protected function findObjectWithFocus(target:DisplayObjectContainer):DisplayObject{
			var m:int = target.numChildren;
			while (m--) {
				var i:DisplayObject = target.getChildAt(m);
				if (i is TextField){
					// check focus
					if (MobileGui.stage.focus == i)
						return i;
				}
				if (i is DisplayObjectContainer){
					var founded:DisplayObject = findObjectWithFocus(i as DisplayObjectContainer);
					if (founded != null)
						return i;
				}
			}
			
			return null;
		}
		
		public function update(ignoreFocusedItems:Boolean = false):void {
			if (tapper)
				tapper.setBounds([_width, _height]);
			setScrollBarSize();
			drawEnv();
			
			if (ignoreFocusedItems == false)
			{
				checkForItemInFocus();
			}
			
			onMoved(false);
		}
		
		protected function checkForItemInFocus():void {
			if (MobileGui.softKeyboardOpened == true || MobileGui.softKeyboardMoving == true) {
				var focusObject:DisplayObject = findObjectWithFocus(box);
				if (focusObject == null)
					return;
				var trueY:int = view.globalToLocal(focusObject.localToGlobal(__point(0, 0))).y;
				var yAndH:int = trueY + focusObject.height + Config.DOUBLE_MARGIN;
				
				if (!(trueY > -1 && yAndH < _height)) {
					// NEED TO SCROLL TO ITEM!
					if (tapper != null)
						tapper.stop();
					TweenMax.killTweensOf(box);
					if (trueY > 0)
					{
						var newPos:Number = box.y - (yAndH - _height);
						if (newPos + box.height < height && box.height > height)
						{
							newPos = height - box.height;
						}
						box.y = newPos;
					}
					else
					{
						box.y = 0;
					}
					onMoved(true);
				}
			} else {
				if (box.y + box.height < height) {
					box.y = Math.min(0, height - box.height);
				}
			}
		}
		
		override public function dispose():void {
			if (_isDisposed)
				return;
			super.dispose();
		
			if (tapper != null) {
				tapper.dispose();
				tapper = null;
			}
			
			scrollCallbackFunction = null;
			
			removeAllObjects();
			items = null;
			if (box && box.parent)
				box.parent.removeChild(box);
			if (box != null)
				TweenMax.killTweensOf(box);
						
			box = null;
			
			if (msk && msk.parent)
				msk.parent.removeChild(msk);
				
			if (msk != null)
				msk.graphics.clear();
			msk = null;
			
			if (scrollBar) {
				scrollBar.graphics.clear();
				TweenMax.killTweensOf(scrollBar);
				if (scrollBar.parent)
					scrollBar.parent.removeChild(scrollBar);
			}
			scrollBar = null;
		}
		
		public function getPositionY():int {
			return box.y * ( -1);
		}
		
		public function setPositionY(y:int):void {
			
		}
		
		public function fitInScrollArea():Boolean 
		{
			return box.height <= _height;
		}
		
		public function scrollToBottom():void 
		{
			if (box.height > _height)
			{
				box.y = _height - box.height;
				onMoved(true);
			}
		}
		
		public function scrollToPosition(position:int, animate:Boolean = false, time:Number = 0.2, delay:Number = 0):void 
		{
			var newPosition:int = -position;
			
			if (newPosition + box.height < height)
			{
				newPosition = height - box.height;
			}
			if (animate == true)
			{
				if (newPosition != box.y)
				{
					TweenMax.to(box, time, { useFrames:false, y:newPosition, ease:Power2.easeOut, delay:delay,
						onUpdate:onMoved, onComplete:onTweenMovingComplete } );
				}
			}
			else
			{
				box.y = newPosition;
				onMoved();
			}
		}
		
		public function isItemVisible(item:Sprite):Boolean 
		{
			if (item.y + box.y < 0)
			{
				return false;
			}
			else if (item.y + box.y + item.height > height)
			{
				return false;
			}
			return true;
		}
		
		public function hideScrollBar():void 
		{
			scrollBar.alpha = 0;
		}
		
		public function getScrollBarWidth():int {
			return scrollBarWidth;
		}
		
		public function disableVisibilityChange():void 
		{
			changeItemVisibility = false;
		}
		
		public function set scrollCallback(value:Function):void 
		{
			scrollCallbackFunction = value;
		}
		
		public function get background():Boolean {
			if (_isDisposed)
				return false;
			return _background;
		}
		
		public function set background(value:Boolean):void {
			if (_isDisposed)
				return;
			_background = value;
			drawEnv();
		}
		
		public function get backgroundColor():uint {
			if (_isDisposed)
				return 0;
			
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void {
			if (_isDisposed)
				return;
			
			_backgroundColor = value;
			drawEnv();
		}
		
		public function get backgroundAlpha():Number {
			if (_isDisposed)
				return 0;
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value:Number):void {
			if (_isDisposed)
				return;
			_backgroundAlpha = value;
			drawEnv();
		}
		
		public function get containerBox():DisplayObjectContainer {
			return box;
		}
		
		public function get itemsHeight():int {
			return box.height;
		}
		
		public function get height():int 
		{
			return _height;
		}
	}
}