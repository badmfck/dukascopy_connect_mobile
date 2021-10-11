package com.dukascopy.connect.screens {
	
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.escrow.EscrowSide;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.customActions.GetNumericKeyboardAction;
	import com.dukascopy.connect.gui.chat.BubbleButton;
	import com.dukascopy.connect.gui.list.renderers.ListCryptoWallet;
	import com.dukascopy.connect.gui.list.renderers.ListEscrowSide;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsFilterVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowPriceScreen;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.langs.Lang;
	import com.forms.Form;
	import com.forms.FormComponent;
	import flash.display.Bitmap;
	import flash.filesystem.File;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov
	 */
	
	public class EscrowAdsCreateScreenForm extends BaseScreen {
		
		private const DEFAULT_BACKGROUND_COLOR:uint = 0xE9F3FB;
		
		private var preloader:Preloader;
		private var answersCountButton:BubbleButton;
		private var questionButtonBG:Bitmap;
		
		private var busy:Boolean = false;
		
		private var getKeyboardAction:GetNumericKeyboardAction;
		
		private var amountString:String;
		
		private var escrowAdsVO:EscrowAdsVO = new EscrowAdsVO(null);
		
		private var form:Form;
		private var btnBack:FormComponent;
		private var btnSide:FormComponent;
		private var btnInstrument:FormComponent;
		private var btnAmount:FormComponent;
		private var btnPrice:FormComponent;
		private var lblSide:FormComponent;
		private var lblInstrument:FormComponent;
		private var lblAmount:FormComponent;
		private var lblPrice:FormComponent;
		private var lblCurrency:FormComponent;
		
		public function EscrowAdsCreateScreenForm() { }
		
		override protected function createView():void {
			super.createView();
			
            form = new Form(File.applicationDirectory.resolvePath("forms"+File.separator+"escrowDealCreate.xml"));
			form.showDeviceFrame("iosx");
			view.addChild(form.view);
			form.onDocumentLoaded=function():void {
				btnBack = form.getComponentByID("btnBack");
				if (btnBack != null)
					btnBack.onTap = onBackButtonTap;
				btnSide = form.getComponentByID("btnSide");
				if (btnSide != null)
					btnSide.onTap = onSideButtonTap;
				btnInstrument = form.getComponentByID("btnInstrument");
				if (btnInstrument != null)
					btnInstrument.onTap = onInstrumentButtonTap;
				btnAmount = form.getComponentByID("btnAmount");
				if (btnAmount != null)
					btnAmount.onTap = onAmountButtonTap;
				btnPrice = form.getComponentByID("btnPrice");
				if (btnPrice != null)
					btnPrice.onTap = onPriceButtonTap;
				lblSide = form.getComponentByID("lblSide");
				lblInstrument = form.getComponentByID("lblInstrument");
				lblAmount = form.getComponentByID("lblAmount");
				lblPrice = form.getComponentByID("lblPrice");
				lblCurrency = form.getComponentByID("lblCurrency");
			};
			
			form.setupUserValues( {
				mainText: Lang.tenderStartText1,
				termsAndConditions: Lang.termsAndConditions
			} );
			
			preloader = new Preloader();
			preloader.visible = false;
			preloader.hide();
			view.addChild(preloader);
		}
		
		/**
		 * @param	data - Object with initialized params (fo r exaple - list of searched conversations or etc..)
		 */
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			form.setSize(_width, _height);
			
			GD.S_ESCROW_ADS_FILTER_REQUEST.invoke(onFilter);
		}
		
		override protected function drawView():void {
			if (_isDisposed)
				return;
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = _height * .5;
			}
			form.setSize(_width, _height);
		}
		
		private function activate():void {
			busy = false;
			if (preloader != null)
				preloader.hide();
			hidePreloader();
		}
		
		override public function deactivateScreen():void {
			if (!_isActivated)
				return;
			_isActivated = false;
		}
		
		override public function activateScreen():void {
			if (isDisposed)
				return;
			if (_isActivated)
				return;
			_isActivated = true;
		}
		
		private function onFilter(escrowAdsFilterVO:EscrowAdsFilterVO):void {
			if (escrowAdsFilterVO != null && escrowAdsFilterVO.instrument != null)
				callBackSelectInstrument(escrowAdsFilterVO.instrument);
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
			/*msgPrice.params = { price:val, currency:currency }
			list.getItemByNum(4).data.updateText(Config.BOUNDS + JSON.stringify(msgPrice));
			list.updateItemByIndex(4);*/
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
					/*msgAmount.params = { val:val }
					list.getItemByNum(3).data.updateText(Config.BOUNDS + JSON.stringify(msgAmount));
					list.updateItemByIndex(3);*/
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
			/*msgAmount.params = { val:val }
			list.getItemByNum(3).data.updateText(Config.BOUNDS + JSON.stringify(msgAmount));
			list.updateItemByIndex(3);*/
		}
		
		private function onSideChanged(val:EscrowSide):void {
			if (val == null)
				return;
			escrowAdsVO.side = val.value;
			lblSide.textContent = val.name;
			/*msgSide.params = { val:val.value, name:val.lang }
			list.getItemByNum(1).data.updateText(Config.BOUNDS + JSON.stringify(msgSide));
			list.updateItemByIndex(1);*/
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
			escrowAdsVO.instrument = ei;
			/*msgCrypto.params = { code:ei.code, name:ei.name }
			list.getItemByNum(2).data.updateText(Config.BOUNDS + JSON.stringify(msgCrypto));
			list.updateItemByIndex(2, true, true);*/
		}
		
		
		
		private function onChatSend():Boolean {
			return true;
			/*if (busy == true)
				return false;
			busy = true;
			
			GD.S_ESCROW_ADS_CREATED.add(onEscrowAdsCreatedSuccess);
			GD.S_ESCROW_ADS_CREATE_FAIL.add(onEscrowAdsCreatedFail);
			GD.S_ESCROW_ADS_CREATE.invoke(escrowAdsVO);
			return true;*/
		}
		
		private function onEscrowAdsCreatedSuccess(escrowAdsVONew:EscrowAdsVO):void {
			/*escrowAdsVO = escrowAdsVONew;
			GD.S_ESCROW_ADS_CREATED.remove(onEscrowAdsCreatedSuccess);
			GD.S_ESCROW_ADS_CREATE_FAIL.remove(onEscrowAdsCreatedFail);
			fillList();
			topBar.setActions( [ actionTrash ] );*/
		}
		
		private function onEscrowAdsCreatedFail(message:String = null):void {
			/*GD.S_ESCROW_ADS_CREATED.remove(onEscrowAdsCreatedSuccess);
			GD.S_ESCROW_ADS_CREATE_FAIL.remove(onEscrowAdsCreatedFail);*/
		}
		
		private function showPreloader():void {
			preloader.show();
		}
		
		private function hidePreloader():void {
			if (preloader != null)
				preloader.hide();
		}
		
		
		
		private function onQuestionAnswers(qVO:QuestionVO):void {
			/*if (qVO != QuestionsManager.getCurrentQuestion())
				return;
			updateAnswersButtonState();*/
		}
		
		private function updateAnswersButtonState():void {
			/*if (QuestionsManager.getCurrentQuestion() == null) {
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
					topBar.setActions(null);*/
		}
		
		private function generateAnswerButtonText(answersCount:int = 0): String{
			return "";
			/*return "+" + answersCount + " answer" + (answersCount < 1 ? "" : "s");*/
		}
		
		private function createAnswersCountButton(btnText:String = ""):void	{
			/*var buttonText:String = btnText!=""?btnText:"Pp";
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
			}*/
		}
		
		private function openOtherAnswers():void {
			/*if (QuestionsManager.getCurrentQuestion() == null)
				return;
			if (QuestionsManager.getCurrentQuestion().type == "public") {
				AnswersManager.answer(QuestionsManager.getCurrentQuestion());
			} else {
				AnswersManager.getAnswersByQuestionUID(QuestionsManager.getCurrentQuestion().uid);
			}*/
		}
		
		public function onBackButtonTap():void {
			onBack();
		}
		
		private function onSideButtonTap():void {
			DialogManager.showDialog(
				ListSelectionPopup, 
				{
					items:EscrowSide.COLLECTION,
					title:Lang.textSelectSide,
					renderer:ListEscrowSide,
					callback:onSideChanged
				}, ServiceScreenManager.TYPE_SCREEN
			);
		}
		
		private function onInstrumentButtonTap():void {
			GD.S_ESCROW_INSTRUMENTS.add(onResult);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
		}
		
		private function onAmountButtonTap():void {
			callKeyboard();
		}
		
		private function onPriceButtonTap():void {
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
		}
		
		private function createQuestionMessage(text:String, createdTime:Number = 0):Object {
			/*var messageData:Object = new Object();
			messageData.id = 0;
			messageData.user_avatar = Auth.avatar;
			messageData.user_name = Auth.username;
			messageData.text = text;
			messageData.usePlainText = true;
			messageData.created = createdTime;
			messageData.user_uid = Auth.uid;
			messageData.fxId = Auth.fxcommID;
			return messageData;*/
			return {};
		}
		
		override public function clearView():void {
			/*echo("QuestionCreateUpdateScreen", "clearView", "");
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
			topBar = null;*/
			super.clearView();
		}
		
		override public function dispose():void {
			/*echo("QuestionCreateUpdateScreen", "dispose", "");
			
			removeKeyboardAction();
			
			_data = null;*/
			super.dispose();
		}
		
		private function onTrashTap():void {
			/*GD.S_ESCROW_ADS_REMOVE.invoke(escrowAdsVO.uid);
			onBack();*/
		}
	}
}