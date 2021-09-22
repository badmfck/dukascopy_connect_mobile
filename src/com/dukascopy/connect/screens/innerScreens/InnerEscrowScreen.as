package com.dukascopy.connect.screens.innerScreens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.IFilterData;
	import com.dukascopy.connect.data.LabelItem;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.escrow.filter.EscrowFilter;
	import com.dukascopy.connect.data.escrow.filter.EscrowFilterType;
	import com.dukascopy.connect.gui.components.StatusClip;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.QuestionCreateUpdateScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.escrow.FiltersPanel;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class InnerEscrowScreen extends BaseScreen {
		
		private static var selectedFilter:String;
		
		private var list:List;
		private var tabs:FilterTabs;
		
		private var needToRefreshAfterScrollStoped:Boolean = false;
		
		static private var storedTabListPosition:Object = {};
		static private var storedTabListPositionCreated:Boolean;
		
		private var wasFilter:Boolean = false;
		private var followItem:ListItem;
		
		private var tweenObj:Object = {};
		private var statusClip:StatusClip;
		private var placeholder:Bitmap;
		private var preloader:HorizontalPreloader;
		private var instrument:String;
		private var filtersPanel:FiltersPanel;
		private var currentFilters:Vector.<EscrowFilter>;
		
		public function InnerEscrowScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			list = new List("QuestionsList");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			_view.addChild(list.view);
			
			tabs = new FilterTabs();

			/*tabs.add(Lang.textAll, QuestionsManager.TAB_OTHER, true, "l");
			tabs.add(Lang.textMine, QuestionsManager.TAB_MINE);
			tabs.add(Lang.questionsResolved, QuestionsManager.TAB_RESOLVED,false,"r");*/
			
			filtersPanel = new FiltersPanel(onFilterRemove);
			_view.addChild(filtersPanel);
			
			createTabs();
			_view.addChild(tabs.view);
			
			if (storedTabListPositionCreated == false) {
				storedTabListPositionCreated = true;
				storedTabListPosition[QuestionsManager.TAB_OTHER] = {};
				storedTabListPosition[QuestionsManager.TAB_OFFERS] = {};
				storedTabListPosition[QuestionsManager.TAB_MINE] = {};
				storedTabListPosition[QuestionsManager.TAB_DEALS] = {};
			}
			
			preloader = new HorizontalPreloader(Style.color(Style.COLOR_ICON_LIGHT));
			_view.addChild(preloader);
		}
		
		private function onFilterRemove(filter:IFilterData):void 
		{
			if (filter != null && filter is EscrowFilter)
			{
				if (currentFilters != null)
				{
					currentFilters.removeAt(currentFilters.indexOf(filter as EscrowFilter));
					onFilters(currentFilters);
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function createTabs():void{
			tabs.add(Lang.ads, QuestionsManager.TAB_OTHER, true, "l");
			tabs.add(Lang.textMine, QuestionsManager.TAB_MINE);
			tabs.add(Lang.escrow_offers, QuestionsManager.TAB_OFFERS);
			tabs.add(Lang.escrow_deals, QuestionsManager.TAB_DEALS, false, "r");
		}
		
		override public function clearView():void {
			super.clearView();
			
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (list != null) {
				if (list.getBoxY() < 0) {
					storedTabListPosition[selectedFilter].listBoxY = list.getBoxY();
					var fli:ListItem = list.getFirstVisibleItem();
					if (fli != null) {
						storedTabListPosition[selectedFilter].item = list.getFirstVisibleItem().data;
						storedTabListPosition[selectedFilter].offset = fli.y + storedTabListPosition[selectedFilter].listBoxY;
					}
					list.dispose();
				} else if ("item" in storedTabListPosition[selectedFilter] == true) {
					delete storedTabListPosition[selectedFilter].item;
					delete storedTabListPosition[selectedFilter].offset;
					delete storedTabListPosition[selectedFilter].listBoxY;
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
			
			updatePositions();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = true;
			
			QuestionsManager.setInOut(true);
			
			
			if (data != null && "additionalData" in data && data.additionalData != null && data.additionalData is String)
			{
				instrument = data.additionalData as String;
			}
			else
			{
				ApplicationErrors.add();
			}
			
			preloader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			if (selectedFilter == null)
				selectedFilter = QuestionsManager.TAB_OTHER; 
			tabs.setSelection(selectedFilter);
			
			GD.S_ESCROW_INSTRUMENTS.add(onInstrumentsLoaded);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
			GD.S_ESCROW_FILTER.add(onFilters);
		}
		
		private function onFilters(filters:Vector.<EscrowFilter>):void 
		{
			currentFilters = filters;
			if (selectedFilter == QuestionsManager.TAB_OTHER)
			{
				//!TODO:;
				setListData();
			}
			updatePositions();
		}
		
		private function updatePositions():void 
		{
			var destY:int;
			
			if (currentFilters != null && currentFilters.length > 0 && selectedFilter == QuestionsManager.TAB_OTHER)
			{
				destY += Config.FINGER_SIZE * .1;
				filtersPanel.visible = true;
				filtersPanel.y = destY
				filtersPanel.draw(currentFilters, _width - Config.MARGIN * 4);
				filtersPanel.x = Config.MARGIN * 2;
				destY += filtersPanel.getHeight() + Config.FINGER_SIZE * .1;
			}
			else
			{
				filtersPanel.visible = false;
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
		
		private function onInstrumentsLoaded(instruments:Vector.<EscrowInstrument>):void 
		{
			if (_isDisposed)
			{
				return;
			}
			if (isActivated)
			{
				list.refresh();
			}
		}
		
		public function onHide():void {
			//TweenMax.killDelayedCallsTo(QuestionsManager.askFirstQuestion);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			
			if (list != null && list.isDisposed == false) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				list.S_ITEM_HOLD.add(onItemHold);
				list.S_STOPED.add(onScrollStopped);
				list.S_MOVING.add(onListMoved);
			}
			
			if (tabs != null && tabs.isDisposed == false) {
				tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			
			filtersPanel.activate();
			
			QuestionsManager.S_QUESTIONS.add(updateData);
			QuestionsManager.S_QUESTIONS_START_LOADING.add(showLoading);
			QuestionsManager.S_QUESTIONS_FILTERED.add(updateData);
			QuestionsManager.S_FILTER_CLEARED.add(updateData);
			QuestionsManager.S_QUESTION.add(updateQuestion);
			AnswersManager.S_QUESTION_ANSWERS.add(updateQuestion);
			AnswersManager.S_ANSWERS.add(onAnswersLoaded);
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
			UsersManager.S_TOAD_UPDATED.add(refreshList);
			
			setListData("");
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
			
			if (list != null && list.isDisposed == false) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
				list.S_ITEM_HOLD.remove(onItemHold);
				list.S_STOPED.remove(onScrollStopped);
				list.S_MOVING.remove(onListMoved);
			}
			
			if (tabs != null && tabs.isDisposed == false) {
				tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			
			QuestionsManager.S_QUESTIONS.remove(updateData);
			QuestionsManager.S_QUESTIONS_START_LOADING.remove(showLoading);
			QuestionsManager.S_QUESTIONS_FILTERED.remove(updateData);
			QuestionsManager.S_FILTER_CLEARED.remove(updateData);
			QuestionsManager.S_QUESTION.remove(updateQuestion);
			AnswersManager.S_QUESTION_ANSWERS.remove(updateQuestion);
			AnswersManager.S_ANSWERS.remove(onAnswersLoaded);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			UsersManager.S_TOAD_UPDATED.remove(refreshList);
			
			UsersManager.S_USERS_FULL_DATA.remove(onUserBanChange);
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
				tabs.updateLabels( [ Lang.textAll, Lang.textMine, Lang.questionsResolved ] );
			}
			super.drawViewLang();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (preloader != null)
			{
				TweenMax.killDelayedCallsTo(startPreloader);
				preloader.dispose();
				preloader = null;
			}
			removePlaceholder();
			GD.S_ESCROW_INSTRUMENTS.remove(onInstrumentsLoaded);
			DialogManager.closeDialog();
		}
		
		public function openQuestionCreateUpdateScreen(e:Event = null):void {
			if (QuestionsManager.checkForUnsatisfiedQuestions() == true) {
				DialogManager.alert(Lang.information, Lang.limitQuestionExists);
				return;
			}
			MobileGui.changeMainScreen(
				QuestionCreateUpdateScreen, {
					backScreen:MobileGui.centerScreen.currentScreenClass,
					title:Lang.escrow_create_your_ad,
					backScreenData:this.data,
					data:null
				},
				ScreenManager.DIRECTION_RIGHT_LEFT
			);
		}
		
		private function updateData():void {
			if (_isDisposed == true)
				return;
			if (_isActivated == false)
				return;
			
			hideStatusClip();
			setListData();
		}
		
		private function hideStatusClip():void {
			if (statusClip)
				statusClip.hide();
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void {
			if (_isDisposed == true)
				return;
			if (list == null)
				return;
			if (method != UsersManager.METHOD_OFFLINE_STATUS && method != UsersManager.METHOD_ONLINE_STATUS)
				return;
			var user:ChatUserVO;
			var item:ListItem;
			var qVO:QuestionVO;
			var l:int = list.getStock().length;
			for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) {
				item = list.getItemByNum(j);
				if (item != null && item.liView != null && item.liView.visible == true) {
					if (item.data is QuestionVO == true) {
						qVO = item.data as QuestionVO;
						if (qVO.isMine() == false && qVO.userUID == status.uid) {
							if (list.getScrolling() == true) {
								list.refresh();
								break;
							} else
								item.draw(list.width);
						}
					} else if (item.data is ChatVO == true) {
						user = UsersManager.getInterlocutor(item.data as ChatVO);
						if (user && user.uid == status.uid) {
							if (list.getScrolling()) {
								list.refresh();
								break;
							} else
								item.draw(list.width);
						}
					}
				} else
					break;
			}
			user = null;
			qVO = null;
			item = null;
		}
		
		private function onUserlistOnlineStatusChanged():void {
			if (_isDisposed == true)
				return;
			if (list != null)
				list.refresh();
		}
		
		private function onAllUsersOffline():void {
			if (_isDisposed == true)
				return;
			if (list != null)
				list.refresh();
		}
		
		private function refreshList():void {
			if (_isDisposed == true)
				return;
			if (list != null)
				list.refresh();
		}
		
		private function onListMoved(...rest):void {
			if (_isDisposed == true)
				return;
			if (selectedFilter != QuestionsManager.TAB_OTHER)
				return;
			if (list == null || followItem == null)
				return;
			if (QuestionsManager.getShowTipsOnly() == true) {
				if (list.getBoxY() > 0)
					list.setBGColorOnly(Style.color(Style.COLOR_BACKGROUND));
				else
					list.setBGColorOnly(Style.color(Style.COLOR_TIPS_911_BACKGROUND));
				return;
			}
		}
		
		private function onScrollStopped(val:Number):void {
			if (_isDisposed == true)
				return;
			if (_isActivated == false)
				return;
			if (needToRefreshAfterScrollStoped == false)
				return;
			needToRefreshAfterScrollStoped = false;
			setListData();
		}
		
		private function onAnswersLoaded():void {
			if (_isDisposed == true)
				return;
			
			//!TODO:;
			if (selectedFilter != QuestionsManager.TAB_RESOLVED)
				return;
			setListData();
		}
		
		private function updateQuestion(qVO:QuestionVO):void {
			if (_isDisposed == true)
				return;
			if (_isActivated == false)
				return;
			if (list == null)
				return;
			if (list.data == null)
				return;
			if (list.getScrolling() == true) {
				needToRefreshAfterScrollStoped = true;
				return;
			}
			list.updateItem(qVO);
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (_isDisposed == true)
				return;
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			if (item != null)
				itemHitZone = item.getLastHitZone();
			if (data is ChatVO) {
				if (itemHitZone && itemHitZone == HitZoneType.DELETE) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmLeaveConversation, function(val:int):void {
						if (val != 1)
							return;
						ChatManager.removeUser((data as ChatVO).uid);
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
				var chatScreenData:ChatScreenData = new ChatScreenData();
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
			else if (data is QuestionVO) {
				var qVO:QuestionVO = data as QuestionVO;
				if (qVO.uid == null || qVO.uid == "") {
					if (itemHitZone == HitZoneType.QUESTION_INFO) {
						QuestionsManager.showRules();
						return;
					}
					if (QuestionsManager.checkForUnsatisfiedQuestions() == true) {
						DialogManager.alert(Lang.information, Lang.limitQuestionExists);
						return;
					}
					MobileGui.changeMainScreen(QuestionCreateUpdateScreen, {
						backScreen:MobileGui.centerScreen.currentScreenClass,
						title:Lang.addTender, 
						data:null
					}, ScreenManager.DIRECTION_RIGHT_LEFT);
					return;
				}
				if (qVO.isRemoving == true)
					return;
				if (itemHitZone) {
					if (itemHitZone == HitZoneType.DELETE) {
						DialogManager.alert(Lang.confirm, Lang.alertConfirmDeleteQuestion, function(val:int):void {
							if (val != 1)
								return;
							QuestionsManager.close(qVO.uid);
							list.updateItemByIndex(n);
						}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
						return;
					}
					if (itemHitZone == HitZoneType.DELETE_ADMIN) {
						DialogManager.alert(Lang.confirm, Lang.alertConfirmDeleteQuestion, function(val:int):void {
							if (val != 1)
								return;
							QuestionsManager.closeByAdmin(qVO.uid);
							list.updateItemByIndex(n);
						}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
						return;
					}
					if (itemHitZone == HitZoneType.QUESTION_INFO) {
						//if (QuestionsManager.getCategoriesFilterNames() == "")
							QuestionsManager.showRules();
						return;
					}
					if (itemHitZone == HitZoneType.TIPS) {
						DialogManager.alert(Lang.information, qVO.tipsAmount + " " + qVO.tipsCurrencyDisplay + Lang.textAdditionalTips);
						return;
					}
				}
				if (qVO.userUID != Auth.uid) {
					AnswersManager.answer(qVO);
					return;
				}
				if (qVO.answersCount > 0) {
					if (qVO.type == null || qVO.type == QuestionsManager.QUESTION_TYPE_PRIVATE) {
						AnswersManager.getAnswersByQuestionUID(qVO.uid);
					} else if (qVO.type == QuestionsManager.QUESTION_TYPE_PUBLIC) {
						AnswersManager.answer(qVO);
					}
					return;
				}
				if (qVO.type == QuestionsManager.QUESTION_TYPE_PUBLIC && qVO.status == "process") {
					AnswersManager.answer(qVO);
					return;
				}
				if (qVO.status == "resolved" || qVO.status == "closed") {
					AnswersManager.getAnswersByQuestionUID(qVO.uid);
				}
				if (qVO.status != "created" && qVO.status != "edited"){
					ToastMessage.display(Lang.answerAreEmpty);
					return;
				}
				MobileGui.changeMainScreen(
					QuestionCreateUpdateScreen, {
						backScreen:MobileGui.centerScreen.currentScreenClass,
						title:Lang.editEscrowAd,
						data:qVO
					},
					ScreenManager.DIRECTION_RIGHT_LEFT
				);
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
		
		private function onTabItemSelected(id:String):void {
			if (_isDisposed == true)
				return;
			updatePositions();
			setListData(id);
			selectedFilter = id;
			list.setBGColorOnly(Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function setListData(id:String = ""):void {
			if (_isDisposed == true)
				return;
			if (list == null)
				return;
			
			var otherID:Boolean = id != "" && id != selectedFilter;
			if (otherID == false && list.getScrolling() == true) {
				needToRefreshAfterScrollStoped = true;
				return;
			}
			
			var listBoxY:int = list.getBoxY();
			
			if (listBoxY < 0) {
				storedTabListPosition[selectedFilter].listBoxY = list.getBoxY();
				var fli:ListItem = list.getFirstVisibleItem();
				if (fli != null) {
					storedTabListPosition[selectedFilter].item = list.getFirstVisibleItem().data;
					storedTabListPosition[selectedFilter].offset = fli.y + storedTabListPosition[selectedFilter].listBoxY;
				}
			} else if ("item" in storedTabListPosition[selectedFilter] == true) {
				delete storedTabListPosition[selectedFilter].item;
				delete storedTabListPosition[selectedFilter].offset;
				delete storedTabListPosition[selectedFilter].listBoxY;
			}
			
			var needToScrollTop:Boolean = !otherID && listBoxY > 0;
			
			if (id == "")
				id = selectedFilter;
			
			drawView();
			
			var listItemClass:Class = ListEscrowRenderer;
			var listData:Array;
			var hideLoader:Boolean = true;
			if (id == QuestionsManager.TAB_RESOLVED) {
				listData = AnswersManager.getAllAnswers();
				listItemClass = ListConversation;
			} else {
				if (id == QuestionsManager.TAB_OTHER)
				{
					listData = QuestionsManager.getNotResolved(getFilters());
					listData = sortByFilters(listData);
					showPreloader();
				}
				else if (id == QuestionsManager.TAB_OFFERS)
				{
					listData = QuestionsManager.getMine();
					showPreloader();
				}
				else if (id == QuestionsManager.TAB_DEALS)
				{
					listData = QuestionsManager.getMine();
					showPreloader();
				}
				if (listData == null)
				{
					hideLoader = false;
					listData = [];
				}
			}
			if (hideLoader)
			{
				hidePreloader();
			}
			list.setData(listData, listItemClass, ["avatarURL"]);
			if (needToScrollTop == false)
				if (storedTabListPosition[id] != null && "item" in storedTabListPosition[id] == true && storedTabListPosition[id].item != null)
					if (list.scrollToItem(null, storedTabListPosition[id].item, storedTabListPosition[id].offset) == false)
						if ("listBoxY" in storedTabListPosition[id] == true)
							list.setBoxY(storedTabListPosition[id].listBoxY);
			list.setContextAvaliable(true);
			
			//!TODO:;
			if (hideLoader == true && id != QuestionsManager.TAB_OFFERS && (listData == null || listData.length == 0))
			{
				addPlaceholder(Lang.escrow_no_active_ads_placeholder);
			}
			else
			{
				removePlaceholder();
			}
		}
		
		private function sortByFilters(listData:Array):Array 
		{
			var needSort:Boolean = false;
			if (currentFilters != null && currentFilters.length > 0)
			{
				for (var i:int = 0; i < currentFilters.length; i++) 
				{
					if (currentFilters[i].field == EscrowFilterType.DIRECTION)
					{
						if (currentFilters[i].value == TradeDirection.buy_sell.type)
						{
							needSort = true;
							break;
						}
					}
				}
			}
			if (needSort)
			{
				var sortFunction:Function = function(a:QuestionVO, b:QuestionVO):int{
					if (a.subtype == "sell" && b.subtype == "sell")
					{
						if (Number(a.price) > Number(b.price))
						{
							return -1;
						}
						else if (Number(a.price) < Number(b.price))
						{
							return 1;
						}
						else
						{
							return 0;
						}
					}
					else if (a.subtype == "buy" && b.subtype == "buy")
					{
						if (Number(a.price) > Number(b.price))
						{
							return 1;
						}
						else if (Number(a.price) < Number(b.price))
						{
							return -1;
						}
						else
						{
							return 0;
						}
					}
					else if (a.subtype == "sell")
					{
						return -1;
					}
					else if (b.subtype == "sell")
					{
						return 1;
					}
					else
					{
						return 0;
					}
				}
				var result:Array = listData.sort(sortFunction);
				return result;
			}
			else
			{
				return listData;
			}
		}
		
		private function getFilters():Vector.<EscrowFilter> 
		{
			var result:Vector.<EscrowFilter>;
			
			if (instrument != null)
			{
				result = new Vector.<EscrowFilter>();
				result.push(new EscrowFilter(EscrowFilterType.INSTRUMENT, instrument));
			}
			if (currentFilters != null && currentFilters.length > 0)
			{
				if (result == null)
				{
					result = new Vector.<EscrowFilter>();
				}
				for (var i:int = 0; i < currentFilters.length; i++) 
				{
					if (currentFilters[i].field == EscrowFilterType.DIRECTION)
					{
						if (currentFilters[i].value == TradeDirection.buy.type)
						{
							result.push(new EscrowFilter(EscrowFilterType.DIRECTION, currentFilters[i].value.toUpperCase()));
						}
						else if (currentFilters[i].value == TradeDirection.sell.type)
						{
							result.push(new EscrowFilter(EscrowFilterType.DIRECTION, currentFilters[i].value.toUpperCase()));
						}
						else if (currentFilters[i].value == TradeDirection.buy_sell.type)
						{
							//sort locally all items;
						}
					}
				}
			}
			
			return result;
		}
		
		private function removePlaceholder():void 
		{
			if (placeholder != null)
			{
				UI.destroy(placeholder);
				placeholder = null;
			}
		}
		
		private function addPlaceholder(text:String):void 
		{
			if (placeholder == null)
			{
				placeholder = new Bitmap();
				view.addChild(placeholder);
			}
			if (placeholder.bitmapData != null)
			{
				placeholder.bitmapData.dispose();
				placeholder.bitmapData = null;
			}
			placeholder.bitmapData = TextUtils.createTextFieldData(text, _width - Config.FINGER_SIZE, 10, true,
																	TextFormatAlign.CENTER, TextFieldAutoSize.CENTER, 
																	FontSize.TITLE_2, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			placeholder.y = list.view.y + Config.FINGER_SIZE;
			placeholder.x = int(_width * .5 - placeholder.width * .5);
		}
	}
}