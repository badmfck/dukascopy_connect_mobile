package com.dukascopy.connect.gui.components.ratesPanel 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RatesPanel extends Sprite
	{
		private var itemWidth:int;
		private var instruments:Vector.<EscrowInstrument>;
		private var itemHeight:Number;
		private var gap:int;
		private var lastItemPosition:int;
		private var lastItemIndex:int;
		private var items:Vector.<Bitmap>;
		private var inAnimation:Boolean;
		private var lastFrameTime:int;
		private var renderer:RatePanelItem;
		private var container:Sprite;
		
		public function RatesPanel(itemWidth:int) 
		{
			this.itemWidth = itemWidth;
			itemHeight = Config.FINGER_SIZE * .54;
			gap = Config.FINGER_SIZE * .4;
			lastItemIndex = 0;
			lastItemPosition = 0;
			items = new Vector.<Bitmap>();
			drawBack();
			
			container = new Sprite();
			addChild(container);
			container.y = Config.APPLE_TOP_OFFSET;
			
			getInstruments();
		}
		
		private function drawBack():void 
		{
			graphics.beginFill(Style.color(Style.COLOR_ACCENT_PANEL));
			graphics.drawRect(0, 0, itemWidth, itemHeight + Config.APPLE_TOP_OFFSET);
			graphics.endFill();
		}
		
		private function getInstruments():void 
		{
			GD.S_ESCROW_INSTRUMENTS.add(onInstruments);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
		}
		
		private function onInstruments(instrumentsData:Vector.<EscrowInstrument>):void 
		{
			if (instruments == null && instrumentsData != null)
			{
				instruments = instrumentsData.concat(instrumentsData);
				construct();
				TweenMax.killTweensOf(container);
				container.alpha = 0;
				TweenMax.to(container, 0.5, {alpha:1});
			}
		}
		
		private function construct():void 
		{
			var item:Bitmap;
			renderer = new RatePanelItem();
			for (var i:int = 0; i < instruments.length; i++) 
			{
				if (lastItemPosition + gap < itemWidth)
				{
					item = renderer.draw(instruments[i], itemHeight);
					item.x = lastItemPosition + gap;
					items.push(item);
					container.addChild(item);
					lastItemPosition = item.x + item.width;
					lastItemIndex = i;
				}
				if (lastItemPosition >= itemWidth)
				{
					inAnimation = true;
					startAnimation();
				}
			}
		}
		
		private function startAnimation():void 
		{
			lastFrameTime = getTimer();
			removeEventListener(Event.ENTER_FRAME, onFrame);
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function stopAnimation():void 
		{
			removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function onFrame(e:Event):void 
		{
			var newFrameTime:int = getTimer();
			var distance:int = Math.max(1, (newFrameTime - lastFrameTime) / 15);
			for (var i:int = 0; i < items.length; i++) 
			{
				items[i].x -= distance;
				if (i == items.length - 1)
				{
					lastItemPosition = items[i].x + items[i].width;
				}
			}
			lastFrameTime = newFrameTime;
			if (lastItemPosition + gap < itemWidth)
			{
				lastItemIndex ++;
				if (lastItemIndex >= instruments.length)
				{
					lastItemIndex = 0;
				}
				var item:Bitmap = renderer.draw(instruments[lastItemIndex], itemHeight);
				item.x = lastItemPosition + gap;
				items.push(item);
				container.addChild(item);
				lastItemPosition = item.x + item.width;
			}
			if (items.length > 0)
			{
				if (items[0].x + items[0].width < 0)
				{
					UI.destroy(items[0]);
					if (container != null && container.contains(items[0]))
					{
						container.removeChild(items[0]);
					}
					items.removeAt(0);
				}
			}
		}
		
		public function dispose():void 
		{
			GD.S_ESCROW_INSTRUMENTS.remove(onInstruments);
			
			instruments = null;
			
			stopAnimation();
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					UI.destroy(items[i]);
				}
				items = null;
			}
			if (renderer != null)
			{
				UI.destroy(renderer);
				renderer = null;
			}
			if (container != null)
			{
				TweenMax.killTweensOf(container);
				UI.destroy(container);
				container = null;
			}
		}
		
		public function getHeight():int 
		{
			return itemHeight;
		}
		
		public function activate():void 
		{
			PointerManager.addTap(this, onTap);
			if (inAnimation)
			{
				startAnimation();
			}
		}
		
		private function onTap(e:Event = null):void 
		{
			
		}
		
		public function deactivate():void 
		{
			PointerManager.removeTap(this, onTap);
			stopAnimation();
		}
	}
}