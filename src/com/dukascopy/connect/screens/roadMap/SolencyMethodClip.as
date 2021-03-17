package com.dukascopy.connect.screens.roadMap 
{
	import assets.StepSelectedIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
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
	public class SolencyMethodClip extends Sprite
	{
		private var title:Bitmap;
		private var subtitle:Bitmap;
		private var icon:Bitmap;
		private var iconDone:Bitmap;
		
		public var data:SolvencyMethodData;
		private var itemWidth:int;
		public static const iconSize:int = Config.FINGER_SIZE * .66;
		public var onSelect:Function;
		private var back:Sprite;
		private var paddingSide:int;
		private var cropRectangle:Rectangle;
		private var standartHeight:int;
		private var realHeight:int;
		
		public function SolencyMethodClip() 
		{
			back = new Sprite();
			addChild(back);
			
			title = new Bitmap();
			addChild(title);
			
			subtitle = new Bitmap();
			addChild(subtitle);
			
			icon = new Bitmap();
			addChild(icon);
			
			iconDone = new Bitmap();
			addChild(iconDone);
			iconDone.visible = false;
			
			paddingSide = Config.FINGER_SIZE * 0.45;
			standartHeight = Config.FINGER_SIZE * 2.2;
			realHeight = standartHeight;
			
			icon.x = paddingSide;
			icon.y = int(standartHeight * .5 - iconSize * .5);
			
			iconDone.x = paddingSide;
			iconDone.y = int(standartHeight * .5 - iconSize * .5);
		}
		
		public function setData(value:SolvencyMethodData, width:int):void
		{
			data = value;
			itemWidth = width;
			draw();
		}
		
		public function getHeight():int 
		{
			return realHeight;
		}
		
		private function draw():void 
		{
			drawicon();
			drawTitle();
			drawUbtitle();
			
			title.x = int(iconSize + paddingSide * 2);
			subtitle.x = int(iconSize + paddingSide * 2);
			
			title.y = int(standartHeight*.5 - Config.FINGER_SIZE*.3 - title.height);
			subtitle.y = standartHeight * .5;
			
			if (subtitle.y + subtitle.height + Config.FINGER_SIZE*.3 > standartHeight)
			{
				realHeight = subtitle.y + subtitle.height + Config.FINGER_SIZE * .3;
			}
			drawBack();
		}
		
		private function drawBack():void 
		{
			var radius:int = Config.FINGER_SIZE * .2;
			
			back.graphics.clear();
			back.graphics.lineStyle(1, Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER));
			back.graphics.beginFill(getBackColor(), 1);
			back.graphics.drawRoundRect(0, 0, itemWidth, getHeight(), radius, radius);
			back.graphics.endFill();
			
			if (data != null && data.selected)
			{
				iconDone.visible = true;
				icon.visible = false;
			}
			else
			{
				iconDone.visible = false;
				icon.visible = true;
			}
		}
		
		private function getBackColor():uint 
		{
			if (data != null && data.selected)
			{
				return Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER);
			}
			else
			{
				return Style.color(Style.COLOR_BACKGROUND);
			}
		}
		
		private function drawicon():void 
		{
			if (data.icon != null)
			{
				var iconClip:Sprite = new (data.icon)() as Sprite;
				UI.scaleToFit(iconClip, iconSize, iconSize);
				UI.colorize(iconClip, Style.color(Style.COLOR_ICON_SETTINGS));
				
				icon.bitmapData = UI.getSnapshot(iconClip);
				UI.destroy(iconClip);
				iconClip = null;
			}
			
			var iconDoneClip:Sprite = new StepSelectedIcon();
			UI.scaleToFit(iconDoneClip, iconSize, iconSize);
			
			iconDone.bitmapData = UI.getSnapshot(iconDoneClip);
			UI.destroy(iconDoneClip);
			iconDoneClip = null;
		}
		
		private function drawTitle():void 
		{
			title.bitmapData = TextUtils.createTextFieldData("<b>" + data.title + "</b>", getTextWidth(), 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.TITLE_2, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true, true);
		}
		
		private function getTextWidth():int 
		{
			return itemWidth - paddingSide * 3 - iconSize;
		}
		
		private function drawUbtitle():void 
		{
			subtitle.bitmapData = TextUtils.createTextFieldData(data.subtitle, getTextWidth(), 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true);
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
			var hitZone:HitZoneData = new HitZoneData();
			var startPoint:Point = new Point(0, 0);
			startPoint = this.localToGlobal(startPoint);
			hitZone.width = itemWidth;
			hitZone.height = getHeight();
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
		
		private function onSelected(e:Event = null):void 
		{
			if (onSelect != null)
			{
				onSelect(this);
			}
		}
		
		public function dispose():void 
		{
			onSelect = null;
			
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
			if (iconDone != null)
			{
				UI.destroy(iconDone);
				iconDone = null;
			}
			data = null;
			cropRectangle = null;
		}
		
		public function select():void 
		{
			if (data != null)
			{
				data.selected = true;
				drawBack();
			}
		}
		
		public function unselect():void 
		{
			if (data != null)
			{
				data.selected = false;
				drawBack();
			}
		}
	}
}