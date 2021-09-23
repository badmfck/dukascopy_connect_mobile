package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.escrow.filter.EscrowFilter;
	import com.dukascopy.connect.data.escrow.filter.EscrowFilterType;
	import com.dukascopy.connect.data.layout.LayoutType;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.radio.RadioGroup;
	import com.dukascopy.connect.gui.components.radio.RadioItem;
	import com.dukascopy.connect.gui.components.selector.ButtonSelectorItem;
	import com.dukascopy.connect.gui.components.selector.MultiSelector;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.AnimatedTitlePopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class EscrowFilterScreen extends ScrollAnimatedTitlePopup {
		
		private var nextButton:BitmapButton;
		
		private var needCallback:Boolean;
		
		private var radio:RadioGroup;
		private var radioSelection:Vector.<SelectorItemData>;
		private var titleSort:Bitmap;
		private var titleBlacklist:Bitmap;
		private var headerHeight:Number;
		private var tradingSideSelector:MultiSelector;
		private var filters:Vector.<EscrowFilter>;
		
		public function EscrowFilterScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createNextButton();
			createRadio();
			
			titleSort = new Bitmap();
			addItem(titleSort);
			
			titleBlacklist = new Bitmap();
			addItem(titleBlacklist);
			
			tradingSideSelector = new MultiSelector();
			tradingSideSelector.multiselection = false;
			tradingSideSelector.itemRenderer = ButtonSelectorItem;
			tradingSideSelector.gap = Config.FINGER_SIZE * .3;
			tradingSideSelector.S_ON_SELECT.add(onSideSelected);
			addItem(tradingSideSelector);
		}
		
		private function onSideSelected(selectedItem:SelectorItemData):void 
		{
			
		}
		
		private function createRadio():void 
		{
			radio = new RadioGroup(onRadioSelection, LayoutType.horizontal);
			addItem(radio);
		}
		
		private function onRadioSelection(value:SelectorItemData):void 
		{
			if (value != null && value.data != null && value.data is Function)
			{
				(value.data as Function)();
			}
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createNextButton():void 
		{
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.tapCallback = onNextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setDownScale(1);
			nextButton.setOverlay(HitZoneType.BUTTON);
			addItem(nextButton);
		}
		
		private function onNextClick():void 
		{
			collectFilters();
			needCallback = true;
			close();
		}
		
		private function collectFilters():void 
		{
			var selectedDiretions:Vector.<SelectorItemData> = tradingSideSelector.getSelectedDataVector();
			if (selectedDiretions != null && selectedDiretions.length > 0)
			{
				var direction:TradeDirection = selectedDiretions[0].data as TradeDirection;
				var sideFilter:EscrowFilter = new EscrowFilter(EscrowFilterType.DIRECTION, direction.type);
				
				addFilter(sideFilter);
			}
		}
		
		private function addFilter(filter:EscrowFilter):void 
		{
			if (filters == null)
			{
				filters = new Vector.<EscrowFilter>();
			}
			filters.push(filter);
		}
		
		override public function initScreen(data:Object = null):void {
			
			super.initScreen(data);
		}
		
		private function drawTitleBlacklist():void 
		{
			if (titleBlacklist.bitmapData != null)
			{
				titleBlacklist.bitmapData.dispose();
				titleBlacklist.bitmapData = null;
			}
			titleBlacklist.bitmapData = TextUtils.createTextFieldData(Lang.blackList, getWidth(), 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
		}
		
		private function getWidth():int 
		{
			return _width - contentPadding * 2;
		}
		
		private function drawTitleSort():void 
		{
			if (titleSort.bitmapData != null)
			{
				titleSort.bitmapData.dispose();
				titleSort.bitmapData = null;
			}
			titleSort.bitmapData = TextUtils.createTextFieldData(Lang.sortBy, getWidth(), 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
		}
		
		override protected function updateContentPositions():void 
		{
			drawControls();
			drawTitleSort();
			drawTitleBlacklist();
			
			tradingSideSelector.dataProvider = getTradingSideVariants();
			
			updatePositions();
		}
		
		private function getTradingSideVariants():Vector.<SelectorItemData> 
		{
			var result:Vector.<SelectorItemData> = new Vector.<SelectorItemData>();
			result.push(new SelectorItemData(Lang.buy_ads, TradeDirection.buy));
			result.push(new SelectorItemData(Lang.sell_ads, TradeDirection.sell));
			result.push(new SelectorItemData(Lang.buy_sell_ads, TradeDirection.buy_sell));
			return result;
		}
		
		override protected function getBottomPadding():int 
		{
			var result:int = 0;
			if (nextButton != null)
			{
				result = nextButton.height + contentPadding * 2;
			}
			return result;
		}
		
		private function updatePositions():void 
		{
			var position:int;
			
			position = Config.FINGER_SIZE * .5;
			
			tradingSideSelector.y = position;
			tradingSideSelector.x = contentPadding;
			position += tradingSideSelector.height + Config.FINGER_SIZE * .3;
			
			titleSort.x = int(getWidth() * .5 - titleSort.width * .5);
			titleSort.y = position;
			position += titleSort.height + Config.FINGER_SIZE * .2;
			
			radio.x = contentPadding;
			radio.y = position;
			position += radio.height + contentPaddingV;
			
			titleBlacklist.x = int(getWidth() * .5 - titleBlacklist.width * .5);
			titleBlacklist.y = position;
			position += titleBlacklist.height + Config.FINGER_SIZE * .5;
			
			nextButton.x = contentPadding;
			nextButton.y = position;
			
			if (nextButton.y + nextButton.height + contentPadding + scrollPanel.view.y < backgroundContent.height && backgroundContent.height > 0)
			{
				nextButton.y = backgroundContent.height - nextButton.height - contentPadding - scrollPanel.view.y;
			}
		}
		
		private function drawControls():void
		{
			//!TODO: padding;
			tradingSideSelector.maxWidth = getWidth();
			
			radioSelection = new Vector.<SelectorItemData>();
			radioSelection.push(new SelectorItemData(Lang.filter_date, null));
			radioSelection.push(new SelectorItemData(Lang.filter_price, null));
			radioSelection.push(new SelectorItemData(Lang.filter_amount, null));
			
			radio.draw(radioSelection, getWidth() - contentPadding * 2, RadioItem);
			radio.select(radioSelection[0]);
			
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			if (nextButton != null)
			{
				textSettings = new TextFieldSettings(Lang.textAccept.toUpperCase(), Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				nextButton.setBitmapData(buttonBitmap, true);
			}
		}
		
		private function getButtonWidth():int 
		{
			return getWidth();
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .3;
			super.drawView();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			
			radio.activate();
			nextButton.activate();
			tradingSideSelector.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			radio.deactivate();
			nextButton.deactivate();
			tradingSideSelector.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1)
				{
					
					(data.callback as Function)(filters);
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (tradingSideSelector != null)
			{
				tradingSideSelector.S_ON_SELECT.remove(onSideSelected);
				tradingSideSelector.dispose();
				tradingSideSelector = null;
			}
			if (titleSort != null)
			{
				UI.destroy(titleSort);
				titleSort = null;
			}
			if (titleBlacklist != null)
			{
				UI.destroy(titleBlacklist);
				titleBlacklist = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (radio != null)
			{
				radio.dispose();
				radio = null;
			}
			
			radioSelection = null;
		}
	}
}