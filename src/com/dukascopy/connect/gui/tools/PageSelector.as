package com.dukascopy.connect.gui.tools 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class PageSelector extends Sprite
	{
		private var pages:Vector.<String>;
		
		private var container:Sprite;
		private var selectedItem:Bitmap;
		private var items:Bitmap;
		
		private var itemColor:Number = 0xCBCBCB;
		private var itemSelectedColor:Number = 0x8E8E8E;
		private var itemWidth:int;
		private var circleRadius:int;
		private var selectedIndex:int;
		private var selectedSize:Number;
		
		public function PageSelector(selectedColor:Number = NaN, backColor:Number = NaN, selectedSize:Number = 1.7) 
		{
			this.selectedSize = selectedSize;
			if (!isNaN(selectedColor)) {
				itemSelectedColor = selectedColor;
			}
			
			if (!isNaN(backColor)) {
				itemColor = backColor;
			}
			
			itemWidth = Config.FINGER_SIZE * .42;
			circleRadius = Config.FINGER_SIZE * .08;
			
			container = new Sprite();
			addChild(container);
			
			items = new Bitmap();
			addChild(items);
			
			selectedItem = new Bitmap();
			addChild(selectedItem);
		}
		
		public function setData(pages:Vector.<String>):void
		{
			clear();
			
			this.pages = pages;
			
			if (pages != null && pages.length > 0)
			{
				createItems();
			}
		}
		
		private function createItems():void 
		{
			var renderSprite:Sprite = new Sprite();
			
			var l:int = pages.length;
			for (var i:int = 0; i < l; i++) 
			{
				renderSprite.graphics.beginFill(itemColor);
				renderSprite.graphics.drawCircle(int(itemWidth * (i + 0.5)), int(itemWidth / 2), circleRadius);
				renderSprite.graphics.endFill();
			}
			var bd:ImageBitmapData = new ImageBitmapData("PageSelector.items", itemWidth * l, itemWidth);
			bd.draw(renderSprite);
			items.bitmapData = bd;
			
			renderSprite.graphics.clear();
			
			renderSprite.graphics.beginFill(itemSelectedColor);
			
			renderSprite.graphics.drawCircle(int(itemWidth / 2), int(itemWidth / 2), circleRadius * selectedSize);
			renderSprite.graphics.endFill();
			
			bd = new ImageBitmapData("PageSelector.selectedItem", itemWidth, itemWidth);
			bd.draw(renderSprite);
			selectedItem.bitmapData = bd;
			
			UI.destroy(renderSprite);
			renderSprite = null;
			
			selectItem(0);
		}
		
		private function selectItem(index:int):void 
		{
			selectedIndex = index;
			var time:Number = 0.1;
			TweenMax.to(selectedItem, time, {alpha:0, onComplete:repositionSelectedClip});
			TweenMax.to(selectedItem, time, {alpha:1, delay:time});
		}
		
		private function repositionSelectedClip():void 
		{
			selectedItem.x = int(itemWidth * selectedIndex);
		}
		
		public function dispose():void 
		{
			if (selectedItem != null)
			{
				TweenMax.killTweensOf(selectedItem);
				TweenMax.killChildTweensOf(container);
				UI.destroy(selectedItem);
				selectedItem = null;
			}
			if (items != null)
			{
				UI.destroy(items);
				items = null;
			}
			if (container)
			{
				UI.destroy(container);
				container = null;
			}
			
			pages = null;
		}
		
		private function clear():void 
		{
			if (selectedItem != null)
			{
				if (selectedItem.bitmapData != null)
				{
					selectedItem.bitmapData.dispose();
					selectedItem.bitmapData = null;
				}
			}
			if (items != null)
			{
				if (items.bitmapData != null)
				{
					items.bitmapData.dispose();
					items.bitmapData = null;
				}
			}
			
			pages = null;
		}
		
		public function select(page:String):void 
		{
			if (pages != null && pages.length > 0)
			{
				var l:int = pages.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (pages[i] == page)
					{
						selectItem(i);
					}
				}
			}
		}
	}
}