package com.dukascopy.connect.gui.list.renderers.listItemContextItem 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.contextActions.ContextAction;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.HitZoneType;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
		private var hitzones:Array;
		private var itemWidth:int;
		private var lastData:Vector.<ContextAction>;
		
		public function ListItemContextClip() 
		{
			content = new Bitmap();
			addChild(content);
		}
		
		public function setData(data:Vector.<ContextAction>):void
		{
			this.data = data;
		}
		
		public function draw(itemHeight:int, itemWidth:int):void
		{
			this.itemWidth = itemWidth;
			if (currentItemHeight != itemHeight || lastData != data)
			{
				currentItemHeight = itemHeight;
				reBuild();
			}
		}
		
		public function getWidth():int 
		{
			return content.width;
		}
		
		private function reBuild():void 
		{
			clear();
			if (!data)
			{
				return;
			}
			lastData = data;
			hitzones = new Array();
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
					UI.scaleToFit(icon, int(currentItemHeight / 2.5), int(currentItemHeight / 2.5));
					matrix = new Matrix();
					var ct:ColorTransform = new ColorTransform();
					ct.color = 0xFFFFFF;
					matrix.scale(icon.scaleX, icon.scaleY);
					matrix.translate(i*currentItemHeight + currentItemHeight*.5 - icon.width*.5, currentItemHeight*.5 - icon.height*.5);
					bd.drawWithQuality(icon, matrix, ct, null, null, false, StageQuality.HIGH);
					
					if (i != 0)
					{
						bd.fillRect(new Rectangle(i*currentItemHeight, 0, 2, currentItemHeight), data[i].backColor - 0x111111);
					}
					else
					{
						bd.fillRect(new Rectangle(i*currentItemHeight, 0, 4, currentItemHeight), data[i].backColor - 0x111111);
					}
					bd.fillRect(new Rectangle(i*currentItemHeight, 0, currentItemHeight, 4), data[i].backColor - 0x111111);
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
		
		public function getHitZones():Array 
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
	}
}