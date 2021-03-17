package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.filter.FilterData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class HSelectorItem extends Sprite
	{
		static public const MAX_WIDTH:int = Config.FINGER_SIZE * 2.4;
		static public const HEIGHT_LABEL:int = Config.FINGER_SIZE * 0.85;
		static public const HEIGHT_ICON:int = Config.FINGER_SIZE * 1.3;
		static public const HEIGHT_WITH_ICON:int = Config.FINGER_SIZE * 1.9;
		private var data:FilterData;
		private var label:Bitmap;
		private var iconClip:Bitmap;
		private var paddingH:int;
		private var itemHeight:Number = 0;
		private var itemWidth:Number;
		private var iconSize:int;
		private var onChangeFunction:Function;
		
		public function HSelectorItem(data:FilterData, onChangeFunction:Function) 
		{
			this.data = data;
			this.onChangeFunction = onChangeFunction;
			
			paddingH = Config.FINGER_SIZE * .2;
			iconSize = Config.FINGER_SIZE * .7;
			
			draw();
		}
		
		public function getWidth():Number 
		{
			return width;
		}
		
		public function getHeight():Number 
		{
			return itemHeight;
		}
		
		public function activate():void 
		{
			PointerManager.addTap(this, onTap);
		}
		
		public function deactivate():void 
		{
			PointerManager.removeTap(this, onTap);
		}
		
		public function dispose():void 
		{
			onChangeFunction = null;
			
			graphics.clear();
			data = null;
			if (label != null)
			{
				UI.destroy(label);
				label = null;
			}
			if (iconClip != null)
			{
				UI.destroy(iconClip);
				iconClip = null;
			}
		}
		
		public function redraw():void 
		{
			updateBack();
		}
		
		private function onTap(e:Event = null):void 
		{
			data.selected = !data.selected;
			updateBack();
			if (onChangeFunction != null)
			{
				onChangeFunction(data);
			}
		}
		
		private function draw():void 
		{
			if (data != null)
			{
				if (data.iconClass != null)
				{
					var icon:Sprite;
					try
					{
						icon = new (data.iconClass)();
					}
					catch (e:Error)
					{
						ApplicationErrors.add();
					}
					if (icon != null)
					{
						UI.scaleToFit(icon, iconSize, iconSize);
					//	UI.colorize(icon, Style.color(Style.TOP_BAR_ICON_COLOR));
						
						iconClip = new Bitmap();
						addChild(iconClip);
						
						iconClip.bitmapData = UI.getSnapshot(icon);
						UI.destroy(icon);
					}
				}
				
				if (data.text != null)
				{
					label = new Bitmap();
					addChild(label);
					
					label.bitmapData = TextUtils.createTextFieldData(data.text, MAX_WIDTH, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, FontSize.SUBHEAD, true, Style.color(Style.COLOR_TEXT));
				}
				
				itemWidth = Config.FINGER_SIZE * .3;
				itemHeight = Config.FINGER_SIZE * .3;
				if (iconClip != null && label != null)
				{
					itemHeight = HEIGHT_WITH_ICON;
				}
				else if (iconClip != null)
				{
					itemHeight = HEIGHT_ICON;
				}
				else
				{
					itemHeight = HEIGHT_LABEL;
				}
				if (label != null)
				{
					itemWidth = Math.max(itemWidth, label.width);
				}
				if (iconClip != null)
				{
					itemWidth = Math.max(itemWidth, iconClip.width);
				}
				
				itemWidth += paddingH * 2;
				
				if (label != null)
				{
					label.x = int(itemWidth * .5 - label.width * .5);
					if (iconClip == null)
					{
						label.y = int(itemHeight * .5 - label.height * .5);
					}
					else
					{
						label.y = int(itemHeight * 0.75 - label.height * .5 - Config.FINGER_SIZE * .05);
					}
				}
				if (iconClip != null)
				{
					iconClip.x = int(itemWidth * .5 - iconClip.width * .5);
					if (label == null)
					{
						iconClip.y = int(itemHeight * .5 - iconClip.height * .5);
					}
					else
					{
						iconClip.y = int(itemHeight * 0.25 - iconClip.height * .5 + Config.FINGER_SIZE * .1);
					}
				}
				
				updateBack();
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function updateBack():void 
		{
			var backColor:Number;
			var outlineColor:Number;
			if (data != null && data.selected == true)
			{
				backColor = Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED);
				outlineColor = Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER);
			}
			else
			{
				backColor = Style.color(Style.COLOR_BACKGROUND);
				outlineColor = Style.color(Style.COLOR_BACKGROUND);
			}
			graphics.clear();
			graphics.lineStyle(1, outlineColor);
			graphics.beginFill(backColor);
			graphics.drawRoundRect(0, 0, itemWidth, itemHeight, Config.FINGER_SIZE * .16);
		}
	}
}