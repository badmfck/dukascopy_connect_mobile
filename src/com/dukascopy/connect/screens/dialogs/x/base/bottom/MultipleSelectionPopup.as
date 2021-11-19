package com.dukascopy.connect.screens.dialogs.x.base.bottom 
{
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class MultipleSelectionPopup extends SearchListSelectionPopup
	{
		private var nextButton:BitmapButton;
		private var selectedItems:Vector.<SelectorItemData>;
		
		public function MultipleSelectionPopup() 
		{
			super();
		}
		
		override protected function createView():void
		{
			super.createView();
			createNextButton();
		}
		
		override public function initScreen(data:Object = null):void {
			drawNextButton();
			super.initScreen(data);
		}
		
		private function drawNextButton():void 
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			if (nextButton != null)
			{
				textSettings = new TextFieldSettings(Lang.textAccept.toUpperCase(), Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, _width - contentPadding * 2, Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				nextButton.setBitmapData(buttonBitmap, true);
			}
		}
		
		private function createNextButton():void 
		{
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.tapCallback = onNextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setDownScale(1);
			nextButton.setOverlay(HitZoneType.BUTTON);
			container.addChild(nextButton);
		}
		
		override protected function onRemove():void{
			if (needCallback == true){
				
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function)
				{
					if ((data.callback as Function).length == 1)
					{
						data.callback(selectedItems);
					}
				}
				selectedItems = null;
			}
		}
		
		private function onNextClick():void 
		{
			selectedItems = getSelectedItems();
			needCallback = true;
			close();
		}
		
		private function getSelectedItems():Vector.<SelectorItemData> 
		{
			var result:Vector.<SelectorItemData> = new Vector.<SelectorItemData>();
			if (list != null && list.data != null && list.data.hasOwnProperty("length"))
			{
				for (var i:int = 0; i < list.data.length; i++) 
				{
					if (list.data[i] is SelectorItemData && (list.data[i] as SelectorItemData).selected)
					{
						result.push(list.data[i] as SelectorItemData);
					}
				}
			}
			return result;
		}
		
		override protected function drawView():void 
		{
			super.drawView();
			nextButton.x = contentPadding;
			nextButton.y = getContentHeight() - nextButton.height - contentPadding;
		}
		
		override public function activateScreen():void 
		{
			super.activateScreen();
			nextButton.activate();
		}
		
		override public function deactivateScreen():void 
		{
			super.deactivateScreen();
			nextButton.deactivate();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
		}
		
		override protected function onItemTap(data:Object, n:int):void {
			needCallback = true;
			
			selectedNum = n;
			if (list.data != null)
			{
				if ("disabled" in list.data[selectedNum] && list.data[selectedNum].disabled == true)
				{
					return;
				}
				var l:int = list.data.length;
				/*for (var i:int = 0; i < l; i++) 
				{
					if ("selected" in list.data[i])
					{
						list.data[i].selected = false;
					}
				}*/
			}
			if ("selected" in data)
			{
				data.selected = !data.selected;
			}
			list.refresh();
		}
		
		override protected function getMaxContentHeight():int
		{
			return super.getMaxContentHeight() - contentPadding * 2 - nextButton.height;
		}
	}
}