package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LinkClip extends Sprite
	{
		private var back:Sprite;
		private var text:Bitmap;
		private var icon:Bitmap;
		
		private var value:String;
		private var link:String;
		private var maxWidth:int;
		
		public function LinkClip(value:String, link:String, maxWidth:int) 
		{
			this.value = value;
			this.link = link;
			this.maxWidth = maxWidth;
			
			back = new Sprite();
			addChild(back);
			
			text = new Bitmap();
			addChild(text);
			
			icon = new Bitmap();
			addChild(icon);
			
			var iconSource:Sprite = new LinkIcon3();
			var iconSize:int = Config.FINGER_SIZE * .26;
			UI.scaleToFit(iconSource, iconSize, iconSize);
			UI.colorize(iconSource, Color.RED);
			icon.bitmapData = UI.getSnapshot(iconSource);
			text.bitmapData = TextUtils.createTextFieldData(value, maxWidth - iconSource.width - Config.FINGER_SIZE * .15, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Color.RED,
																	Style.color(Style.COLOR_BACKGROUND), false);
																	
			text.y = int(Math.max(text.height, icon.height) * .5 - text.height * .5);
			icon.y = int(Math.max(text.height, icon.height) * .5 - icon.height * .5);
			
			icon.x = int(text.x + text.width + Config.FINGER_SIZE * .15);
			
			back.graphics.beginFill(0, 0);
			back.graphics.drawRect(0, 0, icon.x + icon.width, Math.max(icon.height, text.height));
			back.graphics.endFill();
		}
		
		public function dispose():void
		{
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
		}
		
		public function activate():void
		{
			PointerManager.addTap(this, openLink);
			PointerManager.addDown(this, showTouch);
		}
		
		private function openLink(e:Event):void 
		{
			navigateToURL(new URLRequest(link));
		}
		
		private function showTouch(e:Event):void 
		{
			if (parent != null)
			{
				var hitZone:HitZoneData = new HitZoneData();
				var startPoint:Point = new Point(x - Config.FINGER_SIZE *.2, y - Config.FINGER_SIZE *.2);
				startPoint = parent.localToGlobal(startPoint);
				hitZone.width = width + Config.FINGER_SIZE *.4;
				hitZone.height = height + Config.FINGER_SIZE *.4;
				hitZone.type = HitZoneType.MENU_SIMPLE_ELEMENT;
				hitZone.radius = hitZone.height * .5;
				var positionPoint:Point = new Point();
				
				var touchPoint:Point = new Point(mouseX, mouseY);
				var globalTouchPoint:Point = localToGlobal(touchPoint);
				
				hitZone.touchPoint = globalTouchPoint;
				hitZone.x = startPoint.x;
				hitZone.y = startPoint.y;
				Overlay.displayTouch(hitZone);
			}
		}
		
		public function deactivate():void
		{
			PointerManager.removeTap(this, openLink);
			PointerManager.removeDown(this, showTouch);
		}
	}
}