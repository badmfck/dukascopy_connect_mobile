package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.videoChat.VideoChat;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.contactsManager.UserProfileManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.QuestionChatActionType;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.UserProfileVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class QuestionInfoDialog extends ScreenAlertDialog
	{
		private var avatarSize:int;
		private var avatarWithLetter:Sprite;
		private var avatar:Bitmap;
		private var onlineMark:Sprite;
		private var avatarLettertext:TextField;
		private var userNameField:Bitmap;
		private var answers:Bitmap;
		private var since:Bitmap;
		private var questions:Bitmap;
		private var abuse:Bitmap;
		private var spam:Bitmap;
		private var infoButton:RoundedButton;
		private var infoButton2:RoundedButton;
		private var isUserblockedVar:Boolean;
		private var avatarContainer:Sprite;
		private var startChatButton:RoundedButton;
		
		public function QuestionInfoDialog()
		{
			super();
		}
		
		override protected function createView():void
		{
			super.createView();
			
			avatarSize = Config.FINGER_SIZE * 0.5;
			
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
			avatarWithLetter.visible = false;
			
			userNameField = new Bitmap();
			
			answers = new Bitmap();
			since = new Bitmap();
			questions = new Bitmap();
			abuse = new Bitmap();
			spam = new Bitmap();
			
			avatar = new Bitmap();
			avatarContainer = new Sprite();
			avatarContainer.addChild(avatar);
			
			onlineMark = new Sprite();
				onlineMark.graphics.beginFill(MainColors.WHITE);
				onlineMark.graphics.drawCircle(avatarSize / 4.2, avatarSize / 4.2, avatarSize / 4.2);
				onlineMark.graphics.endFill();
				onlineMark.graphics.beginFill(MainColors.GREEN_LIGHT);
				onlineMark.graphics.drawCircle(avatarSize/4.2, avatarSize/4.2, avatarSize/5.9);
				onlineMark.graphics.endFill();
				onlineMark.x = int(avatarContainer.x  + avatarSize * Math.cos(32*Math.PI/180) + avatarSize - onlineMark.width/2);
				onlineMark.visible = false;
			//addChild(onlineMark);
			
			infoButton = new RoundedButton(Lang.textRules, MainColors.GREEN_MEDIUM, MainColors.GREEN_DARK, null);
			infoButton.setStandartButtonParams();
			infoButton.setDownScale(1);
			infoButton.tapCallback = btn4Clicked;
			infoButton.disposeBitmapOnDestroy = true;
			infoButton.hide();			
			_view.addChild(infoButton);
			infoButton.setOverflow(padding, padding, padding, padding);
			
			infoButton2 = new RoundedButton(Lang.textTips, MainColors.GREEN_MEDIUM, MainColors.GREEN_DARK, null);
			infoButton2.setStandartButtonParams();
			infoButton2.setDownScale(1);
			infoButton2.tapCallback = btn5Clicked;
			infoButton2.disposeBitmapOnDestroy = true;
			infoButton2.hide();
			infoButton2.setOverflow();
			_view.addChild(infoButton2);
			infoButton2.setOverflow(padding, padding, padding, padding);
			
			startChatButton = new RoundedButton(Lang.startPrivateChat, 0x267FC3, 0x1D6296, null);
			startChatButton.setStandartButtonParams();
			startChatButton.setDownScale(1);
			startChatButton.tapCallback = btn6Clicked;
			startChatButton.disposeBitmapOnDestroy = true;
			startChatButton.hide();
			startChatButton.setOverflow();
			_view.addChild(startChatButton);
			startChatButton.setOverflow(padding, padding, padding, padding);
		}
		
		override protected function createFirstButton():void {
			var okButtonText:String = Lang.textOk;
			if (data.buttonOk)
				okButtonText = data.buttonOk.toUpperCase();
			button0  = new RoundedButton(okButtonText, MainColors.BLUE_LIGHT, MainColors.BLUE_MEDIUM, null);
			button0.setStandartButtonParams();
			button0.setDownScale(1);
			button0.cancelOnVerticalMovement = true;
			button0.tapCallback = btn0Clicked;
			_view.addChild(button0);
			buttons.push(button0);
		}
		
		override protected function btn0Clicked():void 
		{
			if (callback != null)
			{
				fireCallbackFunctionWithValue(QuestionChatActionType.STOP);
			}
			DialogManager.closeDialog();
		}
		
		override protected function btn1Clicked():void 
		{
			if (callback != null)
			{
				fireCallbackFunctionWithValue(QuestionChatActionType.SPAM);
			}
			DialogManager.closeDialog();
		}
		
		override protected function btn2Clicked():void 
		{
			if (callback != null)
			{
				fireCallbackFunctionWithValue(QuestionChatActionType.ABUSE);
			}
			DialogManager.closeDialog();
		}
		
		override protected function btn3Clicked():void 
		{
			if (isUserblockedVar)
			{
				button4.deactivate();
				UsersManager.USER_BLOCK_CHANGED.add(onUserBlockStatusChanged);
				UsersManager.changeUserBlock(data.data.uid, UserBlockStatusType.UNBLOCK);
			}
			else
			{
				if (callback != null)
				{
					fireCallbackFunctionWithValue(QuestionChatActionType.BLOCK);
				}
				DialogManager.closeDialog();
			}
		}
		
		protected function btn4Clicked():void 
		{
			if (callback != null)
			{
				fireCallbackFunctionWithValue(QuestionChatActionType.MORE_INFO);
			}
			DialogManager.closeDialog();
		}
		
		protected function btn5Clicked():void 
		{
			if (callback != null)
			{
				fireCallbackFunctionWithValue(QuestionChatActionType.TIPS);
			}
			DialogManager.closeDialog();
		}
		
		protected function btn6Clicked():void 
		{
			if (callback != null)
			{
				fireCallbackFunctionWithValue(QuestionChatActionType.START_CHAT);
			}
			DialogManager.closeDialog();
		}
		
		override protected function drawView():void {
			buttonsPadding = Config.MARGIN;
			super.drawView();
			var totalButtonsWidth:Number = infoButton.width + infoButton2.width + padding;
			
			startChatButton.x = button0.x;
			startChatButton.y = button0.y + button0.height + buttonsPadding;
			
			startChatButton.setSizeLimits(button0.width, button0.width);
			startChatButton.draw();
			startChatButton.show();
			
			infoButton.x = button0.x;
			infoButton.y = startChatButton.y + startChatButton.height + buttonsPadding;	
			infoButton2.x = button0.x + button0.width * 0.5 + buttonsPadding*.5;
			infoButton2.y = startChatButton.y + startChatButton.height + buttonsPadding;
			
			infoButton.setSizeLimits(button0.width * 0.5 - buttonsPadding*.5, button0.width * 0.5 - buttonsPadding*.5);
			infoButton2.setSizeLimits(button0.width * 0.5 - buttonsPadding*.5, button0.width * 0.5 - buttonsPadding*.5);
			
			infoButton.draw();
			infoButton2.draw();
			
			infoButton.show();
			infoButton2.show();
			
		}
		
		private function isUserBlocked():Boolean 
		{
			var blockedUsers:Array = Auth.blocked;
			var l:int = blockedUsers.length;
			for (var i:int = 0; i < l; i++){
				if (blockedUsers[i] == data.data.uid){
					return true;
				}
			}
			return false;
		}
		
		private function onUserBlockStatusChanged(data:Object):void
		{
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			if (_isDisposed)
			{
				return;
			}
			//!TODO: need to know if button not already activated, better to implement in button component;
			button4.activate();
			
			if (data.status == UserBlockStatusType.UNBLOCK)
			{
				isUserblockedVar = false;
				(button4 as RoundedButton).setValue(Lang.blockUser.toUpperCase());
			}
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			data.buttonOk = Lang.stopChat;
			data.buttonSecond = Lang.spamButtontext;
			data.buttonThird = Lang.complainAbuse;
			
			isUserblockedVar = isUserBlocked();
			var blockButtontext:String = isUserblockedVar?Lang.unblockButtontext:Lang.blockUser;
			
			data.buttonFourth = blockButtontext;
			super.initScreen(data);
			
			QuestionsManager.S_USER_STAT.add(onUserStat);
			QuestionsManager.getUserStat(data.data.uid);
		}
		
		private function onUserStat(stat:Object):void {
			if (isDisposed)
				return;
			if (!data || !data.data)
				return;
				
			//	*0)questionabuse*1)questionspam*2)chatabuse*3)chatspam*4)questions*5)reports
				
			if ("selfQuestion" in data.data) {
				data.data.spam = stat[3] + stat[1];
				data.data.abuse = stat[2] + stat[0];
				data.data.questionsNum = stat[4];
				data.data.answersNum = stat[5];
			} else {
				data.data.spam = stat[3] + stat[1];
				data.data.abuse = stat[2] + stat[0];
				data.data.questionsNum = stat[4];
				data.data.answersNum = stat[5];
			}
			if ("created" in stat && stat.created != undefined)
				data.data.created = stat.created;
			if ("avatar" in stat)
				data.data.avatar = stat.avatar;
			createTexts(avatarContainer.y);
		}
		
		override protected function updateScrollArea():void {
			if (!content.fitInScrollArea())
				content.enable();
			else
				content.disable();
			content.update();
		}
		
		override protected function recreateContent(padding:Number):void {
			super.recreateContent(padding);
			
			var position:int = 0;
			if (content.itemsHeight > 0) {
				position = content.itemsHeight + padding;
			}
			
			avatarContainer.x = avatarWithLetter.x;
			avatarContainer.y = position;
			
			avatar.visible = false;
			avatarWithLetter.visible = false;
			
			
			if (data.data.avatar == null)
			{
				showLetterAvatar();
			}
			else
			{
				var path:String = getAvatarPath(data.data.avatar);
				
				var image:ImageBitmapData = ImageManager.getImageFromCache(path);
				if (image)
				{
					drawAvatar(image);
				}
				else
				{
					ImageManager.loadImage(path, onAvatarLoaded);
				}
			}
			
			createTexts(position);
		}
		
		private function createTexts(position:int):void {
			createAuthor(position);
			position += userNameField.height + Config.DOUBLE_MARGIN;
			
			createSince(position);
			position += Config.FINGER_SIZE*.3 + Config.MARGIN*.6;
			
			createAnswers(position);
			position += Config.FINGER_SIZE*.3 + Config.MARGIN*.6;
			
			createQuestions(position);
			position += Config.FINGER_SIZE*.3 + Config.MARGIN*.6;
			
			createAbuse(position);
			position += Config.FINGER_SIZE*.3 + Config.MARGIN*.6;
			
			//createSpam(position);
			//position += Config.FINGER_SIZE*.5 + Config.MARGIN*.6;
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
		
		private function createSpam(position:int):void {
			if (spam.bitmapData)
				spam.bitmapData.dispose();
			spam.bitmapData = null;
			spam.bitmapData = TextUtils.createTextFieldData(Lang.questionAuthorSpamNum + ": " + data.data.spam.toString(),
															_width - avatarContainer.x - avatarSize*2 - Config.DOUBLE_MARGIN, 
															10, true, 
															TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .26, 
															true, 
															AppTheme.GREY_MEDIUM, 
															MainColors.WHITE, false, false, false);
			content.addObject(spam);
			spam.x = avatarContainer.x + avatarSize*2 + Config.DOUBLE_MARGIN;
			spam.y = position;
		}
		
		private function createAbuse(position:int):void {
			if (abuse.bitmapData)
				abuse.bitmapData.dispose();
			abuse.bitmapData = null;
			abuse.bitmapData = TextUtils.createTextFieldData(Lang.questionAuthorAbuseNum + ": " + data.data.abuse.toString() + ", " + Lang.questionAuthorSpamNum + ": " + data.data.spam.toString(),
															_width - avatarContainer.x - avatarSize*2 - Config.DOUBLE_MARGIN, 
															10, true, 
															TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .26, 
															true, 
															AppTheme.GREY_MEDIUM, 
															MainColors.WHITE, false, false, false);
			content.addObject(abuse);
			
			abuse.x = avatarContainer.x + avatarSize*2 + Config.DOUBLE_MARGIN;
			abuse.y = position;
		}
		
		private function createQuestions(position:int):void {
			if (questions.bitmapData)
				questions.bitmapData.dispose();
			questions.bitmapData = null;
			questions.bitmapData = TextUtils.createTextFieldData(
																Lang.textQuestions + ": " + data.data.questionsNum.toString(),
																_width - avatarContainer.x - avatarSize*2 - Config.DOUBLE_MARGIN, 
																10, true, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .26, 
																true, 
																AppTheme.GREY_MEDIUM, 
																MainColors.WHITE, false, false, false);
			content.addObject(questions);
			
			questions.x = avatarContainer.x + avatarSize*2 + Config.DOUBLE_MARGIN;
			questions.y = position;
		}
		
		private function createSince(position:int):void {
			if (since.bitmapData)
				since.bitmapData.dispose();
			since.bitmapData = null;
			var date:Date = new Date();
			date.setTime(data.data.created*1000);
			since.bitmapData = TextUtils.createTextFieldData(
																Lang.textSince.toUpperCase() + ": " + DateUtils.getComfortDateRepresentation(date),
																_width - avatarContainer.x - avatarSize*2 - Config.DOUBLE_MARGIN, 
																10, true, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .26, 
																true, 
																AppTheme.GREY_MEDIUM, 
																MainColors.WHITE, false, false, false);
			content.addObject(since);
			
			since.x = avatarContainer.x + avatarSize*2 + Config.DOUBLE_MARGIN;
			since.y = position;
		}
		
		private function createAnswers(position:int):void {
			if (answers.bitmapData)
				answers.bitmapData.dispose();
			answers.bitmapData = null;
			answers.bitmapData = TextUtils.createTextFieldData(
																Lang.textAnswers + ": " + data.data.answersNum.toString(),
																_width - avatarContainer.x - avatarSize*2 - Config.DOUBLE_MARGIN, 
																10, true, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .26, 
																true, 
																AppTheme.GREY_MEDIUM, 
																MainColors.WHITE, false, false, false);
			content.addObject(answers);
			
			answers.x = avatarContainer.x + avatarSize*2 + Config.DOUBLE_MARGIN;
			answers.y = position;
		}
		
		private function createAuthor(position:int):void {
			if (userNameField.bitmapData)
				userNameField.bitmapData.dispose();
			userNameField.bitmapData = null;
			userNameField.bitmapData = TextUtils.createTextFieldData(
																	data.data.name.toUpperCase(), 
																	_width - avatarContainer.x - avatarSize*2 - Config.DOUBLE_MARGIN, 
																	10, true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	true, 
																	AppTheme.GREY_DARK, 
																	MainColors.WHITE, false, false, false);
			content.addObject(userNameField);
			
			userNameField.x = avatarContainer.x + avatarSize*2 + Config.DOUBLE_MARGIN;
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			if (isDisposed)
				return;	
			if (!success) {
				showLetterAvatar();
				return;
			}
			
			drawAvatar(bmd);
		}
		
		private function showLetterAvatar():void 
		{
			avatarWithLetter.visible = false;
			avatar.visible = true;
			
			avatarWithLetter.y = avatarContainer.y;
			avatarWithLetter.x = 0;
			content.addObject(avatarWithLetter);
			if (AppTheme.isLetterSupported(data.data.name.charAt(0)))
			{
				avatarLettertext.text = data.data.name.charAt(0).toUpperCase();
				avatarWithLetter.graphics.clear();
				avatarWithLetter.graphics.beginFill(AppTheme.getColorFromPallete(data.data.name));
				avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
				avatarWithLetter.graphics.endFill();
			}
		}
		
		private function drawAvatar(bmd:ImageBitmapData):void 
		{
			avatarWithLetter.visible = false;
			avatar.visible = true;
			
			var avatarBitmap:ImageBitmapData = new ImageBitmapData("QuestionAvatar", avatarSize * 2, avatarSize * 2);
			ImageManager.drawCircleImageToBitmap(avatarBitmap, bmd, 0, 0, int(avatarSize));
			
			if (avatar.bitmapData)
			{
				avatar.bitmapData.dispose();
				avatar.bitmapData = null;
			}
			
			content.addObject(avatarContainer);
			avatar.bitmapData = avatarBitmap;
		}
		
		override protected function updateContentHeight():void {
			var defaultButtonHeight:int = Config.MARGIN * 5;
			contentHeight = (padding + headerHeight + buttonsAreaHeight + content.itemsHeight) + defaultButtonHeight*2 + buttonsPadding*2 + Config.MARGIN;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (infoButton)
				infoButton.activate();
			if (startChatButton)
				startChatButton.activate();
			if (infoButton2)
				infoButton2.activate();
			if (avatar)
			{
				PointerManager.addTap(avatarContainer, showUserProfile);
			}
			if (avatarWithLetter)
			{
				PointerManager.addTap(avatarWithLetter, showUserProfile);
			}
		}
		
		private function showUserProfile(e:Event):void 
		{
			fireCallbackFunctionWithValue(QuestionChatActionType.SHOW_USER_INFO);
			DialogManager.closeDialog();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (infoButton)
				infoButton.deactivate();
			if (startChatButton)
				startChatButton.deactivate();
			if (infoButton2)
				infoButton2.deactivate();
			if (avatar)
			{
				PointerManager.removeTap(avatarContainer, showUserProfile);
			}
			if (avatarWithLetter)
			{
				PointerManager.removeTap(avatarWithLetter, showUserProfile);
			}
		}
		
		override public function dispose():void {
			if (infoButton)
				infoButton.dispose();
			infoButton = null;
			
			if (infoButton2)
				infoButton2.dispose();
			infoButton2 = null;
			
			if (startChatButton)
				startChatButton.dispose();
			startChatButton = null;
			
			if (avatar)
				UI.destroy(avatar);
			avatar = null;
			
			if (userNameField)
				UI.destroy(userNameField);
			userNameField = null;
			
			if (answers)
				UI.destroy(answers);
			answers = null;
			
			if (since)
				UI.destroy(since);
			since = null;
			
			if (avatarContainer)
				UI.destroy(avatarContainer);
			avatarContainer = null;
			
			if (questions)
				UI.destroy(questions);
			questions = null;
			
			if (spam)
				UI.destroy(spam);
			spam = null;
			
			if (abuse)
				UI.destroy(abuse);
			abuse = null;
			
			if (onlineMark)
				UI.destroy(onlineMark);
			onlineMark = null;
			
			if (avatarWithLetter)
				UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
			
			if (avatarLettertext)
			{
				avatarLettertext.text = "";
			}
			avatarLettertext = null;
			
			QuestionsManager.S_USER_STAT.remove(onUserStat);
			super.dispose();
		}
	}
}