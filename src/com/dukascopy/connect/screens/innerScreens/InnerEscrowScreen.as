package com.dukascopy.connect.screens.innerScreens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LabelItem;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.escrow.filter.EscrowFilterType;
	import com.dukascopy.connect.data.screenAction.customActions.OpenDealAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenOfferAction;
	import com.dukascopy.connect.gui.components.StatusClip;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowAdsRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowDealRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowOfferRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsFilterVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;
	import com.dukascopy.connect.screens.EscrowAdsCreateScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.SwipeUpdateScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.escrow.FiltersPanel;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.EscrowDealVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.utils.maps.EscrowDealMap;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class InnerEscrowScreen extends SwipeUpdateScreen {
		
		private const TAB_OTHER:String = "crypto";
		private const TAB_MINE:String = "mine";
		private const TAB_OFFERS:String = "offers";
		private const TAB_DEALS:String = "deals";
		
		private static var selectedTabID:String;
		
		private var list:List;
		private var tabs:FilterTabs;
		
		private var needToRefreshAfterScrollStoped:Boolean = false;
		
		static private var storedTabListPosition:Object = {};
		static private var storedTabListPositionCreated:Boolean;
		
		private var tweenObj:Object = {};
		private var statusClip:StatusClip;
		private var placeholderTitle:Bitmap;
		private var placeholderSubtitle:Bitmap;
		private var placeholderContainer:Sprite;
		private var preloader:HorizontalPreloader;
		private var instrument:String;
		private var filtersPanel:FiltersPanel;
		private var currentFilter:EscrowAdsFilterVO;
		private var isFirstActivation:Boolean = true;
		private var createButton:HidableButton;
		
		public function InnerEscrowScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			list = new List("EscrowAdsList");
			list.allowSmallListMove(true);
			list.setMask(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			_view.addChild(list.view);
			
			tabs = new FilterTabs();
			createTabs();
			_view.addChild(tabs.view);
			
			filtersPanel = new FiltersPanel(onFilterRemove);
			_view.addChild(filtersPanel);
			
			if (storedTabListPositionCreated == false) {
				storedTabListPositionCreated = true;
				storedTabListPosition[TAB_OTHER] = {};
				storedTabListPosition[TAB_OFFERS] = {};
				storedTabListPosition[TAB_MINE] = {};
				storedTabListPosition[TAB_DEALS] = {};
			}
			
			createButton = new HidableButton();
			createButton.tapCallback = onBottomButtonTap;
			_view.addChild(createButton);
			createButton.setDesign(new CreateButtonIcon());
			createButton.visible = true;
			
			preloader = new HorizontalPreloader(Style.color(Style.COLOR_ICON_LIGHT));
			_view.addChild(preloader);
		}
		
		override protected function update():void
		{
			onTabItemSelected(selectedTabID);
		}
		
		private function onFilterRemove(filter:SelectorItemData):void 
		{
			if (filter != null)
			{
				if (currentFilter != null)
				{
					switch(filter.data)
					{
						case EscrowFilterType.COUNTRIES:
						{
							currentFilter.countries = null;
							break;
						}
						case EscrowFilterType.DIRECTION:
						{
							currentFilter.side = null;
							break;
						}
						case EscrowFilterType.HIDE_BLOCKED:
						{
							currentFilter.hideBlocked = true;
							break;
						}
						case EscrowFilterType.HIDE_NOOBS:
						{
							currentFilter.hideNoobs = false;
							break;
						}
						case EscrowFilterType.SORT:
						{
							currentFilter.sort = EscrowAdsFilterVO.SORT_DATE;
							break;
						}
					}
					GD.S_ESCROW_ADS_FILTER_SETTED.invoke();
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function createTabs():void{
			tabs.add(Lang.ads, TAB_OTHER, false, "l");
			tabs.add(Lang.textMine, TAB_MINE);
			tabs.add(Lang.escrow_offers, TAB_OFFERS);
			tabs.add(Lang.escrow_deals, TAB_DEALS, false, "r");
		}
		
		override public function clearView():void {
			super.clearView();
			
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (list != null) {
				if (list.getBoxY() < 0) {
					storedTabListPosition[selectedTabID].listBoxY = list.getBoxY();
					var fli:ListItem = list.getFirstVisibleItem();
					if (fli != null) {
						storedTabListPosition[selectedTabID].item = list.getFirstVisibleItem().data;
						storedTabListPosition[selectedTabID].offset = fli.y + storedTabListPosition[selectedTabID].listBoxY;
					}
					list.dispose();
				} else if ("item" in storedTabListPosition[selectedTabID] == true) {
					delete storedTabListPosition[selectedTabID].item;
					delete storedTabListPosition[selectedTabID].offset;
					delete storedTabListPosition[selectedTabID].listBoxY;
				}
			}
			
			list = null;
			
			if (statusClip != null)
				statusClip.destroy();
			statusClip = null;
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			view.graphics.clear();
			view.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			view.graphics.drawRect(0, 0, _width, _height);
			view.graphics.endFill();
			
			updatePositions();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = true;
			
			if (data != null && "additionalData" in data && data.additionalData != null && data.additionalData is String) {
				instrument = data.additionalData as String;
			} else {
				ApplicationErrors.add();
			}
			
			preloader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			GD.S_ESCROW_ADS_FILTER_SETTED.add(onFilterChanged);
			onFilterChanged();
			
			createButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE - Config.MARGIN * 2);
			createButton.setOffset(Config.TOP_BAR_HEIGHT * 2 + Config.APPLE_TOP_OFFSET);
			
			GD.S_SCREEN_READY.add(onScreenReady);
			WS.S_CONNECTED.add(update);
			
			/*TweenMax.delayedCall(5, invokeInstr);
		}
		
		private function invokeInstr():void {
			TweenMax.delayedCall(5, invokeInstr);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();*/
		}
		
		private function onScreenReady(screenName:String):void {
			if (screenName == "RootScreen")
				isFirstActivation = true;
		}
		
		private function onFilterChanged():void 
		{
			GD.S_ESCROW_ADS_FILTER_REQUEST.invoke(onFilter);
			TweenMax.killDelayedCallsTo(updateAdsList);
			TweenMax.delayedCall(1, updateAdsList, null, true);
		}
		
		private function updateAdsList():void 
		{
			if (isDisposed)
			{
				return;
			}
			TweenMax.killDelayedCallsTo(updateAdsList);
			if (selectedTabID == TAB_OTHER)
			{
				onTabItemSelected(selectedTabID);
			}
		}
		
		private function onFilter(filter:EscrowAdsFilterVO):void 
		{
			if (isDisposed)
			{
				ApplicationErrors.add();
				return;
			}
			currentFilter = filter;
			
			var filtersPanelData:Vector.<SelectorItemData> = new Vector.<SelectorItemData>();
			if (currentFilter != null)
			{
				if (!currentFilter.hideBlocked)
				{
					filtersPanelData.push(new SelectorItemData(Lang.escrow_show_from_blocked, EscrowFilterType.HIDE_BLOCKED));
				}
				if (currentFilter.hideNoobs)
				{
					filtersPanelData.push(new SelectorItemData(Lang.escrow_hide_noobs, EscrowFilterType.HIDE_NOOBS));
				}
				if (currentFilter.countries != null && currentFilter.countries.length > 0)
				{
					filtersPanelData.push(new SelectorItemData(Lang.escrow_countries_excluded, EscrowFilterType.COUNTRIES));
				}
				if (currentFilter.side != null)
				{
					if (currentFilter.side == "sell")
					{
						filtersPanelData.push(new SelectorItemData(Lang.sell_ads, EscrowFilterType.DIRECTION));
					}
					else if (currentFilter.side == "buy")
					{
						filtersPanelData.push(new SelectorItemData(Lang.buy_ads, EscrowFilterType.DIRECTION));
					}
				}
				if (currentFilter.sort != null)
				{
					if (currentFilter.sort == EscrowAdsFilterVO.SORT_BUY_SELL)
					{
						filtersPanelData.push(new SelectorItemData(Lang.buy_sell_ads, EscrowFilterType.SORT));
					}
				}
			}
			
			if (filtersPanelData != null && filtersPanelData.length > 0)
			{
				filtersPanel.visible = true;
				filtersPanel.draw(filtersPanelData, _width - Config.MARGIN * 4);
			}
			else
			{
				filtersPanel.visible = false;
			}
			
			if (filtersPanel.visible)
			{
				tabs.setSelection(TAB_OTHER, true);
			//	onTabItemSelected(TAB_OTHER);
			}
			updatePositions();
		}
		
		private function updatePositions():void 
		{
			var destY:int;
			
			if (filtersPanel.visible)
			{
				var filtersHeight:int = filtersPanel.getHeight();
				if (filtersHeight > 0)
				{
					destY += Config.FINGER_SIZE * .1;
					filtersPanel.y = destY;
					filtersPanel.x = Config.MARGIN * 2;
					destY += filtersHeight;
					destY += Config.FINGER_SIZE * .1;
				}
				
			}
			
			if (tabs != null) {
				tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
				tabs.view.y = destY;
				destY += tabs.height;
			}
			
			if (preloader)
			{
				preloader.y = destY;
			}
			
			if (list != null) {
				list.view.y = destY;
				list.setWidthAndHeight(_width, _height - list.view.y);
			}
		}
		
		public function onHide():void {
			//TweenMax.killDelayedCallsTo(QuestionsManager.askFirstQuestion);
		}
		
		private function onBottomButtonTap():void 
		{
			MobileGui.changeMainScreen(EscrowAdsCreateScreen, {
					backScreen:RootScreen,
					title:Lang.escrow_create_your_ad, 
					backScreenData:null,
					data:null
				}, ScreenManager.DIRECTION_RIGHT_LEFT
			);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			
			if (list != null && list.isDisposed == false) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				list.S_ITEM_HOLD.add(onItemHold);
				list.S_MOVING.add(onListMove);
				list.S_UP.add(onListTouchUp);
			}
			
			if (tabs != null && tabs.isDisposed == false) {
				tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			
			if (isFirstActivation == true) {
				isFirstActivation = false;
				if (selectedTabID == null)
					tabs.setSelection(TAB_OTHER, true);
				else
					tabs.setSelection(selectedTabID, true);
			}
			if (filtersPanel != null)
			{
				filtersPanel.activate();
			}
			if (createButton != null)
				createButton.activate();
		}
		
		private function showPreloader():void 
		{
			TweenMax.killDelayedCallsTo(startPreloader);
			TweenMax.delayedCall(0.2, startPreloader);
		}
		
		private function startPreloader():void 
		{
			TweenMax.killDelayedCallsTo(startPreloader);
			if (preloader != null)
			{
				preloader.start();
			}
		}
		
		private function hidePreloader():void 
		{
			hideHistoryLoader();
			TweenMax.killDelayedCallsTo(startPreloader);
			preloader.stop();
		}
		
		private function onUserBanChange(userUID:String = null):void {
			refreshList();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			hideHistoryLoader();
			if (list != null && list.isDisposed == false) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
				list.S_ITEM_HOLD.remove(onItemHold);
				list.S_MOVING.remove(onListMove);
				list.S_UP.remove(onListTouchUp);
			}
			
			if (tabs != null && tabs.isDisposed == false) {
				tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			if (filtersPanel != null)
			{
				filtersPanel.deactivate();
			}
			if (createButton != null){				
				createButton.deactivate();
			}
		}
		
		private function showLoading():void {
			if (statusClip == null) {
				statusClip = new StatusClip();
				view.addChild(statusClip);
				statusClip.setSize(_width, Config.FINGER_SIZE * .6);
				statusClip.y = _height;
			}
			statusClip.show(Lang.updatingQuestions);
		}
		
		override public function drawViewLang():void {
			if (tabs != null)
			{
				tabs.updateLabels( [ Lang.ads, Lang.textMine, Lang.escrow_offers, Lang.escrow_deals ] );
			}
			
			super.drawViewLang();
		}
		
		override public function dispose():void {
			super.dispose();
			
			TweenMax.killDelayedCallsTo(updateAdsList);
			GD.S_ESCROW_ADS.remove(onEscrowAdsLoaded);
			GD.S_ESCROW_ADS_MINE.remove(onEscrowAdsMineLoaded);
			GD.S_ESCROW_ADS_FILTER_SETTED.remove(onFilterChanged);
			GD.S_ESCROW_OFFERS_READY.remove(onOffersLoaded);
			GD.S_ESCROW_DEALS_LOADED.remove(onDealsLoaded);
			GD.S_SCREEN_READY.remove(onScreenReady);
			GD.S_ESCROW_OFFERS_UPDATE.remove(onOffersLoaded);
			GD.S_ESCROW_DEALS_UPDATE.remove(onDealsLoaded);
			WS.S_CONNECTED.remove(update);
			
			if (preloader != null) {
				TweenMax.killDelayedCallsTo(startPreloader);
				preloader.dispose();
				preloader = null;
			}
			removePlaceholder();
			DialogManager.closeDialog();
			
			if (createButton)
				createButton.dispose();
			createButton = null;
		}
		
		private function hideStatusClip():void {
			if (statusClip)
				statusClip.hide();
		}
		
		private function refreshList():void {
			if (_isDisposed == true)
				return;
			if (list != null)
				list.refresh();
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (_isDisposed == true)
				return;
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			if (item != null)
				itemHitZone = item.getLastHitZone();
			var chatScreenData:ChatScreenData;
			if (data is ChatVO) {
				if (itemHitZone && itemHitZone == HitZoneType.DELETE) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmLeaveConversation, function(val:int):void {
						if (val != 1)
							return;
						ChatManager.removeUser((data as ChatVO).uid);
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
				chatScreenData = new ChatScreenData();
				chatScreenData.chatVO = data as ChatVO;
				chatScreenData.type = ChatInitType.CHAT;
				chatScreenData.backScreen = RootScreen;
				MobileGui.showChatScreen(chatScreenData);
				return;
			}
			else if (data is LabelItem) {
				if (itemHitZone && itemHitZone == HitZoneType.SIMPLE_ACTION && (data as LabelItem).action != null) {
					(data as LabelItem).action.execute();
				}
				return;
			}
			
			if (data is EscrowAdsVO) {
				
				var escrowAdsVO:EscrowAdsVO = data as EscrowAdsVO;
				
				if (escrowAdsVO.userUid != Auth.uid) {
					GD.S_ESCROW_ADS_ANSWER.invoke(escrowAdsVO);
					return;
				}
				
				if (escrowAdsVO.isRemoving == true)
					return;
				if (itemHitZone == HitZoneType.DELETE) {
					DialogManager.alert(Lang.confirm, Lang.alertConfirmDeleteQuestion, function(val:int):void {
						if (val != 1)
							return;
						GD.S_ESCROW_ADS_REMOVE.invoke(escrowAdsVO.uid);
						list.updateItemByIndex(n, false);
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
				//if (escrowAdsVO.answersCount > 0) {
					GD.S_ESCROW_ADS_ANSWERS.invoke(escrowAdsVO.uid);
				//	return;
				//}
				return;
			}
			if (data is EscrowOfferVO) {
				
				var openOfferAction:OpenOfferAction = new OpenOfferAction((data as EscrowOfferVO).data, (data as EscrowOfferVO).created.time, (data as EscrowOfferVO).msg_id);
				openOfferAction.execute();
				return;
			}
			if (data is EscrowDealVO) {
				
				var openDealAction:OpenDealAction = new OpenDealAction(data as EscrowDealVO);
				openDealAction.execute();
			}
		}
		
		private function onItemHold(data:Object, n:int):void {
			if (_isDisposed == true)
				return;
			if (data is ChatVO == false)
				return;
			var menuItems:Array = [];
			var chatVO:ChatVO = data as ChatVO;
			
			menuItems.push( { fullLink:Lang.deleteChat, id:0 } );
			
			if (menuItems.length == 0)
				return;
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
				if (data.id == 0) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmLeaveConversation, function(val:int):void {
						if (val != 1)
							return;
						ChatManager.removeUser(chatVO.uid);
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
			}, data:menuItems, itemClass:ListLink, title:chatVO.title, multilineTitle:false } );
		}
		
		private function saveListPosition():void {
			var listBoxY:int = list.getBoxY();
			if (listBoxY < 0) {
				storedTabListPosition[selectedTabID].listBoxY = list.getBoxY();
				var fli:ListItem = list.getFirstVisibleItem();
				if (fli != null) {
					storedTabListPosition[selectedTabID].item = list.getFirstVisibleItem().data;
					storedTabListPosition[selectedTabID].offset = fli.y + storedTabListPosition[selectedTabID].listBoxY;
				}
			} else if ("item" in storedTabListPosition[selectedTabID] == true) {
				delete storedTabListPosition[selectedTabID].item;
				delete storedTabListPosition[selectedTabID].offset;
				delete storedTabListPosition[selectedTabID].listBoxY;
			}
		}
		
		private function onTabItemSelected(id:String):void {
			if (_isDisposed == true)
				return;
			hideHistoryLoader();
			
			if (selectedTabID != id)
			{
				setListData(null);
			}
			
			selectedTabID = id;
			updatePositions();
			saveListPosition();
			showPreloader();
			
			GD.S_ESCROW_ADS.remove(onEscrowAdsLoaded);
			GD.S_ESCROW_ADS_MINE.remove(onEscrowAdsMineLoaded);
			GD.S_ESCROW_OFFERS_READY.remove(onOffersLoaded);
			GD.S_ESCROW_DEALS_LOADED.remove(onDealsLoaded);
			GD.S_ESCROW_DEALS_UPDATE.remove(onDealsLoaded);
			GD.S_ESCROW_OFFERS_UPDATE.remove(onOffersLoaded);
			
			if (id == TAB_OTHER) {
				GD.S_ESCROW_ADS.add(onEscrowAdsLoaded);
				GD.S_ESCROW_ADS_REQUEST.invoke(false, true);
				return;
			}
			if (id == TAB_MINE) {
				GD.S_ESCROW_ADS_MINE.add(onEscrowAdsMineLoaded);
				GD.S_ESCROW_ADS_MINE_REQUEST.invoke();
				return;
			}
			if (id == TAB_OFFERS) {
				GD.S_ESCROW_OFFERS_READY.add(onOffersLoaded);
				GD.S_ESCROW_OFFERS_UPDATE.add(onOffersLoaded);
				GD.S_ESCROW_OFFERS_REQUEST.invoke();
				return;
			}
			if (id == TAB_DEALS) {
				GD.S_ESCROW_DEALS_LOADED.add(onDealsLoaded);
				GD.S_ESCROW_DEALS_UPDATE.add(onDealsLoaded);
				GD.S_ESCROW_DEALS_REQUEST.invoke();
				return;
			}
		}
		
		private function onDealsLoaded(deals:EscrowDealMap):void 
		{
			if (_isDisposed)
				return;
			if (selectedTabID != TAB_DEALS)
				return;
		//	if (preloaderHide == true)
			hidePreloader();
			
			var dealsValues:Array;
			if (deals != null)
			{
				dealsValues = deals.getValues();
				setListData(dealsValues);
			}
			
			if ((dealsValues == null || dealsValues.length == 0))
				addPlaceholder(Lang.escrow_no_deals_placeholder_title, Lang.escrow_no_deals_placeholder_subtitle);
			else
				removePlaceholder();
		}
		
		private function onOffersLoaded(offers:Vector.<EscrowOfferVO>):void 
		{
			if (_isDisposed)
				return;
			if (selectedTabID != TAB_OFFERS)
				return;
		//	if (preloaderHide == true)
			hidePreloader();
			setListData(offers);
			
			if ((offers == null || offers.length == 0))
				addPlaceholder(Lang.escrow_no_offers_placeholder_title, Lang.escrow_no_offers_placeholder_subtitle);
			else
				removePlaceholder();
		}
		
		private function onEscrowAdsLoaded(data:Array, preloaderHide:Boolean = false):void {
			
			if (_isDisposed)
				return;
			if (selectedTabID != TAB_OTHER)
				return;
			if (preloaderHide == true)
				hidePreloader();
			setListData(data);
			
			if ((data == null || data.length == 0))
				addPlaceholder(Lang.escrow_no_active_ads_placeholder_title, Lang.escrow_no_active_ads_placeholder_subtitle);
			else
				removePlaceholder();
		}
		
		private function onEscrowAdsMineLoaded(data:Array, preloaderHide:Boolean = false):void {
			if (_isDisposed)
				return;
			if (selectedTabID != TAB_MINE)
				return;
			if (preloaderHide == true)
				hidePreloader();
			setListData(data);
		}
		
		private function setListData(data:Object):void {
			if (_isDisposed == true)
				return;
			if (list == null)
				return;
			var listItemClass:Class = BaseRenderer;
			if (selectedTabID == TAB_OTHER)
				listItemClass = ListEscrowAdsRenderer;
			else if (selectedTabID == TAB_MINE)
				listItemClass = ListEscrowAdsRenderer;
			else if (selectedTabID == TAB_OFFERS)
				listItemClass = ListEscrowOfferRenderer;
			else if (selectedTabID == TAB_DEALS)
				listItemClass = ListEscrowDealRenderer;
			var listData:Object = data;
			if (listData == null)
				listData = [];
			list.setData(listData, listItemClass);
			
			if (storedTabListPosition[selectedTabID] != null && "item" in storedTabListPosition[selectedTabID] == true && storedTabListPosition[selectedTabID].item != null)
				if (list.scrollToItem(null, storedTabListPosition[selectedTabID].item, storedTabListPosition[selectedTabID].offset) == false)
					if ("listBoxY" in storedTabListPosition[selectedTabID] == true)
						list.setBoxY(storedTabListPosition[selectedTabID].listBoxY);
			list.setContextAvaliable(true);
			if (selectedTabID == TAB_MINE && (listData == null || listData.length == 0)) {
				addPlaceholder(Lang.escrow_no_active_ads_placeholder_title, Lang.escrow_no_active_ads_placeholder_subtitle);
			} else {
				removePlaceholder();
			}
		}
		
		private function removePlaceholder():void {
			if (placeholderTitle != null) {
				UI.destroy(placeholderTitle);
				placeholderTitle = null;
			}
			if (placeholderSubtitle != null) {
				UI.destroy(placeholderSubtitle);
				placeholderSubtitle = null;
			}
			if (placeholderContainer != null)
			{
				UI.destroy(placeholderContainer);
				placeholderContainer = null;
			}
		}
		
		private function addPlaceholder(title:String, subtitle:String):void {
			if (placeholderContainer == null) {
				placeholderContainer = new Sprite();
				view.addChild(placeholderContainer);
				
				placeholderTitle = new Bitmap();
				placeholderContainer.addChild(placeholderTitle);
				
				placeholderSubtitle = new Bitmap();
				placeholderContainer.addChild(placeholderSubtitle);
			}
			if (placeholderTitle.bitmapData != null) {
				placeholderTitle.bitmapData.dispose();
				placeholderTitle.bitmapData = null;
			}
			
			if (title != null)
			{
				placeholderTitle.bitmapData = TextUtils.createTextFieldData(
					title,
					_width - Config.FINGER_SIZE,
					10,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.CENTER,
					FontSize.BODY,
					true,
					Style.color(Style.COLOR_TEXT),
					Style.color(Style.COLOR_BACKGROUND),
					false
				);
			}
			
			if (placeholderSubtitle.bitmapData != null) {
				placeholderSubtitle.bitmapData.dispose();
				placeholderSubtitle.bitmapData = null;
			}
			
			if (subtitle != null)
			{
				placeholderSubtitle.bitmapData = TextUtils.createTextFieldData(
					subtitle,
					_width - Config.FINGER_SIZE,
					10,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.CENTER,
					FontSize.SUBHEAD,
					true,
					Style.color(Style.COLOR_SUBTITLE),
					Style.color(Style.COLOR_BACKGROUND),
					false
				);
			}
			
			
			placeholderTitle.x = int(Math.max(placeholderTitle.width, placeholderSubtitle.width) * .5 - placeholderTitle.width * .5);
			placeholderSubtitle.x = int(Math.max(placeholderTitle.width, placeholderSubtitle.width) * .5 - placeholderSubtitle.width * .5);
			
			placeholderSubtitle.y = int(placeholderTitle.height + Config.FINGER_SIZE * .2);
			
			placeholderContainer.y = list.view.y + Config.FINGER_SIZE;
			placeholderContainer.x = int(_width * .5 - placeholderContainer.width * .5);
		}
	}
}