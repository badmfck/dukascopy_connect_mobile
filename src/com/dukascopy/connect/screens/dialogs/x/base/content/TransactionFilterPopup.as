package com.dukascopy.connect.screens.dialogs.x.base.content 
{
	import assets.Filter_affiliate;
	import assets.Filter_cancelled;
	import assets.Filter_card;
	import assets.Filter_coin;
	import assets.Filter_completed;
	import assets.Filter_deposit;
	import assets.Filter_exchange;
	import assets.Filter_fees;
	import assets.Filter_incoming;
	import assets.Filter_investment;
	import assets.Filter_outgoing;
	import assets.Filter_pending;
	import assets.Filter_term_deposit;
	import assets.Filter_withdraw;
	import assets.SelectIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.filter.FilterCategory;
	import com.dukascopy.connect.data.filter.FilterData;
	import com.dukascopy.connect.gui.components.DateSelector;
	import com.dukascopy.connect.gui.components.HorizontalSelector;
	import com.dukascopy.connect.gui.components.IFilterView;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.BottomPopup;
	import com.dukascopy.connect.screens.dialogs.calendar.DatePicker;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.FinanceFilterCategoryType;
	import com.dukascopy.connect.type.FinanceFilterType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TransactionFilterPopup extends BottomPopup
	{
		private var filters:Vector.<FilterCategory>;
		private var accounts:PaymentsAccountsProvider;
		private var selectedCategory:FinanceFilterCategoryType;
		private var filterView:IFilterView;
		private var contentPadding:int;
		private var tabs:FilterTabs;
		private var cancelButton:BitmapButton;
		private var resetButton:BitmapButton;
		private var selectButton:BitmapButton;
		private var needCallback:Boolean;
		
		public function TransactionFilterPopup() 
		{
			
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			contentPadding = Config.FINGER_SIZE * .25;
			
			initDataset();
			getAccounts();
			
			drawSelectButton();
			var buttonWidth:int = (_width - Config.DIALOG_MARGIN * 2 - selectButton.width - contentPadding * 2) * .5;
			drawResetButton(buttonWidth);
			drawCancelButton(buttonWidth);
			
			selectedCategory = new FinanceFilterCategoryType(FinanceFilterCategoryType.TYPE);
			drawFilterSelector();
			onFiltersChanged();
			selectFilterCategory(selectedCategory);
			
			var position:int = Config.FINGER_SIZE * .33;
			if (filterView != null)
			{
				position += filterView.getHeight() + Config.FINGER_SIZE * .3;
			}
			tabs.view.y = position;
			position += tabs.height + Config.FINGER_SIZE * .4;
			
			resetButton.y = position;
			cancelButton.y = position;
			selectButton.y = int(cancelButton.y + cancelButton.height * .5 - selectButton.height * .5);
		}
		
		override protected function createView():void {
			super.createView();
			
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.setDownColor(NaN);
			cancelButton.setDownScale(1);
			cancelButton.setOverlay(HitZoneType.BUTTON);
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.tapCallback = onButtonCancelClick;
			container.addChild(cancelButton);
			
			resetButton = new BitmapButton();
			resetButton.setStandartButtonParams();
			resetButton.setDownColor(NaN);
			resetButton.setDownScale(1);
			resetButton.setOverlay(HitZoneType.BUTTON);
			resetButton.cancelOnVerticalMovement = true;
			resetButton.tapCallback = onButtonResetClick;
			container.addChild(resetButton);
			
			selectButton = new BitmapButton();
			selectButton.setStandartButtonParams();
			selectButton.setDownColor(NaN);
			selectButton.setDownScale(1);
			selectButton.setOverlay(HitZoneType.CIRCLE);
			selectButton.cancelOnVerticalMovement = true;
			selectButton.tapCallback = onButtonSelectClick;
			container.addChild(selectButton);
		}
		
		private function onButtonSelectClick():void 
		{
			needCallback = true;
			close();
		}
		
		private function onButtonResetClick():void 
		{
			clearFilters();
		}
		
		private function clearFilters():void 
		{
			if (filters != null)
			{
				for (var i:int = 0; i < filters.length; i++) 
				{
					if (filters[i].filters != null)
					{
						for (var j:int = 0; j < filters[i].filters.length; j++) 
						{
							filters[i].filters[j].selected = false;
						}
					}
				}
			}
			selectFilterCategory(selectedCategory);
			onFiltersChanged();
		}
		
		private function onButtonCancelClick():void 
		{
			close();
		}
		
		private function getAccounts():void 
		{
			accounts = new PaymentsAccountsProvider(onAccountsDataReady, true);
			if (accounts.ready == false)
			{
				accounts.getData();
			}
			else
			{
				onAccountsDataReady();
			}
		}
		
		private function onAccountsDataReady():void 
		{
		//	MobileGui.changeMainScreen(PaymentsCreateCardScreen);
		//	return;
			
			if (filters != null)
			{
				var categoryAccount:FilterCategory = getCategory(new FinanceFilterCategoryType(FinanceFilterCategoryType.ACCOUNT));
				if (categoryAccount != null)
				{
					var accountsArray:Array = new Array();
					if (accounts.moneyAccounts != null && accounts.moneyAccounts.length > 0)
					{
						accountsArray = accountsArray.concat(accounts.moneyAccounts);
					}
					if (accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
					{
						accountsArray = accountsArray.concat(accounts.coinsAccounts);
					}
					var filter:FilterData;
					var accountName:String;
					var accountNumber:String;
					for (var i:int = 0; i < accountsArray.length; i++) 
					{
						accountName = "";
						accountNumber = null;
						if ("CURRENCY" in accountsArray[i] && accountsArray[i].CURRENCY != null)
						{
							accountName = accountsArray[i].CURRENCY;
						}
						else if ("COIN" in accountsArray[i] && accountsArray[i].COIN != null)
						{
							accountName = accountsArray[i].COIN;
						}
						if ("ACCOUNT_NUMBER" in accountsArray[i] && accountsArray[i].ACCOUNT_NUMBER != null)
						{
							accountNumber = accountsArray[i].ACCOUNT_NUMBER;
						}
						if (Lang[accountName] != null)
						{
							accountName = Lang[accountName];
						}
						if (accountNumber != null)
						{
							filter = new FilterData(accountName, new FinanceFilterType(accountNumber));
							categoryAccount.add(filter);
						}
						else
						{
							ApplicationErrors.add("no account number");
						}
					}
				}
				else
				{
					ApplicationErrors.add("no category");
				}
				
				if (tabs != null && selectedCategory.type == FinanceFilterCategoryType.ACCOUNT)
				{
					selectFilterCategory(selectedCategory, true);
				}
				
				checkCurrentSelection();
				if (tabs != null)
				{
					onFiltersChanged();
				}
			}
		}
		
		private function getCategory(categoryType:FinanceFilterCategoryType):FilterCategory {
			if (filters != null) {
				for (var i:int = 0; i < filters.length; i++) {
					if (filters[i].type.type == categoryType.type) {
						return filters[i];
					}
				}
			}
			return null;
		}
		
		private function selectFilterCategory(value:FinanceFilterCategoryType, animate:Boolean = false):void {
			if (filters != null) {
				if (selectedCategory == value) {
					if (filterView != null) {
						if (filterView.redraw()) {
							return;
						}
					}
				}
				selectedCategory = value;
				if (filterView != null) {
					TweenMax.to(filterView, 0.1, {alpha:0, onComplete:filterViewHided, onCompleteParams:[animate]});
				} else {
					showCurrentFilter(animate);
				}
			} else {
				ApplicationErrors.add();
			}
		}
		
		private function filterViewHided(animate:Boolean = false):void {
			if (filterView != null) {
				filterView.dispose();
				if (container.contains(filterView as Sprite)) {
					container.removeChild(filterView as Sprite);
					filterView = null;
				}
				showCurrentFilter(animate);
			}
		}
		
		private function showCurrentFilter(animate:Boolean = false):void {
			if (selectedCategory != null) {
				filterView = createFilterView(selectedCategory);
				if (filterView != null) {
					TweenMax.killTweensOf(filterView);
					filterView.alpha = 0;
					container.addChild(filterView as Sprite);
					filterView.x = contentPadding;
					filterView.y = int(Config.FINGER_SIZE * .33);
					if (_isActivated == true) {
						filterView.activate();
					}
					TweenMax.to(filterView, 0.2, {alpha:1, delay:0.2});
					if (animate == true) {
						updateContentPosition();
					}
				} else {
					ApplicationErrors.add();
				}
			}
		}
		
		private function updateContentPosition():void {
			var position:int = Config.FINGER_SIZE * .33;
			if (filterView != null) {
				position += filterView.getHeight() + Config.FINGER_SIZE * .3;
			}
			tabs.view.y = position;
			position += tabs.height + Config.FINGER_SIZE * .4;
			
			resetButton.y = position;
			cancelButton.y = position;
			selectButton.y = int(cancelButton.y + cancelButton.height * .5 - selectButton.height * .5);
			
			container.y = _height - getHeight();
			animateBack();
			animationFinished();
		}
		
		override protected function animationFinished():void {
			if (filterView != null) {
				filterView.update();
			}
		}
		
		private function createFilterView(category:FinanceFilterCategoryType):IFilterView {
			var result:IFilterView;
			switch(category.type) {
				case FinanceFilterCategoryType.TYPE:
				case FinanceFilterCategoryType.ACCOUNT:
				case FinanceFilterCategoryType.STATUS: {
					result = new HorizontalSelector(onFiltersChanged);
					break;
				}
				case FinanceFilterCategoryType.DATE: {
					result = new DateSelector(onFiltersChanged);
					break;
				}
			}
			if (result != null) {
				result.setWidth(_width - contentPadding * 2);
				result.setData(getFiltersData(category));
			}
			return result;
		}
		
		private function onFiltersChanged():void {
			if (filters != null) {
				var selected:Boolean;
				for (var i:int = 0; i < filters.length; i++) {
					selected = false;
					if (filters[i].filters != null) {
						for (var j:int = 0; j < filters[i].filters.length; j++) {
							if (filters[i].filters[j].selected) {
								selected = true;
								break;
							}
						}
					}
					tabs.selectNotification(filters[i].type.type, (selected == true));
				}
			}
		}
		
		private function getFiltersData(category:FinanceFilterCategoryType):Vector.<FilterData> {
			if (filters != null && category != null) {
				for (var i:int = 0; i < filters.length; i++) {
					if (filters[i].type != null && filters[i].type.type == category.type) {
						return filters[i].filters;
					}
				}
			}
			return null;
		}
		
		private function initDataset():void {
			var filter:FilterData;
			
			filters = new Vector.<FilterCategory>();
			
			var categoryType:FilterCategory = new FilterCategory(Lang.filter_type, new FinanceFilterCategoryType(FinanceFilterCategoryType.TYPE));
			filter = new FilterData(Lang.filter_moneyWithdraw, new FinanceFilterType(FinanceFilterType.WITHDRAWAL),                    Filter_withdraw);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_exchange,          new FinanceFilterType(FinanceFilterType.INTERNAL_TRANSFER),         Filter_exchange);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_incomingTransfer,  new FinanceFilterType(FinanceFilterType.INCOMING_TRANSFER),         Filter_incoming);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_outgoingTransfer,  new FinanceFilterType(FinanceFilterType.OUTGOING_TRANSFER),         Filter_outgoing);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_deposit,           new FinanceFilterType(FinanceFilterType.DEPOSIT),                   Filter_deposit);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_orderCard,         new FinanceFilterType(FinanceFilterType.ORDER_OF_PREPAID_CARD),     Filter_card);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_investment,        new FinanceFilterType(FinanceFilterType.INVESTMENT),                Filter_investment);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_coinTrade,         new FinanceFilterType(FinanceFilterType.COIN_TRADE),                Filter_coin);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_termDeposit,       new FinanceFilterType(FinanceFilterType.TERM_DEPOSIT),              Filter_term_deposit);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_fees,              new FinanceFilterType(FinanceFilterType.COMMISSION_CHARGE),         Filter_fees);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_transferAffiliate, new FinanceFilterType(FinanceFilterType.PARTNER_ACCOUNT_TRANSFER),  Filter_affiliate);
				categoryType.add(filter);
			filter = new FilterData(Lang.filter_tradeAffiliate,    new FinanceFilterType(FinanceFilterType.PARTNER_CRYPTO_TRADE),      Filter_affiliate);
				categoryType.add(filter);
			
			var categoryStatus:FilterCategory = new FilterCategory(Lang.filter_status, new FinanceFilterCategoryType(FinanceFilterCategoryType.STATUS));
			filter = new FilterData(Lang.filter_completed, new FinanceFilterType(FinanceFilterType.COMPLETED), Filter_completed);
				categoryStatus.add(filter);
			filter = new FilterData(Lang.filter_pending, new FinanceFilterType(FinanceFilterType.PENDING), Filter_cancelled);
				categoryStatus.add(filter);
			filter = new FilterData(Lang.filter_cancelled, new FinanceFilterType(FinanceFilterType.CANCELLED), Filter_pending);
				categoryStatus.add(filter);
			
			var categoryAccount:FilterCategory = new FilterCategory(Lang.filter_account, new FinanceFilterCategoryType(FinanceFilterCategoryType.ACCOUNT));
			categoryAccount.ready = false;
				
			var categoryDate:FilterCategory = new FilterCategory(Lang.filter_date, new FinanceFilterCategoryType(FinanceFilterCategoryType.DATE));
			filter = new FilterData(null, new FinanceFilterType(null));
				categoryDate.add(filter);
			filter = new FilterData(null, new FinanceFilterType(null));
				categoryDate.add(filter);
			
			filters.push(categoryType);
			filters.push(categoryStatus);
			filters.push(categoryAccount);
			filters.push(categoryDate);
			
			checkCurrentSelection();
		}
		
		private function checkCurrentSelection():void {
			if (data != null && "filters" in data && data.filters != null && data.filters is Vector.<FilterCategory>) {
				applyFilters(data.filters as Vector.<FilterCategory>);
			}
		}
		
		private function applyFilters(selection:Vector.<FilterCategory>):void {
			if (filters != null && selection != null) {
				var category:FilterCategory;
				for (var i:int = 0; i < selection.length; i++) {
					category = getCategory(selection[i].type);
					if (category != null && category.filters != null && selection[i].filters != null) {
						for (var j:int = 0; j < selection[i].filters.length; j++) {
							for (var k:int = 0; k < category.filters.length; k++) {
								if (selection[i].filters[j].type.type == category.filters[k].type.type) {
									category.filters[k].selected = true;
									break;
								} else if (selection[i].type.type == FinanceFilterCategoryType.DATE) {
									if (category.filters.length > 1 && selection[i].filters.length > 1) {
										category.filters[0].selected = true;
										category.filters[1].selected = true;
										category.filters[0].type = new FinanceFilterType(selection[i].filters[0].type.type);
										category.filters[1].type = new FinanceFilterType(selection[i].filters[1].type.type);
									}
								}
							}
						}
					}
				}
			}
		}
		
		private function drawFilterSelector():void {
			tabs = new FilterTabs();
			tabs.tabBackgroundBorderSelectedColor = Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER);
			var left:Boolean;
			var right:Boolean;
			if (filters != null) {
				for (var i:int = 0; i < filters.length; i++) {
					left = i == 0;
					right = i == filters.length - 1;
					tabs.add(filters[i].text, filters[i].type.type, false, left?"l":(right?"r":null));
				}
				container.addChild(tabs.view);
			}
			tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
			if (tabs.S_ITEM_SELECTED != null)
				tabs.S_ITEM_SELECTED.add(onTabItemSelected);
			
			tabs.setSelection(selectedCategory.type);
		}
		
		private function onTabItemSelected(type:String):void {
			if (filters != null) {
				selectFilterCategory(new FinanceFilterCategoryType(type), true);
			}
		}
		
		override protected function getHeight():int {
			return Math.max(resetButton.y + resetButton.height, selectButton.y + selectButton.height) + Config.FINGER_SIZE * .4 + Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function drawResetButton(buttonWidth:int):void {
			var buttonText:String = Lang.testReset;
			if (buttonText != null) {
				buttonText = buttonText.toUpperCase();
			}
			var textSettings:TextFieldSettings = new TextFieldSettings(buttonText, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_SSL), buttonWidth, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			resetButton.setBitmapData(buttonBitmap, true);
			resetButton.x = contentPadding;
		}
		
		private function drawCancelButton(buttonWidth:int):void {
			var buttonText:String = Lang.textCancel;
			if (buttonText != null) {
				buttonText = buttonText.toUpperCase();
			}
			var textSettings:TextFieldSettings = new TextFieldSettings(buttonText, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_SSL), buttonWidth, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			cancelButton.setBitmapData(buttonBitmap, true);
			cancelButton.x = _width - cancelButton.width - contentPadding;
		}
		
		private function drawSelectButton():void {
			var icon:SelectIcon = new SelectIcon();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE));
			selectButton.setBitmapData(UI.getSnapshot(icon));
			UI.destroy(icon);
			icon = null;
			selectButton.x = int(_width * .5 - selectButton.width * .5);
		}
		
		private function nextClick():void {
			close();
		}
		
		override protected function drawView():void {
			super.drawView();
		}
		
		override public function dispose():void {
			super.dispose();
			selectedCategory = null;
			filters = null;
			if (accounts != null) {
				accounts.dispose();
				accounts = null;
			}
			if (cancelButton != null) {
				cancelButton.dispose();
				cancelButton = null;
			}
			if (resetButton != null) {
				resetButton.dispose();
				resetButton = null;
			}
			if (selectButton != null) {
				selectButton.dispose();
				selectButton = null;
			}
			if (filterView != null) {
				TweenMax.killTweensOf(filterView);
				filterView.dispose();
				filterView = null;
			}
			if (tabs != null) {
				tabs.dispose();
				tabs = null;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			if (filterView != null) {
				filterView.activate();
			}
			if (tabs != null) {
				tabs.activate();
			}
			cancelButton.activate();
			resetButton.activate();
			selectButton.activate();
		}
		
		override protected function onRemove():void {
			if (needCallback == true) {
				needCallback = false;
				if (data != null &&
					"callback" in data &&
					data.callback != null &&
					data.callback is Function &&
					(data.callback as Function).length == 1) {
						data.callback(getSelectedFilters());
				}
			}
		}
		
		private function getSelectedFilters():Vector.<FilterCategory> {
			var category:FilterCategory;
			var result:Vector.<FilterCategory> = new Vector.<FilterCategory>();
			var filterData:FilterData;
			if (filters != null) {
				for (var i:int = 0; i < filters.length; i++) {
					category = null;
					if (filters[i].filters != null) {
						for (var j:int = 0; j < filters[i].filters.length; j++) {
							if (filters[i].filters[j].selected == true) {
								if (category == null) {
									category = new FilterCategory(filters[i].text, new FinanceFilterCategoryType(filters[i].type.type));
								}
								filterData = new FilterData(filters[i].filters[j].text, new FinanceFilterType(filters[i].filters[j].type.type));
								category.add(filterData);
							}
						}
					}
					if (category != null) {
						result.push(category);
					}
				}
			}
			return result;
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			if (filterView != null) {
				filterView.deactivate();
			}
			if (tabs != null) {
				tabs.deactivate();
			}
			cancelButton.deactivate();
			resetButton.deactivate();
			selectButton.deactivate();
		}
	}
}