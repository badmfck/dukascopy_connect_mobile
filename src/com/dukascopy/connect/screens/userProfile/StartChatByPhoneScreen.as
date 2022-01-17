package com.dukascopy.connect.screens.userProfile {
	
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPhonebook;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.contactsManager.ContactsManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class StartChatByPhoneScreen extends BaseScreen {
		static public const STATE_START:String = "start";
		static public const STATE_ERROR:String = "stateError";
		static public const STATE_NOT_FOUND:String = "notFound";
		static public const STATE_SEARCH:String = "stateSearch";
		static public const STATE_USER_FOUND:String = "stateUserFound";
		static public const STATE_USER_FOUND_IN_CONTACTS:String = "stateUserFoundInContacts";
		
		private var currentState:String;
		
		private var max_text_width:int;
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
		private var phoneField:InputField;
		private var buttonPaddingLeft:int;
		private var currentPhone:String;
		private var currentSurname:String;
		private var preloader:CirclePreloader;
		private var numberBack:Sprite;
		private var searchButton:BitmapButton;
		private var resultMessage:Bitmap;
		private var user:UserSearchResult;
		private var startChatButton:BitmapButton;
		private var inviteButton:BitmapButton;
		private var animationDistance:Number;
		private var currentSearchResult:ContactVO;
		private var userInContacts:Boolean;
		private var hasName:Boolean;
		private var currentSearchResultLocal:ContactVO;
		private var padding:int;
		private var phoneButton:BitmapButton;
		private var description:Bitmap;
		
		public function StartChatByPhoneScreen() {	}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = "New chat with phone number";
			_params.doDisposeAfterClose = true;
			
			padding = Config.DOUBLE_MARGIN;
			drawSearchButton();
			drawStartChatButton();
			drawDescription();
			drawInviteButton();
			
			animationDistance = Config.MARGIN;
			topBar.setData(Lang.startChatByPhoneNumber, true);
			scrollPanel.view.y = topBar.trueHeight;
			
			if (PhonebookManager.isHasPermissionToContacts)
			{
				createPhonebookButton();
			}
			
			updatePositions();
			
			if (data && data.state) {
				var stateToShow:String = STATE_START;
				
				if (data.state == STATE_USER_FOUND) {
					if (("model" in data) && data.model && (data.model is ContactVO)) {
						stateToShow = STATE_USER_FOUND;
						currentSearchResult = data.model as ContactVO;
						phoneField.valueString = currentSearchResult.getPhone().toString();
					}
				}
				else if (data.state == STATE_USER_FOUND_IN_CONTACTS) {
					if (("model" in data) && data.model && (data.model is UserVO)) {
						stateToShow = STATE_USER_FOUND_IN_CONTACTS;
						currentSearchResultLocal = data.model as ContactVO;
						phoneField.valueString = currentSearchResultLocal.getPhone().toString();
					}
				}
				
				setState(stateToShow, false);
			}
			else {
				setState(STATE_START);
			}
			
			view.graphics.clear();
			view.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			view.graphics.drawRect(0, 0, _width, _height);
			view.graphics.endFill();
		}
		
		private function drawDescription():void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			description.bitmapData = TextUtils.createTextFieldData(Lang.search_user_description, _width - padding * 2, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD_14, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND));
			
		}
		
		private function updatePositions():void 
		{
			var position:int = Config.FINGER_SIZE * .3;
			
			description.x = padding;
			description.y = position;
			position += description.height + padding;
			
			var inputWidth:int = _width - padding * 2;
			if (phoneButton != null)
			{
				inputWidth -= phoneButton.width + padding;
			}
			var inputPosition:int = padding;
			phoneField.drawString(inputWidth, null, Lang.enter_phone_number, null, null);
			phoneField.y = position;
			if (phoneButton != null)
			{
				inputWidth -= phoneButton.width + padding;
				inputPosition += phoneButton.width + padding;
				phoneButton.x = padding;
				phoneButton.y = int(phoneField.y + phoneField.textY + phoneField.textHeight * .5 - phoneButton.height * .5);
			}
			
			phoneField.x = inputPosition;
			
			position += phoneField.height + Config.FINGER_SIZE * .3;
			
			numberBack.width = _width;
			numberBack.height = position;
			
			searchButton.x = padding;
			searchButton.y = getContentHeight() - searchButton.height - padding;
		}
		
		private function drawSearchButton():void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.search_user, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			searchButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawStartChatButton():void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.startChat, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			startChatButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawInviteButton():void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textInvite, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BUTTON_ACCENT), 1);
			inviteButton.setBitmapData(buttonBitmap, true);
		}
		
		private function getButtonWidth():int 
		{
			return _width - padding * 2;
		}
		
		private function setState(state:String, animate:Boolean = true):void {
			if (state != currentState)	{
				currentState = state;
				
				user.tap = null;
				
				TweenMax.killTweensOf(resultMessage);
				TweenMax.killTweensOf(startChatButton);
				TweenMax.killTweensOf(user);
				
				var animateTime:Number = 1;
				if (!animate) {
					animateTime = 0;
				}
				var targetPosition:int;
				switch(state) {
					case STATE_USER_FOUND_IN_CONTACTS:	{
						
						user.draw(currentSearchResultLocal, _width - padding * 2, Config.FINGER_SIZE * 1.5);
						displayMessage(Lang.userAlreadyInContacts, -1, animate);
						
						hasName = true;
						if (currentSearchResultLocal.name == null || currentSearchResultLocal.name == "")
							hasName = false;
						
						user.y = resultMessage.y + resultMessage.height + Config.MARGIN * 2;
						
						user.visible = true;
						user.alpha = 0;
						user.tap = startChat;
						user.y = -animationDistance;
						
						TweenMax.to(user, 0.5 * animateTime, { alpha:1, y:0, delay:0.2 * animateTime, ease:Power2.easeOut } );
						
						if (_isActivated) {
							user.activate();
							searchButton.activate();
						}
						
						break;
					}
					case STATE_USER_FOUND: {
						
						scrollPanel.removeObject(searchButton);
						phoneButton.alpha = 1;
						phoneField.alpha = 1;
						scrollPanel.addObject(user);
						view.addChild(startChatButton);
						if (isActivated)
						{
							phoneField.activate();
							phoneButton.activate();
							user.activate();
							startChatButton.activate();
						}
						
						var userModel:ContactVO = new ContactVO(currentSearchResult);
						user.draw(userModel, _width - padding * 2, Config.FINGER_SIZE * 1.5);
						displayMessage(Lang.contactFound, -1, animate);
						
						hasName = true;
						if (userModel.name == null || userModel.name == "")
							hasName = false;
						user.y = resultMessage.y + resultMessage.height + Config.MARGIN * 2;
						
						startChatButton.x = padding;
						startChatButton.y = int(getContentHeight() - startChatButton.height - padding);
						
						targetPosition = numberBack.y + numberBack.height + Config.FINGER_SIZE;
						
						user.visible = true;
						user.alpha = 0;
						user.tap = startChat;
						user.y = targetPosition - animationDistance;
						
						TweenMax.to(user, 0.5 * animateTime, { alpha:1, y:targetPosition, delay:0.2 * animateTime, ease:Power2.easeOut } );
						
						break;
					}
					case STATE_START: {
						
						scrollPanel.removeObject(inviteButton);
						scrollPanel.removeObject(resultMessage);
						scrollPanel.removeObject(user);
						view.addChild(searchButton);
						
						if (startChatButton != null && view.contains(startChatButton))
						{
							view.removeChild(startChatButton);
						}
						
						searchButton.alpha = 1;
						phoneField.alpha = 1;
						phoneButton.alpha = 1;
						
						currentSearchResultLocal = null;
						currentSearchResult = null;
						
						if (_isActivated) {
							searchButton.activate();
							phoneButton.activate();
							phoneField.activate();
						}
						
						hideUserClip();
						
						break;
					}
					case STATE_ERROR: {
						
						phoneField.alpha = 1;
						searchButton.alpha = 1;
						phoneButton.alpha = 1;
						
						scrollPanel.removeObject(inviteButton);
						
						if (_isActivated)
						{
							searchButton.activate();
							phoneButton.activate();
						}
						
						hideUserClip();
						break;
					}
					case STATE_NOT_FOUND: {
						
						phoneField.alpha = 1;
						searchButton.alpha = 1;
						phoneButton.alpha = 1;
						
						displayMessage(LangManager.replace(Lang.regExtValue, Lang.startChatByPhoneDataNULL, phoneField.valueString), -1, animate);
						
						if (_isActivated) {
							inviteButton.activate();
						}
						
						scrollPanel.addObject(inviteButton);
						
						targetPosition = numberBack.y + numberBack.height + resultMessage.height + Config.FINGER_SIZE;
						
						inviteButton.x = int(_width * .5 - inviteButton.width * .5);
						inviteButton.y = targetPosition - animationDistance;
						
						inviteButton.alpha = 0;
						inviteButton.y = targetPosition - animationDistance;
						
						TweenMax.to(inviteButton, 0.5 * animateTime, { alpha:1, y:targetPosition, delay:0.2 * animateTime, ease:Power2.easeOut } );
						
						break;
					}
					case STATE_SEARCH: {
						showPreloader();
						
						searchButton.alpha = 0.5;
						phoneField.alpha = 0.5;
						phoneButton.alpha = 0.5;
						
						Input.S_SOFTKEYBOARD.invoke(false);
						SoftKeyboard.closeKeyboard();
						
						break;
					}
				}
			}
		}
		
		private function showPreloader():void 
		{
			preloader = new CirclePreloader();
			view.addChild(preloader);
			preloader.x = int(_width * .5);
			preloader.y = int(getContentHeight() * .5);
		}
		
		private function openProfile():void {
			var backData:Object = new Object();
			backData.state = currentState;
			if (currentState == STATE_USER_FOUND)
				backData.model = currentSearchResult;
			else if (currentState == STATE_USER_FOUND_IN_CONTACTS)
				backData.model = currentSearchResultLocal;
			if ("data" in data == true && data.data != null && data.data.payCard == true)
				backData.data = { payCard: true };
			MobileGui.changeMainScreen(
				UserProfileScreen,
				{
					data:user.getData(),
					backScreen:StartChatByPhoneScreen,
					backScreenData:backData
				}
			);
		}
		
		private function hideUserClip():void {
			TweenMax.killTweensOf(user);
			user.clean();
			user.visible = false;
		}
		
		override public function onBack(e:Event = null):void {
			if (data && data.backScreen != undefined && data.backScreen != null) {
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function createView():void {
			super.createView();
			
			buttonPaddingLeft = Config.MARGIN * 2;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = AppTheme.GREY_DARK;
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = MainColors.WHITE;
			_view.addChild(scrollPanel.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			scrollPanel.view.y = topBar.trueHeight;
			
			numberBack = new Sprite();
			numberBack.graphics.beginFill(Style.color(Style.COLOR_LIST_SPECIAL), 1);
			numberBack.graphics.drawRect(0, 0, 10, 10);
			numberBack.graphics.endFill();
			scrollPanel.addObject(numberBack);
			
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.AMOUNT;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			phoneField = new InputField( -1, Input.MODE_PHONE);
			phoneField.setBackground(Style.color(Style.COLOR_LIST_SPECIAL));
			phoneField.setDefaultText(Lang.enterPhoneNumber);
			phoneField.onSelectedFunction = onInputSelected;
			phoneField.onChangedFunction = onPhoneChange;
			phoneField.setMaxChars(20);
			phoneField.setPadding(0);
			phoneField.updateTextFormat(tf);
			scrollPanel.addObject(phoneField);;
			
			createSearchButton();
			createStartChatButton();
			createInviteButton();
			
			resultMessage = new Bitmap();
			
			user = new UserSearchResult();
			user.x = buttonPaddingLeft;
			
			description = new Bitmap();
			scrollPanel.addObject(description);
		}
		
		private function createPhonebookButton():void 
		{
			var IconClass:Class = Style.icon(Style.ICON_PHONEBOOK);
			if (IconClass != null)
			{
				phoneButton = new BitmapButton();
				phoneButton.setStandartButtonParams();
				phoneButton.tapCallback = openPhonebook;
				phoneButton.disposeBitmapOnDestroy = true;
				phoneButton.setDownScale(1);
				phoneButton.setOverlay(HitZoneType.CIRCLE);
				
				var iconSprite:Sprite = new IconClass();
				var iconSize:int = Config.FINGER_SIZE * .4;
				UI.scaleToFit(iconSprite, iconSize, iconSize);
				UI.colorize(iconSprite, Style.color(Style.COLOR_ICON_SETTINGS));
				phoneButton.setBitmapData(UI.getSnapshot(iconSprite), true);
				
				scrollPanel.addObject(phoneButton);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function openPhonebook():void 
		{
			if (currentState == STATE_START || currentState == STATE_ERROR || currentState == STATE_NOT_FOUND || currentState == STATE_USER_FOUND)
			{
				var users:Array = PhonebookManager.phones;
				
				if (users != null)
				{
					DialogManager.showDialog(
							ListSelectionPopup,
							{
								items:users,
								title:Lang.TEXT_SELECT_ACCOUNT,
								renderer:ListPhonebook,
								callback:onUserSelected
							}, ServiceScreenManager.TYPE_SCREEN
						);
				}
			}
		}
		
		private function onUserSelected(user:PhonebookUserVO):void 
		{
			if (user != null)
			{
				var phone:String = user.phone;
				if (phone != null)
				{
					phone = StringUtil.trim(phone);
					phone = phone.replace(/ /g, "");
					phone = phone.replace("+", "");
					
					phoneField.valueString = phone;
				}
			}
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function createSearchButton():void 
		{
			searchButton = new BitmapButton();
			searchButton.setStandartButtonParams();
			searchButton.tapCallback = searchUser;
			searchButton.disposeBitmapOnDestroy = true;
			searchButton.setDownScale(1);
			searchButton.setOverlay(HitZoneType.BUTTON);
			view.addChild(searchButton);
		}
		
		private function createStartChatButton():void 
		{
			startChatButton = new BitmapButton();
			startChatButton.setStandartButtonParams();
			startChatButton.tapCallback = startChat;
			startChatButton.disposeBitmapOnDestroy = true;
			startChatButton.setDownScale(1);
			startChatButton.setOverlay(HitZoneType.BUTTON);
		}
		
		private function createInviteButton():void 
		{
			inviteButton = new BitmapButton();
			inviteButton.setStandartButtonParams();
			inviteButton.tapCallback = inviteUser;
			inviteButton.disposeBitmapOnDestroy = true;
			inviteButton.setDownScale(1);
			inviteButton.setOverlay(HitZoneType.BUTTON);
		}
		
		private function inviteUser():void {
			PhonebookManager.invite(null, getPhone());
		}
		
		private function getPhone():String {
			var phoneNumber:String = phoneField.valueString;
			
			phoneNumber = phoneNumber.replace(/[^0-9\+]/gis, '');
			
			if (phoneNumber.length < 6) {
				return null;
			}
			
			if (phoneNumber.charAt(0) == "+") {
				phoneNumber = phoneNumber.substr(1);
			}
			
			return phoneNumber;
		}
		
		private function onPhoneChange():void {
			setState(STATE_START);
		}
		
		private function startChat():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			var cVO:ChatVO = ChatManager.getChatWithUsersList([user.getData().uid]);
			if (cVO != null) {
				chatScreenData.chatVO = cVO;
				chatScreenData.type = ChatInitType.CHAT;
			} else {
				chatScreenData.usersUIDs = [user.getData().uid];
				chatScreenData.type = ChatInitType.USERS_IDS;
			}
			if ("data" in data == true && data.data != null && data.data.payCard == true)
				chatScreenData.payCard = true;
			
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = {state:currentState, model:user.getData()};
			chatScreenData.byPhone = true;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function searchUser():void {
			
			if (currentState == STATE_START)
			{
				var phone:String = getPhone();
				if (phone && phone.length > 7) {
					if (phone == Auth.phone.toString()) {
						return;
					}
					
					var userModel:ContactVO = ContactsManager.getUserByPhone(phone);
					if (userModel) {
						if (userModel.uid == Auth.uid) {
							setState(STATE_NOT_FOUND);
						} else {
							currentSearchResultLocal = userModel;
							setState(STATE_USER_FOUND_IN_CONTACTS);
						}
					} else {
						setState(STATE_SEARCH);
						PHP.getUserByPhone(Crypter.getBaseNumber(Number(phone)), onSearchResult), true;
					}
				}
			}
		}
		
		private function onSearchResult(response:PHPRespond):void {
			if (isDisposed) {
				response.dispose();
				return;
			}
			
			hidePreloader();
			
			searchButton.show();
			if (response.error) {
				//!TODO:
				setState(STATE_ERROR);
				
				displayMessage(ErrorLocalizer.getText(response.errorMsg));
			} else {
				if (response.data) {
					if (("uid" in response.data) && response.data.uid == Auth.uid) {
						setState(STATE_NOT_FOUND);
					} else {
						currentSearchResult = new ContactVO(response.data);
						if (currentSearchResult.userVO != null && phoneField != null && phoneField.valueString != null) {
							currentSearchResult.userVO.setDataFromPhonebookObject( { phone:phoneField.valueString } );
						}
						setState(STATE_USER_FOUND);
					}
				} else {
					setState(STATE_NOT_FOUND);
				}
			}
			response.dispose();
		}
		
		private function displayMessage(text:String, customPosition:int = -1, animate:Boolean = true):void {
			var animationTime:Number = 1;
			if (!animate) {
				animationTime = 0;
			}
			
			if (resultMessage.bitmapData) {
				resultMessage.bitmapData.dispose();
				resultMessage.bitmapData = null;
			}
			resultMessage.bitmapData = TextUtils.createTextFieldData(text, _width - padding * 2, 10, true, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, FontSize.BODY, true, 
																	Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND));
			resultMessage.x = int(_width * .5 - resultMessage.width * .5);
			
			var targetPosition:int;
			if (customPosition == -1) {
				targetPosition = int(numberBack.y + numberBack.height + Config.FINGER_SIZE * .4);
			}
			else {
				targetPosition = customPosition;
			}
			
			scrollPanel.addObject(resultMessage);
			resultMessage.visible = true;
			resultMessage.visible = true;
			resultMessage.y = targetPosition - animationDistance;
			resultMessage.alpha = 0;
			TweenMax.to(resultMessage, 0.5 * animationTime, { alpha:1, y:targetPosition, ease:Power2.easeOut } );
		}
		
		override protected function drawView():void	{
			topBar.drawView(_width);
			topBar.backgroundColor = Style.color(Style.COLOR_LIST_SPECIAL);
			scrollPanel.setWidthAndHeight(_width, getContentHeight() - topBar.trueHeight - searchButton.height - padding * 2);
			if (searchButton != null)
			{
				searchButton.y = getContentHeight() - searchButton.height - padding;
			}
			/*if (searchButton != null)
			{
				searchButton.y = getContentHeight() - searchButton.height - padding;
			}*/
		}
		
		private function getContentHeight():int 
		{
			return _height - Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function hidePreloader():void {
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
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void	{
			super.dispose();
			
			currentSearchResultLocal = null;
			currentSearchResult = null;
			if (topBar != null) {
				topBar.dispose();
				topBar = null;
			}
			if (scrollPanel) {
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (phoneField) {
				phoneField.dispose()
				phoneField = null;
			}
			if (preloader) {
				preloader.dispose()
				preloader = null;
			}
			if (numberBack) {
				UI.destroy(numberBack);
				numberBack = null;
			}
			if (searchButton) {
				searchButton.dispose()
				searchButton = null;
			}
			if (startChatButton) { 
				startChatButton.dispose()
				startChatButton = null;
			}
			if (inviteButton) {
				inviteButton.dispose()
				inviteButton = null;
			}
			if (user) {
				user.dispose()
				user = null;
			}
			if (resultMessage) {
				UI.destroy(resultMessage);
				resultMessage = null;
			}
			if (phoneButton) {
				phoneButton.dispose()
				phoneButton = null;
			}
			if (description) {
				UI.destroy(description);
				description = null;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			if (topBar != null)
				topBar.activate();

			phoneField.activate();
			
			switch(currentState) {
				case STATE_NOT_FOUND: {
					searchButton.activate();
					phoneButton.activate();
					inviteButton.activate();
					break;
				}
				case STATE_SEARCH: {
					break;
				}
				case STATE_START:
				case STATE_ERROR:
				{
					phoneButton.activate();
					searchButton.activate();
					break;
				}
				case STATE_USER_FOUND: {
					user.activate();
					searchButton.activate();
					phoneButton.activate();
					startChatButton.activate();
					break;
				}
				case STATE_USER_FOUND_IN_CONTACTS: {
					user.activate();
					searchButton.activate();
					startChatButton.activate();
					break;
				}
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			
			if (topBar != null)
				topBar.deactivate();
				
			phoneField.deactivate();
			searchButton.deactivate();
			startChatButton.deactivate();
			inviteButton.deactivate();
			user.deactivate();
			phoneButton.deactivate();
			
			SoftKeyboard.closeKeyboard();
		}
	}
}