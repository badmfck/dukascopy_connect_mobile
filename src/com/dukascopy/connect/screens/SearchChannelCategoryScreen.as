package com.dukascopy.connect.screens
{
	
	import assets.PlusIcon;
	import assets.SearchButtonIconWhite;
	import com.adobe.crypto.MD5;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.components.selector.MultiSelector;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.screens.innerScreens.InnerContactScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.userProfile.UserSearchResult;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.categories.CategoryManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.contactsManager.ContactsManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
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
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Alexey Skuryat
	 */
	
	public class SearchChannelCategoryScreen extends BaseScreen
	{
		private var FIT_WIDTH:Number;
		private var max_text_width:int;
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		
		private var title:Bitmap;
		private var bgHeader:Bitmap;
		private var backButton:BitmapButton;
		private var scrollPanel:ScrollPanel;	
		private var buttonPaddingLeft:int;
		private var padding:int=0;
		private var headerSize:int;	
		private var preloader:Preloader;
		
		
		// search input
		// search result list 
		// search result data
		// search request data 
		private var input:Input;
		private var list:List;
		private var lastSearchValue:String = "";
		
		private var channelsSelector:MultiSelector = null;
		
		
		
		/** @CONSTRUCTOR **/
		public function SearchChannelCategoryScreen(){}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			FIT_WIDTH = _width - buttonPaddingLeft * 2;
			scrollPanel.view.y = headerSize + Config.APPLE_TOP_OFFSET;	
			
			_params = new ScreenParams('Main content screen', ScreenParams.TOP_BAR_HIDE);
			_params.title = Lang.textSelectChannels;
			_params.doDisposeAfterClose = true;
				
			// Header plane
			if (bgHeader.bitmapData){
				UI.disposeBMD(bgHeader.bitmapData);
				bgHeader.bitmapData = null;
			}			
			bgHeader.bitmapData = UI.getTopBarLayeredBitmapData(_width, Config.FINGER_SIZE * .85, Config.APPLE_TOP_OFFSET, 0, AppTheme.RED_MEDIUM, AppTheme.RED_DARK, AppTheme.RED_MEDIUM);
				
			// Title 
			if (title.bitmapData != null){
				UI.disposeBMD(title.bitmapData);
				title.bitmapData = null;
			}
			title.visible = true;		
			//title.bitmapData = UI.renderText(params.title, _width - Config.FINGER_SIZE, Config.FINGER_SIZE, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .38, false, 0xffffff, 0, true);
			title.x = int(Config.FINGER_SIZE);
			title.y = Config.APPLE_TOP_OFFSET + int((Config.FINGER_SIZE * .85 - title.height) * .5);
			
			// delayed on show complete 	
			input.view.y = Config.APPLE_TOP_OFFSET;// headerSize + int((Config.FINGER_SIZE - input.view.height) * .5);
			input.view.x = int(Config.FINGER_SIZE);// backButton.x + backButton.width +Config.DOUBLE_MARGIN;
			
			// List 
			//list.view.y = headerSize + Config.APPLE_TOP_OFFSET;
			//list.setWidthAndHeight(_width, _height - headerSize- Config.APPLE_TOP_OFFSET);
			
			//Selector
			drawSelector(Config.FINGER_SIZE_DOT_25);
			CategoryManager.S_CATEGORIES_LOADED.add(onCategoriesLoaded);
			onCategoriesLoaded();
			// add preloader 
			CategoryManager.loadAllCategories();
			
			
		}
		
		
		override public function onBack(e:Event = null):void {
			if (data && data.backScreen != undefined && data.backScreen != null)	{
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		
		override protected function createView():void {
			super.createView();			
			padding = Config.MARGIN * 2;
			buttonPaddingLeft = Config.MARGIN * 2;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = AppTheme.GREY_DARK;
			headerSize = int(Config.FINGER_SIZE * .85);
			var btnSize:int = headerSize * .38;
			var btnY:int = (headerSize - btnSize) * .5;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			// Scroll Panel 
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = MainColors.WHITE;
			_view.addChild(scrollPanel.view);
			
			// List 
			//list = new List("ChanelsList");
			//list.setStartVerticalSpace(headerSize + Config.APPLE_TOP_OFFSET);
			//_view.addChild(list.view);
			//var fake:Array = [];
			//for (var i:int = 0; i < 100; i++) {fake.push({name:"Category name" + i, count:int(Math.random() * 1000) }); }
			
			// Header 
			bgHeader = new Bitmap();
			_view.addChild(bgHeader);
			
			// Title 
			title = new Bitmap(null, "auto", true);
			//_view.addChild(title);			
			
			//list.setData(fake, ListChannel, ["avatarURL"]);		
			
			//Back <-  button;
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1.3);
			backButton.setDownColor(0xFFFFFF);
			backButton.tapCallback = onBack;
			backButton.disposeBitmapOnDestroy = true;
			backButton.show();
			_view.addChild(backButton);
			var icoBack:IconBack = new IconBack();
			icoBack.width = icoBack.height = btnSize;
			backButton.setBitmapData(UI.getSnapshot(icoBack, StageQuality.HIGH, "FindUserScreen.backButton"), true);
			backButton.x = btnOffset;
			backButton.y = btnY + Config.APPLE_TOP_OFFSET;
			backButton.setOverflow(btnOffset, btnOffset, btnOffset, btnOffset);
			UI.destroy(icoBack);
			icoBack = null;		
				
			// Input 
			input = new Input();
			input.setMode(Input.MODE_INPUT);
			input.setLabelText("Search categories...");
			input.setBorderVisibility(false);	
			input.setTextColor(0xffffff);
			input.backgroundColor = AppTheme.RED_MEDIUM;
			input.backgroundAlpha = 0;
			input.deactivate();
			_view.addChild(input.view);
			
			// Preloader 
			preloader = new Preloader();
			_view.addChild(preloader);
			preloader.hide();
			preloader.visible = false;		
			
			// selector
			channelsSelector = new MultiSelector();
			channelsSelector.gap = Config.FINGER_SIZE*.15;
			channelsSelector.S_ON_SELECT.add(onSelectChannel);
			scrollPanel.addObject(channelsSelector);
			scrollPanel.setPositionY(Config.FINGER_SIZE+Config.APPLE_TOP_OFFSET);
			drawSelector(0);		
			
			
			
		}
		
		private function onCategoriesLoaded():void {
			channelsSelector.maxWidth = _width - padding * 2;
			channelsSelector.dataProvider = CategoryManager.getCategoriesArrayFiltered();
			scrollPanel.update();
			
		}
		
		private function onSelectChannel(sid:SelectorItemData):void {
			//trace(channelsSelector.getSelectedDataVector());	
		}
		
		private function drawSelector(positionY:Number):void {
			channelsSelector.maxWidth = _width - padding * 2;
			channelsSelector.x = padding;
			channelsSelector.y = positionY;		
		}
		
		private function displayPreloader():void {
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			preloader.show();
			preloader.visible = true;
		}		
		
		private function onInputValueChanged():void {
			var searchValue:String = StringUtil.trim(input.value);
			var curLenght:int = searchValue.length;	
			//trace(searchValue);
			
			title.visible  = curLenght < 1;
			if (curLenght >=1 && searchValue != "Search categories..." ) {		
			
				lastSearchValue = searchValue;
				showPreloader();
				TweenMax.killDelayedCallsTo(doSearch);
				TweenMax.delayedCall(.1, doSearch);			
			} else {
				TweenMax.killDelayedCallsTo(doSearch);
				CategoryManager.setFilter("");
				//if (list != null) {
					//list.setData(null, ListContact);
				//}
				lastSearchValue = "";
				hidePreloader(); // not valid search value 
			}			
		}
		
		
		private function doSearch():void {
			//trace("Search for a value locally" +lastSearchValue);
			CategoryManager.setFilter(lastSearchValue);
			hidePreloader(); 
			//search locally 
			//PHP.search_category(onChannelSearchRespond, "");		
			//TweenMax.delayedCall(2, onChannelSearchRespond, [new PHPRespond(null)]);
			
		}
		

		//private function onChannelSearchRespond(respond:PHPRespond):void {
			//// name total
			////trace(respond.errorMsg);
			////if (isLatestRespond(respond)){
				//hidePreloader();
				//// display results 				
			////}			
		//}
		
		
		/** 
		 * Prelaoder Methods  
		 **/
		private function showPreloader():void {
			if (preloader == null)
				preloader = new Preloader();
			_view.addChild(preloader);
			preloader.show(false);
			setPreloaderCoords();
		}
		
		private function hidePreloader():void {
			if (preloader != null)
				preloader.hide();
		}
		
		private function setPreloaderCoords():void {
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = (_height /*+ list.getStartVerticalSpace()*/) * .5;
			}
		}
		
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed){
				return;
			}			
			backButton.activate();
			input.activate();
			input.S_CHANGED.add(onInputValueChanged);
			
			channelsSelector.activate();
			scrollPanel.enable();
			
			//list.activate();
			//list.S_STOP_UPPER_CONTENT.add(onListStopUpperContent);
			//list.S_SHOW_UPPER_CONTENT.add(onListShowUpperContent);
			//list.S_HIDE_UPPER_CONTENT.add(onListHideUpperContent);
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			scrollPanel.disable();
			backButton.deactivate();	
			input.deactivate();
			input.S_CHANGED.remove(onInputValueChanged);	
			channelsSelector.deactivate();
			SoftKeyboard.closeKeyboard();
		}
		
		override protected function drawView():void	{
			scrollPanel.setWidthAndHeight(_width, _height - headerSize - Config.APPLE_TOP_OFFSET);
			input.width = _width - Config.DOUBLE_MARGIN -int(Config.FINGER_SIZE);
			// List
			//list.view.y = headerSize + Config.APPLE_TOP_OFFSET;
			//list.setWidthAndHeight(_width, _height - headerSize- Config.APPLE_TOP_OFFSET);
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void	 {
			super.dispose();	
			CategoryManager.S_CATEGORIES_LOADED.remove(onCategoriesLoaded);
			if (title){
				UI.destroy(title);
				title = null;
			}
			if (bgHeader){
				UI.destroy(bgHeader);
				bgHeader = null;
			}
			if (backButton){
				backButton.dispose();
				backButton = null;
			}
			if (scrollPanel){
				scrollPanel.dispose();
				scrollPanel = null;
			}
			
			if (input != null)
				input.dispose();
			input = null;
			
			if (preloader){
				preloader.dispose()
				preloader = null;
			}
			if (channelsSelector != null){
				channelsSelector.dispose();
				
				channelsSelector = null;
			}
			
			if (scrollPanel != null){
				scrollPanel.dispose();
				scrollPanel = null;
			}
			//if (list != null){
				//list.dispose();
				//list = null;
			//}
		}
		
	}
}