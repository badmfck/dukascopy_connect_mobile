package com.dukascopy.connect.screens.innerScreens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ContactListRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.list.renderers.ListBotRenderer;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.BotProfileScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.SearchChannelCategoryScreen;
	import com.dukascopy.connect.screens.SearchChannelScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.channel.CreateChannelDisclaimerScreen;
	import com.dukascopy.connect.screens.dialogs.bot.BotInfoPopup;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bot.BotManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InnerChannelsScreen extends BaseScreen {
		
		private static const TAB_ALL:String = "all";
		private static const TAB_MINE:String = "mine";
		private static const TAB_TRASH:String = "trash";
		private static const TAB_BOTS:String = "bots";
		
		private var tabs:FilterTabs;
		private var list:List;
		
		private var selectedFilter:String;
		private var listPosition:int;
		private var doLoadChannels:Boolean;
		private var channelsData:Array;
		private var needToRefreshAfterScrollStoped:Boolean;
		private var searchChannelButton:HidableButton;
		private var mineChannelsData:Array;
		private var trashChannelsData:Array;
		private var bots:Array;
		private var horizontalLoader:com.dukascopy.connect.gui.tools.HorizontalPreloader;
		
		public function InnerChannelsScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.title = 'Inner channels screen';
			_params.actions = getScreenActions();
			_params.doDisposeAfterClose = false;
			
			BotManager.S_BOTS.add(onBotsLoaded);
			
			BotManager.S_LOAD_START.add(onBotsLoadStart);
			BotManager.S_LOAD_STOP.add(onBotsLoadEnd);
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			ChannelsManager.S_LOAD_ALL_START.add(onChannelsLoadStart);
			ChannelsManager.S_LOAD_ALL_STOP.add(onChannelsLoadStop);
			
			ChannelsManager.S_LOAD_TRASH_START.add(onTrashChannelsLoadStart);
			ChannelsManager.S_LOAD_TRASH_STOP.add(onTrashChannelsLoadStop);
		}
		
		private function onTrashChannelsLoadStart():void 
		{
			if (selectedFilter == TAB_TRASH)
			{
				showLoader();
			}
		}
		
		private function onTrashChannelsLoadStop():void 
		{
			if (selectedFilter == TAB_TRASH)
			{
				hideLoader();
			}
		}
		
		private function onChannelsLoadStart():void 
		{
			if (selectedFilter == TAB_ALL || TAB_MINE)
			{
				showLoader();
			}
		}
		
		private function onChannelsLoadStop():void 
		{
			if (selectedFilter == TAB_ALL || TAB_MINE)
			{
				hideLoader();
			}
		}
		
		private function onBotsLoadEnd():void 
		{
			if (selectedFilter == TAB_BOTS)
			{
				hideLoader();
			}
		}
		
		private function onBotsLoadStart():void 
		{
			if (selectedFilter == TAB_BOTS)
			{
				showLoader();
			}
		}
		
		private function hideLoader():void 
		{
			horizontalLoader.stop();
		}
		
		private function showLoader():void 
		{
			horizontalLoader.start();
		}
		
		private function onBotsLoaded():void 
		{
			bots = null;
			if (_isActivated)
			{
				setListData();
			}
		}
		
		private function getScreenActions():Vector.<IScreenAction> {
			var array:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			var open911ScreenAction:IScreenAction = new Open911ScreenAction();
			array.push(open911ScreenAction);
			return array;
		}
		
		override protected function createView():void {
			super.createView();	
			
			list = new List("ChannelsScreen");
			list.setContextAvaliable(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);;
			list.background = true;
			list.view.y = Config.FINGER_SIZE*1.2;
			_view.addChild(list.view);
			
			createTabs();
			
			selectedFilter = TAB_ALL;
			searchChannelButton = new HidableButton();
			var searchIcon:SWFSearchChannelButton = new SWFSearchChannelButton();
			searchChannelButton.setDesign(searchIcon);	
			searchChannelButton.tapCallback = onBottomButtonTap;
			//_view.addChild(searchChannelButton);
			
			horizontalLoader = new HorizontalPreloader(0xA1B8D2);
			_view.addChild(horizontalLoader);
		}
		
		private function createTabs ():void {
			tabs = new FilterTabs();
			tabs.add(Lang.textAll, TAB_ALL, true, "l");
			tabs.add(Lang.textMine, TAB_MINE, false);
			
			if (Config.BOTS == true || Config.isCompanyMember())
			{
				tabs.add(Lang.textSpam, TAB_TRASH, false);
				tabs.add(Lang.bots, TAB_BOTS, false, "r");
			}
			else{
				tabs.add(Lang.textSpam, TAB_TRASH, false, "r");
			}
			
			_view.addChild(tabs.view);
		}
		
		override public function drawViewLang():void {
			tabs.dispose();
			createTabs();
			tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			tabs.setSelection(selectedFilter);
		}
		
		override protected function drawView():void {
			tabs.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
			list.view.y = (tabs.view.visible) ? tabs.height : 0;
			list.setWidthAndHeight(_width, _height - list.view.y);
			
			searchChannelButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE - Config.MARGIN * 2);
			searchChannelButton.setOffset(MobileGui.stage.stageHeight - _height);
		}
		
		override public function clearView():void {
			super.clearView();
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			if (list != null)
				list.dispose();
			list = null;
			
			if (searchChannelButton)
				searchChannelButton.dispose();
			searchChannelButton = null;
			
			if (horizontalLoader != null)
				horizontalLoader.dispose();
			horizontalLoader = null;
			
			channelsData = null;
			trashChannelsData = null;
			mineChannelsData = null;
			bots = null;
		}
		
		override public function dispose():void {
			super.dispose();
			selectedFilter = TAB_ALL;
			ChatManager.S_CHAT_UNREADED_UPDATED.remove(onChatUnreadedUpdated);
			BotManager.S_BOTS.remove(onBotsLoaded);
			
			BotManager.S_LOAD_START.remove(onBotsLoadStart);
			BotManager.S_LOAD_STOP.remove(onBotsLoadEnd);
			
			ChannelsManager.S_LOAD_ALL_START.remove(onChannelsLoadStart);
			ChannelsManager.S_LOAD_ALL_STOP.remove(onChannelsLoadStop);
			
			ChannelsManager.S_LOAD_TRASH_START.remove(onTrashChannelsLoadStart);
			ChannelsManager.S_LOAD_TRASH_START.remove(onTrashChannelsLoadStop);
		}
		
		override public function activateScreen():void {
			if (_isDisposed)
				return;
			super.activateScreen();
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				list.S_STOPED.add(onScrollStopped);
			}	
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			if (searchChannelButton != null)
				searchChannelButton.activate();
			
			ChannelsManager.S_CHANNELS.add(onChannelsUpdated);
			ChannelsManager.S_CHANNEL_UPDATED.add(onChatUpdated);
			WS.S_CONNECTED.add(onWSConnected);
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeedAuthorization);
			ChatManager.S_CHAT_UNREADED_UPDATED.add(onChatUnreadedUpdated);
			ChatManager.S_CHAT_UPDATED.add(onChatUpdated);
			
			ChannelsManager.getChannels();
			ChannelsManager.listenChannelsChanges();
		}
		
		private function onChatUnreadedUpdated(cvo:ChatVO):void {
			if (list != null)
				list.updateItem(cvo);
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed)
				return;
			super.deactivateScreen();
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
				list.S_STOPED.remove(onScrollStopped);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			if (searchChannelButton != null)
				searchChannelButton.deactivate();
			
			ChannelsManager.S_CHANNELS.remove(onChannelsUpdated);
			ChannelsManager.S_CHANNEL_UPDATED.remove(onChatUpdated);
			WS.S_CONNECTED.remove(onWSConnected);
			Auth.S_NEED_AUTHORIZATION.remove(onAuthNeedAuthorization);
			ChatManager.S_CHAT_UPDATED.remove(onChatUpdated);
			ChannelsManager.stopListenChannelsChanges();
		}
		
		private function onBottomButtonTap():void {			
			
			MobileGui.changeMainScreen(SearchChannelScreen, { data:null, backScreen:RootScreen, backScreenData:null } );
			return;
		}
		
		private function onAuthNeedAuthorization():void {
			echo("InnerChannelsScreen", "onAuthNeedAuthorization");
			if (list != null)
				list.setData(null, null);
			doLoadChannels = false;
			channelsData = null;
			trashChannelsData = null;
			mineChannelsData = null;
		}
		
		private function onWSConnected():void {
			if (_isDisposed)
				return;
			if (_isActivated == false) {
				doLoadChannels = true;
				return;
			}
			
			ChannelsManager.getChannels();
		}
		
		private function onChatUpdated(cvo:ChatVO):void {
			echo("InnerChannelsScreen", "onChatUpdated", "");
			if (!_isActivated) {
				if (cvo.type == ChatRoomType.CHANNEL)
					doLoadChannels = true
				return;
			}
			if (list != null)
				list.updateItem(cvo);
		}
		
		private function onChannelsUpdated():void {
			echo("InnerChannelsScreen", "onChannelsUpdated", "");
			if (_isDisposed || !_isActivated) {
				doLoadChannels = true;
				return;
			}
			doLoadChannels = false;
			channelsData = null;
			trashChannelsData = null;
			mineChannelsData = null;
			
			setListData();
		}
		
		private function showTabs(value:Boolean):void {
			tabs.view.visible = value;
			list.view.y = (tabs.view.visible) ? tabs.height : 0;
			list.setWidthAndHeight(_width, _height - list.view.y);
		}
		
		private function closeChannel(data:ChatVO):void {
			DialogManager.alert(Lang.textConfirm, Lang.alertConfirmCloseChannel, 
					function(val:int):void {
						if (val != 1)
							return;
						if(data!=null)
							ChannelsManager.deleteChannel(data.uid, onChannelRemoveResponse);
					}, Lang.textYes.toUpperCase(), Lang.textCancel.toUpperCase());
		}
		
		private function onChannelRemoveResponse(success:Boolean, channelUID:String, errorMessage:String = null):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (success)
			{
				setListData();
			}
			else
			{
				ToastMessage.display(errorMessage);
			}
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("InnerChannelsScreen", "onItemTap", "");
			
			hideLoader();
			var itemHitZone:String;
			if (data is BotVO) {
				if (data.action != null && (data.action is IScreenAction)) {
					(data.action as IScreenAction).execute();
					return;
				}
				
				item = list.getItemByNum(n);
				if (item != null)
					itemHitZone = item.getLastHitZone();
					
				if (itemHitZone == HitZoneType.BOT_INFO) {
					DialogManager.showDialog(BotInfoPopup, data);
					return;
				}
				
				if ((data as BotVO).group != BotManager.GROUP_OTHER)
				{
					chatScreenData = new ChatScreenData();
						chatScreenData.usersUIDs = [(data as BotVO).uid];
						chatScreenData.type = ChatInitType.USERS_IDS;
						chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
						chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
					MobileGui.showChatScreen(chatScreenData);
				}
				
				return;
			}
			if ( data is ChatUserVO ) {
				MobileGui.changeMainScreen(
					UserProfileScreen,
					{
						data:(data as ChatUserVO).userVO,
						backScreen:MobileGui.centerScreen.currentScreenClass,
						backScreenData:this.data
					}
				);
				return;
			}
			
			if (!(data is ChatVO))
				return;
			if (data.type == ChatRoomType.CHANNEL) {
				
				var item:ListItem = list.getItemByNum(n);
				
				if (item)
					itemHitZone = item.getLastHitZone();
				if (itemHitZone) {
					if (itemHitZone == HitZoneType.OPEN_PROFILE) {
						var user:UserVO = UsersManager.getFullUserData((data as ChatVO).ownerUID);
						if (user)
							MobileGui.changeMainScreen(UserProfileScreen, { backScreen: MobileGui.centerScreen.currentScreenClass, 
								backScreenData: MobileGui.centerScreen.currentScreen.data, 
								data: user
							} );
						return;
					}
					if (itemHitZone == HitZoneType.DELETE) {
						closeChannel(data as ChatVO);
						return;
					}
				}
				
				if (data.uid == null) {
					MobileGui.changeMainScreen(CreateChannelDisclaimerScreen, { backScreen: RootScreen, 
																backScreenData: this.data, 
																data: null
					} );
					return;
				}
			}
			
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.type = ChatInitType.CHAT;
			if (data.uid != null) {
				chatScreenData.chatVO = data as ChatVO;
			} else {
				if ((data as ChatVO).type == ChatRoomType.COMPANY) {
					chatScreenData.pid = (data as ChatVO).pid;
					chatScreenData.type = ChatInitType.SUPPORT;
				}
			}
			chatScreenData.backScreen = RootScreen;
			MobileGui.showChatScreen(chatScreenData)
		}
		
		private function onTabItemSelected(id:String):void {
			echo("InnerChannelsScreen", "onTabItemSelected", "");
			hideLoader();
			needToRefreshAfterScrollStoped = false;
			
			if (id == TAB_TRASH)
			{
				Store.load(Store.SPAM_CHANNELS_INFO_POPUP_STATUS, onSpamChannelsInfoStatusLoaded);
				return;
			}
			
			selectedFilter = id;
			listPosition = 0;
			if (doLoadChannels) {
				list.setData(null, null);
				ChannelsManager.getChannels();
				return;
			}
			setListData();
		}
		
		private function onSpamChannelsInfoStatusLoaded(data:Object, error:Boolean):void 
		{
			if (error == true || data == null || data != "dontShow")
			{
				DialogManager.showSpamChannelsInfoDialog(null, onSpamInfoDialogResult);
			}
			else
			{
				selectedFilter = TAB_TRASH;
				listPosition = 0;
				setListData();
			}
		}
		
		private function onSpamInfoDialogResult(result:Object):void 
		{
			if (result != null)
			{
				if (result.doNotShowAgain == true)
				{
					Store.save(Store.SPAM_CHANNELS_INFO_POPUP_STATUS, "dontShow");
				}
				if (result.id == 1)
				{
					selectedFilter = TAB_TRASH;
					listPosition = 0;
					setListData();
				}
				else{
					tabs.setSelection(selectedFilter);
				}
			}
		}
		
		private function onScrollStopped(val:Number):void {
			if (isActivated == false)
				return;
			if (needToRefreshAfterScrollStoped == false)
				return;
			needToRefreshAfterScrollStoped = false;
			setListData();
		}
		
		private function setListData():void {
			if (list.getScrolling() == true) {
				needToRefreshAfterScrollStoped = true;
				return;
			}
			
			if (list != null) {
				if (selectedFilter == TAB_ALL || selectedFilter == TAB_MINE)
				{
					if (channelsData == null)
						channelsData = ChannelsManager.getAllChannels();
						
					if (list.data != null  && channelsData != null && channelsData.length == list.data.length){
						saveListPosition();
					}
					
					list.setData(getFilteredData(), ListConversation, ['avatarURL'], null);
				}
				else if (selectedFilter == TAB_TRASH)
				{
					if (trashChannelsData == null)
						trashChannelsData = ChannelsManager.getTrashChannels();
					
					list.setData(getFilteredData(), ListConversation, ['avatarURL'], null);
				}
				else if (selectedFilter == TAB_BOTS)
				{
					if (bots == null)
						bots = BotManager.getAllBots();
					list.setData(bots, ListBotRenderer);
					return;
				}
			}
			list.setBoxY(listPosition);
			if (list.data != null && list.data.length != 0) {
				return;
			}
		}
		
		private function getFilteredData():Array {
			
			var result:Array = new Array();
			var l:int;
			
			
			if (selectedFilter == TAB_ALL){
				if (channelsData != null)
				{
					var news_911_channel:ChatVO;
					
					l = channelsData.length;
					for (var i:int = 0; i < l; i++) 
					{
						if ((channelsData[i] as ChatVO).uid == Config.CHANNEL_911_NEWS_UID)
						{
							news_911_channel = channelsData[i] as ChatVO;
						}
						if (Shop.isPaidChannelsAvaliable() == false)
						{
							if ((channelsData[i] as ChatVO).subscription == null)
							{
								result.push(channelsData[i]);
							}
						}
						else{
							result.push(channelsData[i]);
						}
					}
				}
				else{
					return channelsData;
				}
				if (news_911_channel != null && result.length > 0)
				{
					var index:int = result.indexOf(news_911_channel);
					if (index != -1)
					{
						result.insertAt(1, result.removeAt(index));
					}
				}
				return result;
			}
			else if (selectedFilter == TAB_MINE) {
				if (mineChannelsData == null){
					mineChannelsData = getMineChannels();
				}
				return mineChannelsData;
			}
			else if (selectedFilter == TAB_TRASH)
			{
				if (trashChannelsData != null)
				{
					l = trashChannelsData.length;
					for (var i2:int = 0; i2 < l; i2++) 
					{
						if (Shop.isPaidChannelsAvaliable() == false)
						{
							if ((trashChannelsData[i2] as ChatVO).subscription == null)
							{
								result.push(trashChannelsData[i2]);
							}
						}
						else{
							result.push(trashChannelsData[i2]);
						}
					}
				}
				else{
					return trashChannelsData;
				}
				
				return result;
			}
			return null;
		}
		
		private function getMineChannels():Array {
			var value:Array = new Array();
			if (channelsData != null){
				var l:int = channelsData.length;
				var channel:ChatVO;
				for (var i:int = 0; i < l; i++) {
					channel = channelsData[i];
					if (channel != null && channel.ownerUID == Auth.uid){
						value.push(channel);
					}
				}
			}
			return value;
		}
		
		public function saveListPosition():void {
			listPosition = list.getBoxY();
		}
		
		override public function getAdditionalDebugInfo():String {
			return "InnerChannelsScreen > " + selectedFilter;
		}
	}
}