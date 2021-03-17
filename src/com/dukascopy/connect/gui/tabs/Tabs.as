package com.dukascopy.connect.gui.tabs {

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.tabs.vo.TabsItemVO;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author Igor Bloom
	 */
	public class Tabs extends MobileClip implements ITabsPay{

		public var S_ITEM_SELECTED:Signal = new Signal("Tabs.MobileClip");

		protected var current:ITabsItem;
		protected var stock:Array/*TabsItem*/;
		protected var boxItems:Sprite;
		protected var boxItemsCont:Sprite;
		protected var boxSelected:Sprite;
		private var _width:int = 320;
		protected var _height:int = Config.FINGER_SIZE_DOUBLE;
		private var _offsetTop:int = 0;
		private var _selectionPosition:int = 0;// 0 - top, 1 - bottom

		public var tapper:TapperInstance;
		public var busy:Boolean;
		protected var wasTapped:Boolean;

		private static var pt:Point;
		protected var isActive:Boolean;
		private var icon:ImageBitmapData;

		protected var boxBg:Shape;
		protected var itemBgColor:uint;
		protected var itemTextColor:uint;
		private var itemBgAlpha:Number;
		protected var selectionBgColor:uint;
		private var bgHeight:int;
		private var _tabsItemClass:Class;
		protected var _isHidenBTN:Boolean;
		private var _prevID:String = "";

		public function Tabs(itemBgColor:uint = 0xFFFFFF, itemTextColor:uint = 0x0, itemBgAlpha:Number = 1, selectionBgColor:uint = 0xEA3311, tabsItemClass:Class = null, arrawsColor:uint = 0x0, arrawsBGColor:uint = 0x0) {
			_tabsItemClass = tabsItemClass;
			this.selectionBgColor = selectionBgColor;
			this.itemBgAlpha = itemBgAlpha;
			this.itemTextColor = itemTextColor;
			this.itemBgColor = itemBgColor;
			_view = new Sprite();
			boxBg = new Shape();

			boxItems = new Sprite();
			boxItemsCont = new Sprite();
			boxSelected = new Sprite();

			boxSelected.graphics.beginFill(selectionBgColor);
			boxSelected.graphics.drawRect(0, 0, 10, 4);

			boxItems.addChild(boxItemsCont);
			boxItems.addChild(boxSelected);

			_view.addChild(boxBg);
			_view.addChild(boxItems);
			tapper = new TapperInstance(MobileGui.stage, boxItems, onMoved, [_width, _height], 'x');
			stock = [];
		}

		/*public function setBg(img:ImageBitmapData, bgHeight:int):void {
		 this.bgHeight = bgHeight;
		 boxBg.graphics.clear();
		 if (bgHeight > _height)
		 boxBg.y = _height - bgHeight;
		 ImageManager.drawGraphicImage(boxBg.graphics, 0, 0, _widthTabPay, bgHeight, img, ImageManager.SCALE_PORPORTIONAL, -1, true);
		 }*/

		/**
		 * first add all element than drawView
		 * @param vos
		 */
		public function adds(vos:Vector.<TabsItemVO>):void {
			var vo:TabsItemVO;
			removeAll();
			for (var i:int = 0; i < vos.length; i++) {
				vo = vos[i];
				add(vo.name, vo.id,vo.icon,vo.bg, vo.doSelection,vo.neadDrawView);
			}
			updateView();
		}

		/**
		 *
		 * @param name - text
		 * @param id - init name
		 * @param icon
		 * @param bg
		 * @param doSelection
		 * @param neadDrawView - in old versio draw after each add(), new method add element is using adds();
		 */
		public function add(name:String, id:String, icon:ImageBitmapData = null, bg:ImageBitmapData = null, doSelection:Boolean = true, neadDrawView:Boolean = true):void {
			if (stock == null)
				return;
			//check for duplicate
			var item:ITabsItem = getItemById(id);
			if (item != null)
				return;
			item = new _tabsItemClass(name, id, stock.length, icon, bg, itemBgColor, itemBgAlpha, itemTextColor, doSelection);
			//stock.push(i);
			stock[stock.length] = item;
			boxItemsCont.addChild(item.view);
			if(neadDrawView){
				updateView();
			}
		}

		public function remove(id:String):Boolean {
			var m:int = stock.length;
			while (m--) {
				if (stock[m].id == id) {
					stock[m].dispose();
					stock.splice(m, 1);
					updateView();
					return true;
				}
			}
			return false;
		}

		public function removeAll():void {
			var m:int = stock.length;
			while (m--) {
				stock[m].dispose();
				stock.splice(m, 1);
			}
			updateView();
		}

		public function activate():void {
			isActive = true;
			tapper.setTapCallback(onTap);
			tapper.activate();
		}

		public function deactivate():void {
			isActive = false;
			tapper.setTapCallback(null);
			tapper.deactivate();
		}

		private function onTap(e:Event = null):void {
			if (busy == true)
				return;
			if (stock == null || boxSelected == null)
				return;
			//FIND ITEM
			if (pt == null)
				pt = new Point();
			pt.x = boxSelected.mouseX;
			pt.y = boxSelected.mouseY;
			var l:int = stock.length;
			for (var n:int = 0; n < l; n++) {
				if (stock[n].view.getRect(boxSelected).containsPoint(pt)) {
					select(stock[n].id);
					return;
				}
			}
		}


		override public function dispose():void {
			deactivate();
			super.dispose();
			if (stock != null) {
				var l:int = stock.length;
				for (var n:int = 0; n < l; n++) {
					stock[n].dispose();
				}
			}
			stock = null;
			current = null;
			if (tapper != null)
				tapper.dispose();
			tapper = null;
			if (S_ITEM_SELECTED != null)
				S_ITEM_SELECTED.dispose();
			S_ITEM_SELECTED = null;


			if (boxItems != null)
				boxItems.graphics.clear();
			boxItems = null;
			if (boxItemsCont != null)
				boxItemsCont.graphics.clear();
			boxItemsCont = null;
			if (boxSelected != null)
				boxSelected.graphics.clear();
			boxSelected = null;

			pt = null;
			if (icon != null)
				icon.dispose();
			icon = null;
		}

		public function selectCurrent():void {
			if (current == null)
				selectFirst();
			else
				select(current.id);
		}

		public function select(id:String, animate:Boolean = true, ignoreSide:Boolean = false):void {
			if (stock == null)
				return;

			if (current != null && current.id == id)
				return;

			var side:String = 'right'; // ->
			var item:ITabsItem = getItemById(id);
			if (item != null) {
				if (current != null) {
					current.setSelection(false);
					if (item.num < current.num)
						side = 'left';
				}
				if(_prevID == ""){

						_prevID = item.id;
				}else{
						_prevID = current.id;
				}
				current = item;

				if (item.doSelection == false) {
					S_ITEM_SELECTED.invoke(id, side);
					return;
				}

				current.setSelection(true);
				tapper.stop();
				var tX:int = -current.view.x + (_width - current.view.width) * .5;
				if (tX > 0)
					tX = 0;
				if (tX < -(boxItems.width - _width))
					tX = -(boxItems.width - _width);
				TweenMax.killTweensOf(boxItems);
				var speed:Number = (animate) ? .2 : 0;
				if (boxItems.width > _width) {
					wasTapped = true;
					if(_isHidenBTN){
						boxItems.x = tX;
						onCompleteSelect();
					}else{
						TweenMax.to(boxItems, speed, {x: tX, onComplete: onCompleteSelect});
					}
				} else {
					boxItems.x = getXBoxItems();
				}
				TweenMax.to(boxSelected, speed, {x: boxItemsCont.x + current.view.x, width: current.view.width});
				if (ignoreSide == true)
					S_ITEM_SELECTED.invoke(id, null);
				else
					S_ITEM_SELECTED.invoke(id, side);
			}
		}

		/**
		 * Create number for positionX boxItems
		 * @return
		 */
		protected function getXBoxItems():Number {
			return (_width - boxItems.width ) * .5;
		}
		protected function onCompleteSelect():void {
			wasTapped = false;
		}

		public function selectFirst(ignoreSide:Boolean = false):void {
			if (stock != null && stock[0] != null && stock[0].id != null)
				select(stock[0].id, true, ignoreSide);
		}

		public function selectLast():void {
			if (stock != null && stock[stock.length - 1] != null && stock[stock.length - 1].id != null)
				select(stock[stock.length - 1].id);
		}

		public function selectNext():void {
			if (stock == null)
				return;
			if (current != null) {
				var m:int = stock.length;
				while (m--) {
					if (stock[m].id == current.id) {
						if (m == stock.length - 1) {
							selectCurrent();
						} else {
							select(stock[m + 1].id);
						}
						return;
					}
				}
			}
			selectCurrent();
		}

		public function selectPrev():void {
			if (stock == null)
				return;
			if (current != null) {
				var m:int = stock.length;
				while (m--) {
					if (stock[m].id == current.id) {
						if (m == 0) {
							selectCurrent();
						} else {
							select(stock[m - 1].id);
						}
						return;
					}
				}
			}
			selectCurrent();
		}

		protected function onMoved(scrollStopped:Boolean = false):void {
			checkBoxBounds(scrollStopped);
		}

		protected function checkBoxBounds(scrollStopped:Boolean = false):void {
			if (wasTapped)
				return;
		//	var b:int = _widthTabPay - boxItems.width;
			if (boxItems.width <= _width) {
				boxItems.x = 0;
			} else {
				if (scrollStopped) {
					if (boxItems.x + boxItems.width < _width)
						TweenMax.to(boxItems, 10, {useFrames: true, x: _width - boxItems.width});
					else if (boxItems.x > 0)
						TweenMax.to(boxItems, 10, {useFrames: true, x: 0});
				} else {
					if (boxItems.x > 0) {
						boxItems.x -= boxItems.x * .4;
					} else if (boxItems.x + boxItems.width < _width) {
						boxItems.x -= (boxItems.x - (_width - boxItems.width)) * .4;
					}
				}
			}
		}

		public function setWidthAndHeight(w:int, h:int):void {
			if(_width == w && _height == h) return;
			_width = w;
			_height = h;
			updateView();
		}

		public function setY(y:int):void {
			_view.y = y;
			tapper.setBounds();
		}

		public function setX(x:int):void {
			_view.x = x;
			tapper.setBounds();
		}

		protected function updateView():void {
			if(stock == null)return;
			var l:int = stock.length;
			var x:int = 0;
			var itmH:int = _height - _offsetTop;
			if (_selectionPosition == 0)
				boxSelected.y = _offsetTop;
			else
				boxSelected.y = _height - boxSelected.height;

			for (var n:int = 0; n < l; n++) {
				stock[n].rebuild(itmH);
				stock[n].view.x = x;
				stock[n].view.y = _offsetTop;
				x += stock[n].view.width;
			}
			setBoundsTapper();
			if (current != null)
			{
				if(current.view != null)
					boxSelected.width = current.view.width;
			}
		}

		protected function setBoundsTapper():void {
			var itmH:int = _height - _offsetTop;
			if (_offsetTop > 0){
				tapper.setBounds([_width, itmH, 0, _offsetTop]);
			}else{
				tapper.setBounds([_width, itmH]);
			}
		}

		private function getItemById(id:String):ITabsItem {
			if (stock == null)
				return null;
			var m:int = stock.length;
			while (m--) {
				if (stock[m].id == id)
					return stock[m];
			}
			return null;
		}

		public function get height():int {
			return _height;
		}


		public function get offsetTop():int {
			return _offsetTop;
		}

		public function set offsetTop(value:int):void {
			_offsetTop = value;
			updateView();
		}

		public function get selectionPosition():int {
			return _selectionPosition;
		}

		public function set selectionPosition(value:int):void {
			_selectionPosition = value;
			updateView();
		}

		public function get width():int {
			return _width;
		}

		public function get prevID():String {
			return _prevID;
		}
	}
}