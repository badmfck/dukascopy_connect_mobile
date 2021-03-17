package com.dukascopy.connect.gui.list {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	
	public class ExpandedList extends List {
		
		public var S_ASK_REFRESH:Signal = new Signal('ExpandedList.S_ASK_REFRESH');
		public var page:int = 0;
		public var totalPages:int = 0;
		
		private var loader:Preloader;
		private var yBeforeRefresh:Number;
		
		private var _isLoading:Boolean = false;
		
		private var ADITIONAL_HEIGT_FOR_SPINNER:int = Config.FINGER_SIZE*1.5;
		private var BOTTOM_OVERSCROLL_TO_LOAD:int = Config.FINGER_SIZE_DOUBLE;
		
		public function ExpandedList(name:String) {
			super(name);
			loader = new Preloader(Config.FINGER_SIZE * .4);
			_view.addChildAt(loader, 0);
		}
		
		override protected function onUp():void {		
			if (Math.abs(super.bottomOverscrollOnDown) >= BOTTOM_OVERSCROLL_TO_LOAD && hasPagination()) {
				askRefresh();	
				isLoading = true;
			}
			super.onUp();
		}
		
		private function onLoadingStateChanged():void {			
			if (_isLoading) {
				loader.startAnimation();
				super.additionalBottomHeight = ADITIONAL_HEIGT_FOR_SPINNER;
			} else {
				loader.visible = false;
				loader.stopAnimation();	
				super.additionalBottomHeight = 0;
			}
		}
		
		private function hasPagination():Boolean {
			return page != totalPages;
		}
		
		override public function setData(data:Object, itemRendererClass:Class, fieldLinkNames:Array = null, side:String = null, animateFieldNames:Array = null):void {
			yBeforeRefresh = 0;
			super.setData(data, itemRendererClass, fieldLinkNames, side);
		}
		
		public function appendData(data:Object, itemRendererClass:Class, fieldLinkNames:Array = null, side:String = null):void {
			var cachedY:Number = lastY;
			super.setData(data, itemRendererClass, fieldLinkNames, side);
			setBoxY(cachedY);
			isLoading = false;
			super.bringBackIntoBounds();
		}
		
		public function reset():void {
			page = 0;
			yBeforeRefresh = 0;
		}
		
		override protected function onMoved(scrollStopped:Boolean = false, redrawVisible:Boolean = false, recalculateHeight:Boolean = false, animate:Boolean = false, excludeAnimationPosition:int = -1):void {
			if (isDisposed)
				return;
			super.onMoved(scrollStopped, redrawVisible, recalculateHeight);
			if (loader != null) {
				if (isLoading) {	
					loader.visible = true;
					var bottomSpace:int = Math.max(ADITIONAL_HEIGT_FOR_SPINNER * .5, Math.abs(super.bottomOverscroll) * .5);				
					loader.y = int(innerHeight + lastY + bottomSpace);
				} else {
					if (hasPagination() == false) {
						loader.visible = false;
						return;
					}
					var bottomLimit:int = Math.max(ADITIONAL_HEIGT_FOR_SPINNER * .5, Math.abs(super.bottomOverscroll) * .5);					
					if (Math.abs(super.bottomOverscroll) > 5){
						loader.visible = true;
						loader.y = int(innerHeight + lastY +bottomLimit);
					} else {
						loader.visible = false;
					}
				}
			}
		}
		
		public function get swipedToExpand():Boolean {
			return height - innerHeight > lastY - loader.height + Config.FINGER_SIZE && page < totalPages;
		}
		
		override public function updateView(recalHeight:Boolean = false):void {
			super.updateView(recalHeight);
			loader.x = int((this.width - loader.width) * 0.5);
		}
		
		private function askRefresh():void {
			S_ASK_REFRESH.invoke();
		}
		
		public function get isLoading():Boolean {return _isLoading;}		
		public function set isLoading(value:Boolean):void {
			if (_isLoading == value) return;
			_isLoading = value;
			onLoadingStateChanged();
		}
		
		override public function getBottomScroll():Number {
			return Math.max(_innerHeight + box.y - height + 300, 0);
		}
		
		override public function dispose():void {
			super.dispose();
			loader.dispose();
			loader = null;
		}
	}
}