package com.dukascopy.connect.screens.innerScreens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LabelItem;
	import com.dukascopy.connect.gui.components.StatusClip;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowInstrumentRenderer;
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
	
	public class InnerEscrowInstrumentScreen extends BaseScreen {
		
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
		private var escrowInstruments:Vector.<EscrowInstrument>;
		
		public function InnerEscrowInstrumentScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			list = new List("QuestionsList");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			_view.addChild(list.view);
			
			tabs = new FilterTabs();
			
			createTabs();
			_view.addChild(tabs.view);
			
			if (storedTabListPositionCreated == false) {
				storedTabListPositionCreated = true;
				storedTabListPosition[QuestionsManager.TAB_OTHER] = {};
				storedTabListPosition[QuestionsManager.TAB_MINE] = {};
				storedTabListPosition[QuestionsManager.TAB_OFFERS] = {};
				storedTabListPosition[QuestionsManager.TAB_DEALS] = {};
			}
			
			preloader = new HorizontalPreloader(Style.color(Style.COLOR_ICON_LIGHT));
			_view.addChild(preloader);
		}
		
		private function createTabs():void{
			tabs.add(Lang.escrow_text_instruments, QuestionsManager.TAB_OTHER, true, "l");
			tabs.add(Lang.textMine, QuestionsManager.TAB_MINE, false);
			tabs.add(Lang.escrow_text_offers, QuestionsManager.TAB_OFFERS, false);
			tabs.add(Lang.escrow_text_deals, QuestionsManager.TAB_DEALS, false, "r");
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
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = '911 Screen';
			_params.doDisposeAfterClose = true;
			
			QuestionsManager.setInOut(true);
			
			preloader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			if (selectedFilter == null)
				selectedFilter = QuestionsManager.TAB_OTHER; 
			tabs.setSelection(selectedFilter);
			
			GD.S_ESCROW_INSTRUMENTS.add(onInstrumentsLoaded);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
		}
		
		private function onInstrumentsLoaded(instruments:Vector.<EscrowInstrument>):void {
			if (_isDisposed)
				return;
			hidePreloader();
			escrowInstruments = instruments;
			setListData(QuestionsManager.TAB_OTHER);
		}
		
		public function onHide():void {
			
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
			
			AnswersManager.S_ANSWERS.add(onAnswersLoaded);
			
			setListData("");
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
			TweenMax.killDelayedCallsTo(startPreloader);
			preloader.stop();
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
			
			AnswersManager.S_ANSWERS.remove(onAnswersLoaded);
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
				tabs.updateLabels( [ Lang.textAll, Lang.textMine, Lang.questionsResolved ] );
			super.drawViewLang();
		}
		
		override public function dispose():void {
			super.dispose();
			if (preloader != null) {
				TweenMax.killDelayedCallsTo(startPreloader);
				preloader.dispose();
				preloader = null;
			}
			removePlaceholder();
			GD.S_ESCROW_INSTRUMENTS.remove(onInstrumentsLoaded);
			DialogManager.closeDialog();
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
			if (selectedFilter != QuestionsManager.TAB_RESOLVED)
				return;
			setListData();
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
			} else if (data is LabelItem) {
				if (itemHitZone && itemHitZone == HitZoneType.SIMPLE_ACTION && (data as LabelItem).action != null) {
					(data as LabelItem).action.execute();
				}
				return;
			} else if (data is QuestionVO) {
				
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
			
			var listItemClass:Class = ListEscrowInstrumentRenderer;
			var listData:*;
			var hideLoader:Boolean = true;
			if (id == QuestionsManager.TAB_RESOLVED) {
				listData = AnswersManager.getAllAnswers();
				listItemClass = ListConversation;
			} else {
				if (id == QuestionsManager.TAB_OTHER)
				{
					listData = escrowInstruments;
				}
				else if (id == QuestionsManager.TAB_MINE)
				{
					listItemClass = ListEscrowRenderer;
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
			
			if (hideLoader == true && id != QuestionsManager.TAB_RESOLVED && (listData == null || listData.length == 0)) {
				addPlaceholder(Lang.escrow_no_active_ads_placeholder);
			} else {
				removePlaceholder();
			}
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