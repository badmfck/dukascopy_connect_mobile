package com.dukascopy.connect.gui.list {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.listItemContextItem.ListItemContextClip;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.contextActions.ContextAction;
	import com.dukascopy.connect.sys.contextActions.ContextCollectionBuilder;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.pool.IPoolItem;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.getTimer;


	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class List extends MobileClip implements IPoolItem {
		
		public var S_ITEM_TAP:Signal = new Signal('List.S_ITEM_TAP');
		public var S_ITEM_DOUBLE_CLICK:Signal = new Signal('List.S_ITEM_DOUBLE_CLICK');
		public var S_ITEM_HOLD:Signal = new Signal('List.S_ITEM_HOLD');
		public var S_MOVING:Signal = new Signal('List.S_MOVING');
		public var S_STOPED:Signal = new Signal('List.S_STOPED');
		public var S_TAP:Signal = new Signal('List.S_TAP');
		public var S_STOP_UPPER_CONTENT:Signal = new Signal('List.S_STOP_UPPER_CONTENT');
		public var S_SHOW_UPPER_CONTENT:Signal = new Signal('List.S_SHOW_UPPER_CONTENT');
		public var S_HIDE_UPPER_CONTENT:Signal = new Signal('List.S_HIDE_UPPER_CONTENT');
		public var S_UP:Signal = new Signal('List.S_UP');
		public var S_DOWN:Signal = new Signal('List.S_DOWN');
		public var S_ITEM_SWIPE:Signal = new Signal('List.S_ITEM_SWIPE');
		
		protected var _innerHeight:int;
		
		protected var _width:int = 320;
		protected var _height:int = 240;
		
		protected var box:Sprite;
		private var mask:Shape;
		private var bg:Shape;
		private var scrollBar:Shape;
		
		protected var stock:/*ListItem*/Array = [];
		
		protected var currentRenderer:IListRenderer;
		protected var otherRenderers:Array;
		private var _inUse:Boolean;
		private var tapper:TapperInstance;
		
		protected var _data:Object;
		private var isUnderMask:Boolean;
		
		private var inMovementPhase:Boolean;
		private var needToRefresh:Boolean;
		private var needToRefreshHeight:Boolean;
		private var _background:Boolean = false;
		
		
		protected var _isDown:Boolean = false;
		protected var bottomOverscroll:int = 0;
		protected var bottomOverscrollOnDown:int = 0;
		protected var additionalBottomHeight:int = 0;
		
		protected var vspace:int = 0;
		
		protected var lastY:Number = 0;
		private var state:String = 'unknown';
		private var startY:int;
		private var checkOffset:Boolean;
		private var _backgroundColor:uint=0xFFFFFF;
		protected var _name:String;
		private var _followContent:Boolean = false;
		
		protected var delayedData:Object = null;
		protected var isViewBusy:Boolean = false;
		private var _isActive:Boolean;
		private var isContextAvaliable:Boolean = false;
		private var lastItemTouchedIndex:int = -1;
		private var lastItemTouchXPosition:int;
		private var contextMenuShown:Boolean = false;
		
		protected var itemRendererClass:Class;
		private var _listItemClass:Class = ListItem;
		
		private var contextItemData:Vector.<ContextAction>;
		private var contextItem:ListItemContextClip;
		private var inContextMovingPhaze:Boolean = false;
		private var currentItemWithContextMenu:ListItemView;
		private var contextMenuTimeHide:Number = 0.2;
		private var contextMenuTimeShow:Number = 0.3;
		private var hideContextMenuPhaze:Boolean;
		private var lastContextDirection:String;
		private var inTweenAnimationState:Boolean;
		protected var animateFieldNames:Array;
		
		private var firstVisibleItem:ListItem;
		private var firstVisibleItemIndex:int;
		private var _topActivityPadding:int = -1;
		private var _stickToBottom:Boolean;
		private var isSmallListMoveAllowed:Boolean = false;
		private var overlayReaction:Boolean = true;
		private var fadeToAlpha:Boolean;
		public var newMessageAnimationTime:Number = .25;
		
		public function List(name:String) {
			_name = name;
			_view = new Sprite();
			
			contextItem = new ListItemContextClip();
			
			box = new Sprite();
			_view.addChild(box);
			
			box.buttonMode = true;
			
			tapper = new TapperInstance(MobileGui.stage, box, onMovedByTapper, [_width, _height]);
			tapper.setBounds([_width, _height]);
			_view.graphics.clear();
			_view.graphics.beginFill(0x00CC13);
			_view.graphics.drawRect(0, 0, _width, _height);
			
			scrollBar = new Shape();
			scrollBar.alpha = 0;
			_view.addChild(scrollBar);
			_view.addChild(contextItem);
		}
		
		public function setContextAvaliable(isContextAvaliable:Boolean):void {
			this.isContextAvaliable = isContextAvaliable;
			tapper.listenOppositeMoving(isContextAvaliable);
			if (_isActive) {
				if (isContextAvaliable)
					tapper.S_MOVING_OPPOSITE.add(onContextMove);
				else
					tapper.S_MOVING_OPPOSITE.remove(onContextMove);
			}
		}
		
		private function updateContextItemData(itemData:Object):void {
			if (contextItem)
				contextItem.visible = false;
			if (!itemRendererClass)
				return;
			var oldContext:Vector.<ContextAction> = contextItemData;
			contextItemData = ContextCollectionBuilder.getContextActions(itemRendererClass, itemData);
			if (!equalContext(contextItemData, oldContext)) {
				clearCurrentContextItem();
				createContextItem();
			}
			oldContext = contextItemData;
		}
		
		private function createContextItem():void {
			contextItem.setData(contextItemData);
		}
		
		private function equalContext(newContext:Vector.<ContextAction>, oldContext:Vector.<ContextAction>):Boolean {
			if (!newContext && !oldContext)
				return true;
			if (!newContext || !oldContext)
				return false;
			if (newContext.length != oldContext.length)
				return false;
			var exist:int = 0;
			for (var i:int = 0; i < newContext.length; i++) {
				for (var j:int = 0; j < oldContext.length; j++) {
					if (newContext[i].type == oldContext[j].type) {
						exist ++;
						break;
					}
				}
			}
			if (exist == newContext.length)
				return true;
			return false;
		}
		
		private function clearCurrentContextItem():void {
			if (contextItem)
				contextItem.clear();
		}
		
		private function hideContextMenu():void {
			if (hideContextMenuPhaze)
				return;
			
			if (lastItemTouchedIndex != -1) {
				hideContextMenuPhaze = true;
				var item:ListItemView = stock[lastItemTouchedIndex].liView;
				if (!item)
					return;
				TweenMax.killTweensOf(item);
				TweenMax.to(item, contextMenuTimeHide, { x: 0, onUpdate:onContextHideAnimation, onComplete: function():void { unblockListScroll(); }} );
			}
		}
		
		protected function onContextMove(position:Number, scrollStopped:Boolean = false):void {
			if (_data == null)
				return;
			if (hideContextMenuPhaze || inTweenAnimationState || tapper.isFrame)
				return;
			inMovementPhase = true;
			Overlay.removeCurrent();
			var item:ListItemView;
			
			if (lastItemTouchedIndex != -1) {
				item = stock[lastItemTouchedIndex].liView;
				
				if (!inContextMovingPhaze && lastItemTouchXPosition - position < 0) {
					updateContextItemData(stock[lastItemTouchedIndex].data);
					if (!contextItemData || contextItemData.length == 0)
					{
						inMovementPhase = false;
						return;
					}
					
					inContextMovingPhaze = true;
					contextItem.draw(item.height, item.width);
					contextItem.visible = true;
					contextItem.x = _width - contextItem.getWidth();
					contextItem.y = _view.globalToLocal(box.localToGlobal(new Point(0, item.y))).y;
					blockListScroll();
				}
				else if (inContextMovingPhaze)
				{
					contextItem.onResize(Math.min(position, Config.FINGER_SIZE));
				}
				
				if (lastItemTouchXPosition - position < 0) {
					TweenMax.killTweensOf(item);
					if (item.x > (lastItemTouchXPosition - position))
						lastContextDirection = "opening";
					else if(item.x < (lastItemTouchXPosition - position))
						lastContextDirection = "closing";
					item.x = lastItemTouchXPosition - position;
					blockListScroll();
					setContextHitzone(lastItemTouchedIndex);
				} else {
					inContextMovingPhaze = false;
					lastContextDirection = "closed";
					item.x = 0;
					inMovementPhase = false;
				}
			}
			
			if (scrollStopped) {
				if (inContextMovingPhaze && item && item.x != 0) {
					currentItemWithContextMenu = item;
					if (lastContextDirection == "opening") {
						if (item.x < -Config.FINGER_SIZE_DOT_25) {
							TweenMax.killTweensOf(item);
							
							if (contextItem.isSwipeNow())
							{
								callSwipeAction(lastItemTouchedIndex);
								TweenMax.to(item, contextMenuTimeShow, { x: 0, onUpdate:onContextHideAnimation, onComplete:function():void { unblockListScroll(); inMovementPhase = false; } } );
							}
							else
							{
								TweenMax.to(item, contextMenuTimeShow, { x: -contextItem.getWidth(), onComplete:function():void { setContextHitzone(lastItemTouchedIndex); inMovementPhase = false; } } );
							}
							
							blockListScroll();
							return;
						}
						else if(item.x < 0) {
							blockListScroll();
							TweenMax.killTweensOf(item);
							TweenMax.to(item, contextMenuTimeHide, { x: 0, onUpdate:onContextHideAnimation, onComplete: function():void { unblockListScroll(); inMovementPhase = false; }} );
							return;
						} else {
							unblockListScroll(); 
							inMovementPhase = false;
						}
					}
					else if (lastContextDirection == "closing") {
						if (item.x > -(contextItem.getWidth()-Config.FINGER_SIZE_DOT_25)) {
							blockListScroll();
							TweenMax.killTweensOf(item);
							TweenMax.to(item, contextMenuTimeHide, { x: 0, onUpdate:onContextHideAnimation, onComplete: function():void { unblockListScroll(); inMovementPhase = false; }} );
							return;
						}
						else if(item.x < 0){
							TweenMax.killTweensOf(item);
							if (contextItem.isSwipeNow())
							{
								TweenMax.to(item, contextMenuTimeShow, { x: 0, onComplete:function():void { unblockListScroll(); inMovementPhase = false; } } );
							}
							else
							{
								TweenMax.to(item, contextMenuTimeShow, { x: -contextItem.getWidth(), onComplete:function():void { setContextHitzone(lastItemTouchedIndex); inMovementPhase = false; } } );
							}
							blockListScroll();
							return;
						} else {
							unblockListScroll(); 
							inMovementPhase = false;
						}
					}
				} else {
					unblockListScroll();
				}
				
				inContextMovingPhaze = false;
			}
		}
		
		private function callSwipeAction(index:int):void 
		{
			if (lastItemTouchedIndex != -1) {
				S_ITEM_SWIPE.invoke(stock[lastItemTouchedIndex]);
			}
		}
		
		private function setContextHitzone(itemIndex:int):void { }
		
		private function unblockListScroll():void {
			setDefaultHitzone(lastItemTouchedIndex);
			if (contextItem)
				contextItem.visible = false;
			hideContextMenuPhaze = false;
			lastItemTouchedIndex = -1;
			inContextMovingPhaze = false;
			contextMenuShown = false;
			if (tapper != null)
			{
				tapper.setTapCallback(onTapped);
				tapper.setDownCallback(onItemTouchStart);
				tapper.setSwipeCallBack(onSwipe);
				tapper.setHoldCallback(onHold);
				tapper.setUpCallback(onUp);
				tapper.setMoveCallback(onMovedByTapper);
				tapper.setLockMove(false);
			}
		}
		
		public function allowSmallListMove(value:Boolean):void {
			isSmallListMoveAllowed = value;
		}
		
		private function onMovedByTapper(val:Boolean):void {
			_scrolledToBottom = false;
			if (_innerHeight < _height && isSmallListMoveAllowed == false) {
				if (_stickToBottom == true)
					box.y = _height - _innerHeight;
				else
					box.y = 0;
				tapper.stop();
				return;
			}
			onMoved(val);
			
			clearOverlayPending();
		}
		
		private function clearOverlayPending():void 
		{
			TweenMax.killDelayedCallsTo(displayOverlay);
		}
		
		private function displayOverlay(item:ListItemView, listItem:ListItem):void 
		{
			if (listItem == null || listItem.isDisposing == true || box == null || listItem.liView == null || listItem.renderer == null)
			{
				return;
			}


			var touchPoint:Point = new Point(box.mouseX, box.mouseY);
			var globalTouchPoint:Point = box.localToGlobal(touchPoint);
			
			var itemTouchPoint:Point = listItem.liView.globalToLocal(globalTouchPoint);
			
			var zone:HitZoneData = listItem.renderer.getSelectedHitzone(itemTouchPoint, listItem);
			
			if (zone == null)
			{
				zone = new HitZoneData();
				var startZonePoint:Point = new Point(item.x, item.y);
				startZonePoint = box.localToGlobal(startZonePoint);
				zone.x = startZonePoint.x;
				zone.y = startZonePoint.y;
				zone.width = item.width;
				zone.height = item.height;
			}
			else{
				var zoneStart:Point = new Point(zone.x + listItem.liView.x, zone.y + listItem.liView.y);
				zoneStart = box.localToGlobal(zoneStart);
				zone.x = zoneStart.x;
				zone.y = zoneStart.y;
			}
			
			zone.touchPoint = globalTouchPoint;
			
			if (view.parent != null)
			{
				var visibilityStart:Point = new Point(view.x, view.y);
				visibilityStart = view.parent.localToGlobal(visibilityStart);
				zone.visibilityRect = new Rectangle(visibilityStart.x, visibilityStart.y, width, height);
			}
			
			Overlay.displayTouch(zone);
		}
		
		private function setDefaultHitzone(itemIndex:int):void { }
		
		protected function onUp():void {
			_isDown = false;
			if (hideContextMenuPhaze)
				return;
			if (inContextMovingPhaze) {
				if (lastItemTouchedIndex != -1) {
					var item:ListItemView = stock[lastItemTouchedIndex].liView;
					if (!item)
						return;
					if (inContextMovingPhaze && item && item.x != 0) {
						if (item.x < -contextItem.getWidth()*.5) {
							TweenMax.killTweensOf(item);
							
							if (contextItem != null && contextItem.isSwipeNow())
							{
								TweenMax.to(item, contextMenuTimeHide, { x: 0, onUpdate:onContextHideAnimation, onComplete: function():void { unblockListScroll(); }} );
							}
							else
							{
								TweenMax.to(item, contextMenuTimeShow, { x: -contextItem.getWidth() } );
							}
							blockListScroll();
							return;
						} else {
							blockListScroll();
							TweenMax.killTweensOf(item);
							TweenMax.to(item, contextMenuTimeHide, { x: 0, onUpdate:onContextHideAnimation, onComplete: function():void { unblockListScroll(); }} );
							return;
						}
					} else {
						unblockListScroll();
					}
					inContextMovingPhaze = false;
				}
			}
			if (S_UP != null)
				S_UP.invoke();
		}
		
		private function onContextHideAnimation():void 
		{
			if (isDisposed)
			{
				return;
			}
			if (contextItem != null && contextItem.visible == true)
			{
				var item:ListItemView
				if (stock[lastItemTouchedIndex] && stock[lastItemTouchedIndex].liView)
				{
					item = stock[lastItemTouchedIndex].liView;
				}
				if (item)
				{
					contextItem.onResize(Math.min(-item.x, Config.FINGER_SIZE));
				}
			}
		}
		
		private function blockListScroll():void {
			contextMenuShown = true;
			if (tapper != null) {
				tapper.setSwipeCallBack(null);
				tapper.setHoldCallback(null);
				tapper.setMoveCallback(null);
				tapper.setLockMove(true);
			}
		}
		
		public function set background(val:Boolean):void {
			_background = val;
			updateView();
		}
		
		public function setMask(val:Boolean):void {
			isUnderMask = val;
			updateView();
		}
		
		public function setWidthAndHeight(width:int, height:int, needToMove:Boolean = true):void {

			if (_width == width && _height == height) {

				return;
			}
			var recalHeight:Boolean = width != _width;

			_width = width;
			_height = height;
			if (recalHeight == true)
				updateView(true);
			else
				updateViewAfterHeightChanged(needToMove);

		}
		
		private var destinationY:int;
		private var _scrolledToBottom:Boolean = false;
		private var lastItemTapped:int;
		private var lastTapTime:int;
		private var doubleClickTimeout:Number = 600;
		public function scrollBottom(animate:Boolean = false):void {
			_scrolledToBottom = true;
			TweenMax.killTweensOf(box);
			var trueHeight:int = _innerHeight + additionalBottomHeight;
			if (_stickToBottom == true) {
				if (trueHeight < _height)
					return;
			}
			destinationY = -(trueHeight - _height);
			if (animate) {
				TweenMax.to(box, newMessageAnimationTime, { useFrames:false, y:destinationY, onUpdate:sbTweenMaxUpdate, onComplete:sbTweenMaxComplete } );
			} else {
				box.y = destinationY;
				onMoved(true);
			}
		}
		
		private function sbTweenMaxUpdate():void {
			var temp:int = -(_innerHeight + additionalBottomHeight - _height);
			if (destinationY > temp) {
				destinationY = temp;
				TweenMax.killTweensOf(box);
				TweenMax.to(box, newMessageAnimationTime, { useFrames:false, y:destinationY, onUpdate:sbTweenMaxUpdate, onComplete:sbTweenMaxComplete } );
			}
			onMoved();
		}
		
		private function sbTweenMaxComplete():void {
			_scrolledToBottom = false;
			onTweenMovingComplete();
		}
		
		/**
		 * Get element from array by index and set list position to this element
		 * @param	index	int - element index in data array
		 */
		public function navigateToItem(index:int):void {
			if (_data == null || _data.length==null)
				return;
			var itm:ListItem = stock[index];
			if (itm != null) {
				box.y = int(-itm.y);
				onMoved(true);
			}
		}
		
		public function updateView(recalHeight:Boolean = false):void {
			updateBackground();
			updateTapper();
			setScrollBarSize();
			
			onMoved(true, true, recalHeight);
		}
		
		protected function updateViewAfterHeightChanged(needToMove:Boolean):void {
			updateBackground();
			updateTapper();
			setScrollBarSize();
			
			if (needToMove)
				onMoved(true, false, false);
		}
		
		private function updateTapper():void {
			if (_isActive){
				var bounds:Array;
				if (_topActivityPadding != -1 && view.parent && view.parent) {
					
					bounds = [
								_width, 
								_height - _topActivityPadding, 
								view.parent.localToGlobal(new Point(view.x, view.y)).x, 
								view.parent.localToGlobal(new Point(view.x, view.y)).y + _topActivityPadding];
				}
				else {
					bounds = [_width, _height];
				}
				tapper.setBounds(bounds);
			}
		}
		
		public function setActivityPadding(value:int, type:String = "top"):void {
			if (type == "top") {	
				_topActivityPadding = value;
				updateTapper();
			}
		}
		
		private function updateBackground():void 
		{
			_view.graphics.clear();
			_view.graphics.beginFill(_backgroundColor,(_background==true)?1:0);
			_view.graphics.drawRect(0, 0, _width, _height);
			if (isUnderMask == true){
				// REBUILD MASK;
				if (mask == null){
					mask = new Shape();
					mask.graphics.beginFill(0);
					mask.graphics.drawRect(0, 0, 100, 100);
					view.mask = mask;
					_view.addChild(mask);
				}
				mask.width = _width;
				mask.height = _height;
			}else {
				if (isUnderMask == false && mask != null) {
					mask.graphics.clear();
					if (mask.parent != null)
						mask.parent.removeChild(mask);
					mask = null;
					view.mask = null;
				}
			}
		}
		
		
		/**
		 * Add item to list
		 * @param	data Object - dataObjec
		 * @param	itemRendererClass	- Class - renderer
		 * @param	fieldLinkNames	-Array 
		 * @return
		 */
		public function appendItem(
			itemData:Object,
			itemRendererClass:Class = null, 
			fieldLinkNames:Array = null,
			appendToDataCollection:Boolean = false, 
			animate:Boolean = false,
			position:int = -1,
			animationDelay:Number = 0,
			refreshStartPosition:Boolean = false):void {
				if (currentRenderer == null && itemRendererClass == null)
					return;
				if (appendToDataCollection) {
					if (data && "length" in data) {
						if (position != -1 && data.length > position) {
							data.insertAt(position, itemData);
						} else {
							data.push(itemData);
						}
					}
				}
				this.itemRendererClass = itemRendererClass;
				var rend:IListRenderer;
				if (currentRenderer != null && currentRenderer is itemRendererClass)
					rend = currentRenderer;
				if (otherRenderers != null) {
					var orL:int = otherRenderers.length;
					for (var i:int = 0; i < orL; i++) {
						if (otherRenderers[i] is itemRendererClass) {
							rend = otherRenderers[i];
							break;
						}
					}
				}
				if (rend == null) {
					rend = new itemRendererClass();
					otherRenderers ||= [];
					otherRenderers.push(rend);
				}
				if (stock == null)
					stock = [];
				if (_innerHeight == 0)
					_innerHeight = vspace;
				var positionY:int;
				if (stock == null || position == -1 || position > stock.length - 1) {
					positionY = _innerHeight;
				} else {
					positionY = stock[position].y;
				}
				var li:ListItem = addElementToStock(fieldLinkNames, positionY, rend, itemData, position);
				if (animate == true)
					li.animate(animationDelay);
				
				_innerHeight += li.height;
				if (inMovementPhase == false)
					onMoved(true, false, false, animate, position);
				setBoundsBoxes();
				setScrollBarSize();
		}
		
		protected function addElementToStock(fieldLinkNames:Array, y:int, rend:IListRenderer, data:Object, position:int = -1):ListItem {
			var li:ListItem = new _listItemClass(
				_name,
				y,
				stock.length,
				_width,
				rend,
				data,
				this,
				fieldLinkNames,
				animateFieldNames
			);
			if (position != -1)
			{
				stock.insertAt(position, li);
				return li;
			}
			return stock[stock.push(li) - 1];
		}
		
		public function setBoundsBoxes():void {
			box.graphics.clear();
			box.graphics.beginFill(0xFF0000, Capabilities.isDebugger ? 1 : 0);
			box.graphics.drawRect(0, 0, 10, 10);
			box.graphics.endFill();
			box.graphics.beginFill(0xFF0000, 0);
			box.graphics.drawRect(_width - 10, _innerHeight - 10, 10, 10);
		}
		
		public function setData(data:Object, itemRendererClass:Class, fieldLinkNames:Array = null, side:String = null, animateFieldNames:Array = null):void {
			this.itemRendererClass = itemRendererClass;
			this.animateFieldNames = animateFieldNames;
			TweenMax.killTweensOf(box);
			clear();
			_data = data;
			
			// CALCULATE HEIGHT AND BUILD
			if (currentRenderer != null) {
				if (itemRendererClass == null || !(currentRenderer is itemRendererClass) || currentRenderer != itemRendererClass) {
					currentRenderer.dispose();
					currentRenderer = null;
				}
			}
			
			box.y = 0;
			
			// DO CLEAR
			if (side==null && (_data == null || !_data.length)) {
				isViewBusy = false;
				delayedData = null;
				box.visible = true;
				return;
			}
			
			if (isViewBusy) {
				delayedData = [data,itemRendererClass,fieldLinkNames,side];
				return;
			}
			
			// DO SIDE MOVE
			// CREATE BITMAP WITH OLD LIST
			if (side != null) {
				isViewBusy = true;
			}
			if (_data != null) {
				if (currentRenderer == null)
					currentRenderer = new itemRendererClass();
				
				// CALCULATE HEIGHT
				var y:int = vspace;
				var l:int =_data.length;
				var n:int = 0;
				var i:ListItem;
				stock = [];
				
				for (n; n < l; n++) {
					i = addElementToStock(fieldLinkNames, y, currentRenderer, data[n]);
					if (y < _height){
						i.draw(_width, true);
						if (i.liView != null) {
							box.addChild(i.liView);
							i.scrollStoppedShow();
						}
					}
					y += i.height;
				}
				
				_innerHeight = y;
			} else
				_innerHeight = vspace;
			
			
			setBoundsBoxes();
			setScrollBarSize();
			
			TweenMax.delayedCall(1, function():void {
				if (box == null)
					return;
				S_MOVING.invoke(box.y);
				S_STOPED.invoke(box.y);
			}, null, true);
		}
		
		private function itemImageLoaded(num:int):void {
			if (stock == null) {
				// 1:4 TODO - List.itemImageLoaded called, but item disposed. Need to stop loading images when dispose
				return;
			}
			var li:ListItem = stock[num];
			if (li == null) {
				// 2:4 TODO - List.itemImageLoaded called, but item disposed. Need to stop loading images when dispose
				return;
			}
			
			if (li.liView != null && li.liView.visible == true) {
				li.liView.draw('listitem.', num, _width, li.height, true);
				li.liView.render(currentRenderer.getView(li, li.height, _width));
			}
		}
		
		public function activate():void {
			inMovementPhase = false;
			hideContextMenuPhaze = false;
			_isActive = true;
			if (tapper != null)
			{
				tapper.activate();
				
				var bounds:Array;
				if (_topActivityPadding != -1 && view.parent && view.parent) {
					
					bounds = [
								_width, 
								_height - _topActivityPadding, 
								view.parent.localToGlobal(new Point(view.x, view.y)).x, 
								view.parent.localToGlobal(new Point(view.x, view.y)).y + _topActivityPadding];
				}
				else {
					bounds = [_width, _height];
				}
				tapper.setBounds(bounds);
				
				tapper.setTapCallback(onTapped);
				tapper.setDownCallback(onItemTouchStart);
				tapper.setUpCallback(onUp);
				tapper.setSwipeCallBack(onSwipe);
				tapper.setHoldCallback(onHold);
				
				if (isContextAvaliable)
				{
					tapper.S_MOVING_OPPOSITE.add(onContextMove);
				}
				else {
					tapper.S_MOVING_OPPOSITE.remove(onContextMove);
				}
			}
		}
		
		private function onItemTouchStart(e:Event):void
		{
			S_DOWN.invoke();
			_isDown = true;
			TweenMax.killTweensOf(box);			
			var item:ListItemView;
			if (isViewBusy == true)
				return;
			
			// FIND ITEM UNDER TAP!
			var my:int = box.mouseY;
			var l:int = stock.length;
			var iN:int =-1;
			for (var n:int = 0; n < l; n++) {
				var li:ListItem = stock[n];
				item = li.liView;
				if (item == null)
					continue;
				if (item.visible == false)
					continue;
					
				if (my >= item.y && my < item.y + item.height) {
					iN = n;
					break;
				}
			}
			if (hideContextMenuPhaze)
				return;
			if (contextMenuShown) {
				if (lastItemTouchedIndex != iN && lastItemTouchedIndex != -1) {
					hideContextMenu();
					return;
				}
			}
			if (iN == -1)
				return;
			if (!contextMenuShown)
				lastItemTouchedIndex = iN;
			lastItemTouchXPosition = stock[lastItemTouchedIndex].liView.x;
			
			if (overlayReaction == true && !contextMenuShown)
			{
				
				var listItem:ListItem = stock[n];
				
				TweenMax.delayedCall(0.07, displayOverlay, [item, listItem]);
			}
		}
		
		public function setOverlayReaction(value:Boolean):void
		{
			overlayReaction = value;
		}
		
		private function onHold():void {
			if (inMovementPhase == true) {
				onTweenMovingComplete();
				return;
			}
			if (isViewBusy == true)
				return;
			if (stock == null || stock.length == 0)
				return;
			if (S_ITEM_HOLD.callBacksCount == 0)
				return;
			
			// FIND ITEM UNDER TAP!
			var my:int = box.mouseY;
			var l:int=stock.length;
			var iN:int = -1;
			var i:ListItemView;
			for (var n:int = 0; n < l; n++) {
				var li:ListItem = stock[n];
				i = li.liView;
				if (i == null)
					continue;
				if (i.visible == false)
					continue;
				if (my >= i.y && my < i.y + i.height) {
					iN = n;
					break;
				}
			}
			
			if (iN == -1)
				return;
			
			if (i != null && i.image.bitmapData != null && li.renderer != null) {
				i.image.bitmapData.fillRect(i.image.bitmapData.rect, 0);
				i.image.bitmapData.drawWithQuality(li.renderer.getView(li,stock[iN].height, _width, true), null, null, null, null, true, StageQuality.HIGH);
			}
			
			TweenMax.delayedCall(.1,onHoldDelayedComplete,[iN, li]);
		}
		
		private function onHoldDelayedComplete(iN:int, li:ListItem):void {

			if (stock == null || stock.length == 0)
				return;
			if (iN < 0)
				return;
			if (stock[iN] == null)
			{
				return;
			}
			var i:ListItemView = stock[iN].liView;
			if (i != null && i.image != null && i.image.bitmapData != null && li.renderer != null) {
				i.image.bitmapData.fillRect(i.image.bitmapData.rect, 0);
				i.image.bitmapData.drawWithQuality(li.renderer.getView(stock[iN], stock[iN].height, _width), null, null, null, null, true, StageQuality.HIGH);
			}
			if (S_ITEM_HOLD != null)
				S_ITEM_HOLD.invoke(stock[iN].data, iN);
		}
		
		private function onSwipe(swipeSpeed:Number):void {
			S_SHOW_UPPER_CONTENT.invoke();
		}
		
		public function updateItemByIndex(n:int, needToRecalculateHeight:Boolean = true, obligatory:Boolean = false, anyway:Boolean = false):void {
			if (stock[n] == null)
				return;
			if (needToRecalculateHeight == false) {
				if (inMovementPhase == true) {
					refresh(needToRecalculateHeight);
					return;
				}
				if (stock[n].liView != null && stock[n].liView.parent != null && stock[n].liView.visible == true)
				{
					stock[n].draw(_width);
					stock[n].scrollStoppedShow();
				}
				return;
			}
			var oldH:int = stock[n].height;
			stock[n].recalculateHeight();
			stock[n].wasLoading = false;
			stock[n].addImageFieldForLoading("imageThumbURLWithKey", false);
			stock[n].scrollStoppedShow();
			if (inMovementPhase == false)
				onMoved(true, false, false, false);
			var newH:int = stock[n].height;
			if (oldH != newH || anyway == true)
				refresh(true, obligatory);
			else
				refresh(false);
		}
		
		public function updateItem(obj:Object, needToRecalculateHeight:Boolean = true, anyway:Boolean = false):void {
			if (data != null)
			{
				var l:int = data.length;
				for (var n:int = 0; n < l; n++) {
					if (data[n] == obj){
						updateItemByIndex(n, needToRecalculateHeight, true, anyway);
						return;
					}
				}
			}
		}
		
		private function onTapped(e:Event):void {
			if (inMovementPhase == true) {
				onTweenMovingComplete();
				return;
			}
			if (isViewBusy == true)
				return;
			if (stock == null || stock.length == 0)
				return;
			if (e.target is ListItemView == false && e.target is ListItemContextClip == false)
				return;
			
			var i:ListItemView;
			
			// FIND ITEM UNDER TAP!
			var my:int = box.mouseY;
			var mx:int = box.mouseX;
			var l:int=stock.length;
			var iN:int=-1;
			for (var n:int = 0; n < l; n++) {
				var li:ListItem = stock[n];
				i = li.liView;
				if (i == null)
					continue;
				if (i.visible == false)
					continue;
					
				if (my >= i.y && my < i.y + i.height) {
					iN = n;
					break;
				}
			}
			
			var touchPoint:Point = new Point(e["localX"], e["localY"]);
			if (e && e.target is ListItemContextClip && i) {
				touchPoint = i.globalToLocal((e.target as ListItemContextClip).localToGlobal(touchPoint));
				touchPoint.x += i.x;
			}
			
			if (hideContextMenuPhaze)
			{
				clearOverlayPending();
				Overlay.removeCurrent();
				return;
			}
			
			var hzs:Array
			var hz:Object;
			if (contextMenuShown) {
				var contextMenuClicked:Boolean = false;
				if (iN != -1 && contextItem) {
					i = stock[iN].liView;
					if (i && mx > i.x + i.width) {
						hzs = contextItem.getHitZones();
						if (hzs != null) {
							for (var j:int = 0; j < hzs.length; j++) {
								hz = hzs[j];
								if (touchPoint.x >= hz.x && touchPoint.x <= hz.x + hz.width && touchPoint.y >= hz.y && touchPoint.y <= hz.y + hz.height) {
									stock[iN].setLastHitZone(hz);
									contextMenuClicked = true;
									break;
								}
							}
						}
					}
				}
				if (!contextMenuClicked) {
					stock[iN].setLastHitZone(null);
					hideContextMenu();
					return;
				}
			}
			if (iN == -1) {
				// NO ITEM, DO TAP
				S_TAP.invoke();
				return;
			}
			
			if (lastItemTouchedIndex != iN)
				return;
			
			// TODO - CHECK HIT ZONES IN RENDERED. PROBABLY WAS HIT ON SOME BUTTON
			// ITEM FOUNDED
			i = stock[iN].liView;
			if (contextMenuClicked == false) {
				hzs = stock[iN].getHitZones();
				if (hzs != null) {
					for (var j2:int = 0; j2 < hzs.length; j2++) {
						hz = hzs[j2];
						if (touchPoint.x >= hz.x && 
							touchPoint.x <= hz.x + hz.width && 
							touchPoint.y >= hz.y && 
							touchPoint.y <= hz.y + hz.height) {
								//stock[iN].setLastHitZone(hz.type);
								stock[iN].setLastHitZone(hz);
								break;
						}
					}
				}
			}
			//if (i != null && i.image.bitmapData != null) {
				//i.image.bitmapData.fillRect(i.image.bitmapData.rect, 0);
				//i.image.bitmapData.drawWithQuality(currentRenderer.getView(li,stock[iN].height, _width, true), null, null, null, null, true, StageQuality.HIGH);
			//}
			if (li != null)
				li.draw(li.width, true, true);
			
			var delayTime:Number = 0.1;
			if (Overlay.isAnimateNow())
			{
				delayTime = 0.3;
			}
			TweenMax.delayedCall(delayTime, onTapDelayedComplete, [iN]);
			
			if (lastItemTapped != -1 && lastItemTapped == iN && getTimer() - lastTapTime < doubleClickTimeout)
			{
				lastItemTapped = -1;
				if (S_ITEM_DOUBLE_CLICK != null && stock != null)
				{
					S_ITEM_DOUBLE_CLICK.invoke(stock[iN].data, iN);
				}
			}
			else
			{
				lastItemTapped = iN;
				lastTapTime = getTimer();
			}
		}
		
		private function onTapDelayedComplete(iN:int):void {

			if (stock == null || stock.length == 0)
				return;
			if (iN >= stock.length)
				return;
			/*var i:ListItemView = stock[iN].liView;
			if (i != null && i.image.bitmapData != null) {
				i.image.bitmapData.fillRect(i.image.bitmapData.rect, 0);
				i.image.bitmapData.drawWithQuality(currentRenderer.getView(stock[iN],stock[iN].height, _width), null, null, null, null, true, StageQuality.HIGH);
			}*/
			if (stock[iN] != null)
				stock[iN].draw(stock[iN].width);
			if (S_ITEM_TAP != null)
				S_ITEM_TAP.invoke(stock[iN].data, iN);
			if (S_TAP != null)
				S_TAP.invoke();
		}
		
		public function deactivate():void {
			inMovementPhase = false;
			_isActive = false;
			tapper.deactivate();
			tapper.setTapCallback(null);
			tapper.setDownCallback(null);
			tapper.setUpCallback(null);
			tapper.setSwipeCallBack(null);
			tapper.setHoldCallback(null);
			tapper.S_MOVING_OPPOSITE.remove(onContextMove);
		}
		
		// TAPER MOVEMENTS 
		protected function onMoved(scrollStopped:Boolean = false, redrawVisible:Boolean = false, recalculateHeight:Boolean = false, animate:Boolean = false, excludeAnimationPosition:int = -1):void {
			Overlay.removeCurrent();
			clearOverlayPending();
			if (stock == null)
				return;
			inMovementPhase = true;
			if (scrollStopped == false)
				scrollBar.alpha = 1;
			checkBoxBounds(scrollStopped);
			// FIND FIRST IN VISIBLE AREA
			var n:int = 0;
			var l:int = stock.length;
			var bmp:ListItemView;
			firstVisibleItem = null;
			firstVisibleItemIndex = -1;
			
			var endLen:int = l - 1;
			
			if (hideContextMenuPhaze)
				return;
			
			if (recalculateHeight == true)
				_innerHeight = vspace;
			var test:Boolean;
			for (n; n < l; n++) {
				//check item visibility
				var i:ListItem = stock[n];
				if (i == null)
					continue;
				if (recalculateHeight == true) {
					if (n == 0)
					{
						i.changeY(0)
					}
					i.recalculateHeight(_width);
					// height was changed, need to move next item, and change it Y
					var next:int = n + 1;
					if (next < l && stock[next] != null) {
						var nextItem:ListItem = stock[next];
						nextItem.changeY(i.y + i.height, animate);
					}
					_innerHeight += i.height;
				}
				
				// Y - position, H - height, n - number, null - bitmap
				bmp = i.liView;
				
				var iY:int = i.y + box.y;
				var iH:int = i.height;
				
				///////////////////////////////
				// CHECK FOR VISIBLE AREA -> //
				///////////////////////////////
				if (iY > -iH && iY < _height) {
					if (firstVisibleItem == null) {
						firstVisibleItemIndex = n;
						firstVisibleItem = i;
					}
					var needRedraw:Boolean = redrawVisible;
					if (needRedraw == false) {
						if (i.liView == null)
							needRedraw = true;
						else if (i.liView.image.bitmapData == null)
							needRedraw = true;
					}
					if (needRedraw == true) {
						i.draw(_width, scrollStopped);
						if (i.liView != null && i.liView.parent == null)
						{
							/*if (animate == true && excludeAnimationPosition != n)
							{
								i.animate();
							}*/
							box.addChild(i.liView);
						}
					}
					if (bmp != null && bmp.visible == false)
						bmp.visible = true;
					if (scrollStopped == true)
						i.scrollStoppedShow();
				} else {
					if (bmp != null && bmp.visible == true && animate == false)
					{
						bmp.visible = false;
					}
						
					if (scrollStopped == true)
						i.scrollStoppedHide();
				}
				
				if (bmp != null && bmp.visible == true && fadeToAlpha == true)
				{
					if (fadeToAlpha == true)
					{
						bmp.alpha = iY * 3 / height;
					}
					else
					{
						bmp.alpha = 1;
					}
				}
			}
			
			if (recalculateHeight == true) {
				setBoundsBoxes();
				setScrollBarSize();
			}
			
			listMoving(box.y);
			S_MOVING.invoke(box.y);
			if (scrollStopped == true) { 
				inMovementPhase = false;
				if (needToRefresh) {
					needToRefresh = false;
					refresh(needToRefreshHeight);
				}
				if (_stickToBottom == true) {
					if (_innerHeight < _height)
						box.y = _height - _innerHeight;
				}
				S_STOPED.invoke(box.y);
			}
		}
		
		private function listMoving(y:int):void {
			// DETECT CHANGE DIRECTION
			if (lastY > y){
				if (state == 'up' || state=='unknown') {
					state = 'down';	
					checkOffset = true;
					startY = y;
				}
			}
			if (lastY < y) {
				if (state == 'down' || state=='unknown') {
					state = 'up';	
					checkOffset = true;
					startY = y;
				}
			}
			var justFollow:Boolean = false;
			if (checkOffset == true) {
				var offset:int = startY - y;
				if (Math.abs(offset) > Config.FINGER_SIZE){
					checkOffset = false;
					if (state == 'up') {
						if (y < 0 && y > -(_innerHeight-_height))
							S_SHOW_UPPER_CONTENT.invoke();
								else
									state = 'unknown';
					} else {
						if (y < -vspace) {
							S_HIDE_UPPER_CONTENT.invoke();
						} else {
							state = 'unknown';
						}
					}
				}
			}
			
			if (y >= 0) {
				S_STOP_UPPER_CONTENT.invoke((_followContent==true)?y:0);
			}
			
			lastY = y;
		}
		
		public function clearState():void {
			state = "unknown";
			S_SHOW_UPPER_CONTENT.invoke();
		}
		
		private function checkBoxBounds(scrollStopped:Boolean = false):void {
			if (box.height <= _height && isSmallListMoveAllowed == false) {
				box.y = 0;
				scrollBar.alpha = 0;
				setInTweenAnimationState(false);
			} else {
				setInTweenAnimationState(true);
				if (scrollStopped == true) {
					bringBackIntoBounds(scrollStopped);
				} else {
					if (box.y > 0) {
						if (isSmallListMoveAllowed == false)
							box.y -= int(box.y * .4);
						else
							box.y -= int(box.y * .4);
					} else if (box.y + box.height + additionalBottomHeight < _height) {
						if (isSmallListMoveAllowed == true) {
							if (box.y < 0) {
								if (box.height <= _height)
									box.y -= int((box.y) * .4);
								else
									box.y -= int((box.y - (_height - box.height - additionalBottomHeight)) * .4);
							}
						} else {
							box.y -= int((box.y - (_height - box.height - additionalBottomHeight)) * .4);
						}
						if (isSmallListMoveAllowed == false) {
							bottomOverscroll = int(box.y - (_height - box.height));
							if (_isDown == true)
								bottomOverscrollOnDown = int(box.y - (_height - box.height));
							else
								bottomOverscrollOnDown = 0;
						}
					}
				}
			}
			var razn:Number = -box.y / (box.height - _height);
			scrollBar.y = (_height - scrollBar.height) * razn;
		}
		
		protected function bringBackIntoBounds(scrollStopped:Boolean = false):void {
			var trueBoxY:int = (box.height + additionalBottomHeight) - height;
			if (trueBoxY < 0)
				trueBoxY = 0;
			
			TweenMax.killTweensOf(scrollBar);
			TweenMax.to(
				scrollBar,
				10,
				{
					useFrames: true,
					alpha: 0
				}
			);
			
			if (box.y <= 0 && box.y >= -trueBoxY) {
				setInTweenAnimationState(false);
				return;
			}
			if (box.y > 0)
				trueBoxY = 0;
			else
				trueBoxY = -trueBoxY;
			TweenMax.to(
				box,
				10,
				{
					useFrames: true,
					y: trueBoxY,
					onUpdate: bbibTweenMaxUpdate,
					onComplete: bbibTweenMaxComplete
				}
			);
		}
		
		private function cbbTweenMaxUpdate():void {
			onMoved();
		}
		
		private function cbbTweenMaxComplete():void {
			onTweenMovingComplete();
		}
		
		private function setInTweenAnimationState(value:Boolean):void {
			if (inTweenAnimationState != value) {
				tapper.listenOppositeMoving(!value);
				inTweenAnimationState = value;
			}
		}
		
		protected function setScrollBarSize():void {
			var h:Number = (_height / box.height) * _height;
			scrollBar.graphics.clear();
			if (h < _height) {
				if (h < Config.FINGER_SIZE*.5)
					h = Config.FINGER_SIZE*.5;
				scrollBar.graphics.beginFill(0x7E95A8, .4);
				scrollBar.graphics.drawRect(0, 0, Config.FINGER_SIZE * .1, h);
			}
			scrollBar.x = int(( _width - scrollBar.width * 1.3) + .5);
		}
		
		private function onTweenMovingComplete():void {
			setInTweenAnimationState(false);
			onMoved(true);
		}
		// ------------------------------------------------------------------------- EOF TAPER MOVEMENTS
		
		protected function clear():void {
			setInTweenAnimationState(false);
			unblockListScroll();
			
			inContextMovingPhaze = false;
			hideContextMenuPhaze = false;
			inMovementPhase = false;
			if (tapper)
			{
				tapper.setLockMove(false);
			}
			contextMenuShown = false;
			lastItemTouchedIndex  = -1;
			
			if (box != null && box.parent != null){
				box.parent.removeChild(box);
				box = new Sprite();
				if (_view != null)
				{
					_view.addChild(box);
					_view.addChild(scrollBar);
				}
				if (tapper != null)
				{
					tapper.setMovingObject(box);
					tapper.setBounds();
				}
			}
			if (stock != null) {
				var toDispose:Array = [];
				var n:int = 0;
				var l:int = stock.length;
				_innerHeight = 0;
				for (n; n < l; n++) {
					stock[n].isDisposing = true;
					//toDispose.push(stock[n]);
					toDispose.insertAt(toDispose.length,stock[n]);
				}
				
				TweenMax.delayedCall(2, function(itemsToDispose:Array):void {

					var perFrame:int = 20;
					var start:int=0;
					var n:int;
					var strLen:int = itemsToDispose.length;
					
					var __onDispose:Function = function():void {
						if (start == strLen) {
							Loop.remove(__onDispose);
							return;
						}
						
						var len:int = perFrame;
						var bnds:int=start + perFrame
						if ( bnds > strLen)
							len = strLen-start;
						for (n = 0; n < len; n++) {
							var i:int = n + start;
							if(itemsToDispose[i]!=null)
								itemsToDispose[i].dispose();
						}
						start += len;
						
					};
					
					if(strLen>0)
						Loop.add(__onDispose);
						
				},[toDispose], true);
				toDispose = null;
			}
			if (stock != null)
			{
				stock.length = 0;
			}
		}
		
		override public function dispose():void {
			clearOverlayPending();
			Overlay.removeCurrent();
			if (_view != null)
				_view.mask = null;
			super.dispose();
			disposeSignals();
			
			clear();
			
			if (tapper != null)
				tapper.dispose();
			tapper = null;
			
			if (box != null) {
				TweenMax.killTweensOf(box);
				box.graphics.clear();
				box.mask = null;
				if (box.parent != null)
					box.parent.removeChild(box);
			}
			box = null;
			
			if (mask != null) {
				mask.graphics.clear();
				if (mask.parent != null)
					mask.parent.removeChild(mask);
			}
			mask = null;
			
			if (bg != null) {
				bg.graphics.clear();
				if (bg.parent != null)
					bg.parent.removeChild(bg);
			}
			bg = null;
			
			if (scrollBar != null) {
				scrollBar.graphics.clear();
				if (scrollBar.parent != null)
					scrollBar.parent.removeChild(scrollBar);
			}
			scrollBar = null;
			
			if (firstVisibleItem != null)
				firstVisibleItem.dispose();
			firstVisibleItem = null;
			
			if (contextItem != null)
				contextItem.dispose();
			contextItem = null;
			
			if (currentItemWithContextMenu != null)
				currentItemWithContextMenu.dispose();
			currentItemWithContextMenu = null;
			
			if (currentRenderer != null)
				currentRenderer.dispose();
			currentRenderer = null;
			
			if (otherRenderers != null) {
				while (otherRenderers.length != 0)
					otherRenderers.shift().dispose();
			}
			otherRenderers = null;
			
			stock = null;
			_data = null;
			delayedData = null;
			itemRendererClass = null;
			_listItemClass = null;
			
			if (contextItemData != null)
				contextItemData.length = 0
			contextItemData = null;
			
			if (animateFieldNames != null)
				animateFieldNames.length = 0;
			animateFieldNames = null;
		}
		
		private function disposeSignals():void {
			if (S_ITEM_TAP != null)
				S_ITEM_TAP.dispose();
			S_ITEM_TAP = null;
			if (S_ITEM_DOUBLE_CLICK != null)
				S_ITEM_DOUBLE_CLICK.dispose();
			S_ITEM_DOUBLE_CLICK = null;
			if (S_ITEM_HOLD != null)
				S_ITEM_HOLD.dispose();
			S_ITEM_HOLD = null;
			if (S_MOVING != null)
				S_MOVING.dispose();
			S_MOVING = null;
			if (S_STOPED != null)
				S_STOPED.dispose();
			S_STOPED = null;
			if (S_TAP != null)
				S_TAP.dispose();
			S_TAP = null;
			if (S_STOP_UPPER_CONTENT != null)
				S_STOP_UPPER_CONTENT.dispose();
			S_STOP_UPPER_CONTENT = null;
			if (S_SHOW_UPPER_CONTENT != null)
				S_SHOW_UPPER_CONTENT.dispose();
			S_SHOW_UPPER_CONTENT = null;
			if (S_HIDE_UPPER_CONTENT != null)
				S_HIDE_UPPER_CONTENT.dispose();
			S_HIDE_UPPER_CONTENT = null;
			if (S_UP != null)
				S_UP.dispose();
			S_UP = null;
			if (S_DOWN != null)
				S_DOWN.dispose();
			S_DOWN = null;
			if (S_ITEM_SWIPE != null)
				S_ITEM_SWIPE.dispose();
			S_ITEM_SWIPE = null;
		}
		
		/**
		 * Refresh items, redraw visible
		 */
		public function refresh(recalculateHeight:Boolean = false, redrawVisible:Boolean = true, obligatory:Boolean = false, animate:Boolean = false):void {
			clearOverlayPending();
			if (obligatory == false && inMovementPhase == true) {
				needToRefresh = true;
				if (recalculateHeight == true)
					needToRefreshHeight = recalculateHeight;
				return;
			}
			onMoved(true, redrawVisible, recalculateHeight, animate);
			needToRefreshHeight = false;
		}
		
		public function setStartVerticalSpace(vspace:int):void {
			this.vspace = vspace;
		}
		
		public function getStartVerticalSpace():int {
			return vspace;
		}
		
		public function scrollTop():void {
			if (box.y != 0)
				box.y = 0;
			onMoved(true);
		}
		
		public function get tapperInstance():TapperInstance { return tapper; }
		
		public function getBoxX():int { return box.x; }
		public function getBoxY():int { return box.y; }
		
		public function getItemByNum(num:int):ListItem {
			if (num < 0 || num >= stock.length)
				return null;
			return stock[num];
		}
		
		public function setBoxY(val:int):void {
			box.y = val;
			onMoved(true);
		}
		
		public function get inUse():Boolean { return _inUse; }
		public function set inUse(value:Boolean):void{
			_inUse = value;
		}
		
		public function get data():Object { return _data; }
		public function get innerHeight():int { return _innerHeight; }
		public function get height():int { return _height; }
		public function get width():int { return _width; }
		
		public function get backgroundColor():uint { return _backgroundColor; }
		public function set backgroundColor(value:uint):void {
			_backgroundColor = value;
			updateView();
		}
		
		public function get followContent():Boolean { return _followContent; }
		public function set followContent(value:Boolean):void {
			_followContent = value;
		}
		
		public function get length():int {
			if (stock)
				return stock.length;
			return -1;
		}
		
		public function get listItemClass():Class {
			return _listItemClass;
		}
		
		public function set listItemClass(value:Class):void {
			if (value == null)
				_listItemClass = ListItem;
			else
				_listItemClass = value;
		}
		
		public function getStock():Array/*ListItem*/ {
			return stock;
		}
		
		public function getBottomScroll():Number {
			return Math.max(_innerHeight + box.y - height, 0);
		}
		
		public function stopScroll():void {
			tapper.stop();
		}
		
		public function getYOffset():Number {
			return box.y;
		}
		
		public function getFirstVisibleItem():ListItem {
			return firstVisibleItem;
		}
		
		public function getFirstVisibleItemIndex():int {
			return firstVisibleItemIndex;
		}
		
		public function scrollToItem(field:String, value:Object, offset:int, animate:Boolean = false):Boolean {
			if (stock == null)
				return false;
			var l:int = stock.length;
			for (var i:int = 0; i < l; i++) {
				var d:Object = stock[i].data;
				if (field == null) {
					if (d == value) {
						break;
					}
				} else {
					if (d != null && field in d && d[field] == value) {
						break;
					}
				}
			}
			if (i == l)
				return false;
			
			var newY:Number = -(stock[i].y - offset);
			if (newY > 0)
			{
				newY = 0;
			}
			if (newY < -itemsHeight + height)
			{
				newY = -itemsHeight + height;
			}
			if (animate)
			{
				TweenMax.killTweensOf(box);
				TweenMax.to(box, 0.5, { useFrames:false, y:newY, onUpdate:onMoved, onComplete:sbTweenMaxComplete} );
			}
			else
			{
				setBoxY(newY);
			}
			
			return true;
		}
		
		public function scrollToIndex(index:int, offset:int, delay:Number = 0, withTween:Boolean = true):Boolean {
			if (stock == null)
				return false;
			var l:int = stock.length;
			if (index == l)
				return false;
			var newY:Number = -(stock[index].y - offset);
			if (newY + box.height + additionalBottomHeight < _height) 
			{
				newY = _height - box.height - additionalBottomHeight;
			}
			if (box.height <= _height)
			{
				newY = 0;
			}
			TweenMax.killTweensOf(box);
			
			if (withTween) {
				TweenMax.to(box, 0.5, { useFrames:false, y:newY, delay:delay, onUpdate:onMoved, onComplete:sbTweenMaxComplete} );
			} else {
				box.y = newY;
				onMoved(true);
			}
			return true;
		}
		
		public function getScrolling():Boolean {
			return inMovementPhase;
		}
		
		public function setBGColorOnly(val:uint):void {
			if (_backgroundColor == val)
				return;
			_backgroundColor = val;
			updateBackground();
		}
		
		public function setStickToBottom(val:Boolean = false):void {
			_stickToBottom = val;
		}
		
		public function removeLastItem(needToScroll:Boolean = true):void {
			var item:ListItem = stock.pop();
			_innerHeight = item.y;
			item.dispose();
			setBoundsBoxes();
			tapper.setBounds();
			if (needToScroll == true)
				scrollBottom(true);
		}
		
		public function setAlphaFading(value:Boolean):void {
			fadeToAlpha = value;
			onMoved();
		}
		
		public function get itemsHeight():int {
			return box.height;
		}
		
		public function get scrolledToBottom():Boolean {
			return _scrolledToBottom;
		}
		
		private function bbibTweenMaxUpdate():void {
			onMoved();
		}
		
		private function bbibTweenMaxComplete():void {
			onTweenMovingComplete();
		}
		
		public function setAdditionalBottomHeight(val:int):void {
			additionalBottomHeight = val;
		}
		
		public function removeItem(index:int, animate:Boolean = false, calcPositions:Boolean = true):void 
		{
			var item:ListItem = stock.removeAt(index);
			
			if (data != null && data is Array && (data as Array).length > index)
			{
				(data as Array).removeAt(index);
			}
			
			if (calcPositions == true && index == 0 && stock.length > 0)
			{
				var itemNew:ListItem = stock[0];
				itemNew.changeY(item.y);
			}
			
			if (animate == true)
			{
				item.hideWithDispose();
			}
			else
			{
				item.dispose();
			}
			
			setBoundsBoxes();
			tapper.setBounds();
		//	refresh(false);
		}
		
		public function isContextMenuActive():Boolean
		{
			return contextMenuShown;
		}
		
		public function getElementByNumID(num:int):ListItem {
			if (stock == null)
				return null;
			var l:int = stock.length;
			for (var i:int = 0; i < l; i++) {
				if (stock[i].num == num)
					return stock[i];
			}
			return null;
		}
		
		public function updateItemInStockByNum(num:int):ListItem {
			if (stock == null)
				return null;
			var l:int = stock.length;
			for (var i:int = 0; i < l; i++) {
				if (stock[i].num == num)
					updateItemByIndex(i);
			}
			return null;
		}
		
		public function blinkItem(field:String, value:Object):void 
		{
			if (stock == null)
				return;
			var l:int = stock.length;
			for (var i:int = 0; i < l; i++) {
				var d:Object = stock[i].data;
				if (field == null) {
					if (d == value) {
						break;
					}
				} else {
					if (d != null && field in d && d[field] == value) {
						break;
					}
				}
			}
			if (i == l)
				return;
			
			stock[i].blink();
		}
	}
}