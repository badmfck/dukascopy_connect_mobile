package com.dukascopy.connect.screens.innerScreens {
	
	import assets.NumericKeyboardIcon;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911ScreenAction;
	import com.dukascopy.connect.gui.input.SearchBar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ContactListRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListBotRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListPhonesSearch;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.bot.BotInfoPopup;
	import com.dukascopy.connect.screens.userProfile.StartChatByPhoneScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bot.BotManager;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.contactsManager.ContactsManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.socialManager.SocialManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.users.adds.ContactSearchVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Roman Kulyk
	 */
	public class InnerContactScreen extends BaseScreen
	{
		private static const TAB_ALL:String = "all";
		private static const TAB_CONNECT:String = "connect";
		private static const TAB_PHONE:String = "my_phone";
		private static const MEMBERS_COMPANY:String = "DC";
		private static const TAB_COMPANY:String = "tabCompany";
		private static const TAB_BOTS:String = "tabBots";
		private static const TAB_SEARCH:String = "tabSearch";

		private var tabs:FilterTabs;
		private var list:List;
		
		private var internetData:Array = [];
		private var allData:Array;
		private var myData:Array;
		private var membersData:Array;
		private var connectData:Array;
		private var companyData:Array;
		
		private var selectedFilter:String = TAB_ALL;
		private var inviteUserInProgress:Boolean;
		private var contactFilter:String = "";
		
		private const topHeight:int = Config.FINGER_SIZE * 1.5;
		
		private var searchBar:SearchBar;
		private var preloader:Preloader;
		private var emptyClip:Bitmap;
		private var searching:Boolean;
		private var _posY:int=0;
		private var botsData:Array;
		private var horizontalLoader:HorizontalPreloader;
		private var createChatButton:HidableButton;
		private var phoneIcon:NumericKeyboardIcon;
		private var autoInvoiceData:Object;
		
		public function InnerContactScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = 'Inner contact screen';
			_params.actions = getScreenActions();
			_params.doDisposeAfterClose = false;
			if (list.getBoxY() < 0)
				posY = list.getBoxY();
			ContactsManager.S_CONTACTS_UPDATE.add(onContactsUpdated);
			
			if (data != null && "additionalData" in data && data.additionalData != null)
			{
				setAddditionalData(data.additionalData);
			}
			
			Auth.S_PHAZE_CHANGE.add(onPhaseChanged);
			
			if (selectedFilter == TAB_PHONE || selectedFilter == TAB_ALL)
				PhonebookManager.onPhonesContactsTabOpened();
			
			if (PaidBan.isAvaliable()) {
				PaidBan.S_USER_BAN_UPDATED.add(onUserBanChange);
			}
			BotManager.S_BOTS.add(onBotsLoaded);
			BotManager.S_LOAD_START.add(onBotsLoadStart);
			BotManager.S_LOAD_STOP.add(onBotsLoadEnd);
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			ConfigManager.S_CONFIG_READY.add(onConfigReady);
			
			createChatButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE - Config.MARGIN * 2);
			createChatButton.setOffset(Config.TOP_BAR_HEIGHT * 2 + Config.APPLE_TOP_OFFSET);
		}
		
		private function onConfigReady():void 
		{
			if (PayAPIManager.configSeted == true) {
				if (tabs != null) {
					tabs.removeAll();
					tabs.setWidthAndHeight(0, 0);
					createTabs();
					tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
					tabs.setSelection(selectedFilter);
					if (isActivated)
					{
						if (tabs.S_ITEM_SELECTED != null)
							tabs.S_ITEM_SELECTED.add(onTabItemSelected);
						tabs.activate();
					}
				}
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
		
		private function showLoader():void 
		{
			horizontalLoader.start();
		}
		
		private function onBotsLoaded():void 
		{
			clearData();
			if (_isActivated)
			{
				setListData();
			}
		}
		
		private function onPhaseChanged(realChange:Boolean = true):void 
		{
			if (realChange == true)
			{
				onContactsUpdated();
			}
		}
		
		private function onUserBanChange(userUID:String = null):void {
			refreshList();
		}
		
		private function refreshList():void {
			if (_isDisposed == true)
				return;
			if (list != null)
				list.refresh();
		}
		
		private function getScreenActions():Vector.<IScreenAction> {
			var array:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			var open911ScreenAction:IScreenAction = new Open911ScreenAction();
			array.push(open911ScreenAction);
			return array;
		}
		
		private function onSearchContact(searchBar:SearchBar):void {
			echo("InnerContactScreen", "onSearchContact", "");
			searching = true;
			this.searchBar = searchBar;
			showTabs(searchBar.mode == SearchBar.MODE_REST);
			contactFilter = StringUtil.trim(searchBar.text);
			
			if (searchBar.mode == SearchBar.MODE_ACTIVATE && searchBar.text == "") {
				list.setData(null, ContactListRenderer);
				if (emptyClip && emptyClip.parent != null)
					emptyClip.parent.removeChild(emptyClip);
			} else {
				setListData();
			}
			
			TweenMax.killDelayedCallsTo(doExternalSearch);
			hidePreloader();
			if (searchBar.text.length > 2) {
				internetData = PhonebookManager.filterByName(allData, searchBar.text);
				contactFilter = TAB_SEARCH;
				setListData();
				/*showPreloader();
				TweenMax.delayedCall(1, doExternalSearch);*/
			}
		}
		
		private function doExternalSearch(e:TimerEvent = null):void {
			echo("InnerContactScreen", "doExternalSearch");
			PHP.search_all(onRespondSearchContact, contactFilter);
		}
		
		private function onRespondSearchContact(phpRespond:PHPRespond):void {
			//TODO: rewrite this call to controller and signal, not use direct;
			hidePreloader();
			searching = false;
			if (isDisposed) {
				phpRespond.dispose();
				return;
			}
			echo("InnerContactScreen", "onRespondSearchContact", "");
			if (list == null) { // Disposed
				phpRespond.dispose();
				return;
			}
			if (phpRespond.error == true) {
				//trace("SearchScreen::onRespond -> " + phpRespond.errorMsg);
			} else if (phpRespond.data!=null && phpRespond.data.length == 0) {
				//trace("Show no search matches ");
				internetData = [];
				addMembers();
			} else {
				internetData = [];
				var contact:ContactVO;
				var contactSearchVO:ContactSearchVO;
				for (var i:int = 0; i < phpRespond.data.length; i++) {
					if (phpRespond.data[i] && ("uid" in phpRespond.data[i]) && listHasUser(list.data as Array, phpRespond.data[i].uid)) {
						continue;
					}
					
					phpRespond.data[i].name = TextUtils.checkForNumber(phpRespond.data[i].name);
					
					contact = new ContactVO(phpRespond.data[i]);
					
					contactSearchVO = new ContactSearchVO(contactFilter, contact);
					if (internetData.length == 0) internetData.push("Other");
					internetData.push(contactSearchVO);
				}
				addMembers();
			}
			phpRespond.dispose();
		}
		
		private function addMembers():void{
			var members:Array = [];
			if(ContactsManager.companyMembers){
				members = ContactsManager.companyMembers.members;
			}
			var k:int = 0;
			var objInt:ContactSearchVO;
			var objMembers:MemberVO;
			var l:int = internetData.length;
			var bool:Boolean;
			var contactSearchVO:ContactSearchVO;
			var rezultArr:Array = [];
			var value:int;
			var nameM:String;
			for (var r:int = 0; r < members.length; r++) {
				objMembers = members[r];
				for (k; k < l ; k++) {
					if (internetData[k] is ContactSearchVO) {
						objInt =  internetData[k];
					} else {
						continue;
					}
					if("uid" in objInt.entry && objInt.entry["uid"] == members.uid ){
					//	trace("test");
						bool = true;
						break;
					}
				}
				if (bool == false) {
					value = (objMembers.name.toLocaleLowerCase()).indexOf(contactFilter.toLocaleLowerCase());
					if (value != -1 ) {
						contactSearchVO = new ContactSearchVO(contactFilter, objMembers);
						rezultArr.push(contactSearchVO);
					}
				}
			}
			if (internetData.length == 0) {
				internetData.unshift("Other");
			}
			internetData = internetData.concat(rezultArr);
			setListData();
		}
		
		private function listHasUser(data:Array, uid:String):Boolean
		{
			echo("InnerContactScreen", "listHasUser", "");
			if (!data)
			{
				return false;
			}
			for (var i:int = 0; i < data.length; i++) 
			{
				if (data[i] is String) return false;
				if (!("entry" in data[i]) || data[i].entry == null || !("uid" in data[i].entry))
				{
					return false;
				}
				if (data[i].entry.uid && data[i].entry.uid == uid) return true;
			}
			return false;
		}
		
		override protected function createView():void {
			super.createView();	
			echo("InnerContactScreen", "createView", "");
			list = new List("Contacts");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			list.view.y = Config.FINGER_SIZE*1.2;
			_view.addChild(list.view);
			createTabs();
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeedAuthorization);
			
			horizontalLoader = new HorizontalPreloader(0xA1B8D2);
			_view.addChild(horizontalLoader);
			
			createChatButton = new HidableButton();
			createChatButton.tapCallback = onBottomButtonTap;
			_view.addChild(createChatButton);
		}
		
		private function onBottomButtonTap():void {			
			
			MobileGui.changeMainScreen(StartChatByPhoneScreen, { data:null, backScreen:RootScreen, backScreenData:null } );
		}
		
		private function createTabs():void {
			tabs = new FilterTabs();
			tabs.add(Lang.textAll, TAB_ALL, true, "l");
			tabs.add(Lang.textConnect, TAB_CONNECT);
			if (SocialManager.available == true && (Config.BOTS == true || Config.isCompanyMember())) {
				tabs.add(Lang.bots, TAB_BOTS);
			} else {
				tabs.add(Lang.textPhone, TAB_PHONE);
			}
			tabs.add(Lang.textHelp, TAB_COMPANY, false, "r");
			_view.addChild(tabs.view);
		}
		
		override public function drawViewLang():void {
			tabs.updateLabels( [ Lang.textAll, Lang.textConnect, Lang.textPhone, Lang.textHelp ] );
		}
		
		public function setAddditionalData(value:Object):void
		{
			if (isAutoInvoice(value))
			{
				autoInvoiceData = value;
			}
			if (value == null)
			{
				autoInvoiceData = null;
			}
		}
		
		private function isAutoInvoice(value:Object):Boolean 
		{
			if (value != null && "amount" in value && "currency" in value)
			{
				return true;
			}
			return false;
		}
		
		private function onAuthNeedAuthorization():void {
			echo("InnerContactScreen", "onAuthNeedAuthorization");
			allData = null;
			botsData = null;
			myData = null;
			membersData = null;
			connectData = null;
			companyData = null;
			if (list != null)
				list.setData(null, null);
			if (emptyClip != null && emptyClip.parent != null)
				emptyClip.parent.removeChild(emptyClip);
		}
		
		override protected function drawView():void {
			tabs.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
			list.view.y = (tabs.view.visible) ? tabs.height : 0;
			horizontalLoader.y = list.view.y;
			horizontalLoader.y = 0;
			list.setWidthAndHeight(_width, _height - list.view.y);
			createChatButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE - Config.MARGIN * 2);
			createChatButton.setOffset(MobileGui.stage.stageHeight - _height);
		}
		
		private function showEmptyClip():void {
			
			if (selectedFilter == TAB_BOTS)
			{
				return;
			}
			
			if (emptyClip == null) {
				emptyClip = new Bitmap(new ImageBitmapData("InnerContactScreen.emptyClip", _width, _height - tabs.height, false, 0xFFFFFFFF));
				emptyClip.y = tabs.height;
				var txtSnapshot:BitmapData = UI.renderText(Lang.textContactsNull, _width, 1, true, TextFormatAlign.CENTER, TextFieldAutoSize.CENTER, Config.FINGER_SIZE_DOT_35, true, 0x666666);
				var srcBMD:BitmapData = new SWFContactImage();
				var destScale:Number = UI.getMinScale(srcBMD.width, srcBMD.height, emptyClip.bitmapData.rect.width - Config.FINGER_SIZE, emptyClip.bitmapData.rect.height - Config.FINGER_SIZE * 3 - txtSnapshot.height);
				var img:BitmapData = UI.scaleManual(srcBMD, destScale, true);
				var rect:Rectangle = new Rectangle(0, Config.FINGER_SIZE, txtSnapshot.width, txtSnapshot.height);
				ImageManager.drawImageToBitmap(emptyClip.bitmapData, txtSnapshot, rect, 1);
				emptyClip.bitmapData.copyPixels(img, img.rect, new Point(int((_width - img.rect.width ) * .5), Config.FINGER_SIZE * 2 + txtSnapshot.rect.height));
				srcBMD = null;
				img.dispose();
				img = null;
			}
			if (emptyClip && emptyClip.parent == null)
				view.addChild(emptyClip);
		}
		
		private function hideEmptyClip():void {
			if (emptyClip == null)
				return;
			if (emptyClip && emptyClip.parent != null)
				emptyClip.parent.removeChild(emptyClip);
			if (emptyClip && emptyClip.bitmapData != null) {
				emptyClip.bitmapData.dispose();
				emptyClip.bitmapData = null;
			}
			emptyClip = null;
		}
		
		override public function clearView():void {
			echo("InnerContactScreen", "clearView", "");
			super.clearView();
			inviteUserInProgress = false;
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (list != null)
				list.dispose();
			list = null;
			
			if (horizontalLoader != null)
				horizontalLoader.dispose();
			horizontalLoader = null;
			
			if (createChatButton)
				createChatButton.dispose();
			createChatButton = null;
		}
		
		override public function dispose():void {
			echo("InnerContactScreen", "dispose", "");
			super.dispose();
			hidePreloader();
			TweenMax.killDelayedCallsTo(doExternalSearch);
			selectedFilter = TAB_ALL;
			inviteUserInProgress = false;
			internetData = null;
			searchBar = null;
			Auth.S_NEED_AUTHORIZATION.remove(onAuthNeedAuthorization);
			clearData();
			ContactsManager.S_CONTACTS_UPDATE.remove(onContactsUpdated);
			PaidBan.S_USER_BAN_UPDATED.remove(onUserBanChange);
			BotManager.S_BOTS.remove(onBotsLoaded);
			BotManager.S_LOAD_START.remove(onBotsLoadStart);
			BotManager.S_LOAD_STOP.remove(onBotsLoadEnd);
			ConfigManager.S_CONFIG_READY.remove(onConfigReady);
		}
		
		private function onContactsUpdated():void {
			clearData();
			if (_isActivated)
				setListData();
		}
		
		override public function activateScreen():void {
			echo("InnerContactScreen", "activateScreen", "");
			super.activateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}	
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			SearchBar.S_CHANGED.add(onSearchContact);
			ContactsManager.activate();
			
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
			
			PhonebookManager.S_PHONES.add(onPhonesLoaded);
			PhonebookManager.getPhones();
			
			if (createChatButton != null)
				createChatButton.activate();
		}
		
		private function onUserlistOnlineStatusChanged():void 
		{
			if (list)
			{
				list.refresh();
			}
		}
		
		private function onAllUsersOffline():void
		{
			if (list)
			{
				list.refresh();
			}
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void 
		{
			echo("InnerContactScreen", "onUserOnlineStatusChanged", "");
			
			if (isDisposed || list == null)
			{
				return;
			}
			
			var needUpdateItem:Boolean;
			
			
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS)
			{
				var item:ListItem;
				var l:int = list.getStock().length;
				
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) 
				{
					needUpdateItem = false;
					
					item = list.getItemByNum(j);
					if (item && item.liView && item.liView.visible)
					{
						if (item.data is ContactVO && (item.data as ContactVO).uid == status.uid)
						{
							needUpdateItem = true;
						}
						else if (item.data is PhonebookUserVO && (item.data as PhonebookUserVO).uid == status.uid)
						{
							needUpdateItem = true;
						}
						else if (item.data is ContactSearchVO && (item.data as ContactSearchVO).contact && (item.data as ContactSearchVO).contact.uid == status.uid)
						{
							needUpdateItem = true;
						}
						else if (item.data is MemberVO && (item.data as MemberVO).uid == status.uid)
						{
							needUpdateItem = true;
						}
						
						if (needUpdateItem)
						{
							if (list.getScrolling())
							{
								list.refresh();
							}
							else
							{
								item.draw(list.width, !list.getScrolling());
							}
							break;
						}
					} else {
						break;
					}
				}
				item = null;
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			echo("InnerContactScreen", "deactivateScreen", "");
			if (_isDisposed)
				return;
			if(tabs.view.visible == false){
				searchBar.reset();
			}
			if (list != null)
			{
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			if (!inviteUserInProgress) {
				PhonebookManager.S_USER_INVITED.remove(onInvitesUpdated);
			}
			SearchBar.S_CHANGED.remove(onSearchContact);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			
			PhonebookManager.S_PHONES.remove(onPhonesLoaded);
			
			ContactsManager.deactivate();
			
			if (createChatButton != null){				
				createChatButton.deactivate();
			}
		}
		
		private function showTabs(value:Boolean):void {
			echo("InnerContactScreen", "showTabs", "");
			tabs.view.visible = value;
			list.view.y = (tabs.view.visible) ? tabs.height: 0;
			horizontalLoader.y = list.view.y;
			horizontalLoader.y = 0;
			list.setWidthAndHeight(_width, getListHeight());
		}
		
		private function getListHeight():int {
			return _height - list.view.y
		}
		
		private function getListPositionY():int {
			var returnValue:int = 0;
			if (list.getBoxY() != 0) {
				returnValue = list.getBoxY();
			} else if(list.view.height > getListHeight() && posY <= 0) {
				returnValue = posY;
			}
			return returnValue;
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("InnerContactScreen", "onItemTap", "");
			
			var chatScreenData:ChatScreenData;
			
			var item:ListItem;
			posY = list.getBoxY();
			if (data is IScreenAction == true) {
				data.execute();
				return;
			}
			if (("action" in data) && data.action && (data.action is IScreenAction)) {
				(data.action as IScreenAction).execute();
				return;
			}
			if (data is BotVO) {
				
				item = list.getItemByNum(n);
				var itemHitZone:String;
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
			if (data is ContactSearchVO) {
				data = data.entry;
			}
			
			if (autoInvoiceData != null && (data is ContactVO || data is ChatUserVO || data is PhonebookUserVO)) {
				var userUID:String;
				if (data is ContactVO)
				{
					userUID = (data as ContactVO).uid;
				}
				else if (data is ChatUserVO)
				{
					userUID = (data as ChatUserVO).uid;
				}
				else if (data is PhonebookUserVO)
				{
					userUID = (data as PhonebookUserVO).uid;
				}
				
				chatScreenData = new ChatScreenData();
				chatScreenData.additionalData = autoInvoiceData;
				chatScreenData.usersUIDs = [userUID];
				chatScreenData.type = ChatInitType.USERS_IDS;
				chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
				chatScreenData.backScreenData = this.data;
				
				MobileGui.showChatScreen(chatScreenData);
				autoInvoiceData = null;
				return;
			}
			
			if (data is ContactVO) {
				MobileGui.changeMainScreen(UserProfileScreen, {data:data, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:this.data});
			} else if (data is PhonebookUserVO) {
				item = list.getItemByNum(n);
				if (item && item.getLastHitZone() == HitZoneType.INVITE_BUTTON) {
					inviteUserInProgress = true;
					//remove in any case (multiple calls from list items possible);
					PhonebookManager.S_USER_INVITED.remove(onInvitesUpdated);
					PhonebookManager.S_USER_INVITED.add(onInvitesUpdated);
					PhonebookManager.invite(data as PhonebookUserVO);
				} else {
					MobileGui.changeMainScreen(UserProfileScreen, {data:data, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:this.data});	
				}
			}
			else if (data is EntryPointVO ) {
				chatScreenData = new ChatScreenData();
				chatScreenData.pid = (data as EntryPointVO).id;
				chatScreenData.type = ChatInitType.SUPPORT;
				chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
				chatScreenData.backScreenData = this.data;
			
				MobileGui.showChatScreen(chatScreenData);
			}
			else if ( data is MemberVO ) {
				MobileGui.changeMainScreen(UserProfileScreen, {data:data,
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:this.data});
			}
			else if ( data is ChatUserVO ) {
				/*if (data.userVO != null && data.userVO.type == "bot") {
					MobileGui.changeMainScreen(BotProfileScreen, { data:(data as ChatUserVO).userVO,
						backScreen:MobileGui.centerScreen.currentScreenClass,
						backScreenData:this.data});
					return;
				}*/
				MobileGui.changeMainScreen(UserProfileScreen, {data:(data as ChatUserVO).userVO,
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:this.data});
			}
		}
		
		private function onInvitesUpdated(result:Object = null):void {
			echo("InnerContactScreen", "onInvitesUpdated", "");
			inviteUserInProgress = false;
			PhonebookManager.S_USER_INVITED.remove(onInvitesUpdated);
			if (isDisposed) {
				return;
			}
			
			//!TODO: not possible to find in easy way item with needed contact model, in general need to update only this item and block item InviteButton on start of the process;
			
			//Possible multiple invite calls from list...
			if (result && result.success) {
				list.refresh();
			}
		}
		
		private function onTabItemSelected(id:String):void {
			if (id == TAB_PHONE || id == TAB_ALL)
				PhonebookManager.onPhonesContactsTabOpened();
			echo("InnerContactScreen", "onTabItemSelected", "");
			if (selectedFilter != id)
				posY = 0;
			selectedFilter = id;
			setListData();
			setButtonDesign(id);
		}
		
		private function setButtonDesign(id:String):void{
			if (id == TAB_COMPANY) {
				createChatButton.visible = false;
				return;
			}
			
			phoneIcon ||= new NumericKeyboardIcon();
			createChatButton.setDesign(phoneIcon);	
			createChatButton.visible = true;
			return;
		}
		
		private function disposeIcons():void {
			phoneIcon = null;		
		}
		
		private function onPhonesLoaded():void {
			echo("InnerContactScreen", "onPhonesLoaded", "");
			clearData();
			setListData();
		}
		
		private function clearData():void 
		{
			allData = null;
			botsData = null;
			myData = null;
			membersData = null;
			connectData = null;
			companyData = null;
		}
		
		private function setListData():void {
			echo("InnerContactScreen", "setListData", "");
			
			hideLoader();
			
			if (contactFilter != "") {
				if (allData == null || allData.length == 0) {
					allData = PhonebookManager.getAllPhones();
					if (allData == null) {
						allData = [];
					}
				}
				var listData:Array = PhonebookManager.filterByName(allData, contactFilter, "Friends").concat(internetData);
				list.setData(listData, ListPhonesSearch);
				internetData = [];
			} else {
				switch(selectedFilter){
					case TAB_SEARCH:{
						list.setData(internetData, ContactListRenderer);
						internetData = [];
						break;
					}
					case TAB_ALL:{
						if (allData == null || allData.length > 1 && allData[1] is ContactVO && allData[1].uid == "")
							allData = PhonebookManager.getAllPhones();
						list.setData(allData, ContactListRenderer);
						break;
					}
					case TAB_CONNECT:{
						if (connectData == null || connectData.length != 0 && connectData[0] is ContactVO && connectData[0].uid == "")
							connectData = PhonebookManager.getConnectContacts();
						list.setData(connectData, ContactListRenderer);
						break;
					}
					case TAB_PHONE:{
						if (myData == null)
							myData = PhonebookManager.getMyPhones();
						list.setData(myData, ContactListRenderer);
						break;
					}
					case MEMBERS_COMPANY:{
						if (membersData == null)
							membersData = getMembers();
						list.setData(membersData, ContactListRenderer);
						break;
					}
					case TAB_COMPANY:{
						if (companyData == null)
							companyData = PhonebookManager.getEntrypointsContacts();
						list.setData(companyData, ContactListRenderer);
						break;
					}
					case TAB_BOTS:{
						if (botsData == null)
							botsData = BotManager.getAllBots();
						list.setData(botsData, ListBotRenderer, ["avatarURL", "ownerAvatarURL"]);
						break;
					}
				}
				list.setBoxY(getListPositionY());
			}
			
			echo("InnerContactScreen", "setListData", "1");
			TweenMax.killDelayedCallsTo(checkForEmptyClipNeed);
			if (list.data != null && list.data.length != 0) {
				checkForEmptyClipNeed();
				return;
			}
			if (searching == false)
				TweenMax.delayedCall(1, checkForEmptyClipNeed);
			
			function getMembers():Array{
				var members:Array = [];
				if(ContactsManager.companyMembers){
					members = ContactsManager.companyMembers.members;
				}
				return members;
			}
		}
		
		private function hideLoader():void 
		{
			horizontalLoader.stop();
		}

		private function concatArr(allData:Array, members:Array):Array {
			var member:MemberVO;
			var obj:Object;
			var returnArr:Array = [];
			var bool:Boolean;
			for (var i:int = 0; i < allData.length; i++) {
				obj = allData[i];
				for (var j:int = 0; j < members.length; j++) {
					member = members[j];
					if("uid" in obj && obj["uid"] == member.uid){
						bool = true;
						continue;
					}

				}
				if(bool==false){
					returnArr.push(obj);
				}
			}
			returnArr = returnArr.concat(members);
			return returnArr;
		}
		
		private function checkForEmptyClipNeed():void {
			echo("InnerContactScreen", "checkForEmptyClipNeed");
			if (list.data == null || list.data.length == 0) {
				showEmptyClip();
				return;
			}
			hideEmptyClip();
		}
		
		private function showPreloader():void {
			echo("InnerContactScreen", "showPreloader", "");
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
				preloader.y = (_height + list.getStartVerticalSpace()) * .5;
			}
		}

		public function get posY():int {
			return _posY;
		}

		public function set posY(value:int):void {
			_posY = value;
		}
		
		override public function getAdditionalDebugInfo():String {
			return "InnerChatScreen > " + selectedFilter;
		}
	}
}