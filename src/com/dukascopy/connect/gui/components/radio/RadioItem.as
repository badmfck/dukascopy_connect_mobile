package com.dukascopy.connect.gui.components.radio 
{
	import assets.RadioIcon;
	import assets.RadioSelectedIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
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
	public class RadioItem extends Sprite
	{
		private var baseState:Bitmap;
		private var selectedState:Bitmap;
		private var text:Bitmap;
		private var selectorItemData:SelectorItemData;
		private var onSelect:Function;
		private var itemWidth:int;
		
		public function RadioItem(onSelect:Function) 
		{
			this.onSelect = onSelect;
			
			baseState = new Bitmap();
			addChild(baseState);
			
			selectedState = new Bitmap();
			addChild(selectedState);
			
			var iconSize:int = Config.FINGER_SIZE * .46;
			var icon:Sprite = new RadioSelectedIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			selectedState.bitmapData = UI.getSnapshot(icon);
			
			icon = new RadioIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			baseState.bitmapData = UI.getSnapshot(icon);
			
			text = new Bitmap();
			addChild(text);
			
			selectedState.visible = false;
		}
		
		public function activate():void
		{
			PointerManager.addDown(this, showOverlay);
			PointerManager.addTap(this, onTap);
		}
		
		private function onTap(e:Event):void 
		{
			if (onSelect != null)
			{
				onSelect(getData());
			}
		}
		
		public function getData():SelectorItemData
		{
			return selectorItemData;
		}
		
		private function showOverlay(e:Event):void 
		{
			//!TODO:;
		}
		
		public function deactivate():void
		{
			PointerManager.removeDown(this, showOverlay);
			PointerManager.removeTap(this, onTap);
		}
		
		public function dispose():void
		{
			onSelect = null;
			selectorItemData = null;
			
			if (baseState != null)
			{
				UI.destroy(baseState);
				baseState = null;
			}
			if (selectedState != null)
			{
				UI.destroy(selectedState);
				selectedState = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
		}
		
		public function draw(selectorItemData:SelectorItemData, itemWidth:int):void 
		{
			this.selectorItemData = selectorItemData;
			this.itemWidth = itemWidth;
			drawText();
			
			var padding:int = Config.FINGER_SIZE * .1;
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect( -padding, -padding, itemWidth + padding * 2, height + padding * 2);
			graphics.endFill();
			
			text.x = int(selectedState.x + selectedState.width + Config.FINGER_SIZE * .2);
			baseState.y = selectedState.y = int(Math.max(text.y + text.height * .5 - selectedState.height * .5, 0));
			
			if (baseState.y == 0)
			{
				text.y = int(Math.max(0, baseState.height * .5 - text.height * .5));
			}
		}
		
		public function select():void 
		{
			selectedState.visible = true;
			baseState.visible = false;
		}
		
		public function unselect():void 
		{
			selectedState.visible = false;
			baseState.visible = true;
		}
		
		private function drawText():void 
		{
			if (text != null)
			{
				if (text.bitmapData != null)
				{
					text.bitmapData.dispose();
					text.bitmapData = null;
				}
				if (selectorItemData != null && selectorItemData.label != null)
				{
					text.bitmapData = TextUtils.createTextFieldData(selectorItemData.label, itemWidth - selectedState.width - Config.FINGER_SIZE*.2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
				}
				else
				{
					ApplicationErrors.add("data");
				}
			}
			else
			{
				ApplicationErrors.add("clip");
			}
		}
	}
}