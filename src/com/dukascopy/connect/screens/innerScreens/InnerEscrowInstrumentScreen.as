package com.dukascopy.connect.screens.innerScreens {
	
	import assets.PlusAvatar;
	import assets.PlusIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.customActions.OpenDealAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenOfferAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowAdsRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowDealRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowInstrumentRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowOfferRenderer;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsCryptoVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;
	import com.dukascopy.connect.screens.EscrowAdsCreateScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.SwipeUpdateScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.EscrowDealVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.utils.maps.EscrowDealMap;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class InnerEscrowInstrumentScreen extends SwipeUpdateScreen {
		
		private const TAB_ID_CRYPTO:String = "crypto";
		private const TAB_ID_MINE:String = "mine";
		private const TAB_ID_OFFERS:String = "offers";
		private const TAB_ID_DEALS:String = "deals";
		
		private static var selectedTabID:String;
		
		private var list:List;
		private var tabs:FilterTabs;
		
		private var needToRefreshAfterScrollStoped:Boolean = false;
		
		static private var storedTabListPosition:Object = {};
		
		private var placeholder:Bitmap;
		private var preloader:HorizontalPreloader;
		
		private var isFirstActivation:Boolean = true;
		private var createButton:HidableButton;
		
		public function InnerEscrowInstrumentScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			list = new List("QuestionsList");
			list.allowSmallListMove(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			_view.addChild(list.view);
			
			tabs = new FilterTabs();
			createTabs();
			_view.addChild(tabs.view);
			
			storedTabListPosition[TAB_ID_CRYPTO] = {};
			storedTabListPosition[TAB_ID_MINE] = {};
			storedTabListPosition[TAB_ID_OFFERS] = {};
			storedTabListPosition[TAB_ID_DEALS] = {};
			
			preloader = new HorizontalPreloader(Style.color(Style.COLOR_ICON_LIGHT));
			_view.addChild(preloader);
			
			createButton = new HidableButton();
			createButton.tapCallback = onBottomButtonTap;
			_view.addChild(createButton);
			createButton.setDesign(new CreateButtonIcon());
		}
		
		private function onBottomButtonTap():void {
			MobileGui.changeMainScreen(EscrowAdsCreateScreen, {
					backScreen:RootScreen,
					title:Lang.escrow_create_your_ad, 
					backScreenData:null,
					data:null
				}, ScreenManager.DIRECTION_RIGHT_LEFT
			);
		}
		
		private function createTabs():void {
			tabs.add(Lang.escrow_text_instruments, TAB_ID_CRYPTO, false, "l");
			tabs.add(Lang.textMine, TAB_ID_MINE, false);
			tabs.add(Lang.escrow_text_offers, TAB_ID_OFFERS, false);
			tabs.add(Lang.escrow_text_deals, TAB_ID_DEALS, false, "r");
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = true;
			
			preloader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			createButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE - Config.MARGIN * 2 - Config.APPLE_TOP_OFFSET);
			createButton.setOffset(Config.TOP_BAR_HEIGHT * 2 + Config.APPLE_TOP_OFFSET);
			
			GD.S_SCREEN_READY.add(onScreenReady);
		}
		
		override protected function update():void {
			onTabItemSelected(selectedTabID);
		}
		
		private function onScreenReady(screenName:String):void {
			if (screenName == "RootScreen")
				isFirstActivation = true;
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
						storedTabListPosition[selectedTabID].item = fli.data;
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
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			var destY:int;
			if (tabs != null) {
				tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
				tabs.view.y = destY;
				destY += tabs.height;
			}
			preloader.y = destY;
			if (list != null) {
				list.view.y = destY;
				list.setWidthAndHeight(_width, _height - list.view.y);
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			if (list != null && list.isDisposed == false) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
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
					tabs.setSelection(TAB_ID_CRYPTO, true);
				else
					tabs.setSelection(selectedTabID, true);
			}
			if (createButton != null)
				createButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			hideHistoryLoader();
			if (list != null && list.isDisposed == false) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
				list.S_MOVING.remove(onListMove);
				list.S_UP.remove(onListTouchUp);
			}
			if (tabs != null && tabs.isDisposed == false) {
				tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			if (createButton != null) {
				createButton.deactivate();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			if (list != null)
				list.dispose();
			list = null;
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			if (preloader != null) {
				TweenMax.killDelayedCallsTo(startPreloader);
				preloader.dispose();
			}
			preloader = null;
			removePlaceholder();
			GD.S_ESCROW_ADS_CRYPTOS.remove(onEscrowAdsCryptoLoaded);
			GD.S_ESCROW_ADS_MINE.remove(onEscrowAdsCryptoLoaded);
			GD.S_ESCROW_OFFERS_READY.remove(onOffersLoaded);
			GD.S_ESCROW_DEALS_LOADED.remove(onDealsLoaded);
			GD.S_ESCROW_DEALS_UPDATE.remove(onDealsLoaded);
			GD.S_SCREEN_READY.remove(onScreenReady);
			DialogManager.closeDialog();
			
			if (createButton)
				createButton.dispose();
			createButton = null;
		}
		
		override public function drawViewLang():void {
			if (tabs != null)
				tabs.updateLabels( [ Lang.escrow_text_instruments, Lang.textMine, Lang.escrow_text_offers, Lang.escrow_text_deals ] );
			super.drawViewLang();
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (_isDisposed == true)
				return;
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			if (item != null)
				itemHitZone = item.getLastHitZone();
			if (data is EscrowAdsCryptoVO) {
				GD.S_ESCROW_ADS_INSTRUMENT_SELECTED.invoke(data);
				return;
			}
			if (data is EscrowAdsVO) {
				var escrowAdsVO:EscrowAdsVO = data as EscrowAdsVO;
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
				if (escrowAdsVO.answersCount > 0) {
					GD.S_ESCROW_ADS_ANSWERS.invoke(escrowAdsVO.uid);
					return;
				}
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
				return;
			}
		}
		
		private function onTabItemSelected(id:String):void {
			if (_isDisposed == true)
				return;
			hideHistoryLoader();
			removePlaceholder();
			selectedTabID = id;
			saveListPosition();
			GD.S_ESCROW_ADS_CRYPTOS.remove(onEscrowAdsCryptoLoaded);
			GD.S_ESCROW_ADS_MINE.remove(onEscrowAdsMineLoaded);
			GD.S_ESCROW_OFFERS_READY.remove(onOffersLoaded);
			GD.S_ESCROW_DEALS_LOADED.remove(onDealsLoaded);
			GD.S_ESCROW_DEALS_UPDATE.remove(onDealsLoaded);
			showPreloader();
			if (id == TAB_ID_CRYPTO) {
				GD.S_ESCROW_ADS_CRYPTOS.add(onEscrowAdsCryptoLoaded);
				GD.S_ESCROW_ADS_CRYPTOS_REQUEST.invoke();
				return;
			}
			if (id == TAB_ID_MINE) {
				GD.S_ESCROW_ADS_MINE.add(onEscrowAdsMineLoaded);
				GD.S_ESCROW_ADS_MINE_REQUEST.invoke();
				return;
			}
			if (id == TAB_ID_OFFERS) {
				GD.S_ESCROW_OFFERS_READY.add(onOffersLoaded);
				GD.S_ESCROW_OFFERS_REQUEST.invoke();
				return;
			}
			if (id == TAB_ID_DEALS) {
				GD.S_ESCROW_DEALS_LOADED.add(onDealsLoaded);
				GD.S_ESCROW_DEALS_UPDATE.add(onDealsLoaded);
				GD.S_ESCROW_DEALS_REQUEST.invoke();
				return;
			}
			setListData(null);
		}
		
		private function onOffersLoaded(offers:Vector.<EscrowOfferVO>):void {
			if (_isDisposed)
				return;
			if (selectedTabID != TAB_ID_OFFERS)
				return;
			hidePreloader();
			setListData(offers);
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
		
		private function onEscrowAdsCryptoLoaded(data:Array, preloaderHide:Boolean = false, error:Boolean = false):void {
			if (_isDisposed)
				return;
			if (selectedTabID != TAB_ID_CRYPTO)
				return;
			if (preloaderHide == true)
				hidePreloader();
			setListData(data);
		}
		
		private function onEscrowAdsMineLoaded(data:Array, preloaderHide:Boolean = false, error:Boolean = false):void {
			if (_isDisposed)
				return;
			if (selectedTabID != TAB_ID_MINE)
				return;
			if (preloaderHide == true)
				hidePreloader();
			setListData(data);
			if ((data == null || data.length == 0) && preloaderHide == true)
				addPlaceholder(Lang.escrow_no_active_ads_placeholder);
			else
				removePlaceholder();
		}
		
		private function onDealsLoaded(deals:EscrowDealMap):void {
			if (_isDisposed)
				return;
			if (selectedTabID != TAB_ID_DEALS)
				return;
			hidePreloader();
			setListData(deals.getValues());
		}
		
		private function setListData(data:Object):void {
			if (_isDisposed == true)
				return;
			if (list == null)
				return;
			var listItemClass:Class = BaseRenderer;
			if (selectedTabID == TAB_ID_CRYPTO)
				listItemClass = ListEscrowInstrumentRenderer;
			else if (selectedTabID == TAB_ID_MINE)
				listItemClass = ListEscrowAdsRenderer;
			else if (selectedTabID == TAB_ID_OFFERS)
				listItemClass = ListEscrowOfferRenderer;
			else if (selectedTabID == TAB_ID_DEALS)
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
		}
		
		private function addPlaceholder(text:String):void {
			if (placeholder == null) {
				placeholder = new Bitmap();
				view.addChild(placeholder);
			}
			if (placeholder.bitmapData != null) {
				placeholder.bitmapData.dispose();
				placeholder.bitmapData = null;
			}
			placeholder.bitmapData = TextUtils.createTextFieldData(
				text,
				_width - Config.FINGER_SIZE,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.CENTER,
				FontSize.TITLE_2,
				true,
				Style.color(Style.COLOR_TEXT),
				Style.color(Style.COLOR_BACKGROUND),
				false
			);
			placeholder.y = list.view.y + Config.FINGER_SIZE;
			placeholder.x = int(_width * .5 - placeholder.width * .5);
		}
		
		private function removePlaceholder():void {
			if (placeholder != null) {
				UI.destroy(placeholder);
				placeholder = null;
			}
		}
		
		private function showPreloader():void {
			TweenMax.killDelayedCallsTo(startPreloader);
			TweenMax.delayedCall(0.2, startPreloader);
		}
		
		private function startPreloader():void {
			TweenMax.killDelayedCallsTo(startPreloader);
			if (preloader != null)
				preloader.start();
		}
		
		private function hidePreloader():void {
			hideHistoryLoader();
			TweenMax.killDelayedCallsTo(startPreloader);
			preloader.stop();
		}
	}
}