package com.dukascopy.connect.gui.menuStickersAndSmiles {
	
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.telefision.sys.signals.Signal;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * @author
	 */
	
	public class StickersMenu extends MobileClip {
		
		public var S_SELECT:Signal = new Signal("S_SELECT");
		public var S_CLOSE:Signal = new Signal("S_CLOSE");
		public var S_BACKSPACE:Signal = new Signal("S_BACKSPACE");
		
		private var _page:int = 0;
		
		private var page1:Shape;
		private var page2:Shape;
		
		protected var container:Sprite;
		private var activated:Boolean = false;
		
		protected var firstPageDrawn:int = -1;
		
		private var _currentX:Number;
		private var currentPage:int = -1;
		
		private var paginator:Sprite;
		
		private var startX:Number;
		private var startY:Number;
		
		private var lastX:Number = 0;
		private var startPage:int;
		
		private var swipeLength:int = 0;
		private var tapLength:int = 0;
		private var isMoving:Boolean = false;
		
		protected var elementSize:int;
		protected var source:Array;
		
		protected var tabs:SmileyMenuTabs;
		protected var panel:Shape;
		
		protected var _width:int;
		protected var _height:int;
		
		protected var group:int = 0;
		
		protected var hCount:int;
		protected var vCount:int;
		
		public function StickersMenu(){
			super();
		}
		
		override protected function initData():void {
			source = RichTextStickersCodes.getStickers();
			
			var c:Number = Config.PLATFORM == Config.PLATFORM_APPLE? 1.9 : 2;
			elementSize = Config.FINGER_SIZE * c;// * 1.2;
		}
		
		override protected function invokeSelect(id:Object):void {
			startLockTimer();
			
			if (locked)
				return;
			
			S_SELECT.invoke(id);
			locked = true;
		}
		
		override protected function get totalPages():int {
			var result:Number = source[group][2].length / (hCount * vCount);
			return ((result << 0) == result)? result:(result > 0)? (result + 1) >> 0 : result >> 0;
		}
		
		/**
		 * Draw smiles for specified page to the target shape
		 * @param	target:Shape - shape to be drawn
		 * @param	pageNum:int - page to be used to draw
		 */
		override protected function makePage(target:Shape, pageNum:int):void {
			hCount = _width / elementSize;
			vCount = (_height - (Config.FINGER_SIZE * 1.5)) / elementSize;
			
			var hOffset:int = (_width - hCount * elementSize) >> 1;
			
			var lastElement:Number = hCount * vCount;
			var firstElement:Number = pageNum * lastElement;
			
			if (firstElement > source[group][2].length - 1)
				firstElement = source[group][2].length - 1 - lastElement;
			if (firstElement < 0)
				firstElement = 0;
			
			if (lastElement + firstElement > source[group][2].length - 1)
				lastElement = source[group][2].length;
			else
				lastElement += firstElement;
			
			var iH:int = 0;
			var iV:int = 0;
			
			var iconSize:int = elementSize * .8;
			var iconOffset:int = (elementSize - iconSize) >> 1;
			
			target.graphics.clear();
			target.graphics.beginFill(0xE5E5E5, 0);
			target.graphics.drawRect(0, 0, _width, vCount *  elementSize);
			target.graphics.endFill();
			
			var stickerData:BitmapData;
			var drawMode:int = 0;
			
			for (var i:int = firstElement; i < lastElement; i++) {
				stickerData = RichTextStickersCodes.getStickerByIndex(source[group][2][i]);
				
				drawMode = ImageManager.SCALE_INNER_PROP;
				iconOffset = (iconOffset > 0)? (iconOffset + .5) >> 0 : (iconOffset - .5) >> 0;
					
				ImageManager.drawGraphicImage(target.graphics,
					DefinedConstants.rectangle(hOffset + iH * elementSize + iconOffset, iV * elementSize + iconOffset, iconSize, iconSize),
					stickerData,
					drawMode
				);
				
				iH++;
				if (iH >= hCount) {
					iH = 0;
					iV++;
				}
			}
		}
		
		override public function deactivate():void {
			stopLockTimer();
			lockTimer = null;
			super.deactivate();
		}
		
		//////////////////////////////////////////////////////////////////////////////////////////////////
		//  LOCK CHECK  //////////////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////
		private function startLockTimer():void {
			if (!lockTimer)
				lockTimer = new Timer(500);
			else
				stopLockTimer();
			
			lockTimer.addEventListener(TimerEvent.TIMER, lockTimerHandler);
			lockTimer.reset();
			lockTimer.start();
		}
		
		private function lockTimerHandler(e:TimerEvent):void {
			stopLockTimer();
			locked = false;
		}
		
		private function stopLockTimer():void {
			if (!lockTimer)
				return;
			lockTimer.removeEventListener(TimerEvent.TIMER, lockTimerHandler);
			lockTimer.stop();
		}
	}
}