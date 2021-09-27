package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.escrow.FiltersPanel;
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
	public class FiltersSelectList extends Sprite
	{
		private var promptValue:String;
		private var titleValue:String;
		private var itemWidth:int;
		
		private var title:Bitmap;
		private var underline:Bitmap;
		private var prompt:Bitmap;
		private var filtersPanel:FiltersPanel;
		private var items:Vector.<SelectorItemData>;
		private var clicker:Sprite;
		private var isActive:Boolean;
		private var onSelectFunction:Function;
		private var onResizeFunction:Function;
		
		public function FiltersSelectList(promptValue:String, titleValue:String, onSelectFunction:Function = null, onResizeFunction:Function = null) 
		{
			this.promptValue = promptValue;
			this.titleValue = titleValue;
			this.onSelectFunction = onSelectFunction;
			this.onResizeFunction = onResizeFunction;
		}
		
		public function draw(items:Vector.<SelectorItemData>, itemWidth:int):void
		{
			this.itemWidth = itemWidth;
			this.items = items;
			
			if (items == null || items.length == 0)
			{
				addUnderline();
				addPrompt();
				removeTitle();
				removeItems();
				addClicker();
			}
			else
			{
				removeUnderline();
				addTitle();
				removePrompt();
				addItems();
				removeClicker();
			}
			updatePsitions();
		}
		
		private function removeClicker():void 
		{
			if (clicker != null)
			{
				if (contains(clicker))
				{
					removeChild(clicker);
				}
				PointerManager.removeTap(clicker, onTap);
				UI.destroy(clicker);
				clicker = null;
			}
		}
		
		private function addClicker():void 
		{
			if (clicker == null)
			{
				clicker = new Sprite();
				addChild(clicker);
				clicker.graphics.beginFill(0);
				clicker.graphics.drawRect(0, 0, itemWidth, int(prompt.height + Config.FINGER_SIZE * .2));
				clicker.y = -int(Config.FINGER_SIZE * .1);
				clicker.alpha = 0;
			}
			if (isActive)
			{
				PointerManager.addTap(clicker, onTap);
			}
		}
		
		private function onTap(e:Event = null):void 
		{
			if (onSelectFunction != null)
			{
				onSelectFunction();
			}
		}
		
		public function activate():void
		{
			isActive = true;
			if (filtersPanel != null)
			{
				filtersPanel.activate();
			}
			if (clicker != null)
			{
				PointerManager.addTap(clicker, onTap);
			}
		}
		
		public function deactivate():void
		{
			isActive = false;
			if (filtersPanel != null)
			{
				filtersPanel.deactivate();
			}
			if (clicker != null)
			{
				PointerManager.removeTap(clicker, onTap);
			}
		}
		
		private function updatePsitions():void 
		{
			var position:int = 0;
			if (title != null)
			{
				title.y = position;
				position += title.height + Config.FINGER_SIZE * .2;
			}
			if (prompt != null)
			{
				prompt.y = position;
				position += prompt.height + Config.FINGER_SIZE * .1;
			}
			if (filtersPanel != null)
			{
				filtersPanel.y = position;
				position += filtersPanel.height + Config.FINGER_SIZE * .1;
			}
			if (underline != null)
			{
				underline.y = position;
			}
		}
		
		private function addItems():void 
		{
			if (filtersPanel == null)
			{
				filtersPanel = new FiltersPanel(onItemRemove);
				addChild(filtersPanel);
			}
			filtersPanel.draw(items, itemWidth);
			if (isActive)
			{
				filtersPanel.activate();
			}
		}
		
		private function onItemRemove(item:SelectorItemData):void 
		{
			items.removeAt(items.indexOf(item));
			draw(items, itemWidth);
			onResize();
		}
		
		private function onResize():void 
		{
			if (onResizeFunction != null)
			{
				onResizeFunction();
			}
		}
		
		private function removeItems():void 
		{
			if (filtersPanel != null)
			{
				if (contains(filtersPanel))
				{
					removeChild(filtersPanel);
				}
				filtersPanel.deactivate();
				filtersPanel.dispose();
				filtersPanel = null;
			}
		}
		
		private function removePrompt():void 
		{
			if (prompt != null)
			{
				if (contains(prompt))
				{
					removeChild(prompt);
				}
				UI.destroy(prompt);
				prompt = null;
			}
		}
		
		private function addTitle():void 
		{
			if (title == null)
			{
				title = new Bitmap();
				addChild(title);
			}
			else if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = TextUtils.createTextFieldData(titleValue, itemWidth, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
		}
		
		private function removeUnderline():void 
		{
			if (underline != null)
			{
				if (contains(underline))
				{
					removeChild(underline);
				}
				UI.destroy(underline);
				underline = null;
			}
		}
		
		private function removeTitle():void 
		{
			if (title != null)
			{
				if (contains(title))
				{
					removeChild(title);
				}
				UI.destroy(title);
				title = null;
			}
		}
		
		private function addPrompt():void 
		{
			if (prompt == null)
			{
				prompt = new Bitmap();
				addChild(prompt);
			}
			else if (prompt.bitmapData != null)
			{
				prompt.bitmapData.dispose();
				prompt.bitmapData = null;
			}
			prompt.bitmapData = TextUtils.createTextFieldData(promptValue, itemWidth, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.TITLE_2, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
		}
		
		private function addUnderline():void 
		{
			if (underline == null)
			{
				underline = new Bitmap();
				addChild(underline);
				underline.bitmapData = UI.getHorizontalLine(Style.color(Style.COLOR_LINE_LIGHT));
			}
			underline.width = itemWidth;
		}
		
		public function dispose():void
		{
			items = null;
			onSelectFunction = null;
			onResizeFunction = null;
			
			removeItems();
			removePrompt();
			removeTitle();
			removeUnderline();
			removeClicker();
		}
		
		public function getSelection():Vector.<SelectorItemData> 
		{
			if (filtersPanel != null)
			{
				return filtersPanel.getSelection();
			}
			
			return null;
		}
	}
}