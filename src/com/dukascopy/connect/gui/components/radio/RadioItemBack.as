package com.dukascopy.connect.gui.components.radio 
{
	import assets.Radio2;
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
	public class RadioItemBack extends Sprite implements IRadioItem
	{
		private var baseState:Bitmap;
		private var selectedState:Bitmap;
		private var text:Bitmap;
		private var selectorItemData:SelectorItemData;
		private var onSelect:Function;
		private var itemWidth:int;
		private var selected:Boolean;
		private var padding:int;
		private var paddingV:int;
		
		public function RadioItemBack(onSelect:Function) 
		{
			this.onSelect = onSelect;
			
			baseState = new Bitmap();
			addChild(baseState);
			
			selectedState = new Bitmap();
			addChild(selectedState);
			
			var iconSize:int = Config.FINGER_SIZE * .8;
			var icon:Sprite = new RadioSelect2();
			UI.scaleToFit(icon, iconSize, iconSize);
			selectedState.bitmapData = UI.getSnapshot(icon);
			
			icon = new Radio2();
			UI.scaleToFit(icon, iconSize, iconSize);
			baseState.bitmapData = UI.getSnapshot(icon);
			
			text = new Bitmap();
			addChild(text);
			
			selectedState.visible = false;
			
			padding = Config.FINGER_SIZE * .25;
			paddingV = Config.FINGER_SIZE * .25;
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
			baseState.x = selectedState.x = padding;
			text.x = int(selectedState.x + selectedState.width + padding);
			var resultHeight:int = int(Math.max(text.height, selectedState.height)) + paddingV * 2;
			baseState.y = selectedState.y = int(resultHeight * .5 - selectedState.height * .5);
			
			text.y = int(resultHeight * .5 - text.height * .5);
			
			drawBack();
		}
		
		private function drawBack():void 
		{
			graphics.clear();
			
			var r:int = Config.FINGER_SIZE * .2;
			if (selected)
			{
				graphics.beginFill(Style.color(Style.COLOR_LIST_SPECIAL));
			}
			else
			{
				graphics.beginFill(Style.color(Style.COLOR_LIST_SPECIAL), 0);
				graphics.lineStyle(int(Math.max(1, Config.FINGER_SIZE * .04)), Style.color(Style.COLOR_LIST_SPECIAL));
			}
			graphics.drawRoundRect(0, 0, itemWidth, int(Math.max(selectedState.height, text.height) + paddingV * 2), r, r);
			graphics.endFill();
		}
		
		public function select():void 
		{
			selected = true;
			
			selectedState.visible = true;
			baseState.visible = false;
			
			drawBack();
		}
		
		public function unselect():void 
		{
			selected = false;
			
			selectedState.visible = false;
			baseState.visible = true;
			
			drawBack();
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
					text.bitmapData = TextUtils.createTextFieldData(selectorItemData.label, itemWidth - selectedState.width - padding * 3, 10, true,
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