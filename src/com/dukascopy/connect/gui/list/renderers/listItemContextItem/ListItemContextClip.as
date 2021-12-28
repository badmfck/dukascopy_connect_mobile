package com.dukascopy.connect.gui.list.renderers.listItemContextItem 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.contextActions.ContextAction;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ListItemContextClip extends Sprite
	{
		private var data:Vector.<ContextAction>;
		private var currentItemHeight:int;
		private var content:Bitmap;
		private var hitzones:Vector.<HitZoneData>;
		private var itemWidth:int;
		private var lastData:Vector.<ContextAction>;
		private var swipeIcon:Sprite;
		
		public function ListItemContextClip() 
		{
			content = new Bitmap();
			addChild(content);
			
			swipeIcon = new Sprite()
			addChild(swipeIcon);
		}
		
		public function setData(data:Vector.<ContextAction>):void
		{
			this.data = data;
		}
		
		public function draw(itemHeight:int, itemWidth:int):void
		{
			this.itemWidth = itemWidth;
			
			if (isSwipe(data))
			{
				currentItemHeight = itemHeight;
				reBuildSwipe();
			}
			else
			{
				if (currentItemHeight != itemHeight || lastData != data)
				{
					currentItemHeight = itemHeight;
					reBuild();
				}
			}
		}
		
		private function reBuildSwipe():void 
		{
			clear();
			if (!data)
			{
				return;
			}
			if (lastData == data)
			{
				
			}
			else
			{
				clearSwipe();
				lastData = data;
				
				if (data != null && data.length > 0 && data[0] != null && data[0].icon != null)
				{
					var icon:Sprite = new data[0].icon();
					var iconSize:int = Config.FINGER_SIZE * .5;
					iconSize = 1;
					UI.scaleToFit(icon, iconSize, iconSize);
					UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
					
					swipeIcon.addChild(icon);
					swipeIcon.graphics.beginFill(0, 0);
					swipeIcon.graphics.drawRect(0, 0, Config.FINGER_SIZE, 1);
					swipeIcon.graphics.endFill();
					
					icon.x = int(Config.FINGER_SIZE * .5 - icon.width * .5);
					icon.y = int(currentItemHeight * .5 - icon.height * .5);
				}
			}
		}
		
		private function clearSwipe():void 
		{
			if (swipeIcon != null)
			{
				swipeIcon.removeChildren();
				swipeIcon.graphics.clear();
			}
		}
		
		private function isSwipe(data:Vector.<ContextAction>):Boolean 
		{
			if (data != null && data.length > 0 && data[0].reactionType == ContextAction.TYPE_SWIPE)
			{
				return true;
			}
			return false;
		}
		
		public function getWidth():int 
		{
			return Math.max(content.width, swipeIcon.width);
		}
		
		private function reBuild():void 
		{
			clear();
			clearSwipe();
			if (!data)
			{
				return;
			}
			lastData = data;
			hitzones = new Vector.<HitZoneData>();
			var hitzone:HitZoneData;
			
			
			var item:Sprite;
			var icon:Sprite;
			var items:Sprite = new Sprite();
			
			var bd:ImageBitmapData = new ImageBitmapData("ListItemContextRenderer", data.length * currentItemHeight, currentItemHeight, false);
			var matrix:Matrix;
			for (var i:int = 0; i < data.length; i++) 
			{
				bd.fillRect(new Rectangle(i*currentItemHeight, 0, currentItemHeight, currentItemHeight), data[i].backColor);
				if (data[i].icon)
				{
					icon = new data[i].icon();
					var iconSize:int = Math.min(Config.FINGER_SIZE * .5, int(currentItemHeight / 2));
					UI.scaleToFit(icon, iconSize, iconSize);
					matrix = new Matrix();
					var ct:ColorTransform = new ColorTransform();
					ct.color = Style.color(Style.COLOR_ICON_SETTINGS);
					matrix.scale(icon.scaleX, icon.scaleY);
					matrix.translate(i * currentItemHeight + currentItemHeight * .5 - icon.width * .5, currentItemHeight * .5 - icon.height * .5);
					bd.drawWithQuality(icon, matrix, ct, null, null, false, StageQuality.HIGH);
					
					if (i != 0)
					{
						bd.fillRect(new Rectangle(i * currentItemHeight, 0, int(Math.max(2, Config.FINGER_SIZE*.05)), currentItemHeight), Style.color(Style.COLOR_BACKGROUND));
					}
					else
					{
					//	bd.fillRect(new Rectangle(i * currentItemHeight, 0, 4, currentItemHeight), Style.color(Style.COLOR_BACKGROUND));
					}
				//	bd.fillRect(new Rectangle(i * currentItemHeight, 0, currentItemHeight, 4), data[i].backColor - 0x111111);
				}
				
				hitzone = new HitZoneData();
				hitzone.type = data[i].type;
				hitzone.x = itemWidth - (data.length - i) * currentItemHeight;
				hitzone.y = 0;
				hitzone.width = currentItemHeight;
				hitzone.height = currentItemHeight;
				
				hitzones.push(hitzone);
			}
			content.bitmapData = bd;
		}
		
		public function clear():void 
		{
			if (content.bitmapData)
			{
				UI.disposeBMD(content.bitmapData);
				content.bitmapData = null;
			}
		}
		
		public function getHitZones():Vector.<HitZoneData> 
		{
			return hitzones;
		}
		
		public function dispose():void 
		{
			lastData = null;
			data = null;
			if (content)
			{
				UI.destroy(content);
			}
			hitzones = null;
		}
		
		public function onResize(itemWidth:Number):void 
		{
			if (isSwipeNow())
			{
				var icon:Sprite;
				if (swipeIcon != null && swipeIcon.numChildren > 0 && swipeIcon.getChildAt(0) is Sprite)
				{
					icon = swipeIcon.getChildAt(0) as Sprite;
					
					var iconSize:int = Math.max(1, itemWidth * .5);
					UI.scaleToFit(icon, iconSize, iconSize);
					icon.x = int(Config.FINGER_SIZE * .5 - icon.width * .5);
					icon.y = int(currentItemHeight * .5 - icon.height * .5);
				}
			}
		}
		
		public function isSwipeNow():Boolean 
		{
			if (data != null && data.length > 0 && data[0].reactionType == ContextAction.TYPE_SWIPE)
			{
				return true;
			}
			return false;
		}
	}
}