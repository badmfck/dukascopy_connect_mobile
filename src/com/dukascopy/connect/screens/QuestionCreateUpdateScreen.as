package com.dukascopy.connect.screens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.GetNumericKeyboardAction;
	import com.dukascopy.connect.gui.chat.BubbleButton;
	import com.dukascopy.connect.gui.chat.ConnectionIndicator;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListChatItem;
	import com.dukascopy.connect.gui.list.renderers.ListCryptoWallet;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListQuestionType;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowPriceScreen;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov
	 */
	
	public class QuestionCreateUpdateScreen extends BaseScreen {
		
		private const DEFAULT_BACKGROUND_COLOR:uint = 0xE9F3FB;
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var preloader:Preloader;
		private var answersCountButton:BubbleButton;
		private var questionButtonBG:Bitmap;
		
		private var currentQuestion:QuestionVO;
		private var busy:Boolean = false;
		
		private var actionTrash:Object = { id:"refreshBtn", img:SWFTrashIconBold, imgColor:0xFFFFFF, callback:onTrashTap }
		
		private var trashAdded:Boolean = false;
		
		private var createChatButton:HidableButton;
		private var addQuestionIcon:SWFAddQuestionButton;
		private var getKeyboardAction:GetNumericKeyboardAction;
		
		public function QuestionCreateUpdateScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			list = new List("Chat");
			list.setAdditionalBottomHeight(Config.FINGER_SIZE * .5);
			_view.addChild(list.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			preloader = new Preloader();
			preloader.visible = false;
			preloader.hide();
			view.addChild(preloader);
			
			createChatButton = new HidableButton();
			createChatButton.unhide();
			createChatButton.tapCallback = onChatSend;
			addQuestionIcon ||= new SWFAddQuestionButton();
			createChatButton.setDesign(addQuestionIcon);
			_view.addChild(createChatButton);
		}
		
		private function showPreloader():void {
			preloader.show();
		}
		
		/**
		 * @param	data - Object with initialized params (for exaple - list of searched conversations or etc..)
		 */
		override public function initScreen(data:Object = null):void {
			busy = false;
			echo("QuestionCreateUpdateScreen", "initScreen");
			super.initScreen(data);
			if (data != null)
				topBar.setData(data.title, true, null);
			var qVO:QuestionVO;
			if (data != null)
				qVO = data.data;
			QuestionsManager.setCurrentQuestion(data.data);
			if (qVO != null) {
				topBar.setActions( [ actionTrash ] );
				trashAdded = true;
				QuestionsManager.setInOut(true);
			}
			fillList();
			// Add signal update question
			QuestionsManager.S_CURRENT_QUESTION_UPDATED.add(activate);
			QuestionsManager.S_QUESTION.add(onQuestionAnswers);
			QuestionsManager.S_QUESTION_CREATE_FAIL.add(onQuestionCreateError);
			
			if (qVO == null) {
				createChatButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE - Config.MARGIN * 2);
				createChatButton.setOffset(Config.TOP_BAR_HEIGHT * 2 + Config.APPLE_TOP_OFFSET);
			} else {
				createChatButton.visible = false;
			}
		}
		
		private function hidePreloader():void {
			if (preloader != null)
				preloader.hide();
		}
		
		private function fillList():void {
			var _messages:Array = new Array();
			var message:ChatMessageVO;
			
			var messageData:Object = new Object();
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Lang.tenderStartText;
			messageData.usePlainText = true;
			messageData.created = (new Date()).getTime() / 1000;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(
				{
					type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
					method: ChatSystemMsgVO.METHOD_LOCAL_SIDE,
					title: Lang.tenderSide,
					defaultText: Lang.tenderTypeOperation
				}
			);
			messageData.usePlainText = true;
			messageData.created = (new Date()).getTime() / 1000;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(
				{
					type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
					method: ChatSystemMsgVO.METHOD_LOCAL_CRYPTO,
					title: Lang.tenderCrypto,
					defaultText: Lang.tenderSelectCrypto
				}
			);
			messageData.usePlainText = true;
			messageData.created = (new Date()).getTime() / 1000;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(
				{
					type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
					method: ChatSystemMsgVO.METHOD_LOCAL_CRYPTO_AMOUNT,
					title: Lang.tenderCryptoAmount,
					defaultText: Lang.tenderAmount
				}
			);
			messageData.usePlainText = true;
			messageData.created = (new Date()).getTime() / 1000;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(
				{
					type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
					method: ChatSystemMsgVO.METHOD_LOCAL_CURRENCY,
					title: Lang.tenderCurrency,
					defaultText: Lang.tenderChooseCurrency
				}
			);
			messageData.usePlainText = true;
			messageData.created = 0;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(
				{
					type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
					method: ChatSystemMsgVO.METHOD_LOCAL_PRICE,
					title: Lang.tenderTargetPrice,
					defaultText: Lang.tenderInputPrice
				}
			);
			messageData.usePlainText = true;
			messageData.created = 0;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			list.setData(_messages, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey']);
			list.scrollBottom();
		}
		
		override public function onBack(e:Event = null):void {
			QuestionsManager.resetCurrentProperties();
			
			super.onBack(e);
		}
		
		private function refreshList(date:int):void {
			echo("QuestionCreateUpdateScreen", "refreshList", "");
			if (list != null)
				list.refresh();
		}
		
		override protected function drawView():void {
			echo("QuestionCreateUpdateScreen", "drawView", "");
			if (_isDisposed)
				return;
			if (!list)
				return;
			view.graphics.clear();
			view.graphics.beginFill(0xE9F3FB);
			view.graphics.drawRect(0, 0, _width, _height);
			view.graphics.endFill();
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = _height * .5;
			}
			topBar.drawView(_width);
			list.view.y = Config.FINGER_SIZE * .85 + Config.APPLE_TOP_OFFSET;
			
			setChatListSize();
		}
		
		override public function activateScreen():void {
			echo("QuestionCreateUpdateScreen", "activateScreen", "");
			if (topBar != null)
				topBar.activate();
			if (isDisposed)
				return;
				
			if (_isActivated)
				return;
			
			_isActivated = true;
			
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			
			if (answersCountButton) 
				answersCountButton.activate();
			if (createChatButton != null)
				createChatButton.activate();
			
			setChatListSize();
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (data == null)
				return;
			if (list.getItemByNum(n) == null)
				return;
			if (!(data is ChatMessageVO)) {
				return;
			}
			var cmsgVO:ChatMessageVO = data as ChatMessageVO;
			var lhz:String = list.getItemByNum(n).getLastHitZone();
			if (lhz == HitZoneType.BALLOON) {
				if (cmsgVO.isEntryMessage == true) {
					if (cmsgVO.systemMessageVO != null) {
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_SIDE) {
							if (QuestionsManager.getCurrentQuestion() != QuestionsManager.fakeTender)
								return;
							DialogManager.showSelectItemDialog(
								{
									callBack:onSideChanged,
									itemClass:ListQuestionType,
									listData:QuestionsManager.questionsSides,
									title:Lang.textSelectSide
								}
							);
							return;
						}
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CRYPTO) {
							if (QuestionsManager.getCurrentQuestion() != QuestionsManager.fakeTender)
								return;
							GD.S_ESCROW_INSTRUMENTS.add(onResult);
							GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
							return;
						}
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CRYPTO_AMOUNT) {
							if (QuestionsManager.getCurrentQuestion() != QuestionsManager.fakeTender)
								return;
							callKeyboard();
							return;
						}
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CURRENCY) {
							if (QuestionsManager.getCurrentQuestion() != QuestionsManager.fakeTender)
								return;
							if (QuestionsManager.getCurrentQuestion().instrument == null || QuestionsManager.getCurrentQuestion().instrument.price.length < 2)
								return;
                            var currencies:Array = new Array();
                            for (var i:int = 0; i < QuestionsManager.getCurrentQuestion().instrument.price.length; i++)
                                currencies.push(QuestionsManager.getCurrentQuestion().instrument.price[i].name);
                            DialogManager.showDialog(
                                ListSelectionPopup, 
                                {
                                    items:currencies,
                                    title:Lang.selectCurrency,
                                    renderer:ListPayCurrency,
                                    callback:callBackSelectCurrency
                                }, ServiceScreenManager.TYPE_SCREEN
                            );
							return;
						}
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_PRICE) {
							if (QuestionsManager.getCurrentQuestion() != QuestionsManager.fakeTender)
								return;
							if (QuestionsManager.getCurrentQuestion().instrument == null)
								return;
							if (QuestionsManager.getCurrentQuestion().subtype == null)
								return;
							var direction:TradeDirection;
							if (QuestionsManager.getCurrentQuestion().subtype == "buy")
								direction = TradeDirection.buy;
							else if (QuestionsManager.getCurrentQuestion().subtype == "sell")
								direction = TradeDirection.sell;
							else
								ApplicationErrors.add();
							var screenData:Object = new Object();
							screenData.callback = onPriceChange;
							screenData.instrument = QuestionsManager.getCurrentQuestion().instrument;
							screenData.currency = TypeCurrency.EUR;
							screenData.direction = direction;
							screenData.title = Lang.escrow_target_price_per_coin;
							ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowPriceScreen, screenData);
							return;
						}
					}
				}
			}
		}
		
		private function onPriceChange(price:Number, isPercent:Boolean, currency:String):void {
			if (isDisposed)
				return;
			var val:String = price.toString();
			if (isPercent == true) {
				QuestionsManager.getCurrentQuestion().priceCurrency = currency;
				list.updateItemByIndex(4);
			} else {
				val += "%";
			}
			QuestionsManager.getCurrentQuestion().price = val;
			list.updateItemByIndex(5);
		}
		
		private var testCounter:int;
		
		private function callKeyboard():void {
			getKeyboardAction = new GetNumericKeyboardAction();
			getKeyboardAction.S_ACTION_SUCCESS.add(onAmountChange);
			getKeyboardAction.S_ACTION_FAIL.add(onKeyboardClose);
			getKeyboardAction.execute();
		}
		
		private function onKeyboardClose():void {
			if (isDisposed)
				return;
			var val:String = QuestionsManager.getCurrentQuestion().cryptoAmount;
			if (val != null && val.length > 0) {
				if (val.charAt(val.length - 1) == ".") {
					val = val.substr(0, val.length -1);
					QuestionsManager.getCurrentQuestion().cryptoAmount = val;
					list.updateItemByIndex(3);
				}
			}
			removeKeyboardAction();
		}
		
		private function removeKeyboardAction():void {
			if (getKeyboardAction != null) {
				getKeyboardAction.S_ACTION_SUCCESS.remove(onAmountChange);
				getKeyboardAction.S_ACTION_FAIL.remove(onKeyboardClose);
				getKeyboardAction.dispose();
				getKeyboardAction = null;
			}
		}
		
		private function onAmountChange(key:Object):void {
			if (isDisposed)
				return;
			var val:String = QuestionsManager.getCurrentQuestion().cryptoAmount;
			if (val == null)
				val = "";
			if (key == 1002) {
				if (val.length == 0)
					return;
				val = val.substr(0, val.length - 1);
			} else {
				val += key as String;
			}
			if (isNaN(Number(val)))
				return;
			if (val == "")
				val = null;
			QuestionsManager.getCurrentQuestion().cryptoAmount = val;
			list.updateItemByIndex(3);
		}
		
		private function onSideChanged(val:int):void {
			if (val == -1)
				return;
			if (QuestionsManager.getCurrentQuestion() != QuestionsManager.fakeTender)
				return;
			QuestionsManager.getCurrentQuestion().subtype = QuestionsManager.questionsSides[val].type;
			list.updateItemByIndex(1);
		}
		
		private function onResult(instruments:Vector.<EscrowInstrument>):void {
			GD.S_ESCROW_INSTRUMENTS.remove(onResult);
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:instruments,
					title:Lang.selectCurrency,
					renderer:ListCryptoWallet,
					callback:callBackSelectInstrument
				},
				DialogManager.TYPE_SCREEN
			);
		}
		
		private function callBackSelectInstrument(ei:EscrowInstrument):void {
			QuestionsManager.getCurrentQuestion().instrument = ei;
			if (ei.price.length == 1)
				QuestionsManager.getCurrentQuestion().priceCurrency = ei.price[0].name;
			else
				QuestionsManager.getCurrentQuestion().priceCurrency = null;
			list.updateItemByIndex(2, true, true);
		}
		
		private function callBackSelectCurrency(currency:String):void {
			QuestionsManager.getCurrentQuestion().priceCurrency = currency;
			list.updateItemByIndex(4);
		}
		
		override public function deactivateScreen():void {
			echo("QuestionCreateUpdateScreen", "deactivateScreen", "");
			if (!_isActivated)
				return;
			_isActivated = false;
			if (topBar != null)
				topBar.deactivate();
			list.deactivate();
			if (answersCountButton)
				answersCountButton.deactivate();
			if (createChatButton != null)
				createChatButton.deactivate();
		}
		
		private function checkScrollToBottom():Boolean {
			echo("QuestionCreateUpdateScreen", "checkScrollToBottom", "");
			var needScrollToBottom:Boolean  = false;	
			var allowedBottomOffset:int = 100;
			if (list.height < list.innerHeight) {
				needScrollToBottom = Math.abs(list.getBoxY()-allowedBottomOffset) >=  list.innerHeight - list.height;				
			}
			return needScrollToBottom;
		}
		
		private function setChatListSize(needScrollToBottom:Boolean = false):void {
			if (_isDisposed == true)
				return;
			if (list == null || list.view == null)
				return;
			var inBotomPosition:Boolean = true;
			if (list.innerHeight + list.getBoxY() > list.height)
				inBotomPosition = false;
			var lastY:Number = 0;
			var bottomY:int = _height;
			if (answersCountButton) {
				answersCountButton.y = bottomY - answersCountButton.height - Config.MARGIN;
				answersCountButton.x = _width * .6 ;
				if (answersCountButton.getIsShown())
					lastY = answersCountButton.height + Config.MARGIN*2;
			}
			if (questionButtonBG) {
				questionButtonBG.width = _width;
				questionButtonBG.height = lastY;
				questionButtonBG.y =  bottomY - questionButtonBG.height;
			}
			bottomY -= lastY;
			if (preloader)
				preloader.y = _height * .5;
			var listHeightNew:int = bottomY - list.view.y;
			list.setWidthAndHeight(MobileGui.stage.stageWidth, listHeightNew, !(needScrollToBottom || inBotomPosition));
			if (needScrollToBottom || inBotomPosition)
				list.scrollBottom();
		}
		
		private function onChatSend():Boolean {
			if (busy == true)
				return false;
			busy = true;
			if (QuestionsManager.getCurrentQuestion() == null) {
				showPreloader();
			}
			QuestionsManager.createUpdateQuestion("Escrow");
			return true;
		}
		
		private function activate():void {
			busy = false;
			if (preloader != null)
				preloader.hide();
			hidePreloader();
			
			if (list != null)
				list.refresh();
			
			if (trashAdded == false) {
				trashAdded = true;
				topBar.setActions( [ actionTrash ] );
			}
		}
		
		private function onQuestionAnswers(qVO:QuestionVO):void {
			if (qVO != QuestionsManager.getCurrentQuestion())
				return;
			updateAnswersButtonState();
		}
		
		private function updateAnswersButtonState():void {
			if (QuestionsManager.getCurrentQuestion() == null) {
				if (answersCountButton != null)
					answersCountButton.hide();
				return;
			}
			var numOtherAnswers:int = QuestionsManager.getCurrentQuestion().answersCount;
			if (numOtherAnswers > 0) {
				if (answersCountButton == null) {
					createAnswersCountButton(generateAnswerButtonText(numOtherAnswers));
				} else {
					answersCountButton.setText(generateAnswerButtonText(numOtherAnswers), _width * .4 - Config.MARGIN);
				}
				answersCountButton.show(.3);
				setChatListSize(false);
			} else {
				if (answersCountButton != null) {
					answersCountButton.hide();
					setChatListSize(false);
				}
			}
			if (isNaN(QuestionsManager.getCurrentQuestion().tipsAmount) == false)
				if (topBar != null)
					topBar.setActions(null);
		}
		
		private function generateAnswerButtonText(answersCount:int=0): String{
			return "+" + answersCount + " answer" + (answersCount < 1 ? "" : "s");
		}
		
		private function createAnswersCountButton(btnText:String = ""):void	{
			var buttonText:String = btnText!=""?btnText:"Pp";
			answersCountButton ||= new BubbleButton();
			answersCountButton.setStandartButtonParams();
			answersCountButton.setParams(0xffffff,  AppTheme.RED_MEDIUM, 1,  AppTheme.RED_MEDIUM, 0,"center");
			answersCountButton.setText(buttonText, _width * .4 - Config.MARGIN);
			answersCountButton.setDownScale(.9);
			answersCountButton.setDownAlpha(0);
			answersCountButton.setOverflow(20, 20, 20, 20);			
			answersCountButton.tapCallback = openOtherAnswers;
			
			questionButtonBG ||= new Bitmap(new BitmapData(10, 10, false, 0xc4def1));
			_view.addChild(questionButtonBG);
			
			_view.addChild(answersCountButton);
			answersCountButton.hide();		
			if (_isActivated){
				answersCountButton.activate();
			}
		}
		
		private function openOtherAnswers():void {
			if (QuestionsManager.getCurrentQuestion() == null)
				return;
			if (QuestionsManager.getCurrentQuestion().type == "public") {
				AnswersManager.answer(QuestionsManager.getCurrentQuestion());
			} else {
				AnswersManager.getAnswersByQuestionUID(QuestionsManager.getCurrentQuestion().uid);
			}
		}
		
		private function createQuestionMessage(text:String, createdTime:Number = 0):Object {
			var messageData:Object = new Object();
			messageData.id = 0;
			messageData.user_avatar = Auth.avatar;
			messageData.user_name = Auth.username;
			messageData.text = text;
			messageData.usePlainText = true;
			messageData.created = createdTime;
			messageData.user_uid = Auth.uid;
			messageData.fxId = Auth.fxcommID;
			return messageData;
		}
		
		override public function clearView():void {
			echo("QuestionCreateUpdateScreen", "clearView", "");
			if (answersCountButton) {
				answersCountButton.dispose();
				answersCountButton = null;
			}
			
			UI.destroy(questionButtonBG);
			questionButtonBG = null;
			
			if (list != null)
				list.dispose();
			list = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			
			if (createChatButton)
				createChatButton.dispose();
			createChatButton = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			super.clearView();
		}
		
		override public function dispose():void {
			echo("QuestionCreateUpdateScreen", "dispose", "");
			
			removeKeyboardAction();
			
			QuestionsManager.S_CURRENT_QUESTION_UPDATED.remove(activate);
			QuestionsManager.S_QUESTION.remove(onQuestionAnswers);
			QuestionsManager.S_QUESTION_CREATE_FAIL.remove(onQuestionCreateError);
			_data = null;
			super.dispose();
		}
		
		private function onQuestionCreateError():void {
			hidePreloader();
			busy = false;
			ToastMessage.display(Lang.sendMessageFail);
		}
		
		private function onTrashTap():void {
			QuestionsManager.close(QuestionsManager.getCurrentQuestion().uid);
			onBack();
		}
	}
}