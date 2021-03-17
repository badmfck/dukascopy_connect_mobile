package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
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
	 * @author IgorBloom
	 */
	
	public class ScreenQuestionsDialog extends BaseScreen{
		
		private var list:List
		//private var search:Input;
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
		
		public function ScreenQuestionsDialog() { }
		
		
		override protected function createView():void {
			super.createView();				
			
			list = new List("PayPicker");
			list.setMask(true);
			list.view.y = Config.FINGER_SIZE;
			_view.addChild(list.view);
			
			topBox = new Sprite();
			_view.addChild(topBox);			
			
			closeBtn = new BitmapButton();
			closeBtn.setBitmapData(UI.renderAsset(new SWFCloseIconThin(), Config.FINGER_SIZE_DOT_35, Config.FINGER_SIZE_DOT_35, true, "ScreenPayDialog.closeBtn"));
			closeBtn.setOverflow(Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_25);
			closeBtn.setStandartButtonParams();
			_view.addChild(closeBtn);
			closeBtn.show();
			closeBtn.tapCallback = onCloseBtnClick;
			
			titleTF = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25, AppTheme.GREY_DARK, false);
			
			_view.addChild(bar);
			
		}
		
		
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);			

			_params.title = data.label;			
			var maxHeight:int = _height - Config.FINGER_SIZE;		
			if (list.innerHeight > maxHeight)
				list.setWidthAndHeight(_width, maxHeight);
			else 
				list.setWidthAndHeight(_width, list.innerHeight);
			var initialAnswers:Array = parseAnswers(_data.data);
			_data.parsedAnswers = initialAnswers;
			list.setData(initialAnswers, ListConversation, ["avatarURL"]);
			//if (initialAnswers.length == 0){
				updateBar(); // maybe check on dellay if data length>0 else show instantly ? 
			//}else{
				//hiddenOnLoad = true;
				//loadedFromPHP = true;
			//}
			 
			ChatManager.S_CHAT_UPDATED.add(onChatUpdated);
			QuestionsManager.S_QUESTION.add(onQuestionCreated);			
			AnswersManager.S_ANSWERS_LOADED_FROM_PHP.add(onAnswersLoadedFromPHP);
			
			QuestionsManager.answersDialogOpened = true;
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
		 * Load From Local Store Handler
		 * @param	respondData
		 * @param	error
		 */
		private function onAnswersLoadedFromLocal(respondData:Object, error:Boolean):void {
			if (error)
				return;
			if (respondData != null){
				if (respondData.qUID != _data.qUID) return;	
				list.setData(parseAnswers(respondData.answers), ListConversation, ["avatarURL"]);
				drawView();
			}	
		}
		
		
		/**
		 * Load From PHP Handler 
		 * @param	phpRespond
		 */
		private function onAnswersLoadedFromPHP(phpRespond:PHPRespond):void {				
			if (phpRespond.additionalData == null)
				return;
			if (_data.qUID == phpRespond.additionalData.qUID) {
				loadedFromPHP = true;
				updateBar();
				if (phpRespond.error == true) {
					showMessageBox(Lang.errorAnswersLoading);
					return;
				}
				if (phpRespond.data == null) {
					showMessageBox("");
					return;
				}
				if ("answers" in phpRespond.data && phpRespond.data.answers.length > 0) {	
					_data.parsedAnswers  = parseAnswers(phpRespond.data.answers);
					list.setData(_data.parsedAnswers, ListConversation, ["avatarURL"]);
					showMessageBox("");
				} else {
					showMessageBox(Lang.answerAreEmpty);
					list.setData(null,null);
				}
			}
		}
		
		/**
		 * New Question created Handler
		 * @param	qVO
		 */
		private function onQuestionCreated(qVO:QuestionVO):void  {
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
			for (var i:int = 0; i < _data.parsedAnswers.length; i++) {
				listDataItem = _data.parsedAnswers[i];
				if (listDataItem != null){					
					if (listDataItem.uid == chatVO.uid){
						_data.parsedAnswers[i] = chatVO;
						hasChanges = true;
					}
				}
			}			
			
			if(list!=null && hasChanges){
				list.setData(_data.parsedAnswers, ListConversation, ["avatarURL"]);					
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
		
		private function onCloseBtnClick():void {
			DialogManager.closeDialog();			
		}
		
		override public function activateScreen():void{
			super.activateScreen();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			if (closeBtn != null) {
				closeBtn.activate();
			}
		}
		
		private function onItemTap(dataObject:Object, n:int):void {
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
			DialogManager.closeDialog();
		}
		
		override protected function drawView():void {
			var maxHeight:int = _height - Config.FINGER_SIZE;
			
			//search.width = _width;
			if (list.innerHeight > maxHeight)
				list.setWidthAndHeight(_width, maxHeight);
			else 
				list.setWidthAndHeight(_width, list.innerHeight);
			
			topBox.graphics.clear();
			topBox.graphics.beginFill(AppTheme.GREY_LIGHT);
			topBox.graphics.drawRect(0, 0, _width, Config.FINGER_SIZE);
			topBox.graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
			topBox.graphics.drawRect(Config.DOUBLE_MARGIN, Config.FINGER_SIZE-2, _width-Config.DOUBLE_MARGIN*2, 2);
			//topBox.graphics.drawRoundRectComplex(0, 0, _width, Config.FINGER_SIZE, Config.MARGIN, Config.MARGIN, 0, 0);
			topBox.graphics.endFill();
			
			if (topIBD != null && topIBD.isDisposed == false)
				topIBD.dispose();
			topIBD = null;
			topIBD = ImageManager.drawTextFieldToGraphic(topBox.graphics, Config.DOUBLE_MARGIN, Config.MARGIN * 2.5, _params.title.toLocaleUpperCase(), _width - Config.DOUBLE_MARGIN, titleTF);
			
			var messageBoxHeight:int = messageBox != null ? messageBox.height : 0; 
			var trueHeight:int = list.height + Config.FINGER_SIZE + messageBoxHeight;
			var trueY:int = int((_height - trueHeight) * .5);
			if (messageBox != null) {
				messageBox.y = trueY + Config.FINGER_SIZE;
			}
			
			view.graphics.clear();
			view.graphics.beginFill(0xF5F5f5);
			view.graphics.drawRect(0, trueY, _width, list.height + Config.FINGER_SIZE);
			//view.graphics.drawRoundRect(0, trueY, _width, list.height + Config.FINGER_SIZE, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			view.graphics.endFill();
			
			topBox.y = trueY;
			list.view.y = trueY + Config.FINGER_SIZE + messageBoxHeight;
			list.tapperInstance.setBounds();
			
			closeBtn.x = _width - closeBtn.width-closeBtn.LEFT_OVERFLOW;
			closeBtn.y = trueY + (Config.FINGER_SIZE - closeBtn.height) * .5;
			
			updateBar();
		}
		
		override public function dispose():void {
			super.dispose();
			ChatManager.S_CHAT_UPDATED.remove(onChatUpdated);
			QuestionsManager.S_QUESTION.remove(onQuestionCreated);
			//QuestionsManager.S_ANSWERS_LOADED_FROM_STORE.remove(onAnswersLoadedFromLocal);
			AnswersManager.S_ANSWERS_LOADED_FROM_PHP.remove(onAnswersLoadedFromPHP);
			if (messageBox != null) {
				UI.destroy(messageBox);
				messageBox = null;
			}
			if (bar != null) {
				TweenMax.killTweensOf(bar);
				UI.destroy(bar);
				bar = null;
			}			
			list.dispose();			
			list = null;
			topIBD.disposeNow();
			titleTF = null;
			if (closeBtn != null) {
				closeBtn.deactivate();
				closeBtn.dispose();
				closeBtn = null;
			}
			
			QuestionsManager.answersDialogOpened = false;
		}
	}
}