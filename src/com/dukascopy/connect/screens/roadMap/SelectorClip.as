package com.dukascopy.connect.screens.roadMap 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import white.SelectClip;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SelectorClip extends Sprite
	{
		private var itemWidth:int;
		private var itemHeight:int;
		private var iconClip:Bitmap;
		private var labelClip:Bitmap;
		private var color:uint = Style.color(Style.COLOR_ICON_LIGHT);
		private var selectClip:white.SelectClip;
		private var callback:Function;
		private var selected:Boolean;
		
		public function SelectorClip(icon:Sprite, label:String, itemWidth:int, itemHeight:int, callback:Function) 
		{
			this.callback = callback;
			selectClip = new SelectClip();
			var size:int = Config.FINGER_SIZE * .5;
			UI.scaleToFit(selectClip, size, size);
			selectClip.x = int(itemWidth * .5 - selectClip.width * .5);
			selectClip.y = int(itemHeight - selectClip.height * .5);
			selectClip.visible = false;
			addChild(selectClip);
			
			this.itemWidth = itemWidth;
			this.itemHeight = itemHeight;
			
			drawIcon(icon);
			drawText(label, icon != null);
			drawBack();
			
			if (label == null)
			{
				if (iconClip != null)
				{
					iconClip.x = int(itemWidth * .5 - iconClip.width * .5);
					iconClip.y = int(itemHeight * .5 - iconClip.height * .5);
				}
			}
			else
			{
				if (iconClip != null)
				{
					iconClip.x = int(itemWidth * .5 - iconClip.width - Config.FINGER_SIZE * .1);
					iconClip.y = int(itemHeight * .5 - iconClip.height * .5);
					
					labelClip.x = int(itemWidth * .5 + Config.FINGER_SIZE * .1);
				}
				else
				{
					labelClip.x = int(itemWidth * .5 - labelClip.width * .5);
				}
				labelClip.y = int(itemHeight * .5 - labelClip.height * .5);
			}
		}
		
		private function drawBack():void 
		{
			var radius:int = Config.FINGER_SIZE * .1;
			graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			graphics.lineStyle(int(Math.max(1, Config.FINGER_SIZE * .03)), color);
			graphics.drawRoundRect(0, 0, itemWidth, itemHeight, radius, radius);
			graphics.endFill();
			
			graphics.lineStyle(0, 0, 0);
			graphics.beginFill(color);
			graphics.drawCircle(int(itemWidth * .5), itemHeight, int(Config.FINGER_SIZE * .09));
			graphics.endFill();
		}
		
		private function drawText(label:String, iconExist:Boolean):void 
		{
			if (label != null)
			{
				var textWidth:int = itemWidth * .5 - Config.FINGER_SIZE * .1 * 2;
				if (iconExist == false)
				{
					textWidth = itemWidth - Config.DIALOG_MARGIN * 2;
				}
				
				if (labelClip == null)
				{
					labelClip = new Bitmap();
					addChild(labelClip);
				}
				labelClip.bitmapData = TextUtils.createTextFieldData("<b>" + label + "</b>", textWidth, 10, 
																		true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		Config.FINGER_SIZE * .27, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true, true);
			}
		}
		
		private function drawIcon(icon:Sprite):void 
		{
			if (icon != null)
			{
				iconClip = new Bitmap();
				addChild(iconClip);
				iconClip.bitmapData = UI.getSnapshot(icon);
			}
		}
		
		public function select():void
		{
			selected = true;
			selectClip.visible = true;
			color = Color.GREEN;
			drawBack();
		}
		
		public function unselect():void
		{
			selected = false;
			selectClip.visible = false;
			color = Style.color(Style.COLOR_ICON_LIGHT);
			drawBack();
		}
		
		public function activate():void
		{
			PointerManager.addTap(this, onTap);
		}
		
		public function deactivate():void
		{
			PointerManager.addTap(this, onTap);
		}
		
		private function onTap(e:Event = null):void 
		{
			if (callback != null)
			{
				callback();
			}
			makeOverlay(MobileGui.stage.mouseX, MobileGui.stage.mouseY);
		}
		
		private function makeOverlay(downX:Number, downY:Number):void 
		{
			if (parent != null)
			{
				var data:HitZoneData = new HitZoneData();
				var startZonePoint:Point = new Point(this.x, this.y);
				startZonePoint = parent.localToGlobal(startZonePoint);
				
				data.x = startZonePoint.x;
				data.y = startZonePoint.y;
				data.width = itemWidth;
				data.height = itemHeight;
				
				data.radius = Config.FINGER_SIZE * .1;
				data.type = HitZoneType.BUTTON;
				data.touchPoint = new Point(downX, downY);
				Overlay.displayTouch(data);
			}
		}
		
		public function dispose():void
		{
			callback = null;
			graphics.clear();
			if (iconClip != null)
			{
				UI.destroy(iconClip);
				iconClip = null;
			}
			if (labelClip != null)
			{
				UI.destroy(labelClip);
				labelClip = null;
			}
			if (selectClip != null)
			{
				UI.destroy(selectClip);
				selectClip = null;
			}
		}
		
		public function isSelected():Boolean 
		{
			return selected;
		}
	}
}