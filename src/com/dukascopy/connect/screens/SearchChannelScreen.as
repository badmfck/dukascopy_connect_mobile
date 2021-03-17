package com.dukascopy.connect.screens
{
	
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class SearchChannelScreen extends BaseScreen
	{
		private var FIT_WIDTH:Number;
		private var max_text_width:int;
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		private var title:Bitmap;
		private var bgHeader:Bitmap;
		private var backButton:BitmapButton;
		private var buttonPaddingLeft:int;
		private var padding:int=0;
		private var headerSize:int;	
		private var preloader:Preloader;
		private var input:Input;
		private var list:List;
		private var lastSearchValue:String = "";
		static private var channels:Array;
		private var defaultText:String;
		private var busy:Boolean;
		private var needUpdate:Boolean;
		
		/** @CONSTRUCTOR **/
		public function SearchChannelScreen(){}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			FIT_WIDTH = _width - buttonPaddingLeft * 2;
			
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
			list.view.y = headerSize + Config.APPLE_TOP_OFFSET;
			list.setWidthAndHeight(_width, _height - headerSize - Config.APPLE_TOP_OFFSET);
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
			defaultText = Lang.searchChannels;
			padding = Config.MARGIN * 2;
			buttonPaddingLeft = Config.MARGIN * 2;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = AppTheme.GREY_DARK;
			headerSize = int(Config.FINGER_SIZE * .85);
			var btnSize:int = headerSize * .38;
			var btnY:int = (headerSize - btnSize) * .5;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			// List 
			list = new List("ChanelsSearchList");
			list.background = true;
			_view.addChild(list.view);
			
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
			input.setLabelText(defaultText);
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
			
			if (busy == true) {
				lastSearchValue = searchValue;
				needUpdate = true;
				return;
			}
			
			needUpdate = false;
			
			title.visible = curLenght < 2;
			
			if (curLenght > 2 && searchValue != defaultText ) {
				lastSearchValue = searchValue;
				showPreloader();
				TweenMax.killDelayedCallsTo(doSearch);
				TweenMax.delayedCall(.5, doSearch);			
			} else {
				TweenMax.killDelayedCallsTo(doSearch);
				if (list != null) {
					list.setData(null, null);
				}
				lastSearchValue = "";
				hidePreloader(); // not valid search value 
			}			
		}
		
		private function doSearch():void {
			busy = true;
			channels = null;
			PHP.channelsSearch(onSearchRespond, lastSearchValue)
		}
		
		private function onSearchRespond(phpRespond:PHPRespond):void {
			if (_isDisposed == true)
				return;
			
			hidePreloader(); 
			
			busy = false;
			if (phpRespond.error) {
				echo("SearchChannelScreen", "onSearchRespond", "PHP ERROR -> " + phpRespond.errorMsg);
				phpRespond.dispose();
				checkUpdate();
				return;
			}
			
			if (phpRespond.data == null) {
				phpRespond.dispose();
				checkUpdate();
				return;
			}
			
			if (channels == null) {
				channels = new Array();
			}
			
			var cVO:ChatVO;
			
			for (var i:int = 0; i < phpRespond.data.length; i++) {
				channels.push(new ChatVO(phpRespond.data[i]));
			}
			
			if (list != null)
				list.setData(channels, ListConversation, ['avatarURL'], null);
			
			checkUpdate();
			phpRespond.dispose();
		}
		
		private function checkUpdate():void {
			if (needUpdate == true) {
				onInputValueChanged();
			}
		}
		
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
				preloader.y = _height * .5;
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
			
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			backButton.deactivate();	
			input.deactivate();
			list.S_ITEM_TAP.remove(onItemTap);
			input.S_CHANGED.remove(onInputValueChanged);	
			SoftKeyboard.closeKeyboard();
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("InnerChannelsScreen", "onItemTap", "");
			if (!(data is ChatVO))
				return;
			
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.type = ChatInitType.CHAT;
			if (data.uid != null) {
				chatScreenData.chatUID = data.uid;
			}
			chatScreenData.backScreen = RootScreen;
			MobileGui.showChatScreen(chatScreenData)
		}
		
		override protected function drawView():void	{
			input.width = _width - Config.DOUBLE_MARGIN -int(Config.FINGER_SIZE);
			// List
			list.view.y = headerSize + Config.APPLE_TOP_OFFSET;
			list.setWidthAndHeight(_width, _height - headerSize- Config.APPLE_TOP_OFFSET);
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killDelayedCallsTo(doSearch);
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
			if (input != null)
				input.dispose();
			input = null;
			if (preloader){
				preloader.dispose()
				preloader = null;
			}
			if (list != null){
				list.dispose();
				list = null;
			}
			channels = null;
		}
	}
}