package com.dukascopy.connect.screens.chat {
	
		import assets.AddUserToChatIcon;
		import assets.ChoiseIcon;
		import assets.DeleteIcon;
		import assets.IconArrowRight;
		import assets.InfoIcon;
		import assets.ModeIcon;
		import com.dukascopy.connect.Config;
		import com.dukascopy.connect.MobileGui;
		import com.dukascopy.connect.data.ResponseResolver;
		import com.dukascopy.connect.data.TextFieldSettings;
		import com.dukascopy.connect.data.screenAction.IAction;
		import com.dukascopy.connect.data.screenAction.customActions.CropImageAction;
		import com.dukascopy.connect.data.screenAction.customActions.SelectImageAction;
		import com.dukascopy.connect.data.screenAction.customActions.UpdateChannelSettingsAction;
		import com.dukascopy.connect.data.screenAction.customActions.UploadChannelAvatarAction;
		import com.dukascopy.connect.data.screenAction.customActions.UploadPublicImageAction;
		import com.dukascopy.connect.gui.components.message.ToastMessage;
		import com.dukascopy.connect.gui.components.textEditors.FullscreenTextEditor;
		import com.dukascopy.connect.gui.components.textEditors.TitleTextEditor;
		import com.dukascopy.connect.gui.lightbox.UI;
		import com.dukascopy.connect.gui.list.renderers.ListLink;
		import com.dukascopy.connect.gui.menuVideo.BitmapButton;
		import com.dukascopy.connect.gui.menuVideo.OptionSwitcherCustomLayout;
		import com.dukascopy.connect.gui.preloader.Preloader;
		import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
		import com.dukascopy.connect.gui.topBar.TopBarScreen;
		import com.dukascopy.connect.screens.ChatScreen;
		import com.dukascopy.connect.screens.RootScreen;
		import com.dukascopy.connect.screens.base.BaseScreen;
		import com.dukascopy.connect.screens.base.ScreenManager;
		import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
		import com.dukascopy.connect.sys.auth.Auth;
		import com.dukascopy.connect.sys.chatManager.ChatManager;
		import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
		import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
		import com.dukascopy.connect.sys.dialogManager.DialogManager;
		import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
		import com.dukascopy.connect.sys.imageManager.ImageManager;
		import com.dukascopy.connect.sys.style.Style;
		import com.dukascopy.connect.sys.theme.AppTheme;
		import com.dukascopy.connect.utils.actionsSequence.ActionsSequence;
		import com.dukascopy.connect.vo.ChatVO;
		import com.dukascopy.connect.vo.screen.ChatScreenData;
		import com.dukascopy.langs.Lang;
		import com.hurlant.util.Base64;
		import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.display.Shape;
		import flash.events.Event;
		import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class ChannelSettingsScreen extends BaseScreen
	{
		private var topBar:TopBarScreen;
		
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private var iconSize:Number;
		private var buttonPaddingLeft:int;
		private var FIT_WIDTH:int;
		private var backgroundIconHeight:Number;
		private var chatModel:ChatVO;
		private var settingsTextPosition:int;
		private var settingsIconPosition:int;
		private var line1:Bitmap;
		private var uid:String;
		private var scrollPanel:ScrollPanel;
		private var channelInfoButton:BitmapButton;
		private var currentTextEditor:FullscreenTextEditor;
		private var channelModeButton:BitmapButton;
		private var optionNotifications:OptionSwitcherCustomLayout;
		private var channelBackButton:BitmapButton;
		private var avatarSize:int;
		private var preloader:Preloader;
		private var uploadingImage:ImageBitmapData;
		private var changeBackgroundSequence:ActionsSequence;
		private var channelAvatarButton:BitmapButton;
		private var changeAvatarSequence:ActionsSequence;
		private var locked:Boolean;
		private var channelCoverButton:BitmapButton;
		private var changeCoverImageSequence:ActionsSequence;
		private var titleEdit:TitleTextEditor;
		private var lastLoadedBackgroundThumbURL:String;
		private var closeChannelButton:BitmapButton;
		private var line2:Bitmap;
		private var channelUID:String;
		private var addBotButton:BitmapButton;
		private var trashButton:BitmapButton;
		
		public function ChannelSettingsScreen() { }
		
		override public function initScreen(data:Object = null):void {
			if ("data" in data && data.data != null && "chatId" in data.data)
				uid = data.data.chatId;
			if (uid == null && ChatManager.getCurrentChat() != null)
				uid = ChatManager.getCurrentChat().uid;
			if (uid == null) {
				MobileGui.centerScreen.show(RootScreen);
				return;
			}
			
			chatModel = ChannelsManager.getChannel(uid);
			if (chatModel == null)
			{
				chatModel = AnswersManager.getAnswer(uid);
			}
			if (chatModel == null){
				onBack();
				return;
			}
			super.initScreen(data);
			
			_params.title = 'Channel settings screen';
			_params.doDisposeAfterClose = true;
			
			topBar.setData(Lang.channelSettings, true);
			backgroundIconHeight = Config.FINGER_SIZE * .7;
			settingsIconPosition = int(backgroundIconHeight * .5);
			settingsTextPosition = int(backgroundIconHeight + Config.MARGIN*1.5);
			FIT_WIDTH = _width - buttonPaddingLeft * 2;
			avatarSize = Config.FINGER_SIZE * .35;
			
			var position:int = Config.MARGIN;
			
			if (chatModel.questionID == null || chatModel.questionID == ""){
				drawTitleEditor(position);
				position += OPTION_LINE_HEIGHT + Config.MARGIN;
				
				drawChannelInfoButton(position);
				position += OPTION_LINE_HEIGHT;
			}
			
			drawChannelModeButton(position);
			position += OPTION_LINE_HEIGHT;
			
			drawNotificationsOption(position);
			position += OPTION_LINE_HEIGHT;
			
			drawAddBotButton(position);
			position += OPTION_LINE_HEIGHT;
			
			position += Config.MARGIN;
			
			line1.width = _width;
			line1.y = position;
			
			position += Config.MARGIN * 1.5;
			
			if (chatModel.questionID == null || chatModel.questionID == ""){
				drawAvatarButton(position);
				position += OPTION_LINE_HEIGHT;
			}
			
			drawBackgroundButton(position);
			position += OPTION_LINE_HEIGHT;
			
			position += Config.MARGIN * 1.5;
			line2.width = _width;
			line2.y = position;
			position += Config.MARGIN * 1.5;
			
			if (Config.isAdmin())
			{
				drawTrashButton(position);
				position += OPTION_LINE_HEIGHT;
			}
			
			if (chatModel.questionID != null && chatModel.questionID != "") {
				
			}
			else {
				drawCloseChanelButton(position);
				position += OPTION_LINE_HEIGHT;
			}
			
			position += Config.MARGIN * 1.5;
			
			
			/*drawCoverButton(position);
			position += OPTION_LINE_HEIGHT;*/
			
			ChannelsManager.S_CHANNEL_MODERATORS_UPDATED.add(onChannelModeratorChanged);
			ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.add(onChannelChanged);
		}
		
		private function onAddBotCalled():void 
		{
			MobileGui.changeMainScreen(SelectBotScreen, { 	chatModel:chatModel, 
															title:Lang.addBot,
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:data },
										ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		private function drawCloseChanelButton(position:int):void 
		{
			var icon:SWFSettingsIcon_logout = new SWFSettingsIcon_logout();
			UI.scaleToFit(icon, iconSize, iconSize);
			closeChannelButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.closeChannel, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null, 
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			null), true);
			closeChannelButton.x = buttonPaddingLeft;
			closeChannelButton.y = position;
			
			UI.destroy(icon);
			icon = null;
		}
		
		private function drawTrashButton(position:int):void 
		{
			if (trashButton == null)
			{
				trashButton = new BitmapButton();
				trashButton.setStandartButtonParams();
				trashButton.setDownScale(1);
				trashButton.setDownColor(0xFFFFFF);
				trashButton.tapCallback = trashChannel;
				trashButton.disposeBitmapOnDestroy = true;
				trashButton.usePreventOnDown = false;
				trashButton.cancelOnVerticalMovement = true;
				trashButton.show();
				scrollPanel.addObject(trashButton);
			}
			
			var icon:DeleteIcon = new DeleteIcon();
			UI.colorize(icon, 0x91A0AC);
			UI.scaleToFit(icon, iconSize, iconSize);
			
			var text:String;
			if (ChannelsManager.isChannelInTrash(chatModel.uid))
			{
				text = Lang.approveChannel;
			}
			else
			{
				text = Lang.moveToSpam;
			}
			
			trashButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(text, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null, 
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			null), true);
			trashButton.x = buttonPaddingLeft;
			trashButton.y = position;
			
			UI.destroy(icon);
			icon = null;
		}
		
		private function trashChannel():void 
		{
			ChannelsManager.changeChannelStatus(chatModel.uid);
		}
		
		private function onChannelChanged(eventType:String, channelUID:String):void 
		{
			if (channelUID != chatModel.uid)
			{
				return;
			}
			
			switch(eventType)
			{
				case ChannelsManager.EVENT_BACKGROUND_CHANGED:
				{
					drawBackgroundButton(channelBackButton.y);
					break;
				}
				case ChannelsManager.EVENT_BACKGROUND_CHANGED:
				{
					drawAvatarButton(channelAvatarButton.y);
					break;
				}
				case ChannelsManager.EVENT_TITLE_CHANGED:
				{
					drawTitleEditor(titleEdit.y);
					break;
				}
				case ChannelsManager.EVENT_MODE_CHANGED:
				{
					drawChannelModeButton(channelModeButton.y);
					break;
				}
				case ChannelsManager.EVENT_STATUS_CHANGED:
				{
					if (Config.isAdmin() && trashButton != null)
					{
						drawTrashButton(trashButton.y);
					}
					break;
				}
			}
		}
		
		private function onChannelModeratorChanged(eventType:String, channelUID:String):void 
		{
			if (channelUID != chatModel.uid)
			{
				return;
			}
			
			switch(eventType)
			{
				case ChannelsManager.EVENT_REMOVED_FROM_MODERATORS:
				{
					if (this.data && this.data.backScreenData && this.data.backScreenData.backScreenData && (this.data.backScreenData.backScreenData is ChatScreenData))
					{
						MobileGui.changeMainScreen(ChannelInfoScreen, { data:{ chatId:chatModel.uid, chatSettings:this.data.chatSettings },
															backScreen:ChatScreen,
															backScreenData:this.data.backScreenData.backScreenData },
															ScreenManager.DIRECTION_RIGHT_LEFT);
					}
					else
					{
						MobileGui.changeMainScreen(RootScreen);
					}
					
					break;
				}
			}
		}
		
		private function drawTitleEditor(position:int):void 
		{
			if (titleEdit == null) {
				titleEdit = new TitleTextEditor();
				titleEdit.S_CHANGED.add(onTitleChange);
				scrollPanel.addObject(titleEdit);
			}
			
			titleEdit.draw(_width - buttonPaddingLeft * 2);
			titleEdit.value = chatModel.title;
			titleEdit.x = buttonPaddingLeft;
			titleEdit.y = position;
		}
		
		private function drawAvatarButton(position:int, iconImage:Shape = null):void 
		{
			channelAvatarButton.x = buttonPaddingLeft;
			channelAvatarButton.y = position;
			
			if (iconImage)
			{
				channelAvatarButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.channelImage, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null,
																			settingsIconPosition, 
																			settingsTextPosition, 
																			iconImage,
																			null), true);
				
				
				return;
			}
			
			if (chatModel.avatarURL)
			{
				ImageManager.loadImage(chatModel.avatarURL, onChannelAvatarLoaded);
			}
			else
			{
				drawAvatarButton(position, createColorCircle(0xc4def1, avatarSize));
			}
		}
		
		private function onChannelAvatarLoaded(url:String, bmd:BitmapData, success:Boolean):void
		{
			if (!isDisposed)
			{
				if (bmd && success)
				{
					var iconImage:Shape = new Shape();
					ImageManager.drawGraphicCircleImage(
										iconImage.graphics, 
										avatarSize, 
										avatarSize, 
										avatarSize, 
										bmd, 
										ImageManager.SCALE_PORPORTIONAL);
					drawAvatarButton(channelAvatarButton.y, iconImage);
				}
				else
				{
					drawAvatarButton(channelAvatarButton.y, createColorCircle(0xc4def1, avatarSize));
				}
			}
		}
		
		private function drawNotificationsOption(position:int):void 
		{
			optionNotifications.iconPosition = settingsIconPosition;
			optionNotifications.textPosition = settingsTextPosition;
			var notificationIconBD:ImageBitmapData = UI.renderAsset(new SWFSettingsIcon_notification(), iconSize, iconSize, true, "ChannelSettingsScreen.NotificationsControlIcon");
			optionNotifications.create(FIT_WIDTH, OPTION_LINE_HEIGHT, notificationIconBD, Lang.textNotifications, chatModel.getPushAllowed());
			optionNotifications.y = position;
			optionNotifications.x = buttonPaddingLeft;
			notificationIconBD = null;
		}
		
		private function drawChannelModeButton(position:int):void 
		{
			var icon:ModeIcon = new ModeIcon();
			var icon2:ChoiseIcon = new ChoiseIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.scaleToFit(icon2, iconSize, iconSize);
			
			updateModeControlStatus();
			
			channelModeButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.textMode, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			new TextFieldSettings(getChannelMode(), AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT), 
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			icon2), true);
			channelModeButton.x = buttonPaddingLeft;
			channelModeButton.y = position;
			
			UI.destroy(icon);
			UI.destroy(icon2);
			icon = null;
			icon2 = null;
		}
		
		private function updateModeControlStatus():void 
		{
			if (isDisposed || !isActivated)
			{
				return;
			}
			
			if (chatModel.settings.mode == ChannelsManager.CHANNEL_MODE_NONE && !chatModel.isOwner(Auth.uid))
			{
				channelModeButton.deactivate();
			}
			else
			{
				channelModeButton.activate();
			}
		}
		
		private function getChannelMode():String
		{
			switch(chatModel.settings.mode)
			{
				case ChannelsManager.CHANNEL_MODE_ALL:
				{
					return Lang.textAll;
					break;
				}
				case ChannelsManager.CHANNEL_MODE_MODERATORS:
				{
					return Lang.textModerators;
					break;
				}
				case ChannelsManager.CHANNEL_MODE_NONE:
				{
					return Lang.textOwner;
					break;
				}
				default:
				{
					return Lang.textAll;
					break;
				}
			}	
		}
		
		private function drawAddBotButton(position:int):void {
			var icon:AddUserToChatIcon = new AddUserToChatIcon();
			var icon2:IconArrowRight = new IconArrowRight();
			
			UI.scaleToFit(icon, iconSize, iconSize);
			var iconArrowSize:int = Config.FINGER_SIZE * 0.30;
			UI.scaleToFit(icon2, iconArrowSize, iconArrowSize);
			UI.colorize(icon, 0x91A0AC);
			UI.colorize(icon2, 0x91A0AC);
			addBotButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.addBotToChat, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null, 
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			icon2), true);
			addBotButton.x = buttonPaddingLeft;
			addBotButton.y = position;
			
			UI.destroy(icon);
			UI.destroy(icon2);
			icon = null;
			icon2 = null;
		}
		
		private function drawChannelInfoButton(position:int):void 
		{
			var icon:InfoIcon = new InfoIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			channelInfoButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.aboutChannel, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null, 
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			null), true);
			channelInfoButton.x = buttonPaddingLeft;
			channelInfoButton.y = position;
			
			UI.destroy(icon);
			icon = null;
		}
		
		override public function onBack(e:Event = null):void{
			
			if (data && data.backScreen != undefined && data.backScreen != null) {
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function createView():void
		{
			super.createView();
			
			iconSize = Config.FINGER_SIZE * 0.4;
			buttonPaddingLeft = Config.MARGIN * 2;
			
			//scroller component;
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			_view.addChild(scrollPanel.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			channelInfoButton = new BitmapButton();
			channelInfoButton.setStandartButtonParams();
			channelInfoButton.setDownScale(1);
			channelInfoButton.setDownColor(0xFFFFFF);
			channelInfoButton.tapCallback = editChannelInfo;
			channelInfoButton.disposeBitmapOnDestroy = true;
			channelInfoButton.usePreventOnDown = false;
			channelInfoButton.cancelOnVerticalMovement = true;
			channelInfoButton.show();
			scrollPanel.addObject(channelInfoButton);
			
			channelModeButton = new BitmapButton();
			channelModeButton.setStandartButtonParams();
			channelModeButton.setDownScale(1);
			channelModeButton.setDownColor(0xFFFFFF);
			channelModeButton.tapCallback = editChannelMode;
			channelModeButton.disposeBitmapOnDestroy = true;
			channelModeButton.usePreventOnDown = false;
			channelModeButton.cancelOnVerticalMovement = true;
			channelModeButton.show();
			scrollPanel.addObject(channelModeButton);
			
			addBotButton = new BitmapButton();
			addBotButton.setStandartButtonParams();
			addBotButton.setDownScale(1);
			addBotButton.setDownColor(0xFFFFFF);
			addBotButton.tapCallback = onAddBotCalled;
			addBotButton.disposeBitmapOnDestroy = true;
			addBotButton.usePreventOnDown = false;
			addBotButton.cancelOnVerticalMovement = true;
			addBotButton.show();
			scrollPanel.addObject(addBotButton);
			
			optionNotifications = new OptionSwitcherCustomLayout();
			scrollPanel.addObject(optionNotifications);
			optionNotifications.onSwitchCallback = changePushNotifications;
			
			var hLineBitmapData:ImageBitmapData = new ImageBitmapData("ChannelSettingsScreen.hLine", 1, 1, false, AppTheme.GREY_LIGHT);
			line1 = new Bitmap(hLineBitmapData);
			scrollPanel.addObject(line1);
			
			line2 = new Bitmap(hLineBitmapData);
			scrollPanel.addObject(line2);
			hLineBitmapData = null;
			
			
			channelBackButton = new BitmapButton();
			channelBackButton.setStandartButtonParams();
			channelBackButton.setDownScale(1);
			channelBackButton.setDownColor(0xFFFFFF);
			channelBackButton.tapCallback = changeBackground;
			channelBackButton.disposeBitmapOnDestroy = true;
			channelBackButton.usePreventOnDown = false;
			channelBackButton.cancelOnVerticalMovement = true;
			channelBackButton.show();
			scrollPanel.addObject(channelBackButton);
			
			
			channelAvatarButton = new BitmapButton();
			channelAvatarButton.setStandartButtonParams();
			channelAvatarButton.setDownScale(1);
			channelAvatarButton.setDownColor(0xFFFFFF);
			channelAvatarButton.tapCallback = changeAvatar;
			channelAvatarButton.disposeBitmapOnDestroy = true;
			channelAvatarButton.usePreventOnDown = false;
			channelAvatarButton.cancelOnVerticalMovement = true;
			channelAvatarButton.show();
			scrollPanel.addObject(channelAvatarButton);
			
			
			channelCoverButton = new BitmapButton();
			channelCoverButton.setStandartButtonParams();
			channelCoverButton.setDownScale(1);
			channelCoverButton.setDownColor(0xFFFFFF);
			channelCoverButton.tapCallback = changeCoverImage;
			channelCoverButton.disposeBitmapOnDestroy = true;
			channelCoverButton.usePreventOnDown = false;
			channelCoverButton.cancelOnVerticalMovement = true;
			channelCoverButton.show();
			scrollPanel.addObject(channelCoverButton);
			
			
			closeChannelButton = new BitmapButton();
			closeChannelButton.setStandartButtonParams();
			closeChannelButton.setDownScale(1);
			closeChannelButton.setDownColor(0xFFFFFF);
			closeChannelButton.tapCallback = closeChannel;
			closeChannelButton.disposeBitmapOnDestroy = true;
			closeChannelButton.usePreventOnDown = false;
			closeChannelButton.cancelOnVerticalMovement = true;
			closeChannelButton.show();
			scrollPanel.addObject(closeChannelButton);
			
			preloader = new Preloader();
			_view.addChild(preloader);
			
			preloader.hide();
			preloader.visible = false;
		}
		
		private function closeChannel():void {
			channelUID = chatModel.uid;
			DialogManager.alert(Lang.textConfirm, Lang.alertConfirmCloseChannel, 
					function(val:int):void {
						if (val != 1)
							return;
						deactivateScreen();
						if(chatModel!=null)
							ChannelsManager.deleteChannel(chatModel.uid, onChannelRemoveResponse);
					}, Lang.textYes.toUpperCase(), Lang.textCancel.toUpperCase());
		}
		
		private function onChannelRemoveResponse(success:Boolean, channelUID:String, errorMessage:String = null):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (this.channelUID == channelUID)
			{
				if (success)
				{
					var backScreen:Class = RootScreen;
					var backScreenData:Object;
					
					if (this.data != null && ("backScreenData" in this.data) && this.data.backScreenData != null )
					{
						if (("backScreenData" in this.data.backScreenData) && this.data.backScreenData.backScreenData != null )
						{
							if (("backScreen" in this.data.backScreenData.backScreenData) && this.data.backScreenData.backScreenData.backScreen != null)
							{
								backScreen = this.data.backScreenData.backScreenData.backScreen;
								
								if (("backScreenData" in this.data.backScreenData.backScreenData) && this.data.backScreenData.backScreenData.backScreenData != null)
								{
									backScreenData = this.data.backScreenData.backScreenData.backScreenData;
								}
							}
						}
					}
					
					MobileGui.changeMainScreen(backScreen, backScreenData);
				}
				else
				{
					activateScreen();
					ToastMessage.display(errorMessage);
				}
			}
		}
		
		private function onTitleChange():void 
		{
			if (titleEdit.value == chatModel.title)
			{
				return;
			}
			
			var responseResolver:ResponseResolver = new ResponseResolver();
			responseResolver.callback = onChatTitleChangeResponse;
			responseResolver.data = { title:chatModel.title, chatUID:chatModel.uid };
			
			chatModel.title = titleEdit.value;
			
			ChannelsManager.channelChangeTitle(responseResolver, chatModel.uid, Base64.encode(titleEdit.value));
		}
		
		private function onChatTitleChangeResponse(success:Boolean, requestData:Object = null):void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			if (success)
			{
				ChannelsManager.channelTitleChanged(chatModel.uid, chatModel.title);
			}
			else {
				if (requestData != null && "title" in requestData) {
					chatModel.title = requestData.title;
					titleEdit.value = chatModel.title;
				}
			}
		}
		
		private function changeCoverImage():void 
		{
			lockScreen();
			
			changeCoverImageSequence = new ActionsSequence(onCoverChangeSuccess, onCoverChangeFail);
			
			var selectImageAction:IAction = new SelectImageAction();
			var previewImageAction:IAction = new CropImageAction(1242, 496, 0.4);
			var uploadChannelBackgroundAction:IAction = new UploadPublicImageAction();
			var saveCoverUIDAction:IAction = new UpdateChannelSettingsAction(chatModel.uid, ChannelsManager.CHANNEL_SETTINGS_COVER);
			
			changeCoverImageSequence.addAction(selectImageAction);
			changeCoverImageSequence.addAction(previewImageAction);
			changeCoverImageSequence.addAction(uploadChannelBackgroundAction);
			changeCoverImageSequence.addAction(saveCoverUIDAction);
			
			changeCoverImageSequence.execute();
		}
		
		private function onCoverChangeFail(data:Object):void 
		{
			unlockScreen();
			
			if (data is String)
			{
				ToastMessage.display(data as String);
			}
			changeCoverImageSequence.dispose();
			changeCoverImageSequence = null;
		}
		
		private function onCoverChangeSuccess(data:Object):void 
		{
			unlockScreen();
			
			if (data && (data is String))
			{
				chatModel.settings.cover = String(data);
				drawCoverButton(channelCoverButton.y);
			}
			
			drawCoverButton(channelCoverButton.y);
			
			changeCoverImageSequence.dispose();
			changeCoverImageSequence = null;
		}
		
		
		private function changeAvatar():void 
		{
			lockScreen();
			
			changeAvatarSequence = new ActionsSequence(onAvatarChangeSuccess, onAvatarChangeFail);
			
			var selectImageAction:IAction = new SelectImageAction();
			var previewImageAction:IAction = new CropImageAction(Config.CHAT_AVATAR_SIZE_MAX, Config.CHAT_AVATAR_SIZE_MAX, 1);
			var uploadChannelBackgroundAction:IAction = new UploadChannelAvatarAction(chatModel.uid);
			
			changeAvatarSequence.addAction(selectImageAction);
			changeAvatarSequence.addAction(previewImageAction);
			changeAvatarSequence.addAction(uploadChannelBackgroundAction);
			
			changeAvatarSequence.execute();
		}
		
		private function onAvatarChangeFail(data:Object):void 
		{
			unlockScreen();
			
			if (data is String)
			{
				ToastMessage.display(data as String);
			}
			changeAvatarSequence.dispose();
			changeAvatarSequence = null;
		}
		
		private function onAvatarChangeSuccess(data:Object):void 
		{
			unlockScreen();
			
			if (data != null && (data is String) && (data as String) != "")
			{
				chatModel.avatar = Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + String(data);
				drawAvatarButton(channelAvatarButton.y);
				
				ChannelsManager.channelAvatarChanged(chatModel.uid, chatModel.avatar);
			}
			changeAvatarSequence.dispose();
			changeAvatarSequence = null;
		}
		
		private function changeBackground():void 
		{
			lockScreen();
			
			changeBackgroundSequence = new ActionsSequence(onBackgroundChangeSuccess, onBackgroundChangeFail);
			
			var selectImageAction:IAction = new SelectImageAction();
			var previewImageAction:IAction = new CropImageAction(1242, 2400, 1.93);
			var uploadChannelBackgroundAction:IAction = new UploadPublicImageAction();
			var saveBackgroundUIDAction:IAction = new UpdateChannelSettingsAction(chatModel.uid, ChannelsManager.CHANNEL_SETTINGS_BACKGROUND);
			
			changeBackgroundSequence.addAction(selectImageAction);
			changeBackgroundSequence.addAction(previewImageAction);
			changeBackgroundSequence.addAction(uploadChannelBackgroundAction);
			changeBackgroundSequence.addAction(saveBackgroundUIDAction);
			
			changeBackgroundSequence.execute();
		}
		
		private function onBackgroundChangeFail(data:Object):void 
		{
			unlockScreen();
			
			if (data is String)
			{
				ToastMessage.display(data as String);
			}
			changeBackgroundSequence.dispose();
			changeBackgroundSequence = null;
		}
		
		private function onBackgroundChangeSuccess(data:Object):void 
		{
			unlockScreen();
			
			if (data && (data is String))
			{
				chatModel.settings.background = String(data);
				drawAvatarButton(channelAvatarButton.y);
				
				drawBackgroundButton(channelBackButton.y);
				
				ChannelsManager.channelBackgroundChanged(chatModel.uid, chatModel.settings.background);
			}
			
			changeBackgroundSequence.dispose();
			changeBackgroundSequence = null;
		}
		
		private function lockScreen():void
		{
			locked = true;
			displayPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void
		{
			locked = false;
			hidePreloader();
			activateScreen();
		}
		
		private function displayPreloader():void
		{
			preloader.x = _width * .5;
			preloader.y = _height*.5;
			preloader.visible = true;
			preloader.show();
		}
		
		private function hidePreloader():void
		{
			preloader.hide();
		}
		
		private function drawBackgroundButton(position:int, iconImage:Shape = null):void 
		{
			channelBackButton.x = buttonPaddingLeft;
			channelBackButton.y = position;
			
			if (iconImage)
			{
				channelBackButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.backgroundImage, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null,
																			settingsIconPosition, 
																			settingsTextPosition, 
																			iconImage,
																			null), true);
				
				
				return;
			}
			
			if (chatModel.settings.background)
				ImageManager.loadImage(chatModel.settings.backgroundThumbURL, onBackgroundImageLoaded);
			else
				drawBackgroundButton(position, createColorCircle(0xc4def1, avatarSize));
		}
		
		private function onBackgroundImageLoaded(url:String, bmd:BitmapData, success:Boolean):void
		{
			if (lastLoadedBackgroundThumbURL)
				ImageManager.unloadImage(lastLoadedBackgroundThumbURL);
			
			if (!isDisposed) {
				if (bmd && success)	{
					lastLoadedBackgroundThumbURL = url;
					
					var iconImage:Shape = new Shape();
					ImageManager.drawGraphicCircleImage(
										iconImage.graphics, 
										avatarSize, 
										avatarSize, 
										avatarSize, 
										bmd, 
										ImageManager.SCALE_PORPORTIONAL);
					drawBackgroundButton(channelBackButton.y, iconImage);
				}
				else {
					drawBackgroundButton(channelBackButton.y, createColorCircle(0xc4def1, avatarSize));
				}
			}
			else {
				ImageManager.unloadImage(url);
			}
		}
		
		private function drawCoverButton(position:int, iconImage:Shape = null):void 
		{
			channelCoverButton.x = buttonPaddingLeft;
			channelCoverButton.y = position;
			
			if (iconImage)
			{
				channelCoverButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.coverImage, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null,
																			settingsIconPosition, 
																			settingsTextPosition, 
																			iconImage,
																			null), true);
				
				
				return;
			}
			
			if (chatModel.settings.cover)
			{
				//!TODO:
				ImageManager.loadImage(chatModel.settings.coverURL, 
					function(url:String, bmd:BitmapData, success:Boolean):void
					{
						if (!isDisposed)
						{
							if (bmd && success)
							{
								var iconImage:Shape = new Shape();
								ImageManager.drawGraphicCircleImage(
													iconImage.graphics, 
													avatarSize, 
													avatarSize, 
													avatarSize, 
													bmd, 
													ImageManager.SCALE_PORPORTIONAL);
								drawCoverButton(position, iconImage);
							}
							else
							{
								drawCoverButton(position, createColorCircle(0xc4def1, avatarSize));
							}
						}
					});
			}
			else
			{
				drawCoverButton(position, createColorCircle(0xc4def1, avatarSize));
			}
		}
		
		private function createColorCircle(color:Number, radius:Number):Shape 
		{
			var result:Shape = new Shape();
			result.graphics.beginFill(color);
			result.graphics.drawCircle(radius, radius, radius);
			result.graphics.endFill();
			
			return result;
		}
		
		private function editChannelMode():void 
		{
			var menuItems:Array = new Array();
			
			menuItems.push( { fullLink:Lang.textAll, id:ChannelsManager.CHANNEL_MODE_ALL } );
			menuItems.push( { fullLink:Lang.textModerators, id:ChannelsManager.CHANNEL_MODE_MODERATORS } );
			menuItems.push( { fullLink:Lang.textOwner, id:ChannelsManager.CHANNEL_MODE_NONE } );
			
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void
			{
				if (data.id == -1)
				{
					return;
				}
				var newMode:String = data.id;
				
				saveChatMode(chatModel.settings.mode, newMode);
				
			}, data:menuItems, itemClass:ListLink, title:Lang.textMode});
		}
		
		private function editChannelInfo():void 
		{
			currentTextEditor = new FullscreenTextEditor();
			currentTextEditor.editText(chatModel.settings.info, onInfoEditResult);
		}
		
		private function onInfoEditResult(isAccepted:Boolean, result:String = null):void
		{
			if (isAccepted)
			{
				saveChatInfo(chatModel.settings.info, result);
			}
			currentTextEditor.dispose();
			currentTextEditor = null;
		}
		
		private function saveChatMode(oldValue:String, newValue:String):void 
		{
			if (oldValue == newValue)
			{
				return;
			}
			
			chatModel.settings.mode = newValue;
			drawChannelModeButton(channelModeButton.y);
			
			/*var responseResolver:ResponseResolver = new ResponseResolver();
			responseResolver.callback = onChatModeChangeResponse;
			responseResolver.data = oldValue;*/
			ChannelsManager.updateChannelMode(chatModel.uid, newValue);
		}
		
		/*private function onChatModeChangeResponse(success:Boolean, requestData:Object = null):void
		{
			if (_isDisposed)
			{
				return;
			}
			
			if (success)
			{
				ChannelManager.channelModeChanged(chatModel.uid, chatModel.settings.mode);
			}
			else
			{
				ToastMessage.display(Lang.failedUpdateChannelMode);
				
				if (requestData && (requestData is String))
				{
					chatModel.settings.mode = requestData as String;
					drawChannelModeButton(channelModeButton.y);
				}
			}
		}*/
		
		private function saveChatInfo(oldValue:String, newValue:String):void 
		{
			if (oldValue == newValue)
			{
				return;
			}
			
			var responseResolver:ResponseResolver = new ResponseResolver();
			responseResolver.callback = onChatInfoChangeResponse;
			responseResolver.data = oldValue;
			
			chatModel.settings.info = newValue;
			
			ChannelsManager.updateChannelSettings(responseResolver, chatModel.uid, ChannelsManager.CHANNEL_SETTINGS_INFO, Base64.encode(newValue));
		}
		
		private function onChatInfoChangeResponse(success:Boolean, requestData:Object = null):void
		{
			if (_isDisposed)
			{
				return;
			}
			
			if (success)
			{
				
			}
			else
			{
				ToastMessage.display(Lang.failedUpdateChannelInfo);
				
				if (requestData && (requestData is String))
				{
					chatModel.settings.info = requestData as String;
				}
			}
		}
		
		private function changePushNotifications(value:Boolean):void 
		{
			ChatManager.changeChatPushNotificationsStatus(chatModel.uid, value);
		}
		
		override protected function drawView():void
		{
			if (currentTextEditor)
			{
				currentTextEditor.setSize(_width, _height);	
			}
			topBar.drawView(_width);
			scrollPanel.view.y =  topBar.trueHeight;
			scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight, false);
			
			/*if (!scrollPanel.fitInScrollArea())
			{
				if (!scrollPanel.isItemVisible(chartTitleContailer))
				{
					scrollPanel.scrollToPosition(scrollPanel.itemsHeight - chartTitleContailer.y + Config.MARGIN + chatTitle.view.height - scrollPanel.height);
				}
				
				scrollPanel.enable();
			}
			else {
				scrollPanel.disable();
			}*/
			
			scrollPanel.update();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			chatModel = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (currentTextEditor)
			{
				currentTextEditor.dispose();
				currentTextEditor = null;
			}
			
			if (line1)
			{
				UI.destroy(line1);
				line1 = null;
			}
			
			if (line2)
			{
				UI.destroy(line2);
				line2 = null;
			}
			if (trashButton)
			{
				trashButton.dispose();
				trashButton = null;
			}
			if (scrollPanel)
			{
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (channelInfoButton)
			{
				channelInfoButton.dispose();
				channelInfoButton = null;
			}
			if (channelModeButton)
			{
				channelModeButton.dispose();
				channelModeButton = null;
			}
			if (optionNotifications)
			{
				optionNotifications.dispose();
				optionNotifications = null;
			}
			if (channelBackButton)
			{
				channelBackButton.dispose();
				channelBackButton = null;
			}
			if (preloader)
			{
				preloader.dispose();
				preloader = null;
			}
			if (uploadingImage)
			{
				uploadingImage.dispose();
				uploadingImage = null;
			}
			if (changeBackgroundSequence)
			{
				changeBackgroundSequence.dispose();
				changeBackgroundSequence = null;
			}
			if (channelAvatarButton)
			{
				channelAvatarButton.dispose();
				channelAvatarButton = null;
			}
			if (changeAvatarSequence)
			{
				changeAvatarSequence.dispose();
				changeAvatarSequence = null;
			}
			if (channelCoverButton)
			{
				channelCoverButton.dispose();
				channelCoverButton = null;
			}
			if (changeCoverImageSequence)
			{
				changeCoverImageSequence.dispose();
				changeCoverImageSequence = null;
			}
			if (titleEdit)
			{
				titleEdit.dispose();
				titleEdit = null;
			}
			if (closeChannelButton)
			{
				closeChannelButton.dispose();
				closeChannelButton = null;
			}
			
			if (lastLoadedBackgroundThumbURL)
			{
				ImageManager.unloadImage(lastLoadedBackgroundThumbURL);
			}
			
			ChannelsManager.S_CHANNEL_MODERATORS_UPDATED.remove(onChannelModeratorChanged);
			ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.remove(onChannelChanged);
			
			chatModel = null;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			if (_isDisposed)
			{
				return;
			}
			
			if (locked)
			{
				return;
			}
			
			if (currentTextEditor)
			{
				return;
			}
				
			if (topBar != null)
				topBar.activate();
				
			if (trashButton != null)
				trashButton.activate();
			
			if (chatModel != null){
				channelInfoButton.activate();
				updateModeControlStatus();
				optionNotifications.activate();
				channelBackButton.activate();
				channelAvatarButton.activate();
				addBotButton.activate();
				channelCoverButton.activate();
				closeChannelButton.activate();
				if (titleEdit != null){
					titleEdit.activate();
				}
			}
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed)
				return;
				
			if (topBar != null)
				topBar.deactivate();		
			
			if (trashButton != null)
				trashButton.deactivate();
			
			channelInfoButton.deactivate();
			channelModeButton.deactivate();
			optionNotifications.deactivate();
			channelBackButton.deactivate();
			channelAvatarButton.deactivate();
			addBotButton.deactivate();
			channelCoverButton.deactivate();
			closeChannelButton.deactivate();
			if (titleEdit != null){
				titleEdit.deactivate();
			}
		}
	}
}