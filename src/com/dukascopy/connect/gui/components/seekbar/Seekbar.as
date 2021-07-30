package com.dukascopy.connect.gui.components.seekbar
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Seekbar extends Sprite
	{
		public var flipColors:Boolean;
		private var back:Sprite;
		private var backLine:Sprite;
		private var selectLine:Sprite;
		private var button:Sprite;
		
		private var itemHeight:Number;
		private var lineHeight:Number;
		private var buttonRadius:Number;
		
		private var startPoint:Point;
		private var itemWidth:int;
		private var minValue:Number;
		private var maxValue:Number;
		private var startValue:Number;
		private var startPosition:int;
		private var onChange:Function;
		private var zeroPosition:Number;
		
		public function Seekbar(onChange:Function)
		{
			this.onChange = onChange;
			
			itemHeight = Config.FINGER_SIZE * .7;
			lineHeight = Config.FINGER_SIZE * .04;
			buttonRadius = Config.FINGER_SIZE * .2;
			
			createClips();
		}
		
		private function createClips():void
		{
			back = new Sprite();
			addChild(back);
			
			backLine = new Sprite();
			addChild(backLine);
			
			selectLine = new Sprite();
			selectLine.mouseEnabled = false;
			selectLine.mouseChildren = false;
			addChild(selectLine);
			
			button = new Sprite();
			button.graphics.clear();
			button.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			button.graphics.drawCircle(0, 0, buttonRadius);
			button.graphics.endFill();
			button.filters = [new DropShadowFilter(int(Config.FINGER_SIZE * .035), 90, 0, 0.35, int(Config.FINGER_SIZE * .12), int(Config.FINGER_SIZE * .12))];
			addChild(button);
		}
		
		public function draw(itemWidth:int, minValue:Number, maxValue:Number, startValue:Number):void
		{
			this.itemWidth = itemWidth;
			this.minValue = minValue;
			this.maxValue = maxValue;
			this.startValue = startValue;
			
			back.graphics.clear();
			back.graphics.beginFill(0, 0);
			back.graphics.drawRect(0, 0, itemWidth, itemHeight);
			back.graphics.endFill();
			
			backLine.graphics.clear();
			backLine.graphics.beginFill(Style.color(Style.COLOR_SEEK_BACK));
			backLine.graphics.drawRect(0, 0, itemWidth, lineHeight);
			backLine.graphics.endFill();
			
			backLine.y = int(itemHeight * .5 - lineHeight * .5);
			selectLine.y = backLine.y;
			button.y = int(itemHeight * .5);
			
			updatePosition(startValue);
		}
		
		private function updatePosition(positionValue:Number):void
		{
			if (positionValue < minValue)
			{
				positionValue = minValue;
			}
			if (positionValue > maxValue)
			{
				positionValue = maxValue;
			}
			zeroPosition = buttonRadius + int( (0 - minValue) * (itemWidth - buttonRadius * 2) / (maxValue - minValue) );
			startPosition = buttonRadius + int( (positionValue - minValue) * (itemWidth - buttonRadius * 2) / (maxValue - minValue) );
			button.x = startPosition;
		}
		
		public function activate():void
		{
			PointerManager.addDown(button, startDragButton);
			PointerManager.addUp(MobileGui.stage, stopDragButton);
		}
		
		private function stopDragButton(e:Event):void 
		{
			PointerManager.removeMove(MobileGui.stage, startMoveButton);
		}
		
		private function startDragButton(e:Event):void
		{
			startPoint = new Point(button.mouseX, button.mouseY);
			PointerManager.addMove(MobileGui.stage, startMoveButton);
		}
		
		private function startMoveButton(e:Event):void 
		{
			var newPosition:int = mouseX - startPoint.x;
			if (newPosition < buttonRadius)
			{
				newPosition = buttonRadius;
			}
			if (newPosition > itemWidth - buttonRadius)
			{
				newPosition = itemWidth - buttonRadius;
			}
			button.x = newPosition;
			calculatePosition();
		}
		
		private function calculatePosition():void 
		{
			var distance:int = zeroPosition - button.x;
			selectLine.x = zeroPosition;
			
			var color:Number;
			if (distance < 0)
			{
				color = flipColors?Color.GREEN:Color.RED;
			}
			else
			{
				color = flipColors?Color.RED:Color.GREEN;
			}
			
			selectLine.graphics.clear();
			selectLine.graphics.beginFill(color);
			selectLine.graphics.drawRect(0, 0, -distance, lineHeight);
			selectLine.graphics.endFill();
			
			dispatchSelection();
		}
		
		private function dispatchSelection():void 
		{
			if (onChange != null && onChange.length == 1)
			{
				var value:Number = (zeroPosition - button.x) * (maxValue - minValue) / (width - buttonRadius * 2);
				onChange(-value);
			}
		}
		
		public function deactivate():void
		{
			PointerManager.removeDown(button, startDragButton);
			PointerManager.removeMove(MobileGui.stage, startMoveButton);
			PointerManager.removeUp(MobileGui.stage, stopDragButton);
		}
		
		public function dispose():void
		{
			startPoint = null;
			onChange = null;
			
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			if (backLine != null)
			{
				UI.destroy(backLine);
				backLine = null;
			}
			if (selectLine != null)
			{
				UI.destroy(selectLine);
				selectLine = null;
			}
			if (button != null)
			{
				UI.destroy(button);
				button = null;
			}
		}
		
		public function getPosition():int 
		{
			return button.x;
		}
		
		public function setValue(value:Number):void 
		{
			updatePosition(value);
		}
	}
}