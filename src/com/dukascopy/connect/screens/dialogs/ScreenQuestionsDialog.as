package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Ease;
	import com.greensock.easing.Power1;
	import com.greensock.easing.Sine;
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
	
	public class ScreenQuestionsDialog extends ListSelectionPopup {
		
		private var messageBox:Bitmap;
		private var loadedFromPHP:Boolean = false;
		private var hiddenOnLoad:Boolean = false;
		private const PROGRESS_SEC:int = 3;
		private const PROGRESS_TIMEOUT_SEC:int = 8;
		private var items:Array;
		private var preloader:HorizontalPreloader;
		
		public function ScreenQuestionsDialog() { }
		
		override protected function createView():void {
			super.createView();
			
			preloader = new HorizontalPreloader();
			container.addChild(preloader);
		}
		
		override public function initScreen(data:Object = null):void{
			QuestionsManager.answersDialogOpened = true;
			preloader.setSize(_width, int(Config.FINGER_SIZE * .08));
			super.initScreen(data);			
			
			preloader.y = headerHeight;
			ChatManager.S_CHAT_UPDATED.add(onChatUpdated);
			QuestionsManager.S_QUESTION.add(onQuestionCreated);			
			AnswersManager.S_ANSWERS_LOADED_FROM_PHP.add(onAnswersLoadedFromPHP);
		}
		
		override protected function getHeight():int 
		{
			return int(Math.max(Config.FINGER_SIZE * 1.5, super.getHeight()));
		}
		
		override protected function setInitialData():void 
		{
			preloader.start();
			if (data != null && "items" in data && data.items != null)
			{
				items = parseAnswers(data.items);
				if (items != null && items.length > 0)
				{
					drawList(ListConversation, items);
				}
				else
				{
					showMessageBox(Lang.loading);
				}
			}
		}
		
		private function showMessageBox(txt:String):void {	
			if (_isDisposed) return;
			if (txt != ""){
				if (messageBox == null){
					messageBox = new Bitmap();
				}						
				UI.disposeBMD(messageBox.bitmapData);
				messageBox.bitmapData = TextUtils.createTextFieldData(txt, _width - Config.DIALOG_MARGIN * 2, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.CENTER, FontSize.BODY, true, Style.color(Style.COLOR_TEXT));
				container.addChild(messageBox);	
				messageBox.x = int(_width * .5 - messageBox.width * .5);
				messageBox.y = int((getHeight() - headerHeight) * .5 - messageBox.height * .5) + headerHeight;
			}		
		}
		
		/**
		 * Load From PHP Handler 
		 * @param	phpRespond
		 */
		private function onAnswersLoadedFromPHP(phpRespond:PHPRespond):void {
			preloader.stop();
			if (isDisposed)
			{
				return;
			}
			if (phpRespond.additionalData == null)
				return;
			if (_data.qUID == phpRespond.additionalData.qUID) {
				loadedFromPHP = true;
				if (phpRespond.error == true) {
					showMessageBox(Lang.errorAnswersLoading);
					return;
				}
				if (phpRespond.data == null) {
					removeMessage();
					return;
				}
				if ("answers" in phpRespond.data && phpRespond.data.answers.length > 0) {	
					items  = parseAnswers(phpRespond.data.answers);
					drawList(ListConversation, items);
					animateShow(0.3, Power1.easeInOut);
					removeMessage()
				} else {
					showMessageBox(Lang.answerAreEmpty);
					list.setData(null, null);
				}
			}
		//	phpRespond.dispose();
		}
		
		private function removeMessage():void 
		{
			if (messageBox != null)
			{
				if (messageBox.parent != null)
				{
					messageBox.parent.removeChild(messageBox);
				}
				UI.destroy(messageBox);
				messageBox = null;
			}
		}
		
		/**
		 * New Question created Handler
		 * @param	qVO
		 */
		private function onQuestionCreated(qVO:QuestionVO):void {
			if (isDisposed)
			{
				return;
			}
			if (_data.qUID == qVO.uid){
				// TODO rethink this, because it toggles dialog window once again instad of just receive new data of answers
				//QuestionsManager.getAnswersByQuestionUID(qVO.uid);
				loadedFromPHP  = false;
				hiddenOnLoad = false;
				AnswersManager.loadAnswersFromPHP(qVO.uid);
			}
		}
		
		private function onChatUpdated(chatVO:ChatVO):void {
			echo("ScreenQuestionsDialog", "onChatUpdated", "");		
			if (_isDisposed)
				return;
				
			var hasChanges:Boolean = false;
			var listDataItem:ChatVO;	
			for (var i:int = 0; i < items.length; i++) {
				listDataItem = items[i];
				if (listDataItem != null){					
					if (listDataItem.uid == chatVO.uid){
						items[i] = chatVO;
						hasChanges = true;
					}
				}
			}			
			
			if(list!=null && hasChanges){
				drawList(ListConversation, items);
				animateShow(0.3, Power1.easeInOut);
			}
		}
		
		static private function parseAnswers(answersArrayData:Array = null):Array {
			var answers:Array = [];
			if (answersArrayData != null && answersArrayData.length > 0) {
				var cVO:ChatVO;
				var answerVO:Object;
				var sourceVO:Object;
				for (var i:int = 0; i < answersArrayData.length; i++) {
					cVO = ChatManager.getChatByUID(answersArrayData[i].uid);
					if (cVO != null)
						cVO.setData(answersArrayData[i]);
					else
						cVO = new ChatVO(answersArrayData[i]);
					answers.push(cVO);
				}
			}
			return answers;
		}
		
		override protected function onItemTap(dataObject:Object, n:int):void {
			if (!dataObject is ChatVO)
				return;
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			if (item)
				itemHitZone = item.getLastHitZone();
			if (itemHitZone == HitZoneType.DELETE) {
				var qVO:QuestionVO = QuestionsManager.getQuestionByUID(dataObject.questionID);
				if (qVO == null)
					return;
				var incognito:Boolean = (qVO.userUID == Auth.uid && qVO.incognito == true);
				QuestionsManager.complain(qVO.uid, dataObject.uid, dataObject.chatSecurityKey, QuestionsManager.COMPLAIN_STOP, "chat", incognito);
				return;
			}
			if (ChatManager.getCurrentChat() != null &&
				ChatManager.getCurrentChat().uid == dataObject.uid &&
				MobileGui.centerScreen.currentScreenClass is ChatScreen) {
					return;
			}
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.chatVO = dataObject as ChatVO;
			chatScreenData.type = ChatInitType.CHAT;
			chatScreenData.backScreen = RootScreen;
			MobileGui.showChatScreen(chatScreenData)
			
			close();
		}
		
		override public function dispose():void {
			super.dispose();
			
			ChatManager.S_CHAT_UPDATED.remove(onChatUpdated);
			QuestionsManager.S_QUESTION.remove(onQuestionCreated);
			AnswersManager.S_ANSWERS_LOADED_FROM_PHP.remove(onAnswersLoadedFromPHP);
			
			if (messageBox != null) {
				UI.destroy(messageBox);
				messageBox = null;
			}
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
			
			QuestionsManager.answersDialogOpened = false;
		}
	}
}