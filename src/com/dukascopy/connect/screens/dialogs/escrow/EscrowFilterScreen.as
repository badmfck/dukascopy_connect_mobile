package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.layout.LayoutType;
	import com.dukascopy.connect.gui.button.Checkbox;
	import com.dukascopy.connect.gui.components.FiltersSelectList;
	import com.dukascopy.connect.gui.components.radio.RadioGroup;
	import com.dukascopy.connect.gui.components.radio.RadioItem;
	import com.dukascopy.connect.gui.components.selector.ButtonSelectorItem;
	import com.dukascopy.connect.gui.components.selector.MultiSelector;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCountryExclude;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsFilterVO;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.MultipleSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
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
		private var line:Bitmap;
		private var line2:Bitmap;
		private var hideBlocked:Checkbox;
		private var hideNoobs:Checkbox;
		private var countryExclude:FiltersSelectList;
		private var filter:EscrowAdsFilterVO;
		
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
			
			line = new Bitmap();
			line.bitmapData = UI.getHorizontalLine(Style.color(Style.COLOR_SEPARATOR));
			addItem(line);
			
			line2 = new Bitmap();
			line2.bitmapData = UI.getHorizontalLine(Style.color(Style.COLOR_SEPARATOR));
			addItem(line2);
			
			hideBlocked = new Checkbox(Lang.escrow_hide_blocked);
			addItem(hideBlocked);
			hideNoobs = new Checkbox(Lang.escrow_hide_noobs);
			addItem(hideNoobs);
			
			countryExclude = new FiltersSelectList(Lang.excrow_exclude_country, Lang.escrow_excluded_countries, selectCountryExclude, oncountryListResize);
			addItem(countryExclude);
		}
		
		private function oncountryListResize():void 
		{
			updatePositions();
		}
		
		private function selectCountryExclude():void 
		{
			var oldDelimiter:String = "";
			var newDelimiter:String = "";
			var cData:Array = CountriesData.COUNTRIES;
			var cDataNew:Array = [];
			for (var i:int = 0; i < cData.length; i++) {
				newDelimiter = String(cData[i][0]).substr(0, 1).toUpperCase();
				if (newDelimiter != oldDelimiter) {
					oldDelimiter = newDelimiter;
					cDataNew.push([oldDelimiter.toLowerCase(), oldDelimiter]);
				}
				cDataNew.push(cData[i]);
			}
			
			var items:Vector.<SelectorItemData> = new Vector.<SelectorItemData>();
		//	var selectedItems:
			for (var j:int = 0; j < cDataNew.length; j++) 
			{
				items.push(new SelectorItemData(cDataNew[j][4], cDataNew[j]));
			}
			DialogManager.showDialog(
					MultipleSelectionPopup,
					{
						items:items,
						title:Lang.selectCountry,
						renderer:ListCountryExclude,
						callback:onCountryListSelected
					}, ServiceScreenManager.TYPE_SCREEN
				);
		}
		
		private function onCountryListSelected(selectedCountries:Vector.<SelectorItemData>):void
		{
			var filtered:Vector.<SelectorItemData>;
			if (selectedCountries != null)
			{
				filtered = new Vector.<SelectorItemData>();
				for (var i:int = 0; i < selectedCountries.length; i++) 
				{
					if (selectedCountries[i].data != null && selectedCountries[i].data is Array && (selectedCountries[i].data as Array).length == 5)
					{
						filtered.push(selectedCountries[i]);
					}
				}
			}
			countryExclude.draw(filtered, _width - contentPadding * 2);
			updatePositions();
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
			container.addChild(nextButton);
		}
		
		private function onNextClick():void 
		{
			collectFilters();
			needCallback = true;
			close();
		}
		
		private function collectFilters():void 
		{
			if (filter != null)
			{
				var sortTypeExist:Boolean;
				var selectedDiretions:Vector.<SelectorItemData> = tradingSideSelector.getSelectedDataVector();
				if (selectedDiretions != null && selectedDiretions.length > 0)
				{
					var direction:TradeDirection = selectedDiretions[0].data as TradeDirection;
					if (direction == TradeDirection.buy_sell)
					{
						filter.sort = EscrowAdsFilterVO.SORT_BUY_SELL;
						filter.side = null;
						sortTypeExist = true;
					}
					else
					{
						filter.side = direction.type;
					}
				}
				else
				{
					filter.side = null;
				}
				
				if (radio.getSelection() != null && radio.getSelection().data != null && radio.getSelection().data is String && !sortTypeExist)
				{
					filter.sort = radio.getSelection().data as String;
				}
				else
				{
					if (!sortTypeExist)
					{
						filter.sort = null;
					}
				}
				
				var countriesSelected:Vector.<SelectorItemData> = countryExclude.getSelection();
				if (countriesSelected != null && countriesSelected.length > 0)
				{
					var countries:Array = new Array();
					for (var i:int = 0; i < countriesSelected.length; i++) 
					{
						countries.push(countriesSelected[i].data[2]);
					}
					
					filter.countries = countries;
				}
				else
				{
					filter.countries = null;
				}
				
				if (hideNoobs != null && hideNoobs.isSelected())
				{
					filter.hideNoobs = true;
				}
				else
				{
					filter.hideNoobs = false;
				}
				
				if (hideBlocked != null && hideBlocked.isSelected())
				{
					filter.hideBlocked = true;
				}
				else
				{
					filter.hideBlocked = false;
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		override public function initScreen(data:Object = null):void {
			
			if (data != null && "filter" in data && data.filter != null && data.filter is EscrowAdsFilterVO)
			{
				filter = data.filter as EscrowAdsFilterVO;
			}
			else
			{
				ApplicationErrors.add();
			}
			
			super.initScreen(data);
			
			radioSelection = new Vector.<SelectorItemData>();
			radioSelection.push(new SelectorItemData(Lang.filter_date, EscrowAdsFilterVO.SORT_DATE));
			radioSelection.push(new SelectorItemData(Lang.filter_price, EscrowAdsFilterVO.SORT_PRICE));
			radioSelection.push(new SelectorItemData(Lang.filter_amount, EscrowAdsFilterVO.SORT_AMOUNT));
			
			tradingSideSelector.dataProvider = getTradingSideVariants();
			
			countryExclude.draw(null, _width - contentPadding * 2);
			
			applyCurrentFilter();
		}
		
		private function applyCurrentFilter():void 
		{
			if (tradingSideSelector != null)
			{
				if (filter.side == TradeDirection.buy.type)
				{
					tradingSideSelector.selectItemIndex(0);
				}
				else if (filter.side == TradeDirection.sell.type)
				{
					tradingSideSelector.selectItemIndex(1);
				}
			}
			else
			{
				ApplicationErrors.add();
			}
			
			if (filter.hideBlocked == true)
			{
				if (hideBlocked != null)
				{
					hideBlocked.select();
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			
			if (filter.hideNoobs == true)
			{
				if (hideNoobs != null)
				{
					hideNoobs.select();
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			
			if (filter.sort == EscrowAdsFilterVO.SORT_AMOUNT)
			{
				if (radio != null && radioSelection != null)
				{
					radio.select(radioSelection[2]);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else if (filter.sort == EscrowAdsFilterVO.SORT_BUY_SELL)
			{
				if (tradingSideSelector != null)
				{
					tradingSideSelector.selectItemIndex(2);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else if (filter.sort == EscrowAdsFilterVO.SORT_DATE)
			{
				if (radio != null && radioSelection != null)
				{
					radio.select(radioSelection[0]);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else if (filter.sort == EscrowAdsFilterVO.SORT_PRICE)
			{
				if (radio != null && radioSelection != null)
				{
					radio.select(radioSelection[1]);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			
			if (filter.countries != null)
			{
				if (countryExclude != null)
				{
					var oldDelimiter:String = "";
					var newDelimiter:String = "";
					var cData:Array = CountriesData.COUNTRIES;
					var cDataNew:Array = [];
					var l:int = cData.length;
					var i:int;
					for (i = 0; i < l; i++) {
						newDelimiter = String(cData[i][0]).substr(0, 1).toUpperCase();
						if (newDelimiter != oldDelimiter) {
							oldDelimiter = newDelimiter;
							cDataNew.push([oldDelimiter.toLowerCase(), oldDelimiter]);
						}
						cDataNew.push(cData[i]);
					}
					l = cDataNew.length;
					var countriesSelection:Vector.<SelectorItemData> = new Vector.<SelectorItemData>();
					for (var j:int = 0; j < l; j++) 
					{
						for (i = 0; i < filter.countries.length; i++) 
						{
							if (filter.countries[i] == cDataNew[j][2])
							{
								countriesSelection.push(new SelectorItemData(cDataNew[j][4], cDataNew[j]));
							}
						}
					}
					
					countryExclude.draw(countriesSelection, _width - contentPadding * 2);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
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
			
			position = Config.FINGER_SIZE * .6;
			
			tradingSideSelector.y = position;
			tradingSideSelector.x = contentPadding;
			position += tradingSideSelector.height + Config.FINGER_SIZE * .6;
			
			line.width = _width;
			line.y = position;
			position += Config.FINGER_SIZE * .6;
			
			titleSort.x = contentPadding + int(getWidth() * .5 - titleSort.width * .5);
			titleSort.y = position;
			position += titleSort.height + Config.FINGER_SIZE * .3;
			
			radio.x = contentPadding;
			radio.y = position;
			position += radio.height + Config.FINGER_SIZE * .3;
			
			line2.width = _width;
			line2.y = position;
			position += Config.FINGER_SIZE * .3;
			
			titleBlacklist.x = contentPadding + int(getWidth() * .5 - titleBlacklist.width * .5);
			titleBlacklist.y = position;
			position += titleBlacklist.height + Config.FINGER_SIZE * .5;
			
			hideBlocked.x = contentPadding;
			hideBlocked.y = position;
			position += hideBlocked.height + Config.FINGER_SIZE * .1;
			
			hideNoobs.x = contentPadding;
			hideNoobs.y = position;
			position += hideNoobs.height + Config.FINGER_SIZE * .3;
			
			countryExclude.x = contentPadding;
			countryExclude.y = position;
			position += countryExclude.height + Config.FINGER_SIZE * .5;
			
			nextButton.x = contentPadding;
			nextButton.y = getContentHeight() - nextButton.height - contentPadding;
			
			if (nextButton.y + nextButton.height + contentPadding + scrollPanel.view.y < backgroundContent.height && backgroundContent.height > 0)
			{
				nextButton.y = backgroundContent.height - nextButton.height - contentPadding - scrollPanel.view.y;
			}
		}
		
		private function drawControls():void
		{
			tradingSideSelector.maxWidth = getWidth();
			
			radio.draw(radioSelection, getWidth() - contentPadding * 2, RadioItem);
			if (radio.getSelection() == null)
			{
				radio.select(radioSelection[1]);
			}
			
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			if (nextButton != null)
			{
				textSettings = new TextFieldSettings(Lang.textAccept.toUpperCase(), Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				nextButton.setBitmapData(buttonBitmap, true);
			}
			
			hideBlocked.draw(getWidth());
			hideNoobs.draw(getWidth());
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
			hideBlocked.activate();
			hideNoobs.activate();
			countryExclude.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			radio.deactivate();
			nextButton.deactivate();
			tradingSideSelector.deactivate();
			hideBlocked.deactivate();
			hideNoobs.deactivate();
			countryExclude.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1)
				{
					(data.callback as Function)(filter);
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
			if (countryExclude != null)
			{
				countryExclude.dispose();
				countryExclude = null;
			}
			
			radioSelection = null;
		}
	}
}