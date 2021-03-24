package com.dukascopy.connect.sys.dialogManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.list.renderers.ListSimpleText;
	import com.dukascopy.connect.screens.dialogs.InfoDialog;
	import com.dukascopy.connect.screens.dialogs.InfoStepsPopup;
	import com.dukascopy.connect.screens.dialogs.QuestionRulesDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenActivateCardDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenAddInvoiceDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenAddPuzzleDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenAlertDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenAlertTextDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenChangePayPassDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenCreateChatByPhoneDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenNotificationDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayPassDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayPassTouchIDDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenQuestionsDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenSecureCodeDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenSetPinDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenUseTouchIDDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenVerifyDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenVideoSettingsDialog;
	import com.dukascopy.connect.screens.dialogs.SpamChannelsInfoDialog;
	import com.dukascopy.connect.screens.dialogs.bottom.ActionSheetIOSPopup;
	import com.dukascopy.connect.screens.dialogs.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.geolocation.CityGeoposition;
	import com.dukascopy.connect.screens.dialogs.geolocation.SelectLocationPopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ScreenLanguagesPopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ScreenPromoRulesPopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ScreenQuestionInfoPopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ScreenQuestionRulesPopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ScreenSecretPopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.ScreenSelectItemPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.PaymentsLoginScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.ScreenPayPassDialogNew;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.vo.PaymentsNewsVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class DialogManager{
		
		public static var S_SHOW:Signal = new Signal('DialogManager.S_SHOW');
		public static var S_CLOSE_DIALOG:Signal = new Signal('DialogManager.S_CLOSE_DIALOG');
		static public var hasOpenedDialog:Boolean;
		static public var currentScreenType:String;
		static public const TYPE_SCREEN:String = "typeScreen";
		static public const TYPE_DIALOG:String = "typeDialog";
		
		public function DialogManager() { }
		
		static public function alert(title:String, text:String, callBack:Function = null, buttonOk:String = null, buttonSecond:String = null, buttonThird:String = null, textAlign:String = TextFormatAlign.LEFT, htmlText:Boolean = false, transparencyBack:Number = 0.5, showFullTitle:Boolean = false, onContentTap:Function = null, closeTimer:int = 0, paddingRight:int = 0):void {
			if (hasOpenedDialog == true)
				return;
			if (buttonOk == null)
				buttonOk = Lang.textOk;
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenAlertDialog, {
				title:title, 
				text:text, 
				callBack:callBack, 
				buttonOk:buttonOk, 
				buttonSecond:buttonSecond, 
				buttonThird:buttonThird, 
				textAlign:textAlign, 
				htmlText:htmlText,
				showFullTitle:showFullTitle,
				onContentTap:onContentTap,
				closeTimer:closeTimer,
				paddingRight:paddingRight
			}, transparencyBack);
		}
		
		/*static public function alertQuestionInfo(title:String,
										text:String,
										callBack:Function = null,
										buttonOk:String = 'ok',
										buttonSecond:String = null,
										buttonThird:String = null,
										textAlign:String = TextFormatAlign.LEFT,
										htmlText:Boolean = false,
										transparencyBack:Number = 0.3,
										showFullTitle:Boolean = false,
										onContentTap:Function = null
										):void{
			hasOpenedDialog = true;
			S_SHOW.invoke(ScreenAlertQuestionActionsDialog, { title:title,
												text:text, 
												callBack:callBack, 
												buttonOk:buttonOk, 
												buttonSecond:buttonSecond, 
												buttonThird:buttonThird, 
												textAlign:textAlign, 
												htmlText:htmlText,
												showFullTitle:showFullTitle,
												onContentTap:null
												}, transparencyBack);
		}*/
		
		static public function alertText(title:String, 
			text:String, 
			callBackBtns:Function = null, 
			callBackContent:Function = null, 
			buttonOk:String = 'ok', 
			buttonSecond:String = null, 
			htmlText:Boolean = false):void {
				hasOpenedDialog = true;
				currentScreenType = TYPE_DIALOG;
				S_SHOW.invoke(ScreenAlertTextDialog,
					{
						title:title,
						text:text,
						callBackBtns:callBackBtns,
						callBackContent:callBackContent,
						buttonOk:buttonOk,
						buttonSecond:buttonSecond,
						htmlText:htmlText
					}
				);
		}
		
		static public function showDialog(dialog:Class, params:Object = null, screenType:String = null):void {
			if (screenType == null)
			{
				screenType = TYPE_DIALOG;
			}
			hasOpenedDialog = true;	
			currentScreenType = screenType;
			S_SHOW.invoke(dialog, params);
		}
		
		static public function closeDialog():void {
			hasOpenedDialog = false;
			S_CLOSE_DIALOG.invoke();
		}
		
		static public function showTinyMenu(title:String, data:Object):void{
			
		}
		
		static public function showVideoSettings(callBack:Function = null):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenVideoSettingsDialog, { callBack:callBack }, .9);
		}
		
		static public function showQuestionInfoDialog(data:Object, callBack:Function = null, title:String = null):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenQuestionInfoPopup, { callBack:callBack, data:data, title:title } );
		}
			
		static public function showInfoDialog(data:Object, callBack:Function = null, title:String = null):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(InfoDialog, { callBack:callBack, data:data, title:title } );
		}
		
		static public function showSpamChannelsInfoDialog(data:Object, callBack:Function = null, title:String = null):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(SpamChannelsInfoDialog, { callBack:callBack, data:data, title:title } );
		}
		
		static public function showPin(callBack:Function):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenSetPinDialog, { callBack:callBack } );
		}
		
		static public function showPayPass(callBack:Function, data:Object = null):void {
			hasOpenedDialog = true;
			var dialogData:Object = {};
			dialogData.title = Lang.paymentsPassword;
			dialogData.buttonOk = Lang.textOk;
			dialogData.text = Lang.pleaseEnterPassword;
			dialogData.callBack = callBack;
			dialogData.btnsCount = 1;
			dialogData.data = data;
			currentScreenType = TYPE_SCREEN;
		//	currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(PaymentsLoginScreen, dialogData, 1);
		}
		
		static public function showPayPassTouchID(callBack:Function):void {
			currentScreenType = TYPE_DIALOG;
			hasOpenedDialog = true;
			var data:Object = {};
			data.title = Lang.password;
			data.buttonOk = Lang.textOk;
			var message:String;
			if (Config.APPLE_BOTTOM_OFFSET > 0)
			{
				message = Lang.pleaseEnterPasswordFaceID;
			}
			else
			{
				message = Lang.pleaseEnterPasswordTouchID;
			}
			data.text = message;
			data.callBack = callBack;
			data.btnsCount = 1;
			S_SHOW.invoke(ScreenPayPassTouchIDDialog, data, 1);
		}
		
		static public function showSecureCode(callBack: Function, isEnter: Boolean, isStars: Boolean = true, value: String = "", additionalData:Object = null): void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenSecureCodeDialog, {
				callBack: callBack,
				isEnter: isEnter,
				additionalData: additionalData,
				isStars: isStars,
				value: value
			}, .7);
		}
		
		static public function showVerify(callBack:Function,account:Object):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			//if(obj != null && "uid" in obj ){.uid
			
			var data:Object = {};
			data.title = Lang.TEXT_VERIFY_YOUR_CARD;
			
			data.buttonOk = Lang.textVerify;
			//data.text = "Please enter the amount that has been charged from your card.";
			data.callBack = callBack;
			data.buttonSecond = Lang.textBack;
			data.account = account;
			S_SHOW.invoke(ScreenVerifyDialog, data);
		}
		
		
		
		static public function showActivateCard(callBack:Function,cardData:Object, additional:Object = null):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			var data:Object = {};
			data.title = Lang.activateCardText;
			data.buttonOk = Lang.activateButtonText;
			data.htmlText = true;			
			var partMain:String = Lang.cornerActivationText;
			var partSecodary:String = cardData.masked;
			var formatedAccountNumber:String = partSecodary.substr(0, 4) + " " + partSecodary.substr(4, 4) + " <b>XXXX</b> " + partSecodary.substr(12);
			var resultText:String = "<font color='#3e4756' size='" + int(Config.FINGER_SIZE * .22) + "'>"   + partMain   + "</font><br>" +
									"<font color='#93a2ae' size='" + int(Config.FINGER_SIZE*.34) + "'>" + formatedAccountNumber+  "</font>" ;
			data.text= resultText;
			data.callBack = callBack;
			data.buttonSecond = Lang.textBack;
			data.cardData = cardData;
			if (additional != null)
				data.additional = additional;
			S_SHOW.invoke(ScreenActivateCardDialog, data);
		}
		
		static public function showUseTouchID(callBack:Function):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			var obj:Object = { title:Lang.paymentsPassword,
			callBack:callBack,
			buttonOk:Lang.textYes.toUpperCase(),
			buttonSecond:Lang.textNo.toUpperCase(),
			buttonThird:null,
			textAlign:TextFormatAlign.CENTER,
			htmlText:false,
			showFullTitle:false
			};
			S_SHOW.invoke(ScreenUseTouchIDDialog, obj);
		}
		
		static public function showChangePayPass(callBack:Function):void {
			currentScreenType = TYPE_DIALOG;
			if (hasOpenedDialog == true && MobileGui.dialogScreen.currentScreenClass == ScreenChangePayPassDialog)
				return;
			hasOpenedDialog = true;
			S_SHOW.invoke(ScreenChangePayPassDialog, { callBack:callBack }, 1);
		}
		
		static public function showPhone(callBack:Function):void {
			currentScreenType = TYPE_DIALOG;
			hasOpenedDialog = true;
			S_SHOW.invoke(ScreenCreateChatByPhoneDialog, { callBack:callBack } );
		}
		
		static public function showAddPuzzle(callBack:Function, obj:Object = null):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			if(obj == null){
				obj = { title:Lang.addPuzzle,
					callBack:callBack,
					buttonOk:Lang.textSend.toUpperCase(),
					buttonSecond:Lang.textCancel.toUpperCase(),
					buttonThird:null,
					textAlign:TextFormatAlign.CENTER,
					htmlText:false,
					showFullTitle:false,
					image:null
				};
			}
			
			S_SHOW.invoke(ScreenAddPuzzleDialog, obj, .7);
		}
		
		/*public static function showExtraTipsPopup(currency:String = null, type:String = null):void {
			hasOpenedDialog = true;
			S_SHOW.invoke(ScreenExtraTipsPopup, { buttonSecond:Lang.textCancel, title:Lang.addExtraTips, currency:currency, type:type }, .7);
		}*/
		
		static public function showInvitedNotification(data:Object):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenNotificationDialog, { name:data.name } );
		}
		
		static public function showQuestionsDialog(data:Object):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenQuestionsDialog, data);
		}
		
		static public function show911Rules(data:Object):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenQuestionRulesPopup, data);
		}
		
		static public function showPromoEventsRules(data:Object):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenPromoRulesPopup, data);
		}
		
		static public function showSecretPopup(onOKFunction:Function):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenSecretPopup, { buttonSecond:Lang.textCancel, title:Lang.secretTitle, onOKFunction:onOKFunction }, .7);
		}
		
		static public function showGeoPopup(onOKFunction:Function, selectedCity:CityGeoposition):void {
			currentScreenType = TYPE_DIALOG;
			DialogManager.showDialog(SelectLocationPopup, { callback:onOKFunction, selectedCity:selectedCity } );
		}
		
		static public function showLangPopup():void {
			currentScreenType = TYPE_DIALOG;
			hasOpenedDialog = true;
			S_SHOW.invoke(ScreenLanguagesPopup, { buttonSecond:Lang.textCancel, title:Lang.addLanguages }, .7);
		}
		
		static public function showSelectItemDialog(data:Object):void {
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(ScreenSelectItemPopup, data);
		}
		
		/*static public function showQuestionsReactionsDialog(data:Object):void {
			hasOpenedDialog = true;
			S_SHOW.invoke(ScreenQuestionReactionsDialog, data);
		}*/
		
		static public function showQuestionRulesDialog(callBack:Function = null, title:String = null, text:String = null):void {
			hasOpenedDialog = true;
			currentScreenType = TYPE_DIALOG;
			S_SHOW.invoke(QuestionRulesDialog, { callBack:callBack, text:text, title:title } );
		}
		
		static public function showNotaryDialog():void{
			currentScreenType = TYPE_DIALOG;
			var addr:String = Lang.ADDR_GENEVE;
			if (Auth.countryCode == 380)
				addr = Lang.ADDR_KIEV;
			if (Auth.countryCode == 7)
				addr = Lang.ADDR_MOSCOW;
			var fontSize:int = Config.FINGER_SIZE * .3;
			addr = "<font color='#425774' size='" + fontSize + "'>" + addr + "</font>"
			var steps:Array = new Array();
			steps.push("<font color='#6B7A8A' size='" + fontSize + "'>" + Lang.NOTARY_EXPLAIN_STEP_1.replace("%addr%", addr) + "</font>");
			steps.push("<font color='#6B7A8A' size='" + fontSize + "'>" + Lang.NOTARY_EXPLAIN_STEP_2.replace("%addr%", addr) + "</font>");
			steps.push("<font color='#6B7A8A' size='" + fontSize + "'>" + Lang.NOTARY_EXPLAIN_STEP_3.replace("%addr%", addr) + "</font>");
			steps.push("<font color='#6B7A8A' size='" + fontSize + "'>" + Lang.NOTARY_EXPLAIN_STEP_4.replace("%addr%", addr) + "</font>");
			DialogManager.showDialog(InfoStepsPopup, {title:Lang.NOTARY_EXPLAIN_TITLE, steps:steps});
		}
		
		static public function showActionSheets(title:String, items:Array, callback:Function):void 
		{
			if (Config.PLATFORM_APPLE)
			{
				showDialog(
					ActionSheetIOSPopup,
					{
						items:items,
						callback:callback
					}, DialogManager.TYPE_SCREEN
				);
			}
			else
			{
				showDialog(
					ListSelectionPopup,
					{
						items:items,
						title:title,
						renderer:ListSimpleText,
						callback:callback
					}, DialogManager.TYPE_SCREEN
				);
			}
		}
	}
}