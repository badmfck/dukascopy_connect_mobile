package com.dukascopy.connect.screens.chat {
	
	import assets.ChoiseIcon;
	import assets.InfoIcon;
	import assets.ModeIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.components.selector.MultiSelector;
	import com.dukascopy.connect.gui.components.textEditors.FullscreenTextEditor;
	import com.dukascopy.connect.gui.components.textEditors.TitleTextEditor;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.categories.CategoryManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.hurlant.util.Base64;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class ChannelCreateSettingsScreen extends BaseScreen {
		
		private var topBar:TopBarScreen;
		
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private var iconSize:Number;
		private var buttonPaddingLeft:int;
		private var FIT_WIDTH:int;
		private var backgroundIconHeight:Number;
		private var settingsTextPosition:int;
		private var settingsIconPosition:int;
		private var line1:Bitmap;
		private var uid:String;
		private var scrollPanel:ScrollPanel;
		private var channelInfoButton:BitmapButton;
		private var currentTextEditor:FullscreenTextEditor;
		private var channelModeButton:BitmapButton;
		private var titleEdit:TitleTextEditor;
		private var line2:Bitmap;
		private var preloader:Preloader;
		private var locked:Boolean;
		private var channelInfoText:String = "";
		private var channelMode:String;
		private var okButton:RoundedButton;
		private var cancelButton:RoundedButton;
		private var background:Sprite;
		private var categorySelector:MultiSelector;
		private var categoryTitle:Bitmap;
		private var languageTitle:Bitmap;
		private var languageSelector:MultiSelector;
		private var line1_1:Bitmap;
		private var paidChatSectionBack:Sprite;
		private var paidChatDescription:Bitmap;
		private var paidChatCost:Bitmap;
		private var accounts:PaymentsAccountsProvider;
		private var selectorAccont:DDAccountButton;
		private var currentRequestId:String;
		private var selectedAccount:Object;
		
		public function ChannelCreateSettingsScreen() { }
		
		override public function initScreen(data:Object = null):void {
			
			super.initScreen(data);
			
			accounts = new PaymentsAccountsProvider(onAccountsDataReady);
			
			selectorAccont.setSize(_width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE * .8);
			if (accounts.ready == true)
			{
				onAccountsDataReady();
			}
			else
			{
				accounts.getData();
			}
			
			_params.title = 'Channel create settings screen';
			_params.doDisposeAfterClose = true;
			
			topBar.setData(Lang.channelSettings, true);
			var iconSize:int = Config.FINGER_SIZE * 0.36;
			backgroundIconHeight = Config.FINGER_SIZE * .7;
			settingsIconPosition = int(backgroundIconHeight * .5);
			settingsTextPosition = int(backgroundIconHeight + Config.MARGIN*1.5);
			FIT_WIDTH = _width - buttonPaddingLeft * 2;
			
			channelMode = ChannelsManager.CHANNEL_MODE_ALL;
			
			drawTitleEditor();
			drawChannelInfoButton();
		//	drawChannelModeButton();
			
			
			drawPaidChatSection();
			drawPaidChatSectorBack();
			
			line1.width = _width;
			line1_1.width = _width;
			drawCategoryTitle();
			categorySelector.maxWidth = _width - Config.MARGIN * 4;
			line2.width = _width;
			drawLanguageTitle();
			languageSelector.maxWidth = _width - Config.MARGIN * 4;
			
			cancelButton.setSizeLimits((_width - Config.MARGIN * 6) * .5, (_width - Config.MARGIN * 6) * .5);
			drawButtonCancel(Lang.textBack);
			
			okButton.setSizeLimits((_width - Config.MARGIN * 6) * .5, (_width - Config.MARGIN * 6) * .5);
			drawButtonOK(Lang.textProceed);
			
			okButton.x = cancelButton.x + cancelButton.getWidth() + Config.MARGIN * 2;
			
			updateElementsYPosition();
			
			CategoryManager.S_CATEGORIES_LOADED.add(onCategoriesLoaded);
			onCategoriesLoaded();
			CategoryManager.loadAllCategories();
			
			
		}
		
		private function onAccountsDataReady():void 
		{
			if (accounts.ready && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
			{
				selectedAccount = accounts.coinsAccounts[accounts.coinsAccounts.length - 1];
				selectorAccont.setValue(selectedAccount);
			}
		}
		
		private function drawPaidChatSectorBack(expand:Boolean = false):void 
		{
			paidChatSectionBack.width = _width;
			paidChatSectionBack.height = Config.DOUBLE_MARGIN * 3 + paidChatDescription.height + paidChatCost.height + Config.MARGIN + selectorAccont.height;
		}
		
		private function drawPaidChatSection():void 
		{
			if (paidChatDescription.bitmapData != null)
			{
				paidChatDescription.bitmapData.dispose();
				paidChatDescription.bitmapData = null;
			}
			
			paidChatDescription.bitmapData = TextUtils.createTextFieldData(
																	Lang.paidChannelDescription, 
																	_width - Config.DIALOG_MARGIN * 2, 
																	10, true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	true, 0x7B8EA1, 0xFFFFFF, true);
			
			if (paidChatCost.bitmapData != null)
			{
				paidChatCost.bitmapData.dispose();
				paidChatCost.bitmapData = null;
			}
			
			paidChatCost.bitmapData = TextUtils.createTextFieldData(
																	Lang.paidChannelCost, 
																	_width - Config.DIALOG_MARGIN * 2, 
																	10, true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .34, 
																	true, 0x6B7C8C, 0xFFFFFF, true);
		}
		
		private function updateElementsYPosition():void 
		{
			var position:int = Config.MARGIN;
			
			titleEdit.y = position;
				position += OPTION_LINE_HEIGHT + Config.MARGIN;
			
			channelInfoButton.y = position;
				position += OPTION_LINE_HEIGHT;
			
			/*channelModeButton.y = position;
				position += OPTION_LINE_HEIGHT + Config.MARGIN;*/
			
			line1.y = position;
			
			if (Shop.isPaidChannelsAvaliable())
			{
				paidChatSectionBack.y = position + line1.height;
					position += Config.DOUBLE_MARGIN;
				
				paidChatDescription.y = position;
					position += paidChatDescription.height + Config.DOUBLE_MARGIN;
					
				paidChatCost.y = position;
					position += paidChatCost.height + Config.MARGIN;
					
				selectorAccont.y = position;
					position += selectorAccont.height + Config.DOUBLE_MARGIN;
				
				line1_1.y = position;
					position += Config.DOUBLE_MARGIN;
			}
			else {
				position += Config.DOUBLE_MARGIN;
			}
			
			categoryTitle.y = position;
				position += categoryTitle.height + Config.DOUBLE_MARGIN;
			
			categorySelector.y = position;
				position += categorySelector.height + Config.DOUBLE_MARGIN;
			
			line2.y = position;
				position += Config.DOUBLE_MARGIN;
			
			languageTitle.y = position;
				position += languageTitle.height + Config.DOUBLE_MARGIN;
			
			languageSelector.y = position;
				position += languageSelector.height + Config.DOUBLE_MARGIN;
		}
		
		private function drawCategoryTitle():void 
		{
			if (categoryTitle.bitmapData != null)
			{
				categoryTitle.bitmapData.dispose();
				categoryTitle.bitmapData = null;
			}
			
			categoryTitle.bitmapData = 	TextUtils.createTextFieldData(
																		Lang.pleaseSelectCategoryChannel, 
																		_width, 
																		10, 
																		false, 
																		TextFormatAlign.LEFT, 
																		TextFieldAutoSize.LEFT, 
																		Config.FINGER_SIZE * .25, 
																		false, 
																		AppTheme.GREY_MEDIUM, 
																		0xFFFFF, 
																		true);
		
		}
		
		private function drawLanguageTitle():void 
		{
			if (languageTitle.bitmapData != null)
			{
				languageTitle.bitmapData.dispose();
				languageTitle.bitmapData = null;
			}
			
			languageTitle.bitmapData = 	TextUtils.createTextFieldData(
																		Lang.pleaseSelectLanguageChannel, 
																		_width, 
																		10, 
																		false, 
																		TextFormatAlign.LEFT, 
																		TextFieldAutoSize.LEFT, 
																		Config.FINGER_SIZE * .25, 
																		false, 
																		AppTheme.GREY_MEDIUM, 
																		0xFFFFF, 
																		true);
		
		}
		
		private function drawButtonCancel(text:String):void
		{
			cancelButton.setValue(text);
			cancelButton.draw();
			cancelButton.y = _height - Config.MARGIN - cancelButton.getHeight() - Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function drawButtonOK(text:String):void
		{
			okButton.setValue(text);
			okButton.draw();
			okButton.y = _height - Config.MARGIN - okButton.getHeight() - Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function drawTitleEditor():void 
		{
			titleEdit.draw(_width - buttonPaddingLeft * 2);
			titleEdit.prompt = Lang.enterChannelTitle;
			titleEdit.x = buttonPaddingLeft;
		}
		
		private function drawChannelModeButton():void 
		{
			var icon:ModeIcon = new ModeIcon();
			var icon2:ChoiseIcon = new ChoiseIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.scaleToFit(icon2, iconSize, iconSize);
			
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
			
			UI.destroy(icon);
			UI.destroy(icon2);
			icon = null;
			icon2 = null;
		}
		
		private function getChannelMode():String
		{
			switch(channelMode)
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
		
		private function drawChannelInfoButton():void 
		{
			var icon:InfoIcon = new InfoIcon();
			UI.scaleToFit(icon, iconSize, iconSize);
			channelInfoButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.addDescription, AppTheme.GREY_DARK, Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null, 
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			null), true);
			channelInfoButton.x = buttonPaddingLeft;
			
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
			
			background = new Sprite();
			_view.addChild(background);
			
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
			
			var hLineBitmapData:ImageBitmapData = new ImageBitmapData("ChannelSettingsScreen.hLine", 1, 1, false, AppTheme.GREY_SEMI_LIGHT);
			line1 = new Bitmap(hLineBitmapData);
			scrollPanel.addObject(line1);
			
			line1_1 = new Bitmap(hLineBitmapData);
			scrollPanel.addObject(line1_1);
			
			line2 = new Bitmap(hLineBitmapData);
			scrollPanel.addObject(line2);
			hLineBitmapData = null;
			
			titleEdit = new TitleTextEditor();
			titleEdit.S_CHANGED.add(onTitleChange);
			scrollPanel.addObject(titleEdit);
			
			paidChatSectionBack = new Sprite()
			paidChatSectionBack.graphics.beginFill(0x5B606B, 0.05);
			paidChatSectionBack.graphics.drawRect(0, 0, 10, 10);
			paidChatSectionBack.graphics.endFill();
			scrollPanel.addObject(paidChatSectionBack);
			
			paidChatDescription = new Bitmap();
			scrollPanel.addObject(paidChatDescription);
			paidChatDescription.x = Config.DIALOG_MARGIN;
			
			paidChatCost = new Bitmap();
			scrollPanel.addObject(paidChatCost);
			paidChatCost.x = Config.DIALOG_MARGIN;
			
			// selector
			categorySelector = new MultiSelector();
			categorySelector.gap = Config.FINGER_SIZE*.15;
			categorySelector.S_ON_SELECT.add(onSelectChannel);
			scrollPanel.addObject(categorySelector);
			categorySelector.x = Config.DOUBLE_MARGIN;
			
			languageSelector = new MultiSelector();
			languageSelector.gap = Config.FINGER_SIZE*.15;
			languageSelector.S_ON_SELECT.add(onSelectChannel);
			scrollPanel.addObject(languageSelector);
			languageSelector.x = Config.DOUBLE_MARGIN;
			
			preloader = new Preloader();
			_view.addChild(preloader);
			
			preloader.hide();
			preloader.visible = false;
			
			okButton = new RoundedButton("", 0x7BC247, 0x7BC247, null, Config.FINGER_SIZE*.1, 0, Config.FINGER_SIZE, Config.FINGER_SIZE*.38);
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.cancelOnVerticalMovement = true;
			okButton.tapCallback = onButtonOkClick;
			_view.addChild(okButton);
			
			cancelButton = new RoundedButton("", 0x93A2AE, 0x93A2AE, null, Config.FINGER_SIZE*.1, 0, Config.FINGER_SIZE, Config.FINGER_SIZE*.38);
			cancelButton.setStandartButtonParams();
			cancelButton.setDownScale(1);
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.tapCallback = onButtonCancelClick;
			_view.addChild(cancelButton);
			cancelButton.x = Config.MARGIN * 2;
			
			categoryTitle = new Bitmap();
			scrollPanel.addObject(categoryTitle);
			categoryTitle.x = Config.MARGIN * 2;
			
			languageTitle = new Bitmap();
			scrollPanel.addObject(languageTitle);
			languageTitle.x = Config.MARGIN * 2;
			
			selectorAccont = new DDAccountButton(null, null, false);
			scrollPanel.addObject(selectorAccont);
			selectorAccont.x = Config.DOUBLE_MARGIN;
		}
		
		private function onSelectChannel(value:SelectorItemData):void
		{
			
		}
		
		private function onButtonCancelClick():void
		{
			onBack();
		}
		
		private function onButtonOkClick():void
		{
			if (selectedAccount == null)
			{
				return;
			}
			
			var categories:Array;
			var values:Vector.<SelectorItemData> = categorySelector.getSelectedDataVector();
			var l:int = values.length;
			if (l > 0)
			{
				categories = new Array();
				for (var i:int = 0; i < l; i++) 
				{
					categories.push(values[i].data.id);
				}
			}
			
			var languages:Array;
			values = languageSelector.getSelectedDataVector();
			var l2:int = values.length;
			if (l2 > 0)
			{
				languages = new Array();
				for (var i2:int = 0; i2 < l2; i2++) 
				{
					languages.push(values[i2].data.name);
				}
			}
			
			var title:String;
			if (titleEdit.value != titleEdit.prompt)
			{
				title = Base64.encode(titleEdit.value);
			}
			
			var mode:String = channelMode;
			var chanelInfo:String;
			if (channelInfoText != null)
			{
				chanelInfo = Base64.encode(channelInfoText);
			}
			
			var settingsValues:Object = new Object();
			
			if (categories != null && categories.length > 0)
			{
				settingsValues[ChannelsManager.CHANNEL_SETTINGS_CATEGORIES] = categories.join(",");
			}
			
			if (languages != null && languages.length > 0)
			{
				settingsValues[ChannelsManager.CHANNEL_SETTINGS_LANGUAGES] = languages.join(",");
			}
			
			if (chanelInfo != null && chanelInfo != "")
			{
				settingsValues[ChannelsManager.CHANNEL_SETTINGS_INFO] = chanelInfo;
			}
			
			mode = ChannelsManager.CHANNEL_MODE_MODERATORS;
			
			currentRequestId = generateID();
			
			//!TODO:;
			ChannelsManager.S_CHANNEL_UPDATED
			
			
			ChannelsManager.startNewChannel(currentRequestId, (selectedAccount != null) ? selectedAccount.ACCOUNT_NUMBER : null, title, mode, settingsValues);
		}
		
		private function generateID():String 
		{
			return Math.random().toString();
		}
		
		private function onTitleChange():void 
		{
			
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
		
		private function onCategoriesLoaded():void
		{
			categorySelector.dataProvider = CategoryManager.getCategoriesArrayFiltered();
			languageSelector.dataProvider = CategoryManager.getLanguagesArrayFiltered();
			
			if (_isActivated)
			{
				categorySelector.activate();
				languageSelector.activate();
			}
			
			updateElementsYPosition();
			
			scrollPanel.update();
		}
		
		private function editChannelMode():void 
		{
			var menuItems:Array = new Array();
			
			menuItems.push( { fullLink:Lang.textAll,          id:ChannelsManager.CHANNEL_MODE_ALL } );
			menuItems.push( { fullLink:Lang.textModerators,   id:ChannelsManager.CHANNEL_MODE_MODERATORS } );
			menuItems.push( { fullLink:Lang.textOwner,        id:ChannelsManager.CHANNEL_MODE_NONE } );
			
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void
			{
				if (data.id == -1)
				{
					return;
				}
				channelMode = data.id;
				drawChannelModeButton();
			}, data:menuItems, itemClass:ListLink, title:Lang.textMode});
		}
		
		private function editChannelInfo():void 
		{
			currentTextEditor = new FullscreenTextEditor();
			currentTextEditor.editText(channelInfoText, onInfoEditResult);
		}
		
		private function onInfoEditResult(isAccepted:Boolean, result:String = null):void
		{
			channelInfoText = result;
			currentTextEditor.dispose();
			currentTextEditor = null;
			activateScreen();
		}
		
		override protected function drawView():void
		{
			if (currentTextEditor)
			{
				currentTextEditor.setSize(_width, _height);	
			}
			
			background.graphics.clear();
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height - topBar.trueHeight);
			background.y = topBar.trueHeight;
			
			topBar.drawView(_width);
			scrollPanel.view.y =  topBar.trueHeight;
			
			scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight - cancelButton.getHeight() - Config.MARGIN * 3 - Config.APPLE_BOTTOM_OFFSET, false);
			
			scrollPanel.update();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			CategoryManager.S_CATEGORIES_LOADED.remove(onCategoriesLoaded);
			
			if (paidChatSectionBack != null)
			{
				UI.destroy(paidChatSectionBack);
				paidChatSectionBack = null;
			}
			if (paidChatDescription != null)
			{
				UI.destroy(paidChatDescription);
				paidChatDescription = null;
			}
			if (paidChatCost != null)
			{
				UI.destroy(paidChatCost);
				paidChatCost = null;
			}
			if (accounts != null)
			{
				accounts.dispose();
				accounts = null;
			}
			if (selectorAccont != null)
			{
				selectorAccont.dispose();
				selectorAccont = null;
			}
			
			selectedAccount = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (currentTextEditor != null)
			{
				currentTextEditor.dispose();
				currentTextEditor = null;
			}
			if (line1 != null)
			{
				UI.destroy(line1);
				line1 = null;
			}
			if (line1_1 != null)
			{
				UI.destroy(line1_1);
				line1_1 = null;
			}
			if (line2 != null)
			{
				UI.destroy(line2);
				line2 = null;
			}
			if (scrollPanel != null)
			{
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (channelInfoButton != null)
			{
				channelInfoButton.dispose();
				channelInfoButton = null;
			}
			if (channelModeButton != null)
			{
				channelModeButton.dispose();
				channelModeButton = null;
			}
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
			if (titleEdit != null)
			{
				titleEdit.dispose();
				titleEdit = null;
			}
			if (cancelButton != null)
			{
				cancelButton.dispose();
				cancelButton = null;
			}
			if (okButton != null)
			{
				okButton.dispose();
				okButton = null;
			}
			if (background != null)
			{
				UI.destroy(background);
				background = null;
			}
			if (categorySelector != null)
			{
				categorySelector.dispose();
				categorySelector = null;
			}
			if (languageSelector != null)
			{
				languageSelector.dispose();
				languageSelector = null;
			}
			if (categoryTitle)
			{
				UI.destroy(categoryTitle);
				categoryTitle = null;
			}
			if (languageTitle)
			{
				UI.destroy(languageTitle);
				languageTitle = null;
			}
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
			channelModeButton.activate();
			channelInfoButton.activate();
			okButton.activate();
			cancelButton.activate();
			titleEdit.activate();
			categorySelector.activate();
			languageSelector.activate();
			scrollPanel.enable();
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed)
				return;
				
			if (topBar != null)
				topBar.deactivate();	
			
			channelInfoButton.deactivate();
			channelModeButton.deactivate();
			okButton.deactivate();
			cancelButton.deactivate();
			titleEdit.deactivate();
			categorySelector.deactivate();
			languageSelector.deactivate();
			scrollPanel.disable();
		}
	}
}