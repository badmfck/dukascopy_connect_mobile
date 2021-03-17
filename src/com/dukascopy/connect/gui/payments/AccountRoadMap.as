package com.dukascopy.connect.gui.payments {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TransactionData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.dialogs.QueueUnderagePopup;
	import com.dukascopy.connect.screens.dialogs.calendar.RecognitionDateRemindPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.PendingTransactionsPopup;
	import com.dukascopy.connect.screens.roadMap.RoadMapScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quint;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * Created component because maybe used in few screens 
	 * 
	 * @author Alexey Skuryat & Ilya Shcherbakov
	 */
	
	public class AccountRoadMap extends Sprite {
		
		static private var lastBalanceData:Object = null;
		
		private var _viewWidth:int = 100;
		private var _viewHeight:int = 100;
		
		private var labelFontSize:int = Config.FINGER_SIZE * .22;
		private var titleFontSize:int = Config.FINGER_SIZE * .3;
		private var amountFontSize:int = Config.FINGER_SIZE * .55;
		private var currencyFontSize:int = Config.FINGER_SIZE * .5;
		
		private var buttonRTO:BitmapButton;
		private var buttonVideo:BitmapButton;
		private var buttonBank:BitmapButton;
		private var buttonStartChat:BitmapButton;
		
		private var labelStartChat:Bitmap;
		private var labelBalance:Bitmap;
		private var labelCurrencyName:Bitmap;
		private var labelCurrencyAmount:Bitmap;
		private var labelDukat:Bitmap;
		private var labelDukatAmount:Bitmap;
		
		private var stateBubbleRTO:Bitmap;
		private var stateBubbleVideo:Bitmap;
		private var stateBubbleBank:Bitmap;
		private var stateBubbleConnectionLine:Bitmap;
		private var stateBubbleConnectionLine2:Bitmap;
		
		private var separatorLine:Bitmap;
		private var separatorLineHor:Bitmap;
		
		private var preloader:Preloader;
		
		// Y of bubbles 
		private var Y_RTO:int = 0;
		private var Y_VIDEO:int = 0;
		private var Y_BANK:int = 0;
		
		private var X_RTO:int = 0;
		private var X_VIDEO:int = 0;
		private var X_BANK:int = 0;
		
		// lines coords 
		private var Y_LINE_1:int = 0;
		private var Y_LINE_2:int = 0;
		
		private var X_LINE_1:int = 0;
		private var X_LINE_2:int = 0;
		
		private var HEIGHT_LINE_1:int = 0;
		private var HEIGHT_LINE_2:int = 0;
		
		
		private var BUTTON_HEIGHT:int = 140;
		private var BUBBLE_HEIGHT:int = Config.FINGER_SIZE * .45;
		private var BOTTOM_MENU_HEIGHT:int = 100;
		private var BOTTOM_MENU_SPACING:int = BOTTOM_MENU_HEIGHT*.3;
		
		// Currency ammount
		private var _amountValue:String = "";
		private var _dukatValue:String = "";
		private var _dukatLabel:String = "";
		private var _currencyValue:String = "";
		
		// There will be 4 states -> empty , current , done, fail(/) -1 0 1  -2(fail
		/// flags for bubbles 
		private var RTO_STATE:int = -1;// empty 
		private var VID_STATE:int = -1;// empty
		private var ACC_STATE:int = -1; // empty
				
		// used for invalidation for not to redraw many times if state was the same as previous 
		private var _currentRTOState:int = -3;
		private var _currentVIDState:int = -4;
		private var _currentBANKState:int = -3;
		
		
		// flags for lines 
		private var COLOR_GREEN:uint = 0x5cae23;
		private var COLOR_GREY:uint = 0x969697;
		private var COLOR_RED:uint = 0xff0000;
		private var COLOR_BLUE:uint = 0x005bff;
		
		private var LINE_A_COLOR:uint = COLOR_GREY;
		private var LINE_B_COLOR:uint = COLOR_GREY;
		
		
		// bg
		private var bg:Bitmap = new Bitmap(new BitmapData(1, 1, false, 0xf7f7f7));
		
		// screen flags
		private var _isShown:Boolean = false;
		private var _isShowComplete:Boolean = false;
		private var _isActive:Boolean = false;
		private var _isDisposed:Boolean = false;
		
		// reusable assets 
		private var chatIconAsset:SWFChatIconRoadMap;
		private var iconCheckEmpty:SWFCheckIconOutlinedEmpty;
		private var iconCheckCurrent:SWFCheckIconOutlinedCurrent;
		private var iconCheckComplete:SWFCheckIconOutlinedBold;
		private var iconCheckFailed:SWFCheckIconOutlinedFailed;

		// Assets for bubbles 
		private var bubbleAssetEmpty:SWFCheckIconOutlinedEmpty;
		private var bubbleAssetCurrent:SWFCheckIconOutlinedCurrent;
		private var bubbleAssetChecked:SWFCheckIconOutlinedBold;
		
		// Balance 		
		private var _currentBalanceValue:String = "";
		private var _currentDukatBalanceValue:String = "";
		private var _currentBalanceCurrency:String = "";
		private var _isLoadingBalance:Boolean = false;
		
		// Flag for draw two DUK+EUR or one currency EUR 
		private var _hasTwoCurrencies:Boolean = false;
		
		private var statesArray:Array = ["EMPTY","VIDID","VIDID_READY","VIDID_PROGRESS","VI_FAIL", "VI_COMPLETED","ACC_CREATED","ACC_APPROVED","REJECT","NOTARY"];
		private var appontmentClip:Bitmap;
		private var pandingClick:Sprite;
		private var pendingTransactions:Vector.<TransactionData>;
		private var buttonRefreshBalance:BitmapButton;
		private static var lastIgnoreCache:Number = 0;
		
		public function AccountRoadMap() {
			addChild(bg);
			createView();
		}
		
		private function createView():void {
			buttonRTO = createButton(onButtonClickRTO);
			buttonVideo = createButton(onButtonClickVideo);
			buttonBank = createButton(onButtonClickBank);
			buttonStartChat = createButton(onButtonClickBank, .9);
			
			pandingClick = new Sprite();
			addChild(pandingClick);
			
			labelStartChat = new Bitmap();
			labelStartChat.alpha = 0;
			addChild(labelStartChat);
			labelBalance = new Bitmap();
			labelBalance.alpha = 0;
			addChild(labelBalance);
			labelCurrencyName = new Bitmap();
			labelCurrencyName.alpha = 0;
			addChild(labelCurrencyName);
			labelCurrencyAmount = new Bitmap();
			labelCurrencyAmount.alpha = 0;
			addChild(labelCurrencyAmount);
			labelDukat = new Bitmap();
			labelDukat.alpha = 0;
			addChild(labelDukat);
			labelDukatAmount = new Bitmap();
			labelDukatAmount.alpha = 0;
			addChild(labelDukatAmount);
			stateBubbleConnectionLine = new Bitmap(new BitmapData(3, 2, false, 0x969697));
			stateBubbleConnectionLine.visible = false;
			addChild(stateBubbleConnectionLine);
			stateBubbleConnectionLine2 = new Bitmap(new BitmapData(3, 2, false, 0x969697));
			stateBubbleConnectionLine2.visible = false;
			addChild(stateBubbleConnectionLine2);
			stateBubbleRTO = new Bitmap();
			addChild(stateBubbleRTO);
			stateBubbleVideo = new Bitmap();
			addChild(stateBubbleVideo);
			stateBubbleBank = new Bitmap();
			addChild(stateBubbleBank);
			separatorLine = new Bitmap(new BitmapData(2, 2, false, 0xdfe0e1));
			addChild(separatorLine);
			separatorLineHor = new Bitmap(new BitmapData(2, 2, false, 0xdfe0e1));
			addChild(separatorLineHor);
			
			setBubbleState(stateBubbleRTO, RTO_STATE);
			setBubbleState(stateBubbleVideo, VID_STATE);
			setBubbleState(stateBubbleBank, ACC_STATE);	
			
			hideBubbleInstance(stateBubbleRTO);
			hideBubbleInstance(stateBubbleVideo);
			hideBubbleInstance(stateBubbleBank);
			
			buttonRefreshBalance = createButton(onButtonClickRefresh, 1);
			buttonRefreshBalance.setOverflow(Config.FINGER_SIZE * 0.5, Config.FINGER_SIZE * 0.5, Config.FINGER_SIZE * 0.5, Config.FINGER_SIZE * 0.5);
			buttonRefreshBalance.setDownScale(1.05);
			buttonRefreshBalance.show();
			buttonRefreshBalance.visible = false;
			
			var icon:Sprite = new (Style.icon(Style.ICON_REFRESH));
			UI.scaleToFit(icon, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			buttonRefreshBalance.setBitmapData(UI.getSnapshot(icon));
		}
		
		private function onButtonClickRefresh():void 
		{
			buttonRefreshBalance.visible = false;
		//	labelBalance.visible = false;
			labelCurrencyAmount.visible = false;
			labelCurrencyName.visible = false;
			labelDukat.visible = false;
			labelDukatAmount.visible = false;
			loadBalance(true);
		}
		
		public function init():void {
			onPhazeChanged();
			setStartChatLabel(Lang.CHAT_WITH_BANK);
			setBalanceLabel(Lang.PENDING_BALANCE);
			updateBalanceValues();
			loadBalance();
		}
		
		private function loadBalance(ignoreCache:Boolean = true):void {
			_isLoadingBalance = true;
			showPreloader();
			updateBalanceValues();
			if (((new Date()).getTime() - lastIgnoreCache)/(1000) < 10)
			{
				ignoreCache = false;
			}
			if (ignoreCache)
			{
				lastIgnoreCache = (new Date()).getTime();
			}
			PHP.loadBalance(onLoadBalanceComplete, "EUR", ignoreCache);
		}
		
		private function onLoadBalanceComplete(respond:PHPRespond = null):void {
			if (_isDisposed == true)
				return;
				
			labelCurrencyName.visible = true;
			labelCurrencyAmount.visible = true;
			labelDukat.visible = true;
			labelDukatAmount.visible = true;
			buttonRefreshBalance.visible = true;
			
			hidePreloader();
			_isLoadingBalance = false;
			if (respond.error == true || respond.data == -1) {
				echo("AccountRoadMap", "onLoadBalanceComplete", "Error: " + respond.errorMsg);
				_hasTwoCurrencies = false;
				if (respond.errorMsg.indexOf("thro.01") == 0 && AccountRoadMap.lastBalanceData != null) {
					setBalance(lastBalanceData);
					respond.dispose();
					return;
				}
				_currentBalanceValue = "";
				_currentDukatBalanceValue = "";
				updateBalanceValues();
				respond.dispose();
				return;
			}
			AccountRoadMap.lastBalanceData = respond.data;
			setBalance(lastBalanceData);
			respond.dispose();
		}
		
		private function setBalance(balanceData:Object):void {
			_hasTwoCurrencies = Config.START_DUK_AMMOUNT > 0;
			var realAmountDUK:Number = Config.START_DUK_AMMOUNT;
			if (balanceData == null) {
				_currentBalanceValue = "0.00";
			} else if (balanceData is Number) {
				_currentBalanceValue = balanceData + "";
			} else if (balanceData is Object) {
				if ("DOK" in balanceData == true && balanceData.DOK != null) {
					_hasTwoCurrencies = true;
					realAmountDUK += Number(balanceData.DOK); 
				}
				_currentBalanceValue = balanceData.SUMM + "";
			}
			_currentDukatBalanceValue = realAmountDUK + "";
			updateBalanceValues();
			
		//	balanceData = {SUMM:213,FULL:[{amount:200,ccy:"RUB",expiration_timestamp:1577893630},{amount:1,ccy:"RUB",expiration_timestamp:1578067393},{amount:11,ccy:"RUB",expiration_timestamp:1578067431},{amount:1,ccy:"USD",expiration_timestamp:1578838967}]};
			
			if (balanceData != null && "FULL" in balanceData && balanceData.FULL != null && balanceData.FULL is Array)
			{
				pendingTransactions = new Vector.<TransactionData>();
				var transaction:TransactionData;
				
				for (var i:int = 0; i < balanceData.FULL.length; i++) 
				{
					transaction = new TransactionData(balanceData.FULL[i]);
					pendingTransactions.push(transaction);
				}
			}
		}
		
		private function updateBalanceValues():void {
			if (_isLoadingBalance == true) {
				setAmountValue("");
				setDukatLabel("");
				setDukatValue("");
			} else if (_currentBalanceValue == "") {
				setAmountValue("–");
				setDukatLabel("");
				setDukatValue("");
			} else {
				currencyFontSize = _hasTwoCurrencies ? Config.FINGER_SIZE * .3 : Config.FINGER_SIZE * .5;
				if (_hasTwoCurrencies == true) {
					setDukatLabel(Lang.BALANCE_DUK_CURRENCY_NAME);
					setDukatValue(_currentDukatBalanceValue);
				} else {
					setDukatLabel("");
					setDukatValue("");
				}
				setCurrencyValue(Lang.BALANCE_CURRENCY_NAME)
				setAmountValue(_currentBalanceValue);
			}
			pandingClick.graphics.clear();
			pandingClick.graphics.beginFill(0, 0);
			pandingClick.graphics.drawRect(0, 0, _viewWidth * .5, BOTTOM_MENU_HEIGHT);
			pandingClick.graphics.endFill();
			pandingClick.x = width * .5;
			pandingClick.y = height - BOTTOM_MENU_HEIGHT;
		}
		
		public function activate():void {
			if (_isDisposed == true)
				return;
			_isActive = true;
			if (_isShowComplete == false)
				return;
			if (buttonRTO != null)
				buttonRTO.activate();
			if (buttonRefreshBalance != null)
				buttonRefreshBalance.activate();
			if (buttonVideo != null)
				buttonVideo.activate();
			if (buttonBank != null)
				buttonBank.activate();
			if (buttonStartChat != null)
				buttonStartChat.activate();
			if (appontmentClip != null)
				checkCurrentAppointment();
			PointerManager.addTap(pandingClick, openTransactions);
		}
		
		private function openTransactions(e:Event  = null):void 
		{
			DialogManager.showDialog(PendingTransactionsPopup, {items:pendingTransactions});
		}
		
		private function checkCurrentAppointment():void {
			if (Calendar.viAppointmentData == null) {
				if (appontmentClip != null) {
					UI.destroy(appontmentClip);
					if (contains(appontmentClip) == true) {
						try {
							removeChild(appontmentClip);
						} catch (err:Error) {
							echo("AccountRoadMap", "checkCurrentAppointment", "JSON Error: " + err.message);
							ApplicationErrors.add();
						}
					}
					appontmentClip = null;
				}
				var cState:int = _currentVIDState;
				_currentVIDState = -1;
				setBubbleVIDState(cState, false);
			}
		}
		
		public function deactivate():void {
			if (_isDisposed == true)
				return;
			_isActive = false;
			if (buttonRTO != null)
				buttonRTO.deactivate();
			if (buttonRefreshBalance != null)
				buttonRefreshBalance.deactivate();
			if (buttonVideo != null)
				buttonVideo.deactivate();
			if (buttonBank != null)
				buttonBank.deactivate();
			if (buttonStartChat != null)
				buttonStartChat.deactivate();
			PointerManager.removeTap(pandingClick, openTransactions);
		}
		
		private function onPhazeChanged(...rest):void {
			updateFlagsOnPhaseChange();	
		}
		
		private function updateFlagsOnPhaseChange():void {
			TweenMax.killDelayedCallsTo(openInternetBank);
			if (Auth.bank_phase == null)
				return;
			LINE_A_COLOR = COLOR_GREY;
			LINE_B_COLOR = COLOR_GREY;
			switch (Auth.bank_phase) {
				case "EMPTY":
				case "RTO_STARTED":
					RTO_STATE = 0;
					VID_STATE = -1;
					ACC_STATE = -1;
					break;
				case "VIDID":
				case "VIDID_READY":
				case "VIDID_PROGRESS":
				case "VIDID_QUEUE":
					RTO_STATE = 1; 
					VID_STATE = 0;
					ACC_STATE = -1;
					break;
				case "VI_FAIL":
					LINE_A_COLOR = COLOR_RED;
					RTO_STATE = 1;
					VID_STATE = -2;
					ACC_STATE = -1; 
					break;
				case "VI_COMPLETED":
					LINE_A_COLOR = COLOR_GREEN;
					RTO_STATE = 1;
					VID_STATE = 1;
					ACC_STATE = 0;
					break;
				case "ACC_CREATED":
					LINE_A_COLOR = COLOR_GREEN;
					RTO_STATE = 1;
					VID_STATE = 1;
					ACC_STATE = 0;
					break;
				case "ACC_APPROVED":
					LINE_A_COLOR = COLOR_GREEN;
					LINE_B_COLOR = COLOR_GREEN;
					RTO_STATE = 1;
					VID_STATE = 1;
					ACC_STATE = 1;
					TweenMax.delayedCall(3, openInternetBank);
					break;
				case "REJECT":
					LINE_A_COLOR = COLOR_GREEN;
					LINE_B_COLOR = COLOR_RED;
					RTO_STATE = 1;
					VID_STATE = 1;
					ACC_STATE = -2;
					break;
				case "NOTARY":
					RTO_STATE = 1;
					VID_STATE = -3;
					ACC_STATE = -1;
					break;
				default:
					echo("AccountRoadMap", "updateFlagsOnPhaseChange", "PHASE NOT HANDLED");
			}
			updateBubblesDesignByStates();
			updateLinesColorsByStates();
		}
		
		private function openInternetBank():void {
			if (MobileGui.centerScreen.currentScreenClass == RoadMapScreen)
				MobileGui.openMyAccountIfExist();
		}
		
		private function updateBubblesDesignByStates():void {
			if (_isDisposed == true)
				return;
			setBubbleRTOState(RTO_STATE, true);
			setBubbleVIDState(VID_STATE, true);
			setBubbleBANKState(ACC_STATE, true);
		}
		
		private function setBubbleRTOState(state:int, useAnimation:Boolean = true):void {
			if (state == _currentRTOState)
				return;
			_currentRTOState = state;
			setBubbleState(stateBubbleRTO, _currentRTOState);
			if (useAnimation == true && _isShown == true)
				showBubbleInstance(stateBubbleRTO, .3,0, X_RTO, Y_RTO);
			drawButton(
				buttonRTO,
				getSectionTextHTML(
					getStringState(RTO_STATE),
					Lang.FILL_REG_FORM,
					labelFontSize,
					titleFontSize,
					getColorHTMLByState(RTO_STATE)
				)
			);
		}
		
		private function setBubbleVIDState(state:int, useAnimation:Boolean = true):void {
			if (state == _currentVIDState)
				return;
			_currentVIDState = state;
			setBubbleState(stateBubbleVideo, _currentVIDState);
			if (useAnimation == true && _isShown == true)
				showBubbleInstance(stateBubbleVideo, .3,0, X_VIDEO, Y_VIDEO);
			drawButton(
				buttonVideo,
				getSectionTextHTML(
					getStringState(VID_STATE),
					(state == -3) ? Lang.NOTARY_STATE_TEXT: Lang.FILL_VID_REG,
					labelFontSize,
					titleFontSize,
					getColorHTMLByState(VID_STATE)
				)
			);
			if (_currentVIDState == 0)
				loadVerificationReservationData();
		}
		
		private function loadVerificationReservationData():void {
			if (Calendar.viAppointmentData != null &&
				Calendar.viAppointmentData.success == true &&
				Calendar.viAppointmentData.exist == false)
					return;
			if (Calendar.viAppointmentData != null &&
				Calendar.viAppointmentData.success == true &&
				Calendar.viAppointmentData.exist == true) {
					drawViAppointment();
					return;
			}
			Calendar.S_APPOINTMENT_DATA.add(onAppointmentDataLoaded);
			Calendar.loadAppointmentData();
		}
		
		private function onAppointmentDataLoaded():void {
			Calendar.S_APPOINTMENT_DATA.remove(onAppointmentDataLoaded);
			if (Calendar.viAppointmentData != null &&
				Calendar.viAppointmentData.success == true &&
				Calendar.viAppointmentData.exist == true)
					drawViAppointment();
		}
		
		private function drawViAppointment():void {
			drawButton(
				buttonVideo,
				getSectionTextHTML(
					getStringState(VID_STATE),
					Lang.FILL_VID_REG,
					labelFontSize,
					titleFontSize,
					getColorHTMLByState(VID_STATE)
				),
				false
			);
			var cDate:Date = Calendar.viAppointmentData.date;
			var dateString:String = cDate.getDate().toString() + " " + Lang.getMonthTitleByIndex(cDate.getMonth()) + " " + cDate.getFullYear().toString() + ", ";
			var dateBD:ImageBitmapData = TextUtils.createTextFieldData(
				dateString,
				width - Config.DOUBLE_MARGIN * 7,
				10,
				false,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .34,
				false,
				0x6B7A8A,
				0xEDEEEF,
				true
			);
			var minutes:String = cDate.getMinutes().toString();
			if (minutes.length == 1)
				minutes = "0" + minutes;
			var hours:String = cDate.getHours().toString();
			if (hours.length == 1)
				hours = "0" + hours;
			var timeString:String = hours + ":" + minutes;
			var timeBD:ImageBitmapData = TextUtils.createTextFieldData(
				timeString,
				width - Config.DOUBLE_MARGIN * 7,
				10,
				false,
				TextFormatAlign.CENTER, 
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .34,
				false,
				0xFF6600,
				0xEDEEEF,
				true
			);
			var resultBD:ImageBitmapData = new ImageBitmapData("appointmentDate", dateBD.width + timeBD.width + Config.FINGER_SIZE * .1, Math.max(dateBD.height, timeBD.height));
			resultBD.copyPixels(dateBD, dateBD.rect, new Point(), null, null, true);
			resultBD.copyPixels(timeBD, timeBD.rect, new Point(dateBD.width + Config.FINGER_SIZE * .1, 0), null, null, true);
			cDate = null;
			dateBD.dispose();
			timeBD.dispose();
			dateBD = null;
			timeBD = null;
			if (appontmentClip == null) {
				appontmentClip = new Bitmap();
				addChild(appontmentClip);
				appontmentClip.x = Config.DOUBLE_MARGIN * 5;
			} else if (appontmentClip.bitmapData != null) {
				appontmentClip.bitmapData.dispose();
				appontmentClip.bitmapData = null;
			}
			appontmentClip.bitmapData = resultBD;
			appontmentClip.y = int(buttonVideo.y + buttonVideo.height * .5 + Config.FINGER_SIZE * .2);
		}
		
		private function setBubbleBANKState(state:int , useAnimation:Boolean = true):void {
			if (state == _currentBANKState)
				return;
			_currentBANKState = state;
			setBubbleState(stateBubbleBank, _currentBANKState);
			if (useAnimation == true && _isShown == true)
				showBubbleInstance(stateBubbleBank, .3,0, X_BANK, Y_BANK);
			drawButton(
				buttonBank,
				getSectionTextHTML(
					getStringState(ACC_STATE),
					Lang.APPROVE_ACCOUNT,
					labelFontSize,
					titleFontSize,
					getColorHTMLByState(ACC_STATE)
				)
			);
		}
		
		private function updateButtonsTexts():void {
			drawButton(
				buttonRTO,
				getSectionTextHTML(
					getStringState(RTO_STATE),
					Lang.FILL_REG_FORM,
					labelFontSize,
					titleFontSize,
					getColorHTMLByState(RTO_STATE)
				)
			);
			drawButton(
				buttonVideo,
				getSectionTextHTML(
					getStringState(VID_STATE),
					(VID_STATE == -3) ? Lang.NOTARY_STATE_TEXT: Lang.FILL_VID_REG,
					labelFontSize,
					titleFontSize,
					getColorHTMLByState(VID_STATE)
				)
			);
			drawButton(
				buttonBank,
				getSectionTextHTML(
					getStringState(ACC_STATE),
					Lang.APPROVE_ACCOUNT,
					labelFontSize,
					titleFontSize,
					getColorHTMLByState(ACC_STATE)
				)
			);
			chatIconAsset ||= new SWFChatIconRoadMap();
			buttonStartChat.setBitmapData(UI.renderAsset(chatIconAsset, BOTTOM_MENU_SPACING, BOTTOM_MENU_SPACING, false, "ChatICON.AccountRoadMap"), true);
		}
		
		private function updateLinesColorsByStates():void {
			UI.colorize(stateBubbleConnectionLine, LINE_A_COLOR);
			UI.colorize(stateBubbleConnectionLine2, LINE_B_COLOR);
		}
		
		private function showPreloader():void {
			if (preloader == null)
				preloader = new Preloader();
			updatePreloaderPosition();
			addChild(preloader);
			preloader.show();
		}
		
		private function hidePreloader(dispose:Boolean = false):void {
			if (preloader != null)
				preloader.hide(dispose);
		}
		
		private function updatePreloaderPosition():void {
			if (preloader != null) {
				preloader.y = _viewHeight - BOTTOM_MENU_HEIGHT * .5;
				preloader.x = (_viewWidth * .5) * 1.5 ;
			}
		}
		
		public function show():void	{
			if (_isDisposed == true || _isShown == true)
				return;
			_isShown = true;
			_isShowComplete  = false;
			buttonRTO.show(0);
			buttonVideo.show(0);
			buttonBank.show(0);
			buttonStartChat.show(.3, .5);
			
			showBubbleInstance(stateBubbleRTO, .3, .3 , X_RTO, Y_RTO);	
			showBubbleInstance(stateBubbleVideo, .3, .9, X_VIDEO, Y_VIDEO);
			showBubbleInstance(stateBubbleBank, .3, 1.5 , X_BANK, Y_BANK);
			
			var destLineHeight:int = BUTTON_HEIGHT * 2;
			TweenMax.killTweensOf(stateBubbleConnectionLine);
			stateBubbleConnectionLine.height = 0;
			stateBubbleConnectionLine.visible = true;
			TweenMax.to(stateBubbleConnectionLine, .3, { height:HEIGHT_LINE_1, ease:Quint.easeOut, delay:.6 } );
			
			TweenMax.killTweensOf(stateBubbleConnectionLine2);
			stateBubbleConnectionLine2.height = 0;
			stateBubbleConnectionLine2.visible = true;
			TweenMax.to(stateBubbleConnectionLine2, .3, { height:HEIGHT_LINE_2, ease:Quint.easeOut, delay:1.2, onComplete:onShowComplete } );
			
			labelStartChat.alpha = 0;
			TweenMax.to(labelStartChat, .3, { alpha:1, delay:.5 } );
			labelBalance.alpha = 0;
			TweenMax.to(labelBalance, .3, { alpha:1, delay:.5 } );
			labelCurrencyName.alpha = 0;
			labelCurrencyName.visible = true;
			TweenMax.to(labelCurrencyName, .3, { alpha:1, delay:.5 } );
			labelCurrencyAmount.alpha = 0;
			labelCurrencyAmount.visible = true;
			TweenMax.to(labelCurrencyAmount, .3, { alpha:1, delay:.5 } );
			labelDukat.alpha = 0;
			labelDukat.visible = true;
			TweenMax.to(labelDukat, .3, { alpha:1, delay:.5 } );
			labelDukatAmount.alpha = 0;
			labelDukatAmount.visible = true;
			TweenMax.to(labelDukatAmount, .3, { alpha:1, delay:.5 } );
		}
		
		private function onShowComplete():void {
			_isShowComplete = true;
			if (_isActive == true)
				activate();
			Auth.S_PHAZE_CHANGE.add(onPhazeChanged);
			onPhazeChanged();
		}
		
		public function onLangChange():void {
			if (_isDisposed == true)
				return;
			setStartChatLabel(Lang.CHAT_WITH_BANK);
			setBalanceLabel(Lang.PENDING_BALANCE);
			setCurrencyValue(Lang.BALANCE_CURRENCY_NAME);
			updateButtonsTexts();
		}
		
		private function showBubbleInstance(bubble:Bitmap, _time:Number = 0, _delay:Number = 0, anchorX:int = 0, anchorY:int = 0):void {
			if (bubble == null)
				return;
			TweenMax.killTweensOf(bubble);
			if (bubble.bitmapData != null) {
				bubble.x = anchorX + bubble.bitmapData.width * .5;
				bubble.y = anchorY + bubble.bitmapData.height * .5;
			}
			bubble.scaleX = bubble.scaleY = 0;
			bubble.visible = true;
			TweenMax.to(bubble, .3, { scaleX:1, scaleY:1, x:anchorX, y:anchorY, ease:Back.easeInOut, delay:_delay } );
		}
		
		private function hideBubbleInstance(bubble:Bitmap, _time:Number = 0, _delay:Number = 0):void {
			TweenMax.killTweensOf(bubble);
			bubble.scaleX = bubble.scaleY = 0.1;
			bubble.visible = false;
		}
		
		private function createButton(onTap:Function, downScale:Number = 1):BitmapButton {
			var btn:BitmapButton = new BitmapButton();
			btn.setStandartButtonParams();
			btn.setDownScale(downScale);
			btn.usePreventOnDown = false;
			btn.cancelOnVerticalMovement = true;
			btn.tapCallback = onTap;
			btn.hide();
			addChild(btn);
			return btn;
		}
		
		private function onButtonClickRTO():void {
			if (RTO_STATE == 0)
				PayAPIManager.openSwissRTO();
		}
		
		private function onButtonClickVideo():void {
			if (VID_STATE == 0) {
				if (Calendar.viAppointmentData != null &&
					Calendar.viAppointmentData.success == true &&
					Calendar.viAppointmentData.exist == true) {
						DialogManager.showDialog(RecognitionDateRemindPopup, null);
						return;
				}
				openVideoIdentificationChat();
				return;
			}
			if (VID_STATE == -2) {
				openVideoIdentificationChat();
				return;
			}
			if (VID_STATE == -3){
				if (Config.FAST_TRACK == true)
				{
					DialogManager.showDialog(QueueUnderagePopup);
				}
				else
				{
					openVideoIdentificationChat();
				}
				
			//	DialogManager.showNotaryDialog();
			}
		}
		
		private function onButtonClickBank():void {
			openSupportChat();
		}
		
		private function onButtonClickChat():void {
			openVideoIdentificationChat();
		}
		
		private function openSupportChat():void	{
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_VI_DEF;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function openVideoIdentificationChat():void	{
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_VI_DEF;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		public function setDukatLabel(amount:String = ""):void {
			_dukatLabel = amount;
			if (labelDukat != null) {
				drawLabel(labelDukat, _dukatLabel, _viewWidth * .5, currencyFontSize, COLOR_GREEN);
				updateDukatValuePositionAndSizes();
				updateDukatLabelPositionAndSizes();
			}
		}
		
		public function setDukatValue(amount:String = ""):void {
			_dukatValue = amount;
			if (labelDukatAmount != null) {
				drawLabelAdvanced(labelDukatAmount, _dukatValue, _viewWidth * .5, amountFontSize, 0x6E92AF);
				labelDukatAmount.transform.matrix.identity();
				updateDukatValuePositionAndSizes();
				updateDukatLabelPositionAndSizes();
			}
		}
		
		public function setAmountValue(amount:String = ""):void {
			_amountValue = amount;
			if (labelCurrencyAmount != null) {
				drawLabelAdvanced(labelCurrencyAmount, _amountValue, _viewWidth * .5, amountFontSize, 0x6E92AF);
				labelCurrencyAmount.transform.matrix.identity();
				updateAmountLabelPositionAndSizes();
				updateCurrencyLabelPositionAndSizes();
			}
		}
		
		public function setCurrencyValue(currency:String = ""):void {
			if (_currencyValue == currency)
				return;
			_currencyValue = currency;
			redrawCurrencyName();
		}
		
		private function redrawCurrencyName():void {
			drawLabel(labelCurrencyName, _currencyValue, _viewWidth * .5, currencyFontSize, COLOR_GREEN);
			updateBalanceLabelPositionAndSizes();
			updateCurrencyLabelPositionAndSizes();
		}
		
		public function setStartChatLabel(value:String=""):void {
			drawLabel(labelStartChat, value, _viewWidth * .5, labelFontSize);
			updateStartChatLabelPositionAndSizes();
		}
		
		public function setBalanceLabel(value:String = ""):void {
			drawLabel(labelBalance,value, _viewWidth * .5,labelFontSize);
			updateBalanceLabelPositionAndSizes();
		}
		
		public function setSize(w:int, h:int ):void {
			if (_viewWidth != w || _viewHeight != h) {
				_viewWidth = w;
				_viewHeight = h;
				updateViewPort();
			}
		}
		
		private function updateViewPort():void {
			if (_isDisposed == true)
				return;
			bg.width = _viewWidth;
			bg.height = _viewHeight;
			
			BUTTON_HEIGHT = _viewHeight / 5;
			BOTTOM_MENU_HEIGHT = _viewHeight - BUTTON_HEIGHT * 3;
			BOTTOM_MENU_SPACING  = BOTTOM_MENU_HEIGHT * .3;
			
			updateButtonsTexts();
			
			var prevY:int = 0;
			Y_LINE_1 = int(prevY + BUTTON_HEIGHT * .5);
			X_LINE_1 = int( Config.DOUBLE_MARGIN * 2 +BUBBLE_HEIGHT * .5 -1);
			Y_LINE_2 =  int(prevY+BUTTON_HEIGHT * 1.5);
			X_LINE_2 =  int(Config.DOUBLE_MARGIN * 2 +BUBBLE_HEIGHT * .5 -1);
			
			HEIGHT_LINE_1 = BUTTON_HEIGHT+ BUBBLE_HEIGHT * .5;
			HEIGHT_LINE_2 = BUTTON_HEIGHT;
			
			if(stateBubbleConnectionLine != null){
				stateBubbleConnectionLine.y = Y_LINE_1;
				stateBubbleConnectionLine.x = X_LINE_1;
				stateBubbleConnectionLine.height = HEIGHT_LINE_1;
			}
			
			if(stateBubbleConnectionLine2 != null){
				stateBubbleConnectionLine2.y =Y_LINE_2
				stateBubbleConnectionLine2.x = X_LINE_2
				stateBubbleConnectionLine2.height = HEIGHT_LINE_2;
			}
			
			Y_RTO =  prevY + BUTTON_HEIGHT * .5  - BUBBLE_HEIGHT*.5;
			X_RTO =  Config.DOUBLE_MARGIN * 2;
			
			if (buttonRTO != null){
				stateBubbleRTO.y = Y_RTO;
				stateBubbleRTO.x = X_RTO;
				buttonRTO.y = prevY;
				buttonRTO.x = 0;
			}
			
			prevY += BUTTON_HEIGHT;
			Y_VIDEO =  prevY + BUTTON_HEIGHT * .5  - BUBBLE_HEIGHT*.5;
			X_VIDEO =  Config.DOUBLE_MARGIN * 2;
			
			if (buttonVideo != null) {
				stateBubbleVideo.y = Y_VIDEO;
				stateBubbleVideo.x = X_VIDEO;
				buttonVideo.y = prevY;
				buttonVideo.x = 0;
			}
			
			prevY += BUTTON_HEIGHT;
			Y_BANK =  prevY + BUTTON_HEIGHT * .5  - BUBBLE_HEIGHT*.5;
			X_BANK =  Config.DOUBLE_MARGIN * 2;
			
			if (buttonBank != null) {
				stateBubbleBank.y = Y_BANK;
				stateBubbleBank.x = X_BANK;
				
				buttonBank.y = prevY;
				buttonBank.x = 0;
				prevY += BUTTON_HEIGHT;
			}
			
			separatorLineHor.width  = _viewWidth;
			separatorLineHor.y = prevY;
			separatorLineHor.x = 0;
			
			separatorLine.x = _viewWidth * .5;
			separatorLine.y = prevY;
			separatorLine.height = _viewHeight - prevY;
			
			updateStartChatLabelPositionAndSizes();
			updateBalanceLabelPositionAndSizes();
			
			updateDukatValuePositionAndSizes();
			updateDukatLabelPositionAndSizes();
			updateAmountLabelPositionAndSizes();
			updateCurrencyLabelPositionAndSizes();
			
			updatePreloaderPosition();
			
			if (buttonStartChat != null) {
				var topOffset:int = BOTTOM_MENU_SPACING * 1.21;
				var bottomOffset:int = BOTTOM_MENU_SPACING * 1.21;
				var sideOffset:int = (_viewWidth * .5 - BOTTOM_MENU_SPACING ) * .5;
				buttonStartChat.x = int(_viewWidth * .25 - buttonStartChat.width * .5);
				buttonStartChat.y = prevY + BOTTOM_MENU_SPACING * 1.5 - buttonStartChat.height * .5 + BOTTOM_MENU_SPACING * .21;
				buttonStartChat.setOverflow(topOffset, sideOffset, sideOffset, bottomOffset);
			}
		}
		
		private function updateDukatLabelPositionAndSizes():void {
			if (labelDukat == null || labelDukat.width == 0)
				return;
			labelDukat.x = int(labelDukatAmount.x + labelDukatAmount.width + Config.MARGIN);
			labelDukat.y = labelDukatAmount.y + labelDukatAmount.height - labelDukat.height;
		}
		
		private function updateDukatValuePositionAndSizes():void {
			if (labelDukatAmount == null || labelDukatAmount.width == 0)
				return;
			var maxWidth:int = _viewWidth * .5 - 20;
			if (labelDukatAmount.width > maxWidth)
				UI.scaleToFit(labelDukatAmount,maxWidth, BOTTOM_MENU_SPACING);
			labelDukatAmount.x = int((_viewWidth * .5) * 1.5 - (labelDukatAmount.width + labelDukat.width + Config.MARGIN) * .5);
			if (_hasTwoCurrencies)
				labelDukatAmount.y = int(_viewHeight - BOTTOM_MENU_HEIGHT * .6 - labelDukatAmount.height);
		}
		
		private function updateAmountLabelPositionAndSizes():void {
			if (labelCurrencyAmount == null || labelCurrencyAmount.width == 0)
				return;
			var maxWidth:int = _viewWidth * .5 - 20;
			if (labelCurrencyAmount.width > maxWidth)
				UI.scaleToFit(labelCurrencyAmount, maxWidth, BOTTOM_MENU_SPACING);
			labelCurrencyAmount.x = int((_viewWidth * .5) * 1.5 - (labelCurrencyAmount.width + labelCurrencyName.width + Config.MARGIN) * .5);
			if (_hasTwoCurrencies)
				labelCurrencyAmount.y = labelDukatAmount.y + labelDukatAmount.height + Config.MARGIN * 2;
			else
				labelCurrencyAmount.y = int(_viewHeight - BOTTOM_MENU_HEIGHT * .5 - labelCurrencyAmount.height * .5);
		}
		
		private function updateCurrencyLabelPositionAndSizes():void {
			if (labelCurrencyName == null || labelCurrencyName.width == 0)
				return;
			labelCurrencyName.x = int(labelCurrencyAmount.x + labelCurrencyAmount.width + Config.MARGIN);
			labelCurrencyName.y = int(labelCurrencyAmount.y + labelCurrencyAmount.height - labelCurrencyName.height);
			
			buttonRefreshBalance.y = int(labelCurrencyName.y + labelCurrencyName.height + Config.MARGIN * 3);
			buttonRefreshBalance.x = int((_viewWidth * .5) * 1.5 - buttonRefreshBalance.width * .5);
		}
		
		private function updateStartChatLabelPositionAndSizes():void {
			if (labelStartChat == null)
				return;
			labelStartChat.x = int((_viewWidth * .5) * .5 - labelStartChat.width * .5);
			labelStartChat.y = int(_viewHeight - BOTTOM_MENU_HEIGHT + BOTTOM_MENU_SPACING * .5 - labelStartChat.height * .5);
		}
		
		private function updateBalanceLabelPositionAndSizes():void {
			if (labelBalance == null)
				return;
			labelBalance.x = int((_viewWidth * .5) * 1.5 - labelBalance.width * .5);
			labelBalance.y = int(_viewHeight - BOTTOM_MENU_HEIGHT + BOTTOM_MENU_SPACING * .5 - labelBalance.height * .5);
		}
		
		private function drawLabel(bmp:Bitmap, text:String="", width:int = 300, fontSize:Number = 10, textColor:uint= AppTheme.GREY_MEDIUM):void {
			if (bmp.bitmapData != null)
				UI.disposeBMD(bmp.bitmapData);
			bmp.bitmapData = TextUtils.createTextFieldData(
				text,
				width,
				10,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				fontSize,
				false,
				textColor,
				0xFFFFFF
			);
		}
		
		private function drawLabelAdvanced(bmp:Bitmap, text:String="", width:int = 300, fontSize:Number = 10, textColor:uint= AppTheme.GREY_MEDIUM):void {
			if (bmp.bitmapData != null)
				UI.disposeBMD(bmp.bitmapData);
			bmp.bitmapData = TextUtils.createTextFieldData(
				text,
				width,
				10,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				fontSize,
				false,
				textColor,
				0xFFFFFF, false, true
			);
		}
		
		private function drawButton(btn:BitmapButton, text:String, alignVertical:Boolean = true):void {
			var BMD:BitmapData = UI.renderTextPlane2(
				text,
				_viewWidth,
				BUTTON_HEIGHT,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				18,
				true,
				0x3b4452,
				0xedeeef,
				0xdfe0e1,
				0,
				1,
				Config.DOUBLE_MARGIN * 5,
				Config.DOUBLE_MARGIN * 2,
				Config.FINGER_SIZE * .25,
				true,
				0,
				false,
				alignVertical
			);
			btn.setBitmapData(BMD, true);
			btn.setOverflow(0, 0, 0, 0);
		}
		
		public function setBubbleState(bmp:Bitmap, state:int = -1):void {
			var iconChecked:Sprite;
			if (state == -1) {
				iconCheckEmpty ||= new SWFCheckIconOutlinedEmpty();
				iconChecked = iconCheckEmpty;
			} else if (state == 0 || state == -3) {
				iconCheckCurrent ||= new SWFCheckIconOutlinedCurrent();
				iconChecked = iconCheckCurrent;
			} else if (state == 1) {
				iconCheckComplete ||= new SWFCheckIconOutlinedBold()
				iconChecked = iconCheckComplete;
			} else if (state == -2) {
				iconCheckFailed ||= new SWFCheckIconOutlinedFailed()
				iconChecked = iconCheckFailed;
			}
			if (iconChecked != null) {
				iconChecked.width = iconChecked.height = BUBBLE_HEIGHT;
				bmp.bitmapData = UI.renderAsset(iconChecked, BUBBLE_HEIGHT, BUBBLE_HEIGHT, false, "StateAsset.STATE" + state);
			}
		}
		
		public static function getSectionTextHTML(subtitle:String, title:String, fontSizeSubtitle:int, fontSizeTitle:int, subtitleColor:String = "#93a2ae", titleColor:String = "#3b4452"):String {
			return "<font color='" + subtitleColor + "' size='" + fontSizeSubtitle + "'>" + subtitle + "</font><br>" + 
				   "<font color='" + titleColor + "' size='" + fontSizeTitle + "'>" + title + "</font>";
		}
		
		public static function getCurrencyTextHTML(fullPart:String, decimalPart:String, fontSizeFullpart:int, fontSizeDecimal:int, fullPartColor:String = "#93a2ae", decimalPartColor:String = "#3b4452"):String {
			return "<font color='" + fullPartColor + "' size='" + fontSizeFullpart + "'>" + fullPart + "</font>" + 
				   "<font color='" + decimalPartColor + "' size='" + fontSizeDecimal + "'>" + decimalPart + "</font>";
		}
		
		private function getStringState(state:int):String {
			if (state == -1 || state == -3)
				return Lang.MY_ACC_WAITING.toUpperCase();
			if (state == 0)
				return Lang.PRESS_TO_START.toUpperCase();
			if (state == 1)
				return Lang.MY_ACC_COMPLETED.toUpperCase();
			if (state == -2)
				return Lang.MY_ACC_FAILED.toUpperCase();
			return "";
		}
		
		private function getColorHTMLByState(state:int):String {
			var color:uint;
			if (state == 0 || state == -3)
				color = COLOR_BLUE;
			else if (state == 1)
				color = COLOR_GREEN;
			else if (state == -2)
				color = COLOR_RED;
			else
				color = COLOR_GREY;
			return "#" + color.toString(16);
		}
		
		public function dispose():void	{
			if (_isDisposed == true)
				return;
			Calendar.S_APPOINTMENT_DATA.remove(onAppointmentDataLoaded);
			Auth.S_PHAZE_CHANGE.remove(onPhazeChanged);
			if (stateBubbleConnectionLine != null)
				TweenMax.killTweensOf(stateBubbleConnectionLine);
			if (stateBubbleConnectionLine2 != null)
				TweenMax.killTweensOf(stateBubbleConnectionLine2);
			if (labelStartChat != null)
				TweenMax.killTweensOf(labelStartChat);
			if (labelBalance != null)
				TweenMax.killTweensOf(labelBalance);
			if (labelCurrencyName != null)
				TweenMax.killTweensOf(labelCurrencyName);
			if (labelDukat != null)
				TweenMax.killTweensOf(labelDukat);
			if (labelDukatAmount != null)
				TweenMax.killTweensOf(labelDukatAmount);
			if (labelCurrencyAmount != null)
				TweenMax.killTweensOf(labelCurrencyAmount);
			if (stateBubbleRTO != null)
				TweenMax.killTweensOf(stateBubbleRTO);
			if (stateBubbleVideo != null)
				TweenMax.killTweensOf(stateBubbleVideo);
			if (stateBubbleBank != null)
				TweenMax.killTweensOf(stateBubbleBank);	
			chatIconAsset = null;
			iconCheckEmpty = null;
			iconCheckCurrent = null;
			iconCheckComplete = null;
			iconCheckFailed = null;
			bubbleAssetEmpty = null;
			bubbleAssetCurrent = null;
			bubbleAssetChecked = null;
			if (buttonRTO != null)
				buttonRTO.dispose();
			buttonRTO = null;
			if (buttonVideo != null)
				buttonVideo.dispose();
			buttonVideo = null;
			if (buttonBank != null)
				buttonBank.dispose();
			buttonBank = null;
			if (buttonStartChat != null)
				buttonStartChat.dispose();
			buttonStartChat = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			UI.destroy(stateBubbleConnectionLine);
			stateBubbleConnectionLine = null;
			UI.destroy(stateBubbleConnectionLine2);
			stateBubbleConnectionLine2 = null;
			UI.destroy(bg);
			bg = null;
			UI.destroy(labelStartChat);
			labelStartChat = null;
			UI.destroy(labelBalance);
			labelBalance = null;
			UI.destroy(labelCurrencyName);
			labelCurrencyName = null;
			UI.destroy(labelCurrencyAmount);
			labelCurrencyAmount = null;
			UI.destroy(labelDukat);
			labelDukat = null;
			UI.destroy(labelDukatAmount);
			labelDukatAmount = null;
			UI.destroy(appontmentClip);
			appontmentClip = null;
			UI.destroy(stateBubbleRTO);
			stateBubbleRTO = null;
			UI.destroy(stateBubbleVideo);
			stateBubbleVideo = null;
			UI.destroy(stateBubbleBank);
			stateBubbleBank = null;
			if (pandingClick != null)
				UI.destroy(pandingClick);
			pandingClick = null;
			if (buttonRefreshBalance != null)
			{
				buttonRefreshBalance.dispose();
				buttonRefreshBalance = null;
			}
			if (this.parent != null)
				this.parent.removeChild(this);
			_isDisposed = true;
		}
	}
}