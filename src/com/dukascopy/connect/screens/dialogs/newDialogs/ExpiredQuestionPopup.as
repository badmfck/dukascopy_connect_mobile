package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import assets.CloseButtonIconSmall;
	import assets.IconOk2;
	import assets.JailedIllustrationClip;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.list.renderers.ListQuestionRenderer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ExpiredQuestionPopup extends BaseScreen {
		
		private var selectorDebitAccont:DDAccountButton;
		private var selectedAccount:Object;
		private var accountsPreloader:HorizontalPreloader;
		
		private var background:Sprite;
		private var nextButton:BitmapButton;
		private var illustration:Bitmap;
		private var text:Bitmap;
		private var title:Bitmap;
		private var container:Sprite;
		private var componentsWidth:Number;
		private var questionClip:Bitmap;
		private var questions:Array;
		private var currentQuestionIndex:int;
		private var price:Bitmap;
		private var cancelButton:BitmapButton;
		private var needShowWallets:Boolean;
		private var mainPreloader:HorizontalPreloader;
		private var locked:Boolean;
		private var iconOK:IconOk2;
		private var successText:Bitmap;
		private var buttonClose:BitmapButton;
		private var accountReady:Boolean;
		
		public function ExpiredQuestionPopup() {
			super();
		}
		
		private function nextClick():void {
			if (questions != null && questions.length <= currentQuestionIndex) {
				close();
			} else if (selectedAccount != null) {
				locked = true;
				mainPreloader.start();
				selectorDebitAccont.deactivate();
				nextButton.deactivate();
				QuestionsManager.payForProlong((questions[currentQuestionIndex] as QuestionVO).uid, selectedAccount.ACCOUNT_NUMBER);
			}
		}
		
		private function onPaySuccess():void {
			currentQuestionIndex ++;
			
			mainPreloader.stop();
			
			TweenMax.to(text, 0.3, {alpha:0});
			TweenMax.to(selectorDebitAccont, 0.3, {alpha:0});
			TweenMax.to(price, 0.3, {alpha:0});
			
			iconOK.x = int(componentsWidth * .5 - (iconOK.width + successText.width + Config.DIALOG_MARGIN * .5) * .5);
			successText.x = int(iconOK.x + iconOK.width + Config.DIALOG_MARGIN * .5);
			
			successText.y = int((questionClip.y + questionClip.height) + (nextButton.y - (questionClip.y + questionClip.height)) * .5);
			iconOK.y = int(successText.y + successText.height * .5 - iconOK.height * .5);
			
			
			iconOK.alpha = 0;
			successText.alpha = 0;
			
			iconOK.visible = true;
			successText.visible = true;
			
			TweenMax.to(iconOK, 0.3, {alpha:1, delay:0.3});
			TweenMax.to(successText, 0.3, {alpha:1, delay:0.3, onComplete:successAnimationEnd});
			
			if (!(questions != null && questions.length > currentQuestionIndex)) {
				TweenMax.to(nextButton, 0.3, {alpha:0});
				TweenMax.to(cancelButton, 0.3, {alpha:0, onComplete:addFinishButton});
				TweenMax.to(nextButton, 0.3, {alpha:1, delay:0.3});
			}
		}
		
		private function addFinishButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textOk, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x77C043, 1, Config.FINGER_SIZE * .8, NaN);
			nextButton.setBitmapData(buttonBitmap);
			nextButton.x = int(componentsWidth * .5 - nextButton.width * .5);
		}
		
		private function successAnimationEnd():void {
			if (questions != null && questions.length <= currentQuestionIndex) {
				if (isActivated == true) {
					nextButton.activate();
					selectorDebitAccont.activate();
				}
			} else
				TweenMax.delayedCall(1.5, processNextQuestion);
		}
		
		private function onPayFail(errorText:String = null):void {
			mainPreloader.stop();
			if (isActivated == true) {
				nextButton.activate();
				selectorDebitAccont.activate();
			}
			if (errorText != null)
				ToastMessage.display(errorText);
		}
		
		private function close():void {
			ServiceScreenManager.closeView();
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			container = new Sprite();
			view.addChild(container);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			container.addChild(nextButton);
			nextButton.alpha = 0.5;
			
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.setDownScale(1);
			cancelButton.setDownColor(0);
			cancelButton.tapCallback = cancelClick;
			cancelButton.disposeBitmapOnDestroy = true;
			container.addChild(cancelButton);
			
			illustration = new Bitmap();
			container.addChild(illustration);
			
			var btnSize:int = Config.FINGER_SIZE * .3;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			buttonClose = new BitmapButton();
			buttonClose.setStandartButtonParams();
			buttonClose.setDownScale(1.3);
			buttonClose.setDownColor(0xFFFFFF);
			buttonClose.tapCallback = onCloseButtonClick;
			buttonClose.disposeBitmapOnDestroy = true;
			buttonClose.show();
			container.addChild(buttonClose);
			var iconClose:Sprite = new CloseButtonIconSmall();
			iconClose.width = iconClose.height = btnSize;
			
			buttonClose.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "ExpiredQuestionPopup.iconClose"), true);
			buttonClose.setOverflow(btnOffset, int(btnOffset * .6), Config.FINGER_SIZE, btnOffset);
			UI.destroy(iconClose);
			iconClose = null;
			
			title = new Bitmap();
			container.addChild(title);
			
			text = new Bitmap();
			container.addChild(text);
			
			price = new Bitmap();
			container.addChild(price);
			
			successText = new Bitmap();
			container.addChild(successText);
			successText.visible = false;
			
			questionClip = new Bitmap();
			container.addChild(questionClip);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			container.addChild(selectorDebitAccont);
			
			accountsPreloader = new HorizontalPreloader();
			container.addChild(accountsPreloader);
			
			mainPreloader = new HorizontalPreloader(AppTheme.GREEN_MEDIUM);
			container.addChild(mainPreloader);
			
			iconOK = new IconOk2();
			UI.scaleToFit(iconOK, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			container.addChild(iconOK);
			iconOK.visible = false;
		}
		
		private function onCloseButtonClick():void {
			close();
		}
		
		private function cancelClick():void {
			currentQuestionIndex ++;
			if (questions != null && questions.length <= currentQuestionIndex)
				close();
			else
				processNextQuestion();
		}
		
		private function processNextQuestion():void {
			TweenMax.to(successText, 0.3, {alpha:0, y:(successText.y - Config.FINGER_SIZE * .5)});
			TweenMax.to(iconOK, 0.3, {alpha:0, y:(iconOK.y - Config.FINGER_SIZE * .5)});
			TweenMax.to(questionClip, 0.3, {alpha:0, x:-Config.FINGER_SIZE, onComplete:renderQuestion, delay:0.5});
			
			TweenMax.to(selectorDebitAccont, 0.3, {alpha:1, delay:0.8});
			TweenMax.to(price, 0.3, {alpha:1, delay:0.8});
			TweenMax.to(text, 0.3, {alpha:1, delay:0.8});
			
			if (isActivated == true) {
				nextButton.activate();
				selectorDebitAccont.activate();
			}
		}
		
		private function renderQuestion():void {
			questionClip.x = Config.FINGER_SIZE;
			drawQuestion();
			TweenMax.to(questionClip, 0.3, {alpha:1, x:0, delay:0.3});
		}
		
		private function checkData():void {
			accountsPreloader.start();
			PaymentsManager.S_ACCOUNT.add(onAccountInfo);
			PaymentsManager.S_READY.add(onDataReady);
			PaymentsManager.activate();
		}
		
		private function onAccountInfo():void {
			accountsPreloader.stop();
			if (needShowWallets == true)
				return;
			selectBigAccount();
		}
		
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onDataReady():void {
			accountReady = true;
			if (_isDisposed == true) {
				return;
			}
			PaymentsManager.S_READY.remove(onDataReady);
			if (needShowWallets) {
				needShowWallets = false;
				DialogManager.showDialog(
					ScreenPayDialog,
					{
						callback: onWalletSelect, 
						data: PayManager.accountInfo.accounts, 
						itemClass: ListPayWalletItem, 
						label: Lang.TEXT_SELECT_ACCOUNT
					}
				);
			}
		}
		
		private function drawAccountSelector():void {
			selectorDebitAccont.setSize(componentsWidth - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.TEXT_SELECT_ACCOUNT);
			selectorDebitAccont.x = int(componentsWidth * .5 - selectorDebitAccont.width * .5);
		}
		
		private function selectBigAccount():void {
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var bigAccount:Object;
			if (wallets != null && wallets.length > 0) {
				bigAccount = wallets[0];
			}
			for (var i:int = 0; i < l; i++) {
				if (Number(bigAccount.BALANCE) < Number(wallets[i].BALANCE))
					bigAccount = wallets[i];
			}
			if (bigAccount != null)
				onWalletSelect(bigAccount);
		}
		
		private function openWalletSelector(e:Event = null):void {
			if (accountReady == true)
			{
				DialogManager.showDialog(
					ScreenPayDialog,
					{
						callback: onWalletSelect, 
						data: PayManager.accountInfo.accounts, 
						itemClass: ListPayWalletItem, 
						label: Lang.TEXT_SELECT_ACCOUNT
					}
				);
			}
			else
			{
				needShowWallets = true;
				checkData();
			}
		}
		
		private function onWalletSelect(account:Object, cleanCurrent:Boolean = false):void {
			if (account == null) {
				if (cleanCurrent == true)
					selectedAccount = account;
			} else
				selectedAccount = account;
			if (account != null || cleanCurrent == true) {
				selectorDebitAccont.setValue(account);
				nextButton.alpha = 1;
			}
			checkDataValid();
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "questions" in data && data.questions != null)
				questions = data.questions as Array;
			
			currentQuestionIndex = 0;
			
			componentsWidth = _width - Config.DIALOG_MARGIN;
			
			background.graphics.beginFill(0x000000, 0.35);
			background.graphics.drawRect(0, 0, _width, _height);
			
			createButtons();
			createIllustration();
			createTitle();
			drawQuestion();
			createPrice();
			createText();
			drawAccountSelector();
			drawSuccessText();
			
			var position:int = 0;
			
			illustration.y = position;
			illustration.x = int(componentsWidth * .5 - illustration.width * .5);
			position += illustration.height + Config.FINGER_SIZE * .18;
			
			title.y = position;
			title.x = int(componentsWidth * .5 - title.width * .5);
			position += title.height + Config.FINGER_SIZE * .21;
			
			questionClip.y = position;
			position += questionClip.height + Config.FINGER_SIZE * .32;
			
			text.y = position;
			text.x = int(componentsWidth * .5 - text.width * .5);
			position += text.height + Config.FINGER_SIZE * .4;
			
			price.y = position;
			price.x = int(componentsWidth * .5 - price.width * .5);
			position += price.height + Config.FINGER_SIZE * .15;
			
			
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + Config.FINGER_SIZE * .45;
			
			nextButton.y = position;
			cancelButton.y = position;
			
			if (questions != null && questions.length > 1) {
				cancelButton.x = Config.DIALOG_MARGIN;
				nextButton.x = cancelButton.x + cancelButton.width + Config.DIALOG_MARGIN;
			} else {
				nextButton.x = int(componentsWidth * .5 - nextButton.width * .5);
				cancelButton.visible = false;
			}
			
			position += nextButton.height + Config.FINGER_SIZE * .45;
			
			container.graphics.beginFill(0xFFFFFF);
			var startPosition:int = 0;
			
			position -= illustration.height * .5;
			startPosition = int(illustration.height * .5);
			
			container.graphics.drawRect(0, startPosition, _width - Config.DIALOG_MARGIN, position);
			container.graphics.endFill();
			container.y = _height * .5 - container.height * .5;
			container.x = int(Config.DIALOG_MARGIN*.5);
			
			container.graphics.lineStyle(2, 0xD9DED5, 1, false, "normal", CapsStyle.NONE, JointStyle.BEVEL);
			container.graphics.moveTo(0, questionClip.y);
			container.graphics.lineTo(componentsWidth, questionClip.y);
			container.graphics.moveTo(0, questionClip.y + questionClip.height);
			container.graphics.lineTo(componentsWidth, questionClip.y + questionClip.height);
			
			
			accountsPreloader.setSize(selectorDebitAccont.width, int(Config.FINGER_SIZE * .05));
			accountsPreloader.y = selectorDebitAccont.y + selectorDebitAccont.height;
			accountsPreloader.x = selectorDebitAccont.x;
			
			mainPreloader.setSize(componentsWidth, int(Config.FINGER_SIZE * .08));
			mainPreloader.y = startPosition + position;
			
			buttonClose.x = componentsWidth - buttonClose.width - Config.DOUBLE_MARGIN;
			buttonClose.y = startPosition + Config.DOUBLE_MARGIN;
			
			QuestionsManager.S_QUESTION_PROLONG.add(onProlongResult);
		}
		
		private function onProlongResult(success:Boolean, qid:String):void {
			if (isDisposed == true)
				return;
			if (questions != null && questions[currentQuestionIndex] != null && (questions[currentQuestionIndex] as QuestionVO).uid == qid) {
				if (success == true)
					onPaySuccess();
				else
					onPayFail();
			}
		}
		
		private function drawSuccessText():void {
			successText.bitmapData = TextUtils.createTextFieldData(
				Lang.questionProlongSuccess,
				componentsWidth - Config.DIALOG_MARGIN - iconOK.width - Config.DIALOG_MARGIN,
				10,
				true, 
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT, 
				int(Config.FINGER_SIZE * .38),
				true,
				0x596269,
				0xFFFFFF
			);
		}
		
		private function drawQuestion():void {
			if (questions == null || questions.length == 0)
			{
				return;
			}
			
			var renderer:IListRenderer = new ListQuestionRenderer();
			var question:QuestionVO = questions[currentQuestionIndex];
			if (question != null) {
				var item:ListItem = new ListItem("fake", 0, 0, componentsWidth, renderer, question, null, ["avatarURL"]);
				item.draw(componentsWidth);
				if (questionClip.bitmapData != null) {
					questionClip.bitmapData.dispose();
					questionClip.bitmapData = null;
				}
				if (question.avatarURL != null)
					if (ImageManager.getImageFromCache(question.avatarURL) == null)
						ImageManager.loadImage(question.avatarURL, onImageLoaded);
				questionClip.bitmapData = UI.getSnapshot(
					renderer.getView(
						item,
						renderer.getHeight(item, componentsWidth),
						componentsWidth
					) as Sprite,
					StageQuality.HIGH,
					"ExpiredQuestionPopup.questionClip"
				);
				item.dispose();
				renderer.dispose();
			}
		}
		
		private function onImageLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			if (isDisposed == true)
				return;
			if (success && questions != null &&
				currentQuestionIndex < questions.length &&
				questions[currentQuestionIndex] != null &&
				(questions[currentQuestionIndex] as QuestionVO).avatarURL == url)
					drawQuestion();
		}
		
		private function createIllustration():void {
			var clip:Sprite = new JailedIllustrationClip();
			if (clip != null) {
				var size:int = Config.FINGER_SIZE * 2.2;
				UI.scaleToFit(clip, size, size);
				illustration.bitmapData = UI.getSnapshot(clip, StageQuality.HIGH, "BottomPopupScreen.illustration", true);
			}
		}
		
		private function createTitle():void {
			title.bitmapData = TextUtils.createTextFieldData(
				Lang.questionExpired,
				componentsWidth - Config.DIALOG_MARGIN,
				10,
				true, 
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT, 
				int(Config.FINGER_SIZE * .38),
				true,
				0x596269,
				0xFFFFFF
			);
		}
		
		private function createText():void {
			text.bitmapData = TextUtils.createTextFieldData(
				Lang.expiredQuestionDescription,
				componentsWidth - Config.DIALOG_MARGIN,
				10,
				true, 
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT, 
				int(Config.FINGER_SIZE * .26),
				true,
				0x838C98,
				0xFFFFFF
			);
		}
		
		private function createPrice():void {
			price.bitmapData = TextUtils.createTextFieldData(
				Lang.buyQuestionProlong,
				componentsWidth - Config.DIALOG_MARGIN,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				int(Config.FINGER_SIZE * .34),
				true,
				0x616C7B,
				0xFFFFFF
			);
		}
		
		private function createButtons():void {
			var buttonWidth:int = (componentsWidth - Config.DIALOG_MARGIN * 3) * .5;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.prolong, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x77C043, 1, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			nextButton.setBitmapData(buttonBitmap);
			
			var cancelText:String;
			if (questions != null && questions.length > 1)
				cancelText = Lang.textNext;
			else
				cancelText = Lang.textCancel;
			
			var textSettingsCancel:TextFieldSettings = new TextFieldSettings(cancelText, 0x6B7587, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettingsCancel, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, 0x6B7587, buttonWidth);
			cancelButton.setBitmapData(buttonBitmap);
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			selectorDebitAccont.activate();
			if (selectedAccount != null)
				nextButton.activate();
			cancelButton.activate();
			buttonClose.activate();
			checkDataValid();
		}
		
		private function checkDataValid():void {
			if (isActivated && selectedAccount != null)
				nextButton.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			selectorDebitAccont.deactivate();
			cancelButton.deactivate();
			nextButton.deactivate();
			buttonClose.deactivate();
		}
		
		private function onOK():void {
			onCloseTap();
		}
		
		protected function onCloseTap():void {
			if (_isDisposed == true)
				return;
			if (data.callback != null)
				data.callback(0);
			ServiceScreenManager.closeView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			TweenMax.killTweensOf(price);
			TweenMax.killTweensOf(successText);
			TweenMax.killTweensOf(cancelButton);
			TweenMax.killTweensOf(nextButton);
			TweenMax.killTweensOf(iconOK);
			TweenMax.killTweensOf(questionClip);
			TweenMax.killTweensOf(selectorDebitAccont);
			TweenMax.killDelayedCallsTo(onPaySuccess);
			TweenMax.killDelayedCallsTo(processNextQuestion);
			
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			PaymentsManager.S_READY.remove(onDataReady);
			PaymentsManager.deactivate();
			
			QuestionsManager.S_QUESTION_PROLONG.remove(onProlongResult);
			
			if (buttonClose != null)
				buttonClose.dispose();
			buttonClose = null;
			if (selectorDebitAccont != null)
				selectorDebitAccont.dispose();
			selectorDebitAccont = null;
			if (accountsPreloader != null)
				accountsPreloader.dispose();
			accountsPreloader = null;
			if (nextButton != null)
				nextButton.dispose();
			nextButton = null;
			if (mainPreloader != null)
				mainPreloader.dispose();
			mainPreloader = null;
			if (cancelButton != null)
				cancelButton.dispose();
			cancelButton = null;
			UI.destroy(background);
			background = null;
			UI.destroy(illustration);
			illustration = null;
			UI.destroy(questionClip);
			questionClip = null;
			UI.destroy(iconOK);
			iconOK = null;
			UI.destroy(text);
			text = null;
			UI.destroy(title);
			title = null;
			UI.destroy(container);
			container = null;
			UI.destroy(price);
			price = null;
			UI.destroy(successText);
			successText = null;
			
			selectedAccount = null;
			questions = null;
		}
	}
}