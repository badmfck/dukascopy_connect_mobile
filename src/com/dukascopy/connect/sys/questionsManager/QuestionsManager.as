package com.dukascopy.connect.sys.questionsManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.AlertScreenData;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.customActions.TestCreateOfferAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.QuestionCreateUpdateScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowRulesPopup;
	import com.dukascopy.connect.screens.dialogs.geolocation.CityGeoposition;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ExpiredQuestionPopup;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.imageManager.ImageUploader;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.video.VideoUploader;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.sys.ws.WSMethodType;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov
	 */
	
	public class QuestionsManager {
		
		static public const MESSAGE_BOUNDS:String = "~#$bkw#2d~UPD:";
		static public const MESSAGE_KEY:String = "123456789qwerty";
		
		static public const MAX_OTHER_QUESTIONS:int = 50;
		static public const MAX_OTHER_QUESTIONS_WITH_TIPS:int = 200;
		
		static public const TAB_ALL:String = "all";
		static public const TAB_MINE:String = "mine";
		static public const TAB_OTHER:String = "other";
		static public const TAB_RESOLVED:String = "resolved";
		static public const TAB_JAIL:String = "tabJail";
		static public const TAB_FLOWERS:String = "tabFlowers";
		static public const TAB_OFFERS:String = "tabOffers";
		static public const TAB_DEALS:String = "tabDeals";
		
		static public const STATUS_REJECTED:String = "rejected";
		static public const STATUS_ACCEPTED:String = "accepted";
		static public const STATUS_REMOVED:String = "removed";
		
		static public const QUESTION_STATUS_CREATED:String = "created";
		static public const QUESTION_STATUS_EDITED:String = "edited";
		static public const QUESTION_STATUS_PROCESS:String = "process";
		static public const QUESTION_STATUS_WAITING:String = "waiting";
		static public const QUESTION_STATUS_REVOKED:String = "revoked";
		static public const QUESTION_STATUS_RESOLVED:String = "resolved";
		static public const QUESTION_STATUS_REMOVED:String = "removed";
		static public const QUESTION_STATUS_ARCHIVED:String = "archived";
		
		static public const QUESTION_TYPE_PRIVATE:String = "private";
		static public const QUESTION_TYPE_PUBLIC:String = "public";
		
		static public const QUESTION_SIDE_BUY:String = "buy";
		static public const QUESTION_SIDE_SELL:String = "sell";
		
		static public const COMPLAIN_SPAM:String = "Spam";
		static public const COMPLAIN_ABUSE:String = "Abuse";
		static public const COMPLAIN_BLOCK:String = "Block";
		static public const COMPLAIN_STOP:String = "Stop";
		
		static public const S_QUESTIONS:Signal = new Signal("QuestionsManager.S_QUESTIONS");
		static public const S_QUESTIONS_START_LOADING:Signal = new Signal("QuestionsManager.S_QUESTIONS_START_LOADING");
		static public const S_QUESTIONS_FILTERED:Signal = new Signal("QuestionsManager.S_QUESTIONS_FILTERED");
		static public const S_QUESTION:Signal = new Signal("QuestionsManager.S_QUESTION");
		static public const S_QUESTION_CLOSED:Signal = new Signal("QuestionsManager.S_QUESTION_CLOSED");
		static public const S_QUESTION_NEW:Signal = new Signal("QuestionsManager.S_QUESTION_NEW");
		static public const S_CURRENT_QUESTION_UPDATED:Signal = new Signal("QuestionsManager.S_CURRENT_QUESTION_UPDATED");
		static public const S_QUESTION_CREATE_SUCCESS:Signal = new Signal("QuestionsManager.S_QUESTION_CREATE_SUCCESS");
		static public const S_USER_STAT:Signal = new Signal("QuestionsManager.S_USER_STAT");
		static public const S_NEW:Signal = new Signal("QuestionsManager.S_NEW");
		
		static public const S_QUESTION_CREATE_FAIL:Signal = new Signal("QuestionsManager.S_QUESTION_CREATE_FAIL");
		static public const S_TIPS:Signal = new Signal("QuestionsManager.S_TIPS");
		static public const S_CATEGORIES:Signal = new Signal("QuestionsManager.S_CATEGORIES");
		static public const S_FILTER_CLEARED:Signal = new Signal("QuestionsManager.S_FILTER_CLEARED");
		static public const S_LANGUAGES:Signal = new Signal("QuestionsManager.S_LANGUAGES");
		static public const S_CURRENCY:Signal = new Signal("QuestionsManager.S_CURRENCY");
		
		static public const S_QUESTION_PROLONG:Signal = new Signal("QuestionsManager.S_QUESTION_PROLONG");
		
		static public const questionsTypes:Array = [
			{ label:Lang.textQuestionTypePrivate, type:QUESTION_TYPE_PRIVATE },
			{ label:Lang.textQuestionTypePublic, type:QUESTION_TYPE_PUBLIC }
		];
		
		static public const questionsSides:Array =  [
			{ label:Lang.textQuestionSideBuy, type:QUESTION_SIDE_BUY },
			{ label:Lang.textQuestionSideSell, type:QUESTION_SIDE_SELL }
		];
		
		
		
		static public var answersDialogOpened:Boolean;
		
		static private var senderUID:Number;
		
		static private var initialized:Boolean;
		
		
		private static var questionsGetting:Boolean = false;
		static private var questionsHash:String = null;
		
		static private var questions:Array/*QuestionVO*/;
		static private var questionsMine:Array/*QuestionVO*/;
		static private var questionsOther:Array/*QuestionVO*/;
		static private var questionsFiltered:Array/*QuestionVO*/;
		
		static private var currentQuestion:QuestionVO;
		static private var payingUIDS:Array = [];
		static private var _isInitedPayingUsers:Boolean = false;
		
		static private var tipsAmount:Number;
		static private var tipsCurrency:EscrowInstrument;
		static private var tipsSetted:Boolean = false;
		static private var currency:String;
		
		static private var categories:Vector.<SelectorItemData>;
		static private var languages:Vector.<SelectorItemData>;
		static private var incognito:Boolean = false;
		static private var geo:CityGeoposition;
		static private var type:int;
		static private var side:int = -1;
		static private var newFilteredQuestions:Boolean;
		static private var categoriesFilter:Array;
		static private var categoriesFilterNames:String = "";
		
		static private var emptyQM:QuestionVO = new QuestionVO(null);
		static private var flagInOut:Boolean;
		
		static private var lastTipsQUIDs:String;
		static private var lastTipsQUID:String;
		static private var showTipsOnly:Boolean;
		static private var showTipsOnlyPublic:Boolean;
		static private var loadingQuestions:Array;
		static private var needToRefresh:Boolean = true;
		static private var firstQuestionTimeOut:Number;
		static private var firstQuestionCreated:Boolean=false;
		
		static private var getQuestionsTS:Number;

		static private var wallet:String;
		
		static public var fakeTender:QuestionVO;
		
		static public var escrowStat:Object = {};
		static public var escrowInstrumentSelected:String;
		
		public function QuestionsManager() { }
		
		public static function init():void {
			if (initialized == true) {
				return;
			}
			emptyQM.setHeader();
			initialized = true;
			senderUID = new Date().getTime();
			WS.S_CONNECTED.add(updateQuestions);
			Auth.S_NEED_AUTHORIZATION.add(clear);
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onImageUploadReady);
			ImageUploader.S_FILE_UPLOADED.add(sendFileMessage);
			
			VideoUploader.S_FILE_UPLOADED.add(sendVideoMessage);
			VideoUploader.S_FILE_UPLOADED_FINISH.add(sendVideoMessageFinish);
			VideoUploader.S_FILE_UPLOADED_PROGRESS.add(sendVideoMessageProgress);
			
		//	GD.S_ESCROW_FILTER.add(onFilterAdded);
			
			GD.S_ESCROW_DEAL_CREATED.add(onDealCreated);
			
			initPayingUIDS();
		}
		
		static private function saveMaxID(stat:Object):void {
			var crypto:String = stat.instrument;
			if (crypto == "DUK+")
				crypto = "DCO";
			escrowInstrumentSelected = crypto;
			escrowStat[crypto] = stat.maxId;
			Store.save("escrowMaxID", escrowStat);
		}
		
		/*static private function onFilterAdded(escrowFilterVO:EscrowFilterVO):void {
			getQuestions(escrowFilterVO);
		}*/
		
		static private var maxIDWasLoaded:Boolean = false;
		
		static public function getEscrowStats():void {
			GD.S_ESCROW_INSTRUMENT_Q_SELECTED.add(saveMaxID);
			
			if (maxIDWasLoaded == false) {
				maxIDWasLoaded = true;
				Store.load("escrowMaxID", onMaxIdLoaded);
				return;
			}
			PHP.escrow_getStat(onRatesReceived);
		}
		
		static private function onMaxIdLoaded(data:Object, err:Boolean):void {
			if (err == false)
				escrowStat = data;
			PHP.escrow_getStat(onRatesReceived);
		}
		
		static private function onRatesReceived(phpRespond:PHPRespond):void {
			if (phpRespond.error == true)
				return;
			phpRespond.data.push(
				{
					"instrument": "USDT",
					"mca_ccy": "All",
					"side": "Both",
					"maxId": "1848",
					"cnt": "0",
					"volume": "0"
				}
			)
			GD.S_ESCROW_STAT.invoke(phpRespond.data);
		}
		
		static private function onDealCreated(dealData:EscrowMessageData):void {
			
		}
		
		static private function onImageUploadReady(success:Boolean, ibd:ImageBitmapData, title:String):void {
			if (MobileGui.centerScreen.currentScreenClass != QuestionCreateUpdateScreen) {
				return;
			}
			if (success && ibd != null) {
				if (ibd.width >  Config.MAX_UPLOAD_IMAGE_SIZE || ibd.height > Config.MAX_UPLOAD_IMAGE_SIZE)
					ibd = ImageManager.resize(ibd, Config.MAX_UPLOAD_IMAGE_SIZE, Config.MAX_UPLOAD_IMAGE_SIZE, ImageManager.SCALE_INNER_PROP);
				ImageUploader.uploadChatImage(ibd, "que", title, MESSAGE_KEY);
			}
		}
		
		static public function sendFileMessage(iu:ImageUploader, data:Object):void {
			if (MobileGui.centerScreen.currentScreenClass != QuestionCreateUpdateScreen) {
				return;
			}
			var msg:String = JSON.stringify( { method:"fileSended",
				title:data.name,
				type:"file",
				fileType:"cimg",
				additionalData:data.uid + ',' + data.width + ',' + data.height }
			);
			createUpdateQuestion(msg);
		}
		
		static public function sendVideoMessage(iu:VideoUploader, data:MediaFileData):void {
			
		}
		
		static public function sendVideoMessageProgress(iu:VideoUploader, data:MediaFileData):void {
			
		}
		
		static public function sendVideoMessageFinish(iu:VideoUploader, data:MediaFileData):void {
			
		}
		
		static private function onQuestionClosed(quid:String, status:String = "resolved"):void {
			if (questions == null) {
				return;
			}
			var qVO:QuestionVO;
			var ql:int = questions.length;
			var al:int;
			var j:int;
			for (var i:int = ql; i > 0; i--) {
				qVO = questions[i - 1];
				if (qVO == null)
					continue;
				if (qVO.uid == quid) {
					qVO.setStatus(status);
					if (qVO.isMine() == false) {
						S_QUESTION.invoke(qVO);
						if (questionsOther != null) {
							al = questionsOther.length;
							for (j = al; j > 0; j--) {
								if (qVO == questionsOther[j - 1]) {
									questionsOther.splice(j - 1, 1);
									S_QUESTIONS.invoke();
									break;
								}
							}
						}
						if (questionsFiltered != null) {
							al = questionsFiltered.length;
							for (j = al; j > 0; j--) {
								if (qVO == questionsFiltered[j - 1]) {
									questionsFiltered.splice(j - 1, 1);
									S_QUESTIONS_FILTERED.invoke();
									break;
								}
							}
						}
						removeQuestionFromMainArray(qVO);
						return;
					} else {
						if (questionsMine != null) {
							if (qVO.status == "resolved") {
								return;
							}
							al = questionsMine.length;
							for (j = al; j > 0; j--) {
								if (qVO == questionsMine[j - 1]) {
									questionsMine.splice(j - 1, 1);
									S_QUESTIONS.invoke();
									return;
								}
							}
						}
					}
				}
			}
		}
		
		static public function getCategoriesFilter():Array {
			return categoriesFilter;
		}
		
		static private function getQuestionNewFromWS(data:Object):void {
			if (senderUID == data.senderUID)
				return;
			if (data.categories == null || data.categories == "") {
				if (categoriesFilter != null && categoriesFilter.length != 0 && categoriesFilter.indexOf(Config.CAT_GENERAL) == -1)
					S_NEW.invoke();
			} else {
				var category:int = int(String(data.categories).split(",")[0]);
				if (categoriesFilter == null || categoriesFilter.length == 0) {
					if (category == Config.CAT_DATING)
						S_NEW.invoke();
				} else {
					if (categoriesFilter.indexOf(category) == -1)
						S_NEW.invoke();
				}
			}
			if (questionsHash != null || (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().questionID == data.quid)) {
				if (String(data.categories).split(",").indexOf(Config.CAT_DATING + "") != -1) {
					if (categoriesFilter == null || categoriesFilter.length == 0 || categoriesFilter.indexOf(Config.CAT_DATING) == -1) {
						return;
					}
				}
				newFilteredQuestions = true;
				if ("data" in data == true && data.data != null) {
					//trace("getQuestionNewFromWS -> QUESTION DATA NOT NULL");
					var queData:Object;
					try {
						queData = JSON.parse(data.data);
					} catch (err:Error) {
						echo("QuestionsManager", "getQuestionNewFromWS", "JSON Error: " + err.message);
					}
					if (queData != null) {
						onQuestionsLoadedProceed(queData);
						return;
					}
				}
				//trace("getQuestionNewFromWS -> QUESTION DATA IS NULL");
				getQuestion(data.quid);
			}
		}
		
		static private function getQuestionUpdateFromWS(data:Object):void {
			if (data == null || senderUID == data.senderUID) {
				return;
			}
			var qVO:QuestionVO = getQuestionByUID(data.quid, false);
			if (qVO == null) {
				if (questionsOther == null || questionsOther.length < 50) {
					//trace("getQuestionUpdateFromWS -> QUESTION IS NULL AND LENGTH IS " + ((questionsOther == null) ? "NULL" : questionsOther.length));
					getQuestion(data.quid);
				}
			} else {
				if ("action" in data == true) {
					qVO.setStatus(QUESTION_STATUS_PROCESS);
					if (data.action == "release") {
						qVO.updateUnread(data.chatUID, false);
						qVO.setUpdatedAnswersCount(qVO.answersCount - 1);
					} else if (data.action == "take") {
						qVO.updateUnread(data.chatUID, true);
						qVO.setUpdatedAnswersCount(qVO.answersCount + 1);
					}
					S_QUESTION.invoke(qVO);
					if (qVO.answersCount == qVO.answersMaxCount) {
						var cVO:ChatVO = AnswersManager.getChatByQuestionUID(data.quid);
						if (cVO == null || cVO.hasQuestionAnswer == false) {
							for (var i:int = 0; i < questionsOther.length; i++) {
								if (questionsOther[i] == qVO) {
									questionsOther.splice(i, 1);
									removeQuestionFromMainArray(qVO);
									S_QUESTIONS.invoke();
									return;
								}
							}
						} 
					}
					return;
				}
				//trace("getQuestionUpdateFromWS -> QUESTION NOT NULL BUT ACTION IS NULL");
				getQuestion(data.quid);
			}
		}
		
		static private function clear():void {
			if (questions == null) {
				return;
			}
			while (questions.length) {
				questions[0].dispose();
				questions.splice(0, 1);
			}
			questions = null;
			if (questionsMine != null)
				questionsMine.length = 0;
			questionsMine = null;
			if (questionsOther != null)
				questionsOther.length = 0;
			questionsOther = null;
			questionsHash = null;
			initialized = false;
			
			currentQuestion = null;
			payingUIDS = [];
			_isInitedPayingUsers = false;
			
			tipsAmount = NaN;
			tipsCurrency = null;
			tipsSetted = false;
			
			categories = null;
			languages = null;
			incognito = false;
			geo = null;
			newFilteredQuestions = false;
			categoriesFilter = null;
			categoriesFilterNames = "";
			
			flagInOut = false;
			
			lastTipsQUIDs = null;
			lastTipsQUID = null;
			//!TODO;;
		//	showTipsOnly = false;
			showTipsOnly = true;
			showTipsOnlyPublic = false;
			
			WS.S_CONNECTED.remove(updateQuestions);
			Auth.S_NEED_AUTHORIZATION.remove(clear);
			WSClient.S_QUESTION_NEW.remove(getQuestionNewFromWS);
			WSClient.S_QUESTION_UPDATED.remove(getQuestionUpdateFromWS);
			WSClient.S_QUESTION_CLOSED.remove(onQuestionClosed);
		}
		
		static private function updateQuestions():void {
			if (initialized == false) {
				return;
			}
			setInOut(flagInOut, true);
			if (new Date().getTime() < getQuestionsTS + 3000) {
				return;
			}
			if (flagInOut == true)
				getQuestions();
		}
		
		static private function getQuestions():void {
			init();
			TweenMax.killDelayedCallsTo(getQuestions);
			if (!WS.connected) {
				return;
			}
			if (questionsGetting == true)
				return;
			getQuestionsTS = new Date().getTime();
			needToRefresh = false;
			questionsGetting = true;
			S_QUESTIONS_START_LOADING.invoke();
			
			PHP.question_get(onQuestionsLoaded, questionsHash, null, null, (questionsHash == null) ? 10 : 50);
		}
		
		static public function getQuestionByUID(quid:String, needServerCall:Boolean = true):QuestionVO {
			if (questions == null) {
				if (needServerCall == true) {
					getQuestion(quid);
				}
				return null;
			}
			var qVO:QuestionVO;
			var ql:int = questions.length;
			for (var i:int = 0; i < ql; i++) {
				qVO = questions[i];
				if (qVO.uid == quid) {
					return qVO;
				}
			}
			if (needServerCall == true) {
				//trace("getQuestionByUID -> QUESTION IS NULL AND NEED SERVER CALL");
				getQuestion(quid);
			}
			return null;
		}
		
		static private function getQuestion(quid:String):void {
			if (quid == null || quid == "")
				return;
			init();
			loadingQuestions ||= new Array();
			if (loadingQuestions[quid] == true)
				return;
			loadingQuestions[quid] = true;
			PHP.question_getOne(onQuestionLoaded, quid);
		}
		
		static private function onQuestionLoaded(phpRespond:PHPRespond):void {
			if (loadingQuestions != null) {
				if ("additionalData" in phpRespond && loadingQuestions[phpRespond.additionalData.quid] == true)
					delete loadingQuestions[phpRespond.additionalData.quid];
			}
			if (phpRespond.error == true) {
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				DialogManager.alert(Lang.textWarning, Lang.serverError + " " + Lang.emptyData);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data.length == 0) {
				phpRespond.dispose();
				return;
			}
			onQuestionsLoadedProceed(phpRespond.data);
			phpRespond.dispose();
		}
		
		static public function onQuestionsLoadedProceed(data:Object):void {
			if (questions == null)
				questions = [];
			if (questionsMine == null)
				questionsMine = [];
			if (questionsOther == null)
				questionsOther = [];
			var qVO:QuestionVO;
			var ql:int = questions.length;
			for (var i:int = 0; i < ql; i++) {
				qVO = questions[i];
				if (qVO.uid == data.uid) {
					qVO.update(data);
					if (qVO.isMine() == false && qVO.answersCount == qVO.answersMaxCount) {
						var cVO:ChatVO = ChatManager.getChatByQuestionUID(qVO.uid);
						if (cVO == null) {
							for (var n:int = 0; n < questionsOther.length; n++) {
								if (questionsOther[n] == qVO) {
									questionsOther.splice(n, 1);
									removeQuestionFromMainArray(qVO);
									S_QUESTIONS.invoke();
									return;
								}
							}
						}
					}
					updateCurrentChatQuestion(qVO);
					S_QUESTION.invoke(qVO);
					if (qVO == currentQuestion)
						S_CURRENT_QUESTION_UPDATED.invoke();
					return;
				}
			}
			qVO = new QuestionVO(data);
			if (qVO.isMine() == false && qVO.answersCount == qVO.answersMaxCount && qVO.bind == true) {
				qVO.dispose();
				return;
			}
			questions.push(qVO);
			if (qVO.status == "created" || qVO.status == "edited" || qVO.status == "process") {
				if (qVO.isMine() == true)
					questionsMine.push(questions[questions.length - 1]);
				else {
					var needToAdd:Boolean = true;
					if (qVO.categories != null) {
						for (var j:int = 0; j < qVO.categories.length; j++) {
							if (qVO.categories[i] == Config.CAT_DATING)
								needToAdd = false;
						}
					}
					if (needToAdd == true)
						questionsOther.push(questions[questions.length - 1]);
				}
			}
			
			questionsMine.sort(questionsSort);
			questionsOther.sort(questionsSort);
			
			checkForMaxCount();
			
			updateCurrentChatQuestion(qVO, true);
			
			if (questionsHash != null)
				S_QUESTIONS.invoke();
			S_QUESTION_NEW.invoke(qVO);
		}
		
		static private function checkForMaxCount():void {
			if (questionsOther == null)
				return;
			var qVO:QuestionVO;
			var cVO:ChatVO = ChatManager.getCurrentChat();
			var i:int = questionsOther.length;
			var index:int;
			var count:int = 0;
			for (i; i != 0; i--) {
				index = i - 1;
				if (isNaN(questionsOther[index].tipsAmount) == true)
					count++;
				else
					continue;
				if (count < MAX_OTHER_QUESTIONS)
					continue;
				if (cVO != null && cVO.questionID == questionsOther[index].uid)
					continue;
				qVO = questionsOther[index];
				questionsOther.splice(index, 1);
				removeQuestionFromMainArray(qVO);
			}
		}
		
		static private function removeQuestionFromMainArray(qVO:QuestionVO):void {
			if (questions == null || questions.length == 0) {
				return;
			}
			if (qVO == null) {
				return;
			}
			var l:int = questions.length;
			for (var i:int = 0; i < l; i++) {
				if (questions[i] != null && questions[i] == qVO) {
					questions.splice(i, 1);
					qVO.dispose();
					break;
				}
			}
		}
		
		static private function onQuestionsLoaded(phpRespond:PHPRespond):void {
			questionsGetting = false;
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg == "io" && NetworkManager.isConnected == true)
					TweenMax.delayedCall(5, getQuestions);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				DialogManager.alert(Lang.textWarning, Lang.serverError + " " + Lang.emptyData);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data.hash == questionsHash) {
				phpRespond.dispose();
				return;
			}
			var needProlong:Boolean = true;
			if (phpRespond.additionalData.limit == 10) {
				questionsHash = "";
				needProlong = false;
				getQuestions();
			} else {
				questionsHash = phpRespond.data.hash;
			}
			if (questions == null)
				questions = [];
			if (questionsMine == null)
				questionsMine = [];
			if (questionsOther == null)
				questionsOther = [];
			var i:int;
			var j:int;
			var qVO:QuestionVO;
			var ql:int = questions.length;
			var al:int;
			var prolong:Array = [];
			for (i = ql; i > 0; i--) {
				qVO = questions[i - 1];
				if (qVO.isMine() == true) {
					checkForUpdateOrRemove(questionsMine, "mine", qVO, i, phpRespond);
					if (qVO.freshTime > 0)
						prolong.push(qVO);
					continue;
				}
				checkForUpdateOrRemove(questionsOther, "others", qVO, i, phpRespond);
			}
			if ("mine" in phpRespond.data && phpRespond.data.mine != null) {
				al = phpRespond.data.mine.length;
				for (i = 0; i < al; i++) {
					qVO = new QuestionVO(phpRespond.data.mine[i]);
					if (qVO.freshTime > 0)
						prolong.push(qVO);
					questionsMine.push(questions[questions.push(qVO) - 1]);
					if (loadingQuestions != null) {
						if (loadingQuestions[phpRespond.data.mine[i].uid] == true) {
							delete loadingQuestions[phpRespond.data.mine[i].uid];
						}
					}
				}
			}
			if ("others" in phpRespond.data && phpRespond.data.others != null) {
				al = phpRespond.data.others.length;
				for (i = 0; i < al; i++) {
					questionsOther.push(questions[questions.push(new QuestionVO(phpRespond.data.others[i])) - 1]);
					if (loadingQuestions != null) {
						if (loadingQuestions[phpRespond.data.others[i].uid] == true) {
							delete loadingQuestions[phpRespond.data.others[i].uid];
						}
					}
				}
			}
			if (questionsMine.length > 0 && (questionsMine[0].uid == null || questionsMine[0].uid == ""))
				questionsMine.splice(0, 1);
			if (questionsOther.length > 0 && (questionsOther[0].uid == null || questionsOther[0].uid == ""))
				questionsOther.splice(0, 1);
			S_QUESTIONS.invoke();
			
			phpRespond.dispose();
			
			if (prolong.length == 0 || needProlong == false)
				return;
			//askForProlong(prolong);
		}
		
		static private function askForProlong(prolong:Array):void {
			if (prolong == null) {
				return;
			}
			if (prolong.length == 1) {
				if (prolong[0] == null || (prolong[0] is QuestionVO) == false || (prolong[0] as QuestionVO).isDisposed) {
					return;
				}
			}
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ExpiredQuestionPopup, { questions : prolong } );
		}
		
		static public var cquid:String;
		static public function payForProlong(qUID:String, wallet:String):void {
			cquid = qUID;
			Shop.S_PRODUCT_BUY_RESPONSE.add(onProlonged);
			Shop.buyQuestionProduct(qUID, wallet);
		}
		
		static private function onProlonged(success:Boolean, quid:String, errorMsg:String = null):void {
			if (cquid != quid)
				return;
			Shop.S_PRODUCT_BUY_RESPONSE.remove(onProlonged);
			if (success == true)
				ToastMessage.display(Lang.questionProlonged);
			else
				ToastMessage.display(errorMsg);
			S_QUESTION_PROLONG.invoke(success, quid);
		}
		
		static private function checkForUpdateOrRemove(arr:Array/*QuestionVO*/, field:String, qVO:QuestionVO, i:int, phpRespond:PHPRespond):void {
			var al:int;
			var j:int;
			if (field in phpRespond.data && phpRespond.data[field] != null) {
				al = phpRespond.data[field].length;
				for (j = al; j > 0; j--) {
					if (phpRespond.data[field][j - 1].uid == qVO.uid) {
						qVO.update(phpRespond.data[field][j - 1]);
						phpRespond.data[field].splice(j - 1, 1);
						return;
					}
				}
			}
			al = arr.length;
			for (j = al; j > 0; j--) {
				if (qVO.uid == arr[j - 1].uid) {
					arr.splice(j - 1, 1);
					if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().questionID == qVO.uid) {
						continue;
					}
					questions.splice(i - 1, 1);
					qVO.dispose();
					break;
				}
			}
		}
		
		static public function getMine():Array/*QuestionVO*/ {
			if (questionsHash == null)
				getQuestions();
			if (needToRefresh == true)
				getQuestions();
			lastTipsQUIDs = "";
			addArray(null, (questionsMine == null) ? [] : questionsMine);
			questionsFiltered.sort(questionsSort1);
		//	questionsFiltered.unshift(emptyQM);
			return questionsFiltered;
		}
		
		static public function getOther():Array/*QuestionVO*/ {
			if (categoriesFilter != null && categoriesFilter.length != 0) {
				return getFiltered();
			}
			if (questionsHash == null)
				getQuestions();
			if (needToRefresh == true)
				getQuestions();
			return questionsOther;
		}
		
		static public function getAll():Array/*QuestionVO*/ {
			if (questionsHash == null)
				getQuestions();
			if (needToRefresh == true)
				getQuestions();
			return questions;
		}
		
		static private function getFiltered():Array/*QuestionVO*/ {
			if (questions == null) {
				return null;
			}
			if (needToRefresh == true)
				getQuestions();
			questionsFiltered ||= [];
			newFilteredQuestions = false;
			questionsFiltered.length = 0;
			var l:int = questions.length;
			for (var i:int = 0; i < l; i++)
				if (checkForFilteredCategory(questions[i]))
					questionsFiltered.push(questions[i]);
			return questionsFiltered;
		}
		
		static private function checkForFilteredCategory(qVO:QuestionVO):Boolean {
			if (qVO == null) {
				return false;
			}
			if (qVO.status == "resolved" || qVO.status == "closed" || qVO.status == "removed") {
				return false;
			}
			if (qVO.isMine() == false && qVO.answersCount > qVO.answersMaxCount - 1 && qVO.bind == true) {
				return false;
			}
			if (categoriesFilter == null || categoriesFilter.length == 0) {
				return true;
			}
			var l0:int = categoriesFilter.length;
			var l1:int = 0;
			if (qVO.categories != null)
				l1 = qVO.categories.length;
			if (l1 == 0) {
				for (var k:int = 0; k < l0; k++)
					if (categoriesFilter[k] == Config.CAT_GENERAL) {
						return true;
					}
			} else {
				for (var i:int = 0; i < l1; i++) {
					for (var j:int = 0; j < l0; j++) {
						if (categoriesFilter[j] == qVO.categories[i]) {
							return true;
						}
					}
				}
			}
			return false;
		}
		
		static public function getNotResolved():Array/*QuestionVO*/ {
			
			
			if (questionsHash == null) {
				getQuestions();
				return null;
			}
			
			
			
			//!TODO:!!!;
			//!TODO:!!!;
			//!TODO:!!!;
			needToRefresh = true;
			//!TODO:!!!;
			//!TODO:!!!;
			//!TODO:!!!;
			
			
			
			if (needToRefresh == true)
				getQuestions();
			if (categoriesFilter == null || categoriesFilter.length == 0)
				addArray(questionsOther, questionsMine, true);
			else
				getOther();
			questionsFiltered.sort(questionsSort);
			if (categoriesFilter == null || categoriesFilter.length == 0 || categoriesFilter[0] != Config.CAT_DATING)
				showFirstTips();
			
			var temp:Array;
			
			return questionsFiltered;
		}
		
		static private function showFirstTips():void {
			if (questionsFiltered == null || questionsFiltered.length == 0)
				return;
			lastTipsQUIDs = "";
			var c:int = 0;
			for (var i:int = 0; i < questionsFiltered.length; i++) {
				if (isNaN(questionsFiltered[i].tipsAmount) == false) {
					questionsFiltered.splice(c, 0, questionsFiltered.removeAt(i));
					lastTipsQUIDs += questionsFiltered[c].uid + ",";
					c++;
					if (c == 2) {
						lastTipsQUID = questionsFiltered[1].uid;
						return;
					}
				}
			}
			if (c == 1)
				lastTipsQUID = questionsFiltered[0].uid;
			else
				lastTipsQUID = null;
		}
		
		/**
		 * 
		 * @param	arr1 - others
		 * @param	arr2 - mine
		 */
		static private function addArray(arr1:Array/*QuestionVO*/, arr2:Array/*QuestionVO*/ = null, flag:Boolean = false):void {
			var cVO:ChatVO;
			questionsFiltered ||= [];
			questionsFiltered.length = 0;
			var tipsCount:int = 2;
			var i:int = 0;
			var l:int;
			if (arr1 != null && arr1.length > 0) {
				l = arr1.length;
				for (i; i < l; i++) {
					if (arr1[i].bind == false && arr1[i].answersCount == arr1[i].answersMaxCount)
						continue;
					if (flag == true) {
						if (showTipsOnly == true) {
							if (isNaN(arr1[i].tipsAmount) == true)
								continue;
							if (showTipsOnlyPublic == true && arr1[i].type != QUESTION_TYPE_PUBLIC)
								continue;
						} else {
							if (isNaN(arr1[i].tipsAmount) == false) {
								if (tipsCount == 0)
									continue;
								tipsCount--;
							}
						}
					}
					if (arr1[i] != emptyQM) {
						questionsFiltered.push(arr1[i]);
					}
				}
			}
			if (arr2 != null && arr2.length > 0) {
				l = arr2.length;
				for (i = 0; i < l; i++) {
					if (arr2[i].uid == null)
						continue;
					if (arr1 != null && arr2[i].status != "created" && arr2[i].status != "edited" && arr2[i].status != "process")
						continue;
					if (flag == true && showTipsOnly == true) {
						if (isNaN(arr2[i].tipsAmount) == true)
							continue;
						if (showTipsOnlyPublic == true && arr2[i].type != QUESTION_TYPE_PUBLIC)
							continue;
					}
					if (arr2[i] != emptyQM)
						questionsFiltered.push(arr2[i]);
				}
			}
		}
		
		static public function createUpdateQuestion(text:String):void {
			if (text.length > 2048) {
				DialogManager.alert(Lang.textAlert, Lang.textMessageIsTooLong + "2048");
				return;
			}
			var txt:String = text.replace(/\s/, "");
			if (txt.length == 0)
				return;
			if (currentQuestion == fakeTender) {
				createQuestion(text);
				return;
			} else if (currentQuestion.answersCount > 0) {
				DialogManager.alert(Lang.textAlert, Lang.alertUpdateQuestion);
				return;
			}
			editQuestion(currentQuestion.uid, text);
		}
		
		static private function createQuestion(text:String):void {
			firstQuestionCreated = true;
			if (text == null) {
				S_QUESTION_CREATE_FAIL.invoke();
				return;
			}
			if (currentQuestion.subtype == null) {
				S_QUESTION_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			if (currentQuestion.instrument == null) {
				S_QUESTION_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			if (currentQuestion.cryptoAmount == null) {
				S_QUESTION_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			if (currentQuestion.priceCurrency == null) {
				S_QUESTION_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			if (currentQuestion.price == null) {
				S_QUESTION_CREATE_FAIL.invoke(Lang.escrow_fill_application_form);
				return;
			}
			
			currentQuestion.cryptoAmount = NumberFormat.formatAmount(Number(currentQuestion.cryptoAmount), currentQuestion.instrument.code, true);
			
			var selectedDirection:TradeDirection = (currentQuestion.subtype == QUESTION_SIDE_BUY) ? TradeDirection.buy : TradeDirection.sell;
			var price:Number = 0;
			if (currentQuestion.price.indexOf("%") == -1) {
				price = Number(currentQuestion.price);
			} else {
				for (var i:int = 0; i < currentQuestion.instrument.price.length; i++) {
					if (currentQuestion.instrument.price[i].name == currentQuestion.priceCurrency) {
						price = currentQuestion.instrument.price[i].value + currentQuestion.instrument.price[i].value * Number(currentQuestion.price.substr(0, currentQuestion.price.length -1));
						break;
					}
				}
				if (price == 0) {
					S_QUESTION_CREATE_FAIL.invoke();
					return;
				}
			}
			var fiatAmount:Number = Number(currentQuestion.cryptoAmount) * price;
			var resultAmount:Number = fiatAmount + ((currentQuestion.subtype == QUESTION_SIDE_BUY) ?  fiatAmount * EscrowSettings.refundableFee : fiatAmount * EscrowSettings.getCommission(currentQuestion.instrument.code));
			
			var checkPaymentsAction:TestCreateOfferAction = new TestCreateOfferAction(selectedDirection, resultAmount, currentQuestion.priceCurrency, currentQuestion.instrument);
			checkPaymentsAction.disposeOnResult = true;
			checkPaymentsAction.getFailSignal().add(onPaymentsBuyCheckFail);
			checkPaymentsAction.getSuccessSignal().add(onPaymentsBuyCheckSuccess);
			checkPaymentsAction.execute();
		}
		
		static private function onPaymentsBuyCheckSuccess():void {
			PHP.question_create(
				onQuestionCreated,
				Crypter.crypt("Escrow", MESSAGE_KEY),
				Number(currentQuestion.cryptoAmount),
				currentQuestion.instrument.code,
				currentQuestion.priceCurrency,
				incognito,
				currentQuestion.subtype,
				NaN,
				NaN,
				null,
				currentQuestion.price
			);
		}
		
		static private function onPaymentsBuyCheckFail(errorMessage:String):void {
			S_QUESTION_CREATE_FAIL.invoke();
			ToastMessage.display(errorMessage);
		}
		
		static private function onCreateQuestionSuccess(data:Object):void {
			if (questions == null)
				questions = [];
			if (questionsMine == null)
				questionsMine = [];
			if (questionsMine.length > 0 && (questionsMine[0].uid == null || questionsMine[0].uid == ""))
				questionsMine.splice(0, 1);
			currentQuestion = new QuestionVO(data);
			currentQuestion.type = questionsTypes[type].type;
			questionsMine.unshift(questions[questions.push(currentQuestion) - 1]);
			S_QUESTIONS.invoke();
			S_CURRENT_QUESTION_UPDATED.invoke();
			S_QUESTION_CREATE_SUCCESS.invoke();
			WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_CREATED, { quid:questionsMine[0].uid, senderUID:senderUID, categories:createCategoriesString(), data:JSON.stringify(data) } );
		}
		
		static private function onCreateQuestionFail(error:String = null):void {
			var errorMsg:String = error;
			if (errorMsg != null) {
				if (errorMsg.substr(0, 7) == "que..08")
					DialogManager.alert(Lang.textAlert, error.substr(8));
				if (errorMsg.substr(0, 7) == "que..17")
					DialogManager.alert(Lang.textAttention, Lang.questionOneByOne);
				if (errorMsg.substr(0, 7) == "que..16")
					DialogManager.alert(Lang.textAttention, Lang.questionYouAreBanned);
				if (errorMsg.substr(0, 7) == "que..23")
					DialogManager.alert(Lang.textAttention, Lang.questionHasUnpaid);
				if (errorMsg.substr(0, 7) == "que..24")
					DialogManager.alert(Lang.textAttention, Lang.questionNotEnoughMoney);
				if (errorMsg.substr(0, 7) == "que..28") {
					var errorText:String = Lang.questionWrongTipAmount;
					if (errorText.indexOf("3") != -1 && errorMsg != null && errorMsg.indexOf(",") != -1 && errorMsg.split(",") != null && errorMsg.split(",").length > 0) {
						errorText = errorText.replace("3", errorMsg.split(",")[1]);
					}
					DialogManager.alert(Lang.textAttention, errorText);
				} else {
					DialogManager.alert(Lang.textAttention, errorMsg);
				}
			}
			S_QUESTION_CREATE_FAIL.invoke();
		}
		
		static public function editQuestion(quid:String, text:String):void {
			if (tipsCurrency != null)
			{
				var amount:Number = parseFloat(NumberFormat.formatAmount(tipsAmount, tipsCurrency.code, true));
				PHP.question_edit(onQuestionEdited, quid, (text == null) ? null : Crypter.crypt(text, MESSAGE_KEY), amount, tipsCurrency.code, createCategoriesString(), incognito);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		static public function createCategoriesString(workWithParam:Boolean = false, cats:Vector.<SelectorItemData> = null):String {
			if (workWithParam == false) {
				if (categories == null || categories.length == 0) {
					return null;
				}
				cats = categories;
			}
			var val:String = "";
			for (var i:int = 0; i < cats.length; i++) {
				if (i != 0)
					val += ",";
				val += cats[i].data.id;
			}
			return val;
		}
		
		static private function onQuestionEdited(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				S_QUESTION_CREATE_FAIL.invoke();
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				S_QUESTION_CREATE_FAIL.invoke();
				DialogManager.alert(Lang.textWarning, Lang.serverError + " " + Lang.emptyData);
				phpRespond.dispose();
				return;
			}
			if (questions == null || questionsMine == null) {
				S_CURRENT_QUESTION_UPDATED.invoke();
				phpRespond.dispose();
				return;
			}
			var qVO:QuestionVO;
			var ql:int = questions.length;
			for (var i:int = 0; i < ql; i++) {
				qVO = questions[i];
				if (qVO.uid == phpRespond.data.uid) {
					qVO.update(phpRespond.data);
					if (questionsMine.length > 0 && (questionsMine[0].uid == null || questionsMine[0].uid == ""))
						questionsMine.splice(0, 1);
					S_QUESTION.invoke(qVO);
					S_CURRENT_QUESTION_UPDATED.invoke();
					break;
				}
			}
			WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_UPDATED, { quid:questionsMine[0].uid, senderUID:senderUID } );
			phpRespond.dispose();
		}
		
		static public function acceptQuestionAnswer(cVO:ChatVO):void {
			if (cVO == null) {
				return;
			}
			if (cVO.type != ChatRoomType.QUESTION) {
				return;
			}
			if (cVO.questionID == null || cVO.questionID == "") {
				return;
			}
			var qVO:QuestionVO = cVO.getQuestion();
			if (qVO == null)
				qVO = getQuestionByUID(cVO.questionID, false);
			if (qVO == null || qVO.busy == true) {
				return;
			}
			var quid:String = cVO.questionID;
			var cuid:String = cVO.uid;
			var csk:String = cVO.chatSecurityKey;
			var ownerUID:String = cVO.ownerUID;
			var incognito:Boolean = qVO.incognito;
			qVO.setUpdatedAnswersCount(qVO.answersCount - 1);
			qVO.busy = true;
			/*var needPaidStatus:Boolean = !isNaN(qVO.tipsAmount) && qVO.needPayBeforeClose;
			var notPayable:String;
			if (cVO.messages == null) {
				notPayable = "Empty answer";
			} else {
				var answersCount:int = 0;
				var symbolCount:int;
				var onlyStickers:Boolean = true;
				var answer:Boolean = false;
				var queSticker:Boolean = true;
				for (var i:int = 0; i < cVO.messages.length; i++) {
					if (cVO.messages[i].userUID == Auth.uid) {
						if (answer == false && queSticker == true)
							queSticker = !(cVO.messages[i].systemMessageVO == null || cVO.messages[i].systemMessageVO.type != ChatSystemMsgVO.TYPE_STICKER);
						continue;
					}
					answer = true;
					if (cVO.messages[i].userUID == null)
						continue;
					answersCount++;
					if (cVO.messages[i].crypted == true)
						cVO.messages[i].decrypt(cVO.securityKey);
					if (cVO.messages[i].systemMessageVO != null && cVO.messages[i].systemMessageVO.type == ChatSystemMsgVO.TYPE_STICKER)
						continue;
					onlyStickers = false;
					symbolCount += cVO.messages[i].text.length;
					if (symbolCount > 100)
						break;
				}
				if (queSticker == true)
					notPayable = "Question is sticker";
				else if (answersCount < 3)
					notPayable = "Too short answer";
				else if (onlyStickers == true)
					notPayable = "Sticker answer";
				else if (symbolCount < 100)
					notPayable = "Few characters answer";
			}*/
			PHP.question_closeAnswer(onAnswerClosedNew, STATUS_ACCEPTED, cuid, { notPayable:null, quid:quid, cuid:cuid, csk:csk, ownerUID:ownerUID, incognito:incognito, status:STATUS_ACCEPTED, needPaidStatus:false } );
		}
		
		static private function onAnswerClosedNew(phpRespond:PHPRespond):void {
			S_QUESTION_CLOSED.invoke(phpRespond.additionalData.quid);
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg.substr(0, 7) != "que..21") {
					if (phpRespond.errorMsg.substr(0, 7) == "que..16") {
						//banned user
						DialogManager.alert(Lang.textError, ErrorLocalizer.getText(phpRespond.errorMsg));
					} else {
						DialogManager.alert(Lang.textError, phpRespond.errorMsg.substr(8));
					}
				}
				var quid:String = phpRespond.additionalData.quid;
				var qVO:QuestionVO = getQuestionByUID(quid, false);
				if (qVO != null) {
					qVO.busy = false;
					// бредово, но потому что при старте запроса понижается количество ответов.
					qVO.setUpdatedAnswersCount(qVO.answersCount + 1);
				}
				
				phpRespond.dispose();
				return;
			}
			/*if (phpRespond.additionalData.needPaidStatus == true)
				PHP.question_isPaid(onPublicQuestionSetPaidResult, phpRespond.additionalData.quid);*/
			proceedCloseAnswer(phpRespond, !phpRespond.data.isBankPayer, false, false);
			/*saveIsPayingUID(phpRespond.additionalData.ownerUID);*/
			phpRespond.dispose();
			return;
		}
		
		static private function proceedCloseAnswer(phpRespond:PHPRespond, fromUser:Boolean = false, showDialog:Boolean = true, needInvoice:Boolean = true):void {
			var quid:String = phpRespond.additionalData.quid;
			var cuid:String = phpRespond.additionalData.cuid;
			var csk:String = phpRespond.additionalData.csk;
			var status:String = phpRespond.additionalData.status;
			var incognito:Boolean = phpRespond.additionalData.incognito;
			if (status == STATUS_ACCEPTED) {
				if (!("chats" in phpRespond.data)) {
					return;
				}
				if (showDialog == true)
					DialogManager.alert(Lang.information, Lang.doYouWantStartPrivateChat, openPrivateChatDialogResponse, Lang.textYes, Lang.no);
				for (var i:int = 0; i < phpRespond.data.chats.length; i++)
					ChatManager.sendMessageToOtherChat(Config.BOUNDS + "{\"title\":\"Got answer\",\"type\":\"911\",\"method\":\"gotAnswer\"}", phpRespond.data.chats[i].chatUID, phpRespond.data.chats[i].securityKey, incognito);
				if (fromUser == true)
					ChatManager.sendMessageToOtherChat(Config.BOUNDS + "{\"title\":\"Satisfied\",\"type\":\"911\",\"method\":\"satisfyUser\"}", cuid, csk, incognito);
				else
					ChatManager.sendMessageToOtherChat(Config.BOUNDS + "{\"title\":\"Satisfied\",\"type\":\"911\",\"method\":\"satisfy\"}", cuid, csk, incognito);
				if (needInvoice == true)
					prepareInvoiceForWS();
				WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_CLOSED, { quid:quid } );
			} else if (status == STATUS_REJECTED) {
				ChatManager.sendMessageToOtherChat(Config.BOUNDS + "{\"title\":\"Not satisfied\",\"type\":\"911\",\"method\":\"notSatisfy\"}", cuid, csk, incognito);
				WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_UPDATED, { quid:quid, action:"release", chatUID:cuid } );
			} else if (status == STATUS_REMOVED)
				if (phpRespond.data.question.status != "resolved")
					WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_UPDATED, { quid:quid, action:"release", chatUID:cuid } );
			if (!("question" in phpRespond.data)) {
				return;
			}
			if (questions != null) {
				var ql:int = questions.length;
				for (var j:int = 0; j < ql; j++) {
					if (questions[j].uid == phpRespond.data.question.uid) {
						questions[j].update(phpRespond.data.question);
						if (status == STATUS_ACCEPTED)
							questions[j].setIsPaid();
						S_QUESTION.invoke(questions[j]);
						break;
					}
				}
			}
		}
		
		static public function closePublicAnswer(cVO:ChatVO, winnerUID:String, status:String, giftData:GiftData = null):void {
			if (cVO == null) {
				return;
			}
			if (cVO.type == ChatRoomType.CHANNEL && cVO.questionID != "" && cVO.questionID != null) {
				var qVO:QuestionVO = cVO.getQuestion();
				if (qVO == null)
					qVO = getQuestionByUID(cVO.questionID, false);
				if (qVO == null || qVO.busy == true) {
					return;
				}
				var quid:String = cVO.questionID;
				var cuid:String = cVO.uid;
				var csk:String = cVO.chatSecurityKey;
				var ownerUID:String = cVO.ownerUID;
				var incognito:Boolean = false;
				if (qVO != null) {
					qVO.busy = true;
					incognito = qVO.incognito;
				}
				var needPaidStatus:Boolean = false;
				if (qVO != null) {
					needPaidStatus = !isNaN(qVO.tipsAmount) && qVO.needPayBeforeClose;
				}
				PHP.question_closePublicAnswer(onPublicAnswerClosed, status, quid, winnerUID, { needPaidStatus:needPaidStatus, giftData:giftData, winnerUID:winnerUID, quid:quid, cuid:cuid, csk:csk, ownerUID:ownerUID, incognito:incognito, status:status } );
			}
		}
		
		static private function onPublicQuestionSetPaidResult(phpRespond:PHPRespond):void {
			phpRespond.dispose();
		}
		
		static private function onPublicAnswerClosed(phpRespond:PHPRespond):void {
			ChatManager.S_LOAD_STOP.invoke();
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg.substr(0, 7) != "que..21")
					DialogManager.alert(Lang.textError, phpRespond.errorMsg.substr(8));
				phpRespond.dispose();
				return;
			}
			if (phpRespond.additionalData.giftData != null) {
				var quid:String = phpRespond.additionalData.quid;
				var cuid:String = phpRespond.additionalData.cuid;
				var csk:String = phpRespond.additionalData.csk;
				var status:String = phpRespond.additionalData.status;
				var winnerUID:String = phpRespond.additionalData.winnerUID;
				var incognito:Boolean = phpRespond.additionalData.incognito;
				var giftData:GiftData = phpRespond.additionalData.giftData;
				var chatVO:ChatVO;
				if (ChatManager.getCurrentChat() != null &&	ChatManager.getCurrentChat().uid == cuid) {
					chatVO = ChatManager.getCurrentChat();
				}
				if (chatVO == null) {
					chatVO = ChannelsManager.getChannel(cuid);
				}
				if (phpRespond.additionalData.needPaidStatus == true) {
					PHP.question_isPaid(onPublicQuestionSetPaidResult, quid);
				}
				ChannelsManager.updateChannelMode(cuid, ChannelsManager.CHANNEL_MODE_NONE);
				if (chatVO != null) {
					if (giftData != null && chatVO.getQuestion() != null)
						Gifts.sendTipsPaidMessage(giftData, chatVO);
					var isIncognito:Boolean = false;
					if (chatVO.questionID != null && chatVO.questionID != "" && chatVO.getQuestion() != null && chatVO.getQuestion().incognito == true) {
						isIncognito = true;
					}
					if (isIncognito == false && giftData != null) {
						Gifts.sendMoneyTransferMessage(giftData);
					}
				}
			}
			proceedClosePublicAnswer(phpRespond);
			phpRespond.dispose();
		}
		
		static private function proceedClosePublicAnswer(phpRespond:PHPRespond):void {
			var quid:String = phpRespond.additionalData.quid;
			var cuid:String = phpRespond.additionalData.cuid;
			var csk:String = phpRespond.additionalData.csk;
			var status:String = phpRespond.additionalData.status;
			var incognito:Boolean = phpRespond.additionalData.incognito;
			if (status == STATUS_ACCEPTED) {
				WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_CLOSED, { quid:quid } );
			}
			if (questions != null) {
				var ql:int = questions.length;
				for (var j:int = 0; j < ql; j++) {
					if (questions[j].uid == quid) {
						questions[j].setStatus(status);
						questions[j].setIsPaid();
						questions[j].busy = false;
						S_QUESTION.invoke(questions[j]);
						break;
					}
				}
			}
		}
		
		static private function openPrivateChatDialogResponse(val:int):void {
			if (val != 1) {
				return;
			}
			if (ChatManager.getCurrentChat() == null || ChatManager.getCurrentChat().users == null || ChatManager.getCurrentChat().users.length == 0) {
				return;
			}
			var chatScreenData:ChatScreenData = new ChatScreenData();
			var cVO:ChatVO = ChatManager.getChatWithUsersList([ChatManager.getCurrentChat().users[0].uid]);
			if (cVO != null) {
				chatScreenData.chatVO = cVO;
				chatScreenData.type = ChatInitType.CHAT;
			} else {
				chatScreenData.usersUIDs = [ChatManager.getCurrentChat().users[0].uid];
				chatScreenData.type = ChatInitType.USERS_IDS;
			}
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		static private function prepareInvoiceForWS():void {
			if (ChatManager.getCurrentChat() == null || ChatManager.getCurrentChat().getQuestion() == null) {
				return;
			}
			var qVO:QuestionVO = ChatManager.getCurrentChat().getQuestion();
			if (isNaN(qVO.tipsAmount) == true) {
				return;
			}
			var invoiceData:ChatMessageInvoiceData = ChatMessageInvoiceData.create(
				qVO.tipsAmount,
				qVO.tipsCurrency,
				Lang.promisedTips,
				UsersManager.getInterlocutor(ChatManager.getCurrentChat()).name,
				UsersManager.getInterlocutor(ChatManager.getCurrentChat()).uid,
				(qVO.incognito == true) ? "Secret" : qVO.user.getDisplayName(),
				qVO.userUID,
				"$0cHu!X3pa",
				InvoiceStatus.NEW,
				null,
				null,
				null,
				false
			);
			var invoiceString:String = invoiceData.toJsonString();
			invoiceString = Config.BOUNDS_INVOICE + ChatManager.cryptTXT(invoiceString);
			WSClient.call_addAnswerInvoice(ChatManager.getCurrentChat().uid, invoiceString);
		}
		
		static public function close(quid:String, byAdmin:Boolean = false):void {
			var qVO:QuestionVO = getQuestionByUID(quid);
			if (qVO != null) {
				if (qVO.isRemoving == true)
					return;
				qVO.isRemoving = true;
			}
			if (byAdmin == true) {
				PHP.question_closeByAdmin(onQuestionRemoved, quid);
				return;
			}
			PHP.question_close(onQuestionRemoved, quid);
		}
		
		static public function closeByAdmin(quid:String):void {
			PHP.question_closeByAdmin(onQuestionRemoved, quid);
		}
		
		static private function onQuestionRemoved(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg == "io") {
					DialogManager.alert(Lang.information, Lang.noInternetConnection);
				} else {
					DialogManager.alert(Lang.textError, Lang.serverError + ": " + phpRespond.errorMsg);
				}
				var qVO:QuestionVO = getQuestionByUID(phpRespond.additionalData.qUID);
				if (qVO != null) {
					qVO.isRemoving = false;
					S_QUESTION.invoke(qVO);
				}
				phpRespond.dispose();
				return;
			}
			onQuestionClosed(phpRespond.additionalData.qUID, "removed");
			WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_CLOSED, { quid:phpRespond.additionalData.qUID, status:"removed" } );
			phpRespond.dispose();
		}
		
		static public function complain(quid:String, chatUID:String, chatSK:String, reason:String, type:String = "que", incognito:Boolean = false, withTips:Boolean = false):void {
			PHP.complain_complain(function(phpRespond:PHPRespond):void {
				if (phpRespond.error == true) {
					DialogManager.closeDialog();
					if (phpRespond.errorMsg.substr(0,7) != "block04")
						DialogManager.alert("Alert", phpRespond.errorMsg.substr(8));
					phpRespond.dispose();
					return;
				}
				if (withTips == false || reason != COMPLAIN_STOP)
					ChatManager.sendMessageToOtherChat(Config.BOUNDS + "{\"title\":\"" + reason + "\",\"type\":\"Complain\",\"method\":\"" + reason.toLowerCase() + "\"}", chatUID, chatSK, incognito);
				if (phpRespond.data.slotsReduced == 1) {
					WSClient.call_blackHoleToGroup("que", "send", "mobile", WSMethodType.QUESTION_UPDATED, { quid:quid, senderUID:senderUID, action:"release", chatUID:chatUID } );
				}
				phpRespond.dispose();
				
				if (reason == QuestionsManager.COMPLAIN_BLOCK) {
					if (type == "chat") {
						var chatVO:ChatVO = ChatManager.getChatByUID(chatUID);
						if (chatVO != null && chatVO.users != null) {
							var user:ChatUserVO = UsersManager.getInterlocutor(chatVO);
							if (user != null) {
								UsersManager.USER_BLOCK_CHANGED.invoke( { uid:user.uid, status:UserBlockStatusType.BLOCK } );
							}
						}
					} else if (type == "que") {
						var question:QuestionVO = getQuestionByUID(quid);
						if (question != null && question.user != null && "uid" in question.user && question.user.uid != null) {
							UsersManager.USER_BLOCK_CHANGED.invoke( { user:question.user.uid, status:UserBlockStatusType.BLOCK } );
						}
					}
				}
			}, type, (type == "chat") ? chatUID : quid, reason.toLowerCase(), "");
			
			if (type == "chat") {
				//trace("complain -> TYPE IS CHAT");
				getQuestion(quid);
			} else {
				onQuestionClosed(quid);
			}
		}
		
		static public function onQuestionCreated(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				var errorMsg:String = phpRespond.errorMsg;
				if (errorMsg.substr(0, 7) == "que..08")
					DialogManager.alert(Lang.textAlert, phpRespond.errorMsg.substr(8));
				if (errorMsg.substr(0, 7) == "que..17")
					DialogManager.alert(Lang.textAttention, Lang.questionOneByOne);
				if (errorMsg.substr(0, 7) == "que..16")
					DialogManager.alert(Lang.textAttention, Lang.questionYouAreBanned);
				if (errorMsg.substr(0, 7) == "que..23")
					DialogManager.alert(Lang.textAttention, Lang.questionHasUnpaid);
				if (errorMsg.substr(0, 7) == "que..04")
					DialogManager.alert(Lang.textAttention, Lang.noRights);
				if (errorMsg.substr(0, 7) == "que..24")
					DialogManager.alert(Lang.textAttention, Lang.questionNotEnoughMoney);
				if (errorMsg.substr(0, 7) == "que..28") {
					var errorText:String = Lang.questionWrongTipAmount;
					if (errorText.indexOf("3") != -1 && errorMsg != null && errorMsg.indexOf(",") != -1 && errorMsg.split(",") != null && errorMsg.split(",").length > 0) {
						errorText = errorText.replace("3", errorMsg.split(",")[1]);
					}
					DialogManager.alert(Lang.textAttention, errorText);
				}
				S_QUESTION_CREATE_FAIL.invoke();
				phpRespond.dispose();
				errorMsg = "";
				return;
			}
			if (phpRespond.data == null) {
				DialogManager.alert(Lang.textWarning, Lang.serverError + " " + Lang.emptyData);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == false) {
				phpRespond.dispose();
				return;
			}
			onCreateQuestionSuccess(phpRespond.data);
			phpRespond.dispose();
		}
		
		/*static public function preAskFirstQuestion():void {
			if (ReferralProgram.dialogWasClosed == false)
				return;
			if (Auth.isVIDIDInProgress() == true)
				return;
			if (WSClient.getWasMessage() == true)
				return;
			if (firstQuestionCreated == true)
				return;
			firstQuestionCreated = true;
			TweenMax.delayedCall(QuestionsManager.getFirstQuestionTimeOut(), askFirstQuestion);
		}*/
		
		/*static public function askFirstQuestion():void {
			var currentLang:String = "en";
			if (LangManager.model != null && LangManager.model.getCurrentLanguageID())
				currentLang = LangManager.model.getCurrentLanguageID();
			if (Lang.firstQuestion911 != null) {
				var questions:Array = Lang.firstQuestion911.split(";");
				if (questions.length > 0) {
					var question:String = "";
					var index:int = 0;
					for (var i:int = 0; i < 5; i++) {
						index = int(Math.random() * questions.length);
						if (index == questions.length)
							continue;
						question = TextUtils.clearDelimeters(questions[index]);
						question = StringUtil.trim(question);
						if (question!="")
							break;
					}
					if (question != "") {
						question = Crypter.crypt(question, MESSAGE_KEY);
						PHP.question_createFirst911(currentLang, question);
					}
				}
			}
		}*/
		
		static public function initPayingUIDS():void {
			Store.load("willpay_uids", onPayingUIDsLoadedFromStore);
		}
		
		static private function onPayingUIDsLoadedFromStore(dataString:String, error:Boolean):void {
			_isInitedPayingUsers = true;
			if (error == true) {
				return;
			}
			if (dataString == null)
				dataString = "";
			var splitedArray:Array = dataString.split(",");
			if (splitedArray != null)
				payingUIDS = mergeArrays(payingUIDS, splitedArray);
		}
		
		static public function isPaying(ownerUID:String):Boolean {
			if (payingUIDS == null) {
				return false;
			}
			return payingUIDS.indexOf(ownerUID) != -1;
		}
		
		static public function saveIsPayingUID(ownerUID:String):void {
			if (ownerUID == null) {
				return;
			}
			if (payingUIDS.indexOf(ownerUID) == -1) {
				payingUIDS.push(ownerUID);	
				Store.save("willpay_uids", payingUIDS);
			}
		}
		
		static public function mergeArrays(...args):Array {
			var retArr:Array = new Array();
			for each (var arg:* in args){
				if (arg is Array) {
					for each (var value:* in arg) {
						if (retArr.indexOf(value) == -1)
							retArr.push(value);
					}
				}
			}
			return retArr;
		}
		
		static private function questionsSort(a:QuestionVO, b:QuestionVO):int {
			if (a.createdTime < b.createdTime)
				return 1;
			if (a.createdTime > b.createdTime)
				return -1;
			return 0;
		}
		
		static private function questionsSort1(a:QuestionVO, b:QuestionVO):int {
			if (a.createdTime < b.createdTime)
				return 1;
			if (a.createdTime > b.createdTime)
				return -1;
			return 0;
		}
		
		static public function getCurrentQuestion():QuestionVO {
			return currentQuestion;
		}
		
		static public function setCurrentQuestion(qVO:QuestionVO):void {
			currentQuestion = qVO;
			if (qVO == null) {
				fakeTender = new QuestionVO(null);
				currentQuestion = fakeTender;
				return;
			}
		}
		
		static public function showRules():void {
			
			var screenData:AlertScreenData = new AlertScreenData();
			screenData.mainTitle = Lang.escrow_rules;
			screenData.callback = showEscrowTerms;
			screenData.button = Lang.termsAndConditions;
			screenData.text = Lang.questionRulesDialogText;
			screenData.textColor = Style.color(Style.COLOR_SUBTITLE);
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowRulesPopup, screenData);
			
		//	DialogManager.show911Rules( { title:Lang.textRules } );
		}
		
		static private function showEscrowTerms():void 
		{
			navigateToURL(new URLRequest(Lang.escrow_terms_link));
		}
		
		static public function checkForUnsatisfiedQuestionWithTipsExists():int {
			if (currentQuestion != null && currentQuestion.isPaid == false) {
				return 0;
			}
			if (questionsHash == null) {
				getQuestions();
				return -1;
			}
			if (questionsMine != null && questionsMine.length == 0) {
				return 0;
			}
			var l:int = questionsMine.length;
			for (var i:int = 0; i < l; i++) {
				if (questionsMine[i].isPaid == false) {
					return 1;
				}
			}
			return 0;
		}
		
		static public function removeQuestionFromOthers(quid:String):void {
			removeQuestionFromFiltered(quid);
			if (questionsOther == null || questionsOther.length == 0) {
				return;
			}
			var l:int = questionsOther.length;
			for (var i:int = 0; i < l; i++) {
				if (questionsOther[i].uid == quid) {
					questionsOther.removeAt(i);
					break;
				}
			}
		}
		
		static public function removeQuestionFromFiltered(quid:String):void {
			if (questionsFiltered == null || questionsFiltered.length == 0) {
				return;
			}
			var l:int = questionsFiltered.length;
			for (var i:int = 0; i < l; i++) {
				if (questionsFiltered[i].uid == quid) {
					questionsFiltered.removeAt(i);
					break;
				}
			}
		}
		
		static public function getFilteredQuestionsFromServer(selectedCategories:Vector.<SelectorItemData>):void {
			categoriesFilter ||= [];
			categoriesFilter.length = 0;
			categoriesFilterNames = "";
			if (selectedCategories == null || selectedCategories.length == 0) {
				S_FILTER_CLEARED.invoke();
				return;
			}
			var fs:String = "";
			var l:int = selectedCategories.length;
			for (var i:int = 0; i < l; i++) {
				categoriesFilter.push(selectedCategories[i].data.id);
				if (i != 0) {
					fs += ",";
					categoriesFilterNames += ", ";
				}
				fs += selectedCategories[i].data.id;
				categoriesFilterNames += selectedCategories[i].data.name;
			}
			PHP.question_get(onFilteredQuestionsLoaded, null, null, fs);
		}
		
		static private function onFilteredQuestionsLoaded(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				return;
			}
			if (phpRespond.data == null) {
				return;
			}
			if ("others" in phpRespond.data && phpRespond.data.others != null) {
				var l:int = phpRespond.data.others.length;
				for (var i:int = 0; i < l; i++) {
					if (getQuestionByUID(phpRespond.data.others[i].uid, false) != null)
						continue;
					if (questions == null)
						questions = [];
					questions.push(new QuestionVO(phpRespond.data.others[i]));
				}
			}
			newFilteredQuestions = true;
			S_QUESTIONS_FILTERED.invoke();
			phpRespond.dispose();
		}
		
		static public function checkForUnsatisfiedQuestions():Boolean {
			if (questionsMine == null || questionsMine.length == 0) {
				return false;
			}
			var count:int;
			var l:int = questionsMine.length;
			var qVO:QuestionVO;
			for (var i:int = 0; i < l; i++) {
				qVO = questionsMine[i];
				if (qVO.status == "created")
					count++;
			}
			if (count == 3) {
				return true;
			}
			return false;
		}
		
		static private function updateCurrentChatQuestion(qVO:QuestionVO, isNew:Boolean = false):void {
			if (isNew == false && qVO.answersCount != 0)
				return;
			var cVO:ChatVO = ChatManager.getCurrentChat();
			if (cVO == null)
				return;
			if (cVO.type == ChatRoomType.QUESTION || (cVO.questionID != null && cVO.questionID != "")) {
				if (cVO.questionID == qVO.uid) {
					if (cVO.setQuestion(qVO) == true)
						ChatManager.S_MESSAGES.invoke();
				}
			}
		}
		
		static public function setInOut(val:Boolean, obligatory:Boolean = false):void {
			if (flagInOut == val && obligatory == false)
				return;
			flagInOut = val;
			var needToResendInOut:Boolean;
			if (flagInOut == true) {
				needToRefresh = true;
				//needToResendInOut = !WSClient.call_blackHoleToGroup("que", "subscribe");
				
				WSClient.S_QUESTION_NEW.add(getQuestionNewFromWS);
				WSClient.S_QUESTION_UPDATED.add(getQuestionUpdateFromWS);
				WSClient.S_QUESTION_CLOSED.add(onQuestionClosed);
			} else {
				categoriesFilter = null;
				categoriesFilterNames = "";
				//needToResendInOut = !WSClient.call_blackHoleToGroup("que", "unsubscribe");
				
				WSClient.S_QUESTION_NEW.remove(getQuestionNewFromWS);
				WSClient.S_QUESTION_UPDATED.remove(getQuestionUpdateFromWS);
				WSClient.S_QUESTION_CLOSED.remove(onQuestionClosed);
			}
			
			//!TODO:;
		//	showTipsOnly = false;
			showTipsOnly = true;
			
			if (needToResendInOut == true)
				WS.S_CONNECTED.add(resendInOut);
		}
		
		static private function resendInOut():void {
			return;
			WS.S_CONNECTED.remove(resendInOut);
			if (flagInOut == true)
				WSClient.call_blackHoleToGroup("que", "subscribe");
			else
				WSClient.call_blackHoleToGroup("que", "unsubscribe");
		}
		
		static public function getLastTipsQUID():String {
			return lastTipsQUID;
		}
		
		static public function getLastTipsQUIDs():String {
			return lastTipsQUIDs;
		}
		
		static public function setShowTipsOnly(val:Boolean):void {
			showTipsOnly = val;
		}
		
		static public function getShowTipsOnly():Boolean {
			return showTipsOnly;
		}
		
		static public function setShowTipsOnlyPublic(val:Boolean):void {
			showTipsOnlyPublic = val;
		}
		
		static public function getShowTipsOnlyPublic():Boolean {
			return showTipsOnlyPublic;
		}
		
		static public function refreshLangConsts():void {
			questionsTypes[0].label = Lang.textQuestionTypePrivate;
			questionsTypes[1].label = Lang.textQuestionTypePublic;
			
			questionsSides[0].label = Lang.tenderSideBuy;
			questionsSides[1].label = Lang.tenderSideSell;
		}
		
		static public function setFirstQuestionTimeOut(val:Number):void {
			firstQuestionTimeOut = val;
		}
		
		static public function getFirstQuestionTimeOut():Number {
			return firstQuestionTimeOut;
		}
		
		static public function getSide(side:String):Object {
			for (var i:int = 0; i < questionsSides.length; i++) {
				if (questionsSides[i].type == side)
					return questionsSides[i];
			}
			return null;
		}
		
		static public function resetCurrentProperties():void {
			currentQuestion = null;
			if (fakeTender != null)
				fakeTender.dispose();
			fakeTender = null;
		}
	}
}