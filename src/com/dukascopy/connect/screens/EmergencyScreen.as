package com.dukascopy.connect.screens {
	
	import assets.AddItemButton;
	import assets.FilterIcon;
	import assets.Icon911;
	import assets.IconHelpClip3;
	import assets.IconInfoClip;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.button.InfoButtonPanel;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListQuestionRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class EmergencyScreen extends BaseScreen {
		
		private static var selectedFilter:String;
		
		public var FIT_WIDTH:Number;
		private var title:Bitmap;
		private var bgHeader:Shape;
		private var backButton:BitmapButton;
		private var questionButton:BitmapButton;
		private var supportButton:BitmapButton;
		private var max_text_width:int;
		
		private var headerSize:int;
		private var iconSize:Number;
		private var iconArrowSize:Number;
		private var buttonPaddingLeft:Number;
		private var image:Bitmap;
		private var backImage:Sprite;
		private var list:List;
		private var tabs:FilterTabs;
		private var infoButton:BitmapButton;
		private var moreInfoButton:InfoButtonPanel;
		
		private var btnShowHideTips:BitmapButton;
		private var btnShowHideTipsUpBMD:ImageBitmapData;
		private var btnShowHideTipsDownBMD:ImageBitmapData;
		
		private var phoneIcon:FilterIcon;
		
		private static var infoWasClosed:Boolean = false;
		private static var showInfoBoxLoaded:Boolean = false;
		private static var needToShowInfoBox:Boolean = false;
		private static var needToRefreshAfterScrollStoped:Boolean = false;
		
		static private var storedTabListPosition:Object = {};
		static private var storedTabListPositionCreated:Boolean;
		
		private var needToUpdateListPosition:Boolean;
		
		private var wasFilter:Boolean = false;
		private var followItem:ListItem;
		private var needToRedrawButtonTips:Boolean;
		
		public function EmergencyScreen() { }
		
		override public function initScreen(data:Object = null):void {
			echo("EmergencyScreen", "initScreen", "START");
			super.initScreen(data);
			_params.title = '911 Screen';
			_params.doDisposeAfterClose = true;
			
			needToRedrawButtonTips = true;
			
			bgHeader.width = _width;
			
			if (selectedFilter == null)
				selectedFilter = QuestionsManager.TAB_OTHER; 
			tabs.setSelection(selectedFilter);
			//setButtonDesign(selectedFilter);
			if (!infoWasClosed) {
				if (!showInfoBoxLoaded) {
					Store.load("showInfoBox", onShowInfoBoxLoaded);
				} else {
					if (needToShowInfoBox)
						TweenMax.delayedCall(1, showMoreInfoButton);
				}
			}
			//setFilterButton.setPosition(_width - Config.FINGER_SIZE - Config.DOUBLE_MARGIN,  _height - Config.FINGER_SIZE - Config.MARGIN * 2);
			QuestionsManager.setInOut(true);
			echo("EmergencyScreen", "initScreen", "END");
			
			drawTitle();
		}
		
		private function drawTitle():void {
			var icon:Sprite = new Icon911();
			var ct:ColorTransform = new ColorTransform();
			ct.color = 0xFFFFFF;
			icon.transform.colorTransform = ct;
			UI.scaleToFit(icon, Config.FINGER_SIZE * 1.5, Config.FINGER_SIZE * .4);
			
			title.bitmapData = UI.getSnapshot(icon, StageQuality.HIGH, "EmergencyScreen.title");
		}
		
		private function onShowInfoBoxLoaded(data:Object, err:Boolean):void {
			echo("EmergencyScreen", "onShowInfoBoxLoaded", "START");
			showInfoBoxLoaded = true;
			if (err == true) {
				needToShowInfoBox = true;
				TweenMax.delayedCall(1, showMoreInfoButton);
				echo("EmergencyScreen", "onShowInfoBoxLoaded", "ERROR");
				return;		
			}
			var wasClosed:Boolean = data == "1";
			infoWasClosed = wasClosed;
			needToShowInfoBox  = !wasClosed;
			echo("EmergencyScreen", "onShowInfoBoxLoaded", "END");
		}
		
		private function closeAndSave():void {
			echo("EmergencyScreen", "closeAndSave", "START");
			infoWasClosed = true;	
			needToShowInfoBox = false;
			Store.save("showInfoBox", "1");
			echo("EmergencyScreen", "closeAndSave", "END");
		}
		
		public static function resetClosed():void {
			echo("EmergencyScreen", "resetClosed", "START");
			infoWasClosed = false; // na logout 
			showInfoBoxLoaded = false;
			Store.remove("showInfoBox");
			echo("EmergencyScreen", "resetClosed", "END");
		}
		
		override public function onBack(e:Event = null):void {
			echo("EmergencyScreen", "onBack", "START");
			if (data && data.backScreen != undefined && data.backScreen != null) {
				selectedFilter = QuestionsManager.TAB_OTHER;
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			selectedFilter = QuestionsManager.TAB_OTHER;
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
			echo("EmergencyScreen", "onBack", "END");
		}
		
		public function openQuestionCreateUpdateScreen(e:Event = null):void {
			echo("EmergencyScreen", "openQuestionCreateUpdateScreen", "START");
			if (QuestionsManager.checkForUnsatisfiedQuestions() == true) {
				DialogManager.alert(Lang.information, Lang.limitQuestionExists);
				echo("EmergencyScreen", "onItemTap", "START QUESTION FAIL LIMIT");
				return;
			}
			MobileGui.changeMainScreen(QuestionCreateUpdateScreen, {
					backScreen:MobileGui.centerScreen.currentScreenClass,
					title:Lang.addTender, 
					backScreenData:this.data,
					data:null
				}, ScreenManager.DIRECTION_RIGHT_LEFT
			);
			echo("EmergencyScreen", "openQuestionCreateUpdateScreen", "END");
		}
		
		override protected function createView():void {
			echo("EmergencyScreen", "createView", "START");
			super.createView();
			
			//size variables;
			headerSize = int(Config.FINGER_SIZE * .85);
			iconSize = Config.FINGER_SIZE * 0.36;
			iconArrowSize = Config.FINGER_SIZE * 0.30;
			buttonPaddingLeft = Config.MARGIN * 2;
			var btnSize:int = headerSize * .38;
			var btnY:int = (headerSize - btnSize) * .5;
			var btnOffset:int = (Config.FINGER_SIZE * .85 - btnSize) * .5;
			
			list = new List("QuestionsList");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			_view.addChild(list.view);
			
			tabs = new FilterTabs();
			tabs.add(Lang.textAll, QuestionsManager.TAB_OTHER, true, "l");
			//storedTabListPosition[QuestionsManager.TAB_OTHER] = {};
			tabs.add(Lang.textMine, QuestionsManager.TAB_MINE);
			//storedTabListPosition[QuestionsManager.TAB_MINE] = {};
			tabs.add(Lang.questionsResolved, QuestionsManager.TAB_RESOLVED, false, "r");
			//storedTabListPosition[QuestionsManager.TAB_RESOLVED] = {};
			_view.addChild(tabs.view);
			
			/*tabsType = new FilterTabs();
			tabsType.setBackgroundVisible(false);
			tabsType.setTabsWidthByText(true);
			tabsType.add(Lang.textAll, QuestionsManager.TAB_ALL, !QuestionsManager.getShowTipsOnlyPublic(), "l");
			tabsType.add(Lang.textQuestionTypePublics, QuestionsManager.TAB_OTHER, QuestionsManager.getShowTipsOnlyPublic(), "r");*/
			
			if (storedTabListPositionCreated == false) {
				storedTabListPositionCreated = true;
				storedTabListPosition[QuestionsManager.TAB_OTHER] = {};
				storedTabListPosition[QuestionsManager.TAB_MINE] = {};
				storedTabListPosition[QuestionsManager.TAB_RESOLVED] = {};
			}
			
			backImage = new Sprite();
			view.addChild(backImage);
			backImage.graphics.beginFill(0xFFFFFF);
			backImage.graphics.drawRect(0, 0, 20, 20);
			backImage.graphics.endFill();
			
			//header background;
			bgHeader = UI.getTopBarShape();
			_view.addChild(bgHeader);
			
			//back header button;
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1.3);
			backButton.setDownColor(0xFFFFFF);
			backButton.tapCallback = onBack;
			backButton.disposeBitmapOnDestroy = true;
			backButton.show();
			_view.addChild(backButton);
			var icoBack:IconBack = new IconBack();
			icoBack.width = icoBack.height = btnSize;
			backButton.setBitmapData(UI.getSnapshot(icoBack, StageQuality.HIGH, "SelectBackgroundScreen.backButton"), true);
			backButton.x = btnOffset;
			backButton.y = btnY + Config.APPLE_TOP_OFFSET;
			backButton.setOverflow(btnOffset, btnOffset, Config.FINGER_SIZE, btnOffset + Config.FINGER_SIZE*.1);
			UI.destroy(icoBack);
			icoBack = null;
			
			//header title;
			title = new Bitmap(null, "auto", true);
			_view.addChild(title);
			
			btnOffset = (Config.FINGER_SIZE * .85 - btnSize) * .5;
			
			//ask question button;
			questionButton = new BitmapButton();
			questionButton.setStandartButtonParams();
			questionButton.setDownScale(1.3);
			questionButton.setDownColor(0xFFFFFF);
			questionButton.tapCallback = openQuestionCreateUpdateScreen;
			questionButton.disposeBitmapOnDestroy = true;
			questionButton.show();
			_view.addChild(questionButton);
			var icon:Sprite = new AddItemButton();
			UI.scaleToFit(icon, btnSize, btnSize);
			questionButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "SelectBackgroundScreen.questionButton"), true);
			questionButton.y = backButton.y;
			questionButton.setOverflow(btnOffset, btnOffset, btnOffset, btnOffset);
			UI.destroy(icon);
			icon = null;
			btnOffset = (Config.FINGER_SIZE * .85 - btnSize * 1.3) * .5;
			//info button;
			infoButton = new BitmapButton();
			infoButton.setStandartButtonParams();
			infoButton.setDownScale(1.3);
			infoButton.setDownColor(0xFFFFFF);
			infoButton.tapCallback = onInfoButtonClick;
			infoButton.disposeBitmapOnDestroy = true;
			infoButton.show();
			_view.addChild(infoButton);
			icon = new IconInfoClip();
			icon.height = btnSize * 1.3;
			icon.width = btnSize * 1.3;
			infoButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "SelectBackgroundScreen.infoIcon"), true);
			infoButton.y = int(questionButton.y + questionButton.height * .5 - infoButton.height * .5);
			infoButton.setOverflow(btnOffset, btnOffset, btnOffset, btnOffset);
			UI.destroy(icon);
			icon = null;
			//info button;
			supportButton = new BitmapButton();
			supportButton.setStandartButtonParams();
			supportButton.setDownScale(1.3);
			supportButton.setDownColor(0xFFFFFF);
			supportButton.tapCallback = onSupportButtonClick;
			supportButton.disposeBitmapOnDestroy = true;
			supportButton.show();
			_view.addChild(supportButton);
			icon = new IconHelpClip3();
			icon.height = btnSize * 1.3;
			icon.width = btnSize * 1.3;
			supportButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "SelectBackgroundScreen.infoIcon"), true);
			supportButton.y = int(questionButton.y + questionButton.height * .5 - supportButton.height * .5);
			supportButton.setOverflow(btnOffset, btnOffset, btnOffset, btnOffset);
			UI.destroy(icon);
			icon = null;
			echo("EmergencyScreen", "createView", "END");
		}
		
		private function onSupportButtonClick():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_911;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = this.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function onTipsTapped():void {
			QuestionsManager.setShowTipsOnly(!QuestionsManager.getShowTipsOnly());
			setListData();
		}
		
		private function onBottomButtonTap():void {
			echo("EmergencyScreen", "onBottomButtonTap", "START");
			if (selectedFilter != QuestionsManager.TAB_OTHER) {
				echo("EmergencyScreen", "onBottomButtonTap", "TAB IS NOT OTHER");
				return;
			}
			//DialogManager.showCategoriesPopup(onCategoriesSelected, true);
			echo("EmergencyScreen", "onBottomButtonTap", "START");
		}
		
		private function onCategoriesSelected(selectedCategories:Vector.<SelectorItemData>):void {
			echo("EmergencyScreen", "onCategoriesSelected", "START");
			/*if (wasFilter == false && (selectedCategories == null || selectedCategories.length == 0))
				return;*/
			if (selectedFilter != QuestionsManager.TAB_OTHER) {
				echo("EmergencyScreen", "onCategoriesSelected", "TAB IS NOT OTHER");
				return;
			}
			QuestionsManager.getFilteredQuestionsFromServer(selectedCategories);
			list.updateItemByIndex(0);
			echo("EmergencyScreen", "onCategoriesSelected", "END");
		}
		
		private function addMoreInfoButton():void {
			echo("EmergencyScreen", "addMoreInfoButton", "START");
			if (moreInfoButton == null) {
				moreInfoButton = new InfoButtonPanel();
				moreInfoButton.tapCallback = onMoreInfoClick;
				view.addChild(moreInfoButton);
				moreInfoButton.viewWidth = _width;
				moreInfoButton.setText(/*(wasFilter == true) ? QuestionsManager.getCategoriesFilterNames() : */Lang.emergencyMoreInfoButton);
			}
			if (tabs != null && tabs.view != null) {
				moreInfoButton.y = bgHeader.height;	
			}
			echo("EmergencyScreen", "addMoreInfoButton", "END");
		}
		
		private function showMoreInfoButton():void {
			echo("EmergencyScreen", "showMoreInfoButton", "START");
			if (moreInfoButton != null && moreInfoButton.isShown == true) {
				echo("EmergencyScreen", "showMoreInfoButton", "BUTTON IS NULL");
				return;
			}
			addMoreInfoButton();
			//TODO update list 
			if (list != null) {
				moreInfoButton.y = bgHeader.height;	
				var destY:int = moreInfoButton.y + moreInfoButton.height;
				TweenMax.killTweensOf(tabs.view);
				TweenMax.to(tabs.view, .2, {y:destY, ease:Quint.easeOut, onComplete:function():void{
					tabs.view.y = destY;
				}});
				TweenMax.killTweensOf(list.view);
				TweenMax.to(list.view, .2, { y:destY + Config.TOP_BAR_HEIGHT, ease:Quint.easeOut, onUpdate:onListMoved, onComplete:function():void {
						list.view.y = destY + Config.TOP_BAR_HEIGHT;
						list.setWidthAndHeight(_width, _height - list.view.y);
						onListMoved();
					}
				});
			}
			moreInfoButton.show((wasFilter == true) ? 0 : .3);
			if (_isActivated)
				moreInfoButton.activate();
			echo("EmergencyScreen", "showMoreInfoButton", "END");
		}
		
		private function hideMoreInfoButton():void {
			echo("EmergencyScreen", "hideMoreInfoButton", "START");
			if (moreInfoButton != null) {
				moreInfoButton.hide();
			}
			if (list != null) {
				var destY:int = bgHeader.height;
				TweenMax.killTweensOf(tabs.view);
				TweenMax.to(tabs.view, .4, { y:destY, delay:.3, ease:Quint.easeOut, onComplete:function():void {
					tabs.view.y = destY;
				}});
				TweenMax.killTweensOf(list.view);
					list.setWidthAndHeight(_width, _height - destY + Config.TOP_BAR_HEIGHT);
				TweenMax.to(list.view, .4, {y:destY + Config.TOP_BAR_HEIGHT, delay:.3, ease:Quint.easeOut, onUpdate:onListMoved, onComplete:function():void{
					list.view.y = destY + Config.TOP_BAR_HEIGHT;
					list.setWidthAndHeight(_width, _height - list.view.y);
				}});
			}
			echo("EmergencyScreen", "hideMoreInfoButton", "END");
		}
		
		private function onMoreInfoClick(closeClicked:Boolean = false):void {
			echo("EmergencyScreen", "onMoreInfoClick", "START");
			if (closeClicked == true) {
				hideMoreInfoButton();
				closeAndSave();
			} else
				QuestionsManager.showRules();
			echo("EmergencyScreen", "onMoreInfoClick", "END");
		}
		
		
		private function onInfoButtonClick():void {
			echo("EmergencyScreen", "onInfoButtonClick", "START");
			QuestionsManager.showRules();
			echo("EmergencyScreen", "onInfoButtonClick", "END");
		}
		
		override public function clearView():void {
			echo("EmergencyScreen", "clearView", "START");
			
			super.clearView();
			
			if (tabs != null) {
				TweenMax.killTweensOf(tabs.view);
				tabs.dispose();
				tabs = null;
			}
			/*if (tabsType != null) {
				TweenMax.killTweensOf(tabsType.view);
				tabsType.dispose();
				tabsType = null;
			}*/
			if (list != null) {
				TweenMax.killTweensOf(list.view);
				storedTabListPosition[selectedFilter].listBoxY = list.getBoxY();
				var fli:ListItem = list.getFirstVisibleItem();
				if (fli != null) {
					storedTabListPosition[selectedFilter].item = list.getFirstVisibleItem().data;
					storedTabListPosition[selectedFilter].offset = fli.y + storedTabListPosition[selectedFilter].listBoxY;
				}
				list.dispose();
				list = null;
			}
			/*if (setFilterButton)
				setFilterButton.dispose();
			setFilterButton = null;*/
			echo("EmergencyScreen", "clearView", "END");
		}
		
		override protected function drawView():void {
			echo("EmergencyScreen", "drawView", "START");
			if (_isDisposed == true) {
				echo("EmergencyScreen", "drawView", "DISPOSED");
				return;
			}
			FIT_WIDTH = _width - buttonPaddingLeft * 2;
			
			var currentYDrawPosition:int = 0;
			
			tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
			/*tabsType.setWidthAndHeight(_width * .5 - Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_5 / 66 * 100);*/
			var destY:int = bgHeader.height;
			if (moreInfoButton != null && moreInfoButton.isShown == true) {
				moreInfoButton.viewWidth = _width;
				moreInfoButton.y = bgHeader.height;	
				destY += moreInfoButton.height;
			}
			tabs.view.y = destY;
			/*tabsType.view.y = int(_height - Config.DOUBLE_MARGIN - tabsType.height * .83);
			tabsType.view.x = _width - tabsType.width;*/
			destY += tabs.height;
			list.view.y = destY;
			list.setWidthAndHeight(_width, _height - list.view.y);
			
			title.y = Config.APPLE_TOP_OFFSET + int((Config.FINGER_SIZE * .85 - title.height) * .5);
			
			title.x = Config.FINGER_SIZE;
			title.y = Config.APPLE_TOP_OFFSET + int((Config.FINGER_SIZE * .85 - title.height) * .5);
			questionButton.x = int(_width - questionButton.width - Config.MARGIN * 2);
			infoButton.x = int(questionButton.x - infoButton.width - Config.MARGIN * 2);
			supportButton.x = int(infoButton.x - supportButton.width - Config.MARGIN * 2);
			echo("EmergencyScreen", "drawView", "END");
		}
		
		override public function dispose():void {
			echo("EmergencyScreen", "dispose", "START");
			super.dispose();
			TweenMax.killDelayedCallsTo(showMoreInfoButton);
			UI.destroy(title);
			UI.destroy(bgHeader);
			
			if (backButton != null) 
				backButton.dispose();
			backButton = null;
			if (questionButton != null) 
				questionButton.dispose();
			questionButton = null;
			if (infoButton != null) 
				infoButton.dispose();
			infoButton = null;
			if (supportButton != null) 
				supportButton.dispose();
			supportButton = null;
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
			
			// Remove dialog with answers if exists, but if dialog is other ???
			DialogManager.closeDialog();
			
			//storedTabListPosition = null;
			echo("EmergencyScreen", "dispose", "END");
		}
		
		private function updateData():void {
			echo("EmergencyScreen", "updateData", "START");
			if (_isActivated == false) {
				echo("EmergencyScreen", "updateData", "DEACTIVATED");
				return;
			}
			setListData();
			echo("EmergencyScreen", "updateData", "END");
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void {
			echo("EmergencyScreen", "onUserOnlineStatusChanged", "START");
			if (_isDisposed || list == null) {
				echo("EmergencyScreen", "onUserOnlineStatusChanged", "DISPOSED OR LIST IS NULL");
				return;
			}
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS) {
				var user:ChatUserVO;
				var item:ListItem;
				var qVO:QuestionVO;
				var l:int = list.getStock().length;
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) {
					item = list.getItemByNum(j);
					if (item && item.liView && item.liView.visible) {
						if (item.data is QuestionVO) {
							qVO = item.data as QuestionVO;
							if (!qVO.isMine() && qVO.userUID == status.uid) {
								if (list.getScrolling()) {
									list.refresh();
									break;
								} else
									item.draw(list.width, !list.getScrolling());
							}
						} else if (item.data is ChatVO) {
							user = UsersManager.getInterlocutor(item.data as ChatVO);
							if (user && user.uid == status.uid) {
								if (list.getScrolling()) {
									list.refresh();
									break;
								} else
									item.draw(list.width, !list.getScrolling());
								break;
							}
						}
					} else
						break;
				}
				user = null;
				qVO = null;
				item = null;
			}
			echo("EmergencyScreen", "onUserOnlineStatusChanged", "END");
		}
		
		private function onUserlistOnlineStatusChanged():void {
			echo("EmergencyScreen", "onUserlistOnlineStatusChanged", "START");
			if (list)
				list.refresh();
			echo("EmergencyScreen", "onUserlistOnlineStatusChanged", "END");
		}
		
		private function onAllUsersOffline():void {
			echo("EmergencyScreen", "onAllUsersOffline", "START");
			if (list)
				list.refresh();
			echo("EmergencyScreen", "onAllUsersOffline", "END");
		}
		
		override public function activateScreen():void {
			echo("EmergencyScreen", "activateScreen", "START");
			super.activateScreen();
			if (_isDisposed) {
				echo("EmergencyScreen", "activateScreen", "DISPOSED");
				return;
			}
			backButton.activate();
			questionButton.activate();
			infoButton.activate();
			supportButton.activate();
			
			if (moreInfoButton != null)
				moreInfoButton.activate();
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				list.S_ITEM_HOLD.add(onItemHold);
				list.S_STOPED.add(onScrollStopped);
				list.S_MOVING.add(onListMoved);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			/*if (tabsType != null) {
				if (tabsType.S_ITEM_SELECTED != null)
					tabsType.S_ITEM_SELECTED.add(onTabTypeItemSelected);
				tabsType.activate();
			}*/
			if (btnShowHideTips != null)
				btnShowHideTips.activate();
			/*if (setFilterButton != null)
				setFilterButton.activate();*/
			QuestionsManager.S_QUESTIONS.add(updateData);
			QuestionsManager.S_QUESTION.add(updateQuestion);
			AnswersManager.S_QUESTION_ANSWERS.add(updateQuestion);
			QuestionsManager.S_QUESTIONS_FILTERED.add(updateData);
			QuestionsManager.S_FILTER_CLEARED.add(updateData);
			AnswersManager.S_ANSWERS.add(onAnswersLoaded);
			//QuestionsManager.S_NEW.add(onNew);
			
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
			UsersManager.S_TOAD_UPDATED.add(refreshList);
			
			if (PaidBan.isAvaliable()) {
				PaidBan.S_USER_BAN_UPDATED.add(onUserBanChange);
			}
			
			setListData();
			echo("EmergencyScreen", "activateScreen", "END");
		}
		
		private function onUserBanChange(userUID:String = null):void {
			refreshList();
		}
		
		/*private function onTabTypeItemSelected(id:String):void {
			QuestionsManager.setShowTipsOnlyPublic(id == QuestionsManager.TAB_OTHER);
			setListData();
		}*/
		
		private function refreshList():void {
			list.refresh();
		}
		
		private function onListMoved(...rest):void {
			if (selectedFilter != QuestionsManager.TAB_OTHER)
				return;
			if (list == null || followItem == null)
				return;
			if (QuestionsManager.getShowTipsOnly() == true) {
				if (list.getBoxY() > 0)
					list.setBGColorOnly(0xFFFFFF);
				else
					list.setBGColorOnly(0xF6F7F2);
				return;
			}
			btnShowHideTips.y = followItem.y + followItem.height + list.getBoxY() + list.view.y - btnShowHideTips.height * .5;
		}
		
		/*private function onNew():void {
			if (setFilterButton == null)
				return;
			if (setFilterButton.visible == false)
				return;
			setFilterButton.startWiggle();
			TweenMax.killDelayedCallsTo(stopWiggle);
			TweenMax.delayedCall(5, stopWiggle)
		}*/
		
		/*private function stopWiggle():void {
			if (setFilterButton == null)
				return;
			setFilterButton.stopWiggle();
		}*/
		
		private function onAnswersLoaded():void {
			echo("EmergencyScreen", "onAnswersLoaded", "START");
			if (selectedFilter != QuestionsManager.TAB_RESOLVED) {
				echo("EmergencyScreen", "onAnswersLoaded", "DISPOSED");
				return;
			}
			setListData();
			echo("EmergencyScreen", "onAnswersLoaded", "END");
		}
		
		private function updateQuestion(qVO:QuestionVO):void {
			echo("EmergencyScreen", "updateQuestion", "START");
			if (_isActivated == false) {
				echo("EmergencyScreen", "updateQuestion", "DEACTIVATED");
				return;
			}
			if (list == null) {
				echo("EmergencyScreen", "updateQuestion", "LIST IS NULL");
				return;
			}
			if (list.data == null) {
				echo("EmergencyScreen", "updateQuestion", "LIST DATA IS NULL");
				return;
			}
			if (list.getScrolling() == true) {
				needToRefreshAfterScrollStoped = true;
				echo("EmergencyScreen", "updateQuestion", "LIST SCROLLING");
				return;
			}
			list.updateItem(qVO);
			echo("EmergencyScreen", "updateQuestion", "END");
		}
		
		override public function deactivateScreen():void {
			echo("EmergencyScreen", "deactivateScreen", "START");
			super.deactivateScreen();
			if (_isDisposed) {
				echo("EmergencyScreen", "deactivateScreen", "DEACTIVATED");
				return;
			}
			backButton.deactivate();
			questionButton.deactivate();
			infoButton.deactivate();
			supportButton.deactivate();
			if (moreInfoButton != null)
				moreInfoButton.deactivate();
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
				list.S_ITEM_HOLD.remove(onItemHold);
				list.S_STOPED.remove(onScrollStopped);
				list.S_MOVING.remove(onListMoved);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			/*if (tabsType != null) {
				if (tabsType.S_ITEM_SELECTED != null)
					tabsType.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabsType.deactivate();
			}*/
			if (btnShowHideTips != null)
				btnShowHideTips.deactivate();
			/*if (setFilterButton != null)
				setFilterButton.deactivate();*/
			QuestionsManager.S_QUESTIONS.remove(updateData);
			QuestionsManager.S_QUESTION.remove(updateQuestion);
			AnswersManager.S_QUESTION_ANSWERS.remove(updateQuestion);
			AnswersManager.S_ANSWERS.remove(onAnswersLoaded);
			//QuestionsManager.S_NEW.remove(onNew);
			
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			UsersManager.S_TOAD_UPDATED.remove(refreshList);
			
			PaidBan.S_USER_BAN_UPDATED.remove(onUserBanChange);
			echo("EmergencyScreen", "deactivateScreen", "END");
		}
		
		private function onItemHold(data:Object, n:int):void {
			echo("EmergencyScreen", "onItemHold", "START");
			if (!(data is ChatVO)) {
				echo("EmergencyScreen", "onItemHold", "DATA IS NOT CHATVO");
				return;
			}
			var menuItems:Array = [];
			var chatVO:ChatVO = data as ChatVO;
			
			menuItems.push( { fullLink:Lang.deleteChat, id:0 } );
			
			if (menuItems.length == 0)
				return;
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
				echo("EmergencyScreen", "onItemHold::DialogCallback", "START");
				if (data.id == 0) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmLeaveConversation, function(val:int):void {
						if (val != 1) {
							echo("EmergencyScreen", "onItemHold::DialogCallback", "VAL != 1");
							return;
						}
						ChatManager.removeUser(chatVO.uid);
						echo("EmergencyScreen", "onItemHold::DialogCallback", "END");
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
			}, data:menuItems, itemClass:ListLink, title:chatVO.title, multilineTitle:false } );
			echo("EmergencyScreen", "onItemHold", "END");
		}
		
		private function onScrollStopped(val:Number):void {
			echo("EmergencyScreen", "onScrollStopped", "START");
			if (_isActivated == false) {
				echo("EmergencyScreen", "onScrollStopped", "DEACTIVATED");
				return;
			}
			if (needToRefreshAfterScrollStoped == false) {
				echo("EmergencyScreen", "onScrollStopped", "DO NOT REFRESH");
				return;
			}
			needToRefreshAfterScrollStoped = false;
			setListData();
			echo("EmergencyScreen", "onScrollStopped", "END");
		}
		
		private function showTabs(value:Boolean):void {
			echo("EmergencyScreen", "showTabs", "START");
			tabs.view.visible = value;
			list.view.y = (tabs.view.visible) ? tabs.height : 0;
			list.setWidthAndHeight(_width, _height - list.view.y);
			echo("EmergencyScreen", "showTabs", "END");
		}
		
		private function onTabItemSelected(id:String):void {
			echo("EmergencyScreen", "onTabItemSelected", "START");
			//setButtonDesign(id);
			if (btnShowHideTips != null && btnShowHideTips.parent != null)
				btnShowHideTips.parent.removeChild(btnShowHideTips);
			/*if (tabsType != null && tabsType.view.parent != null)
				tabsType.view.parent.removeChild(tabsType.view);*/
			if (id != QuestionsManager.TAB_OTHER)
				hideMoreInfoButton();
			else if (wasFilter)
				showMoreInfoButton();
			needToRedrawButtonTips = true;
			setListData(id);
			selectedFilter = id;
			list.setBGColorOnly(0xFFFFFF);
			echo("EmergencyScreen", "onTabItemSelected", "END");
		}
		
		override public function drawViewLang():void {
			if (tabs != null)
				tabs.updateLabels( [ Lang.textAll, Lang.textMine, Lang.questionsResolved ] );
			/*if (tabsType != null)
				tabsType.updateLabels( [ Lang.textAll, Lang.textQuestionTypePublic ] );*/
			if (moreInfoButton != null)
				moreInfoButton.setText(Lang.emergencyMoreInfoButton);
			super.drawViewLang();
		}
		
		/*private function setButtonDesign(id:String):void {
			echo("EmergencyScreen", "setButtonDesign", "START");
			if (id == QuestionsManager.TAB_OTHER) {
				setFilterButton.visible = true;
				echo("EmergencyScreen", "setButtonDesign", "TAB OTHER");
				return;
			}
			setFilterButton.visible = false;
			echo("EmergencyScreen", "setButtonDesign", "END");
		}*/
		
		private function setListData(id:String = ""):void {
			echo("EmergencyScreen", "setListData", "START");
			if (list == null) {
				echo("EmergencyScreen", "setListData", "LIST IS NULL");
				return;
			}
			if (list.getScrolling() == true) {
				needToRefreshAfterScrollStoped = true;
				echo("EmergencyScreen", "setListData", "LIST SCROLLING");
				return;
			}
			
			if (id == "")
				id = selectedFilter;
			
			// Save list position
			if (needToUpdateListPosition == true) {
				storedTabListPosition[selectedFilter].listBoxY = list.getBoxY();
				var fli:ListItem = list.getFirstVisibleItem();
				if (fli != null) {
					storedTabListPosition[selectedFilter].item = list.getFirstVisibleItem().data;
					storedTabListPosition[selectedFilter].offset = fli.y + storedTabListPosition[selectedFilter].listBoxY;
				}
			}
			
			var listItemClass:Class = ListQuestionRenderer;
			var listData:Array;
			if (id == QuestionsManager.TAB_RESOLVED) {
				listData = AnswersManager.getAllAnswers();
				listItemClass = ListConversation;
			} else {
				if (id == QuestionsManager.TAB_OTHER)
					listData = QuestionsManager.getNotResolved();
				else if (id == QuestionsManager.TAB_MINE)
					listData = QuestionsManager.getMine();
				if (listData == null)
					listData = [];
			}
			
			list.setData(listData, listItemClass, ["avatarURL"]);
			
			if (list.scrollToItem(null, storedTabListPosition[id].item, storedTabListPosition[id].offset) == false)
				list.setBoxY(storedTabListPosition[id].listBoxY);
			list.setContextAvaliable(true);
			
			checkForTipsButtonNeeded(id);
			
			needToUpdateListPosition = true;
			echo("EmergencyScreen", "setListData", "END");
		}
		
		private function checkForTipsButtonNeeded(id:String = ""):void {
			if (id != QuestionsManager.TAB_OTHER || QuestionsManager.getLastTipsQUID() == null) {
				if (btnShowHideTips != null && btnShowHideTips.parent != null)
					view.removeChild(btnShowHideTips);
				return;
			}
			followItem = list.getItemByNum(1);
			if (followItem.data.uid != QuestionsManager.getLastTipsQUID())
				followItem = list.getItemByNum(2);
			if (btnShowHideTips == null) {
				var icon:Sprite = new SWFDoubleArrowsDown();
				UI.scaleToFit(icon, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5);
				btnShowHideTipsDownBMD = UI.getSnapshot(icon, StageQuality.HIGH, "EmergencyScreen.tipsDown");
				icon = new SWFDoubleArrowsUp();
				UI.scaleToFit(icon, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5);
				btnShowHideTipsUpBMD = UI.getSnapshot(icon, StageQuality.HIGH, "EmergencyScreen.tipsUp");
				
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
				/*if (tabsType != null) {
					tabsType.activate();
					if (tabsType.view.parent == null)
						_view.addChild(tabsType.view);
				}*/
				return;
			}
			if ((btnShowHideTips.currentBitmapData != btnShowHideTipsDownBMD)) {
				btnShowHideTips.setBitmapData(btnShowHideTipsDownBMD);
				btnShowHideTips.show(.3);
				onListMoved();
				list.setBGColorOnly(0xFFFFFF);
				/*if (tabsType != null) {
					tabsType.deactivate();
					if (tabsType.view.parent != null)
						tabsType.view.parent.removeChild(tabsType.view);
				}*/
			}
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("EmergencyScreen", "onItemTap", "START");
			
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			if (item)
				itemHitZone = item.getLastHitZone();
			if (data is ChatVO) {
				if (itemHitZone && itemHitZone == HitZoneType.DELETE) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmLeaveConversation, function(val:int):void {
						echo("EmergencyScreen", "onItemTap::Dialog_1_Callback", "START");
						if (val != 1) {
							echo("EmergencyScreen", "onItemTap::Dialog_1_Callback", "VAL != 1");
							return;
						}
						ChatManager.removeUser((data as ChatVO).uid);
						echo("EmergencyScreen", "onItemTap::Dialog_1_Callback", "END");
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					echo("EmergencyScreen", "onItemTap", "DATA IS CHATVO AND HITZONE IS DELETE");
					return;
				}
				
				var chatScreenData:ChatScreenData = new ChatScreenData();
				chatScreenData.chatVO = data as ChatVO;
				chatScreenData.type = ChatInitType.CHAT;
				chatScreenData.backScreen = EmergencyScreen;
				MobileGui.showChatScreen(chatScreenData);
				echo("EmergencyScreen", "onItemTap", "DATA IS CHATVO");
				return;
			}
			var qVO:QuestionVO = data as QuestionVO;
			if (qVO.uid == null || qVO.uid == "") {
				if (itemHitZone == HitZoneType.QUESTION_INFO) {
					onInfoButtonClick();
					return;
				}
				if (QuestionsManager.checkForUnsatisfiedQuestions() == true) {
					DialogManager.alert(Lang.information, Lang.limitQuestionExists);
					echo("EmergencyScreen", "onItemTap", "START QUESTION FAIL LIMIT");
					return;
				}
				MobileGui.changeMainScreen(QuestionCreateUpdateScreen, {
					backScreen:MobileGui.centerScreen.currentScreenClass,
					title:Lang.addTender, 
					data:null
				}, ScreenManager.DIRECTION_RIGHT_LEFT);
				echo("EmergencyScreen", "onItemTap", "START QUESTION");
				return;
			}
			if (qVO.isRemoving == true)
				return;
			if (itemHitZone) {
				if (itemHitZone == HitZoneType.DELETE) {
					DialogManager.alert(Lang.confirm, Lang.alertConfirmDeleteQuestion, function(val:int):void {
						echo("EmergencyScreen", "onItemTap::Dialog_2_Callback", "START");
						if (val != 1) {
							echo("EmergencyScreen", "onItemTap::Dialog_2_Callback", "VAL != 1");
							return;
						}
						QuestionsManager.close(qVO.uid);
						list.updateItemByIndex(n);
						echo("EmergencyScreen", "onItemTap::Dialog_2_Callback", "END");
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					echo("EmergencyScreen", "onItemTap", "DATA IS QUESTIONVO AND HITZONE IS DELETE");
					return;
				}
				if (itemHitZone == HitZoneType.QUESTION_INFO) {
					/*if (QuestionsManager.getCategoriesFilterNames() == "")
						QuestionsManager.showRules();
					else*/
						onBottomButtonTap();
					echo("EmergencyScreen", "onItemTap", "DATA IS QUESTIONVO AND HITZONE IS QUESTION_INFO");
					return;
				}
				if (itemHitZone == HitZoneType.TIPS) {
					DialogManager.alert(Lang.information, qVO.tipsAmount + " " + qVO.tipsCurrency + Lang.textAdditionalTips);
					echo("EmergencyScreen", "onItemTap", "DATA IS QUESTIONVO AND HITZONE IS TIPS");
					return;
				}
			}
			if (qVO.userUID != Auth.uid) {
				AnswersManager.answer(qVO);
				echo("EmergencyScreen", "onItemTap", "START ANSWER");
				return;
			}
			if (qVO.answersCount > 0) {
				if (qVO.type == null || qVO.type == QuestionsManager.QUESTION_TYPE_PRIVATE) {
					AnswersManager.getAnswersByQuestionUID(qVO.uid);
					echo("EmergencyScreen", "onItemTap", "GET ANSWERS");
				} else if (qVO.type == QuestionsManager.QUESTION_TYPE_PUBLIC) {
					AnswersManager.answer(qVO);
					echo("EmergencyScreen", "onItemTap", "OPEN ANSWERS CHANNEL");
				}
				return;
			}
			if (qVO.status == "resolved" || qVO.status == "closed") {
				AnswersManager.getAnswersByQuestionUID(qVO.uid);
			}
			if (qVO.status != "created" && qVO.status != "edited") {
				echo("EmergencyScreen", "onItemTap", "INCORRECT STATUS");
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
			echo("EmergencyScreen", "onItemTap", "END");
		}
	}
}