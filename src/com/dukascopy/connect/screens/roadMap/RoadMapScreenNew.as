package com.dukascopy.connect.screens.roadMap {
	
	import assets.AskFriendIllustration;
	import assets.ShadowClip;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.TransactionData;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.payments.AccountRoadMap;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.roadMap.actions.InitialDepositAction;
	import com.dukascopy.connect.screens.roadMap.actions.ScanDocumentAction;
	import com.dukascopy.connect.screens.roadMap.actions.SelectCardAction;
	import com.dukascopy.connect.screens.roadMap.actions.SolvencyCheckAction;
	import com.dukascopy.connect.screens.roadMap.actions.StartRTOAction;
	import com.dukascopy.connect.screens.roadMap.actions.StartVideoidentificationAction;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mrz.MrzBridge;
	import com.dukascopy.connect.sys.mrz.MrzData;
	import com.dukascopy.connect.sys.mrz.MrzError;
	import com.dukascopy.connect.sys.mrz.MrzResult;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import white.ChatIcon;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class RoadMapScreenNew extends BaseScreen {
		
		static private var lastBalanceData:Object = null;
		
		private var topBar:TopBarScreen;
		private var illustration:Bitmap;
		private var balanceTitle:Bitmap;
		private var disabledMessage:Bitmap;
		private var back:Sprite;
		private var supportButton:BitmapButton;
		private var cryptoBalance:PendingSummClip;
		private var eurBalance:PendingSummClip;
		private var scroll:ScrollPanel;
		private var steps:Vector.<RoadmapStepClip>;
		private var startClip:Sprite;
		private var endClip:Sprite;
		private var lines:Sprite;
		private var scrollBack:Sprite;
		
		private static var lastIgnoreCache:Number = 0;
		static private var canEnerCodeStatus:Boolean = true;
		private var _isLoadingBalance:Boolean = false;
		private var preloader:CirclePreloader;
		private var pendingTransactions:Vector.<TransactionData>;
		
		private var actions:Array = [
			{ id:"refreshBtn", img:Style.icon(Style.ICON_REFRESH), callback:onRefresh, imgColor:Style.color(Style.TOP_BAR_ICON_COLOR) }
		];
		
		private const REGISTRATION_TYPE_STANDART:String = "standart";
		private const REGISTRATION_TYPE_DEPOSIT:String = "deposit";
		private const REGISTRATION_TYPE_DEPOSIT_CARD:String = "deposit_card";
		private const REGISTRATION_TYPE_SOLVENCY_CHECK:String = "zbx_check";
		
		static public const TAB_ACCOUNT_MCA:String = "tabAccountMca";
		static public const TAB_ACCOUNT_TRADE_CH:String = "tabAccountTradeCh";
		static public const TAB_ACCOUNT_TRADE_EU:String = "tabAccountTradeEu";
		
		private var registrationType:String = REGISTRATION_TYPE_STANDART;
		private var stepsStart:Number;
		private var enterCodeButton:EnterCodeButton;
		private var firstTime:Boolean;
		private var dataLoaded:Boolean;
		private var dataShown:Boolean;
		private var dataLoadStart:Boolean;
		private var shadow:ShadowClip;
		private var roadmapDisabled:Boolean;
		private var depositPrice:String;
		private var needBirthDate:Boolean;
		public static var busy:Boolean = false;
		private static var instance:RoadMapScreenNew;
		private var okButton:BitmapButton;
		private var iconFriend:Bitmap;
		private var textFriend:Bitmap;
		private var solvencyAction:SolvencyCheckAction;
		private var needRemoveFriends:Boolean;
	//	private var registrationType = REGISTRATION_TYPE_DEPOSIT;
	//	private var registrationType = REGISTRATION_TYPE_DEPOSIT_CARD;
		private var tabs:FilterTabs;
		private var selectedFilter:String = TAB_ACCOUNT_MCA;
		private var locked:Boolean;
		private var hideTime:Number = 0.3;
		private var showTime:Number = 0.3;
		private var tabsHeight:Number;
		private var depositAction:InitialDepositAction;
		private var depositPriceNum:Number;
		private var depositPriceCurrency:String;
			
		public function RoadMapScreenNew() {}
		
		override protected function createView():void {
			super.createView();
			back = new Sprite();
			view.addChild(back);
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			supportButton = new BitmapButton();
			supportButton.setDownScale(1);
			supportButton.setDownColor(Color.GREEN);
			_view.addChild(supportButton);
			supportButton.show();
			supportButton.tapCallback = supportButtonClick;
			
			illustration = new Bitmap();
			view.addChild(illustration);
			
			balanceTitle = new Bitmap();
			view.addChild(balanceTitle);
			
			disabledMessage = new Bitmap();
			view.addChild(disabledMessage);
			
			scroll = new ScrollPanel();
			scroll.disableVisibilityChange();
			scroll.scrollCallback = onScrolled;
			scroll.background = false;
			view.addChild(scroll.view);
			
			startClip = new Sprite();
			startClip.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			startClip.graphics.drawRect(0, 0, 1, 1);
			startClip.graphics.endFill();
			
			endClip = new Sprite();
			endClip.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			endClip.graphics.drawRect(0, 0, 1, 1);
			endClip.graphics.endFill();
			
			scroll.addObject(startClip);
			scroll.addObject(endClip);
			
			scrollBack = new Sprite();
			scroll.addObject(scrollBack);
			
			shadow = new ShadowClip();
			scroll.addObject(shadow);
			
			shadow.height = Config.FINGER_SIZE * .3;
			
			lines = new Sprite();
			scroll.addObject(lines);
			
			enterCodeButton = new EnterCodeButton();
			scroll.addObject(enterCodeButton);
		}
		
		private function createTabs():void {
			
			var items:Array = new Array();
			
			items.push({title:Lang.account_mca, filter:TAB_ACCOUNT_MCA});
			
			if (Auth.ch_phase == BankPhaze.VIDID || Auth.ch_phase == BankPhaze.VIDID_PROGRESS || Auth.ch_phase == BankPhaze.VIDID_READY || Auth.ch_phase == BankPhaze.VI_FAIL)
			{
				items.push({title:Lang.account_trade_ch, filter:TAB_ACCOUNT_TRADE_CH});
			}
			if (Auth.eu_phase == BankPhaze.VIDID || Auth.eu_phase == BankPhaze.VIDID_PROGRESS || Auth.eu_phase == BankPhaze.VIDID_READY || Auth.eu_phase == BankPhaze.VI_FAIL)
			{
				items.push({title:Lang.account_eu, filter:TAB_ACCOUNT_TRADE_EU});
			}
			
			var position:String;
			if (items.length > 1)
			{
				tabs = new FilterTabs();
				for (var i:int = 0; i < items.length; i++) 
				{
					if (i == 0)
					{
						position = "l";
					}
					else if (i == items.length - 1)
					{
						position = "r";
					}
					else
					{
						position = "";
					}
					tabs.add(items[i].title, items[i].filter, false, position);
					if (items[i].filter != TAB_ACCOUNT_MCA)
					{
						selectedFilter = items[i].filter;
					}
				}
				_view.addChild(tabs.view);
				tabs.view.y = topBar.trueHeight;
				tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
				
				tabs.setSelection(selectedFilter);
			}
		}
		
		private function onScrolled():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (shadow != null)
			{
				var alphaValue:Number = 1;
				if (scroll.getPositionY() <= 0)
				{
					alphaValue = 0;
				}
				else{
					alphaValue = 1;
				}
				shadow.alpha = alphaValue;
			}
		}
		
		private function onPhazeChanged(realChange:Boolean = true):void {
			if (busy == false)
			{
				if (textFriend == null || needRemoveFriends == true)
				{
					needRemoveFriends = false;
					updateSteps();
				}
			}
		}
		
		private function updateSteps():void 
		{
			removeErrorMessage();
			
			TweenMax.killDelayedCallsTo(openInternetBank);
			if (Auth.bank_phase == null)
				return;
			
			var items:Vector.<RoadmapStepData> = new Vector.<RoadmapStepData>();
			
			var item_registration_form   :RoadmapStepData = new RoadmapStepData(RoadmapStepData.STEP_REGISTRATION_FORM,   Lang.roadmap_fillRegistrationForm);
			var item_document_scan       :RoadmapStepData = new RoadmapStepData(RoadmapStepData.STEP_DOCUMENT_SCAN,       Lang.roadmap_documentScan);
			var item_initial_Deposit     :RoadmapStepData = new RoadmapStepData(RoadmapStepData.STEP_DEPOSIT,             getDepositText());
			var item_select_card         :RoadmapStepData = new RoadmapStepData(RoadmapStepData.STEP_SELECT_CARD,         Lang.roadmap_selectCard);
			var item_videoidentification :RoadmapStepData = new RoadmapStepData(RoadmapStepData.STEP_VIDEOIDENTIFICATION, Lang.roadmap_identityVerification);
			var item_approve_account     :RoadmapStepData = new RoadmapStepData(RoadmapStepData.STEP_APPROVE_ACCOUNT,     Lang.roadmap_approveAccount);
			
			var item_solvency_check      :RoadmapStepData = new RoadmapStepData(RoadmapStepData.STEP_SOLVENCY_CHECK,      Lang.roadmap_solvencyCheck);
			
			item_registration_form.action = new StartRTOAction();
			item_document_scan.action = new ScanDocumentAction();
			item_select_card.action = new SelectCardAction();
			item_initial_Deposit.action = getInitialDepositAction(depositPrice);
			item_videoidentification.action = new StartVideoidentificationAction(getEntryPoint());
			
			item_solvency_check.action = getSolvencyCheckAction(depositPrice);
			item_solvency_check.action.getSuccessSignal().add(onSolvencySuccess);
			item_solvency_check.action.getFailSignal().add(onSolvencyFail);
			
			
			switch (Auth.bank_phase) {
				case BankPhaze.EMPTY:
				case BankPhaze.RTO_STARTED:
				{
					item_registration_form.status   = RoadmapStepData.STATE_ACTIVE;
					item_solvency_check.status      = RoadmapStepData.STATE_INACTIVE;
					item_select_card.status         = RoadmapStepData.STATE_INACTIVE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_INACTIVE;
					item_videoidentification.status = RoadmapStepData.STATE_INACTIVE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
				
				case BankPhaze.SOLVENCY_CHECK:
				case BankPhaze.ZBX:
				case BankPhaze.DONATE:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_solvency_check.status      = RoadmapStepData.STATE_ACTIVE;
					item_select_card.status         = RoadmapStepData.STATE_INACTIVE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_INACTIVE;
					item_videoidentification.status = RoadmapStepData.STATE_INACTIVE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
				case BankPhaze.DOCUMENT_SCAN:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_document_scan.status       = RoadmapStepData.STATE_ACTIVE;
					item_solvency_check.status      = RoadmapStepData.STATE_INACTIVE;
					item_select_card.status         = RoadmapStepData.STATE_INACTIVE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_INACTIVE;
					item_videoidentification.status = RoadmapStepData.STATE_INACTIVE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
					
				case BankPhaze.VIDID:
				case BankPhaze.VIDID_READY:
				case BankPhaze.VIDID_PROGRESS:
				case BankPhaze.VIDID_QUEUE:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_select_card.status         = RoadmapStepData.STATE_DONE;
					item_solvency_check.status      = RoadmapStepData.STATE_DONE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_DONE;
					item_videoidentification.status = RoadmapStepData.STATE_ACTIVE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
				case BankPhaze.VI_FAIL:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_select_card.status         = RoadmapStepData.STATE_DONE;
					item_solvency_check.status      = RoadmapStepData.STATE_DONE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_DONE;
					item_videoidentification.status = RoadmapStepData.STATE_FAIL;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
				case BankPhaze.VI_COMPLETED:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_select_card.status         = RoadmapStepData.STATE_DONE;
					item_solvency_check.status      = RoadmapStepData.STATE_DONE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_DONE;
					item_videoidentification.status = RoadmapStepData.STATE_DONE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
				case BankPhaze.ACC_CREATED:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_select_card.status         = RoadmapStepData.STATE_DONE;
					item_solvency_check.status      = RoadmapStepData.STATE_DONE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_DONE;
					item_videoidentification.status = RoadmapStepData.STATE_DONE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
				case BankPhaze.ACC_APPROVED:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_select_card.status         = RoadmapStepData.STATE_DONE;
					item_solvency_check.status      = RoadmapStepData.STATE_DONE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_DONE;
					item_videoidentification.status = RoadmapStepData.STATE_DONE;
					item_approve_account.status     = RoadmapStepData.STATE_DONE;
					TweenMax.delayedCall(3, openInternetBank);
					break;
				}
				case BankPhaze.REJECT:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_select_card.status         = RoadmapStepData.STATE_DONE;
					item_solvency_check.status      = RoadmapStepData.STATE_DONE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_DONE;
					item_videoidentification.status = RoadmapStepData.STATE_DONE;
					item_approve_account.status     = RoadmapStepData.STATE_FAIL;
					break;
				}
				case BankPhaze.NOTARY:
				case BankPhaze.WIRE_DEPOSIT:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_select_card.status         = RoadmapStepData.STATE_DONE;
					item_solvency_check.status      = RoadmapStepData.STATE_CHANGE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_ACTIVE;
					item_videoidentification.status = RoadmapStepData.STATE_INACTIVE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
				case BankPhaze.CARD:
				{
					item_registration_form.status   = RoadmapStepData.STATE_DONE;
					item_select_card.status         = RoadmapStepData.STATE_ACTIVE;
					item_solvency_check.status      = RoadmapStepData.STATE_CHANGE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_INACTIVE;
					item_videoidentification.status = RoadmapStepData.STATE_INACTIVE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
					break;
				}
				default:
				{
					item_registration_form.status   = RoadmapStepData.STATE_INACTIVE;
					item_select_card.status         = RoadmapStepData.STATE_INACTIVE;
					item_solvency_check.status      = RoadmapStepData.STATE_INACTIVE;
					item_initial_Deposit.status     = RoadmapStepData.STATE_INACTIVE;
					item_videoidentification.status = RoadmapStepData.STATE_INACTIVE;
					item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
				}
			}
			
			if (selectedFilter == TAB_ACCOUNT_MCA)
			{
				items.push(item_registration_form);
				
				if (registrationType == REGISTRATION_TYPE_SOLVENCY_CHECK)
				{
					items.push(item_solvency_check);
					(item_solvency_check.action as SolvencyCheckAction).allowZBX = true;
					
					if (Auth.bank_phase == BankPhaze.CARD)
					{
						items.push(item_select_card);
						items.push(item_initial_Deposit);
					}
					else if (Auth.bank_phase == BankPhaze.NOTARY || Auth.bank_phase == BankPhaze.WIRE_DEPOSIT)
					{
						items.push(item_select_card);
						items.push(item_initial_Deposit);
					}
				}
				else
				{
					if (Auth.bank_phase == BankPhaze.DOCUMENT_SCAN)
					{
						items.push(item_document_scan);
						item_document_scan.action.getSuccessSignal().add(onDocumentScanSuccess);
						item_document_scan.action.getFailSignal().add(onDocumentScanFail);
					}
					
					if (registrationType == REGISTRATION_TYPE_DEPOSIT || registrationType == REGISTRATION_TYPE_DEPOSIT_CARD)
					{
						items.push(item_solvency_check);
					}
					if (registrationType == REGISTRATION_TYPE_DEPOSIT_CARD)
					{
						items.push(item_select_card);
					}
					if (registrationType == REGISTRATION_TYPE_DEPOSIT || registrationType == REGISTRATION_TYPE_DEPOSIT_CARD)
					{
						items.push(item_initial_Deposit);
					}
				}
				
				items.push(item_videoidentification);
				items.push(item_approve_account);
			}
			else
			{
				item_registration_form.status   = RoadmapStepData.STATE_DONE;
				item_videoidentification.status = RoadmapStepData.STATE_ACTIVE;
				item_approve_account.status     = RoadmapStepData.STATE_INACTIVE;
				
				items.push(item_registration_form);
				items.push(item_videoidentification);
				items.push(item_approve_account);
			}
			
			drawItems(items);
		}
		
		private function getDepositText():String
		{
			if (Auth.bank_phase == BankPhaze.WIRE_DEPOSIT)
			{
				return Lang.roadmap_wireDeposit;
			}
			return Lang.roadmap_initialDeposit;
		}
		
		private function getInitialDepositAction(depositPrice:String):InitialDepositAction 
		{
			if (depositAction == null)
			{
				depositAction = new InitialDepositAction(depositPrice)
			}
			else
			{
				depositAction.price = depositPrice;
			}
			return depositAction;
		}
		
		private function getEntryPoint():int 
		{
			if (selectedFilter == TAB_ACCOUNT_MCA)
			{
				return Config.EP_VI_DEF;
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_CH)
			{
				return Config.EP_VI_PAY;
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_EU)
			{
				return Config.EP_VI_EUR;
			}
			return Config.EP_VI_DEF;
		}
		
		private function getSolvencyCheckAction(depositPrice:String):SolvencyCheckAction 
		{
			if (solvencyAction == null)
			{
				solvencyAction = new SolvencyCheckAction(depositPrice)
			}
			else
			{
				solvencyAction.price = depositPrice;
			}
			return solvencyAction;
		}
		
		private function onSolvencyFail():void 
		{
			
		}
		
		private function onSolvencySuccess(method:String, success:Boolean = false):void 
		{
			if (method == SolvencyMethodData.METHOD_ASK_FRIEND)
			{
				clearItems();
				addFriendClips();
			}
			else if (method == SolvencyMethodData.METHOD_CRYPTO_DEPOSIT)
			{
				if (success == true)
				{
					removeSteps();
					onRefresh();
				}
			}
			else if (method == SolvencyMethodData.METHOD_CARD_DEPOSIT)
			{
				removeSteps();
				onRefresh();
			}
		}
		
		private function addFriendClips():void 
		{
			if (enterCodeButton != null)
			{
				scroll.removeObject(enterCodeButton);
			}
			
			okButton = new BitmapButton();
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.setDownColor(NaN);
			okButton.setOverlay(HitZoneType.BUTTON);
			okButton.cancelOnVerticalMovement = false;
			okButton.ignoreHittest = true;
			okButton.tapCallback = onButtonOkClick;
			scroll.addObject(okButton);
			okButton.activate();
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.askAFriend.toUpperCase(), Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, _width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * .2, Style.size(Style.SIZE_BUTTON_CORNER));
			okButton.setBitmapData(buttonBitmap, true);
			
			iconFriend = new Bitmap();
			scroll.addObject(iconFriend);
			var iconClip:Sprite = new AskFriendIllustration();
			UI.scaleToFit(iconClip, Config.FINGER_SIZE * .9, Config.FINGER_SIZE * .9);
			UI.colorize(iconClip, Style.color(Style.COLOR_ICON_SETTINGS));
			iconFriend.bitmapData = UI.getSnapshot(iconClip);
			UI.destroy(iconClip);
			iconClip = null;
			
			textFriend = new Bitmap();
			scroll.addObject(textFriend);
			
			var textValue:String = Lang.askFriendDescription_2;
			textValue = LangManager.replace(/%@/g, textValue, depositPrice);
			
			textFriend.bitmapData = TextUtils.createTextFieldData(
				textValue,
				_width - Config.DIALOG_MARGIN*2,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				true,
				Style.color(Style.COLOR_TEXT),
				Style.color(Style.COLOR_BACKGROUND),
				false, true
			);
			
			okButton.x = int(_width * .5 - okButton.width * .5);
			textFriend.x = int(_width * .5 - textFriend.width * .5);
			iconFriend.x = int(_width * .5 - iconFriend.width * .5);
			
			var position:int = Config.FINGER_SIZE + illustration.height;
			iconFriend.y = position;
			position += iconFriend.height + Config.FINGER_SIZE * .7;
			textFriend.y = position;
			position += textFriend.height + Config.FINGER_SIZE * .7;
			okButton.y = position;
			position += okButton.height + Config.FINGER_SIZE * .3;
			
			endClip.y = position;
				
			scrollBack.y = illustration.height;
			scrollBack.graphics.clear();
			scrollBack.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			scrollBack.graphics.drawRect(0, 0, _width, endClip.y - scrollBack.y);
			scrollBack.graphics.endFill();
			
			scroll.update();
			scroll.scrollToBottom();
		}
		
		private function onButtonOkClick():void 
		{
			var textValue:String = Lang.friendInvoiceConfirm_2;
			textValue = LangManager.replace(/%@/g, textValue, depositPriceNum + " " + depositPriceCurrency);
			
			MobileGui.changeMainScreen(RootScreen, {selectedTab:RootScreen.CONTACTS_SCREEN_ID, 
													additionalData:{
															buttonText:Lang.askFriendInvoice, 
															amount:depositPriceNum, 
															currency:depositPriceCurrency, 
															comment:Lang.friendInvoiceComment, 
															confirm:textValue}});
		}
		
		private function onDocumentScanSuccess():void 
		{
			busy = false;
			if (instance != null)
			{
				instance.onBirthdateSaved();
			}
		}
		
		private function onDocumentScanFail():void 
		{
			busy = false;
			if (!isDisposed)
			{
				onBack();
			}
		}
		
		private function onBirthdateSaved():void 
		{
			dataLoadStart = true;
			loadRegistrationStatus();
		}
		
		private function removeErrorMessage():void 
		{
			//!TODO:;
		}
		
		private function onRefresh(init:Boolean = false):void {
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				return;
			}
			needRemoveFriends = true;
			loadBalance(true);
			loadRegistrationStatus();
		}
		
		private function openInternetBank(immediate:Boolean = false):void {
			
			if (tradingPhazeExist() && immediate == false)
			{
				return;
			}
			
			if (MobileGui.centerScreen.currentScreenClass == RoadMapScreenNew)
				MobileGui.openMyAccountIfExist();
		}
		
		private function createSupportButton():ImageBitmapData 
		{
			var clip:Sprite = new Sprite();
			var icon:Sprite = new (Style.icon(Style.ICON_CHAT))() as Sprite;
			UI.colorize(icon, Style.color(Style.ICON_COLOR));
			UI.scaleToFit(icon, int(Config.FINGER_SIZE), int(Config.FINGER_SIZE * .47));
			clip.addChild(icon);
			var padding:int = Config.FINGER_SIZE * .28;
			icon.x = padding;
			icon.y = padding;
			clip.graphics.lineStyle(UI.getLineThickness(), Style.color(Style.COLOR_SEPARATOR));
			clip.graphics.moveTo(0, Math.max(1, int(UI.getLineThickness() * .5)));
			clip.graphics.lineTo(_width, Math.max(1, int(UI.getLineThickness() * .5)));
			var text:Bitmap = new Bitmap();
			clip.addChild(text);
			text.bitmapData = TextUtils.createTextFieldData(getSupportButtonText(), _width - icon.width - Config.DIALOG_MARGIN - padding - Config.FINGER_SIZE * .3, 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .29, true, Style.color(Style.COLOR_SUBTITLE), 0xFFFFFF, true);
			text.x = int(icon.x + icon.width + Config.FINGER_SIZE * .3);
			if (text.height > icon.height)
			{
				text.y = padding;
				icon.y = int((text.height + padding * 2) * .5 - icon.height * .5);
			}
			else{
				text.y = int((icon.height + padding * 2) * .5 - text.height * .5);
			}
			
			var result:ImageBitmapData = new ImageBitmapData("RoadMapScreenNew.supportButton", _width, int(Math.max(text.height, icon.height) + padding * 2), true, Style.color(Style.COLOR_BACKGROUND));
			result.drawWithQuality(clip);
			return result;
		}
		
		private function getSupportButtonText():String 
		{
			if (selectedFilter == TAB_ACCOUNT_MCA)
			{
				return Lang.startChatWithBankConsultant;
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_CH)
			{
				return Lang.startChatWithBankConsultantCH;
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_EU)
			{
				return Lang.startChatWithBankConsultantEU;
			}
			return "";
		}
		
		private function supportButtonClick():void 
		{
			var EP:int = getEntryPoint();
			
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = EP;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		override public function initScreen(data:Object = null):void {
			instance = this;
			super.initScreen(data);
			topBar.setData(Lang.MY_ACCOUNT_TITLE, true, actions);
			
			tabsHeight = 0;
			if (tradingPhazeExist())
			{
				createTabs();
				tabsHeight = tabs.height;
			}
			drawSupportButton();
			
			drawBack();
			drawIllustration();
			
			drawBalanceTitle();
			updatePositions();
			
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				if (cryptoBalance != null)
				{
					cryptoBalance.alpha = 0;
				}
				if (eurBalance != null)
				{
					eurBalance.alpha = 0;
				}
			}
			
			Auth.S_PHAZE_CHANGE.add(onPhazeChangedAuth);
			
			loadBalance();
		}
		
		private function drawSupportButton():void 
		{
			supportButton.setBitmapData(createSupportButton(), true);
		}
		
		private function updatePositions():void 
		{
			back.y = topBar.trueHeight;
			illustration.y = topBar.trueHeight + tabsHeight;
			
			enterCodeButton.y = int(Config.FINGER_SIZE * .5 + illustration.height);
			enterCodeButton.x = int(_width * .5 - enterCodeButton.getWidth() * .5);
			
			stepsStart = illustration.height;
			
			if (selectedFilter != TAB_ACCOUNT_MCA && enterCodeButton != null)
			{
				scroll.removeObject(enterCodeButton);
			}
			if (enterCodeButton != null && enterCodeButton.parent != null && enterCodeButton.visible && enterCodeButton.alpha > 0)
			{
				stepsStart += enterCodeButton.height + Config.FINGER_SIZE * .6;
			}
			
			supportButton.x = 0;
			supportButton.y = int(_height - supportButton.height - Config.APPLE_BOTTOM_OFFSET);
			
			shadow.width = _width;
			shadow.y = illustration.height - shadow.height;
			
			scroll.setWidthAndHeight(_width, supportButton.y - illustration.y);
			scroll.view.y = int(illustration.y);
			
			balanceTitle.x = int(_width * .5 - balanceTitle.width * .5);
			balanceTitle.y = illustration.y + int(Math.max(Config.FINGER_SIZE * .2, illustration.height * .18));
		}
		
		private function tradingPhazeExist():Boolean 
		{
			if (Auth.ch_phase == BankPhaze.VIDID || Auth.ch_phase == BankPhaze.VIDID_PROGRESS || Auth.ch_phase == BankPhaze.VIDID_READY || Auth.ch_phase == BankPhaze.VI_FAIL)
			{
				return true;
			}
			if (Auth.eu_phase == BankPhaze.VIDID || Auth.eu_phase == BankPhaze.VIDID_PROGRESS || Auth.eu_phase == BankPhaze.VIDID_READY || Auth.eu_phase == BankPhaze.VI_FAIL)
			{
				return true;
			}
			return false;
		}
		
		private function drawBack():void 
		{
			back.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			back.graphics.drawRect(0, 0, _width, _height - topBar.trueHeight);
			back.graphics.endFill();
		}
		
		private function drawIllustration():void 
		{
			var imageClass:Class;
			var targetImage:BitmapData;
			if (selectedFilter == TAB_ACCOUNT_MCA)
			{
				imageClass = Style.icon(Style.ROADMAP_ILLUSTRATION);
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_CH)
			{
				imageClass = RCH;
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_EU)
			{
				imageClass = REU;
			}
			
			targetImage = new imageClass();
			
			var targetBitmapData:ImageBitmapData = TextUtils.scaleBitmapData(targetImage, _width / targetImage.width);
			if (targetImage != null)
			{
				targetImage.dispose();
				targetImage = null;
			}
			if (illustration.bitmapData != null)
			{
				illustration.bitmapData.dispose();
				illustration.bitmapData = null;
			}
			
			illustration.bitmapData = targetBitmapData;
		}
		
		private function loadRegistrationStatus():void 
		{
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				return;
			}
			if (busy == false)
			{
				PHP.getRegistrationSteps(onRegistrationStepsLoaded);
			}
		}
		
		private function onRegistrationStepsLoaded(respond:PHPRespond):void 
		{
			if (isDisposed == true)
			{
				return;
				respond.dispose();
			}
			
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				return;
				respond.dispose();
			}
			
			if (respond.error == true)
			{
				showErrorMessage();
			}
			else
			{
				if ("needBirthDate" in respond.data && respond.data.needBirthDate == true)
				{
					needBirthDate = true;
				}
				else
				{
					needBirthDate = false;
				}
				
				if (respond.data != null && ("age" in respond.data) == true && respond.data == -1)
				{
					roadmapDisabled = true;
				}
				else{
					roadmapDisabled = false;
				}
				
				if (respond.data != null && ("reg_steps" in respond.data) == true)
				{
					registrationType = respond.data.reg_steps;
				}
				
				if (respond.data != null && ("price" in respond.data) == true && ("currency" in respond.data) == true)
				{
					depositPrice = respond.data.price + " " + respond.data.currency;
					depositPriceNum = respond.data.price;
					depositPriceCurrency = respond.data.currency;
				}
				
				loadRefCodeStatus();
			}
			respond.dispose();
		}
		
		private function loadRefCodeStatus():void 
		{
			PHP.referral_getInvite(onInviteDataLoaded);
		}
		
		private function onInviteDataLoaded(response:PHPRespond):void {
			if (isDisposed == true)
			{
				response.dispose();
				return;
			}
			if (response.error == true) {
				ToastMessage.display(ErrorLocalizer.getText(response.errorMsg));
			}
			else{
				if ("data" in response && response.data == false) {
					canEnerCodeStatus = true;
				}
				else {
					canEnerCodeStatus = false;
				}
			}
			onPhazeChanged();
			response.dispose();
		}
		
		private function showErrorMessage():void 
		{
			
		}
		
		private function showPreloader():void {
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				return;
			}
			
			if (preloader == null)
			{
				preloader = new CirclePreloader(NaN, int(Config.FINGER_SIZE * .06), 0xFFFFFF);
			}
			
			preloader.x = int(illustration.x + illustration.width * .5);
			preloader.y = int(illustration.y + illustration.height * .5);
			
			view.addChild(preloader);
			view.setChildIndex(scroll.view, view.numChildren - 1);
		}
		
		private function hidePreloader(dispose:Boolean = false):void {
			if (preloader != null)
			{
				if (view.contains(preloader))
				{
					view.removeChild(preloader);
				}
				preloader.dispose();
				preloader = null;
			}
		}
		
		private function loadBalance(ignoreCache:Boolean = true):void {
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				return;
			}
			if (preloader != null)
			{
				return;
			}
			if (cryptoBalance != null)
			{
				cryptoBalance.alpha = 0.3;
			}
			if (eurBalance != null)
			{
				eurBalance.alpha = 0.3;
			}
			
			_isLoadingBalance = true;
			showPreloader();
			
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
			{
				respond.dispose();
				return;
			}
			
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				respond.dispose();
				return;
			}
			
			hidePreloader();
			_isLoadingBalance = false;
			if (respond.error == true || respond.data == -1) {
				
				if (respond.errorMsg != null && respond.errorMsg.indexOf("thro.01") == 0 && lastBalanceData != null) {
					setBalance(lastBalanceData);
					respond.dispose();
					return;
				}
				
				respond.dispose();
				return;
			}
			lastBalanceData = respond.data;
			setBalance(lastBalanceData);
			respond.dispose();
		}
		
		private function setBalance(balanceData:Object):void {
			var hasTwoCurrencies:Boolean = false;
			var currentBalanceValue:Number = 0;
			var currentDukatBalanceValue:Number = 0;
			
			hasTwoCurrencies = Config.START_DUK_AMMOUNT > 0;
			var realAmountDUK:Number = Config.START_DUK_AMMOUNT;
			if (balanceData == null) {
				currentBalanceValue = 0;
			} else if (balanceData is Number) {
				currentBalanceValue = Number(balanceData);
			} else if (balanceData is Object) {
				if ("DOK" in balanceData == true && balanceData.DOK != null) {
					hasTwoCurrencies = true;
					realAmountDUK += Number(balanceData.DOK); 
				}
				currentBalanceValue = balanceData.SUMM;
			}
			currentDukatBalanceValue = realAmountDUK;
			
			var position:int;
			if (hasTwoCurrencies == true)
			{
				drawbalanceCrypto(currentDukatBalanceValue, "DUK+");
				drawbalanceEUR(currentBalanceValue, "EUR");
				
			//	cryptoBalance.alpha = 1;
			//	eurBalance.alpha = 1;
				
				cryptoBalance.visible = true;
				eurBalance.visible = true;
				
				cryptoBalance.x = int((_width - PendingSummClip.size * 2) / 3);
				eurBalance.x = (cryptoBalance.x + PendingSummClip.size + (_width - PendingSummClip.size * 2) / 3);
				var i:int = (illustration.height - balanceTitle.y - balanceTitle.height + illustration.y) * .5 - PendingSummClip.size * .5;
				position = int(balanceTitle.y + balanceTitle.height + Math.min(Config.FINGER_SIZE * .5, i));
				cryptoBalance.y = position;
				eurBalance.y = position;
			}
			else
			{
				drawbalanceEUR(currentBalanceValue, "EUR");
				
				eurBalance.visible = true;
				
				eurBalance.x = int((_width - PendingSummClip.size) * .5);
				var i3:int = (illustration.height - balanceTitle.y - balanceTitle.height + illustration.y) * .5 - PendingSummClip.size * .5;
				position = int(balanceTitle.y + balanceTitle.height + Math.min(Config.FINGER_SIZE * .5, i3));
				eurBalance.y = position;
			}
			
			if (balanceData != null && "FULL" in balanceData && balanceData.FULL != null && balanceData.FULL is Array)
			{
				pendingTransactions = new Vector.<TransactionData>();
				var transaction:TransactionData;
				
				for (var i2:int = 0; i2 < balanceData.FULL.length; i2++) 
				{
					transaction = new TransactionData(balanceData.FULL[i2]);
					pendingTransactions.push(transaction);
				}
			}
			view.setChildIndex(scroll.view, view.numChildren - 1);
		}
		
		private function drawItems(items:Vector.<RoadmapStepData>):void 
		{
			clearItems();
			if (isDisposed == true)
			{
				return;
			}
			dataLoaded = true;
			
			if (roadmapDisabled == true)
			{
				drawDisabledMessage();
				scroll.addObject(disabledMessage);
				if (canEnterCode())
				{
					scroll.removeObject(enterCodeButton);
				}
				scroll.update();
				
				dataShown = true;
				scroll.view.alpha = 1;
				TweenMax.killTweensOf(scroll.view);
			}
			else
			{
				scroll.removeObject(disabledMessage);
				if (firstTime == false && dataLoaded)
				{
					firstTime = true;
					if (canEnterCode())
					{
						enterCodeButton.animate();
					}
				}
				
				if (canEnterCode())
				{
					enterCodeButton.animate();
					scroll.addObject(enterCodeButton);
					stepsStart = illustration.height + enterCodeButton.height + Config.FINGER_SIZE * .6;
				}
				else
				{
					scroll.removeObject(enterCodeButton);
					stepsStart = illustration.height;
				}
				var minItemHeight:int = Config.FINGER_SIZE * 1.3;
				var padding:int = Config.FINGER_SIZE * .7;
				var gap:int = Config.FINGER_SIZE * 0.75;
				
				var resultSize:int = RoadmapStepClip.iconSize * items.length + padding * 2 + gap * (items.length - 1);
				var maxSize:int = supportButton.y - illustration.y - illustration.height;
				if (resultSize > maxSize)
				{
					
				}
				else
				{
					gap = Math.min(Config.FINGER_SIZE * 2, maxSize - padding * 2 - RoadmapStepClip.iconSize * items.length) / (items.length - 1);
				//	padding = (maxSize - minItemHeight * items.length - (items.length - 1) * gap) / 2;
				}
				
				steps = new Vector.<RoadmapStepClip>();
				var clip:RoadmapStepClip;
				var maxItemWidth:int = 0;
				for (var i:int = 0; i < items.length; i++) 
				{
					clip = new RoadmapStepClip();
					clip.setData(items[i], _width - Config.FINGER_SIZE*.8);
					scroll.addObject(clip);
					clip.y = padding + i * (RoadmapStepClip.iconSize + gap) + stepsStart;
					steps.push(clip);
					maxItemWidth = Math.max(maxItemWidth, clip.getWidth());
					if (isActivated)
					{
						clip.activate();
					}
				}
				var cropRectangle:Rectangle = new Rectangle(scroll.view.x, scroll.view.y, _width, scroll.height);
				
				for (var j:int = 0; j < steps.length; j++) 
				{
					steps[j].x = Math.round((_width - maxItemWidth)* .5) /* - Config.FINGER_SIZE * .5*/;
					steps[j].setOverlaySize(maxItemWidth, minItemHeight, cropRectangle);
					if (j == 0)
					{
						lines.graphics.moveTo(int(steps[j].x + steps[j].getHeight() * .5), int(steps[j].y + steps[j].getHeight()));
					}
					else
					{
						lines.graphics.moveTo(int(steps[j - 1].x + steps[j - 1].getHeight() * .5), int(steps[j - 1].y + steps[j - 1].getHeight()));
						lines.graphics.lineStyle(Math.max(1, int(Config.FINGER_SIZE * .04)), steps[j].getIconColor());
						lines.graphics.lineTo(int(steps[j].x + steps[j].getHeight() * .5), int(steps[j].y));
					}
				}
				
				if (steps.length > 0)
				{
					endClip.y = int(steps[steps.length - 1].y + steps[steps.length - 1].getHeight() + padding);
				}
				else
				{
					endClip.y = stepsStart;
				}
				
				scrollBack.y = illustration.height;
				
				scrollBack.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				scrollBack.graphics.drawRect(0, 0, _width, endClip.y - scrollBack.y);
				scrollBack.graphics.endFill();
				
				scroll.update();
				
				if (dataShown == false)
				{
					dataShown = true;
					scroll.view.alpha = 0;
					TweenMax.killTweensOf(scroll.view);
					TweenMax.to(scroll.view, 0.5, {alpha:1});
				}
				
				for (var k:int = 0; k < items.length; k++) 
				{
					if (items[k].status == RoadmapStepData.STATE_ACTIVE)
					{
						var position:int = steps[k].y  - Config.FINGER_SIZE * .5;
						if (scroll.isItemVisible(steps[k]) == false)
						{
							scroll.scrollToPosition(position, true, 0.6, 0.3);
						}
						
						return;
					}
				}
			}
		}
		
		private function canEnterCode():Boolean 
		{
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				return false;
			}
			if (canEnerCodeStatus == false)
			{
				return false;
			}
			if (Auth.bank_phase == BankPhaze.VIDID_PROGRESS || 
				Auth.bank_phase == BankPhaze.VI_COMPLETED || 
				Auth.bank_phase == BankPhaze.ACC_CREATED || 
				Auth.bank_phase == BankPhaze.ACC_APPROVED)
			{
				return false;
			}
			return true;
		}
		
		private function drawDisabledMessage():void 
		{
			if (disabledMessage.bitmapData != null)
			{
				disabledMessage.bitmapData.dispose();
				disabledMessage.bitmapData = null;
			}
			disabledMessage.bitmapData = TextUtils.createTextFieldData(Lang.mcaOpenRestricted, _width - Config.FINGER_SIZE * 1, 10, 
																	true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .3, true, Style.color(Style.COLOR_SUBTITLE), 0xFFFFFF, true);
			disabledMessage.x = int(_width * .5 - disabledMessage.width * .5);
			disabledMessage.y = (illustration.y + illustration.height + Config.FINGER_SIZE * .5);
		}
		
		private function clearItems():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (scrollBack != null)
			{
				scrollBack.graphics.clear();
			}
			if (iconFriend != null)
			{
				UI.destroy(iconFriend);
				iconFriend = null;
			}
			if (textFriend != null)
			{
				UI.destroy(textFriend);
				textFriend = null;
			}
			if (okButton != null)
			{
				okButton.dispose();
				okButton = null;
			}
			
			removeSteps();
		}
		
		private function removeSteps():void 
		{
			if (steps != null)
			{
				for (var i:int = 0; i < steps.length; i++) 
				{
					steps[i].dispose();
					if (scroll != null)
					{
						scroll.removeObject(steps[i]);
					}
				}
				steps = null;
			}
			if (lines != null)
			{
				lines.graphics.clear();
			}
		}
		
		private function drawbalanceCrypto(amount:Number, currency:String):void 
		{
			if (cryptoBalance == null)
			{
				cryptoBalance = new PendingSummClip();
				view.addChild(cryptoBalance);
				cryptoBalance.alpha = 0;
			}
			TweenMax.to(cryptoBalance, 0.5, {alpha:1, delay:0.5});
			cryptoBalance.setValue(amount, currency);
		}
		
		private function drawbalanceEUR(amount:Number, currency:String):void 
		{
			if (eurBalance == null)
			{
				eurBalance = new PendingSummClip();
				view.addChild(eurBalance);
				eurBalance.alpha = 0;
			}
			TweenMax.to(eurBalance, 0.5, {alpha:1, delay:0.5});
			eurBalance.setValue(amount, currency);
		}
		
		private function drawBalanceTitle():void 
		{
			var text:String;
			var size:Number;
			var color:Number;
			if (selectedFilter == TAB_ACCOUNT_MCA)
			{
				text = Lang.youPendingBalance;
				size = Config.FINGER_SIZE * .3;
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_CH)
			{
				text = Lang.tradingAccountInSwiss;
				size = FontSize.TITLE_2;
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_EU)
			{
				text = Lang.tradingAccountInEU;
				size = FontSize.TITLE_2;
			}
			
			if (balanceTitle.bitmapData != null)
			{
				balanceTitle.bitmapData.dispose();
				balanceTitle.bitmapData = null;
			}
			balanceTitle.bitmapData = TextUtils.createTextFieldData(text, _width - Config.FINGER_SIZE * 1.5, 10, 
																	true, TextFormatAlign.CENTER, TextFieldAutoSize.CENTER, 
																	size, true, Color.WHITE, 0xFFFFFF, true);
			
			balanceTitle.x = int(_width * .5 - balanceTitle.width * .5);
			balanceTitle.y = illustration.y + int(Math.max(Config.FINGER_SIZE * .2, illustration.height * .18));
		}
		
		override public function activateScreen():void {
			if (_isDisposed) return;
			super.activateScreen();
			if (topBar != null)
				topBar.activate();
			
			scroll.enable();
			supportButton.activate();
			
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			
			if (steps != null)
			{
				for (var i:int = 0; i < steps.length; i++) 
				{
					steps[i].activate();
				}
			}
			
			if (firstTime == false && dataLoaded && selectedFilter == TAB_ACCOUNT_MCA)
			{
				firstTime = true;
				enterCodeButton.animate();
			}
			
			if (dataLoadStart == false && busy == false && selectedFilter == TAB_ACCOUNT_MCA)
			{
				dataLoadStart = true;
				loadRegistrationStatus();
			}
			else
			{
				updateSteps();
			}
			if (okButton != null)
			{
				okButton.activate();
			}
			
			PointerManager.addTap(enterCodeButton, enterCode);
		}
		
		private function enterCode(e:Event = null):void 
		{
			ReferralProgram.enterCode();
		}
		
		private function onTabItemSelected(id:String):void {
			selectedFilter = id;
			
			if (selectedFilter == TAB_ACCOUNT_MCA && Auth.bank_phase == BankPhaze.ACC_APPROVED)
			{
				openInternetBank(true);
			}
			
			changeContentToSelectedFilter();
		}
		
		private function changeContentToSelectedFilter():void 
		{
			if (illustration != null)
			{
				locked = true;
				TweenMax.to(illustration, hideTime, {alpha:0, onComplete:showCurrentContent});
				TweenMax.to(supportButton, hideTime, {alpha:0});
				if (enterCodeButton != null)
				{
					TweenMax.to(enterCodeButton, hideTime, {alpha:0});
				}
				if (balanceTitle != null)
				{
					TweenMax.to(balanceTitle, hideTime, {alpha:0});
				}
				if (cryptoBalance != null)
				{
					TweenMax.to(cryptoBalance, hideTime, {alpha:0});
				}
				if (eurBalance != null)
				{
					TweenMax.to(eurBalance, hideTime, {alpha:0});
				}
			}
		}
		
		private function showCurrentContent():void 
		{
			drawIllustration();
			updatePositions();
			drawSupportButton();
			drawBalanceTitle();
			updateSteps();
			
			if (selectedFilter == TAB_ACCOUNT_MCA)
			{
				if (enterCodeButton != null)
				{
					scroll.addObject(enterCodeButton);
				}
				if (cryptoBalance != null)
				{
					view.addChild(cryptoBalance);
				}
				if (eurBalance != null)
				{
					view.addChild(eurBalance);
				}
				
				loadRegistrationStatus();
				loadBalance();
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_CH)
			{
				if (enterCodeButton != null)
				{
					scroll.removeObject(enterCodeButton);
				}
				/*if (balanceTitle != null && view.contains(balanceTitle))
				{
					view.removeChild(balanceTitle);
				}*/
				if (cryptoBalance != null && view.contains(cryptoBalance))
				{
					view.removeChild(cryptoBalance);
				}
				if (eurBalance != null && view.contains(eurBalance))
				{
					view.removeChild(eurBalance);
				}
			}
			else if (selectedFilter == TAB_ACCOUNT_TRADE_EU)
			{
				if (enterCodeButton != null)
				{
					scroll.removeObject(enterCodeButton);
				}
				if (cryptoBalance != null && view.contains(cryptoBalance))
				{
					view.removeChild(cryptoBalance);
				}
				if (eurBalance != null && view.contains(eurBalance))
				{
					view.removeChild(eurBalance);
				}
			}
			
			TweenMax.to(illustration, showTime, {alpha:1, onComplete:unlock});
			TweenMax.to(supportButton, showTime, {alpha:1});
			if (enterCodeButton != null)
			{
				TweenMax.to(enterCodeButton, showTime, {alpha:1});
			}
			if (balanceTitle != null)
			{
				TweenMax.to(balanceTitle, showTime, {alpha:1});
			}
			if (cryptoBalance != null)
			{
				TweenMax.to(cryptoBalance, showTime, {alpha:1});
			}
			if (eurBalance != null)
			{
				TweenMax.to(eurBalance, showTime, {alpha:1});
			}
		}
		
		private function unlock():void 
		{
			locked = false;
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed) return;
			super.deactivateScreen();
			if (topBar != null)
				topBar.deactivate();
			
			scroll.disable();
			supportButton.deactivate();
			
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			
			if (steps != null)
			{
				for (var i:int = 0; i < steps.length; i++) 
				{
					steps[i].deactivate();
				}
			}
			if (okButton != null)
			{
				okButton.deactivate();
			}
			PointerManager.removeTap(enterCodeButton, enterCode);
		}
		
		override protected function drawView():void {
			if (_isDisposed) return;
			topBar.drawView(_width);
		}
		
		override public function dispose():void {
			if (_isDisposed) return;
			instance = null;
			Auth.S_PHAZE_CHANGE.remove(onPhazeChangedAuth);
			
			clearItems();
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (solvencyAction != null)
			{
				solvencyAction.remove();
				solvencyAction = null;
			}
			
			if (depositAction != null)
			{
				depositAction.remove();
				depositAction = null;
			}
			
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			if (balanceTitle != null)
			{
				UI.destroy(balanceTitle);
				balanceTitle = null;
			}
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			if (disabledMessage != null)
			{
				UI.destroy(disabledMessage);
				disabledMessage = null;
			}
			if (startClip != null)
			{
				UI.destroy(startClip);
				startClip = null;
			}
			if (endClip != null)
			{
				UI.destroy(endClip);
				endClip = null;
			}
			if (lines != null)
			{
				UI.destroy(lines);
				lines = null;
			}
			if (supportButton != null)
			{
				supportButton.dispose();
				supportButton = null;
			}
			if (cryptoBalance != null)
			{
				cryptoBalance.dispose();
				cryptoBalance = null;
			}
			if (eurBalance != null)
			{
				eurBalance.dispose();
				eurBalance = null;
			}
			if (scroll != null)
			{
				TweenMax.killTweensOf(scroll.view);
				scroll.dispose();
				scroll = null;
			}
			if (scrollBack != null)
			{
				UI.destroy(scrollBack);
				scrollBack = null;
			}
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
			if (enterCodeButton != null)
			{
				enterCodeButton.dispose();
				enterCodeButton = null;
			}
			if (shadow != null)
			{
				UI.destroy(shadow);
				shadow = null;
			}
			
			pendingTransactions = null;
			actions = null;
			
			_isDisposed = true;
			super.dispose();
		}
		
		private function onPhazeChangedAuth(realChange:Boolean = true):void 
		{
			if (selectedFilter != TAB_ACCOUNT_MCA)
			{
				return;
			}
			if (Auth.regSteps != registrationType)
			{
				loadRegistrationStatus();
			}
			else{
				onPhazeChanged(realChange);
			}
		}
	}
}