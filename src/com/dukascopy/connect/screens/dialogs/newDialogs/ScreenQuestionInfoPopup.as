package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.UserQuestionsStatScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsStatisticsManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.QuestionChatActionType;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.QuestionsStatVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ScreenQuestionInfoPopup extends DialogBaseScreen {
		
		private var avatarSize:Number;
		private var callBack:Function;
		
		private var startChatButton:RoundedButton;
		private var rulesButton:RoundedButton;
		private var tipsButton:RoundedButton;
		private var stopChatButton:RoundedButton;
		private var complainSpamButton:RoundedButton;
		private var complainAbuseButton:RoundedButton;
		private var blockUserButton:RoundedButton;
		private var statButton:BitmapButton;
		private var avatarWithLetter:Sprite;
		private var avatarLettertext:TextField;
		private var avatar:Bitmap;
		private var avatarContainer:Sprite;
		
		private var isUserblockedVar:Boolean;
		private var maxTextWidth:int;
		private var statTextField:TextField;
		
		private var userStatVO:QuestionsStatVO;
		private var secret:Boolean;
		private var statButtonContainer:Sprite;
		
		public function ScreenQuestionInfoPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			avatarSize = Config.FINGER_SIZE * 0.5;
			createAvatarContainer();
			createStatText();
			createStatButton();
			createButtons();
		}
		
		private function createStatButton():void {
			statButton = new BitmapButton();
			statButton.setStandartButtonParams();
			statButton.setDownScale(1);
			statButton.cancelOnVerticalMovement = true;
			statButton.tapCallback = openStatistic;
			statButton.show();
			
			statButtonContainer = new Sprite();
			statButtonContainer.addChild(statButton);
			
			scrollPanel.addObject(statButtonContainer);
		}
		
		private function openStatistic():void {
			MobileGui.changeMainScreen(UserQuestionsStatScreen, { 
				userUID:data.data.uid, 
				backScreen:MobileGui.centerScreen.currentScreenClass, 
				backScreenData:MobileGui.centerScreen.currentScreen.data
			} );
			onCloseTap();
		}
		
		private function createStatText():void {
			statTextField = new TextField();
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = AppTheme.GREEN_LIGHT;
			textFormat.leading = int(Config.FINGER_SIZE * .04);
			textFormat.size = Config.FINGER_SIZE * .28;
			textFormat.align = TextFormatAlign.LEFT;
			statTextField.defaultTextFormat = textFormat;
			statTextField.selectable = false;
			statTextField.multiline = true;
			statTextField.wordWrap = true;
			statTextField.cacheAsBitmap = true;
			scrollPanel.addObject(statTextField);
		}
		
		private function createAvatarContainer():void {
			avatarContainer = new Sprite();
			avatarContainer.x = hPadding;
			scrollPanel.addObject(avatarContainer);
		}
		
		private function createImageAvatar():void {
			avatar = new Bitmap();
			avatarContainer.addChild(avatar);
		}
		
		private function createLetterAvatar():void {
			avatarWithLetter = new Sprite();
			avatarLettertext = new TextField();
			avatarWithLetter.addChild(avatarLettertext);
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = Config.FINGER_SIZE * .5;
			textFormat.align = TextFormatAlign.CENTER;
			avatarLettertext.defaultTextFormat = textFormat;
			avatarLettertext.selectable = false;
			avatarLettertext.width = avatarSize * 2;
			avatarLettertext.multiline = false;
			avatarLettertext.text = "A";
			avatarLettertext.height = avatarLettertext.textHeight + 4;
			avatarLettertext.y = int(avatarSize - (avatarLettertext.textHeight + 4) * .5);
			avatarLettertext.text = "";
			avatarWithLetter.graphics.beginFill(AppTheme.GREY_MEDIUM);
			avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
			avatarWithLetter.graphics.endFill();
			
			avatarContainer.addChild(avatarWithLetter);
		}
		
		private function createButtons():void {
			blockUserButton = createButton(Lang.blockUser, MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, blockUser);
			complainAbuseButton = createButton(Lang.complainAbuse, MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, complainAbuse);
			complainSpamButton = createButton(Lang.spamButtontext, MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, complainSpam);
			stopChatButton = createButton(Lang.stopChat, MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, stopChat);
			startChatButton = createButton(Lang.startPrivateChat, 0x267FC3, 0x1D6296, startChat);
			rulesButton = createButton(Lang.textRules, MainColors.GREEN_MEDIUM, MainColors.GREEN_DARK, showInfo);
			tipsButton = createButton(Lang.textTips, MainColors.GREEN_MEDIUM, MainColors.GREEN_DARK, showTips);
		}
		
		private function createButton(text:String, topColor:Number, bottomColor:Number, tapCallback:Function):RoundedButton {
			var button:RoundedButton = new RoundedButton(text, topColor, bottomColor, null);;
			button.setStandartButtonParams();
			button.setDownScale(1);
			button.cancelOnVerticalMovement = true;
			button.tapCallback = tapCallback;
			button.hide();
			button.draw();
			scrollPanel.addObject(button);
			return button;
		}
		
		private function resizeButtons():void {
			var smallButtonWidth:int = Math.max(rulesButton.width, tipsButton.width);
			var bigButtonWidth:int = Math.max(
				smallButtonWidth * 2 + Config.MARGIN, 
				blockUserButton.width,
				complainAbuseButton.width,
				complainSpamButton.width,
				stopChatButton.width,
				startChatButton.width
			);
			
			bigButtonWidth = Math.min(bigButtonWidth, _width - hPadding * 2);
			
			if ((bigButtonWidth - Config.MARGIN) * .5 > smallButtonWidth)
				smallButtonWidth = (bigButtonWidth - Config.MARGIN) / 2;
			
			setButtonWidth(rulesButton, smallButtonWidth);
			setButtonWidth(tipsButton, smallButtonWidth);
			setButtonWidth(blockUserButton, bigButtonWidth);
			setButtonWidth(complainAbuseButton, bigButtonWidth);
			setButtonWidth(complainSpamButton, bigButtonWidth);
			setButtonWidth(stopChatButton, bigButtonWidth);
			setButtonWidth(startChatButton, bigButtonWidth);
		}
		
		private function setButtonWidth(button:RoundedButton, widthValue:int):void {
			if (button.width != widthValue) {
				button.setSizeLimits(widthValue, widthValue);
				button.draw();
			}
		}
		
		protected function blockUser():void {
			if (isUserblockedVar)
			{
				fireCallbackFunctionWithValue(QuestionChatActionType.UNBLOCK);
			}
			else {
				fireCallbackFunctionWithValue(QuestionChatActionType.BLOCK);
			}
			
			onCloseTap();
		}
		
		protected function complainAbuse():void {
			fireCallbackFunctionWithValue(QuestionChatActionType.ABUSE);
			onCloseTap();
		}
		
		protected function complainSpam():void {
			fireCallbackFunctionWithValue(QuestionChatActionType.SPAM);
			onCloseTap();
		}
		
		protected function stopChat():void {
			fireCallbackFunctionWithValue(QuestionChatActionType.STOP);
			onCloseTap();
		}
		
		protected function startChat():void {
			fireCallbackFunctionWithValue(QuestionChatActionType.START_CHAT);
			onCloseTap();
		}
		
		protected function showInfo():void {
			fireCallbackFunctionWithValue(QuestionChatActionType.MORE_INFO);
			onCloseTap();
		}
		
		protected function showTips():void {
			fireCallbackFunctionWithValue(QuestionChatActionType.TIPS);
			onCloseTap();
		}
		
		protected function fireCallbackFunctionWithValue(value:int):void {
			if (callBack != null) {
				var callBackFunction:Function = callBack;
				callBack = null;
				callBackFunction(value);
			}
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			resizeButtons();
			
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().users != null)
			{
				var user:ChatUserVO = ChatManager.getCurrentChat().getUser(data.data.uid);
				if (user != null && user.secretMode == true)
				{
					secret = true;
				}
			}
			
			isUserblockedVar = isUserBlocked();
			blockUserButton.setValue(isUserblockedVar ? Lang.unblockButtontext : Lang.blockUser);
			
			if ("callBack" in data)
				callBack = data.callBack;
			
			updateElementsXPosition();
			updateAvatar();
			updateStatButton();
			
			QuestionsStatisticsManager.S_USER_STAT.add(onUserStat);
			userStatVO = QuestionsStatisticsManager.getUserStat(data.data.uid);
			
			updateTexts();
			
			if (secret == true)
			{
				scrollPanel.removeObject(startChatButton);
			}
			else {
				scrollPanel.addObject(startChatButton);
			}
			startChatButton.visible = !secret;
			
			updateElementsYPosition();
		}
		
		private function updateStatButton():void {
			statButton.setBitmapData(
				TextUtils.createTextFieldData(
					"<u>" + Lang.textShowStatistic + "</u>",
					componentsWidth,
					10,
					true,
					TextFormatAlign.LEFT,
					TextFieldAutoSize.LEFT,
					Config.FINGER_SIZE * .3,
					true,
					0x0000FF,
					0xFFFFFF,
					true,
					true
				),
				true
			);
			statButton.setOverflow(Config.FINGER_SIZE);
			statButtonContainer.x = statTextField.x + 2;
		}
		
		private function updateAvatar():void {
			var avatarURL:String = data.data.getAvatarURL();
			
			if (secret)
			{
				avatarURL = LocalAvatars.SECRET;
			}
			
			if (avatarURL == null) {
				showLetterAvatar();
			} else {
				var path:String = getAvatarPath(avatarURL);
				var image:ImageBitmapData = ImageManager.getImageFromCache(path);
				if (image)
					drawAvatar(image);
				else
					ImageManager.loadImage(path, onAvatarLoaded);
			}
		}
		
		private function getAvatarPath(origPath:String):String {
			if (!origPath)
				return null;
			if (origPath && origPath.indexOf("no_photo") != -1)
				return null;
			else if (origPath && origPath.indexOf("vk.me") != -1)
				return origPath;
			var userCode:Array = origPath.split("/");
			if (origPath.indexOf("graph.facebook.com") != -1) {
				if (userCode.length > 4)
					return "http://graph.facebook.com/" + userCode[3] + "/" + userCode[4];
			} else {
				if (userCode.length > 4 && origPath.indexOf("wb-dev.telefision") == -1)
					return Config.URL_IMAGE + userCode[5] + "/" + (avatarSize*2) + "_3/image.jpg";
			}
			return origPath;
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			if (isDisposed)
				return;	
			if (!success) {
				showLetterAvatar();
				return;
			}
			drawAvatar(bmd);
			scrollPanel.update();
		}
		
		private function drawAvatar(bmd:ImageBitmapData):void {
			if (avatar == null)
				createImageAvatar();
			if (avatarWithLetter != null)
				avatarWithLetter.visible = false;
			
			var avatarBitmap:ImageBitmapData = new ImageBitmapData("QuestionAvatar", avatarSize * 2, avatarSize * 2);
			ImageManager.drawCircleImageToBitmap(avatarBitmap, bmd, 0, 0, int(avatarSize));
			
			if (avatar.bitmapData)
				avatar.bitmapData.dispose();
			avatar.bitmapData = null;
			
			avatar.bitmapData = avatarBitmap;
		}
		
		private function showLetterAvatar():void {
			if (avatarWithLetter == null)
				createLetterAvatar();
			
			if (avatar != null)
				avatar.visible = false;
			
			avatarWithLetter.y = avatarContainer.y;
			avatarWithLetter.x = 0;
			
			if (TextUtils.isAvatarLetterSupported(data.data.getDisplayName().charAt(0))) {
				avatarLettertext.text = data.data.getDisplayName().charAt(0).toUpperCase();
				avatarWithLetter.graphics.clear();
				avatarWithLetter.graphics.beginFill(AppTheme.getColorFromPallete(data.data.getDisplayName()));
				avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
				avatarWithLetter.graphics.endFill();
			}
		}
		
		private function updateElementsYPosition():void {
			var position:int = statTextField.height + Config.MARGIN;
			
			statButton.visible = !secret;
			
			statButtonContainer.y = position;
			
			position += statButton.height + Config.DOUBLE_MARGIN;
			
			blockUserButton.y = position;
			position += blockUserButton.height + Config.MARGIN;
			
			complainAbuseButton.y = position;
			position += complainAbuseButton.height + Config.MARGIN;
			
			complainSpamButton.y = position;
			position += complainSpamButton.height + Config.MARGIN;
			
			stopChatButton.y = position;
			position += stopChatButton.height + Config.MARGIN;
			
			if (secret == false)
			{
				startChatButton.y = position;
				position += startChatButton.height + Config.MARGIN;
			}
			
			rulesButton.y = position;
			tipsButton.y = position;
			position += tipsButton.height + Config.MARGIN;
			
			drawView();
		}
		
		private function updateElementsXPosition():void {
			statTextField.x = avatarContainer.x + avatarSize * 2 + hPadding;
			
			var bigButtonWidth:int = blockUserButton.width;
			var smallButttonWidth:int = (bigButtonWidth - Config.MARGIN) / 2;
			var buttonsX:int = _width / 2 - bigButtonWidth / 2;
			
			blockUserButton.x = buttonsX;
			complainAbuseButton.x = buttonsX;
			complainSpamButton.x = buttonsX;
			stopChatButton.x = buttonsX;
			startChatButton.x = buttonsX;
			rulesButton.x = buttonsX;
			tipsButton.x = buttonsX + smallButttonWidth + Config.MARGIN;
		}
		
		private function updateTexts():void {
			
			var userName:String = data.data.getDisplayName().toUpperCase();
			if (secret == true)
			{
				userName = Lang.textIncognito;
			}
			
			maxTextWidth = componentsWidth - avatarContainer.x - avatarSize * 2 - hPadding;
			
			var textValue:String = "";
			
			textValue = "<font font='" + Config.defaultFontName + "'color='#" + AppTheme.GREY_DARK.toString(16) + "' size='" + int(Config.FINGER_SIZE*.28) + "'>" + userName + "</font>" + "<br>";
			
			if (secret == false)
			{
				var defaultTextStyle:String = "font='" + Config.defaultFontName + "'color='#" + AppTheme.GREY_MEDIUM.toString(16) + "' size='" + int(Config.FINGER_SIZE * .26) + "'";
				if (userStatVO != null && userStatVO.hash != null) {
					var date:Date = new Date();
					date.setTime(userStatVO.since * 1000);
					textValue += "<font " + defaultTextStyle + ">" + Lang.textSince.toUpperCase() + ": " + DateUtils.getComfortDateRepresentation(date) + "</font>" + "<br>";
				}
			}
			statTextField.htmlText = textValue;
			statTextField.width = maxTextWidth;
			statTextField.height = statTextField.textHeight + 4;
		}
		
		private function onUserStat(uid:String):void {
			if (isDisposed)
				return;
			if (!data || !data.data)
				return;
			updateTexts();
			updateElementsYPosition();
		}
		
		private function onUserBlockStatusChanged(data:Object):void {
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			if (_isDisposed)
				return;
			//!TODO: need to know if button not already activated, better to implement in button component;
			blockUserButton.activate();
			
			if (data.status == UserBlockStatusType.UNBLOCK) {
				isUserblockedVar = false;
				blockUserButton.setValue(Lang.blockUser);
			}
		}
		
		private function isUserBlocked():Boolean {
			var blockedUsers:Array = Auth.blocked;
			var l:int = blockedUsers.length;
			for (var i:int = 0; i < l; i++)
				if (blockedUsers[i] == data.data.uid)
					return true;
			return false;
		}
		
		override protected function drawView():void {
			super.drawView();
			scrollPanel.update();
		}
		
		private function showUserProfile(e:Event):void {
			if (secret)
			{
				return;
			}
			fireCallbackFunctionWithValue(QuestionChatActionType.SHOW_USER_INFO);
			onCloseTap();
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			
			if (blockUserButton.getIsShown() == false)
				blockUserButton.show(.3, .15, true, 0.9, 0);
			if (complainAbuseButton.getIsShown() == false)
				complainAbuseButton.show(.3, .20, true, 0.9, 0);
			if (complainSpamButton.getIsShown() == false)
				complainSpamButton.show(.3, .25, true, 0.9, 0);
			if (stopChatButton.getIsShown() == false)
				stopChatButton.show(.3, .30, true, 0.9, 0);
			if (startChatButton.getIsShown() == false)
				startChatButton.show(.3, .35, true, 0.9, 0);
			if (rulesButton.getIsShown() == false)
				rulesButton.show(.3, .40, true, 0.9, 0);
			if (tipsButton.getIsShown() == false)
				tipsButton.show(.3, .45, true, 0.9, 0);
			
			startChatButton.activate();
			rulesButton.activate();
			tipsButton.activate();
			stopChatButton.activate();
			complainSpamButton.activate();
			complainAbuseButton.activate();
			blockUserButton.activate();
			statButton.activate();
			
			PointerManager.addTap(avatarContainer, showUserProfile);
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			
			startChatButton.deactivate();
			rulesButton.deactivate();
			tipsButton.deactivate();
			stopChatButton.deactivate();
			complainSpamButton.deactivate();
			complainAbuseButton.deactivate();
			blockUserButton.deactivate();
			statButton.deactivate();
			
			PointerManager.removeTap(avatarContainer, showUserProfile);
		}
		
		override public function dispose():void {
			super.dispose();
			
			callBack = null;
			
			if (statButtonContainer != null)
			{
				UI.destroy(statButtonContainer);
				statButtonContainer = null;
			}
			
			if (startChatButton != null)
				startChatButton.dispose();
			startChatButton = null;
			if (rulesButton != null)
				rulesButton.dispose();
			rulesButton = null;
			if (tipsButton != null)
				tipsButton.dispose();
			tipsButton = null;
			if (stopChatButton != null)
				stopChatButton.dispose();
			stopChatButton = null;
			if (complainSpamButton != null)
				complainSpamButton.dispose();
			complainSpamButton = null;
			if (complainAbuseButton != null)
				complainAbuseButton.dispose();
			complainAbuseButton = null;
			if (blockUserButton != null)
				blockUserButton.dispose();
			blockUserButton = null;
			if (statButton != null)
				statButton.dispose();
			statButton = null;
			if (avatar != null)
				UI.destroy(avatar);
			avatar = null;
			if (avatarWithLetter != null)
				UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
			if (avatarLettertext != null)
				UI.destroy(avatarLettertext);
			avatarLettertext = null;
			if (avatarContainer != null)
				UI.destroy(avatarContainer);
			avatarContainer = null;
			if (statTextField != null)
				UI.destroy(statTextField);
			statTextField = null;
			
			Overlay.removeCurrent();
		}
	}
}