package com.dukascopy.connect.screens.innerScreens {
	
	import assets.FilterIcon;
	import assets.MissBanner;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LabelItem;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.gui.button.InfoButtonPanel;
	import com.dukascopy.connect.gui.components.BanStatusClip;
	import com.dukascopy.connect.gui.components.StatusClip;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListBanUserRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListQuestionRenderer;
	import com.dukascopy.connect.gui.list.renderers.MissListRenderer;
	import com.dukascopy.connect.gui.list.renderers.TopExtensionListRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.QuestionCreateUpdateScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ScreenMissRulesPopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ScreenQuestionRulesPopup;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.extensions.ExtensionTopData;
	import com.dukascopy.connect.sys.usersManager.extensions.MissData;
	import com.dukascopy.connect.sys.usersManager.extensions.UserExtensionsManager;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
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
	
	public class InnerQuestionsScreen extends BaseScreen {
		
		private static var selectedFilter:String;
		
		private var max_text_width:int;
		
		private var headerSize:int;
		private var iconSize:Number;
		private var iconArrowSize:Number;
		private var buttonPaddingLeft:Number;
		private var image:Bitmap;
		private var list:List;
		private var tabs:FilterTabs;
		private var moreInfoButton:InfoButtonPanel;
		
		private var btnShowHideTips:BitmapButton;
		private var btnShowHideTipsUpBMD:ImageBitmapData;
		private var btnShowHideTipsDownBMD:ImageBitmapData;
		
		private var phoneIcon:FilterIcon;
		
		private var infoWasClosed:Boolean = false;
		private var showInfoBoxLoaded:Boolean = false;
		private var needToShowInfoBox:Boolean = false;
		private var needToRefreshAfterScrollStoped:Boolean = false;
		
		static private var storedTabListPosition:Object = {};
		static private var storedTabListPositionCreated:Boolean;
		
		private var wasFilter:Boolean = false;
		private var followItem:ListItem;
		private var needToRedrawButtonTips:Boolean;
		
		private var tweenObj:Object = {};
		private var statusClip:StatusClip;
		private var banNotificationClip:BanStatusClip;
		private var missBanner:Sprite;
		
		public function InnerQuestionsScreen() { }
		
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

			createTabs();
			_view.addChild(tabs.view);
			
			if (storedTabListPositionCreated == false) {
				storedTabListPositionCreated = true;
				storedTabListPosition[QuestionsManager.TAB_OTHER] = {};
				storedTabListPosition[QuestionsManager.TAB_MINE] = {};
				storedTabListPosition[QuestionsManager.TAB_RESOLVED] = {};
				storedTabListPosition[QuestionsManager.TAB_JAIL] = {};
				storedTabListPosition[QuestionsManager.TAB_FLOWERS] = {};
			}
			
			banNotificationClip = new BanStatusClip();
			_view.addChild(banNotificationClip);
		}
		
		private function createTabs():void{
			tabs.add(Lang.ads, QuestionsManager.TAB_OTHER, true, "l");
			tabs.add(Lang.textMine, QuestionsManager.TAB_MINE);
			tabs.add(Lang.history, QuestionsManager.TAB_RESOLVED, false, "r");
			
			/*if (PaidBan.showJailSection == true)
				tabs.add(Lang.jail, QuestionsManager.TAB_JAIL);
			tabs.add(Lang.miss, QuestionsManager.TAB_FLOWERS, false, "r");*/
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
			
			if (moreInfoButton != null)
				moreInfoButton.dispose();
			moreInfoButton = null;
			
			if (btnShowHideTips != null)
				btnShowHideTips.dispose();
			btnShowHideTips = null;
			UI.disposeBMD(btnShowHideTipsDownBMD);
			btnShowHideTipsDownBMD = null;
			UI.disposeBMD(btnShowHideTipsUpBMD);
			btnShowHideTipsUpBMD = null;
			
			PaidBan.S_UPDATED.remove(onBansUpdated);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			var destY:int;
			if (moreInfoButton != null && moreInfoButton.isShown == true) {
				moreInfoButton.viewWidth = _width;
				destY += moreInfoButton.height;
			}
			
			if (tabs != null) {
				tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
				tabs.view.y = destY;
				destY += tabs.height;
			}
			if (missBanner != null)
			{
				destY += missBanner.height;
			}
			
			if (list != null) {
				list.view.y = destY;
				list.setWidthAndHeight(_width, _height - list.view.y);
			}
			
			if (btnShowHideTips != null && QuestionsManager.getShowTipsOnly())
				btnShowHideTips.y = _height - Config.DOUBLE_MARGIN - btnShowHideTips.height;
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = '911 Screen';
			_params.doDisposeAfterClose = true;
			
			needToRedrawButtonTips = true;
			
			QuestionsManager.setInOut(true);
			
			if (selectedFilter == null)
				selectedFilter = QuestionsManager.TAB_OTHER; 
			tabs.setSelection(selectedFilter);
			if (infoWasClosed == false) {
				if (showInfoBoxLoaded == false)
					Store.load("ShowQueInfo", onShowInfoBoxLoaded);
				else if (needToShowInfoBox == true)
					TweenMax.delayedCall(1, showMoreInfoButton);
			}
			banNotificationClip.y = _height;
			banNotificationClip.setSize(_width);
			PaidBan.S_UPDATED.add(onBansUpdated);
			
			GD.S_ESCROW_INSTRUMENTS.add(onInstrumentsLoaded);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
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
		
		private function onExtensionsLoaded(data:Array):void {
			if (selectedFilter == QuestionsManager.TAB_FLOWERS)
			{
				setListData(selectedFilter);
			}
		}
		
		private function onBansUpdated(success:Boolean):void {
			if (PayAPIManager.configSeted==true) {
				if (tabs != null) {
					tabs.removeAll();
					tabs.setWidthAndHeight(0, 0);
					createTabs();
					tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
					tabs.setSelection(selectedFilter);
				}
			}
		}
		
		public function onHide():void {
			//TweenMax.killDelayedCallsTo(QuestionsManager.askFirstQuestion);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			
			if (moreInfoButton != null)
				moreInfoButton.activate();
			
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
			
			if (missBanner != null)
			{
				PointerManager.addTap(missBanner, openMissRules);
			}
			
			if (btnShowHideTips != null)
				btnShowHideTips.activate();
			
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
			UserExtensionsManager.S_CURENT_MISS_LIST.add(onExtensionsLoaded);
			
			if (PaidBan.isAvaliable()) {
				PaidBan.S_USER_BAN_UPDATED.add(onUserBanChange);
				PaidBan.S_BANS_TOP_LIST.add(updateBansData);
				UsersManager.S_USERS_FULL_DATA.add(onUserBanChange);
			}
			
			setListData();
			
			// Где проверка на открытый диалог реф кода?
			QuestionsManager.preAskFirstQuestion();
			
			
			if (banNotificationClip != null) {
				banNotificationClip.activate();
			}
		}
		
		private function onUserBanChange(userUID:String = null):void {
			refreshList();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			
			if (moreInfoButton != null)
				moreInfoButton.deactivate();
			
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
			
			if (btnShowHideTips != null)
				btnShowHideTips.deactivate();
			
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
			
			PaidBan.S_USER_BAN_UPDATED.remove(onUserBanChange);
			PaidBan.S_BANS_TOP_LIST.remove(updateBansData);
			UsersManager.S_USERS_FULL_DATA.remove(onUserBanChange);
			UserExtensionsManager.S_CURENT_MISS_LIST.remove(onExtensionsLoaded);
			
			if (missBanner != null)
			{
				PointerManager.removeTap(missBanner, openMissRules);
			}
			
			if (banNotificationClip != null) {
				banNotificationClip.deactivate();
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
				if (PaidBan.showJailSection == true) {
					tabs.updateLabels( [ Lang.textAll, Lang.textMine, Lang.questionsResolved, Lang.jail ] );
				}
				else {
					tabs.updateLabels( [ Lang.textAll, Lang.textMine, Lang.questionsResolved ] );
				}
			}
			if (moreInfoButton != null)
				moreInfoButton.setText(Lang.emergencyMoreInfoButton);
			super.drawViewLang();
		}
		
		override public function dispose():void {
			super.dispose();
			
			GD.S_ESCROW_INSTRUMENTS.remove(onInstrumentsLoaded);
			TweenMax.killDelayedCallsTo(showMoreInfoButton);
			DialogManager.closeDialog();
			
			if (banNotificationClip != null) {
				banNotificationClip.dispose();
			}
			removeMissBanner();
		}
		
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  TOP INFO PANEL  ->  ///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function onShowInfoBoxLoaded(data:Object, err:Boolean):void {
			showInfoBoxLoaded = true;
			if (err == true) {
				/*needToShowInfoBox = true;
				TweenMax.delayedCall(1, showMoreInfoButton);*/
				return;
			}
			needToShowInfoBox = true;
			TweenMax.delayedCall(1, showMoreInfoButton);
		}
		
		private function showMoreInfoButton():void {
			if (moreInfoButton != null && moreInfoButton.isShown == true)
				return;
			addMoreInfoButton();
			moreInfoButton.show((wasFilter == true) ? 0 : .3, 0);
			
			tweenObj.y = 0;
			TweenMax.killTweensOf(tweenObj);
			TweenMax.to(
				tweenObj,
				.2,
				{ 
					y:moreInfoButton.height,
					ease:Quint.easeOut,
					onUpdate:setDownContentPositionY,
					onComplete:onComplete
				}
			);
		}
		
		private function addMoreInfoButton():void {
			if (moreInfoButton != null)
				return;
			moreInfoButton = new InfoButtonPanel();
			moreInfoButton.tapCallback = onMoreInfoClick;
			moreInfoButton.viewWidth = _width;
			moreInfoButton.setText(Lang.emergencyMoreInfoButton);
			view.addChild(moreInfoButton);
			
			if (_isActivated == true)
				moreInfoButton.activate();
		}
		
		private function hideMoreInfoButton():void {
			if (moreInfoButton == null)
				return;
			moreInfoButton.hide();
			tweenObj.y = tabs.view.y;
			TweenMax.killTweensOf(tweenObj);
			TweenMax.to(
				tweenObj,
				.2,
				{ 
					y:0,
					delay:.3,
					ease:Quint.easeOut,
					onUpdate:setDownContentPositionY,
					onComplete:onComplete
				}
			);
		}
		
		private function onComplete():void {
			setDownContentPositionY(true);
		}
		
		private function setDownContentPositionY(end:Boolean = false):void {
			var offset:Number = tweenObj.y;
			if (tabs != null) {
				tabs.view.y = offset;
				offset += tabs.height;
			}
			if (list != null) {
				list.view.y = offset;
				if (end == true)
					list.setWidthAndHeight(_width, _height - list.view.y);
			}
		}
		
		private function onMoreInfoClick(closeClicked:Boolean = false):void {
			if (closeClicked == true) {
				hideMoreInfoButton();
				closeAndSave();
				return;
			}
			QuestionsManager.showRules();
		}
		
		private function closeAndSave():void {
			infoWasClosed = true;	
			needToShowInfoBox = false;
			Store.remove("ShowQueInfo");
		}
		
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  <-  TOP INFO PANEL  ///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function openQuestionCreateUpdateScreen(e:Event = null):void {
			if (QuestionsManager.checkForUnsatisfiedQuestions() == true) {
				DialogManager.alert(Lang.information, Lang.limitQuestionExists);
				return;
			}
			MobileGui.changeMainScreen(
				QuestionCreateUpdateScreen, {
					backScreen:MobileGui.centerScreen.currentScreenClass,
					title:Lang.askQuestions,
					backScreenData:this.data,
					data:null
				},
				ScreenManager.DIRECTION_RIGHT_LEFT
			);
		}
		
		private function onTipsTapped():void {
			QuestionsManager.setShowTipsOnly(!QuestionsManager.getShowTipsOnly());
			setListData();
			if (list != null)
				list.scrollTop();
		}
		
		private function updateData():void {
			if (_isDisposed == true)
				return;
			if (_isActivated == false)
				return;
			
			if (selectedFilter == QuestionsManager.TAB_JAIL) {
				return;
			}
			
			hideStatusClip();
			setListData();
		}
		
		private function updateBansData():void {
			if (selectedFilter == QuestionsManager.TAB_JAIL) {
				if (_isDisposed == true)
					return;
				if (_isActivated == false)
					return;
				hideStatusClip();
				setListData();
			}
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
			if (btnShowHideTips != null)
				btnShowHideTips.y = followItem.y + followItem.height + list.getBoxY() + list.view.y - btnShowHideTips.height * .5;
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
			else if (data is ExtensionTopData && (data as ExtensionTopData).user != null) {
				MobileGui.changeMainScreen(UserProfileScreen, {data:(data as ExtensionTopData).user, 
																backScreen:MobileGui.centerScreen.currentScreenClass, 
																backScreenData:data});
			}
			else if (data is UserBan911VO) {
				if((data as UserBan911VO).user != null && (data as UserBan911VO).user.uid != Auth.uid && (data as UserBan911VO).user.getDisplayName() != null) {
					MobileGui.changeMainScreen(
						UserProfileScreen,
						{
							data:(data as UserBan911VO).user, 
							backScreen:MobileGui.centerScreen.currentScreenClass, 
							backScreenData:MobileGui.centerScreen.currentScreen.data
						}
					);
				}
				return;
			}
			else if (data is PaidBanProtectionData) {
				if((data as PaidBanProtectionData).user != null && (data as PaidBanProtectionData).user.uid != Auth.uid && (data as PaidBanProtectionData).user.getDisplayName() != null) {
					MobileGui.changeMainScreen(
						UserProfileScreen,
						{
							data:(data as PaidBanProtectionData).user, 
							backScreen:MobileGui.centerScreen.currentScreenClass, 
							backScreenData:MobileGui.centerScreen.currentScreen.data
						}
					);
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
						DialogManager.alert(Lang.information, qVO.tipsAmount + " " + qVO.tipsCurrency + Lang.textAdditionalTips);
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
						title:Lang.editQuestions,
						data:qVO
					},
					ScreenManager.DIRECTION_RIGHT_LEFT
				);
			}
			else if (data is MissData)
			{
				if (itemHitZone && itemHitZone == HitZoneType.SHOW_ALL) {
					UserExtensionsManager.stateMiss = UserExtensionsManager.STATE_MISS_ALL;
					setListData();
				}
				else if (itemHitZone && itemHitZone == HitZoneType.EXPAND)
				{
					UserExtensionsManager.stateMiss = UserExtensionsManager.STATE_MISS_TOP_MORE;
					setListData();
				}
				else if (itemHitZone && itemHitZone == HitZoneType.COLLAPSE)
				{
					UserExtensionsManager.stateMiss = UserExtensionsManager.STATE_MISS_TOP;
					setListData();
				}
				else if (itemHitZone && itemHitZone == HitZoneType.BACK)
				{
					UserExtensionsManager.stateMiss = UserExtensionsManager.STATE_MISS_TOP;
					setListData();
				}
				else if((data as MissData).user != null)
				{
					MobileGui.changeMainScreen(UserProfileScreen, {data:(data as MissData).user, 
																backScreen:MobileGui.centerScreen.currentScreenClass, 
																backScreenData:data});
				}
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
			if (btnShowHideTips != null && btnShowHideTips.parent != null)
				btnShowHideTips.parent.removeChild(btnShowHideTips);
			if (id != QuestionsManager.TAB_OTHER)
				hideMoreInfoButton();
			else if (wasFilter == true)
				showMoreInfoButton();
			needToRedrawButtonTips = true;
			setListData(id);
			selectedFilter = id;
			if (selectedFilter == QuestionsManager.TAB_FLOWERS)
			{
				UserExtensionsManager.getCurrentMissList();
			}
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
			
			if (id == QuestionsManager.TAB_FLOWERS && Auth.bank_phase == "ACC_APPROVED")
			{
				addMissBanner();
			}
			else
			{
				removeMissBanner();
			}
			
			drawView();
			
			var listItemClass:Class = ListQuestionRenderer;
			var listData:Array;
			if (id == QuestionsManager.TAB_RESOLVED) {
				listData = AnswersManager.getAllAnswers();
				listItemClass = ListConversation;
			} else if (id == QuestionsManager.TAB_JAIL) {
				listData = PaidBan.getJailData();
				listItemClass = ListBanUserRenderer;
			}
			else if (id == QuestionsManager.TAB_FLOWERS) {
				list.setData(null, null);
				listData = UserExtensionsManager.getCurrentMissList();
				listItemClass = MissListRenderer;
			}else {
				if (id == QuestionsManager.TAB_OTHER)
					listData = QuestionsManager.getNotResolved();
				else if (id == QuestionsManager.TAB_MINE)
					listData = QuestionsManager.getMine();
				if (listData == null)
					listData = [];
			}
			
			list.setData(listData, listItemClass, ["avatarURL"]);
			if (needToScrollTop == false)
				if (storedTabListPosition[id] != null && "item" in storedTabListPosition[id] == true && storedTabListPosition[id].item != null)
					if (list.scrollToItem(null, storedTabListPosition[id].item, storedTabListPosition[id].offset) == false)
						if ("listBoxY" in storedTabListPosition[id] == true)
							list.setBoxY(storedTabListPosition[id].listBoxY);
			list.setContextAvaliable(true);
			
			checkForTipsButtonNeeded(id);
		}
		
		private function removeMissBanner():void 
		{
			if (missBanner != null)
			{
				PointerManager.removeTap(missBanner, openMissRules);
				if (view.contains(missBanner))
				{
					view.removeChild(missBanner);
				}
				while (missBanner.numChildren > 0)
				{
					UI.destroy(missBanner.removeChildAt(0));
				}
				UI.destroy(missBanner);
				missBanner = null;
			}
		}
		
		private function addMissBanner():void 
		{
			if (missBanner == null)
			{
				missBanner = new Sprite();
				var ill:MissBanner = new MissBanner();
				UI.scaleToFit(ill, _width, _height);
				missBanner.addChild(ill);
				view.addChild(missBanner);
				missBanner.y = tabs.view.y + tabs.height;
				
				missBanner.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND))
				missBanner.graphics.drawRect(0, ill.height, _width, int(Config.FINGER_SIZE * .3));
				missBanner.graphics.endFill();
				
				if (list != null) {
					list.view.y = int(missBanner.y + missBanner.height);
					list.setWidthAndHeight(_width, _height - list.view.y);
				}
				PointerManager.addTap(missBanner, openMissRules);
				var text:Bitmap = new Bitmap(
					TextUtils.createTextFieldData(
						Lang.missRulesTitle,
						_width - Config.FINGER_SIZE * 2,
						10,
						true,
						TextFormatAlign.LEFT,
						TextFieldAutoSize.LEFT,
						Config.FINGER_SIZE * .3,
						true,
						Color.GREY_DARK,
						0xFFFFFF,
						true
					)
				);
				missBanner.addChild(text);
				text.x = int(Config.FINGER_SIZE * .6);
				text.y = int(ill.height * .5 - text.height * .5);
			}
		}
		
		private function openMissRules(e:Event = null):void {
			DialogManager.showDialog(ScreenMissRulesPopup,  { title:Lang.textRules } );
		}
		
		private function checkForTipsButtonNeeded(id:String = ""):void {
			if (id != QuestionsManager.TAB_OTHER || QuestionsManager.getLastTipsQUID() == null) {
				if (btnShowHideTips != null && btnShowHideTips.parent != null)
					view.removeChild(btnShowHideTips);
				return;
			}
			followItem = list.getItemByNum(1);
			if (followItem == null)
				return;
			if (followItem.data.uid != QuestionsManager.getLastTipsQUID())
				followItem = list.getItemByNum(2);
			if (btnShowHideTips == null) {
				var icon:Sprite = new (Style.icon(Style.ICON_ARROW_DOWN));
				UI.scaleToFit(icon, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5);
				btnShowHideTipsDownBMD = UI.getSnapshot(icon, StageQuality.HIGH, "InnerQuestionsScreen.tipsDown");
				icon = new (Style.icon(Style.ICON_ARROW_UP));
				UI.scaleToFit(icon, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5);
				btnShowHideTipsUpBMD = UI.getSnapshot(icon, StageQuality.HIGH, "InnerQuestionsScreen.tipsUp");
				
				btnShowHideTips = new BitmapButton();
				btnShowHideTips.setStandartButtonParams();
				btnShowHideTips.setDownScale(1.3);
				btnShowHideTips.tapCallback = onTipsTapped;
				btnShowHideTips.disposeBitmapOnDestroy = true;
				btnShowHideTips.setOverflow(Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25);
				btnShowHideTips.x = int((_width - btnShowHideTipsDownBMD.width) * .5);
				
				if (_isActivated == true)
					btnShowHideTips.activate();
			}
			if (btnShowHideTips.parent == null)
				view.addChildAt(btnShowHideTips, 1);
			if (QuestionsManager.getShowTipsOnly() == true) {
				if (btnShowHideTips.currentBitmapData != btnShowHideTipsUpBMD) {
					btnShowHideTips.setBitmapData(btnShowHideTipsUpBMD);
					btnShowHideTips.show(.3);
				}
				btnShowHideTips.y = _height - Config.DOUBLE_MARGIN - btnShowHideTips.height;
				return;
			}
			if ((btnShowHideTips.currentBitmapData != btnShowHideTipsDownBMD)) {
				btnShowHideTips.setBitmapData(btnShowHideTipsDownBMD);
				btnShowHideTips.show(.3);
				onListMoved();
				list.setBGColorOnly(Style.color(Style.COLOR_BACKGROUND));
			}
		}
	}
}