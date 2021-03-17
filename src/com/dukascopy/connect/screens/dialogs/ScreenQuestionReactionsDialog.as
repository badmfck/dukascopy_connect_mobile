package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ChatUserReactionAllRenderer;
	import com.dukascopy.connect.gui.list.renderers.ChatUserReactionMineRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.utils.Animator;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.chat.QuestionUserReactions;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ScreenQuestionReactionsDialog extends BaseScreen {
		
		private var list:List;
		private var topIBD:ImageBitmapData;	
		private var topBox:Sprite;
		private var closeBtn:BitmapButton;
		private var bar:Bitmap = new Bitmap(new BitmapData(1, Config.FINGER_SIZE * .06, false, AppTheme.RED_MEDIUM));
		private var messageBox:Bitmap;
		private var titleTF:TextFormat;
		private var loadedFromPHP:Boolean = false;
		private var hiddenOnLoad:Boolean = false;
		private const PROGRESS_SEC:int = 3;
		private const PROGRESS_TIMEOUT_SEC:int = 8;
		static public const FILTER_MINE:String = "filterMine";
		static public const FILTER_ALL:String = "filterAll";
		private var qUID:String;
		private var chatUID:String;
		private var tabs:FilterTabs;
		private var selectedFilter:String;
		private var sortText:Bitmap;
		private var currentData:Vector.<QuestionUserReactions>;
		private var lastSort:String;
		private var updateTimeout:Number = 10;
		private var animator:Animator;
		private var topBoxText:Sprite;
		private var lastSelectedReaction:QuestionUserReactions;
		private var currentGiftData:GiftData;
		
		public function ScreenQuestionReactionsDialog() { }
		
		override protected function createView():void {
			super.createView();				
			
			selectedFilter = FILTER_MINE;
			
			list = new List("Reactions");
			list.setMask(true);
			list.view.y = Config.FINGER_SIZE;
			_view.addChild(list.view);
			
			topBox = new Sprite();
			_view.addChild(topBox);			
			
			topBoxText = new Sprite();
			topBox.addChild(topBoxText);
			
			closeBtn = new BitmapButton();
			closeBtn.setBitmapData(UI.renderAsset(new SWFCloseIconThin(), Config.FINGER_SIZE_DOT_35, Config.FINGER_SIZE_DOT_35, true, "ScreenPayDialog.closeBtn"));
			closeBtn.setOverflow(Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_25);
			closeBtn.setStandartButtonParams();
			_view.addChild(closeBtn);
			closeBtn.show();
			closeBtn.tapCallback = onCloseBtnClick;
			
			titleTF = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25, AppTheme.GREY_DARK, false);
			
			_view.addChild(bar);
			
			tabs = new FilterTabs();
			tabs.add(Lang.textMine, FILTER_MINE, true, FilterTabs.LEFT);
			tabs.add(Lang.textAll, FILTER_ALL, false, FilterTabs.RIGHT);
			_view.addChild(tabs.view);
			tabs.view.visible = false;
			
			sortText = new Bitmap();
			_view.addChild(sortText);
			sortText.visible = false;
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);		
			
			_params.title = data.label;			
			var maxHeight:int = _height - Config.FINGER_SIZE*3;		
			if (list.innerHeight > maxHeight)
				list.setWidthAndHeight(_width, maxHeight);
			else 
				list.setWidthAndHeight(_width, list.innerHeight);
			
			updateBar();
			
			if (data != null && "qUID" in data && data.qUID != null) {
				qUID = data.qUID;
			} else {
				qUID = ChatManager.getCurrentChat().questionID;
			}
			
			if (data != null && "chatUID" in data && data.chatUID != null) {
				chatUID = data.chatUID;
			} else {
				chatUID = ChatManager.getCurrentChat().uid;
			}
			
			sortText.bitmapData = TextUtils.createTextFieldData(Lang.sortBy, _width - Config.DOUBLE_MARGIN * 2, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0xA5AFB8, 0xFFFFFF, true);
			
			ChannelsManager.S_TOP_REACTIONS_LOADED_FROM_PHP.add(onReactionsLoadedFromPHP);
			ChannelsManager.getQuestionTopReactions(chatUID);
		}
		
		private function updateBar():void {		
			if (bar != null){				
				var messageBoxHeight:int = messageBox!=null?messageBox.height:0; 
				var trueHeight:int = list.height + Config.FINGER_SIZE+messageBoxHeight;
				var trueY:int = int((_height - trueHeight) * .5)
				bar.y = trueY + Config.FINGER_SIZE;
				_view.addChild(bar);				
				if (loadedFromPHP){
					if(!hiddenOnLoad){
						TweenMax.killTweensOf(bar);
						TweenMax.to(bar, .3, {width:_width,onComplete:hidePreloader});
					}
				}else{					
					TweenMax.to(bar, PROGRESS_SEC, {width:_width-100,onComplete:startTimeoutTween});
				}				
			}
		}
		
		private function hidePreloader():void {
			hiddenOnLoad = true;
			TweenMax.killTweensOf(bar);
			TweenMax.to(bar, .3, {height:0});
		}
		
		/**
		 * Was not synced in first 3 seconds , 
		 * lets wait more 8 sec, 
		 * if fails then hide preloader 
		 */
		private function startTimeoutTween():void {
			TweenMax.to(bar,PROGRESS_TIMEOUT_SEC, {width:_width,onComplete:onPreloadTimeout});
		}
		
		/**
		 * Cannot sync answers so hide preloader
		 */
		private function onPreloadTimeout():void {			
			loadedFromPHP = true;
			updateBar();	
		}
		
		private function showMessageBox(txt:String):void {	
			if (_isDisposed) return;
			if (txt != ""){
				if (messageBox == null){
					messageBox = new Bitmap();
				}						
				UI.disposeBMD(messageBox.bitmapData);
				messageBox.bitmapData = UI.renderTextPlane(txt, _width,8, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT,Config.FINGER_SIZE*.26, true, AppTheme.RED_MEDIUM, AppTheme.GREY_LIGHT, AppTheme.GREY_LIGHT, 0, 0, 15, 10);
				_view.addChild(messageBox);				
			}else{
				if (messageBox != null)
					UI.disposeBMD(messageBox.bitmapData);
			}			
			drawView();
		}
		
		/**
		 * Load From PHP Handler 
		 * @param	phpRespond
		 */
		private function onReactionsLoadedFromPHP(reactions:Vector.<QuestionUserReactions>, questionUID:String):void {
			if (questionUID == chatUID && isDisposed == false) {
				ChannelsManager.S_TOP_REACTIONS_LOADED_FROM_PHP.remove(onReactionsLoadedFromPHP);
				showMessageBox("");
				loadedFromPHP = true;
				if (reactions != null && reactions.length > 0) {
					currentData = reactions;
					tabs.view.visible = true;
					sortText.visible = true;
					updateListData();
				}
			}
			
			TweenMax.delayedCall(updateTimeout, updateData);
		}
		
		private function updateData():void 
		{
			ChannelsManager.getQuestionTopReactions(chatUID);
			TweenMax.killDelayedCallsTo(updateData);
		}
		
		private function onCloseBtnClick():void {
			ServiceScreenManager.closeView();			
		}
		
		override public function activateScreen():void{
			super.activateScreen();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			if (closeBtn != null) {
				closeBtn.activate();
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
		}
		
		override public function deactivateScreen():void{
			super.deactivateScreen();
			list.deactivate();
			list.S_ITEM_TAP.remove(onItemTap);
			if (closeBtn != null) {
				closeBtn.deactivate();
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
		}
		
		private function onTabItemSelected(id:String):void {			
			echo("ScreenQuestionReactionsDialog", "onTabItemSelected", "");
			selectedFilter = id;
			
			updateListData();
		}
		
		private function updateListData():void 
		{
			if (currentData != null) {
				if (lastSort != selectedFilter)
				{
					lastSort = selectedFilter;
					currentData = currentData.sort(sortDataFunction);
				}
				var renderClass:Class;
				if (lastSort == FILTER_MINE) {
					renderClass = ChatUserReactionMineRenderer;
				}
				else {
					renderClass = ChatUserReactionAllRenderer;
				}
				list.setData(currentData, renderClass, ["avatar"]);
				drawView();
			}
		}
		
		private function sortDataFunction(a:QuestionUserReactions, b:QuestionUserReactions):int 
		{
			if (lastSort == FILTER_ALL) {
				if (a.all > b.all) {
					return -1;
				}
				else if (a.all < b.all) {
					return 1;
				}
				else {
					return 0;
				}
			}
			else if(lastSort == FILTER_MINE) {
				if (a.mine > b.mine) {
					return -1;
				}
				else if (a.mine < b.mine) {
					return 1;
				}
				else {
					return 0;
				}
			}
			return 0;
		}
		
		private function onItemTap(dataObject:Object, n:int):void {
			if (!dataObject is QuestionUserReactions)
				return;
			
			var currentQuestion:QuestionVO = QuestionsManager.getQuestionByUID(qUID);
			
			if (currentQuestion != null && currentQuestion.userUID == Auth.uid && currentQuestion.isPaid == false) {
				var reaction:QuestionUserReactions = dataObject as QuestionUserReactions;
				
				lastSelectedReaction = reaction;
				
				if (currentQuestion != null) {
					
					var giftData:GiftData = new GiftData();
					giftData.currency = currentQuestion.tipsCurrency;
					giftData.customValue = currentQuestion.tipsAmount;
					giftData.type = GiftType.FIXED_TIPS;
					giftData.chatUID = chatUID;
					giftData.recieverSecret = reaction.secretMode;
					
					var rawUserData:Object = { };
					rawUserData.uid = reaction.uid;
					rawUserData.avatar = reaction.avatar;
					rawUserData.username = reaction.username;
					
					var user:UserVO = UsersManager.getUserByChatUserObject(rawUserData);
					giftData.user = user;
					
					currentGiftData = giftData;
					
					if (currentQuestion.needPayBeforeClose == true)
					{
						Gifts.startSendMoney(giftData);
						ServiceScreenManager.closeView();
					}
					else
					{
						var userName:String = "";
						if (lastSelectedReaction != null)
						{
							userName = lastSelectedReaction.username;
						}
						DialogManager.alert(Lang.selectWinner, Lang.winnerConfirm + " " + userName + "?", onWinnerConfirm, Lang.textOk, Lang.CANCEL);
					}
				}
			}
		}
		
		private function onWinnerConfirm(val:int):void 
		{
			if (currentGiftData == null)
			{
				return;
			}
			if (val == 1) {
				var chatVO:ChatVO;
				
				if (ChatManager.getCurrentChat() != null &&	ChatManager.getCurrentChat().uid == currentGiftData.chatUID) {
					chatVO = ChatManager.getCurrentChat();
				}
				
				if (chatVO == null) {
					chatVO = ChannelsManager.getChannel(currentGiftData.chatUID);
				}
				ChatManager.S_LOAD_START.invoke();
				QuestionsManager.closePublicAnswer(chatVO, currentGiftData.user.uid, QuestionsManager.STATUS_ACCEPTED, currentGiftData);
				ServiceScreenManager.closeView();
			}
		}
		
		override protected function drawView():void {
			var maxHeight:int = _height - Config.FINGER_SIZE*3;
			
			//search.width = _width;
			if (list.innerHeight > maxHeight)
				list.setWidthAndHeight(_width, maxHeight);
			else 
				list.setWidthAndHeight(_width, list.innerHeight);
			
			topBox.graphics.clear();
			topBox.graphics.beginFill(AppTheme.WHITE);
			topBox.graphics.drawRect(0, 0, _width, Config.FINGER_SIZE);
			topBox.graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
			topBox.graphics.drawRect(Config.DOUBLE_MARGIN, Config.FINGER_SIZE-2, _width-Config.DOUBLE_MARGIN*2, 2);
			//topBox.graphics.drawRoundRectComplex(0, 0, _width, Config.FINGER_SIZE, Config.MARGIN, Config.MARGIN, 0, 0);
			topBox.graphics.endFill();
			
			if (topIBD != null && topIBD.isDisposed == false)
				topIBD.dispose();
			topIBD = null;
			topIBD = ImageManager.drawTextFieldToGraphic(topBoxText.graphics, Config.DOUBLE_MARGIN, Config.MARGIN * 2.5, _params.title.toLocaleUpperCase(), _width - Config.DOUBLE_MARGIN, titleTF);
			
			var messageBoxHeight:int = messageBox!=null?messageBox.height:0; 
			var trueHeight:int = list.height + Config.FINGER_SIZE+messageBoxHeight;
			var trueY:int = int((_height - trueHeight) * .5);
			if (messageBox != null){
				messageBox.y = trueY + Config.FINGER_SIZE;
			}
			
			view.graphics.clear();
			view.graphics.beginFill(0xFfffff);
			view.graphics.drawRect(0, trueY, _width, list.height + Config.FINGER_SIZE);
			//view.graphics.drawRoundRect(0, trueY, _width, list.height + Config.FINGER_SIZE, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			view.graphics.endFill();
			
			/*TweenMax.killTweensOf(topBox);
			if (topBox.y == 0) {
				topBox.y = trueY;
			}
			else {
				TweenMax.to(topBox, 0.5, { y:trueY } );
			}*/
			
			topBox.y = trueY;
			
			tabs.setWidthAndHeight(_width * .5, Config.TOP_BAR_HEIGHT);
			tabs.view.y = trueY + Config.FINGER_SIZE + messageBoxHeight;
			tabs.view.x = _width - tabs.view.width;
			
			sortText.x = Config.DOUBLE_MARGIN;
			sortText.y = int(tabs.view.y + tabs.height * .5 - sortText.height * .5);
			
			list.view.y = tabs.view.y + tabs.height;
			list.tapperInstance.setBounds();
			
			closeBtn.x = _width - closeBtn.width - closeBtn.LEFT_OVERFLOW;
			closeBtn.y = trueY + (Config.FINGER_SIZE - closeBtn.height) * .5;
			
			updateBar();
			
			var currentQuestion:QuestionVO = QuestionsManager.getQuestionByUID(qUID);
			if (currentQuestion != null && currentQuestion.userUID == Auth.uid && currentQuestion.isPaid == false) {
				startHeaderBlink();
			}
		}
		
		private function startHeaderBlink():void 
		{
			if (animator == null) {
				animator = new Animator(topBoxText);
				animator.start();
			}
		}
		
		override public function dispose():void{
			super.dispose();
			ChannelsManager.S_TOP_REACTIONS_LOADED_FROM_PHP.remove(onReactionsLoadedFromPHP);
			if (animator != null) {
				animator.dispose();
			}
			if (messageBox != null){
				UI.destroy(messageBox);
				messageBox = null;
			}
			if (bar != null){
				TweenMax.killTweensOf(bar);
				UI.destroy(bar);
				bar = null;
			}
			if (list != null) {
				list.dispose();			
				list = null;
			}
			if (topIBD != null) {
				topIBD.disposeNow();
			}
			titleTF = null;
			if (closeBtn != null) {
				closeBtn.deactivate();
				closeBtn.dispose();
				closeBtn = null;
			}
			if (tabs != null) {
				tabs.dispose();
				tabs = null;
			}
			if (sortText != null) {
				UI.destroy(sortText);
				sortText = null;
			}
			if (topBoxText != null) {
				UI.destroy(topBoxText);
				topBoxText = null;
			}
			currentData = null;
			currentGiftData = null;
			lastSelectedReaction = null;
			
			TweenMax.killDelayedCallsTo(updateData);
		}
	}
}