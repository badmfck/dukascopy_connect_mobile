package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PercentSeletor extends Sprite
	{
		private var componentWidth:int;
		private var clips:Vector.<BitmapButton>;
		private var gap:int;
		private var items:Vector.<SelectorItemData>;
		private var activated:Boolean;
		private var onSelect:Function;
		
		public function PercentSeletor() 
		{
			
		}
		
		public function draw(onSelect:Function, items:Vector.<SelectorItemData>, componentWidth:int, selectedItem:SelectorItemData = null):void
		{
			gap = Config.FINGER_SIZE * .07;
			this.componentWidth = componentWidth;
			this.items = items;
			this.onSelect = onSelect;
			clean();
			create(items, selectedItem);
		}
		
		private function create(items:Vector.<SelectorItemData>, selectedItem:SelectorItemData):void 
		{
			clips = new Vector.<BitmapButton>();
			var itemWidth:int = (componentWidth - (items.length - 1) * gap) / items.length;
			var selectedItemCreated:Boolean;
			var filled:Boolean;
			for (var i:int = 0; i < items.length; i++) 
			{
				filled = false;
				if (selectedItem != null)
				{
					filled = true;
					if (selectedItemCreated)
					{
						filled = false;
					}
				}
				clips.push(createItem(items[i], itemWidth, filled, selectedItem == items[i]));
				addChild(clips[clips.length - 1]);
				if (!selectedItemCreated)
				{
					selectedItemCreated = selectedItem == items[i];
				}
			}
			for (var j:int = 0; j < clips.length; j++) 
			{
				clips[j].x = j * (itemWidth + gap);
			}
		}
		
		private function createItem(itemData:SelectorItemData, itemWidth:int, filled:Boolean, selected:Boolean):BitmapButton 
		{
			var renderer:Sprite = new Sprite();
			var textColor:Number;
			if (selected)
			{
				textColor = Style.color(Style.COLOR_TEXT);
			}
			else
			{
				textColor = Style.color(Style.COLOR_SUBTITLE);
			}
			
			var text:ImageBitmapData = TextUtils.createTextFieldData(itemData.label, itemWidth,
																	10, true, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, FontSize.AMOUNT, true, 
																	textColor, Style.color(Style.COLOR_BACKGROUND), 
																	false, true);
			var textBitmap:Bitmap = new Bitmap(text);
			renderer.addChild(textBitmap);
			textBitmap.y = int(Config.FINGER_SIZE * .4);
			textBitmap.x = int(itemWidth * .5 - text.width * .5);
			var color:Number;
			if (filled)
			{
				color = Color.GREEN;
			}
			else
			{
				color = Style.color(Style.COLOR_LINE_SSL);
			}
			renderer.graphics.beginFill(color, 1);
			renderer.graphics.drawRect(0, 0, itemWidth, int(Config.FINGER_SIZE * .09));
			renderer.graphics.endFill();
			
			renderer.graphics.beginFill(0, 0);
			renderer.graphics.drawRect(0, 0, itemWidth, int(Config.FINGER_SIZE));
			renderer.graphics.endFill();
			
			var button:BitmapButton = new BitmapButton();
			button.setStandartButtonParams();
			button.setDownScale(1);
			button.setDownColor(0);
			button.tapCallback = onItemSelected;
			button.callbackParam = itemData;
			button.disposeBitmapOnDestroy = true;
			button.setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
			button.setBitmapData(UI.getSnapshot(renderer));
			
			if (activated)
			{
				button.activate();
			}
			
			UI.destroy(textBitmap);
			UI.destroy(renderer);
			
			return button;
		}
		
		private function onItemSelected(itemData:SelectorItemData):void 
		{
			if (activated)
			{
				draw(onSelect, items, componentWidth, itemData);
				
				if (onSelect != null)
				{
					onSelect(itemData.data);
				}
			}
		}
		
		public function activate():void
		{
			activated = true;
			if (clips != null)
			{
				for (var i:int = 0; i < clips.length; i++) 
				{
					clips[i].activate();
				}
			}
		}
		
		public function deactivate():void
		{
			activated = false;
			if (clips != null)
			{
				for (var i:int = 0; i < clips.length; i++) 
				{
					clips[i].deactivate();
				}
			}
		}
		
		private function clean():void 
		{
			if (clips != null)
			{
				for (var i:int = 0; i < clips.length; i++) 
				{
					clips[i].dispose();
				}
			}
			clips = null;
		}
		
		public function dispose():void
		{
			clean();
			items = null;
			onSelect = null;
		}
	}
}