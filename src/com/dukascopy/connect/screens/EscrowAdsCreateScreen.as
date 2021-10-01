package com.dukascopy.connect.screens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.AlertScreenData;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.EscrowSide;
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
	import com.dukascopy.connect.gui.list.renderers.ListEscrowSide;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsFilterVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowPriceScreen;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatAlert;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.NumberFormat;
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
	
	public class EscrowAdsCreateScreen extends BaseScreen {
		
		private const DEFAULT_BACKGROUND_COLOR:uint = 0xE9F3FB;
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var preloader:Preloader;
		private var answersCountButton:BubbleButton;
		private var questionButtonBG:Bitmap;
		
		private var currentQuestion:QuestionVO;
		private var busy:Boolean = false;
		
		private var actionTrash:Object = { id:"refreshBtn", img:Style.icon(Style.ICON_TRASH), imgColor:Style.color(Style.COLOR_ICON_SETTINGS), callback:onTrashTap }
		
		private var addQuestionIcon:SWFAddQuestionButton;
		private var getKeyboardAction:GetNumericKeyboardAction;
		
		private var amountString:String;
		
		private var escrowAdsVO:EscrowAdsVO = new EscrowAdsVO(null);
		
		private var msgSide:Object = {
			type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
			method: ChatSystemMsgVO.METHOD_LOCAL_SIDE,
			title: Lang.tenderSide,
			defaultText: Lang.tenderTypeOperation
		};
		private var msgCrypto:Object = {
			type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
			method: ChatSystemMsgVO.METHOD_LOCAL_CRYPTO,
			title: Lang.tenderCrypto,
			defaultText: Lang.tenderSelectCrypto
		};
		private var msgAmount:Object = {
			type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
			method: ChatSystemMsgVO.METHOD_LOCAL_CRYPTO_AMOUNT,
			title: Lang.tenderCryptoAmount,
			defaultText: Lang.tenderAmount
		};
		private var msgPrice:Object = {
			type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
			method: ChatSystemMsgVO.METHOD_LOCAL_PRICE,
			title: Lang.tenderTargetPrice,
			defaultText: Lang.tenderInputPrice
		};
		
		public function EscrowAdsCreateScreen() { }
		
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
		}
		
		/**
		 * @param	data - Object with initialized params (for exaple - list of searched conversations or etc..)
		 */
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if (data != null)
				topBar.setData(data.title, true, null);
			/*if (data != null)
				escrowAdsVO = data.data;
			if (escrowAdsVO != null)
				topBar.setActions( [ actionTrash ] );*/
			fillList();
			GD.S_ESCROW_ADS_FILTER_REQUEST.invoke(onFilter);
		}
		
		private function fillList():void {
			var _messages:Array = new Array();
			var message:ChatMessageVO;
			
			var messageData:Object = new Object();
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Lang.tenderStartText1;
			messageData.usePlainText = true;
			messageData.created = (new Date()).getTime() / 1000;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(msgSide);
			messageData.usePlainText = true;
			messageData.created = (new Date()).getTime() / 1000;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(msgCrypto);
			messageData.usePlainText = true;
			messageData.created = (new Date()).getTime() / 1000;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(msgAmount);
			messageData.usePlainText = true;
			messageData.created = (new Date()).getTime() / 1000;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			messageData = {};
			messageData.id = 0;
			messageData.user_avatar = LocalAvatars.QUESTIONS;
			messageData.user_name = "911";
			messageData.text = Config.BOUNDS + JSON.stringify(msgPrice);
			messageData.usePlainText = true;
			messageData.created = 0;
			messageData.isEntryMessage = true;
			message = new ChatMessageVO(messageData);
			_messages.push(message);
			
			if (escrowAdsVO.uid == null) {
				messageData = {};
				messageData.id = 0;
				messageData.user_avatar = LocalAvatars.QUESTIONS;
				messageData.user_name = "911";
				messageData.text = Config.BOUNDS + JSON.stringify(
					{
						type: ChatSystemMsgVO.TYPE_LOCAL_QUESTION,
						method: ChatSystemMsgVO.METHOD_LOCAL_CREATE,
						title: Lang.create.toUpperCase()
					}
				);
				messageData.usePlainText = true;
				messageData.created = 0;
				messageData.isEntryMessage = true;
				message = new ChatMessageVO(messageData);
				_messages.push(message);
			}
			
			list.setData(_messages, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey']);
			list.scrollBottom();
		}
		
		private function onFilter(escrowAdsFilterVO:EscrowAdsFilterVO):void {
			if (escrowAdsFilterVO != null && escrowAdsFilterVO.instrument != null)
				callBackSelectInstrument(escrowAdsFilterVO.instrument);
		}
		
		override protected function drawView():void {
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
							DialogManager.showDialog(
                                ListSelectionPopup, 
                                {
                                    items:EscrowSide.COLLECTION,
                                    title:Lang.textSelectSide,
                                    renderer:ListEscrowSide,
                                    callback:onSideChanged
                                }, ServiceScreenManager.TYPE_SCREEN
                            );
							return;
						}
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CRYPTO) {
							GD.S_ESCROW_INSTRUMENTS.add(onResult);
							GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
							return;
						}
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CRYPTO_AMOUNT) {
							callKeyboard();
							return;
						}
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_PRICE) {
							if (escrowAdsVO.instrument == null)
								return;
							if (escrowAdsVO.side == null)
								return;
							var direction:TradeDirection;
							if (escrowAdsVO.side == EscrowSide.BUY.value)
								direction = TradeDirection.buy;
							else if (escrowAdsVO.side == EscrowSide.SELL.value)
								direction = TradeDirection.sell;
							else
								ApplicationErrors.add();
							var screenData:Object = new Object();
							screenData.callback = onPriceChange;
							screenData.instrument = escrowAdsVO.instrument;
							screenData.currency = TypeCurrency.EUR;
							screenData.direction = direction;
							screenData.title = Lang.escrow_target_price_per_coin;
							ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowPriceScreen, screenData);
							return;
						}
						if (cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_CREATE) {
							onChatSend();
							return;
						}
					}
				}
			}
		}
		
		private function onPriceChange(price:Number, isPercent:Boolean, currency:String):void {
			if (isDisposed)
				return;
			if (isPercent == false)
				price = parseFloat(NumberFormat.formatAmount(price, currency, true));
			var val:String = price.toString();
			if (isPercent == true)
				val += "%";
			escrowAdsVO.currency = currency;
			escrowAdsVO.priceValue = val;
			msgPrice.params = { price:val, currency:currency }
			list.getItemByNum(4).data.updateText(Config.BOUNDS + JSON.stringify(msgPrice));
			list.updateItemByIndex(4);
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
			var val:String = amountString;
			if (isNaN(escrowAdsVO.amount) == false)
				val = escrowAdsVO.amount + "";
			if (val != null && val.length > 0) {
				if (val.charAt(val.length - 1) == ".") {
					val = val.substr(0, val.length -1);
					amountString = val;
					msgAmount.params = { val:val }
					list.getItemByNum(3).data.updateText(Config.BOUNDS + JSON.stringify(msgAmount));
					list.updateItemByIndex(3);
				}
			}
			escrowAdsVO.amount = Number(val);
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
			var val:String = amountString;
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
			amountString = val;
			msgAmount.params = { val:val }
			list.getItemByNum(3).data.updateText(Config.BOUNDS + JSON.stringify(msgAmount));
			list.updateItemByIndex(3);
		}
		
		private function onSideChanged(val:EscrowSide):void {
			if (val == null)
				return;
			escrowAdsVO.side = val.value;
			msgSide.params = { val:val.value, name:val.lang }
			list.getItemByNum(1).data.updateText(Config.BOUNDS + JSON.stringify(msgSide));
			list.updateItemByIndex(1);
		}
		
		private function onResult(instruments:Vector.<EscrowInstrument>):void {
			if (isDisposed)
				return;
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
			if (ei == null)
				return;
			if (escrowAdsVO == null)
				return;
			if (ei.isLinked) {
				escrowAdsVO.instrument = ei;
				msgCrypto.params = { code:ei.code, name:ei.name }
				list.getItemByNum(2).data.updateText(Config.BOUNDS + JSON.stringify(msgCrypto));
				list.updateItemByIndex(2, true, true);
			} else {
				var screenData:AlertScreenData = new AlertScreenData();
				screenData.text = Lang.escrow_blockchain_address_needed.replace(Lang.regExtValue, ei.name);
				screenData.button = Lang.textRegister.toUpperCase();
				screenData.callback = registerBlockchain;
				screenData.callbackData = ei.code;
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FloatAlert, screenData);
			}
		}
		
		private function registerBlockchain(instrumentCode:String):void {
			EscrowScreenNavigation.registerBlockchain(instrumentCode);
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
			
			GD.S_ESCROW_ADS_CREATED.add(onEscrowAdsCreatedSuccess);
			GD.S_ESCROW_ADS_CREATE_FAIL.add(onEscrowAdsCreatedFail);
			GD.S_ESCROW_ADS_CREATE.invoke(escrowAdsVO);
			return true;
		}
		
		private function onEscrowAdsCreatedSuccess(escrowAdsVONew:EscrowAdsVO):void {
			escrowAdsVO = escrowAdsVONew;
			GD.S_ESCROW_ADS_CREATED.remove(onEscrowAdsCreatedSuccess);
			GD.S_ESCROW_ADS_CREATE_FAIL.remove(onEscrowAdsCreatedFail);
			fillList();
			topBar.setActions( [ actionTrash ] );
		}
		
		private function onEscrowAdsCreatedFail(message:String = null):void {
			GD.S_ESCROW_ADS_CREATED.remove(onEscrowAdsCreatedSuccess);
			GD.S_ESCROW_ADS_CREATE_FAIL.remove(onEscrowAdsCreatedFail);
		}
		
		private function showPreloader():void {
			preloader.show();
		}
		
		private function hidePreloader():void {
			if (preloader != null)
				preloader.hide();
		}
		
		private function activate():void {
			busy = false;
			if (preloader != null)
				preloader.hide();
			hidePreloader();
			
			if (list != null)
				list.refresh();
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
			
			escrowAdsVO = null;
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
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			super.clearView();
		}
		
		override public function dispose():void {
			echo("QuestionCreateUpdateScreen", "dispose", "");
			
			removeKeyboardAction();
			
			_data = null;
			super.dispose();
		}
		
		private function onTrashTap():void {
			GD.S_ESCROW_ADS_REMOVE.invoke(escrowAdsVO.uid);
			onBack();
		}
	}
}