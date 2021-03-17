package com.dukascopy.connect.gui.tabs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * @author Ilya Shcherbakov
	 */
	
	public class NewTabs extends MobileClip {
		
		public var S_ITEM_SELECTED:Signal = new Signal('FilterTabs.S_ITEM_SELECTED');
		
		private var stock:Array/*TabsItemSmileSticker*/;
		
		private var container:Sprite;
		
		private var _width:int;
		private var _height:int;
		
		private var tabW:int = Config.FINGER_SIZE;
		private var tabH:int;
		
		private var indexSelected:int = -1;
		
		private var downX:int;
		private var downY:int;
		
		private var startX:int;
		private var startY:int;
		
		private var wasMove:Boolean;
		
		public var tapper:TapperInstance;
		
		public var busy:Boolean = false;
		
		public function NewTabs() {
			createView();
			
			stock = [];
		}
		
		private function createView():void {
			_view = new Sprite();
			
			container = new Sprite();
			_view.addChild(container);
			
			tapper = new TapperInstance(MobileGui.stage, container, onMoved, [_width, _height], 'x');
			tapper.setTapCallback(callTap);
			tapper.setDownCallback(onDown);
			tapper.setUpCallback(onUp);
		}
		
		private function onDown(...rest):void {
			TweenMax.killTweensOf(container);
		}
		
		private function onUp(...rest):void {
			tapper.stop()
			onMoved(true);
		}
		
		private function onMoved(scrollStopped:Boolean = false):void {
			checkBoxBounds(scrollStopped);
		}
		
		private function checkBoxBounds(scrollStopped:Boolean = false):void {
			if (scrollStopped == false)
				return;
			var tx:Number = -1;
			TweenMax.killTweensOf(container);
			if (container.x + container.width < _width)
				tx = _width - container.width;
			else if (container.x > 0)
				tx = 0;
			if (tx != -1)
				TweenMax.to(container, 15, { useFrames:true, x:tx } );
		}
		
		public function add(name:String, id:String, selected:Boolean = false, icon:MovieClip = null, ibmd:ImageBitmapData = null):void {
			if (stock == null)
				return;
			var i:TabsItemSmileSticker = getItemById(id);
			if (i != null)
				return;
			if (selected == true) {
				if (indexSelected != -1)
					stock[indexSelected].selection = false;
				indexSelected = stock.length;
			}
			container.addChild(stock[stock.push(new TabsItemSmileSticker(name, id, selected, icon, ibmd)) - 1].getView());
		}
		
		public function callTap(e:Event):void {
			
			if (stock == null || stock.length == 0)
				return;
			if (busy == true)
				return;
			var trueX:int = _view.mouseX - container.x;
			if (trueX < 0)
				trueX = 0;
			var index:int = (trueX / stock[0].getView().width);
			if (index >= stock.length)
				index = stock.length - 1;
			if (indexSelected == index)
				return;
			if (indexSelected != -1) {
				stock[indexSelected].selection = false;
				stock[indexSelected].rebuild(tabW, _height);
			}
			indexSelected = index;
			stock[index].selection = true;
			stock[index].rebuild(tabW, _height);
			S_ITEM_SELECTED.invoke(stock[index].id);
			
			updatePosition();
			
		}
		
		public function updateSelected(index:int):void {
			if (indexSelected != -1) {
				stock[indexSelected].selection = false;
				stock[indexSelected].rebuild(tabW, _height);
			}
			indexSelected = index;
			stock[index].selection = true;
			stock[index].rebuild(tabW, _height);
			S_ITEM_SELECTED.invoke(stock[index].id);
			
			updatePosition();
		}
		
		private function updatePosition():void {
			if (container.getChildAt(indexSelected).x + container.x < 0) {
				container.x = -container.getChildAt(indexSelected).x;
				return;
			}
			if (container.getChildAt(indexSelected).x + container.getChildAt(indexSelected).width + container.x > _width) {
				container.x = _width - (container.getChildAt(indexSelected).x + container.getChildAt(indexSelected).width);
				return;
			}
		}
		
		public function setWidthAndHeight(w:int, h:int):void {
			if (_width == w && _height == h)
				return;
			
			_width = w;
			_height = h;
			
			_view.graphics.clear();
			_view.graphics.beginFill(0, 0);
			_view.graphics.drawRect(0, 0, _width, _height);
			_view.graphics.endFill();
			
			updateView();
		}
		
		private function updateView():void{
			var l:int = stock.length;
			var x:int = 0;
			
			for (var i:int = 0; i < l; i++) {
				stock[i].rebuild(tabW, _height);
				stock[i].getView().x = x;
				x += stock[i].getView().width;
			}
		}
		
		private function getItemById(id:String):TabsItemSmileSticker {
			if (stock == null)
				return null;
			var m:int = stock.length;
			while (m--){
				if (stock[m].id == id)
					return stock[m];
			}
			return null;
		}
		
		public function get height():int {
			return _height;
		}
		
		override public function dispose():void {
			deactivate();
			S_ITEM_SELECTED.dispose();
			super.dispose();
			if (stock != null) {
				while (stock.length != 0) {
					stock[0].dispose();
					stock.splice(0, 1);
				}
			}
			stock = null;
		}
		
		public function activate():void {
			tapper.activate();
		}
		
		public function deactivate():void {
			tapper.deactivate();
		}
		
		public function getLastIndex():int {
			return stock.length - 1;
		}
	}
}