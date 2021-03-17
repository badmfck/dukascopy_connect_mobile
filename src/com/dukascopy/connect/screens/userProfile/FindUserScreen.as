package com.dukascopy.connect.screens.userProfile {
	
	import assets.CircleLoaderShape;
	import assets.PlusIcon;
	import assets.SearchButtonIconWhite;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.contactsManager.ContactsManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.easing.Power2;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class FindUserScreen extends BaseScreen
	{
		static public const STATE_START:String = "start";
		static public const STATE_ERROR:String = "stateError";
		static public const STATE_NOT_FOUND:String = "notFound";
		static public const STATE_SEARCH:String = "stateSearch";
		static public const STATE_USER_FOUND:String = "stateUserFound";
		static public const STATE_USER_ADDED_TO_PHONE:String = "stateUserAddedToPhone";
		static public const STATE_USER_ADDED_TO_CONTACTS:String = "stateUserAddedToContacts";
		static public const STATE_USER_FOUND_IN_CONTACTS:String = "stateUserFoundInContacts";
		static public const IOS:String = "ios";
		
		private var currentState:String;
		
		private var FIT_WIDTH:Number;
		private var max_text_width:int;
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
		private var nameInputBottom:Bitmap;
		private var phoneField:Input;
		private var buttonPaddingLeft:int;
		private var headerSize:int;
		private var continueButton:RoundedButton;
		private var currentPhone:String;
		private var currentSurname:String;
		private var preloader:Preloader;
		private var preloaderContainer:Sprite;
		private var changeNameRequestId:String;
		private var numberBack:Sprite;
		private var searchButton:BitmapButton;
		private var resultMessage:Bitmap;
		private var searchLoader:Preloader;
		private var searchLoaderContainer:Sprite;
		private var searchButtonContainer:Sprite;
		private var resultMessageContainer:Sprite;
		private var continueButtonContainer:Sprite;
		private var phoneInputContainer:Sprite;
		private var phoneBackContainer:Sprite;
		private var phoneLineContainer:Sprite;
		private var user:UserSearchResult;
		private var userContainer:Sprite;
		private var addContactButton:RoundedButton;
		private var addButtonContainer:Sprite;
		private var inviteButton:RoundedButton;
		private var inviteButtonContainer:Sprite;
		private var plusIcon:PlusIcon;
		private var animationDistance:Number;
		private var busy:Boolean = false;
		private var currentSearchResult:ContactVO;
		private var userInContacts:Boolean;
		private var existOnPhone:Boolean;
		private var addPhoneContactButton:RoundedButton;
		private var addPhoneButtonContainer:Sprite;
		private var currentSearchResultLocal:ContactVO;
		private var addToPhoneError:Boolean;
		
		public function FindUserScreen()
		{
		
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			_params.title = "add new contact";
			_params.doDisposeAfterClose = true;
			
			animationDistance = Config.MARGIN;
			FIT_WIDTH = _width - buttonPaddingLeft * 2;
			
			scrollPanel.view.y = topBar.trueHeight;
			
			addContactButton.setSizeLimits(Config.FINGER_SIZE * 3.5, FIT_WIDTH);
			addPhoneContactButton.setSizeLimits(Config.FINGER_SIZE * 3.5, FIT_WIDTH);
			continueButton.setSizeLimits(Config.FINGER_SIZE * 3.5, FIT_WIDTH);
			inviteButton.setSizeLimits(Config.FINGER_SIZE * 3.5, FIT_WIDTH);
			continueButton.draw();
			addPhoneContactButton.draw();
			inviteButton.draw();
			addContactButton.draw();
			
			topBar.setData(Lang.addNewContact, true);
			
			phoneInputContainer.x = int(buttonPaddingLeft + plusIcon.width - Config.MARGIN);
			phoneInputContainer.y = buttonPaddingLeft;
			phoneField.width = FIT_WIDTH - searchButton.width - Config.MARGIN - plusIcon.width;
			
			numberBack.width = _width;
			numberBack.height = phoneInputContainer.y + phoneField.height + buttonPaddingLeft;
			
			nameInputBottom.width = FIT_WIDTH - searchButton.width - Config.MARGIN;
			phoneLineContainer.y = phoneInputContainer.y + phoneField.view.height - Config.MARGIN*.6;
			phoneLineContainer.x = buttonPaddingLeft;
			
			searchButtonContainer.x = int(phoneLineContainer.x + phoneLineContainer.width + Config.MARGIN);
			searchButtonContainer.y = int(phoneInputContainer.y + phoneField.height * .5 - searchButton.height * .5);
			
			continueButtonContainer.x = int(_width * .5 - continueButton.width * .5);
			continueButtonContainer.y = int(numberBack.y + numberBack.height + buttonPaddingLeft);
			
			searchLoaderContainer.x = int(searchButtonContainer.x + searchButton.width*.5);
			searchLoaderContainer.y = int(searchButtonContainer.y + searchButton.height*.5);
			
			plusIcon.x = buttonPaddingLeft;
			plusIcon.y = int(phoneInputContainer.y + phoneField.height * .5 - plusIcon.height * .5 + Config.MARGIN * .2);
			
			if (data && data.state)
			{
				var stateToShow:String = STATE_START;
				
				if (data.state == STATE_USER_FOUND)
				{
					if (("model" in data) && data.model && (data.model is ContactVO))
					{
						stateToShow = STATE_USER_FOUND;
						currentSearchResult = data.model as ContactVO;
						phoneField.value = currentSearchResult.getPhone().toString();
					}
				}
				else if (data.state == STATE_USER_ADDED_TO_PHONE)
				{
					
				}
				else if (data.state == STATE_USER_FOUND_IN_CONTACTS)
				{
					if (("model" in data) && data.model && (data.model is UserVO))
					{
						stateToShow = STATE_USER_FOUND_IN_CONTACTS;
						currentSearchResultLocal = data.model as ContactVO;
						if (!isNaN(currentSearchResultLocal.getPhone())){
							phoneField.value = currentSearchResultLocal.getPhone().toString();
						}
					}
				}
				else if (data.state == STATE_USER_ADDED_TO_CONTACTS)
				{
					
				}
				
				setState(stateToShow, false);
			}
			else
			{
				setState(STATE_START);
			}
			NativeExtensionController.S_NATIVE_ERROR.add(onNativeError);
		}
		
		private function onNativeError(type:String):void 
		{
			if (type == NativeExtensionController.NATIVE_ERROR_NEED_CONTACTS_PERMISSION) {
				addToPhoneError = true;
				if (userContainer != null && user != null) {
				//	displayMessage(Lang.needContactsPermissionToAddContact, userContainer.y + user.height + Config.MARGIN * 3, true, 0xCC3300);
				}
			}
		}
		
		private function setState(state:String, animate:Boolean = true):void 
		{
			if (state != currentState)
			{
				currentState = state;
				
				user.tap = null;
				
				TweenMax.killTweensOf(resultMessage);
				TweenMax.killTweensOf(addContactButton);
				TweenMax.killTweensOf(addPhoneContactButton);
				TweenMax.killTweensOf(userContainer);
				TweenMax.killTweensOf(user);
				
				var animateTime:Number = 1;
				if (!animate)
				{
					animateTime = 0;
				}
				
				switch(state)
				{
					case STATE_USER_FOUND_IN_CONTACTS:
					{
						continueButton.hide();
						continueButton.deactivate();
						inviteButton.hide();
						existOnPhone = (PhonebookManager.getUserModelByUserUID(currentSearchResultLocal.uid) != null);
						
						user.draw(currentSearchResultLocal, FIT_WIDTH, Config.FINGER_SIZE * 1.5);
						displayMessage(Lang.userAlreadyInContacts, -1, animate);
						
						userContainer.y = resultMessageContainer.y + resultMessage.height + Config.MARGIN * 2;
						
						if (!existOnPhone)
						{
							//есть в контактах, но не на телефоне;
							
							addPhoneButtonContainer.x = int(_width * .5 - addContactButton.width * .5);
							addPhoneButtonContainer.y = int(userContainer.y + user.getHeight() + Config.MARGIN);
							
							addPhoneContactButton.show(0);
							addPhoneContactButton.alpha = 0;
							addPhoneContactButton.y = -animationDistance;
							addPhoneButtonContainer.visible = true;
							TweenMax.to(addPhoneContactButton, 0.5 * animateTime, { alpha:1, y:0, delay:0.4 * animateTime, ease:Power2.easeOut } );
						}
						
						user.visible = true;
						user.alpha = 0;
						user.tap = openProfile;
						user.y = -animationDistance;
						
						TweenMax.to(user, 0.5 * animateTime, { alpha:1, y:0, delay:0.2 * animateTime, ease:Power2.easeOut } );
						
						if (_isActivated)
						{
							user.activate();
							searchButton.activate();
							
							if(!existOnPhone)
							{
								addPhoneContactButton.activate();
							}
						}
						
						break;
					}
					case STATE_USER_FOUND:
					{
						inviteButton.hide();
						user.activate();
						existOnPhone = (PhonebookManager.getUserModelByUserUID(currentSearchResult.uid) != null);
						
						var userModel:ContactVO = new ContactVO(currentSearchResult);
						user.draw(userModel, FIT_WIDTH, Config.FINGER_SIZE * 1.5);
						displayMessage(Lang.contactFound, -1, animate);
						
						userContainer.y = resultMessageContainer.y + resultMessage.height + Config.MARGIN * 2;
						
						
						addButtonContainer.x = int(_width * .5 - addContactButton.width * .5);
						addButtonContainer.y = int(userContainer.y + user.getHeight() + Config.MARGIN);
						
						addContactButton.show(0);
						addContactButton.alpha = 0;
						addContactButton.y = -animationDistance;
						addButtonContainer.visible = true;
						TweenMax.to(addContactButton, 0.5 * animateTime, { alpha:1, y:0, delay:0.4 * animateTime, ease:Power2.easeOut } );
						
						user.visible = true;
						user.alpha = 0;
						user.tap = openProfile;
						user.y = -animationDistance;
						
						TweenMax.to(user, 0.5 * animateTime, { alpha:1, y:0, delay:0.2 * animateTime, ease:Power2.easeOut } );
						
						if (_isActivated)
						{
							user.activate();
							searchButton.activate();
							addContactButton.activate();
						}
						
						break;
					}
					case STATE_USER_ADDED_TO_CONTACTS:
					{
						addContactButton.hide();
						addContactButton.deactivate();
						
						addPhoneContactButton.hide();
						addPhoneContactButton.deactivate();
						
						resultMessage.visible = false;
						
						TweenMax.to(userContainer, 0.5 * animateTime, { y:(numberBack.height), ease:Power2.easeOut,
								onComplete:function():void
								{
									if (addToPhoneError == true)   {
										displayMessage(Lang.needContactsPermissionToAddContact, userContainer.y + user.height + Config.MARGIN * 3, animate, 0xCC3300);
									}
									else {
										displayMessage(user.getData().name  + " " + Lang.contactWasAdded, userContainer.y + user.height + Config.MARGIN * 3, animate);
									}
								}
						});
						if (_isActivated)
						{
							user.activate();
							user.tap = openProfile;
						}
						
						break;
					}
					case STATE_USER_ADDED_TO_PHONE:
					{
						addPhoneContactButton.hide();
						addPhoneContactButton.deactivate();
						
						resultMessage.visible = false;
						
						TweenMax.to(userContainer, 0.5 * animateTime, { y:(numberBack.height), ease:Power2.easeOut, delay:1,
								onComplete:function():void
								{
									if (addToPhoneError == true)   {
										displayMessage(Lang.needContactsPermissionToAddContact, userContainer.y + user.height + Config.MARGIN * 3, animate, 0xCC3300);
									}
									else {
										displayMessage(Lang.savedToPhone, userContainer.y + user.height + Config.MARGIN * 3, animate);
									}
								}
						});
						if (_isActivated)
						{
							user.activate();
							user.tap = openProfile;
						}
						
						break;
					}
					case STATE_START:
					{
						currentSearchResultLocal = null;
						currentSearchResult = null;
						addPhoneContactButton.hide();
						inviteButton.hide();
						continueButton.show();
						continueButtonContainer.visible = true;
						addContactButton.hide();
						
						if (_isActivated)
						{
							continueButton.activate();
							searchButton.activate();
						}
						
						hideUserClip();
						resultMessage.visible = false;
						
						continueButton.alpha = 0;
						TweenMax.to(continueButton, 0.5 * animateTime, {alpha:1, delay:0.3 * animateTime, ease:Power2.easeOut});
						
						break;
					}
					case STATE_ERROR:
					{
						inviteButton.visible = false;
						continueButton.hide();
						continueButton.deactivate();
						addContactButton.hide();
						
						if (_isActivated)
						{
							searchButton.activate();
						}
						
						hideUserClip();
						
						break;
					}
					case STATE_NOT_FOUND:
					{
						displayMessage(LangManager.replace(Lang.regExtValue, Lang.startChatByPhoneDataNULL, phoneField.value), -1, animate);
						
						inviteButton.show(0);
						inviteButton.visible = true;
						
						if (_isActivated)
						{
							inviteButton.activate();
						}
						
						inviteButtonContainer.x = int(_width * .5 - inviteButton.width * .5);
						inviteButtonContainer.y = int(resultMessageContainer.y + resultMessage.height + Config.MARGIN * 3);
						
						inviteButton.show(0);
						inviteButton.alpha = 0;
						inviteButton.y = -animationDistance;
						inviteButtonContainer.visible = true;
						
						TweenMax.to(inviteButton, 0.5 * animateTime, { alpha:1, y:0, delay:0.2 * animateTime, ease:Power2.easeOut } );
						
						break;
					}
					case STATE_SEARCH:
					{
						continueButton.hide();
						onPoneInputFocusOut();
						addContactButton.hide();
						hideUserClip();
						Input.S_SOFTKEYBOARD.invoke(false);
						
						searchLoader.show();
						searchButton.hide();
						resultMessage.visible = false;
						inviteButton.visible = false;
						
						SoftKeyboard.closeKeyboard();
						
						break;
					}
				}
			}
		}
		
		private function openProfile():void 
		{
			var backData:Object = new Object();
			backData.state = currentState;
			if (currentState == STATE_USER_FOUND)
			{
				backData.model = currentSearchResult;
			}
			else if (currentState == STATE_USER_FOUND_IN_CONTACTS)
			{
				backData.model = currentSearchResultLocal;
			}
			
			MobileGui.changeMainScreen(UserProfileScreen, {data:user.getData(), 
															backScreen:FindUserScreen, 
															backScreenData:backData});
		}
		
		private function hideUserClip():void 
		{
			TweenMax.killTweensOf(user);
			user.clean();
			user.visible = false;
		}
		
		override public function onBack(e:Event = null):void
		{
			if (data && data.backScreen != undefined && data.backScreen != null)
			{
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function createView():void
		{
			super.createView();
			
			buttonPaddingLeft = Config.MARGIN * 2;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = AppTheme.GREY_DARK;
			headerSize = int(Config.FINGER_SIZE * .85);
			var btnSize:int = headerSize * .38;
			var btnY:int = (headerSize - btnSize) * .5;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = MainColors.WHITE;
			_view.addChild(scrollPanel.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			numberBack = new Sprite();
			numberBack.graphics.beginFill(0xF7F7F7, 1);
			numberBack.graphics.drawRect(0, 0, 10, 10);
			numberBack.graphics.endFill();
			phoneBackContainer = new Sprite();
			phoneBackContainer.addChild(numberBack);
			scrollPanel.addObject(phoneBackContainer);
			
			phoneField = new Input();
			phoneField.setPadding(Config.FINGER_SIZE*.2);
			phoneField.backgroundColor = 0xF7F7F7;
			phoneField.setMode(Input.MODE_PHONE);
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = Config.FINGER_SIZE * .4;
			phoneField.updateTextFormat(textFormat);
			phoneField.setLabelText(Lang.enterPhoneNumber);
			phoneField.S_FOCUS_OUT.add(onPoneInputFocusOut);
			phoneField.setBorderVisibility(false);
			phoneField.setRoundBG(false);
			phoneField.S_CHANGED.add(onPhoneChange);
		//	phoneField.getTextField().textColor = AppTheme.GREY_DARK;
			phoneField.setRoundRectangleRadius(0);
			phoneField.inUse = true;
			phoneInputContainer = new Sprite();
			phoneInputContainer.addChild(phoneField.view);
			scrollPanel.addObject(phoneInputContainer);
			
			plusIcon = new PlusIcon();
			plusIcon.transform.colorTransform = colorTransform;
			UI.scaleToFit(plusIcon, int(Config.FINGER_SIZE * .25), int(Config.FINGER_SIZE * .25));
			scrollPanel.addObject(plusIcon);
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2, AppTheme.GREY_DARK);
			nameInputBottom = new Bitmap(hLineBitmapData);
			phoneLineContainer = new Sprite();
			phoneLineContainer.addChild(nameInputBottom);
			scrollPanel.addObject(phoneLineContainer);
			
			continueButton = new RoundedButton(Lang.BTN_CONTINUE, AppTheme.GREEN_MEDIUM, AppTheme.GREEN_DARK, null);
			continueButton.setStandartButtonParams();
			continueButton.setDownScale(1);
			continueButton.cancelOnVerticalMovement = true;
			continueButton.tapCallback = searchUser;
			continueButtonContainer = new Sprite();
			continueButtonContainer.addChild(continueButton);
			scrollPanel.addObject(continueButtonContainer);
			continueButton.hide();
			
			addContactButton = new RoundedButton(Lang.addToContacts, AppTheme.GREEN_MEDIUM, AppTheme.GREEN_DARK, null);
			addContactButton.setStandartButtonParams();
			addContactButton.setDownScale(1);
			addContactButton.cancelOnVerticalMovement = true;
			addContactButton.tapCallback = addUser;
			addButtonContainer = new Sprite();
			addButtonContainer.addChild(addContactButton);
			scrollPanel.addObject(addButtonContainer);
			addContactButton.hide();
			
			addPhoneContactButton = new RoundedButton(Lang.saveToPhone, AppTheme.GREEN_MEDIUM, AppTheme.GREEN_DARK, null);
			addPhoneContactButton.setStandartButtonParams();
			addPhoneContactButton.setDownScale(1);
			addPhoneContactButton.cancelOnVerticalMovement = true;
			addPhoneContactButton.tapCallback = addUserToPhone;
			addPhoneButtonContainer = new Sprite();
			addPhoneButtonContainer.addChild(addPhoneContactButton);
			scrollPanel.addObject(addPhoneButtonContainer);
			addPhoneContactButton.hide();
			
			inviteButton = new RoundedButton(Lang.textInvite, AppTheme.GREEN_MEDIUM, AppTheme.GREEN_DARK, null);
			inviteButton.setStandartButtonParams();
			inviteButton.setDownScale(1);
			inviteButton.cancelOnVerticalMovement = true;
			inviteButton.tapCallback = inviteUser;
			inviteButtonContainer = new Sprite();
			inviteButtonContainer.addChild(inviteButton);
			scrollPanel.addObject(inviteButtonContainer);
			inviteButton.hide();
			
			var searchButtonIcon:SearchButtonIconWhite = new SearchButtonIconWhite();
			UI.scaleToFit(searchButtonIcon, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			searchButtonIcon.transform.colorTransform = colorTransform;
			searchButton = new BitmapButton();
			searchButton.setStandartButtonParams();
			searchButton.setDownScale(1);
			searchButton.cancelOnVerticalMovement = true;
			searchButton.tapCallback = searchUser;
			searchButton.setOverflow((Config.FINGER_SIZE - searchButton.height)/2, (Config.FINGER_SIZE - searchButton.width)/2, (Config.FINGER_SIZE - searchButton.width)/2, (Config.FINGER_SIZE - searchButton.height)/2);
			searchButton.setBitmapData(UI.getSnapshot(searchButtonIcon, StageQuality.HIGH, "FindUserScreen.searchButton"));
			searchButtonContainer = new Sprite();
			scrollPanel.addObject(searchButtonContainer);
			searchButtonContainer.addChild(searchButton);
			
			
			resultMessage = new Bitmap();
			resultMessage.visible = false;
			resultMessageContainer = new Sprite();
			scrollPanel.addObject(resultMessageContainer);
			resultMessageContainer.addChild(resultMessage);
			
			
			searchLoaderContainer = new Sprite();
			var loaderSize:int = Config.FINGER_SIZE * .5;
			if (loaderSize%2 == 1)
				loaderSize ++;
			searchLoader = new Preloader(loaderSize, CircleLoaderShape);
			scrollPanel.addObject(searchLoaderContainer);
			searchLoaderContainer.addChild(searchLoader);
			searchLoader.visible = false;
			
			
			user = new UserSearchResult();
			user.x = buttonPaddingLeft;
			userContainer = new Sprite();
			userContainer.addChild(user);
			scrollPanel.addObject(userContainer);
			user.visible = false;
			
			
			preloader = new Preloader();
			_view.addChild(preloader);
			preloader.hide();
			preloader.visible = false;
		}
		
		private function inviteUser():void 
		{
			PhonebookManager.invite(null, getPhone());
		}
		
		private function getPhone():String 
		{
			var phoneNumber:String = phoneField.value;
			
			phoneNumber = phoneNumber.replace(/[^0-9\+]/gis, '');
			
			if (phoneNumber.length < 6)
			{
				return null;
			}
			
			if (phoneNumber.charAt(0) == "+")
			{
				phoneNumber = phoneNumber.substr(1);
			}
			
			return phoneNumber;
		}
		
		private function onPhoneChange():void 
		{
			setState(STATE_START);
		}
		
		private function addUserToPhone():void 
		{
			var userName:String;
			
			var dataName:String = user.getData().name;
			if (dataName != null && dataName != "")
			{
				userName = dataName;
			}
			else
			{
				userName = Lang.noName;
			}
			
			var firstName:String = "";
			var secondName:String = "";
			
			if (userName == Lang.noName)
			{
				firstName = userName;
			}
			else
			{
				if (userName.split(" ").length == 2)
				{
					firstName = userName.split(" ")[0];
					secondName = userName.split(" ")[1];
				}
				else
				{
					firstName = userName;
				}
			}
			
			// load user avatar to save on phone;
			var imageBytes:ByteArray;
			var avatarPath:String = user.getData().avatarURL;
			if (!avatarPath)
				avatarPath = user.getData().avatarURL;
			
			var phoneToAdd:String = user.getData().getPhone().toString();
			if(phoneToAdd == null)
				phoneToAdd = "";
			else
				phoneToAdd = "+" + phoneToAdd;
			
			addContactToPhone(firstName, secondName, "+" + user.getData().getPhone().toString(), avatarPath);
		}
		
		private function addContactToPhone(firstName:String, secondName:String, phone:String, imagePath:String):void {
			addToPhoneError = false;
			if (Config.PLATFORM_APPLE) {
				if (MobileGui.dce != null) {
					var contactAccessStatus:Number = MobileGui.dce.contactAccessStatus();
					if (contactAccessStatus == 3) {
						MobileGui.dce.addContact(firstName, "+" + user.getData().getPhone().toString(), secondName, imagePath);
						if (currentState != STATE_USER_ADDED_TO_CONTACTS) {
							setState(STATE_USER_ADDED_TO_PHONE);
						}
					} else {
						//!TODO: нет доступа к телефонной книге;
					}
				} else {
					ApplicationErrors.add("native extension missed");
				}
			} else if (Config.PLATFORM_ANDROID) {
				if (MobileGui.androidExtension) {
					if (currentState != STATE_USER_ADDED_TO_CONTACTS) {
						setState(STATE_USER_ADDED_TO_PHONE);
					}
					MobileGui.androidExtension.addContact(firstName, secondName, "+" + user.getData().getPhone().toString(), imagePath);
				}
			} else {
				if (currentState != STATE_USER_ADDED_TO_CONTACTS) {
					setState(STATE_USER_ADDED_TO_PHONE);
				}
			}
		}
		
		private function addUser():void {
			busy = true;
			addContactButton.deactivate();
			addContactButton.hide();
			var customName:String = user.getData().name;
			
			PHP.addUserToMemo(onUserAddResponse, user.getData().uid, customName);
		}
		
		private function onUserAddResponse(response:PHPRespond):void {
			busy = false;
			if (isDisposed) {
				response.dispose();
				return;
			}
			if (response.error) {
				if (isActivated)
					addContactButton.activate();
				var errorMessage:String;
				if (response.errorMsg == PHP.NETWORK_ERROR)
					errorMessage = Lang.alertProvideInternetConnection;
				else
					errorMessage = Lang.serverError + response.errorMsg;
				DialogManager.alert(Lang.textWarning, errorMessage);
			} else {
				setState(STATE_USER_ADDED_TO_CONTACTS);
				ContactsManager.addMemoUser(user.getData());
				addUserToPhone();
			}
			response.dispose();
		}
		
		private function onPoneInputFocusOut():void {
			var currentValue:String = StringUtil.trim(phoneField.value);
			if (currentValue != "" && currentValue != phoneField.getDefValue()) {
				currentPhone = currentValue;
			} else {
				phoneField.value = currentPhone;
			}
		}
		
		private function searchUser():void {
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
		
		private function onSearchResult(response:PHPRespond):void {
			if (isDisposed) {
				response.dispose();
				return;
			}
			searchLoader.hide();
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
						if (currentSearchResult.userVO != null && phoneField != null && phoneField.value != null) {
							currentSearchResult.userVO.setDataFromPhonebookObject( { phone:phoneField.value } );
						}
						setState(STATE_USER_FOUND);
					}
				} else {
					setState(STATE_NOT_FOUND);
				}
			}
			response.dispose();
		}
		
		private function displayMessage(text:String, customPosition:int = -1, animate:Boolean = true, color:Number = AppTheme.GREY_MEDIUM):void 
		{
			var animationTime:Number = 1;
			if (!animate)
			{
				animationTime = 0;
			}
			
			if (resultMessage.bitmapData)
			{
				resultMessage.bitmapData.dispose();
				resultMessage.bitmapData = null;
			}
			resultMessage.bitmapData = TextUtils.createTextFieldData(text, FIT_WIDTH - Config.FINGER_SIZE, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, color, MainColors.WHITE);
			resultMessageContainer.x = int(_width * .5 - resultMessage.width * .5);
			if (customPosition == -1)
			{
				resultMessageContainer.y = continueButtonContainer.y + Config.MARGIN * 2;
			}
			else
			{
				resultMessageContainer.y = customPosition;
			}
			
			resultMessageContainer.visible = true;
			resultMessage.visible = true;
			resultMessage.y = -animationDistance;
			resultMessage.alpha = 0;
			TweenMax.killTweensOf(resultMessage);
			TweenMax.to(resultMessage, 0.5 * animationTime, { alpha:1, y:0, ease:Power2.easeOut } );
		}
		
		private function lockScreen():void
		{
			displayPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void
		{
			hidePreloader();
			activateScreen();
		}
		
		override protected function drawView():void
		{
			topBar.drawView(_width);
			scrollPanel.setWidthAndHeight(_width, _height - headerSize - Config.APPLE_TOP_OFFSET);
		}
		
		private function displayPreloader():void
		{
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			preloader.show();
			preloader.visible = true;
		}
		
		private function hidePreloader():void
		{
			preloader.hide();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			currentSearchResultLocal = null;
			currentSearchResult = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;

			if (scrollPanel){
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (nameInputBottom){
				UI.destroy(nameInputBottom);
				nameInputBottom = null;
			}
			if (phoneField){
				phoneField.S_CHANGED.remove(onPhoneChange);
				phoneField.S_FOCUS_OUT.remove(onPoneInputFocusOut);
				phoneField.dispose()
				phoneField = null;
			}
			if(addPhoneContactButton)
			{
				addPhoneContactButton.dispose()
				addPhoneContactButton = null;
			}
			if (continueButton){
				continueButton.dispose()
				continueButton = null;
			}
			if (preloader){
				preloader.dispose()
				preloader = null;
			}
			if (preloaderContainer){
				UI.destroy(preloaderContainer);
				preloaderContainer = null;
			}
			if (numberBack){
				UI.destroy(numberBack);
				numberBack = null;
			}
			if (searchButton){
				searchButton.dispose()
				searchButton = null;
			}
			if (addContactButton){
				addContactButton.dispose()
				addContactButton = null;
			}
			if (inviteButton){
				inviteButton.dispose()
				inviteButton = null;
			}
			if (user){
				user.dispose()
				user = null;
			}
			if (resultMessage){
				UI.destroy(resultMessage);
				resultMessage = null;
			}
			if (searchLoaderContainer){
				UI.destroy(searchLoaderContainer);
				searchLoaderContainer = null;
			}
			if (searchButtonContainer){
				UI.destroy(searchButtonContainer);
				searchButtonContainer = null;
			}
			if (resultMessageContainer){
				UI.destroy(resultMessageContainer);
				resultMessageContainer = null;
			}
			if (continueButtonContainer){
				UI.destroy(continueButtonContainer);
				continueButtonContainer = null;
			}
			if (phoneInputContainer){
				UI.destroy(phoneInputContainer);
				phoneInputContainer = null;
			}
			if (phoneBackContainer){
				UI.destroy(phoneBackContainer);
				phoneBackContainer = null;
			}
			if (phoneLineContainer){
				UI.destroy(phoneLineContainer);
				phoneLineContainer = null;
			}
			if (userContainer){
				UI.destroy(userContainer);
				userContainer = null;
			}
			if (addButtonContainer){
				UI.destroy(addButtonContainer);
				addButtonContainer = null;
			}
			if (inviteButtonContainer){
				UI.destroy(inviteButtonContainer);
				inviteButtonContainer = null;
			}
			if (plusIcon){
				UI.destroy(plusIcon);
				plusIcon = null;
			}
			if (searchLoader){
				searchLoader.dispose();
				searchLoader = null;
			}
			NativeExtensionController.S_NATIVE_ERROR.remove(onNativeError);
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			if (_isDisposed)
			{
				return;
			}
			
			if (topBar != null)
				topBar.activate();
				
			phoneField.activate();
			
			switch(currentState)
			{
				case STATE_NOT_FOUND:
				{
					searchButton.activate();
					inviteButton.activate();
					break;
				}
				case STATE_SEARCH:
				{
					break;
				}
				case STATE_START:
				{
					continueButton.activate();
					searchButton.activate();
					break;
				}
				case STATE_USER_FOUND:
				{
					user.activate();
					searchButton.activate();
					if (!busy)
					{
						if (userInContacts && !existOnPhone)
						{
							addPhoneContactButton.activate();
						}
						addContactButton.activate();
					}
					break;
				}
				case STATE_USER_FOUND_IN_CONTACTS:
				{
					user.activate();
					searchButton.activate();
					if (!busy)
					{
						if (userInContacts && !existOnPhone)
						{
							addPhoneContactButton.activate();
						}
						addContactButton.activate();
					}
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
			continueButton.deactivate();
			searchButton.deactivate();
			addContactButton.deactivate();
			inviteButton.deactivate();
			user.deactivate();
			addPhoneContactButton.deactivate();
			SoftKeyboard.closeKeyboard();
		}
	}
}