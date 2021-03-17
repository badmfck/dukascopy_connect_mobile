package com.dukascopy.connect.screens.dialogs.calendar 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.calendar.TimeRange;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.dukascopy.connect.utils.ColorUtils;
	import com.greensock.TweenMax;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TimeScrollSelector extends Sprite
	{
		private var background:Sprite;
		private var itemsClip:Sprite;
		private var ranges:Vector.<TimeRange>;
		private var itemWidth:Number;
		private var tapper:TapperInstance;
		private var items:Vector.<RangeItem>;
		private var positions:Vector.<int>;
		private var sizes:Vector.<int>;
		private var maxHeight:int;
		private var distance:int;
		private var startPoint:Point;
		private var itemHeight:Number;
		private var moving:Boolean;
		private var locked:Boolean;
		private var colors:Vector.<uint>;
		private var onUpdateCallback:Function;
		
		public function TimeScrollSelector(onUpdateCallback:Function = null) 
		{
			this.onUpdateCallback = onUpdateCallback;
			create();
			addEventListener(Event.ADDED_TO_STAGE, updateTapper);
		}
		
		private function create():void 
		{
			itemWidth = Config.FINGER_SIZE * 1.3;
			
			itemsClip = new Sprite();
			itemsClip.mouseChildren = false;
			itemsClip.mouseEnabled = false;
			addChild(itemsClip);
			
			itemsClip.x = int(itemWidth * .5);
			
			background = new Sprite();
			background.graphics.beginFill(0xFFFFFF, 0.1);
			background.graphics.drawRect(0, 0, 10, 10);
			background.graphics.endFill();
			
			addChild(background);
		}
		
		public function getItemWidth():int
		{
			return itemWidth;
		}
		
		public function draw(ranges:Vector.<TimeRange>):void
		{
			if (this.ranges == ranges)
			{
				return;
			}
			clear();
			
			this.ranges = ranges;
			
			setChildIndex(itemsClip, numChildren - 1);
			
			calculatePositions();
			addItems();
			
			maxHeight = positions[5] + sizes[5] * .5 + distance;
			
			background.width = itemWidth;
			background.height = maxHeight;
			
			if (tapper == null)
			{
				var point:Point = new Point(background.x, background.y);
				point = localToGlobal(point);
				tapper = new TapperInstance(MobileGui.stage, background, onMoved, [background.width + Config.FINGER_SIZE * .45, background.height, point.x -  + Config.FINGER_SIZE * .45 * .5, point.y], "y");
			}
			
			updateTapper();
			scrollToFirst();
		}
		
		private function scrollToFirst():void 
		{
			var firstItem:RangeItem;
			if (ranges != null && ranges.length > 0)
			{
				firstItem = items[0];
			}
			
			/*if (firstItem.y == positions[3])
			{
				trace("123");
			}*/
			
			if (firstItem != null && firstItem.y != positions[3])
			{
				locked = true;
				
				var positionHolder:Object = new Object();
				positionHolder.startPosition = firstItem.y;
				TweenMax.to(firstItem, 0.01, {
												y:positions[3], 
												onUpdate:finalTweenUpdate, 
												onUpdateParams: [
																	firstItem, 
																	positionHolder
																], 
												onComplete:finalMoveComplete
											});
			}
		}
		
		private function clear():void 
		{
			if (items != null)
			{
				var l:int = items.length;
				for (var i:int = 0; i < l; i++) 
				{
					TweenMax.killTweensOf(items[i]);
					items[i].dispose();
				}
				items = null;
			}
			if (tapper != null)
			{
				tapper.dispose();
				tapper = null;
			}
		}
		
		private function calculatePositions():void 
		{
			itemHeight = Config.FINGER_SIZE * .55;
			distance = Config.MARGIN * 1;
			
			sizes = new Vector.<int>();
			
			sizes.push(itemHeight);
			sizes.push(itemHeight);
			sizes.push(itemHeight);
			sizes.push(itemHeight * 1.3);
			sizes.push(itemHeight);
			sizes.push(itemHeight);
			sizes.push(itemHeight);
			
			positions = new Vector.<int>();
			
			positions.push(int(- itemHeight * 0.5));
			positions.push(int(distance + itemHeight * .5));
			positions.push(int(distance * 2 + itemHeight * 1.5));
			positions.push(int(distance * 3 + itemHeight * 2.5));
			positions.push(int(distance * 4 + itemHeight * 3.5));
			positions.push(int(distance * 5 + itemHeight * 4.5));
			positions.push(int(distance * 6 + itemHeight * 5.5));
			
			colors = new Vector.<uint>();
			
			colors.push(0xFFFFFF);
			colors.push(0xDBDBDB);
			colors.push(0xBDBDBD);
			colors.push(0xFF6600);
			colors.push(0xBDBDBD);
			colors.push(0xDBDBDB);
			colors.push(0xFFFFFF);
		}
		
		private function addItems():void 
		{
			var index:int = 0;
			
			items = new Vector.<RangeItem>();
			var item:RangeItem;
			
			var l:int = Math.min(6, ranges.length);
			var positionIndex:int;
			
			var startIndex:int = Math.min(Math.max(6 - ranges.length, 0), 3);
			
			for (var i:int = startIndex; i < l + startIndex; i++) 
			{
				item = new RangeItem();
				item.setRange(ranges[index], itemHeight * 1.2, index);
				items.push(item);
				
				positionIndex = i;
				if (positionIndex > positions.length - 1)
				{
					positionIndex -= positions.length;
				}
				
				itemsClip.addChild(item);
				item.setPosition(positionIndex, positions[positionIndex]);
				item.setSize(sizes[positionIndex]);
				
				index ++;
				if (index >= ranges.length)
				{
					index = 0;
				}
			}
			updateItemsView();
		}
		
		private function updateTapper(e:Event = null):void 
		{
			if (background != null)
			{
				var point:Point = new Point(background.x, background.y);
				point = localToGlobal(point);
				
				removeEventListener(Event.ADDED_TO_STAGE, updateTapper);
				
				if (tapper != null)
				{
					tapper.setBounds([background.width + Config.FINGER_SIZE * .45, background.height, point.x - Config.FINGER_SIZE * .45 * .5, point.y]);
					
					if (items != null && items.length < 6)
					{
						tapper.fadingKoef = 0.6;
					}
				}
			}
		}
		
		private function onMoved(scrollStopped:Boolean = false):void 
		{
			background.y = 0;
			
			if (locked == true)
			{
				return;
			}
			
			var moveSpeed:Number = 3;
			if (items != null && items.length < 6)
			{
				moveSpeed = 0.5;
			}
			
			if (Math.abs(tapper.primarySpeed) > 0.5)
			{
				moveItems(tapper.primarySpeed * moveSpeed);
			}
			else if(moving == false)
			{
				moveToNearest();
			}
		}
		
		private function moveItems(difference:Number):void 
		{
			var position:Number;
			
			var checkPosition:Number;
			
			if (items.length < 6)
			{
				checkPosition = items[0].y - difference
				
				if (checkPosition > positions[3])
				{
					difference *= 0.3;
				}
				
				checkPosition = items[items.length - 1].y - difference
				
				if (checkPosition < positions[3])
				{
					difference *= 0.3;
				}
			}
			
			for (var i:int = 0; i < items.length; i++) 
			{
				position = items[i].y - difference;
				
				items[i].setPosition(1, position);
			}
			
			checkItemsPositions();
			updateItemsView();
		}
		
		private function updateItemsView():void 
		{
			var k:Number
			var item:RangeItem;
			var difference:Number = sizes[3] - sizes[2];
			
			for (var i:int = 0; i < items.length; i++) 
			{
				item = items[i];
				if (item.y >= positions[2] && item.y <= positions[4])
				{
					k = 1 - Math.abs(positions[3] - item.y) / (positions[3] - positions[2]);
					
					item.setSize(sizes[2] + difference * (k));
					
					item.setColor(Color.interpolateColor(colors[2], colors[3], k));
					item.visible = true;
				}
				else
				{
					if ((item.y >= positions[1] && item.y <= positions[2]) || (item.y >= positions[4] && item.y <= positions[5]))
					{
						if ((item.y >= positions[1] && item.y <= positions[2]))
						{
							k = 1 - Math.abs(positions[2] - item.y) / (positions[2] - positions[1]);
						}
						else
						{
							k = Math.abs(positions[5] - item.y) / (positions[5] - positions[4]);
						}
						
						item.setColor(Color.interpolateColor(colors[1], colors[2], k));
						item.visible = true;
					}
					else
					{
						if (item.y <= positions[1])
						{
							k = 1 - Math.abs(positions[1] - item.y) / (positions[1] - positions[0]);
						}
						else
						{
							k = Math.abs(positions[6] - item.y) / (positions[6] - positions[5]);
						}
						
						item.setColor(Color.interpolateColor(colors[0], colors[1], k));
						
						if (k < 0 || k > 1)
						{
							item.visible = false;
						}
						else
						{
							item.visible = true;
						}
					}
				}
				
			}
		}
		
		private function checkItemsPositions():void 
		{
			if (items.length < 6)
			{
				return;
			}
			
			var i:int;
			var j:int;
			var minY:Number;
			var minItem:RangeItem;
			var rangeIndex:int;
			
			for (i = 0; i < items.length; i++) 
			{
				if (items[i].y > positions[5] + itemHeight + distance)
				{
					minY = items[i].y;
					minItem = null;
					for (j = 0; j < items.length; j++) 
					{
						if (items[j].y < minY)
						{
							minY = items[j].y;
							minItem = items[j];
						}
					}
					if (minItem != null)
					{
						rangeIndex = minItem.rangeIndex - 1;
						if (rangeIndex < 0)
						{
							rangeIndex = ranges.length - 1;
						}
						items[i].setRange(ranges[rangeIndex], itemHeight * 1.2, rangeIndex);
						items[i].setPosition(1, minItem.y - itemHeight - distance);
						items[i].setSize(sizes[2]);
					//	items[i].setColor(colors[0]);
					}
				}
				else if (items[i].y < positions[0])
				{
					minY = items[i].y;
					minItem = null;
					for (j = 0; j < items.length; j++) 
					{
						if (items[j].y > minY)
						{
							minY = items[j].y;
							minItem = items[j];
						}
					}
					if (minItem != null)
					{
						rangeIndex = minItem.rangeIndex + 1;
						if (rangeIndex > ranges.length - 1)
						{
							rangeIndex = 0;
						}
						items[i].setRange(ranges[rangeIndex], itemHeight * 1.2, rangeIndex);
						items[i].setPosition(1, minItem.y + itemHeight + distance);
						items[i].setSize(sizes[2]);
					//	items[i].setColor(colors[0]);
					}
				}
			}
		}
		
		private function moveToNearest():void 
		{
			if (locked == true)
			{
				return;
			}
			
			var firstItem:RangeItem;
			var nearestDistance:Number = 10000;
			
			for (var i:int = 0; i < items.length; i++) 
			{
				if (Math.abs(positions[3] - items[i].y) < nearestDistance)
				{
					nearestDistance = Math.abs(positions[3] - items[i].y);
					firstItem = items[i];
				}
			}
			if (firstItem != null && firstItem.y != positions[3])
			{
				locked = true;
				
				var positionHolder:Object = new Object();
				positionHolder.startPosition = firstItem.y;
				TweenMax.to(firstItem, 0.15, {
												y:positions[3], 
												onUpdate:finalTweenUpdate, 
												onUpdateParams: [
																	firstItem, 
																	positionHolder
																], 
												onComplete:finalMoveComplete
											});
			}
		}
		
		private function onUpdate():void 
		{
			if (onUpdateCallback != null)
			{
				onUpdateCallback();
			}
		}
		
		private function finalMoveComplete():void 
		{
			moveItems(0);
			locked = false;
			checkItemsPositions();
			onUpdate();
		}
		
		private function finalTweenUpdate(movingItem:RangeItem, positionHolder:Object):void 
		{
			if (items == null)
			{
				return;
			}
			
			var difference:Number = positionHolder.startPosition - movingItem.y;
			positionHolder.startPosition = movingItem.y;
			var position:Number;
			
			for (var i:int = 0; i < items.length; i++) 
			{
				if (items[i] != movingItem)
				{
					position = items[i].y - difference;
					items[i].setPosition(1, position);
				}
			}
			updateItemsView();
		}
		
		public function activate():void
		{
			if (tapper != null)
			{
				tapper.activate();
				updateTapper();
			}
			
			PointerManager.addDown(background, startMove);
		}
		
		private function startMove(e:MouseEvent = null):void 
		{
			if (locked == true)
			{
				return;
			}
			
			moving = true;
			startPoint = new Point(e.stageX, e.stageY);
			
			PointerManager.addUp(MobileGui.stage, stopMove);
			PointerManager.addMove(MobileGui.stage, move);
		}
		
		private function move(e:MouseEvent = null):void 
		{
			var point:Point = new Point(background.mouseX, background.mouseY);
			point = background.localToGlobal(point);
			var difference:Number = startPoint.y - point.y;
			if (difference != 0)
			{
				moveItems(difference);
				startPoint.y = point.y;
			}
		}
		
		private function stopMove(e:MouseEvent = null):void 
		{
			if (locked == true)
			{
				return;
			}
			
			moving = false;
			PointerManager.removeMove(MobileGui.stage, move);
			
			if (tapper != null && Math.abs(tapper.primarySpeed) <= 0.5)
			{
				TweenMax.delayedCall(1, tryMoveToNearest, null, true);
			}
		}
		
		private function tryMoveToNearest():void 
		{
			if (Math.abs(tapper.primarySpeed) <= 0.5)
			{
				moveToNearest();
			}
		}
		
		public function deactivate():void
		{
			//!TODO:;
			
			PointerManager.removeDown(background, startMove);
			PointerManager.removeUp(MobileGui.stage, stopMove);
			PointerManager.removeMove(MobileGui.stage, move);
			
			if (tapper != null)
			{
				tapper.deactivate();
			}
		}
		
		public function getSelected():TimeRange 
		{
			var firstItem:RangeItem;
			var nearestDistance:Number = 10000;
			
			for (var i:int = 0; i < items.length; i++) 
			{
				if (Math.abs(positions[3] - items[i].y) < nearestDistance)
				{
					nearestDistance = Math.abs(positions[3] - items[i].y);
					firstItem = items[i];
				}
			}
			
			if (firstItem != null)
			{
				return firstItem.timeRange;
			}
			return null;
		}
		
		public function getHeight():int 
		{
			return itemHeight * 5 + distance * 6;
		}
		
		public function dispose():void 
		{
			onUpdateCallback = null;
			ranges = null;
			sizes = null;
			positions = null;
			colors = null;
			
			TweenMax.killDelayedCallsTo(tryMoveToNearest);
			
			if (background != null)
			{
				UI.destroy(background);
				background = null;
			}
			if (itemsClip != null)
			{
				UI.destroy(itemsClip);
				itemsClip = null;
			}
			if (items != null)
			{
				var l:int = items.length;
				for (var i:int = 0; i < l; i++) 
				{
					TweenMax.killTweensOf(items[i]);
					items[i].dispose();
				}
				items = null;
			}
			if (tapper != null)
			{
				tapper.dispose();
				tapper = null;
			}
		}
		
		public function equalData(value:Vector.<TimeRange>):Boolean 
		{
			if (ranges == null)
			{
				if (value == null)
				{
					return true;
				}
				return false;
			}
			else if(value == null)
			{
				return false;
			}
			else{
				if (value.length == ranges.length)
				{
					var length:int = value.length;
					for (var i:int = 0; i < length; i++) 
					{
						if (value[i].value != ranges[i].value)
						{
							return false;
						}
					}
					return true;
				}
				else
				{
					return false;
				}
			}
			return false;
		}
	}
}