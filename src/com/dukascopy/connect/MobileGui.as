package com.dukascopy.connect {
	
	import assets.JailedIllustrationClip;
	import com.dukascopy.connect.data.ChatSettingsModel;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenBankAccountAction;
	import com.dukascopy.connect.gui.components.HiddenOnlineIndicator;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.networkIndicator.NetworkIndicator;
	import com.dukascopy.connect.gui.puzzle.Puzzle;
	import com.dukascopy.connect.gui.tools.ImagePreviewCrop;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.LoginScreen;
	import com.dukascopy.connect.screens.MyAccountScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.call.CallScreen;
	import com.dukascopy.connect.screens.chat.main.VIChatScreen;
	import com.dukascopy.connect.screens.roadMap.RoadMapScreenNew;
	import com.dukascopy.connect.screens.serviceScreen.BottomMenuScreen;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.GlobalDate;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.callManager.CallsHistoryManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.ChatUsersManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.contactsManager.ContactsManager;
	import com.dukascopy.connect.sys.debug.RemoteDebugger;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.geolocation.GeolocationManager;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.messagesController.MessagesController;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.notificationManager.InnerNotificationManager;
	import com.dukascopy.connect.sys.notificationManager.PushNotificationsNative;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayNews;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.phoneWeightManager.PhoneWeightManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.promoEvents.PromoEvents;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.settings.GlobalSettings;
	import com.dukascopy.connect.sys.socialManager.SocialManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.sys.stat.StatManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.swiper.Swiper;
	import com.dukascopy.connect.sys.touchID.TouchIDManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.extensions.UserExtensionsManager;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.utils.RenderUtils;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.dccext.DCCExt;
	import com.dukascopy.dukascopyextension.DukascopyExtensionAndroid;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import connect.DukascopyExtension;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.display.FocusDirection;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageOrientation;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	public class MobileGui {
		
		static public const S_WS_EVENT:Signal = new Signal("WS.S_WS_EVENT");
		
		static private var S_MAIN_SCREEN_CHANGE:Signal = new Signal("MobileGui.S_MAIN_SCREEN_CHANGE");
		static public var S_DIALOG_CLOSED:Signal = new Signal("MobileGui.S_DIALOG_CLOSED");
		static public var S_BACK_PRESSED:Signal = new Signal("MobileGui.S_BACK_PRESSED");
		
		static public var stage:Stage;
		
		static private var _softKeyboardOpened:Boolean;
		static private var _softKeyboardMoving:Boolean;
		static private var _softKeyboardHeight:int = 0;
		static private var _softKeyboardHeightOriginal:int = 0;
		static private var _softKeyboardYPosition:Number = 0;
		
		static private var _currentOrientation:String = StageOrientation.DEFAULT;
		
		static private var _isActive:Boolean = true;
		static private var _isCreated:Boolean = false;
		
		static private var authSreenShowed:Boolean = false;
		// EXTENTIONS
		static public var dce:DukascopyExtension;
		static public var androidExtension:DukascopyExtensionAndroid;
		// INIT FRAMES
		private var initFramesCount:int = 10;
		private var framesCount:int = 0;
		// SCREEN MANAGERS
		static private var mainSM:ScreenManager;
		static private var serviceSM:ScreenManager;
		static private var dialogsSM:ScreenManager;
		// CONTAINERS
		private var container:Sprite;
			private var boxScreens:Sprite;
			private var boxDialog:Sprite;
			private var boxLightBox:Sprite;
			private var boxBlack:Sprite;
			private var boxService:Sprite;
		private var ni:NetworkIndicator;
		// SHOWED FLAGS
		static private var _dialogShowed:Boolean = false;
		static private var _serviceShowed:Boolean = false;
		static private var testField:TextField;
		static private var _doNotOpenScreenOnStart:Boolean;
		static private var testText:TextField;
		
		static public var th:MobileGui;
		static public var preventScreenRemove:Boolean;
		
		public function MobileGui(container:Sprite, stage:Stage) {
			th = this;
			
			this.container = container;
			
			MobileGui.stage = stage;
			
			_softKeyboardYPosition = stage.stageHeight;
			
			initComponents();
			create();
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeativate);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onAppExit);
		}
		
		private function initComponents():void {
			
			if (Config.PLATFORM_APPLE)
			{
				DCCExt.init();
			}
			
			Loop.init(stage);
			RenderUtils.stageRef = stage;
			ToastMessage.setStage(stage);
			ImagePreviewCrop.setStage(stage);
			NewMessageNotifier.init();
			ChatUsersManager.init();
			NativeExtensionController.init();
			PushNotificationsNative.init();
			NetworkManager.init();
			MessagesController.init();
			TweenPlugin.activate([AutoAlphaPlugin]);
			Swiper.init(stage);
			WS.init();
			/*if (Config.PLATFORM_WINDOWS == true)
				WSNew.init();*/
			CallManager.init();
			PhonebookManager.init();
			ImageManager.init();
			SoundController.init();
			InnerNotificationManager.init(stage);
			ChatManager.init();
			CallsHistoryManager.init();
			ChannelsManager.init();
			Gifts.init();
			PayAPIManager.init();
			ReferralProgram.init();
			PaidBan.init();
			Shop.init();
			GeolocationManager.init();
			PromoEvents.init();
			UserExtensionsManager.init();
			Calendar.init();
			SoftKeyboard.startDetectHeight();

			/*if(Config.PLATFORM_WINDOWS)
				stage.addChild(new MemoryMonitor());*/
		}
		
		private function onInitFrames():void {
			if (framesCount > initFramesCount) {
				Loop.remove(onInitFrames);
				create();
			}
			framesCount++;
		}
		
		private function create():void {
			if (_isCreated == true)
				return;
			_isCreated = true;
			
			boxScreens = new Sprite();
			container.addChild(boxScreens);
			
			mainSM = new ScreenManager("Main");
			boxScreens.addChild(mainSM.view);
			
			boxLightBox = new Sprite();
			boxLightBox.mouseEnabled = false;
			boxLightBox.mouseChildren = true;
			container.addChild(boxLightBox);
			
			boxBlack = new Sprite();
			boxBlack.graphics.beginFill(0, 1);
			boxBlack.graphics.drawRect(0, 0, 1, 1);
			boxBlack.graphics.endFill();
			boxBlack.visible = false;
			boxBlack.alpha = 0;
			
			boxService = new Sprite();
			container.addChild(boxService);
			serviceSM = new ScreenManager("Service screens");
			serviceSM.manager = ServiceScreenManager;
			serviceSM.dontActivate = true;
			serviceSM.setBackground(false);
			
			boxDialog = new Sprite();
			container.addChild(boxDialog);
			dialogsSM = new ScreenManager("Dialogs");
			dialogsSM.manager = DialogManager;
			dialogsSM.dontActivate = true;
			dialogsSM.setBackground(false);
			
			setSignalsAndEvents();
			onStageResize();
			
			LightBox.setStage(stage, boxLightBox);
			Puzzle.setStage(stage, boxLightBox);
			LangManager.init();
			Auth.init();
			
			/*if (Config.isTF() == true) {
				ni ||= new NetworkIndicator();
				if (ni.parent == null)
					stage.addChild(ni);
			} else if (ni != null) {
				ni.dispose();
				ni = null;
			}*/

			container.addChild(new HiddenOnlineIndicator());



			//debug_createWSLogger();

		}

		private function debug_createWSLogger():void{
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25);
			tf.mouseEnabled = false;
			tf.mouseWheelEnabled = false;
			tf.backgroundColor = 0;
			tf.background = true;
			tf.alpha = .7;
			tf.textColor = 0xFFFFFF;
			tf.y = Config.FINGER_SIZE_DOT_75 * 3;
			tf.x = 0;
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight * .3;
			tf.wordWrap = true;
			stage.addChild(tf);

			var txt:Array=[];

			GD.S_DEBUG_WS.add(function (str:String):void{
				txt.push(str);
				if(txt.length>300)
						txt.shift();
				tf.text="";
				for(var i:int=0;i<txt.length;i++)
					tf.appendText(txt[i]+"\n");
				tf.scrollV=tf.maxScrollV;
			});


			var spr:Sprite=new Sprite();
			spr.graphics.beginFill(0x00FF00,1);
			spr.graphics.drawRoundRect(0,0,30,30,4,4);
			spr.addEventListener(MouseEvent.CLICK,function (e:MouseEvent):void {
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,tf.text,true);
			});
			spr.x=stage.stageWidth*.5;
			spr.y=150;
			stage.addChild(spr);
		}
		
		private function setSignalsAndEvents():void {
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeedAuthorization);
			Auth.S_AUTHORIZED.add(onAuthorized);
			DialogManager.S_SHOW.add(onDialogShow);
			DialogManager.S_CLOSE_DIALOG.add(onDialogClose);
			ServiceScreenManager.S_SHOW.add(onServiceScreenShow);
			ServiceScreenManager.S_CLOSE_DIALOG.add(onServiceScreenClose);
			Input.S_SOFTKEYBOARD.add(onSoftKeyboard);
			SoftKeyboard.S_OPENING.add(onCustomSoftKeyboardMoving);
			SoftKeyboard.S_OPENED.add(onCustomSoftKeyboardOpened);
			SoftKeyboard.S_CLOSING.add(onCustomSoftKeyboardMoving);
			SoftKeyboard.S_CLOSED.add(onCustomSoftKeyboardClosed);
			
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
			
			S_MAIN_SCREEN_CHANGE.add(onMainScreenChangeInvoke);
		}
		
		private static function onActivate(e:Event = null):void {
			echo("MobileGui", "onActivate");
			_isActive = true;
			if (stage != null) {
				stage.quality = StageQuality.LOW; // Rewaet BUG c chernim ekranom na Androide 
				stage.frameRate = 60;
			}
			activateByUser();
			/*if (Config.PLATFORM_ANDROID == true)
				if (androidExtension != null)
					androidExtension.clearNotifications();*/
		}
		
		private function onDeativate(e:Event):void {
			echo("MobileGui", "onDeativate");
			_isActive = false;
			if (stage != null) {
				stage.quality = StageQuality.MEDIUM; // Rewaet BUG c chernim ekranom na Androide
				stage.assignFocus(null, FocusDirection.NONE);
			}
			deactivateByUser();
			SoftKeyboard.closeKeyboard();
			onSoftKeyboard(false);
			SoundController.stopAllChatSounds();
			QuestionsManager.setInOut(false);
		}
		
		static private function onAppExit(e:Event):void {
			PayManager.reset();
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == 27) {
				if (MobileGui.isActive == true)
					MobileGui.deactivateByUser();
			}
			if (e.keyCode != Keyboard.BACK)
				return;
			e.preventDefault();
			e.stopImmediatePropagation();
			if (_softKeyboardOpened == true) {
				SoftKeyboard.closeKeyboard();
				onStageResize();
				return;
			}
			if (DialogManager.hasOpenedDialog && !Auth.isExpired) {
				if (dialogsSM.currentScreen != null && DialogManager.currentScreenType == DialogManager.TYPE_SCREEN) {
					dialogsSM.currentScreen.onBack();
				} else {
					DialogManager.closeDialog();
				}
				return;
			}
			if (ServiceScreenManager.hasOpenedDialog && !Auth.isExpired) {
				ServiceScreenManager.onBack();
				return;
			}
			if (InvoiceManager.isProcessingInvoice) {
				InvoiceManager.stopProcessInvoice();
				return;
			}		
			
			if (Puzzle.isOpened) {
				Puzzle.closePuzzle();
				return;
			}
			
			if (LightBox.isShowing) {
				LightBox.close();
				return;
			}
			if (ImagePreviewCrop.isShowing) {
				ImagePreviewCrop.close();
				return;
			}
			S_BACK_PRESSED.invoke();
		}
		
		static public function onQuitDialogCallback(value:int):void {
			if (value == 1)
				NativeApplication.nativeApplication.exit();
		}
		
		public static function changeMainScreen(screen:Class, data:Object = null, directon:int = 0):void {
			if (screen == LoginScreen) {
				S_MAIN_SCREEN_CHANGE.invoke(screen, data, directon);
				return;
			}
			var screenLabel:String;
			if (screen == RootScreen)
				screenLabel = "RootScreen";


			if (screenLabel != null)
				Store.save(Store.VAR_SCREEN, screenLabel);

			S_MAIN_SCREEN_CHANGE.invoke(screen, data, directon);
		}
		
		static public function showChatScreen(chatData:ChatScreenData, directon:int = 0, currentClipEndAlpha:Number = 1):void {
			
			if (centerScreen.currentScreen != null && centerScreen.currentScreen is CallScreen)
			{
				// videoidentification and other calls in progress;
				return;
			}
			
			if (Config.isAdmin() == false && Auth.myProfile != null && Auth.myProfile.payRating < 3) {
				var canOpenChat:Boolean = true;
				if (chatData.type == ChatInitType.USERS_IDS && chatData.usersUIDs != null && chatData.usersUIDs.length == 1) {
					if (PhonebookManager.getUserModelByUserUID(chatData.usersUIDs[0]) == null && ContactsManager.getUserModelByUserUID(chatData.usersUIDs[0]) == null) {
						canOpenChat = false;
						if (ChatManager.getChatWithUsersList(chatData.usersUIDs) != null) {
							canOpenChat = true;
						}
						if(chatData.byPhone)
							canOpenChat=true;
					}
				}

				if (canOpenChat == false) {
					var popupData:PopupData = new PopupData();
					var action:IScreenAction = new OpenBankAccountAction();
					var txt_Action:String=Lang.openBankAccount;
					var txt_title:String=Lang.noBankAccount;
					var txt_text:String=Lang.cantStartChatWithoutBankAccount;
					if(Auth.bank_phase.toLowerCase()=="acc_approved") {
						// NOT ENOUGHT POINTS BUT ACCOUNT EXISTS
						txt_Action=Lang.openBankAccount;
						txt_title=Lang.notEnoughtLoyaltyPoints;
						txt_text=Lang.cantStartChatWithoutLoyaltyPoints;
					}
					action.setData(txt_Action);
					popupData.action = action;
					popupData.illustration = JailedIllustrationClip;
					// TITLE TEXT
					popupData.title = txt_title;
					popupData.text = txt_text;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
					return;
				}
			}
			if (dialogShowed == true) {
				DialogManager.closeDialog();
				mainSM.activate();
			}
			var cUID:String;
			if (chatData && ChatManager.getCurrentChat() != null) {
				if (chatData.type == ChatInitType.CHAT) {
					cUID = chatData.chatUID;
					if (chatData.chatVO != null)
						cUID = chatData.chatVO.uid;
					if (cUID != ChatManager.getCurrentChat().uid)
						ChatManager.closeChat();
				} else {
					ChatManager.closeChat();
				}
			}
			var screenClass:Class = ChatScreen;
			var pid:int =-1;
			if (!isNaN(chatData.pid))
				pid = chatData.pid;
			if (pid ==-1 && chatData.chatVO != null && !isNaN(chatData.chatVO.pid))
				pid = chatData.chatVO.pid;
			if (pid == Config.EP_VI_DEF ||
				pid == Config.EP_VI_EUR ||
				pid == Config.EP_VI_PAY) {
					screenClass = VIChatScreen;
			}
			if (!chatData.settings) {
				if (cUID == null) {
					S_MAIN_SCREEN_CHANGE.invoke(screenClass, chatData, directon, currentClipEndAlpha);
					return;
				}
				ChatManager.getChatSettingsModel(cUID, function(model:ChatSettingsModel):void {
					chatData.settings = model;
					S_MAIN_SCREEN_CHANGE.invoke(screenClass, chatData, directon, currentClipEndAlpha);
				});
			} else {
				S_MAIN_SCREEN_CHANGE.invoke(screenClass, chatData, directon, currentClipEndAlpha);
			}
		}
		
		private function onMainScreenChangeInvoke(screen:Class, data:Object = null, direction:int = 0, currentScreenEndAlpha:Number = 1):void {
			echo("MobileGui", "onMainScreenChangeInvoke", "");
			var fromPayments:Boolean = PayManager.isInsidePaymentsScreenNow;
			PayManager.isInsidePaymentsScreenNow = false;
			if (!NetworkManager.isConnected && PayManager.isInsidePaymentsScreenNow) {
				DialogManager.alert(Lang.textAlert, Lang.alertCantOpenPayment);
				PayManager.isInsidePaymentsScreenNow = false;
				if (!fromPayments)
					return;
				mainSM.show(RootScreen);
			}
			mainSM.show(screen, data, direction, 0.3, currentScreenEndAlpha);
		}
		
		private function onDialogShow(dialog:Class, params:Object = null, transparency:Number = .5):void {
			_dialogShowed = true;
			if (LightBox.isShowing == true) {
				LightBox.deactivate();
			} else {
				serviceSM.deactivate();
				mainSM.deactivate();
			}
			if (boxBlack.parent != boxDialog && (dialog == BottomMenuScreen) == false) {
				if (boxBlack.parent == null)
					boxBlack.alpha = 0;
				boxDialog.addChildAt(boxBlack, 0);
			}
			PointerManager.addTap(boxBlack, closePopup)
			TweenMax.killTweensOf(boxBlack);
			
			var dialogPaddingDouble:int = 0;
			
			if (DialogManager.currentScreenType != DialogManager.TYPE_SCREEN) {
				TweenMax.killTweensOf(boxBlack);
				dialogPaddingDouble = Config.DOUBLE_MARGIN * 2;
				TweenMax.to(boxBlack, 21, { autoAlpha:transparency, ease:Quint.easeOut, useFrames:true } );
			}
			else
			{
			//	TweenMax.to(boxBlack, 21, { autoAlpha:transparency, ease:Quint.easeOut, useFrames:true } );
			}
			
			if (dialogsSM.view.parent == null)
				boxDialog.addChild(dialogsSM.view);
			
			var dialogW:int = MobileGui.stage.stageWidth - dialogPaddingDouble;
			var dialogH:int = MobileGui.stage.stageHeight - dialogPaddingDouble - _softKeyboardHeight;
			var dialogHWithPaddings:int = dialogH - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET;
			if (DialogManager.currentScreenType == DialogManager.TYPE_SCREEN)
			{
				dialogHWithPaddings = dialogH;
			}
			dialogsSM.setSize(dialogW, dialogHWithPaddings);
			
			onCustomSoftKeyboardClosed();
			dialogsSM.activate();
			
			dialogsSM.show(dialog, params, 0, 0);
		}
		
		private function closePopup(e:Event):void {
			if (dialogsSM.currentScreen != null)
				DialogManager.closeDialog();
		}
		
		private function closeServiceScreen(e:Event):void {
			if (dialogsSM.currentScreen != null)
				return;
			if (serviceScreen.currentScreen != null && serviceScreen.currentScreen.isModal() == false)
				ServiceScreenManager.closeView();
		}
		
		private function onDialogClose():void {
			_dialogShowed = false;
			PointerManager.removeTap(boxBlack, closePopup);
			dialogsSM.deactivate();
			if (dialogsSM.view.parent != null)
				dialogsSM.view.parent.removeChild(dialogsSM.view);
			dialogsSM.disposeCurentScreen();
			
			S_DIALOG_CLOSED.invoke();
			
			TweenMax.killTweensOf(boxBlack);
			if (LightBox.isShowing == true) {
				TweenMax.to(boxBlack, 21, { autoAlpha:0, ease:Quint.easeOut, useFrames:true, onComplete:removeBoxBlack } );
				LightBox.activate();
				return;
			}
			if (_serviceShowed == true && serviceSM != null && serviceSM.isDisposed == false) {
				boxService.addChildAt(boxBlack, 0);
				TweenMax.to(boxBlack, 21, { autoAlpha:.5, ease:Quint.easeOut, useFrames:true } );
				serviceSM.activate();
				return;
			}
			if (mainSM != null && mainSM.isDisposed == false) {
				TweenMax.to(boxBlack, 21, { autoAlpha:0, ease:Quint.easeOut, useFrames:true, onComplete:removeBoxBlack } );
				mainSM.activate();
			}
			onStageResize();
		}
		
		private function onServiceScreenShow(dialog:Class, params:Object = null, transitionTime:Number = 0.5, transparency:Number = 0.5):void { 
			_serviceShowed = true;
			if (LightBox.isShowing == true) {
				LightBox.deactivate();
			} else {
				mainSM.deactivate();
			}
			if (_dialogShowed == false) {
				if (boxBlack.parent != boxService) {
					if (boxBlack.parent == null)
						boxBlack.alpha = 0;
					boxService.addChildAt(boxBlack, 0);
				}
				if (ServiceScreenManager.currentScreenType != ServiceScreenManager.TYPE_SCREEN) {
					TweenMax.killTweensOf(boxBlack);
					TweenMax.to(boxBlack, 21, { autoAlpha:transparency, ease:Quint.easeOut, useFrames:true } );
				}
			}
			if (serviceSM.view.parent == null)
				boxService.addChild(serviceSM.view);
			onCustomSoftKeyboardClosed();
			serviceSM.activate();
			PointerManager.addTap(boxBlack, closeServiceScreen);
			serviceSM.show(dialog, params, 0, transitionTime);
			if (mainSM != null)
				mainSM.deactivate();
		}
		
		private function onServiceScreenClose():void {
			PointerManager.removeTap(boxBlack, closeServiceScreen);
			_serviceShowed = false;
			TweenMax.killTweensOf(boxBlack);
			if (MobileGui.dialogShowed == false) {
				TweenMax.to(boxBlack, 21, { autoAlpha:0, ease:Quint.easeOut, useFrames:true, onComplete:removeBoxBlack } );
			}
			mainSM.listenBackSignal();
			serviceSM.deactivate();
			if (serviceSM.view!=null && serviceSM.view.parent != null)
				serviceSM.view.parent.removeChild(serviceSM.view);
			serviceSM.disposeCurentScreen();
			if (MobileGui.dialogShowed == false) {
				if (mainSM != null) {
					if (LightBox.isShowing)
						LightBox.activate();
					else
						mainSM.activate();
				}
			}
			onStageResize();
		}
		
		private function removeBoxBlack():void {
			if (boxBlack.parent == null)
				return;
			boxBlack.parent.removeChild(boxBlack);
		}
		
		private function onCustomSoftKeyboardClosed():void {
			_softKeyboardMoving = false;
			_softKeyboardOpened = false;
			_softKeyboardHeight = 0;
			onStageResize();
		}
		
		private function onCustomSoftKeyboardOpened(h:int):void {
			_softKeyboardMoving = false;
			_softKeyboardOpened = true;
			_softKeyboardHeight = h;
			onStageResize();
		}
		
		private function onCustomSoftKeyboardMoving(h:int):void {
			_softKeyboardMoving = true;
			_softKeyboardHeight = h;
			onStageResize();
		}
		
		private function onSoftKeyboard(shows:Boolean):void {
			_softKeyboardHeight = 0;
			// IF current focus is on input, no need to hide keyboards
			TweenMax.delayedCall(1, function():void {
				echo("MobileGui", "onSoftKeyboard", "TweenMax.delayedCall");
				_softKeyboardOpened = shows;
				// EMULATION
				if (Input.emulateSoftKeyboard == true) {
					if (shows == true)
						_softKeyboardHeight = 300;
					onStageResize();
					return;
				}
				if (shows == true || (SoftKeyboard.getInstance() != null && SoftKeyboard.getInstance().isShowed == true)) {
					trace("onSoftKeyboard", "3");
					if (Config.PLATFORM_ANDROID) {
						trace("onSoftKeyboard", "4", SoftKeyboard.extensionKeyboardHeightDetected, SoftKeyboard.detectedKeyboardHeight);
						if (SoftKeyboard.extensionKeyboardHeightDetected) {
							_softKeyboardHeight = SoftKeyboard.detectedKeyboardHeight;
							onStageResize();
						} else {
							trace("onSoftKeyboard", "4");
							SoftKeyboard.S_REAL_HEIGHT_DETECTED.add(onAndroidKeyboardHeightDetected);
							SoftKeyboard.startDetectHeight();
						}
					} else {
						if (_softKeyboardHeightOriginal > 0) {
							_softKeyboardHeight = _softKeyboardHeightOriginal;
							onStageResize();
						} else {
							Loop.add(onSoftKeyboardHeightLoop);
						}
					}
				} else
				{
					onStageResize();
				}
			}, null, true);
		}
		
		private function onAndroidKeyboardHeightDetected():void {
			SoftKeyboard.S_REAL_HEIGHT_DETECTED.remove(onAndroidKeyboardHeightDetected);
			if (_softKeyboardOpened == true) {
				_softKeyboardHeight = SoftKeyboard.detectedKeyboardHeight;
				onStageResize();
			}
		}
		
		private function onSoftKeyboardHeightLoop():void {
			if (_softKeyboardOpened == false) {
				Loop.remove(onSoftKeyboardHeightLoop);
				_softKeyboardHeight = 0;
				return;
			}
			
			_softKeyboardHeight = stage.softKeyboardRect.height;
			if (_softKeyboardHeight > 0) {
				_softKeyboardHeightOriginal = _softKeyboardHeight;
				Loop.remove(onSoftKeyboardHeightLoop);
				echo("MobileGui", "onSoftKeyboardHeightLoop");
				onStageResize();
				return;
			}
		}
		
		private function onOrientationChange(e:StageOrientationEvent):void {
			e.preventDefault();
			_currentOrientation = e.afterOrientation;
		}
		
		private function onStageResize(e:Event = null):void {
			
			if (_isCreated == false)
				return;
			
			if (container != null && stage != null)
			{
				container.graphics.clear();
				container.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				container.graphics.drawRect(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
				container.graphics.endFill();
			}
			
			var sw:int = MobileGui.stage.stageWidth;
			var sh:int = MobileGui.stage.stageHeight;
			
			if (sw <= 0 || sh <= 0) {
				TweenMax.delayedCall(1, onStageResize);
				return;
			}
			var stageH:int = sh - _softKeyboardHeight; // tut soft keyboard height nepravilnaja 
			InnerNotificationManager.setWidth(sw);
			if (mainSM != null) {
				if ((dialogsSM == null || dialogsSM.view.parent == null) &&
					(serviceSM == null || serviceSM.view.parent == null)) {
					mainSM.setSize(sw, stageH);
					return;
				}
			}
			if(boxBlack!= null) {
				boxBlack.width = sw;
				boxBlack.height = sh;
			}
			var dialogPadding:int = Config.DOUBLE_MARGIN;
			var dialogPaddingDouble:int = dialogPadding * 2;
			var dialogW:int = sw - dialogPaddingDouble;
			var dialogH:int = sh - dialogPaddingDouble - _softKeyboardHeight;
			var dialogHWithPaddings:int = dialogH - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET;
			
			if (dialogsSM != null && dialogsSM.view.parent != null) {
				
				if (DialogManager.currentScreenType == DialogManager.TYPE_DIALOG) {
					dialogsSM.view.x = dialogPadding;
					dialogsSM.view.y = dialogPadding + Config.APPLE_TOP_OFFSET;
					dialogsSM.setSize(dialogW, dialogHWithPaddings);
				} else if (DialogManager.currentScreenType == DialogManager.TYPE_SCREEN) {
					dialogsSM.setSize(sw, stageH);
					dialogsSM.view.x = 0;
					dialogsSM.view.y = 0;
				}
			}
			if (serviceSM != null && serviceSM.view.parent != null) {
				var screenWidth:int;
				var screenHeight:int;
				if (ServiceScreenManager.currentScreenType == ServiceScreenManager.TYPE_DIALOG) {
					screenWidth = dialogW;
					screenHeight = dialogHWithPaddings;
					serviceSM.view.y = dialogPadding + Config.APPLE_TOP_OFFSET;
				} else if (ServiceScreenManager.currentScreenType == ServiceScreenManager.TYPE_SCREEN) {
					screenWidth = sw;
					screenHeight = stageH;
					dialogPadding = 0;
					serviceSM.view.y = Math.round((stageH - screenHeight) * .5);
				}
				serviceSM.view.x = dialogPadding;
				boxBlack.width = sw;
				boxBlack.height = sh;
				serviceSM.setSize(screenWidth, screenHeight);
			}
		}
		
		static public function setCurrentOrientation(value:String):void {
			_currentOrientation = value;
		}
		
		private function onAuthNeedAuthorization():void {
			authSreenShowed = true;
			mainSM.clear();
			changeMainScreen(LoginScreen);
			PaymentsManager.deactivate();
		}
		
		private function onAuthorized():void {
			GlobalSettings.initSettings();
			SQLite.S_CREATE_FINISH.add(onDatabaseCreated);
			SQLite.init();
			GlobalDate.init();
			UsersManager.init();
			StatManager.init();
			PhoneWeightManager.init();

			if(Auth.phone!=15555000987)
				PayNews.init();

			if(Config.isTF())
				new RemoteDebugger();
		}
		
		private function onDatabaseCreated():void 
		{
			SQLite.S_CREATE_FINISH.remove(onDatabaseCreated);
			onDatabaseInitFinish();
		}
		
		private function onDatabaseInitFinish():void 
		{
			SocialManager.init(continueAuth);
		}
		
		private function continueAuth():void {
			if (PushNotificationsNative.handleRemoteNotification(true) == true)
				return;

			/*if(Auth.phone==15555000987){
				mainSM.show(VITestScreen);
				return;
			}*/

			if (authSreenShowed == true) {
				if (SocialManager.available == true)
				{
					var needShowTradingRoadmap:Boolean;
					if (Auth.ch_phase == BankPhaze.VIDID || Auth.ch_phase == BankPhaze.VIDID_PROGRESS || Auth.ch_phase == BankPhaze.VIDID_READY || Auth.ch_phase == BankPhaze.VI_FAIL)
					{
						needShowTradingRoadmap = true;
					}
					if (Auth.eu_phase == BankPhaze.VIDID || Auth.eu_phase == BankPhaze.VIDID_PROGRESS || Auth.eu_phase == BankPhaze.VIDID_READY || Auth.eu_phase == BankPhaze.VI_FAIL)
					{
						needShowTradingRoadmap = true;
					}
					if (needShowTradingRoadmap)
					{
						showRoadMap();
					}
					else
					{
						openMyAccountIfExist();
					}
				}
				else
					mainSM.show(RootScreen);
				return;
			}
			mainSM.show(RootScreen);
		}
		
		static public function get softKeyboardOpened():Boolean { return _softKeyboardOpened; }
		static public function get softKeyboardMoving():Boolean { return _softKeyboardMoving; }
		static public function get softKeyboardYPosition():Number { return _softKeyboardYPosition; }
		
		static public function get currentOrientation():String  { return _currentOrientation; }
		static public function get isVerticalOrientation():Boolean  { return _currentOrientation == StageOrientation.DEFAULT || _currentOrientation == StageOrientation.UPSIDE_DOWN; }
		
		static public function get dialogShowed():Boolean { return _dialogShowed };
		static public function get serviceShowed():Boolean { return _serviceShowed };
		
		static public function get centerScreen():ScreenManager { return mainSM; }
		static public function get dialogScreen():ScreenManager { return dialogsSM; }
		static public function get serviceScreen():ScreenManager { return serviceSM; }
		
		static public function get isActive():Boolean { return _isActive; }
		
		static public function get touchIDManager():TouchIDManager { return NativeExtensionController.touchIDManager; }
		
		static public function setSoftKeyboardY(val:Number):void {
			_softKeyboardYPosition = val;
		}
		
		static public function refreshManagers():void {
			QuestionsManager.refreshLangConsts();
			GeolocationManager.refreshLangConst();
		}
		
		static public function doNotOpenScreenOnStart():void {
			_doNotOpenScreenOnStart = true;
		}
		
		static public function openMyAccountIfExist():void {
			QuestionsManager.setInOut(false);
			if (Auth.bank_phase != "ACC_APPROVED") {
				MobileGui.showRoadMap();
				return;
			}
			if (Config.BANKBOT == true || Auth.companyID == "08A29C35B3") {
				changeMainScreen(MyAccountScreen);
				return;
			}
			mainSM.show(RootScreen);
		}
		
		static public function openBankBot():void {
			QuestionsManager.setInOut(false);
			if (Auth.bank_phase != "ACC_APPROVED") {
				MobileGui.showRoadMap();
				return;
			}
			if (Config.BANKBOT == true || Auth.companyID == "08A29C35B3") {
				BankManager.openChatBotScreen( { bankBot:true/*, backScreen:MyAccountScreen*/ }, true);
				return;
			}
			mainSM.show(RootScreen);
		}
		
		private function cleanMemoryNow():void {
			System.gc();
		}
		
		static public function deactivateByUser():void {
			if (Config.PLATFORM_ANDROID == false || preventScreenRemove == true) {
				preventScreenRemove = false;
				return;
			}
			if (stage != null) {
				if (th.boxScreens.parent != null)
					th.boxScreens.parent.removeChild(th.boxScreens);
				if (th.boxLightBox.parent != null)
					th.boxLightBox.parent.removeChild(th.boxLightBox);
				if (th.boxService.parent != null)
					th.boxService.parent.removeChild(th.boxService);
				if (th.boxDialog.parent != null)
					th.boxDialog.parent.removeChild(th.boxDialog);
			}
		}
		
		static public function activateByUser(...rest):void {
			if (Config.PLATFORM_ANDROID == false)
				return;
			if (stage != null) {
				th.container.addChild(th.boxScreens);
				th.container.addChild(th.boxLightBox);
				th.container.addChild(th.boxService);
				th.container.addChild(th.boxDialog);
			}
		}
		
		static public function addReport(caller:String):void {
			PHP.call_statVI("WrongChatOpen", caller);
		}

		static public function showRoadMap():void
		{
			changeMainScreen(RoadMapScreenNew, null);
		}
		
		static public function traceText(text:String):void 
		{
		//	return;
			if (testText == null)
			{
				testText = new TextField();
				stage.addChild(testText);
				var tf:TextFormat = new TextFormat();
				tf.size = Config.FINGER_SIZE * .2;
				tf.font = Config.defaultFontName;
				tf.color = 0xFFFFFF;
				testText.defaultTextFormat = tf;
				testText.width = stage.stageWidth - 100;
				testText.height = stage.stageHeight * .3;
				testText.multiline = true;
				testText.wordWrap = true;
				testText.background = true;
				testText.backgroundColor = 0;
				testText.alpha = 0.6;
				testText.y = 150;
				testText.x = 100;
				
			}
			testText.appendText("\n" + text);
		//	testText.scrollV = testText.maxScrollV;
		}
	}
}