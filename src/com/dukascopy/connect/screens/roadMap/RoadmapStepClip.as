package com.dukascopy.connect.screens.roadMap 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RoadmapStepClip extends Sprite
	{
		private var title:Bitmap;
		private var subtitle:Bitmap;
		private var icon:Bitmap;
		
		private var data:RoadmapStepData;
		private var itemWidth:int;
		public static const iconSize:int = Config.FINGER_SIZE * .66;
		private var back:Sprite;
		private var overlayWidth:int;
		private var overlayHeight:int;
		private var paddingSide:int;
		private var cropRectangle:Rectangle;
		private var color:Number;
		
		public function RoadmapStepClip() 
		{
			back = new Sprite();
			addChild(back);
			
			title = new Bitmap();
			addChild(title);
			
			subtitle = new Bitmap();
			addChild(subtitle);
			
			icon = new Bitmap();
			addChild(icon);
			
			paddingSide = Config.FINGER_SIZE * 1;
		}
		
		public function setData(value:RoadmapStepData, width:int, color:Number = NaN):void
		{
			this.color = color;
			data = value;
			itemWidth = width;
			draw();
		}
		
		public function setOverlaySize(width:int, height:int, cropRectangle:Rectangle):void
		{
			overlayWidth = width;
			overlayHeight = height;
			
			this.cropRectangle = cropRectangle;
			
			drawBack();
		}
		
		public function getHeight():int
		{
			return iconSize;
		}
		
		private function draw():void 
		{
			drawicon();
			drawTitle();
			drawUbtitle();

			title.x = int(iconSize + Config.FINGER_SIZE * .3);
			subtitle.x = int(iconSize + Config.FINGER_SIZE * .3);
			
			title.y = int(iconSize * .5 - (title.height + subtitle.height + Config.FINGER_SIZE * .1) * .5 + Config.FINGER_SIZE * .05);
			subtitle.y = int(title.y + title.height + Config.FINGER_SIZE*.1);
		}
		
		private function drawBack():void 
		{
			back.graphics.beginFill(0, 0);
			back.graphics.drawRect(-x, iconSize * .5 - overlayHeight * .5, itemWidth, overlayHeight);
			back.graphics.endFill();
		}
		
		private function drawicon():void 
		{
			var iconClip:Sprite = new (data.icon)() as Sprite;
			UI.scaleToFit(iconClip, iconSize, iconSize);
			UI.colorize(iconClip, getIconColor());
			
			icon.bitmapData = UI.getSnapshot(iconClip);
			UI.destroy(iconClip);
			iconClip = null;
		}
		
		public function getIconColor():uint 
		{
			if (!isNaN(color))
			{
				return color;
			}
			switch(data.status)
			{
				case RoadmapStepData.STATE_ACTIVE:
				{
					return Style.color(Style.COLOR_TITLE);
				}
				case RoadmapStepData.STATE_DONE:
				case RoadmapStepData.STATE_CHANGE:
				{
					return Style.color(Style.COLOR_ROADMAP_DONE);
				}
				case RoadmapStepData.STATE_FAIL:
				{
					return Style.color(Style.COLOR_ROADMAP_FAIL);
				}
				case RoadmapStepData.STATE_INACTIVE:
				{
					return Style.color(Style.COLOR_ROADMAP_INACTIVE);
				}
			}
			return Style.color(Style.COLOR_ICON_LIGHT);
		}
		
		private function drawTitle():void 
		{
			var textColor:Number = Style.color(Style.COLOR_TITLE);
			if (!isNaN(color))
			{
				textColor = color;
			}
			title.bitmapData = TextUtils.createTextFieldData(data.title, getTextWidth(), 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .31, true, textColor, Style.color(Style.COLOR_BACKGROUND), true);
		}
		
		private function getTextWidth():int 
		{
			return itemWidth - iconSize - Config.FINGER_SIZE * .3;
		}
		
		private function drawUbtitle():void 
		{
			subtitle.bitmapData = TextUtils.createTextFieldData(data.subtitle, getTextWidth(), 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .20, true, getSubtitleColor(), Style.color(Style.COLOR_BACKGROUND), true);
		}
		
		private function getSubtitleColor():uint 
		{
			if (!isNaN(color))
			{
				return color;
			}
			switch(data.status)
			{
				case RoadmapStepData.STATE_ACTIVE:
				case RoadmapStepData.STATE_CHANGE:
				{
					return Style.color(Style.COLOR_ROADMAP_ACTIVE);
				}
				case RoadmapStepData.STATE_DONE:
				{
					return Style.color(Style.COLOR_ROADMAP_DONE);
				}
				case RoadmapStepData.STATE_FAIL:
				{
					return Style.color(Style.COLOR_ROADMAP_FAIL);
				}
				case RoadmapStepData.STATE_INACTIVE:
				{
					return Style.color(Style.COLOR_ROADMAP_INACTIVE);
				}
			}
			return Style.color(Style.COLOR_ICON_LIGHT);
		}
		
		public function activate():void
		{
			PointerManager.addTap(back, onSelected);
			PointerManager.addDown(back, onDown);
		}
		
		public function deactivate():void
		{
			PointerManager.removeTap(back, onSelected);
			PointerManager.removeDown(back, onDown);
		}
		
		private function onDown(e:Event = null):void 
		{
			if (data.status != RoadmapStepData.STATE_INACTIVE && data.status != RoadmapStepData.STATE_DONE)
			{
				var hitZone:HitZoneData = new HitZoneData();
				var startPoint:Point = new Point(- x, iconSize * .5 - overlayHeight * .5);
				startPoint = this.localToGlobal(startPoint);
				hitZone.width = itemWidth;
				hitZone.height = overlayHeight;
				hitZone.type = HitZoneType.MENU_MIDDLE_ELEMENT;
				var positionPoint:Point = new Point();
				
				var touchPoint:Point = new Point(back.mouseX, back.mouseY);
				var globalTouchPoint:Point = back.localToGlobal(touchPoint);
				
				hitZone.touchPoint = globalTouchPoint;
				hitZone.visibilityRect = cropRectangle;
				hitZone.x = startPoint.x;
				hitZone.y = startPoint.y;
				Overlay.displayTouch(hitZone);
			}
		}
		
		private function onSelected(e:Event = null):void 
		{
			if (data != null && data.action != null && data.status != RoadmapStepData.STATE_INACTIVE && data.status != RoadmapStepData.STATE_DONE)
			{
				data.action.execute();
			}
		}
		
		public function dispose():void 
		{
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (subtitle != null)
			{
				UI.destroy(subtitle);
				subtitle = null;
			}
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			if (data != null && data.action != null)
			{
				data.action.dispose();
			}
			data = null;
			cropRectangle = null;
		}
		
		public function getWidth():int 
		{
			return icon.width + Config.FINGER_SIZE * .3 + Math.max(title.width, subtitle.width);
		}
	}
}