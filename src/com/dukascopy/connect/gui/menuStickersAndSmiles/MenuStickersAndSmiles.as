package com.dukascopy.connect.gui.menuStickersAndSmiles {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	public class MenuStickersAndSmiles extends MobileClip {
		
		public var S_SELECT:Signal = new Signal("S_SELECT");
		
		private var paginator:Sprite;
		private var container:Sprite;
		private var page1:Sprite;
		private var page2:Sprite;
		
		private var activated:Boolean = false;
		
		private var _currentX:Number;
		
		private var firstPageDrawn:int = -1;
		private var currentPage:int = -1;
		private var startPage:int;
		
		private var startX:Number;
		private var startY:Number;
		
		private var lastX:Number = 0;
		
		private var swipeLength:int = 0;
		private var tapLength:int = 0;
		private var isMoving:Boolean = false;
		
		protected var hOffset:int;
		
		protected var elementSize:int;
		protected var source:Array;
		
		protected var _width:int;
		protected var _height:int;
		
		protected var group:int = 0;
		
		protected var rowCount:int; // row count on page
		protected var columnCount:int; // column count on page
		protected var allCount:int; // all stickers count on page
		
		protected var totalPages:int; // pages count
		
		public function MenuStickersAndSmiles() {
			elementSize = Config.FINGER_SIZE;
			
			createView();
			
			swipeLength = Config.FINGER_SIZE;// << 1;
			tapLength = Config.FINGER_SIZE * .2 * Config.FINGER_SIZE * .2;
			
			initData();
		}
		
		private function createView():void {
			_view = new Sprite();
				container = new Sprite();
				container.mouseChildren = false;
					page1 = new Sprite();
				container.addChild(page1);
					page2 = new Sprite();
				container.addChild(page2);
			_view.addChild(container);
		}
		
		protected function initData():void { }
		
		public function activate():void {
			activated = true;
			
			currentX = 0;
			
			PointerManager.addDown(container, onDown);
		}
		
		private function onDown(e:Event):void {
			isMoving = false;
			TweenMax.killTweensOf(this);
			startPage = currentPage;
			startX = lastX = MobileGui.stage.mouseX;
			startY = MobileGui.stage.mouseY;
			PointerManager.addMove(MobileGui.stage, onMove);
			PointerManager.addUp(MobileGui.stage, onUp);
		}
		
		private function onMove(e:Event):void {
			if (!isMoving) {
				var offset:int = MobileGui.stage.mouseX - startX;
				offset = (offset ^ (offset >> 31)) - (offset >> 31);
				if (((offset * offset) << 1) < tapLength)
					return;
				isMoving = true;
			}
			
			var step:int = MobileGui.stage.mouseX - lastX;
			
			currentX += step;
			lastX = MobileGui.stage.mouseX;
		}
		
		private function onUp(e:Event):void {
			var xOffset:int = MobileGui.stage.mouseX - startX;
			var yOffset:int = MobileGui.stage.mouseY - startY;
			
			if (xOffset * xOffset + yOffset * yOffset < tapLength)
				processTap();
			if (isMoving)
				currentX += MobileGui.stage.mouseX - lastX;
			
			lastX = MobileGui.stage.mouseX;
			
			PointerManager.removeMove(MobileGui.stage, onMove);
			PointerManager.removeUp(MobileGui.stage, onUp);
			
			var swipe:int = 0;
			if (lastX - startX > (swipeLength))
				swipe = 1;
			else if (lastX - startX < -swipeLength)
				swipe = -1;
			
			var _pg:int = currentPage;
			
			if (swipe != 0) {
				if (startPage - swipe == currentPage)
					_pg = currentPage;
				else
					_pg = startPage - swipe;
			}
			
			if (_pg > totalPages - 1)
				_pg--;
			if (_pg < 0)
				_pg++;
			
			TweenMax.killTweensOf(this);
			TweenMax.to(this, 20,  { useFrames:true, currentX:-_pg * _width} );
		}
		
		protected function processTap():void {
			var p:int = getElementIndexUnderMouse();
			if (p < 0)
				return;
			if (p < source.length)
				invokeSelect(source[p]);
		}
		
		protected function getElementIndexUnderMouse():int {
			var beforeCount:int = firstPageDrawn * (rowCount * columnCount);
			var sx:int = 0;
			if (container.mouseX > _width) {
				beforeCount += rowCount * columnCount;
				sx = _width;
			}
			
			var hOffset:int = (_width - columnCount * elementSize) >> 1;
			
			if (container.mouseX > _width - hOffset || container.mouseX < hOffset)
				return -1;
			
			var row:Number = container.mouseY / elementSize;
			row = ((row << 0) == row)? row:(row > 0)? (row + 1) >> 0 : row >> 0;
			
			var column:Number = (container.mouseX - hOffset - sx) / elementSize;
			column = ((column << 0) == column)? column:(column > 0)? (column + 1) >> 0 : column >> 0;
			
			var p:int;
			if (row == 0)
				p = column - 1;
			else
				p = ((row - 1) * columnCount) + column - 1;
			
			p += beforeCount;
			
			return p;
		}
		
		protected function invokeSelect(id:Object):void {
			S_SELECT.invoke(id);
		}
		
		public function get currentX():Number { return _currentX; }
		public function set currentX(value:Number):void {
			var _pg:int = -value / _width;
			var _currentPage:int = -(value - _width * .5) / _width;
			
			if (_currentPage > totalPages - 1)
				_currentPage = totalPages - 1;
			if (_currentPage < 0)
				_currentPage = 0;
			
			var pgChanged:Boolean = false;
			if (_currentPage != currentPage) {
				currentPage = _currentPage;
				pgChanged = true;
			}
			container.x = _pg * _width + value;
			
			if (firstPageDrawn != _pg) {
				firstPageDrawn = _pg;
				makePage(page1, _pg);
				if (_pg < totalPages - 1) {
					makePage(page2, _pg + 1);
					page2.visible = true;
				} else
					page2.visible = false;
			}
			_currentX = value;
			if (pgChanged)
				updatePaginator();
		}
		
		protected function calcTotalPages():void {
			if (source == null)
				return;
			var val:Number = source.length / (rowCount * columnCount);
			totalPages = ((val << 0) == val) ? val : (val > 0)? (val + 1) >> 0 : val >> 0;
		}
		
		/**
		 * Draw smiles for specified page to the target shape
		 * @param	target:Shape - shape to be drawn
		 * @param	pageNum:int - page to be used to draw
		 */
		protected function makePage(target:Sprite, pageNum:int):void	{ }
		
		private function updatePaginator():void {
			if (!activated)
				return;
			
			var iw:int = Config.FINGER_SIZE >> 1;
			var r:int = 10 * Config.FINGER_SIZE / 160;
			
			if (!paginator) {
				paginator = new Sprite();
				_view.addChild(paginator);
				PointerManager.addTap(paginator, onPaginatorTap);
			}
			
			paginator.graphics.clear();
			
			if (totalPages < 2)
				return;
			
			paginator.graphics.beginFill(0x000000, 0);
			paginator.graphics.drawRect(0, -(r * 3), (Config.FINGER_SIZE >> 1) * totalPages, r * 6);
			paginator.graphics.endFill();
			
			for (var i:int = 0; i < totalPages; i++) {
				paginator.graphics.beginFill((i==currentPage)? 0xC2C2C2:0x7C7C7C);
				paginator.graphics.drawCircle((iw >> 1) + iw * i, 0, r);
				paginator.graphics.endFill();
			}
			
			var _x:Number = (_width - paginator.width) >> 1;
			paginator.x = (_x + .5) >> 0;
			paginator.y = Config.FINGER_SIZE * .3;
		}
		
		private function onPaginatorTap(e:Event):void {
			var iw:int = Config.FINGER_SIZE >> 1;
			var p:int = paginator.mouseX / iw;
			TweenMax.killTweensOf(this);
			TweenMax.to(this, 20,  { useFrames:true, currentX:-p * _width } );
		}
		
		public function get width():Number { return _width; }
		public function set width(value:Number):void {
			_width = value;
			page2.x = _width;
			calculateVHCount();
			calcTotalPages();
			updatePages();
		}
		
		public function get height():Number { return _height; }
		public function set height(value:Number):void {
			_height = value;
			calculateVHCount();
			calcTotalPages();
			var _y:Number = Config.FINGER_SIZE * .3 + (_height - (Config.FINGER_SIZE * .3)  - (rowCount * elementSize) >> 1);
			container.y = (_y > 0) ? (_y + .5) >> 0 : (_y - .5) >> 0;
			updatePages();
		}
		
		private function calculateVHCount():void {
			columnCount = _width / elementSize;
			rowCount = (_height - (Config.FINGER_SIZE)) / elementSize;
			// Alexey added Ilya tut vi4eslenie nemnogo ne pravilno ))) poetomu dobavil 1 
			if (rowCount < 1) rowCount = 1;
			allCount = rowCount * columnCount;
			hOffset = (_width - columnCount * elementSize) >> 1;
		}
		
		private function updatePages():void {
			if (source == null)
				return;
			updatePaginator();
			startPage = 0;
			currentPage = -1;
			firstPageDrawn = -1;
			currentX = 0;
		}
		
		public function deactivate():void {
			activated = false;
			TweenMax.killTweensOf(this);
			
			if (container) {
				TweenMax.killTweensOf(container);
				container.x = 0;
			}
			
			if (page1)
				page1.graphics.clear();
			if (page2)
				page2.graphics.clear();
			
			PointerManager.removeDown(container, onDown);
			PointerManager.removeMove(MobileGui.stage, onMove);
			PointerManager.removeUp(MobileGui.stage, onUp);
			
			_currentX = 0;
			currentPage = -1;
			firstPageDrawn = -1;
			
			if (paginator) {
				paginator.graphics.clear();
				if (paginator.parent)
					paginator.parent.removeChild(paginator);
				paginator = null;
			}
		}
		
		override public function dispose():void {
			source = null;
			deactivate();
			while (page1.numChildren)
				page1.removeChildAt(0);
			page1.graphics.clear();
			page1 = null;
			while (page2.numChildren)
				page2.removeChildAt(0);
			page2.graphics.clear();
			page2 = null;
			while (container.numChildren)
				container.removeChildAt(0);
			container = null;
			if (paginator != null)
				paginator.graphics.clear();
			paginator = null
			while (_view.numChildren)
				_view.removeChildAt(0);
			_view = null;
			super.dispose();
		}
	}
}