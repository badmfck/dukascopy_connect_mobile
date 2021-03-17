package com.dukascopy.connect.gui.graph.lineChart 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.coinMarketplace.stat.MarketplaceStatistic;
	import com.dukascopy.connect.data.coinMarketplace.stat.StatPointData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.TransformGesture;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LineChart extends Sprite
	{
		private var line:Sprite;
		private var grid:Sprite;
		private var axisX:Sprite;
		private var axisY:Sprite;
		private var zoomData:Object;
		private var startPointX:int;
		private var startPointY:int;
		private var minValue:Number;
		private var maxValue:Number;
		private var lineMask:Sprite;
		private var swipeData:Object;
		private var leftTitle:Bitmap;
		private var minValueY:Number;
		private var maxValueY:Number;
		private var contentWidth:int;
		private var background:Sprite;
		private var contentHeight:int;
		private var rightTitle:Bitmap;
		private var swipe:SwipeGesture;
		private var sortLines:Function;
		private var maxDataValue:Number;
		private var minDataValue:Number = -1;
		private var doubleTap:TapGesture;
		private var toast:PointValueClip;
		private var SMOOTHNESS:Number = 0.3
		private var lineColorBase:uint = 0x9D222E;
		private var gridLines:Vector.<LineData>;
		private var titlesVertical:Vector.<Bitmap>;
		private var freeTransform:TransformGesture;
		private var backgroundColor:uint = 0x0A1842;
		private var titlesHorizontal:Vector.<Bitmap>;
		private var currentData:Vector.<StatPointData>;
		private var componentWidth:int = Config.FINGER_SIZE * 6;
		private var componentHeight:int = Config.FINGER_SIZE * 6;
		
		private var scaleFactor:Number = 1;
		private var startPosition:Number = 0;
		private var startIndex:Number;
		private var endIndex:Number;
		private var currentSelection:Vector.<LinePoint>;
		private var currentStep:Number;
		private var currentTimeLimit:Number;
		
		public var S_REQUEST_DATA:Signal = new Signal('LineChart.S_REQUEST_DATA');
		
		public function LineChart() 
		{
			create();
			
			sortLines = function(a:LineData, b:LineData):int
			{
				if (a.index > b.index)
				{
					return 1;
				}
				return -1
			}
		}
		
		private function create():void 
		{
			background = new Sprite();
			addChild(background);
			
			grid = new Sprite();
			grid.mouseEnabled = false;
			grid.mouseChildren = false;
			addChild(grid);
			
			line = new Sprite();
			line.mouseEnabled = false;
			line.mouseChildren = false;
			addChild(line);
			
			lineMask = new Sprite();
			addChild(lineMask);
			
			axisX = new Sprite();
			addChild(axisX);
			
			axisY = new Sprite();
			addChild(axisY);
			
			titlesVertical = new Vector.<Bitmap>();
			titlesHorizontal = new Vector.<Bitmap>();
			gridLines = new Vector.<LineData>();
			
			freeTransform = new TransformGesture(background);
			swipe = new SwipeGesture(background);
			swipe.minOffset = Config.FINGER_SIZE;
			swipe.minVelocity = Config.FINGER_SIZE * .008;
			line.mask = lineMask;
			lineMask.visible = false;
			
			doubleTap = new TapGesture(background);
			doubleTap.maxTapDelay = 300;
			doubleTap.maxTapDuration = 1000;
			doubleTap.numTapsRequired = 2;
		}
		
		private function onFreeTransform(event:GestureEvent):void
		{
			TweenMax.killTweensOf(swipeData);
			TweenMax.killTweensOf(zoomData);
		//	showValue(freeTransform.location.x);
			
			transformLine(freeTransform.offsetX, freeTransform.scale, freeTransform.location);
		}
		
		private function transformLine(offsetX:Number, scale:Number, location:Point, indexesShift:int = 0, timeLimit:Number = NaN, maxTimeValue:Number = 0):void 
		{
			if (currentData == null)
			{
				return;
			}
			
			if (toast != null)
			{
				toast.visible = false;
			}
			
			var currentDistance:Number = location.x - startPosition;
			
			var oldScale:Number = scaleFactor;
			scaleFactor = Math.max(scaleFactor * scale, 1);
			
			var newX:int = startPosition;
			
			var scaleAdd:Number = scaleFactor / oldScale;
			
			if (scaleAdd == 1 && scaleFactor == 1 && scale < 1 && maxTimeValue == 0)
			{
				scaleFactor = oldScale;
				S_REQUEST_DATA.invoke(true, false);
				return;
			}
			
			if (scale != 1 && scaleFactor > 1)
			{
				newX = location.x - currentDistance * scaleAdd;
			}
			else
			{
				newX += offsetX;
			}
			
			for (var k:int = 0; k < titlesHorizontal.length; k++) 
			{
				titlesHorizontal[k].visible = false;
			}
			
			if (newX > startPointX && maxTimeValue == 0)
			{
				newX = startPointX;
				S_REQUEST_DATA.invoke(true, false);
				return;
			}
			if (newX + contentWidth * scaleFactor < startPointX + contentWidth)
			{
				newX = startPointX + contentWidth - contentWidth * scaleFactor;
			}
			
			if (Math.abs(newX - (startPointX + contentWidth - contentWidth * scaleFactor)) < Config.FINGER_SIZE*.05 && rightTitle != null)
			{
				rightTitle.visible = true;
			}
			if (newX == startPointX && leftTitle != null)
			{
				leftTitle.visible = true;
			}
			
			if (scaleFactor == 1 && leftTitle != null && rightTitle != null)
			{
				leftTitle.visible = true;
				rightTitle.visible = true;
			}
			
			var l:int = gridLines.length;
			
			startPosition = newX;
			
			var distance:int;
			
			calculateIndexes(timeLimit, indexesShift, maxTimeValue);
			
			drawPoints(startIndex, endIndex);
			
			gridLines.sort(sortLines);
			
			var timeDistance:Number = currentData[currentData.length - 1].key - currentData[0].key;
			var linesDelete:Vector.<LineData> = new Vector.<LineData>();
			for (var i:int = 0; i < l; i++) 
			{
				var xPos:int = ((gridLines[i].index - currentData[0].key) * contentWidth * scaleFactor / timeDistance) + startPosition - startPointX;
				gridLines[i].clip.x = xPos;
				
				gridLines[i].title.x = gridLines[i].clip.x - gridLines[i].title.width * .5;
				if (gridLines[i].clip.x < 0 || gridLines[i].clip.x > contentWidth)
				{
					linesDelete.push(gridLines[i]);
				}
			}
			l = linesDelete.length;
			for (var j:int = 0; j < l; j++) 
			{
				gridLines.removeAt(gridLines.indexOf(linesDelete[j]));
				deleteLine(linesDelete[j]);
			}
			linesDelete = null;
			
			checkLines(startIndex, endIndex);
			
			drawGrid(false);
		}
		
		private function calculateIndexes(timeLimit:Number = NaN, shift:int = 0, maxTimeValue:Number = 0):void 
		{
			if (currentData == null)
			{
				return;
			}
			
			var allTime:Number = currentData[currentData.length - 1].key - currentData[0].key;
			
			if (maxTimeValue != 0)
			{
				if (!isNaN(timeLimit))
				{
					scaleFactor = allTime / timeLimit;
				}
			}
			
			if (shift != 0 && isNaN(timeLimit))
			{
				minValue = currentData[shift].key;
			}
			else
			{
				minValue = currentData[shift].key + Math.round( (startPointX - startPosition)                * allTime / (contentWidth * scaleFactor) );
				maxValue = currentData[shift].key + Math.round( (startPointX - startPosition + contentWidth) * allTime / (contentWidth * scaleFactor) );
				
			}
			
			if (maxTimeValue != 0)
			{
				maxValue = maxTimeValue;
				if (!isNaN(timeLimit))
				{
					minValue = maxValue - timeLimit;
					startPosition = startPointX - (minValue - currentData[shift].key) * (contentWidth * scaleFactor) / allTime;
				}
			}
			
			if (!isNaN(timeLimit) && maxValue - minValue > timeLimit  && maxTimeValue == 0)
			{
				minValue = maxValue - timeLimit;
				scaleFactor = allTime / timeLimit;
				
				startPosition = contentWidth - contentWidth * scaleFactor + startPointX;
			}
			
			startIndex = Math.ceil((startPointX - startPosition) * currentData.length / (contentWidth * scaleFactor));
			
			if (shift != 0 && isNaN(timeLimit))
			{
				startIndex = shift;
			}
			startIndex = Math.max(startIndex, 0);
			startIndex = Math.min(startIndex, currentData.length - 1);
			endIndex = Math.floor((startPointX - startPosition + contentWidth) * currentData.length / (contentWidth * scaleFactor));
			endIndex = Math.max(endIndex, 0);
			endIndex = Math.min(currentData.length - 1, endIndex);
			
			if (currentData[startIndex].key > minValue)
			{
				for (var m:int = startIndex; m > 0; m--) 
				{
					if (currentData[m].key <= minValue)
					{
						startIndex = m;
						startIndex = Math.max(startIndex, 0);
						break;
					}
				}
			}
			else 
			{
				for (var n:int = 0; n < startIndex; n++) 
				{
					if (currentData[n].key >= minValue)
					{
						startIndex = n;
						startIndex = Math.max(startIndex, 0);
						break;
					}
				}
			}
			
			if (currentData[endIndex].key > maxValue)
			{
				for (var m2:int = endIndex; m2 > 0; m2--) 
				{
					if (currentData[m2].key <= maxValue)
					{
						endIndex = m2 + 1;
						break;
					}
				}
			}
			else 
			{
				var l2:int = currentData.length;
				for (var n2:int = startIndex; n2 < l2; n2++) 
				{
					if (currentData[n2].key >= maxValue)
					{
						endIndex = n2 + 1;
						break;
					}
				}
			}
			
			if (maxTimeValue != 0)
			{
				startIndex -= 10;
				endIndex += 10;
			}
			
			startIndex = Math.max(startIndex, 0);
			endIndex = Math.max(endIndex, 0);
			endIndex = Math.min(currentData.length - 1, endIndex);
			currentTimeLimit = maxValue - minValue;
			
			
		}
		
		private function checkLines(startIndex:int, endIndex:int):void 
		{
			gridLines.sort(sortLines);
			var index:int;
			var needUpdate:Boolean = false;
			
			if (gridLines.length == 0)
			{
				addStandartLines();
			}
			else
			{
				var timeDistance:Number = currentData[currentData.length - 1].key - currentData[0].key;
				var startTime:Number = currentData[0].key + (startPointX - startPosition) * timeDistance / (contentWidth * scaleFactor);
				var endTime:Number = currentData[0].key + (startPointX - startPosition + contentWidth) * timeDistance / (contentWidth * scaleFactor);
				
				var num:int;
				var i:int;
				var nextTime:Number;
				
				if (gridLines[0].index - startTime > currentStep)
				{
					num = Math.floor((gridLines[0].index - startTime) / currentStep);
					for (i = 0; i < num + 1; i++) 
					{
						nextTime = gridLines[0].index - currentStep;
						
						if (nextTime >= startTime)
						{
							addLine(nextTime);
							gridLines.sort(sortLines);
						}
					}
				}
				
				if (endTime - gridLines[gridLines.length - 1].index > currentStep)
				{
					num = Math.floor((endTime - gridLines[gridLines.length - 1].index) / currentStep);
					for (i = 0; i < num + 1; i++) 
					{
						nextTime = gridLines[gridLines.length - 1].index + currentStep;
						
						if (nextTime <= endTime)
						{
							addLine(nextTime);
							gridLines.sort(sortLines);
						}
					}
				}
				
				if (gridLines.length < 4)
				{
					if (gridLines.length > 1)
					{
						var j:int;
						var k:int;
						var newLines:Array = new Array();
						var nextStep:Number = (gridLines[1].index - gridLines[0].index) / (1000 * 60);
						if (nextStep % 2 == 0)
						{
							currentStep = currentStep / 2;
							
							if (gridLines[0].index - currentStep >= startTime)
							{
								newLines.push(gridLines[0].index - currentStep);
							}
							
							for (j = 0; j < gridLines.length; j++) 
							{
								if (gridLines[j].index + currentStep <= endTime)
								{
									newLines.push(gridLines[j].index + currentStep);
								}
							}
							
							for (k = 0; k < newLines.length; k++) 
							{
								addLine(newLines[k]);
							}
							gridLines.sort(sortLines);
						}
						else if (nextStep % 3 == 0)
						{
							currentStep = currentStep / 3;
							
							if (gridLines[0].index - currentStep >= startTime)
							{
								newLines.push(gridLines[0].index - currentStep);
							}
							if (gridLines[0].index - currentStep * 2 >= startTime)
							{
								newLines.push(gridLines[0].index - currentStep * 2);
							}
							
							for (j = 0; j < gridLines.length; j++) 
							{
								if (gridLines[j].index + currentStep <= endTime)
								{
									newLines.push(gridLines[j].index + currentStep);
								}
								if (gridLines[j].index + currentStep * 2 <= endTime)
								{
									newLines.push(gridLines[j].index + currentStep * 2);
								}
							}
							
							for (k = 0; k < newLines.length; k++) 
							{
								addLine(newLines[k]);
							}
							gridLines.sort(sortLines);
						}
					}
				}
				else if (gridLines.length > 7)
				{
					currentStep *= 2;
					var linesToDelete:Array = new Array();
					for (var l:int = 0; l < gridLines.length; l++) 
					{
						if (l%2 == 0)
						{
							linesToDelete.push(gridLines[l]);
						}
					}
					for (var m:int = 0; m < linesToDelete.length; m++) 
					{
						deleteLine(linesToDelete[m]);
						gridLines.removeAt(gridLines.indexOf(linesToDelete[m]));
					}
					linesToDelete = null;
				}
			}
		}
		
		private function addLine(time:Number):void 
		{
			var timeDistance:Number = currentData[currentData.length - 1].key - currentData[0].key;
			
			var xPos:int = ((time - currentData[0].key) * contentWidth * scaleFactor / timeDistance) + startPosition - startPointX;
			var title:Bitmap = new Bitmap();
			axisX.addChild(title);
			
			title.bitmapData = drawTitle(time); 
			
			title.y = int(contentHeight + Config.FINGER_SIZE * .1);
			title.x = int(xPos - title.width * .5);
			
			var lineData:LineData = new LineData(time);
			lineData.clip = new Shape();
		//	lineData.value = index;
			grid.addChild(lineData.clip);
			
			lineData.clip.graphics.lineStyle(Math.max(int(Config.FINGER_SIZE * .026), 2), 0x2B375B, 1);
			lineData.clip.graphics.moveTo(0, 0);
			lineData.clip.graphics.lineTo(0, contentHeight);
			lineData.clip.x = xPos;
			lineData.title = title;
			gridLines.push(lineData);
		}
		
		private function drawTitle(key:Number):ImageBitmapData 
		{
			var date:Date = new Date();
			date.setTime(key);
			var value:String = date.getDate().toString() + ".";
			if (date.getMonth() + 1 < 9)
			{
				value = value + "0";
			}
			value = value + (date.getMonth() + 1).toString();
			
			
			var time:String = date.getMinutes().toString();
			if (time.length == 1)
			{
				time = "0" + time;
			}
			time = date.getHours() + ":" + time;
			if (time.length == 4)
			{
				time = "0" + time;
			}
			
			value = value + "<br><font color='#49535D' size='" + int(Config.FINGER_SIZE*.24) + "'>" + time + "</font>";
			
			return TextUtils.createTextFieldData(
													value, 
													Config.FINGER_SIZE * 2, 
													10, true, 
													TextFormatAlign.CENTER, 
													TextFieldAutoSize.LEFT, 
													Config.FINGER_SIZE * .28, 
													true, 0x6B7B8A, 0xFFFFFF, true, true);
		}
		
		private function addStandartLines():void 
		{
			var timeDistance:Number = currentData[currentData.length - 1].key - currentData[0].key;
			
			var startTime:Number = currentData[0].key + (startPointX - startPosition) * timeDistance / (contentWidth * scaleFactor);
			var endTime:Number = currentData[0].key + (startPointX - startPosition + contentWidth) * timeDistance / (contentWidth * scaleFactor);
			
			var sectorDistance:Number = endTime - startTime;
			
			var items:int = 5;
			var step:Number = Math.floor(sectorDistance / items);
			step = Math.max(step, 1000 * 60);
			
			var stepIntervals:Array = [1, 10, 30, 60, 60*4, 60*12, 60*24, 60*32, 60*24*2, 60*24*3, 60*24*4, 60*24*5, 60*24*6, 60*24*7, 60*24*8, 60*24*9, 60*24*10, 60*24*15, 60*24*20, 60*24*30, 60*24*40, 60*24*50, 60*24*60, 60*24*120];
			
			var minDistance:Number = 10000000000000000;
			var index:int = -1;
			for (var j:int = 0; j < stepIntervals.length; j++) 
			{
				if (Math.abs(step - stepIntervals[j] * 60 * 1000) < minDistance)
				{
					minDistance = Math.abs(step - stepIntervals[j] * 60 * 1000);
					index = j;
				}
			}
			if (index != -1)
			{
				step = stepIntervals[index] * 60 * 1000;
			}
			
			currentStep = step;
			
			for (var i:int = 0; i < items + 10; i++) 
			{
				if (step * i + startTime <= endTime)
				{
					addLine(step * i + startTime);
				}
				else
				{
					break;
				}
			}
		}
		
		private function deleteLine(lineData:LineData):void 
		{
			if (axisX.contains(lineData.title))
			{
				axisX.removeChild(lineData.title);
				UI.destroy(lineData.title);
			}
			else
			{
				ApplicationErrors.add();
			}
			
			grid.removeChild(lineData.clip);
			UI.destroy(lineData.title);
			UI.destroy(lineData.clip);
		}
		
		public function setSizes(componentWidth:int, componentHeight:int):void
		{
			this.componentWidth = componentWidth;
			this.componentHeight = componentHeight;
			
			contentWidth = componentWidth - Config.FINGER_SIZE * 1.2;
			contentHeight = componentHeight - Config.FINGER_SIZE;
			
			startPointX = Config.FINGER_SIZE * 1;
			startPointY = Config.FINGER_SIZE * .3;
			
			line.x = startPointX;
			startPosition = startPointX;
			line.y = startPointY;
			
			grid.x = startPointX;
			grid.y = startPointY;
			
			axisX.x = startPointX;
			axisX.y = startPointY;
			
			axisY.x = startPointX;
			axisY.y = startPointY;
			
			lineMask.graphics.clear();
			lineMask.graphics.beginFill(backgroundColor);
			lineMask.graphics.drawRect(startPointX, startPointY, contentWidth, contentHeight);
			lineMask.graphics.endFill();
			
			draw(currentData);
		}
		
		public function draw(points:Vector.<StatPointData>, indexesShift:int = -1):void
		{
			currentData = points;
			
			currentSelection = null;
			minDataValue = -1;
			maxDataValue = -1;
			
			drawBackground();
			
			clearTitles();
			clearDots();
			clearGrid();
			
			if (indexesShift == -1)
			{
				scaleFactor = 1;
				startPosition = startPointX;
			}
			
			if (currentData != null)
			{
				titlesVertical = new Vector.<Bitmap>();
				titlesHorizontal = new Vector.<Bitmap>();
				
				if (indexesShift == -1)
				{
					calculateIndexes(1000 * 60 * 60 * 24 * 7);
				}
				else
				{
					
				//	calculateIndexes(currentTimeLimit, 0, maxValue);
				//	transformLine(0, scaleFactor, new Point(), indexesShift);
					transformLine(0, 1, new Point(), 0, currentTimeLimit, maxValue);
				}
				
			//	calculateIndexes();
				
				drawPoints(startIndex, endIndex, true);
				drawGrid();
			//	checkLines(startIndex, endIndex);
			}
			
			if (toast != null)
			{
				TweenMax.killTweensOf(toast);
				toast.visible = false;
			}
		}
		
		public function dispose():void 
		{
			TweenMax.killTweensOf(swipeData);
			TweenMax.killTweensOf(zoomData);
			
			S_REQUEST_DATA.dispose();
			S_REQUEST_DATA = null;
			
			doubleTap.dispose();
			swipe.dispose();
			freeTransform.dispose();
			
			doubleTap = null;
			swipe = null;
			freeTransform = null;
			
			clearDots();
			clearGrid();
			clearTitles();
			
			rightTitle = null;
			leftTitle = null;
			
			if (toast != null)
			{
				TweenMax.killTweensOf(toast);
			}
			if (background != null)
			{
				UI.destroy(background);
				background = null
			}
			if (line != null)
			{
				UI.destroy(line);
				line = null
			}
			if (grid != null)
			{
				UI.destroy(grid);
				grid = null
			}
			if (background != null)
			{
				UI.destroy(background);
				background = null
			}
			if (background != null)
			{
				UI.destroy(background);
				background = null
			}
			if (axisX != null)
			{
				UI.destroy(axisX);
				axisX = null
			}
			if (axisY != null)
			{
				UI.destroy(axisY);
				axisY = null
			}
			if (lineMask != null)
			{
				UI.destroy(lineMask);
				lineMask = null
			}
			if (toast != null)
			{
				toast.dispose();
				toast = null
			}
			
			currentData = null;
			titlesVertical = null;
		}
		
		public function showValue(mouseX:Number):void 
		{
			mouseX -= startPointX;
			if (toast == null)
			{
				toast = new PointValueClip();
				addChild(toast);
			}
			
			if (currentSelection != null && currentSelection.length > 0)
			{
				var l:int = currentSelection.length;
				var nearest:Number = 10000;
				var position:int = -1;
				for (var i:int = 0; i < l; i++) 
				{
					if (Math.abs(currentSelection[i].x - mouseX) < nearest)
					{
						position = i;
						nearest = Math.abs(currentSelection[i].x - mouseX);
					}
				}
				if (position != -1)
				{
					var posX:int = startPointX + currentSelection[position].x;
					var posY:int = startPointY + currentSelection[position].y;
				//	TweenMax.to(toast, 0.2, {x:posX, y:posY});
					toast.x = posX;
					toast.y = posY;
					toast.visible = true;
					toast.draw(currentSelection[position].value.toString());
				}
			}	
		}
		
		private function clearGrid():void 
		{
			if (grid != null)
			{
				grid.graphics.clear();
			}
		}
		
		private function clearDots():void 
		{
			if (line != null)
			{
				line.graphics.clear();
			}
			
			if (gridLines != null)
			{
				for (var i:int = 0; i < gridLines.length; i++) 
				{
					deleteLine(gridLines[i]);
				}
				gridLines = new Vector.<LineData>();
			}
		}
		
		private function clearTitles():void 
		{
			if (titlesVertical != null)
			{
				for (var i:int = 0; i < titlesVertical.length; i++) 
				{
					UI.destroy(titlesVertical[i]);
				}
				titlesVertical = null;
			}
			
			if (axisY != null)
			{
				axisY.removeChildren();
			}
		}
		
		public final function activate():void
		{
			freeTransform.addEventListener(GestureEvent.GESTURE_BEGAN, onFreeTransform);
			freeTransform.addEventListener(GestureEvent.GESTURE_CHANGED, onFreeTransform);
			
			swipe.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onSwipe);
		//	swipe.addEventListener(GestureEvent.GESTURE_STATE_CHANGE, onSwipe);
		
			doubleTap.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onDoubleTap);
			
			PointerManager.addWheel(background, onWheel);
			PointerManager.addTap(background, onTap);
			PointerManager.addDown(background, onDown);
		}
		
		private function onDoubleTap(e:GestureEvent):void 
		{
			TweenMax.killTweensOf(zoomData);
			TweenMax.killTweensOf(swipeData);
			
			zoomData = new Object();
			zoomData.value = 0;
			
			TweenMax.to(zoomData, 0.4, {value:1, onUpdate:onZoomUpdate, onUpdateParams:[doubleTap.location]});
		}
		
		private function onZoomUpdate(location:Point):void 
		{
			if (zoomData != null)
			{
				transformLine(0, 1.04, location);
			}
		}
		
		private function onSwipe(e:GestureEvent):void 
		{
			if (swipe.offsetX == 0)
			{
				return;
			}
			
			TweenMax.killTweensOf(swipeData);
			TweenMax.killTweensOf(zoomData);
			
			swipeData = new Object();
			swipeData.value = swipe.offsetX * 3.5;
			
			TweenMax.to(swipeData, 0.5, {value:0, onUpdate:onSwipeUpdate});
		}
		
		private function onSwipeUpdate():void 
		{
			if (swipeData != null)
			{
				transformLine(swipeData.value, 1, new Point());
			}
		}
		
		private function onTap(e:Event):void 
		{
			TweenMax.killTweensOf(swipeData);
		//	TweenMax.killTweensOf(zoomData);
			showValue(background.mouseX);
		}
		
		public final function deactivate():void
		{
			freeTransform.removeEventListener(GestureEvent.GESTURE_BEGAN, onFreeTransform);
			freeTransform.removeEventListener(GestureEvent.GESTURE_CHANGED, onFreeTransform);
			
			swipe.removeEventListener(GestureEvent.GESTURE_RECOGNIZED, onSwipe);
			
			doubleTap.removeEventListener(GestureEvent.GESTURE_RECOGNIZED, onDoubleTap);
			
			PointerManager.removeWheel(background, onWheel);
			PointerManager.removeTap(background, onTap);
			PointerManager.removeDown(background, onDown);
		}
		
		private function onDown(e:Event):void 
		{
			TweenMax.killTweensOf(swipeData);
		//	TweenMax.killTweensOf(zoomData);
		}
		
		private function onWheel(e:MouseEvent):void 
		{
			TweenMax.killTweensOf(swipeData);
			TweenMax.killTweensOf(zoomData);
			transformLine(0, 1 + e.delta * 0.1 / 3, new Point(background.mouseX, background.mouseY));
		}
		
		private function drawGrid(drawHorizontal:Boolean = true):void 
		{
			var i:int;
			if (titlesVertical != null)
			{
				for (i = 0; i < titlesVertical.length; i++) 
				{
					UI.destroy(titlesVertical[i]);
				}
				titlesVertical = null;
			}
			
			if (axisY != null)
			{
				axisY.removeChildren();
			}
			titlesVertical = new Vector.<Bitmap>();
			
			grid.graphics.clear();
			grid.graphics.lineStyle(Math.max(int(Config.FINGER_SIZE*.026), 2), 0x2B375B, 1);
			grid.graphics.drawRect(0, 0, contentWidth, contentHeight);
			
			var positionsVertical:int = 5;
			
			var difference:Number = maxValueY - minValueY;
			var k:int;
			if (difference < 0.5)
			{
				k = 3;
			}
			else if (difference < 10)
			{
				k = 2;
			}
			else if (difference < 100)
			{
				k = 0;
			}
			
			difference = parseFloat(difference.toFixed(k));
			
			var distance:Number = Math.floor((difference * Math.pow(10, k)) / positionsVertical) / Math.pow(10, k);
			
			var yPos:Number;
			
			var title:Bitmap;
			var value:String;
			
			for (i = 0; i < positionsVertical; i++) 
			{
				title = new Bitmap();
				titlesVertical.push(title);
				axisY.addChild(title);
				value = (parseFloat((minValueY + distance * (i + 1)).toFixed(k))).toString();
				title.bitmapData = drawValue(value);
				
				yPos = (difference - distance * (i + 1)) * contentHeight / difference;
				
				titlesVertical[i].y = int(yPos - titlesVertical[i].height * .5);
				titlesVertical[i].x = int( - titlesVertical[i].width - Config.FINGER_SIZE * .2);
				grid.graphics.moveTo(0, yPos);
				grid.graphics.lineTo(contentWidth, yPos);
			}
			
			if (titlesVertical[titlesVertical.length - 1].y > Config.FINGER_SIZE*.6)
			{
				title = new Bitmap();
				titlesVertical.push(title);
				axisY.addChild((title));
				title.bitmapData = drawValue((parseFloat(maxValueY.toFixed(2))).toString());
				
				title.y = int(0);
				title.x = int( - title.width - Config.FINGER_SIZE * .2);
			}
			
			title = new Bitmap();
			titlesVertical.push(title);
			axisY.addChild((title));
			title.bitmapData = drawValue((parseFloat(minValueY.toFixed(2))).toString());
			
			title.y = int(contentHeight - title.height);
			title.x = int( - title.width - Config.FINGER_SIZE * .2);
			
			if (drawHorizontal)
			{
				/*title = new Bitmap();
				titlesHorizontal.push(title);
				axisX.addChild(title);
				leftTitle = title;
				title.bitmapData = drawTitle(currentData[startIndex].key);
				
				title.y = int(contentHeight + Config.FINGER_SIZE * .1);
				title.x = int(0);
				
				
				title = new Bitmap();
				titlesHorizontal.push(title);
				axisX.addChild(title);
				rightTitle = title;
				title.bitmapData = drawTitle(currentData[currentData.length - 1].key);
				
				title.y = int(contentHeight + Config.FINGER_SIZE * .1);
				title.x = int(contentWidth - title.width);*/
				
				addStandartLines();
			}
		}
		
		private function drawValue(value:String):ImageBitmapData 
		{
			return TextUtils.createTextFieldData(
													value, 
													Config.FINGER_SIZE, 
													10, false, 
													TextFormatAlign.CENTER, 
													TextFieldAutoSize.LEFT, 
													Config.FINGER_SIZE * .26, 
													false, 0x8497AA, 0xFFFFFF, true);
		}
		
		private function drawPoints(start:Number, end:Number, detailsUpdateImmediate:Boolean = false):void 
		{
			var time:Number = getTimer();
			
			var l:int;
			var i:int;
				
			//	if (minDataValue == -1)
			//	{
					//!TODO:;
					
					minDataValue = Number.POSITIVE_INFINITY;
					maxDataValue = Number.NEGATIVE_INFINITY;
					
					for (var j:int = start; j < end; j++) 
					{
						if (minDataValue > currentData[j].value)
						{
							minDataValue = currentData[j].value;
						}
						if (maxDataValue < currentData[j].value)
						{
							maxDataValue = currentData[j].value;
						}
					}
			//	}
				
			if (currentSelection == null)
			{
				currentSelection = new Vector.<LinePoint>();
			}
			
			var linePoint:LinePoint;
			var newPoints:Vector.<LinePoint>;
			var pointData:StatPointData;
			
			if (currentSelection.length > 1)
			{
				// текущая выборка не пересекается с новой, генерится вся заново;
				
				if (currentSelection[0].startIndex > end || currentSelection[currentSelection.length - 1].endIndex < start)
				{
					newPoints = getPoints(start, end);
					currentSelection = newPoints.concat();
				}
				else
				{
					if (currentSelection[0].endIndex < start)
					{
						// удаляем слева;
						
						var newStart:int = 0;
						l = currentSelection.length;
						for (var k:int = 0; k < l; k++) 
						{
							if (currentSelection[k].startIndex >= start - 4)
							{
								newStart = k;
								break;
							}
						}
						
						currentSelection = currentSelection.slice(newStart);
					}
					
					if (currentSelection[currentSelection.length - 1].endIndex > end)
					{
						// удаляем справа;
						
						var newEnd:int = currentSelection.length;
						for (var k2:int = currentSelection.length - 1; k2 > 0; k2--) 
						{
							if (currentSelection[k2].endIndex <= end + 5)
							{
								newEnd = k2;
									break;
							}
						}
						
						currentSelection = currentSelection.slice(0, newEnd);
					}
					
					if (currentSelection[currentSelection.length - 1].endIndex < end)
					{
						// добавляем справа
						
						newPoints = new Vector.<LinePoint>();
						
						var startPoint:int;
						for (var m:int = end; m > 0; m--) 
						{
							if (currentData[m].index < currentSelection[currentSelection.length - 1].endIndex)
							{
								startPoint = m + 2;
								break;
							}
						}
						
						newPoints = getPoints(startPoint, end);
						
						currentSelection = currentSelection.concat(newPoints);
					}
					
					if (currentSelection[0].startIndex > start)
					{
						// добавляем слева;
						
						newPoints = getPoints(start, currentSelection[0].startIndex - 1);
						
						currentSelection = newPoints.concat(currentSelection);
					}
				}
			}
			else
			{
				newPoints = getPoints(start, end);
				currentSelection = newPoints.concat();
			}
			
			if (detailsUpdateImmediate == true)
			{
				updatePointsWithDetails(start, end);
			}
			else
			{
				TweenMax.killDelayedCallsTo(updatePointsWithDetails);
				TweenMax.delayedCall(0.5, updatePointsWithDetails, [start, end]);
			}
			
			l = currentSelection.length;
			var padding:Number = (maxDataValue - minDataValue) * .2 * .9;
			minValueY = Math.floor((minDataValue - padding) * 100) / 100;
			maxValueY = Math.ceil((maxDataValue + padding) * 100) / 100;
			for (var i3:int = 0; i3 < l; i3++) 
			{
				currentSelection[i3].x = (currentSelection[i3].key - minValue) * contentWidth/(maxValue - minValue);
				currentSelection[i3].y = (maxValueY - currentSelection[i3].value) * contentHeight / (maxValueY - minValueY);
			}
				
			line.graphics.clear();
			if (currentSelection.length > 1)
			{
				drawLine(line.graphics, currentSelection, NaN, 3);
			}
		}
		
		private function getPoints(start:Number, end:Number):Vector.<LinePoint> 
		{
			var l:int;
			var i:int;
			
			var currentPoint:LinePoint;
			var maxSteps:Number = 300;
			var minTimeGap:Number = MarketplaceStatistic.timeGap;
			var timeSector:Number = maxValue - minValue;
			var step:Number = timeSector / maxSteps;
			if (step < minTimeGap)
			{
				step = minTimeGap;
			}
			else
			{
				var stepsInside:Number = step / minTimeGap;
				step = Math.floor(stepsInside) * minTimeGap;
			}
			
			var newPoints:Vector.<LinePoint> = new Vector.<LinePoint>();
			
			var pointData:StatPointData;
			var currentIndex:int = 0;
			
			var currentTime:Number;
			
			var values:Array = new Array();
			var sum:Number;
			var l2:int;
			
			if (currentData == null || currentData.length == 0 || currentData.length < end + 1)
			{
				return newPoints;
			}
			
			for (i = start; i < end + 1; i++) 
			{
				pointData = currentData[i];
				if (pointData != null)
				{
					if (currentPoint == null)
					{
						currentPoint = new LinePoint();
						
						values.length = 0;
						values.push(pointData.value);
						currentTime = pointData.key;
						
						currentPoint.startIndex = pointData.index;
						currentPoint.endIndex = pointData.index;
						currentPoint.key = currentTime;
					}
					else if (pointData.key < currentTime + step)
					{
						values.push(pointData.value);
						if (i == l - 1)
						{
							l2 = values.length;
							sum = 0;
							for (var j:int = 0; j < l2; j++) 
							{
								sum += values[j];
							}
							currentPoint.value = Math.floor((sum / l2) * 100) / 100;
							;
							if (i > 0)
							{
								currentPoint.endIndex = currentData[i - 1].index;
							}
							
							newPoints.push(currentPoint);
							currentPoint.endIndex = newPoints.length - 1;
						}
					}
					else
					{
						var dif:Number = (pointData.key - currentTime) / step;
						
						currentTime += Math.floor(dif) * step;
						
						l2 = values.length;
						sum = 0;
						for (var j2:int = 0; j2 < l2; j2++) 
						{
							sum += values[j2];
						}
						currentPoint.value = Math.floor((sum / l2) * 100) / 100;
						newPoints.push(currentPoint);
						if (i > 0)
						{
							currentPoint.endIndex = currentData[i - 1].index;
						}
						
						currentPoint = new LinePoint();
						values.length = 0;
						values.push(pointData.value);
						currentPoint.startIndex = pointData.index;
						currentPoint.endIndex = pointData.index;
						currentPoint.key = currentTime;
					}
				}
			}
			
			return newPoints;
		}
		
		private function updatePointsWithDetails(start:Number, end:Number):void 
		{
			TweenMax.killDelayedCallsTo(updatePointsWithDetails);
			
			currentSelection = getPoints(start, end).concat();
			
			var l:int = currentSelection.length;
			var padding:Number = (maxDataValue - minDataValue) * .2 * .9;
			minValueY = Math.floor((minDataValue - padding) * 100) / 100;
			maxValueY = Math.ceil((maxDataValue + padding) * 100) / 100;
			for (var i3:int = 0; i3 < l; i3++) 
			{
				currentSelection[i3].x = (currentSelection[i3].key - minValue) * contentWidth/(maxValue - minValue);
				currentSelection[i3].y = (maxValueY - currentSelection[i3].value) * contentHeight / (maxValueY - minValueY);
			}
			if (line != null)
			{
				line.graphics.clear();
				if (currentSelection.length > 1)
				{
					drawLine(line.graphics, currentSelection, NaN, 3);
				}
			}
		}
		
		private function drawLine(target:Graphics, points:Vector.<LinePoint>, lineColor:Number = NaN, thickness:Number = NaN):void 
		{
			var color:Number;
			if (!isNaN(lineColor))
			{
				color = lineColor;
			}
			else
			{
				color = lineColorBase;
			}
			
			var lineThickness:Number;
			if (!isNaN(thickness))
			{
				lineThickness = thickness;
			}
			else
			{
				lineThickness = Math.max(int(Config.FINGER_SIZE * .045), 3);
			}
			
			var l:int = points.length;
			
			var lX:Number = 0;
			var lY:Number = 0;
			var d0:Number = 0;
			var x1:Number = 0;
			var x2:Number = 0;
			var y1:Number = 0;
			var y2:Number = 0;
			var d1:Number = 0;
			var p:Point;
			var p0:Point;
			var p1:Point;
			
			target.lineStyle(lineThickness, color, 1, false, LineScaleMode.NONE);
			target.moveTo(points[0].x, points[0].y);
			
			if (points.length > 1)
			{
				for (var i2:int = 1; i2 < l; i2++) {	
					target.lineTo(points[i2].x, points[i2].y);
				}
			}
			else
			{
				for (var i:int = 1; i < l; i++) {	
					p = points[i];
					
					p0 = points[i - 1];
					d0 = Math.sqrt(Math.pow(p.x - p0.x, 2) + Math.pow(p.y - p0.y, 2));
					x1 = Math.min(p0.x + lX * d0, (p0.x + p.x) / 2);
					y1 = p0.y + lY * d0;
					
					p1 = points[i + 1 < l ? i + 1 : i];
					d1 = Math.sqrt(Math.pow(p1.x - p0.x, 2) + Math.pow(p1.y - p0.y, 2));
					lX = (p1.x - p0.x) / d1 * SMOOTHNESS;
					lY = (p1.y - p0.y) / d1 * SMOOTHNESS;
					x2 = Math.max(p.x - lX*d0, (p0.x + p.x)/2);
					y2 = p.y - lY * d0;
					
					target.cubicCurveTo(x1, y1, x2, y2, p.x, p.y);
				}
			}
		}
		
		private function drawBackground():void 
		{
			background.graphics.clear();
			background.graphics.beginFill(backgroundColor);
			background.graphics.drawRect(0, 0, componentWidth, componentHeight);
			background.graphics.endFill();
		}
	}
}