package com.dukascopy.connect.sys.chatManager.typesManagers {
	
	import com.dukascopy.connect.data.ErrorMessages;
	import com.dukascopy.connect.data.ResponseResolver;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.applicationShop.commodity.Commodity;
	import com.dukascopy.connect.sys.applicationShop.parser.ShopProductDataParser;
	import com.dukascopy.connect.sys.applicationShop.product.ProductCost;
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDuration;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDurationType;
	import com.dukascopy.connect.sys.applicationShop.serverTask.PaidChannelRequestData;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.ChatUsersCollection;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.sys.sqlite.SQLRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.sys.ws.WSMethodType;
	import com.dukascopy.connect.sys.ws.WSMethodType;
	import com.dukascopy.connect.type.ActionType;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.utils.ArrayUtils;
	import com.dukascopy.connect.vo.chat.QuestionUserReactions;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.ChatSettingsRemote;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.utils.getTimer;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov
	 */
	
	public class ChannelsManager {
		
		static public const CHANNEL_SETTINGS_INFO:String = "info";
		static public const CHANNEL_SETTINGS_MODE:String = "mode";
		static public const CHANNEL_SETTINGS_BACKGROUND:String = "back";
		static public const CHANNEL_SETTINGS_COVER:String = "cover";
		static public const CHANNEL_SETTINGS_CATEGORIES:String = "categories";
		static public const CHANNEL_SETTINGS_LANGUAGES:String = "languages";
		static public const CHANNEL_SETTINGS_RESTRICTED:String = "restricted";
		
		static public const CHANNEL_MODE_MODERATORS:String = "moderated";
		static public const CHANNEL_MODE_NONE:String = "owner";
		static public const CHANNEL_MODE_ALL:String = "all";
		
		static public const CHANNEL_WRITE_MODE_STARS:String = "stars";
		
		static public const EVENT_MODERATOR_ADDED:String = "eventModeratorAdded";
		static public const EVENT_MODERATOR_REMOVED:String = "eventModeratorRemoved";
		static public const EVENT_ADDED_TO_MODERATORS:String = "eventAddedToModerators";
		static public const EVENT_REMOVED_FROM_MODERATORS:String = "eventRemovedFromModerators";
		static public const EVENT_KICKED:String = "eventKicked";
		static public const EVENT_BACKGROUND_CHANGED:String = "eventBackgroundChanged";
		static public const EVENT_AVATAR_CHANGED:String = "eventAvatarChanged";
		static public const EVENT_TITLE_CHANGED:String = "eventTitleChanged";
		static public const EVENT_BANNED:String = "eventBanned";
		static public const EVENT_UNBAN:String = "eventUnban";
		static public const EVENT_MODE_CHANGED:String = "eventModeChanged";
		static public const EVENT_STATUS_CHANGED:String = "eventStatusChanged";
		
		static public const CHANNEL_MAX_LOCAL_STORE_MESSAGES_NUM:int = 100;
		
		//TODO: придумать как засунуть в Lang;
		static private var _emptyChannelVO:ChatVO;
		
		static private var channels:Array/*ChatVO*/
		static private var trashChannels:Array/*ChatVO*/
		static private var channelsGetted:Boolean = false;
		static private var busy:Boolean;
		static private var sortFunction:Function;
		static private var filteredChannels:Array;
		static private var currentHash:String;
		static private var lastUpdateTime:Number = 0;
		static private var flagInOut:Boolean;
		static private var trashChannelsGetted:Boolean;
		static private var busyTrash:Boolean;
		static private var lastTrashUpdateTime:int;
		static private var currentTrashHash:String;
		
		static public var S_CHANNELS:Signal = new Signal('ChannelManager.S_CHANNELS');
		static public var S_CHANNEL_UPDATED:Signal = new Signal('ChannelManager.S_CHANNEL_UPDATED');
		static public var S_CHANNEL_SETTINGS_UPDATED:Signal = new Signal('ChannelManager.S_CHANNEL_SETTINGS_UPDATED');
		static public var S_CHANNEL_MODERATORS_UPDATED:Signal = new Signal('ChannelManager.S_CHANNEL_MODERATORS_UPDATED');
		
		static public var S_BANS_LIST_UPDATE:Signal = new Signal('ChannelManager.S_BANS_LIST_UPDATE');
		
		static public var S_LOAD_ALL_START:Signal = new Signal('ChannelManager.S_LOAD_ALL_START');
		static public var S_LOAD_ALL_STOP:Signal = new Signal('ChannelManager.S_LOAD_ALL_STOP');
		
		static public var S_LOAD_TRASH_START:Signal = new Signal('ChannelManager.S_LOAD_TRASH_START');
		static public var S_LOAD_TRASH_STOP:Signal = new Signal('ChannelManager.S_LOAD_TRASH_STOP');
		
		static public const S_TOP_REACTIONS_LOADED_FROM_PHP:Signal = new Signal("QuestionsManager.S_TOP_REACTIONS_LOADED_FROM_PHP");
		
		public function ChannelsManager() { }
		
		static public function init():void {
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
			WSClient.S_CHANNEL_UPDATE.add(onChannelUpdateEvent);
			
			sortFunction = function(a:ChatVO, b:ChatVO):int {
				var value:int = 0;
				
				if (a == null || a.channelData == null) value = 1;
				if (b == null || b.channelData == null) value = -1;
				
				if (a.channelData != null && b.channelData != null) {
					if (a.channelData.subscribed == true && b.channelData.subscribed == true) {
						if (a.getPrecenceDate().getTime() < b.getPrecenceDate().getTime())
							value = 1;
						else
							value = -1;
					}
					else if(a.channelData.subscribed == true) {
						value = -1;
					}
					else if(b.channelData.subscribed == true) {
						value = 1;
					}
					else {
						if (a.getPrecenceDate().getTime() < b.getPrecenceDate().getTime())
							value = 1;
						else
							value = -1;
					}
				}
				
				return value;
			}
		}
		
		static private function onAuthNeeded():void 
		{
			clearChats();
		}
		
		static private function clearChats():void 
		{
			if (channels != null)
			{
				var l:int = channels.length;
				for (var j:int = 0; j < l; j++) {
					if (channels[j] != ChatManager.getCurrentChat() && channels[j] != _emptyChannelVO) {
						channels[j].dispose();
					}
				}
				channels = null;
			}
		}
		
		public static function get allChannels() :Array {
			return channels;
		}
		
		private static function get emptyChannelVO ():ChatVO {
			if (_emptyChannelVO == null) 
				_emptyChannelVO = new ChatVO( { type:"public", title:Lang.addNewChannel, ownerID:Auth.uid} );
			return _emptyChannelVO;
		}
		
		static private function onChannelUpdateEvent(updateEventType:String, channelUID:String, data:Object):void {
			var channel:ChatVO;
			var channelName:String = "";
			switch(updateEventType) {
				case EVENT_MODERATOR_ADDED: {
					channel = getChannel(channelUID);
					if (channel != null && data is ChatUserVO) {
						(data as ChatUserVO).setRole(ChatUserVO.ROLE_MODERATOR);
						channel.addUser(data as ChatUserVO);
						S_CHANNEL_MODERATORS_UPDATED.invoke(EVENT_MODERATOR_ADDED, channelUID);
					}
					
					if (data.uid == Auth.uid)
					{
						if (channel) {
							channelName = " :" + channel.title;
						}
						ToastMessage.display(Lang.youPromotedToModerator + channelName);
						S_CHANNEL_MODERATORS_UPDATED.invoke(EVENT_ADDED_TO_MODERATORS, channelUID);
					}
					break;
				}
				case EVENT_MODERATOR_REMOVED: {
					channel = getChannel(channelUID);
					if (channel) {
						channel.removeUser(data as String);
						S_CHANNEL_MODERATORS_UPDATED.invoke(EVENT_MODERATOR_REMOVED, channelUID);
					}
					
					if (data == Auth.uid)
					{
						if (channel) {
							channelName = " :" + channel.title;
						}
						ToastMessage.display(Lang.youNotLongerModerator + channelName);
						S_CHANNEL_MODERATORS_UPDATED.invoke(EVENT_REMOVED_FROM_MODERATORS, channelUID);
					}
					
					break;
				}
				case EVENT_KICKED: {
					if ((data as String) == Auth.uid) {
						ToastMessage.display(Lang.youKickedFromChannel);
						ChatManager.S_ERROR_CANT_OPEN_CHAT.invoke(ActionType.CHAT_CLOSE_ON_ERROR);
						ChatManager.closeChat();
					}
					
					break;
				}
				case EVENT_BANNED: {
					if ((data is UserBanData) && (data as UserBanData).uid == Auth.uid) {
						ToastMessage.display(Lang.youBanned);
						Auth.addBan(channelUID, data as UserBanData);
						ChatManager.S_BANNED_IN_CHAT.invoke(channelUID, data as UserBanData);
					}
					else
					{
						S_BANS_LIST_UPDATE.invoke(channelUID);
					}
					
					break;
				}
				case EVENT_UNBAN: {
					if ((data as String) == Auth.uid) {
						ToastMessage.display(Lang.youUnbanned);
						Auth.removeBan(channelUID);
						ChatManager.S_UNBANNED_IN_CHAT.invoke(channelUID);
					}
					else
					{
						S_BANS_LIST_UPDATE.invoke(channelUID);
					}
					
					break;
				}
				case EVENT_BACKGROUND_CHANGED: {
					var newBackId:String = data as String;
					channel = getChannel(channelUID);
					if (channel && channel.settings.background != newBackId) {
						channel.settings.background = newBackId;
						S_CHANNEL_SETTINGS_UPDATED.invoke(EVENT_BACKGROUND_CHANGED, channelUID);
					}
					break;
				}
				case EVENT_AVATAR_CHANGED: {
					var newAvatar:String = data as String;
					channel = getChannel(channelUID);
					if (channel && channel.avatar != newAvatar) {
						channel.avatar = newAvatar;
						S_CHANNEL_SETTINGS_UPDATED.invoke(EVENT_AVATAR_CHANGED, channelUID);
						S_CHANNEL_UPDATED.invoke(channel);
					}
					break;
				}
				case EVENT_TITLE_CHANGED: {
					var newTitle:String = data as String;
					channel = getChannel(channelUID);
					if (channel && channel.title != newTitle) {
						channel.title = newTitle;
						S_CHANNEL_SETTINGS_UPDATED.invoke(EVENT_TITLE_CHANGED, channelUID);
						S_CHANNEL_UPDATED.invoke(channel);
					}
					break;
				}
				case EVENT_MODE_CHANGED: {
					var newMode:String = data as String;
					channel = getChannel(channelUID);
					if (channel) {
						channel.settings.mode = newMode;
						S_CHANNEL_SETTINGS_UPDATED.invoke(EVENT_MODE_CHANGED, channelUID);
					}
					break;
				}
			}
		}
		
		static public function getChannel(chatUID:String):ChatVO {
			if (channels == null)
				return null;
			for (var i:int = 0; i < channels.length; i++)
				if (channels[i].uid == chatUID)
					return channels[i];
			if (trashChannels != null)
			{
				for (var i2:int = 0; i2 < trashChannels.length; i2++)
				if (trashChannels[i2].uid == chatUID)
					return trashChannels[i2];
			}
			
			return null;
		}
		
		static public function addChannelFromServer(data:Object):void
		{
			if (data != null){
				if (data.senderUID == Auth.uid)
					return;
				PHP.chat_get(onChannelLoadedFromPHP, data.cuid, true, true, "addChannelFromServer");
			}
		}
		
		static private function onChannelLoadedFromPHP(phpRespond:PHPRespond):ChatVO {
			echo("ChannelManager", "onChannelLoadedFromPHP");
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.22') != -1) {
					var parser:ShopProductDataParser = new ShopProductDataParser();
					var product:ShopProduct = parser.parse(phpRespond.data.data, new ProductType(ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION));
					if (product != null) {
						var chatUID:String;
						if (product.targetData != null && product.targetData is ChatVO) {
							chatUID = (product.targetData as ChatVO).uid;
						}
						if (chatUID != null) {
							Shop.buyChannelAccess(chatUID, product);
						}
					}
					phpRespond.dispose();
					return null;
				}
				echo("ChannelManager", "onChannelLoadedFromPHP", "ERROR: " + phpRespond.errorMsg);
				if (phpRespond.errorMsg.toLowerCase().indexOf('chat.03') != -1) {
					phpRespond.dispose();
					return null;
				}
			}
			if ("data" in phpRespond && phpRespond.data == null) {
				echo("ChannelManager", "onChannelLoadedFromPHP", "ERROR: Data is null");
				phpRespond.dispose();
				return null;
			}
			var cVO:ChatVO = getChannel(phpRespond.data.uid);
			if (cVO == null) {
				cVO = new ChatVO(phpRespond.data);
				addNewChannel(cVO);
			} else
				cVO.setData(phpRespond.data);
			phpRespond.dispose();
			
			return cVO;
		}
		
		static public function addNewChannel(cvo:ChatVO):void {
			if (cvo == null)
				return;
			if (channels == null)
				channels = [emptyChannelVO];
			var existingChat:ChatVO = getChannel(cvo.uid);
			if (existingChat != null)
				existingChat.setData(cvo.getRawData());
			else
				channels.splice(1, 0, cvo);
			refreshChannelsList();
		}
		
		static public function getChannels():void {
			if (busy)
				return;
			echo("ChannelManager", "getChannels");
			if (channelsGetted == false) {
				busy = true;
				getChannelsFromStore();
			}
			else {
				S_CHANNELS.invoke();
				updateDataFromPHP();
			}
		}
		
		static private function updateDataFromPHP():void {
			if ((getTimer() - lastUpdateTime)/1000 > 15){
				lastUpdateTime = getTimer();
				getChannelsFromPHP();
			}
		}
		
		static public function getTrashChannels():Array {
			if (trashChannels == null)
				trashChannels = [emptyChannelVO];
			if (trashChannelsGetted == false)
				loadTrashChannels();
			
			return trashChannels;
		}
		
		static public function loadTrashChannels():void {
			if (busyTrash)
				return;
			echo("ChannelManager", "loadTrashChannels");
			if (trashChannelsGetted == false) {
				busyTrash = true;
				getTrashChannelsFromStore();
			}
			else {
				S_CHANNELS.invoke();
				updateTrashDataFromPHP();
			}
		}
		
		static private function updateTrashDataFromPHP():void {
			if ((getTimer() - lastTrashUpdateTime)/1000 > 15){
				lastTrashUpdateTime = getTimer();
				getTrashChannelsFromPHP();
			}
		}
		
		static private function getTrashChannelsFromStore():void {
			if (trashChannelsGetted == false) {
				echo("ChannelManager","getTrashChannelsFromStore");
				Store.load(Store.VAR_CHANNELS_TRASH, onTrashStoreChannelsLoaded);
				return;
			} else
			{
				S_CHANNELS.invoke();
				busyTrash = false;
			}
		}
		
		static private function onTrashStoreChannelsLoaded(data:Object, err:Boolean):void {
			if (err == true || data == null) {
				getTrashChannelsFromPHP();
				return;
			}
			
			trashChannels = [];
			
			var i:int;
			var chat:ChatVO;
			if (data.all != null && data.all.length != 0) {
				for (i = 0; i < data.all.length; i++) {
					chat = new ChatVO(data.all[i]);
					chat.inTrash = true;
					trashChannels.push(chat);
				}
			}
			
			trashChannels.sort(sortFunction);
			
			trashChannels.unshift(emptyChannelVO);
			
			onTrashChannelsLoaded(false);
			ChannelsManager.S_CHANNELS.invoke();
			if ("hash" in data)
				currentTrashHash = data.hash;
			
			getTrashChannelsFromPHP();
		}
		
		static private function onTrashChannelsLoaded(fromPhp:Boolean):void 
		{
			NewMessageNotifier.setInitialData(NewMessageNotifier.type_CHANNELS_TRASH, trashChannels, fromPhp, false);
		}
		
		static private function getTrashChannelsFromPHP():void {
			S_LOAD_TRASH_START.invoke();
			PHP.call_irc_trash(onTrashChannelsGetted, currentTrashHash + "123");
		}
		
		static private function onTrashChannelsGetted(phpRespond:PHPRespond):void {
			busyTrash = false;
			S_LOAD_TRASH_STOP.invoke();
			if (phpRespond.error) {
				echo("ChannelManager", "onTrashChannelsGetted", "PHP ERROR -> " + phpRespond.errorMsg);
				phpRespond.dispose();
				return;
			}
			trashChannelsGetted = true;
			if (phpRespond.data == null) {
				phpRespond.dispose();
				return;
			}
			
			if (trashChannels == null) {
				trashChannels = new Array();
			}
			
			var cVO:ChatVO;
			var newChannels:Array = new Array();
			
			var i:int;
			var index:int;
			if ("all" in phpRespond.data && phpRespond.data.all != null && phpRespond.data.all.length != 0) {
				for (i = 0; i < phpRespond.data.all.length; i++) {
					cVO = getChannel(phpRespond.data.all[i].uid);
					if (cVO != null)
					{
						cVO.setData(phpRespond.data.all[i]);
						index = trashChannels.indexOf(cVO);
						if (index != -1) {
							trashChannels.removeAt(index);
						}
						cVO.inTrash = true;
						newChannels.push(cVO);
					}
					else
					{
						cVO = new ChatVO(phpRespond.data.all[i]);
						cVO.inTrash = true;
						newChannels.push(cVO);
					}
				}
			}
			
			newChannels.sort(sortFunction);
			newChannels.unshift(emptyChannelVO);
			
			var l:int = trashChannels.length;
			for (var j:int = 0; j < l; j++) {
				if (trashChannels[j] != ChatManager.getCurrentChat() && trashChannels[j] != _emptyChannelVO) {
					trashChannels[j].dispose();
				}
			}
			trashChannels = null;
			trashChannels = newChannels;
			
			if ("hash" in phpRespond.data && phpRespond.data.hash != null) {
				if (currentHash != phpRespond.data.hash){
				}
				currentTrashHash = phpRespond.data.hash;
				Store.save(Store.VAR_TRASH_CHANNELS_HASH, phpRespond.data.hash);
			}
			Store.save(Store.VAR_CHANNELS_TRASH, phpRespond.data);
			onTrashChannelsLoaded(true);
			S_CHANNELS.invoke();
			phpRespond.dispose();
		}
		
		static public function getAllChannels():Array {
			if (channels == null)
				channels = [emptyChannelVO];
			if (channelsGetted == false)
				getChannels();
			
			if (channels != null) {
				if (filteredChannels == null) {
					filteredChannels = new Array();
				}
				filteredChannels.length = 0;
				
				var l:int = channels.length;
				for (var i:int = 0; i < l; i++) {
					if (channels[i].questionID == null || channels[i].questionID == "") {
						filteredChannels.push(channels[i]);
					}
				}
				return filteredChannels;
			}
			else {
				return null;
			}
		}
		
		static private function getChannelsFromStore():void {
			if (channelsGetted == false) {
				echo("ChannelManager","getChannelsFromStore");
				Store.load(Store.VAR_CHANNELS, onStoreChannelsLoaded);
				return;
			} else
			{
				S_CHANNELS.invoke();
				busy = false;
			}
		}
		
		static private function onStoreChannelsLoaded(data:Object, err:Boolean):void {
			if (err == true || data == null) {
				getChannelsFromPHP();
				return;
			}
			
			channels = [];
			
			var i:int;
			if ("my" in data && data.my != null && data.my.length != 0) {
				for (i = 0; i < data.my.length; i++) {
					channels.push(new ChatVO(data.my[i]));
				}
			}
			if ("all" in data && data.all != null && data.all.length != 0) {
				for (i = 0; i < data.all.length; i++) {
					channels.push(new ChatVO(data.all[i]));
				}
			}
			
			channels.sort(sortFunction);
			
			channels.unshift(emptyChannelVO);
			
			onChannelsLoaded(false);
			ChannelsManager.S_CHANNELS.invoke();
			if ("hash" in data)
				currentHash = data.hash;
			
			getChannelsFromPHP();
		}
		
		static private function onChannelsLoaded(fromPhp:Boolean):void 
		{
			NewMessageNotifier.setInitialData(NewMessageNotifier.type_CHANNELS, channels, fromPhp, false);
		}
		
		static private function getChannelsFromPHP():void {
			S_LOAD_ALL_START.invoke();
			PHP.channelGet(onChannelsGetted, currentHash + "123");
		}
		
		static private function onChannelsGetted(phpRespond:PHPRespond):void {
			S_LOAD_ALL_STOP.invoke();
			busy = false;
			if (phpRespond.error) {
				echo("ChannelManager", "onChannelsGetted", "PHP ERROR -> " + phpRespond.errorMsg);
				phpRespond.dispose();
				return;
			}
			channelsGetted = true;
			if (phpRespond.data == null) {
				phpRespond.dispose();
				return;
			}
			
			if (channels == null) {
				channels = new Array();
			}
			
			var cVO:ChatVO;
			var newChannels:Array = new Array();
			
			var i:int;
			var index:int;
			if ("my" in phpRespond.data && phpRespond.data.my != null && phpRespond.data.my.length != 0) {
				for (i = 0; i < phpRespond.data.my.length; i++) {
					cVO = getChannel(phpRespond.data.my[i].uid);
					if (cVO != null)
					{
						cVO.setData(phpRespond.data.my[i]);
						index = channels.indexOf(cVO);
						if (index != -1) {
							channels.removeAt(index);
						}
						newChannels.push(cVO);
					}
					else
					{
						newChannels.push(new ChatVO(phpRespond.data.my[i]));
					}
				}
			}
			if ("all" in phpRespond.data && phpRespond.data.all != null && phpRespond.data.all.length != 0) {
				for (i = 0; i < phpRespond.data.all.length; i++) {
					cVO = getChannel(phpRespond.data.all[i].uid);
					if (cVO != null)
					{
						cVO.setData(phpRespond.data.all[i]);
						index = channels.indexOf(cVO);
						if (index != -1) {
							channels.removeAt(index);
						}
						newChannels.push(cVO);
					}
					else
					{
						newChannels.push(new ChatVO(phpRespond.data.all[i]));
					}
				}
			}
			
			newChannels.sort(sortFunction);
			newChannels.unshift(emptyChannelVO);
			
			var l:int = channels.length;
			for (var j:int = 0; j < l; j++) {
				if (channels[j] != ChatManager.getCurrentChat() && channels[j] != _emptyChannelVO) {
					channels[j].dispose();
				}
			}
			channels = null;
			channels = newChannels;
			
			if ("hash" in phpRespond.data && phpRespond.data.hash != null) {
				if (currentHash != phpRespond.data.hash){
					trace("NEW", phpRespond.data.hash);
				}
				currentHash = phpRespond.data.hash;
				Store.save(Store.VAR_CHANNELS_HASH, phpRespond.data.hash);
			}
			Store.save(Store.VAR_CHANNELS, phpRespond.data);
			onChannelsLoaded(true);
			S_CHANNELS.invoke();
			phpRespond.dispose();
		}
		
		private function moveFavoritesUp(a:ChatVO, b:ChatVO):int
		{
			if (a.channelData != null && b.channelData != null)
			{
				if (a.channelData.subscribed == true && a.channelData.subscribed == true)
				{
					return 0;
				}
				else if(a.channelData.subscribed == true)
				{
					return 1;
				}
				else
				{
					return -1;
				}
			}
			return 0;
		}
		
		static public function startNewChannel(requestID:String, wallet:String, title:String = null, mode:String = null, settingsValues:Object = null):void {
			//!TODO:;
		//	Shop.S_PRODUCT_BUY_RESPONSE.add();
			
			var product:ShopProduct = Shop.createProduct(new ProductType(ProductType.TYPE_PAID_CHANNEL), requestID);
			product.targetData = new PaidChannelRequestData(title, mode, settingsValues);
			Shop.buyPaidChannelStart(product, requestID, wallet);
		}
		
		/*static public function startNewChannel(title:String = null, mode:String = null, settingsValues:Object = null):void {
			PHP.channelStart(onChannelCreated, title, mode, settingsValues);
		}*/
		
		static private function onChannelCreated(phpRespond:PHPRespond):void {
			if (phpRespond.error) {
				echo("ChannelManager", "onChannelCreated", "PHP ERROR -> " + phpRespond.errorMsg);
				ToastMessage.display(ErrorLocalizer.getText(phpRespond.errorMsg));
				phpRespond.dispose();
				return;
			}
			channels ||= [emptyChannelVO];
			var channel:ChatVO = getChannel(phpRespond.data.uid);
			if (channel == null) {
				channel = new ChatVO(phpRespond.data);
				channels.splice(1, 0, channel);
			}
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.chatVO = channel;
			chatScreenData.type = ChatInitType.CHAT;
			chatScreenData.backScreen = RootScreen;
			MobileGui.showChatScreen(chatScreenData);
			ChannelsManager.S_CHANNELS.invoke();
			
			WSClient.call_blackHoleToGroup("public", "send", "mobile", WSMethodType.CHANNEL_CREATED, { cuid:channel.uid, senderUID:Auth.uid } );
			
			phpRespond.dispose();
		}
		
		static public function updateChannelSettings(resolver:ResponseResolver, chatUID:String, settingsType:String, value:String):void {
			PHP.irc_updateSetting(onChannelSettingsUpdated, chatUID, settingsType, value, resolver);
		}
		
		static private function onChannelSettingsUpdated(phpRespond:PHPRespond):void {
			var addData:ResponseResolver;
			if (phpRespond.additionalData != null && phpRespond.additionalData is ResponseResolver)
				addData = phpRespond.additionalData as ResponseResolver;
			if (phpRespond.error == true) {
				echo("ChannelManager", "updateChannelSettings", "PHP ERROR -> " + phpRespond.errorMsg);
				if (addData != null && addData.callback != null)
					addData.callback(false, addData.data);
				phpRespond.dispose();
				return;
			}
			if (addData != null && addData.callback != null)
				addData.callback(true, addData.data);
			phpRespond.dispose();
		}
		
		static public function channelChangeTitle(responseResolver:ResponseResolver, channelUID:String, value:String):void {
			PHP.irc_changeTopic(onChannelTopicChangeResponse, channelUID, value, responseResolver);
		}
		
		static private function onChannelTopicChangeResponse(phpRespond:PHPRespond):void {
			var addData:ResponseResolver;
			if (phpRespond.additionalData != null && phpRespond.additionalData is ResponseResolver)
				addData = phpRespond.additionalData as ResponseResolver;
			if (phpRespond.error == true) {
				echo("ChannelManager", "onChannelTopicChangeResponse", "PHP ERROR -> " + phpRespond.errorMsg);
				var message:String;
				if (phpRespond.errorMsg == PHP.NETWORK_ERROR)
					message = Lang.alertProvideInternetConnection;
				else
					message = Lang.failedUpdateChannelTitle;
				ToastMessage.display(message);
				if (addData && addData.callback != null)
					addData.callback(false, addData.data);
				phpRespond.dispose();
				return;
			}
			if (addData != null) {
				if (addData.data != null && "chatUID" in addData.data)
					S_CHANNEL_UPDATED.invoke(getChannel(addData.data.chatUID));
				if (addData.callback != null)
					addData.callback(true, addData.data);
			}
			phpRespond.dispose();
		}
		
		static public function addModerator(channelUID:String, userUID:String):void {
			
			WSClient.channel_add_moderator(channelUID, userUID);
		//	PHP.irc_addModerator(onChannelAddModeratorResponse, channelUID, userUID, resolver);
		}
		
		/*static private function onChannelAddModeratorResponse(phpRespond:PHPRespond):void {
			var addData:ResponseResolver;
			if (phpRespond.additionalData != null && phpRespond.additionalData is ResponseResolver)
				addData = phpRespond.additionalData as ResponseResolver;
			if (phpRespond.error == true) {
				echo("ChannelManager", "onChannelAddModeratorResponse", "PHP ERROR -> " + phpRespond.errorMsg);
				if (addData != null && addData.callback != null)
					addData.callback(false, addData.data);
				phpRespond.dispose();
				return;
			}
			if (addData != null) {
				if (addData.data != null && addData.data.channelUID != undefined && addData.data.channelUID != null && addData.data.channelUID != "") {
					var channel:ChatVO = getChannel(addData.data.channelUID);
					if ("userUID" in addData.data && "channelUID" in addData.data) {
						var usersCollection:ChatUsersCollection = ChatManager.chatUsersCollection;
						if (usersCollection.chatUID == addData.data.channelUID) {
							var user:ChatUserVO = usersCollection.getUser(addData.data.userUID);
							if (user) {
								var channelTitle:String = "";
								if (channel)
									channelTitle = channel.title;
								notifyChannelModeratorAdded(addData.data.channelUID, user.user, channelTitle);
							}
						}
					}
				//	if (channel)
				//		channel.addUser(phpRespond.data);
				}
				if (addData.callback != null)
					addData.callback(true, addData.data);
			}
			phpRespond.dispose();
		}*/
		
		/*static private function notifyChannelModeratorAdded(chanelUID:String, userData:UserProfileVO, channelTitle:String):void {
			WSClient.channel_notify_moderator_added(chanelUID, userData, channelTitle);
		}*/
		
		static public function removeModerator(channelUID:String, userUID:String):void {
			
			WSClient.channel_remove_moderator(channelUID, userUID);
		//	PHP.irc_removeModerator(onChannelRemoveModeratorResponse, channelUID, userUID, resolver);
		}
		
		/*static private function onChannelRemoveModeratorResponse(phpRespond:PHPRespond):void {
			var addData:ResponseResolver;
			if (phpRespond.additionalData != null && phpRespond.additionalData is ResponseResolver)
				addData = phpRespond.additionalData as ResponseResolver;
			if (phpRespond.error == true) {
				echo("ChannelManager", "onChannelRemoveModeratorResponse", "PHP ERROR -> " + phpRespond.errorMsg);
				if (addData != null && addData.callback != null)
					addData.callback(false, addData.data);
				phpRespond.dispose();
				return;
			}
			if (addData != null) {
				if (addData.data != null && addData.data.channelUID != undefined && addData.data.channelUID != null && addData.data.channelUID != "") {
					var channel:ChatVO = getChannel(addData.data.channelUID);
					if ("userUID" in addData.data && "channelUID" in addData.data) {
						var channelTitle:String = "";
						if (channel)
							channelTitle = channel.title;
						notifyChannelModeratorRemoved(addData.data.channelUID, addData.data.userUID, channelTitle);
					}
					if (channel)
						channel.removeUser(addData.data.userUID);
				}
				if (addData.callback != null)
					addData.callback(true, addData.data);
			}
			phpRespond.dispose();
		}*/
		
		/*static private function notifyChannelModeratorRemoved(chanelUID:String, userUID:String, channelTitle):void {
			WSClient.channel_notify_moderator_removed(chanelUID, userUID, channelTitle);
		}*/
		
		static public function getBannedUsers(channelUID:String):void {
			var resolver:ResponseResolver = new ResponseResolver();
			resolver.data = channelUID;
			PHP.irc_getBans(onChannelBansLoaded, channelUID, resolver);
		}
		
		static private function onChannelBansLoaded(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				var message:String;
				if (phpRespond.errorMsg == PHP.NETWORK_ERROR)
					message = Lang.alertProvideInternetConnection;
				else
					message = phpRespond.errorMsg;
				ToastMessage.display(message);
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data && (phpRespond.data is Array) && phpRespond.additionalData && (phpRespond.additionalData is ResponseResolver) && (phpRespond.additionalData as ResponseResolver).data) {
				var users:Array = new Array();
				var l:int = (phpRespond.data as Array).length;
				var user:ChatUserVO;
				for (var i:int = 0; i < l; i++) {
					user = new ChatUserVO((phpRespond.data as Array)[i]);
					if (("banInfo" in (phpRespond.data as Array)[i]) && (phpRespond.data as Array)[i].banInfo != null) {
						user.banned = true;
						user.banData = new UserBanData();
						user.banData.banCreatedTime = (phpRespond.data as Array)[i].banInfo.created;
						user.banData.banEndTime = (phpRespond.data as Array)[i].banInfo.canceled;
						user.banData.reason = (phpRespond.data as Array)[i].banInfo.reason;
						user.banData.moderator = (phpRespond.data as Array)[i].banInfo.moderator;
					}
					users.push(user);
				}
				S_BANS_LIST_UPDATE.invoke((phpRespond.additionalData as ResponseResolver).data, users);
			}
			phpRespond.dispose();
		}
		
		static public function getChannelSettingsFromServer(channelUID:String, resolver:ResponseResolver):void {
			PHP.irc_getSettings(onChannelSettingsLoaded, channelUID, resolver);
		}
		
		static private function onChannelSettingsLoaded(phpRespond:PHPRespond):void {
			var addData:ResponseResolver;
			if (phpRespond.additionalData != null && phpRespond.additionalData is ResponseResolver)
				addData = phpRespond.additionalData as ResponseResolver;
			if (phpRespond.error == true) {
				echo("ChannelManager", "onChannelSettingsLoaded", "PHP ERROR -> " + phpRespond.errorMsg);
				if (addData != null && addData.callback != null)
					addData.callback(false, addData.data);
				phpRespond.dispose();
				return;
			}
			if (addData != null && addData.callback != null) {
				addData.data.settings = new ChatSettingsRemote(phpRespond.data);
				addData.callback(true, addData.data);
			}
			phpRespond.dispose();
		}
		
		static public function banUser(channelUid:String, userUid:String, userBanData:UserBanData):void {
			WSClient.channel_user_ban(channelUid, userUid, userBanData.reason, userBanData.getDurationTime());
		}
		
		static public function unbanUser(channelUid:String, userUid:String):void {
			WSClient.channel_user_unban(channelUid, userUid);
		}
		
		static public function kickUser(channelUid:String, userUid:String):void {
			WSClient.channel_user_kick(channelUid, userUid);
		}
		
		static public function channelBackgroundChanged(channelUid:String, background:String):void {
			WSClient.channel_notify_background_changed(channelUid, background);
		}
		
		static public function channelAvatarChanged(channelUid:String, avatar:String):void {
			WSClient.channel_notify_avatar_changed(channelUid, avatar);
		}
		
		static public function channelTitleChanged(channelUid:String, title:String):void {
			WSClient.channel_notify_title_changed(channelUid, title);
		}
		
		static public function updateChannelMode(channelUid:String, newValue:String):void {
			WSClient.channel_change_mode(channelUid, newValue);
		}
		
		static public function onChannelClosed(channelUid:String):void {
			//keep max 100 messages in database;
			SQLite.call_limitMessagesInChat(onChannelMessagesTrimmed, channelUid, CHANNEL_MAX_LOCAL_STORE_MESSAGES_NUM);
		}
		
		static public function removeChannel(channelUID:String):Boolean {
			//удаление канала локальное;
			if (channelUID == null) {
				return false;
			}
			var l:int;
			if (channels != null)
			{
				l = channels.length;
				for (var i:int = 0; i < l; i++)
				{
					if (channels[i].uid == channelUID)
					{
						channels[i].dispose();
						channels.splice(i, 1);
						S_CHANNELS.invoke();
						removeChannelFromStore(channelUID);
						return true;
					}
				}
			}
			if (trashChannels != null)
			{
				l = trashChannels.length;
				for (var i2:int = 0; i2 < l; i2++)
				{
					if (trashChannels[i2].uid == channelUID)
					{
						trashChannels[i2].dispose();
						trashChannels.splice(i2, 1);
						S_CHANNELS.invoke();
						removeTrashChannelFromStore(channelUID);
						return true;
					}
				}
			}
			
			return false;
		}
		
		static private function removeTrashChannelFromStore(channelUID:String):void 
		{
			Store.load(Store.VAR_CHANNELS_TRASH, function(data:Object, err:Boolean):void {
				if (err == true || data == null)
					return;
				var l:int;
				if ("all" in data && data.all != null) {
					l = data.all.length;
					for (var k:int = 0; k < l; k++) {
						if (data.all[k].uid == channelUID) {
							data.all.splice(k, 1);
							if ("hash" in data)
							{
								data.hash = "123";
							}
							Store.save(Store.VAR_CHANNELS_TRASH, data);
							return;
						}
					}
				}
			});
		}
		
		static private function removeChannelFromStore(channelUID:String):void 
		{
			Store.load(Store.VAR_CHANNELS, function(data:Object, err:Boolean):void {
				if (err == true || data == null)
					return;
				var l:int;
				if ("my" in data && data.my != null) {
					l = data.my.length;
					for (var i:int = 0; i < l; i++) {
						if (data.my[i].uid == channelUID) {
							data.my.splice(i, 1);
							if ("hash" in data)
							{
								data.hash = "123";
							}
							Store.save(Store.VAR_CHANNELS, data);
							return;
						}
					}
				}
				if ("all" in data && data.all != null) {
					l = data.all.length;
					for (var k:int = 0; k < l; k++) {
						if (data.all[k].uid == channelUID) {
							data.all.splice(k, 1);
							if ("hash" in data)
							{
								data.hash = "123";
							}
							Store.save(Store.VAR_CHANNELS, data);
							return;
						}
					}
				}
			});
		}
		
		static public function deleteChannel(channelUID:String, callback:Function):void
		{
			//запрос на удаление канала на сервер;
			var resolver:ResponseResolver = new ResponseResolver();
			resolver.data = channelUID;
			resolver.callback = callback;
			PHP.irc_remove(onChannelDeleted, channelUID, resolver);
		}
		
		static private function onChannelDeleted(phpRespond:PHPRespond):void 
		{
			var addData:ResponseResolver;
			if (phpRespond.additionalData != null && phpRespond.additionalData is ResponseResolver)
				addData = phpRespond.additionalData as ResponseResolver;
			if (phpRespond.error == true) {
				echo("ChannelManager", "onChannelSettingsLoaded", "PHP ERROR -> " + phpRespond.errorMsg);
				if (addData != null)
				{
					if (addData.callback != null)
					{
						var errorMessage:String = ErrorMessages.getLocal(phpRespond.errorMsg);
						if (errorMessage == null)
						{
							errorMessage = Lang.errorRemoveChannel;
						}
						addData.callback(false, addData.data, errorMessage);
					}
					addData.dispose();
				}
				phpRespond.dispose();
				return;
			}
			if (addData != null)
			{
				if (addData.callback != null)
				{
					addData.callback(true, addData.data);
				}
				
				WSClient.call_blackHoleToGroup("public", "send", "mobile", WSMethodType.CHANNEL_CLOSED, { cuid:addData.data, senderUID:Auth.uid } );
				
				removeChannel(addData.data as String);
				addData.dispose();
			}
			phpRespond.dispose();
		}
		
		static public function unsubscribe(channelUID:String, callback:Function):void 
		{
			var resolver:ResponseResolver = new ResponseResolver();
			resolver.data = channelUID;
			resolver.callback = callback;
			PHP.irc_unsubscribe(onChannelUnsubscribeResponse, channelUID, resolver);
		}
		
		static private function onChannelUnsubscribeResponse(phpRespond:PHPRespond):void 
		{
			var addData:ResponseResolver;
			if (phpRespond.additionalData != null && phpRespond.additionalData is ResponseResolver)
				addData = phpRespond.additionalData as ResponseResolver;
			if (phpRespond.error == true) {
				echo("ChannelManager", "onChannelSettingsLoaded", "PHP ERROR -> " + phpRespond.errorMsg);
				if (addData != null)
				{
					if (addData.callback != null)
					{
						var errorMessage:String = ErrorMessages.getLocal(phpRespond.errorMsg);
						if (errorMessage == null)
						{
							errorMessage = Lang.errorUnubscribeChannel;
						}
						addData.callback(false, addData.data, errorMessage);
					}
					addData.dispose();
				}
				phpRespond.dispose();
				return;
			}
			if (addData != null)
			{
				if (addData.callback != null)
				{
					addData.callback(true, addData.data);
				}
				
				var channel:ChatVO = getChannel(addData.data as String);
				if (channel != null && channel.channelData != null)
				{
					channel.channelData.subscribed = false;
				}
				addData.dispose();
				
				refreshChannelsList();
			}
			phpRespond.dispose();
		}
		
		static public function subscribe(channelUID:String, callback:Function):void 
		{
			var resolver:ResponseResolver = new ResponseResolver();
			resolver.data = channelUID;
			resolver.callback = callback;
			PHP.irc_subscribe(onChannelSubscribeResponse, channelUID, resolver);
		}
		
		static private function onChannelSubscribeResponse(phpRespond:PHPRespond):void 
		{
			var addData:ResponseResolver;
			if (phpRespond.additionalData != null && phpRespond.additionalData is ResponseResolver)
				addData = phpRespond.additionalData as ResponseResolver;
			if (phpRespond.error == true) {
				echo("ChannelManager", "onChannelSettingsLoaded", "PHP ERROR -> " + phpRespond.errorMsg);
				if (addData != null)
				{
					if (addData.callback != null)
					{
						var errorMessage:String = ErrorMessages.getLocal(phpRespond.errorMsg);
						if (errorMessage == null)
						{
							errorMessage = Lang.errorUnubscribeChannel;
						}
						addData.callback(false, addData.data, errorMessage);
					}
					addData.dispose();
				}
				phpRespond.dispose();
				return;
			}
			if (addData != null)
			{
				if (addData.callback != null)
				{
					addData.callback(true, addData.data);
				}
				
				var channel:ChatVO = getChannel(addData.data as String);
				if (channel != null && channel.channelData != null)
				{
					channel.channelData.subscribed = true;
				}
				addData.dispose();
				
				refreshChannelsList();
			}
			phpRespond.dispose();
		}
		
		static private function refreshChannelsList():void {
			if (channels == null){
				return;
			}
			if (channels.indexOf(emptyChannelVO) != -1){
				channels.removeAt(channels.indexOf(emptyChannelVO));
			}
			channels.sort(sortFunction);
			channels.unshift(emptyChannelVO);
			
			ChannelsManager.S_CHANNELS.invoke();
		}
		
		static private function onChannelMessagesTrimmed(respond:SQLRespond):void {
			
		}
		
		static public function getQuestionTopReactions(chatUID:String):void {
			echo("ChannelsManager", "getQuestionTopReactions", "START");
			if (chatUID == null || chatUID == "") {
				echo("ChannelsManager", "getQuestionTopReactions", "chatUID UID IS NULL");
				return;			
			}
			PHP.question_top_reactions(onQuestionReactionsLoadedFromPHP, chatUID);
			echo("ChannelsManager", "getQuestionTopReactions", "END");
		}
		
		static public function listenChannelsChanges():void {
			setInOut(true);
		}
		
		static public function stopListenChannelsChanges():void {
			setInOut(false);
		}
		
		static public function setInOut(val:Boolean, obligatory:Boolean = false):void {
			if (flagInOut == val && obligatory == false)
				return;
			flagInOut = val;
			var needToResendInOut:Boolean;
			if (flagInOut == true) {
			//	needToRefresh = true;
				
				needToResendInOut = !WSClient.call_blackHoleToGroup("public", "subscribe");
				
				WSClient.S_CHANNEL_NEW.add(addChannelFromServer);
				WSClient.S_CHANNEL_CLOSED.add(onChannelClosedFromServer);
			} else {
				needToResendInOut = !WSClient.call_blackHoleToGroup("public", "unsubscribe");
				
				WSClient.S_CHANNEL_NEW.remove(addChannelFromServer);
				WSClient.S_CHANNEL_CLOSED.remove(onChannelClosedFromServer);
			}
			
			if (needToResendInOut == true)
				WS.S_CONNECTED.add(resendInOut);
		}
		
		static public function isChannelInTrash(chatUID:String):Boolean
		{
			if (channels == null)
			{
				return false;
			}
			for (var i:int = 0; i < channels.length; i++)
				if (channels[i].uid == chatUID)
					return false;
			if (trashChannels != null)
			{
				for (var i2:int = 0; i2 < trashChannels.length; i2++)
				if (trashChannels[i2].uid == chatUID)
					return true;
			}
			return false;
		}
		
		static public function changeChannelStatus(channelUID:String):void 
		{
			var param:String;
			if (isChannelInTrash(channelUID))
			{
				param = "on";
			}
			else
			{
				param = "off";
			}
			
			PHP.call_inspectIRC(onChannelStatusChangeRespond, channelUID, param);
		}
		
		static private function onChannelStatusChangeRespond(phpRespond:PHPRespond):void {
			echo("ChannelManager", "onChannelLoadedFromPHP");
			if (phpRespond.error) {
				
				var errorMessage:String = ErrorLocalizer.getText(phpRespond.errorMsg);
				ToastMessage.display(errorMessage);
				phpRespond.dispose();
				return;
			}
			var channelToMove:ChatVO;
			if (phpRespond.additionalData != null)
			{
				var channelUID:String = phpRespond.additionalData.channelUID
				if (channelUID != null)
				{
					if (phpRespond.additionalData.status == "off")
					{
						if (channels != null)
						{
							var l:int = channels.length;
							for (var i:int = 0; i < l; i++) 
							{
								if (channels[i].uid == channelUID)
								{
									channelToMove = channels.removeAt(i);
									break;
								}
							}
							if (channelToMove != null)
							{
								if (trashChannels == null)
								{
									trashChannels = [emptyChannelVO];
								}
								channelToMove.inTrash = true;
								trashChannels.push(channelToMove);
							}
						}
					}
					else if (phpRespond.additionalData.status == "on")
					{
						if (trashChannels != null)
						{
							var l2:int = trashChannels.length;
							for (var i2:int = 0; i2 < l2; i2++) 
							{
								if (trashChannels[i2].uid == channelUID)
								{
									channelToMove = trashChannels.removeAt(i2);
									break;
								}
							}
							if (channelToMove != null)
							{
								if (channels == null)
								{
									channels = [emptyChannelVO];
								}
								channelToMove.inTrash = false;
								channels.push(channelToMove);
							}
						}
					}
				}
				else{
					ApplicationErrors.add();
				}
			}
			
			S_CHANNEL_SETTINGS_UPDATED.invoke(EVENT_STATUS_CHANGED, channelUID);
			S_CHANNELS.invoke();
			phpRespond.dispose();
		}
		
		static private function onChannelClosedFromServer(data:Object):void 
		{
			if (data != null){
				if (data.senderUID == Auth.uid)
					return;
				
				var channel:ChatVO = getChannel(data.cuid);
				if (channel != null){
					if (channel == ChatManager.getCurrentChat()){
						ChatManager.S_ERROR_CANT_OPEN_CHAT.invoke(ActionType.CHAT_CLOSE_ON_ERROR);
						ChatManager.closeChat(channel);
					}
					var index:int = channels.indexOf(channel);
					if (index != -1){
						channels.removeAt(index);
					}
					S_CHANNELS.invoke();
				}
			}
		}
		
		static private function resendInOut():void {
			WS.S_CONNECTED.remove(resendInOut);
			if (flagInOut == true)
				WSClient.call_blackHoleToGroup("public", "subscribe");
			else
				WSClient.call_blackHoleToGroup("public", "unsubscribe");
		}
		
		static private function onQuestionReactionsLoadedFromPHP(phpRespond:PHPRespond):void {
			echo("ChannelsManager", "onQuestionReactionsLoadedFromPHP", "START");
			
			var chatUID:String;
			if (phpRespond != null && phpRespond.additionalData != null && "chatUID" in phpRespond.additionalData)
			{
				chatUID = phpRespond.additionalData.chatUID;
			}
			
			if (phpRespond.error == true) {
				phpRespond.dispose();
				S_TOP_REACTIONS_LOADED_FROM_PHP.invoke(null, chatUID);
				echo("ChannelsManager", "onQuestionReactionsLoadedFromPHP", "PHP ERROR");
				return;
			}
			
			if (phpRespond.data == null) {
				S_TOP_REACTIONS_LOADED_FROM_PHP.invoke(null, chatUID);
				phpRespond.dispose();
				echo("ChannelsManager", "onQuestionReactionsLoadedFromPHP", "PHP DATA IS NULL");
				return;
			}
			
			var reactions:Vector.<QuestionUserReactions> = new Vector.<QuestionUserReactions>();
			
			var l:int = phpRespond.data.length;
			var reactionModel:QuestionUserReactions;
			var chat:ChatVO = getChannel(chatUID);
			
			for (var i:int = 0; i < l; i++) {
				reactionModel = new QuestionUserReactions(phpRespond.data[i]);
				if (chat != null) {
					if (chat.ownerUID != reactionModel.uid) {
						reactions.push(reactionModel);
					}
				}
				else {
					reactions.push(reactionModel);
				}
			}
			S_TOP_REACTIONS_LOADED_FROM_PHP.invoke(reactions, chatUID);
			phpRespond.dispose();
			echo("ChannelsManager", "onQuestionReactionsLoadedFromPHP", "END");
		}
	}
}