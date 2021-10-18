package com.dukascopy.connect.sys.chatManager.typesManagers {
	
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.screens.dialogs.ScreenQuestionsDialog;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * Если пользователь удаляет вопрос, то он выходит со всех чатов и они больше на запрос getLatest не придут!!!
	 * @author Ilya Shcherbakov
	 */
	
	public class AnswersManager {
		
		static public const S_QUESTION_ANSWERS:Signal = new Signal("QuestionsManager.S_QUESTION_ANSWERS");
		static public const S_ANSWERS_LOADED_FROM_STORE:Signal = new Signal("QuestionsManager.S_ANSWERS_LOADED_FROM_STORE");
		static public const S_ANSWERS_LOADED_FROM_PHP:Signal = new Signal("QuestionsManager.S_ANSWERS_LOADED_FROM_PHP");
		
		static public var S_ANSWERS:Signal = new Signal('AnswersManager.S_ANSWERS');
		
		static private var answersGetted:Boolean = false;
		static private var answers:Array/*ChatVO*/;
		
		private static var loadingAnswersUID:String = "";
		
		static private var busy:Boolean = false;
		
		public function AnswersManager() { }
		
		static public function init():void {
			WS.S_CONNECTED.add(updateData);
			Auth.S_NEED_AUTHORIZATION.add(clearAllAnswers);
			GD.S_ESCROW_ADS_ANSWERS.add(getAnswersByQuestionUID);
			GD.S_ESCROW_ADS_ANSWER.add(callAnswer);
		}
		
		static private function callAnswer(escrowAdsVO:EscrowAdsVO):void 
		{
			var chatScreenData:ChatScreenData = new ChatScreenData();
			var cVO:ChatVO = getChatByQuestionUID(escrowAdsVO.uid);
			if (cVO == null || cVO.users == null || cVO.users.length == 0) {
			//	chatScreenData.question = qVO;
				chatScreenData.escrow_ad_uid = escrowAdsVO.uid;
				chatScreenData.type = ChatInitType.QUESTION;
				chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
				chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
				MobileGui.showChatScreen(chatScreenData);
				echo("QuestionsManager", "answer", "CHAT NOT EXISTS");
				return;
			}
			chatScreenData.chatVO = cVO;
			chatScreenData.type = ChatInitType.CHAT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		static private function updateData():void {
			answersGetted = false;
			S_ANSWERS.invoke();
		}
		
		static public function getAllAnswers():Array {
			if (answersGetted == false)
				getAnswers();
			if (answers == null)
				answers = [];
			var i:int = answers.length;
			while (i != 0) {
				i--;
				if (answers[i].isDisposed)
					answers.splice(i, 1);
			}
			return answers;
		}
		
		static public function getAnswers():void {
			if (busy)
				return;
			echo("AnswersManager", "getAnswers");
			if (answersGetted == false) {
				busy = true;
				getAnswersFromStore();
				return;
			}
			S_ANSWERS.invoke();
		}
		
		static private function getAnswersFromStore():void {
			if (answers == null || answers.length == 0) {
				echo("AnswersManager", "getAnswersFromStore");
				Store.load(Store.VAR_ANSWERS, onStoreAnswersLoaded);
				return;
			}
			getAnswersFromPHP();
		}
		
		static private function onStoreAnswersLoaded(data:Object, err:Boolean):void {
			echo("AnswersManager", "onStoreAnswersLoaded", "START");
			if (err == true || data == null) {
				getAnswersFromPHP();
				echo("AnswersManager", "onStoreAnswersLoaded", "ERROR OR DATA IS NULL");
				return;
			}
			if ("latest" in data && data.latest != null) {
				var cVO:ChatVO;
				for (var i:int = 0; i < data.latest.length; i++) {
					cVO = getAnswer(data.latest[i].uid);
					if (cVO != null)
						cVO.setData(data.latest[i]);
					else {
						if (answers == null)
							answers = [];
						answers.push(new ChatVO(data.latest[i]));
					}
				}
			}
			onAnswersLoaded(false);
			S_ANSWERS.invoke();
			if ("hash" in data)
				getAnswersFromPHP(data.hash);
			else
				getAnswersFromPHP();
			echo("AnswersManager", "onStoreAnswersLoaded", "END");
		}
		
		static private function onAnswersLoaded(fromPhp:Boolean, firstTime:Boolean = false):void 
		{
			NewMessageNotifier.setInitialData(NewMessageNotifier.type_911, answers, fromPhp, firstTime);
		}
		
		static private function getAnswersFromPHP(hash:String = null):void {
			PHP.chat_getLatest(onAnswersGetted, hash, "private,group,public,company");
		}
		
		static private function onAnswersGetted(phpRespond:PHPRespond):void {
			echo("AnswersManager","onAnswersGetted");
			busy = false;
			if (phpRespond.error == true) {
				echo("AnswersManager", "onAnswersGetted", "PHP ERROR -> " + phpRespond.errorMsg);
				phpRespond.dispose();
				return;
			}
			answersGetted = true;
			if (phpRespond.data == null) {
				echo("AnswersManager", "onAnswersGetted", "DATA IS NULL");
				phpRespond.dispose();
				return;
			}
			if ("latest" in phpRespond.data == false || phpRespond.data.latest == null) {
				clearAllAnswers(false);
				Store.remove(Store.VAR_ANSWERS);
				S_ANSWERS.invoke();
				phpRespond.dispose();
				echo("AnswersManager", "onAnswersGetted", "LATEST IN DATA IS NULL");
				return;
			}
			if (answers == null)
				answers = [];
			var phpAnswers:Array = phpRespond.data.latest.concat();
			var l2:int = phpAnswers.length;
			for (var i:int = answers.length; i > 0; i--) {
				for (var j:int = 0; j < l2; j++) {
					if (answers[i - 1].uid == phpAnswers[j].uid) {
						answers[i - 1].setData(phpAnswers[j]);
						break;
					}
				}
				if (j != l2) {
					phpAnswers.splice(j, 1);
					l2 = phpAnswers.length;
					continue;
				}
				if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == answers[i - 1].uid)
					break;
				answers[i - 1].dispose();
				answers.splice(i - 1, 1);
			}
			while (phpAnswers.length > 0) {
				answers.push(new ChatVO(phpAnswers[0]));
				phpAnswers.splice(0, 1);
			}
			phpAnswers = null;
			
			answers.sort(sortByDate);
			
			Store.save(Store.VAR_ANSWERS, phpRespond.data);
			onAnswersLoaded(true);
			S_ANSWERS.invoke();
			phpRespond.dispose();
			echo("AnswersManager", "onAnswersGetted", "END");
		}
		
		static private function sortByDate(a:ChatVO, b:ChatVO):int {
			if (a.getTime() < b.getTime())
				return 1;
			if (a.getTime() > b.getTime())
				return -1;
			return 0;
		}
		
		static private function clearAllAnswers(val:Boolean = true):void {
			echo("AnswersManager", "clearAllAnswers", "START")
			if (answers == null) {
				echo("AnswersManager", "clearAllAnswers", "ANSWERS IS NULL")
				return;
			}
			for (var i:int = answers.length; i > 0; i--) {
				if (val == false && ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == answers[i])
					continue;
				answers[i - 1].dispose();
				answers.splice(i - 1, 1);
			}
			echo("AnswersManager", "clearAllAnswers", "END");
		}
		
		static public function getAnswer(chatUID:String):ChatVO {
			if (answers == null)
				return null;
			for (var i:int = 0; i < answers.length; i++)
				if (answers[i].uid == chatUID)
					return answers[i];
			return null;
		}
		
		static public function addNewAnswer(cvo:ChatVO):void {
			if (cvo == null)
				return;
			if (answers == null)
				answers = [];
			var existingChat:ChatVO = getAnswer(cvo.uid);
			if (existingChat != null)
				existingChat.setData(cvo.getRawData());
			else
				answers.unshift(cvo);
			if (cvo.type == ChatRoomType.CHANNEL)
				ChannelsManager.addNewChannel(cvo);
			S_ANSWERS.invoke();
		}
		
		static public function sendToTop(chatVO:ChatVO, oldDate:Date, newDate:Date):void {
			if (answers == null)
				return;
			if (answers[0] != chatVO) {
				answers.splice(answers.indexOf(chatVO), 1);
				answers.unshift(chatVO);
				if (oldDate.getFullYear() != newDate.getFullYear() || oldDate.getMonth() != newDate.getMonth() || oldDate.getDate() != newDate.getDate())
					S_ANSWERS.invoke();
			}
		}
		
		static public function removeAnswer(chatUID:String):Boolean {
			if (answers == null || answers.length == 0)
				return false;
			var l:int = answers.length;
			for (var i:int = 0; i < l; i++) {
				if (answers[i].uid == chatUID) {
					answers[i].dispose();
					answers.splice(i, 1);
					S_ANSWERS.invoke();
					removeAnswerFromStore(chatUID);
					return true;
				}
			}
			return false;
		}
		
		static private function removeAnswerFromStore(chatUID:String):void {
			Store.load(Store.VAR_ANSWERS, function(data:Object, err:Boolean):void {
				if (err == true || data == null)
					return;
				if ("latest" in data && data.latest != null) {
					for (var i:int = 0; i < data.latest.length; i++) {
						if (data.latest[i].uid == chatUID) {
							data.latest.splice(i, 1);
							Store.save(Store.VAR_ANSWERS, data);
							return;
						}
					}
				}
			});
		}
		
		static public function getChatByQuestionUID(quid:String, loadIfNull:Boolean = false, fromPHP:Boolean = true):ChatVO {
			var ts:int;
			if (answers == null) {
				if (loadIfNull == true) {
					if (fromPHP == true) {
						PHP.question_answer(onAnswerGettedFromPHP, quid);
						return null;
					}
					ts = new Date().getTime() / 1000;
					return new ChatVO( { qUID:quid, qStatus:"waiting", ownerID:Auth.uid, accessed:ts, created:ts, platform:"mobile", type:"que" } );
				}
				return null;
			}
			for (var i:int = 0; i < answers.length; i++) {
				if (answers[i].questionID == quid)
					return answers[i];
			}
			if (loadIfNull == true) {
				if (fromPHP == true) {
					PHP.question_answer(onAnswerGettedFromPHP, quid);
					return null;
				}
				ts = new Date().getTime() / 1000;
				return new ChatVO( { qUID:quid, qStatus:"waiting", ownerID:Auth.uid, accessed:ts, created:ts, platform:"mobile", type:"que" } );
			}
			return null;
		}
		
		static private function onAnswerGettedFromPHP(phpRespond:PHPRespond):void {
			echo("AnswersManager", "onAnswerGettedFromPHP");
			if (phpRespond.error == true) {
				echo("AnswersManager", "onAnswerGettedFromPHP", 'Server Error: ' + phpRespond.errorMsg);
				if (phpRespond.errorMsg.toLowerCase().indexOf('que..06') != -1)
					DialogManager.alert(Lang.textWarning, Lang.questionNotFound);
				else if (phpRespond.errorMsg.toLowerCase().indexOf('que..09') != -1) {
					if (phpRespond.additionalData != null && "quid" in phpRespond.additionalData)
						QuestionsManager.removeQuestionFromOthers(phpRespond.additionalData.quid);
					ToastMessage.display(Lang.questionToManyAnswers);
				} else if (phpRespond.errorMsg.toLowerCase().indexOf('que..07') != -1) {
					if (phpRespond.additionalData != null && "quid" in phpRespond.additionalData)
						QuestionsManager.removeQuestionFromOthers(phpRespond.additionalData.quid);
					ToastMessage.display(Lang.questionResolved);
				}
				else if (phpRespond.errorMsg.toLowerCase().indexOf('que..07') != -1) {
					if (phpRespond.additionalData != null && "quid" in phpRespond.additionalData)
						QuestionsManager.removeQuestionFromOthers(phpRespond.additionalData.quid);
					ToastMessage.display(Lang.questionAlreadyClosed);
				}
				ChatManager.S_ERROR_CANT_OPEN_CHAT.invoke(phpRespond.errorMsg);
				phpRespond.dispose();
				return;
			}
			if (!("uid" in phpRespond.data)) {
				DialogManager.alert(Lang.textWarning, "Server Error: Wrong data format");
				phpRespond.dispose();
				return;
			}
			echo("AnswersManager", "onAnswerGettedFromPHP", "Chat Loaded");
			var c:ChatVO = ChatManager.getChatByUID(phpRespond.data.uid);
			if (c == null) {
				c = new ChatVO(phpRespond.data);
				addNewAnswer(c);
			}
			TweenMax.delayedCall(1, function():void {
				echo("AnswersManager", "onAnswerGettedFromPHP", "TweenMax.delayedCall");
				if (c != null && c.uid != null)
					ChatManager.openChatByVO(c);
			}, null, true);
			phpRespond.dispose();
		}
		
		static public function getAnswersByQuestionUID(questionUID:String):void {
			echo("QuestionsManager", "getAnswersByQuestionUID", "START");
			if (questionUID == null || questionUID == "") {
				echo("QuestionsManager", "getAnswersByQuestionUID", "QUESTION UID IS NULL");
				return;
			}
			loadingAnswersUID = questionUID;
			Store.load(Store.ANSWERS_FOR_QUESTION + questionUID, onLoadAnswersFromStore);
			echo("QuestionsManager", "getAnswersByQuestionUID", "END");
		}
		
		static private function onLoadAnswersFromStore(data:Object, error:Boolean):void {
			echo("QuestionsManager", "onLoadAnswersFromStore", "START");
			S_ANSWERS_LOADED_FROM_STORE.invoke(data, error);
			
			var items:Array = [];
			if (data != null)
				items = data.answers;
			
			DialogManager.showDialog(
				ScreenQuestionsDialog,
				{
					qUID:loadingAnswersUID,
					items:items,
					title:Lang.latestAnswer
				}, ServiceScreenManager.TYPE_SCREEN
			);
			
			if (data != null && data.hash != null)
				loadAnswersFromPHP(loadingAnswersUID, data.hash);
			else
				loadAnswersFromPHP(loadingAnswersUID);
			if (data != null)
				addQuestionAnswers(data.answers);
			echo("QuestionsManager", "onLoadAnswersFromStore", "END");
		}
		
		static public function loadAnswersFromPHP(questionUID:String, hash:String = ""):void {
			echo("QuestionsManager", "loadAnswersFromPHP", "START");
			TweenMax.delayedCall(1, function():void {
				echo("QuestionsManager", "loadAnswersFromPHP:DelayedCall", "START");
				PHP.question_answers(onAnswersLoadedFromPHP, questionUID, hash + "123");
				echo("QuestionsManager", "loadAnswersFromPHP:DelayedCall", "END");
			}, null, true);
			echo("QuestionsManager", "loadAnswersFromPHP", "END");
		}
		
		static private function onAnswersLoadedFromPHP(phpRespond:PHPRespond):void {
			echo("QuestionsManager", "onAnswersLoadedFromPHP", "START");
			S_ANSWERS_LOADED_FROM_PHP.invoke(phpRespond);
			if (phpRespond.error == true) {
				phpRespond.dispose();
				echo("QuestionsManager", "onAnswersLoadedFromPHP", "PHP ERROR");
				return;
			}
			var qVO:QuestionVO = QuestionsManager.getQuestionByUID(phpRespond.additionalData.qUID, false);
			if (phpRespond.data == null) {
				S_QUESTION_ANSWERS.invoke(qVO);
				phpRespond.dispose();
				echo("QuestionsManager", "onAnswersLoadedFromPHP", "PHP DATA IS NULL");
				return;
			}
			if ("answers" in phpRespond.data && phpRespond.data.answers.length > 0) {
				Store.save(Store.ANSWERS_FOR_QUESTION + phpRespond.data.qUID, phpRespond.data);
				if (qVO != null && qVO.answersCount != phpRespond.data.answers) {
					qVO.setUpdatedAnswersCount(phpRespond.data.answers.length);
					S_QUESTION_ANSWERS.invoke(qVO);
				}
			} else {
				if (qVO != null && qVO.answersCount != 0) {
					qVO.setUpdatedAnswersCount(0);
					S_QUESTION_ANSWERS.invoke(qVO);
				}
			}
			addQuestionAnswers(phpRespond.data.answers);
			phpRespond.dispose();
			echo("QuestionsManager", "onAnswersLoadedFromPHP", "END");
		}
		
		static private function addQuestionAnswers(val:Array):void {
			if (val == null || val.length == 0)
				return;
			var i:int;
			answers ||= [];
			if (answers.length == 0) {
				for (i = 0; i < val.length; i++)
					answers.push(new ChatVO(val[i]));
				return;
			}
			var j:int;
			for (i = 0; i < val.length; i++) {
				for (j = 0; j < answers.length; j++) {
					if (val[i].uid == answers[j].uid)
						break;
				}
				if (j == answers.length)
					answers.push(new ChatVO(val[i]));
			}
		}
		
		static public function answer(qVO:QuestionVO):void {
			echo("QuestionsManager", "answer", "START");
			var chatScreenData:ChatScreenData = new ChatScreenData();
			var cVO:ChatVO = getChatByQuestionUID(qVO.uid);
			if (cVO == null || cVO.users == null || cVO.users.length == 0) {
				chatScreenData.question = qVO;
				chatScreenData.type = ChatInitType.QUESTION;
				chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
				chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
				MobileGui.showChatScreen(chatScreenData);
				echo("QuestionsManager", "answer", "CHAT NOT EXISTS");
				return;
			}
			chatScreenData.chatVO = cVO;
			chatScreenData.type = ChatInitType.CHAT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
			echo("QuestionsManager", "answer", "END");
		}
		
		static public function getNextAnswer(qUID:String, cUID:String):ChatVO {
			if (answers != null && answers.length != 0)
				for (var i:int = 0; i < answers.length; i++) 
					if (answers[i].questionID == qUID && answers[i].uid != cUID && (answers[i].complainStatus == null || answers[i].complainStatus == ""))
						return answers[i];
			return null;
		}
	}
}