package com.dukascopy.connect.screens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.CopyMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.ForwardMessageAction;
	import com.dukascopy.connect.gui.chat.ConnectionIndicator;
	import com.dukascopy.connect.gui.chatInput.BankInfoInput;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListChatItem;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.context.ContextMenuScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.sys.GlobalDate;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.ForwardingManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ActionType;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatItemContextMenuItemType;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.chat.VoiceMessageVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.AudioPlaybackMode;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ChatScreenBankInfo extends BaseScreen {
		
		private var actions:Array = [
			
		];
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var input:BankInfoInput;
		
		private var currentWidth:int;
		private var currentHeight:int;
		private var noConnectionIndicator:ConnectionIndicator;
		private var preloader:Preloader;
		
		private var _messagesLoaded:Boolean = false;
		private var needToOpenChat:Boolean = false;
		
		private var lastMessagesHash:String;
		private var historyLoadingState:Boolean;
		private var historyLoadingScroller:Preloader;
		private var loadHistoryOnMouseUp:Boolean;
		private var chatData:ChatVO;
		
		public function ChatScreenBankInfo() { }
		
		override protected function createView():void {
			super.createView();
			
			topBar = new TopBarScreen();
			
			list = new List("bankAccountList");
			list.newMessageAnimationTime = 0.3;
			list.background = true;
			list.backgroundColor = Style.color(Style.CHAT_BACKGROUND);
			list.view.y = topBar.trueHeight;
			list.setAdditionalBottomHeight(Config.FINGER_SIZE * .5);
			
			input = new BankInfoInput(Lang.startChatWithConsultant);
			input.sendCallback = onInputSend;
			input.homeCallback = openBank;
			
			_view.addChild(list.view);
			_view.addChild(topBar);
			_view.addChild(input);
		}
		
		private function openBank():void 
		{
			MobileGui.openMyAccountIfExist();
		}
		
		private function openMyAccount():void {
			MobileGui.changeMainScreen(MyAccountScreen);
		}
		
		private function onInputSend():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_VI_DEF;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			chatData = data as ChatVO;
			
			topBar.setData(chatData.title, true, actions);
			topBar.drawView(_width);
			
			list.setWidthAndHeight(_width, _height - topBar.trueHeight - input.getHeight());
			
			currentWidth = _width;
			currentHeight = _height;
			
			input.setWidth(currentWidth);
			input.y = _height - input.getHeight();
			
			ChatManager.S_CHAT_STAT_CHANGED.add(onChatUpdated);
			ChatManager.S_MESSAGES.add(onMessagesLoaded);
			ChatManager.S_HISTORICAL_MESSAGES.add(onHistoricalMessagesLoaded);
			ChatManager.S_MESSAGE.add(onNewMessage);
			ChatManager.S_MESSAGE_UPDATED.add(onMessageUpdated);
			ChatManager.S_MESSAGES_LOADING_FROM_PHP.add(sMessagesStartLoadFromPHP);
			ChatManager.S_REMOTE_MESSAGES_STOP_LOADING.add(onRemoteMessagesStopLoading);
			ChatManager.S_ERROR_CANT_OPEN_CHAT.add(onChatError);
			GlobalDate.S_NEW_DATE.add(refreshList);
			LightBox.S_LIGHTBOX_OPENED.add(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.add(onLightboxClose);
			
			ChatManager.S_LOAD_START.add(showPreloader);
			ChatManager.S_LOAD_STOP.add(hidePreloader);
			
			needToOpenChat = true;
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			if (currentWidth == _width && currentHeight == _height)
				return;
			currentWidth = _width;
			currentHeight = _height;
			if (topBar != null)
				topBar.drawView(_width);
			if (list != null)
				list.setWidthAndHeight(_width, _height - topBar.trueHeight - input.getHeight());
			if (input != null) {
				input.setWidth(currentWidth);
				input.y = _height - input.getHeight();
			}
			
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = _height * .5;
			}
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			if (_isActivated)
				return;
			super.activateScreen();
			if (topBar != null)
				topBar.activate();
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				list.S_ITEM_HOLD.add(onItemHold);
				list.S_MOVING.add(onListMove);
				list.S_UP.add(onListTouchUp);
			}
			if (input != null)
				input.activate();
			
			if (noConnectionIndicator != null && noConnectionIndicator.visible == true && noConnectionIndicator.parent != null)
			{
				PointerManager.addTap(noConnectionIndicator, tryReconnect);
			}
			
			if (needToOpenChat == true) {
				needToOpenChat = false;
				
				ChatManager.openChatByVO(chatData);
			}
			
			if (_isDisposed == true)
				return;
			
			SoundController.S_SOUND_PLAY_START.add(onSoundPlayStart);
			SoundController.S_SOUND_PLAY_STOP.add(onSoundPlayStop);
			SoundController.S_SOUND_PLAY_LOADING.add(onSoundLoading);
			SoundController.S_SOUND_PLAY_PROGRESS.add(onSoundPlayProgress);
			
			TweenMax.delayedCall(1.5, addPreloader);
			
			NetworkManager.S_CONNECTION_CHANGED.add(onNetworkChanged);
			
			onNetworkChanged();
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (!(data is ChatMessageVO)) {
				return;
			}
			var cmsgVO:ChatMessageVO = data as ChatMessageVO;
			
			var selectedItem:ListItem = list.getItemByNum(n);
			
			var lastHitzoneObject:Object =  selectedItem.getLastHitZoneObject();
			var lhz:String = lastHitzoneObject!=null?lastHitzoneObject.type:null;// selectedItem.getLastHitZone();
			
			var overlayTouch:HitZoneData;
			
			var updateItemTime:Boolean = true;
			if (lhz == HitZoneType.BALLOON) {
				if (cmsgVO.linksArray != null && cmsgVO.linksArray.length > 0) {
					if (cmsgVO.linksArray.length > 1) {
						
						if (canOpenLink(cmsgVO) == false)
						{
							return;
						}
						
						DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
							if (data.id == -1)
								return;
							
							openLink(data.shortLink);
						}, data:cmsgVO.linksArray, itemClass:ListLink, title:Lang.chooseLinkToOpen } );
					} else {
						var linkObj:Object = cmsgVO.linksArray[0];
						
						if (canOpenLink(cmsgVO) == false)
						{
							return;
						}
						
						if (linkObj != null)
							openLink(linkObj.shortLink);
					}
				}
			}
		}
		
		private function openLink(link:String):void {
			var nativeAppExist:Boolean = false;
			var appLink:String;
			if (link.indexOf("http://www.dukascopy.com/fxcomm/") == 0 ||
				link.indexOf("http://www.dukascopy.com/tradercontest/") == 0 ||
				link.indexOf("http://www.dukascopy.com/strategycontest/") == 0) {
					appLink = link.substr(25);
					if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
						nativeAppExist = MobileGui.androidExtension.launchFXComm("url", appLink);
					else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
						nativeAppExist = MobileGui.dce.launchFXComm("url", appLink);
			}
			if (link.indexOf("https://www.dukascopy.com/fxcomm/") == 0 ||
				link.indexOf("https://www.dukascopy.com/tradercontest/") == 0 ||
				link.indexOf("https://www.dukascopy.com/strategycontest/") == 0) {
					appLink = link.substr(26);
					if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
						nativeAppExist = MobileGui.androidExtension.launchFXComm("url", appLink);
					else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
						nativeAppExist = MobileGui.dce.launchFXComm("url", appLink);
			}
			
			if (nativeAppExist == false)
				navigateToURL(new URLRequest(link));
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (topBar != null)
				topBar.deactivate();
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (input != null)
				input.deactivate();
			
			if (noConnectionIndicator != null)
			{
				PointerManager.removeTap(noConnectionIndicator, tryReconnect);
			}
			
			NetworkManager.S_CONNECTION_CHANGED.remove(onNetworkChanged);
			
			if (ChatManager.getCurrentChat())
				SoundController.stopSoundsByChat(ChatManager.getCurrentChat().uid);
			
			SoundController.S_SOUND_PLAY_START.remove(onSoundPlayStart);
			SoundController.S_SOUND_PLAY_STOP.remove(onSoundPlayStop);
			SoundController.S_SOUND_PLAY_LOADING.remove(onSoundLoading);
			SoundController.S_SOUND_PLAY_PROGRESS.remove(onSoundPlayProgress);
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (list != null)
				list.dispose();
			list = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (input != null)
				input.dispose();
			input = null;
			
			actions = null;
			
			if (noConnectionIndicator != null)
			{
				PointerManager.removeTap(noConnectionIndicator, tryReconnect);
			}
			
			ChatManager.S_MESSAGES_LOADING_FROM_PHP.remove(sMessagesStartLoadFromPHP);
			
			ChatManager.S_CHAT_STAT_CHANGED.remove(onChatUpdated);
			ChatManager.S_MESSAGES.remove(onMessagesLoaded);
			ChatManager.S_HISTORICAL_MESSAGES.remove(onHistoricalMessagesLoaded);
			ChatManager.S_MESSAGE.remove(onNewMessage);
			ChatManager.S_MESSAGE_UPDATED.remove(onMessageUpdated);
			ChatManager.S_ERROR_CANT_OPEN_CHAT.remove(onChatError);

			ChatManager.S_REMOTE_MESSAGES_STOP_LOADING.remove(onRemoteMessagesStopLoading);
			GlobalDate.S_NEW_DATE.remove(refreshList);
			LightBox.S_LIGHTBOX_OPENED.remove(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.remove(onLightboxClose);
			
			NetworkManager.S_CONNECTION_CHANGED.remove(onNetworkChanged);
			
			ChannelsManager.setInOut(false);
			ChatManager.onExitChat();
			
			ChatManager.S_LOAD_START.remove(showPreloader);
			ChatManager.S_LOAD_STOP.remove(hidePreloader);
			
			_data = null;
		}
		
		override public function onBack(e:Event = null):void {
			super.onBack(e);
		}
		
		private function hidePreloader():void 
		{
			if (preloader != null)
			{
				preloader.hide();
			}
		}
		
		private function showPreloader():void 
		{
			preloader ||= new Preloader();
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
		}
		
		private function dellayedActivate():void {
			if (_isDisposed)
				return;
			
			activateScreen();
		}
		
		// TODO - show alert
		private function onChatError(message:String = null):void {
			echo("ChatScreen", "onChatError", "");
			if (message == ActionType.CHAT_CLOSE_ON_ERROR)
				onBack();
			else if (message != null && message.indexOf("que..09") == 0)
				onBack();
			else if (message != null && message.indexOf("io") == 0) {
				ToastMessage.display(Lang.textConnectionError);
				onBack();
			}
			else if (message == "") {
				ToastMessage.display(Lang.somethingWentWrong);
				onBack();
			}
			else if (message == null)
			{
				onBack();
			}
			_messagesLoaded = true;
			// REMOVE SPINNER
			TweenMax.killDelayedCallsTo(addPreloader);
			if (preloader != null)
				preloader.hide();
		}
		
		private function onChatUpdated(chatVO:ChatVO):void {
			echo("ChatScreen", "onChatUpdated", "");
			if (chatVO != ChatManager.getCurrentChat())
				return;
			if (list == null)
				return;
			if (_isDisposed)
				return;
			list.refresh();
		}
		
		private function onMessageUpdated(msgVO:ChatMessageVO):void {
			echo("ChatScreen", "onMessageUpdated", "");
			if (list != null)
				list.updateItem(msgVO);
		}
		
		private function refreshList(date:int):void {
			echo("ChatScreen", "refreshList", "");
			if (list != null)
				list.refresh();
		}
		
		private function addPreloader():void {
			if (_messagesLoaded == false) {
				preloader ||= new Preloader();
				preloader.x = _width * .5;
				preloader.y = _height * .5;
				view.addChild(preloader);
				preloader.show();
			}
		}
		
		private function onListTouchUp():void {
			if (loadHistoryOnMouseUp) {
				loadHistoryOnMouseUp = false;
				
				if (ChatManager.getCurrentChat().messages.length > 0 && ChatManager.getCurrentChat().messages[0].num == 1) {
					historyLoadingState = false;
					if (historyLoadingScroller != null)
						historyLoadingScroller.hide();
				} else {
					historyLoadingState = true;
					if (historyLoadingScroller != null)
						historyLoadingScroller.startAnimation();
					ChatManager.loadChatHistorycalMessages();
				}
			}
			else
			{
				if (historyLoadingScroller != null)
					historyLoadingScroller.hide();
			}
		}
		
		private function canOpenLink(cmsgVO:ChatMessageVO):Boolean 
		{
			var chat:ChatVO = ChatManager.getCurrentChat();
			
			if (chat != null && chat.type == ChatRoomType.CHANNEL && chat.questionID != null && chat.questionID != "")
			{
				var allowOpenLink:Boolean = false;
				var user:UserVO = UsersManager.getUserByMessageObject(cmsgVO);
				if (user != null && ((Config.ADMIN_UIDS != null && Config.ADMIN_UIDS.indexOf(user.uid) != -1) || (user.payRating > 4)))
				{
					allowOpenLink = true;
				}
				return allowOpenLink;
			}
			return true;
		}
		
		private function onItemHold(data:Object, n:int):void {
			echo("ChatScreen", "onItemHold", "");
			if (!(data is ChatMessageVO))
				return;
			var msgVO:ChatMessageVO = data as ChatMessageVO;
			if (msgVO.id == 0)
				return;
			
			var selectedItem:ListItem;
			
			if (msgVO.typeEnum == ChatMessageType.TEXT && msgVO.text == "")
				return;
			var isMine:Boolean = (msgVO.userUID == Auth.uid);
			var editable:Boolean = (msgVO.created * 1000 > new Date().getTime() - 1800000);
			var menuItems:Array = new Array();
			
				if (msgVO.typeEnum == ChatMessageType.TEXT) {
					
					if (msgVO.linksArray == null || (msgVO.linksArray.length > 0 && canOpenLink(msgVO)))
					{
						menuItems.push( { fullLink:Lang.textCopy, id:ChatItemContextMenuItemType.COPY } );
					}
				}
				
				var removeExist:Boolean = false;
				
				if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1) {
					removeExist = true;
					menuItems.push( { fullLink:Lang.textRemove, id:ChatItemContextMenuItemType.REMOVE } );
				}
				
				if (msgVO.typeEnum == ChatMessageType.INVOICE || 
					msgVO.typeEnum == ChatMessageType.TEXT || 
					msgVO.typeEnum == ChatMessageType.STICKER || 
					
					(msgVO.typeEnum == ChatSystemMsgVO.TYPE_FILE && 
					msgVO.systemMessageVO != null && 
					(msgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG || msgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG_CRYPTED)))
				{
					menuItems.push({fullLink:Lang.forwardMessage, id:ChatItemContextMenuItemType.FORWARD});
				}
			
			if (menuItems.length == 0)
				return;
			
			TweenMax.delayedCall(0.3, NativeExtensionController.vibrate);
			
			var actionsTap:Vector.<IScreenAction> = convertMessageMenuToActions(msgVO, menuItems);
			
			selectedItem = list.getItemByNum(n);
			var messageContentHitzone:HitZoneData = (selectedItem.renderer as ListChatItem).getMessageHitzone(selectedItem);
			if (messageContentHitzone != null) {
				var screenDataContext:Object = new Object();
				var globalPointTap:Point = selectedItem.liView.parent.localToGlobal(new Point(selectedItem.liView.x, selectedItem.liView.y));
				messageContentHitzone.x = globalPointTap.x + messageContentHitzone.x;
				messageContentHitzone.y = globalPointTap.y + messageContentHitzone.y;
				messageContentHitzone.visibilityRect = new Rectangle(0, list.view.y, _width, list.view.height);
				
				if (messageContentHitzone.y < list.view.y) {
					messageContentHitzone.height -= list.view.y - messageContentHitzone.y;
					messageContentHitzone.y = list.view.y;
				}
				if (messageContentHitzone.y + messageContentHitzone.height > list.view.y + list.height) {
					messageContentHitzone.height -= messageContentHitzone.y + messageContentHitzone.height - (list.view.y + list.height);
				}
				
				screenDataContext.hitzone = messageContentHitzone;
				
				screenDataContext.actions = actionsTap;
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ContextMenuScreen, {
																										backScreen:MobileGui.centerScreen.currentScreen, 
																										backScreenData:MobileGui.centerScreen.currentScreen.data, 
																										data:screenDataContext}, 0, 0);
				return;
			}
			
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
				switch(data.id) {
					case ChatItemContextMenuItemType.COPY: {
						if (msgVO.text != null)
						{
							Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, msgVO.text);
						}
						
						break;
					}
					case ChatItemContextMenuItemType.FORWARD:{
						ForwardingManager.openSelectAdresseeScreenForForwardingMessage(msgVO,data);
						break;
					}
				}
			}, data:menuItems, itemClass:ListLink, title:Lang.textMenu} );
		}
		
		private function convertMessageMenuToActions(msgVO:ChatMessageVO, menuItems:Array):Vector.<IScreenAction> {
			if (menuItems == null) {
				return null;
			}
			
			var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			var l:int = menuItems.length;
			
			var action:IScreenAction;
			for (var i:int = 0; i < l; i++) {
				action = null;
				switch(menuItems[i].id)
				{
					case ChatItemContextMenuItemType.FORWARD:
					{
						action = new ForwardMessageAction(msgVO);
						break;
					}
					case ChatItemContextMenuItemType.COPY:
					{
						action = new CopyMessageAction(msgVO);
						break;
					}
				}
				if (action != null) {
					actions.push(action);
				}
			}
			
			return actions;
		}
		
		private function onListMove(position:Number):void {
			if (position > 0) {
				if (!historyLoadingState) {
					var positionScroller:int = Config.FINGER_SIZE*.85 + Config.APPLE_TOP_OFFSET + position - Config.FINGER_SIZE;
					
					if (positionScroller > Config.FINGER_SIZE * 2.5) {
						loadHistoryOnMouseUp = true;
						positionScroller = Config.FINGER_SIZE * 2.5;
					} else {
						loadHistoryOnMouseUp = false;
					}
					
					if (ChatManager.getCurrentChat() != null &&
						ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE &&
						ChatManager.getCurrentChat().users != null &&
						ChatManager.getCurrentChat().users.length > 0) {
							var cuVO:ChatUserVO = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
							if (cuVO != null &&
								cuVO.userVO != null &&
								cuVO.userVO.uid != Auth.uid &&
								cuVO.userVO.type.toLowerCase() == "bot")
									return;
					}
					
					if (historyLoadingScroller == null) {
						var loaderSize:int = Config.FINGER_SIZE * 0.6;
						if (loaderSize%2 == 1)
							loaderSize ++;
						
						historyLoadingScroller = new Preloader(loaderSize, ListLoaderShape);
						_view.addChild(historyLoadingScroller);
						if (topBar != null && _view.contains(topBar))
						{
							_view.setChildIndex(topBar, _view.numChildren - 1);
						}
					}
					
					historyLoadingScroller.y = Config.FINGER_SIZE * .85 + Config.APPLE_TOP_OFFSET - Config.FINGER_SIZE * .5;
					historyLoadingScroller.x = int(_width * .5);
					
					
					historyLoadingScroller.show(true, false);
					
					historyLoadingScroller.rotation = positionScroller * 100 / Config.FINGER_SIZE;
					historyLoadingScroller.y = positionScroller;
				}
			}
		}
		
		private function sMessagesStartLoadFromPHP():void {
			if (preloader != null)
				preloader.show();
		}
		
		private function onRemoteMessagesStopLoading():void {
			TweenMax.killDelayedCallsTo(addPreloader);
			if (preloader != null)
				preloader.hide();
			
			hideHistoryLoader();
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//  SOUND MESSAGE  ->  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		private function switchSoundOnCurrentAudio(cmsgVO:ChatMessageVO):void {
			if (cmsgVO.systemMessageVO == null)
				return;
			if (cmsgVO.systemMessageVO.voiceVO == null)
				return;
			var vmVO:VoiceMessageVO = cmsgVO.systemMessageVO.voiceVO;
			var ticket:PlaySoundTicket = new PlaySoundTicket();
			ticket.type = PlaySoundTicket.TYPE_REMOTE_UID;
			ticket.soundLink = vmVO.uid;
			
			ticket.action = PlaySoundTicket.ACTION_SWITCH_SPEAKER;
			
			if (vmVO.speakerMode == AudioPlaybackMode.MEDIA) {
				vmVO.speakerMode = AudioPlaybackMode.VOICE;
			} else if (vmVO.speakerMode == AudioPlaybackMode.VOICE) {
				vmVO.speakerMode = AudioPlaybackMode.MEDIA;
			}
			list.updateItem(cmsgVO);
			
			ticket.speakerType = vmVO.speakerMode;
			ticket.caller = PlaySoundTicket.CALLER_CHAT;
			ticket.chatUID = ChatManager.getCurrentChat().uid;
			ticket.messageUID = cmsgVO.id;
			SoundController.playTicket(ticket);
		}
		
		private function playSound(cmsgVO:ChatMessageVO):void {
			if (cmsgVO.systemMessageVO == null)
				return;
			if (cmsgVO.systemMessageVO.voiceVO == null)
				return;
			var vmVO:VoiceMessageVO = cmsgVO.systemMessageVO.voiceVO;
			var ticket:PlaySoundTicket = new PlaySoundTicket();
			ticket.type = PlaySoundTicket.TYPE_REMOTE_UID;
			ticket.duration = vmVO.duration;
			ticket.format = vmVO.codec;
			ticket.soundLink = vmVO.uid;
			if (vmVO.isPlaying) {
				vmVO.isPlaying = false;
				ticket.action = PlaySoundTicket.ACTION_PAUSE;
			}
			else if (vmVO.isLoading) {
				vmVO.currentTime = 0;
				ticket.action = PlaySoundTicket.ACTION_STOP;
			} else {
				ticket.action = PlaySoundTicket.ACTION_PLAY;
			}
			
			list.updateItem(cmsgVO);
			
			ticket.speakerType = vmVO.speakerMode;
			ticket.caller = PlaySoundTicket.CALLER_CHAT;
			ticket.chatUID = ChatManager.getCurrentChat().uid;
			ticket.messageUID = cmsgVO.id;
			SoundController.playTicket(ticket);
		}
		
		private function onSoundLoading(ticket:PlaySoundTicket):void {
			if (ticket.caller == PlaySoundTicket.CALLER_CHAT && ticket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(ticket.messageUID);
				if (msgVO == null)
					return;
				if (msgVO.systemMessageVO == null)
					return;
				if (msgVO.systemMessageVO.voiceVO == null)
					return;
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				vmVO.isLoading = true;
			//	vmVO.currentTime = vmVO.duration;
				if (list != null)
					list.updateItem(msgVO);
			}
		}
		
		private function onSoundPlayStop(ticket:PlaySoundTicket):void {
			if (ticket.caller == PlaySoundTicket.CALLER_CHAT && ticket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(ticket.messageUID);
				if (msgVO == null)
					return;
				if (msgVO.systemMessageVO == null)
					return;
				if (msgVO.systemMessageVO.voiceVO == null)
					return;
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				vmVO.isLoading = false;
				vmVO.isPlaying = false;
				vmVO.currentTime = 0;
				if (list != null)
					list.updateItem(msgVO);
			}
		}
		
		private function onSoundPlayStart(ticket:PlaySoundTicket):void {
			if (ticket.caller == PlaySoundTicket.CALLER_CHAT && ticket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(ticket.messageUID);
				if (msgVO == null)
					return;
				if (msgVO.systemMessageVO == null)
					return;
				if (msgVO.systemMessageVO.voiceVO == null)
					return;
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				vmVO.isLoading = false;
				vmVO.isPlaying = true;
				if (list != null)
					list.updateItem(msgVO);
			}
		}
		
		private function onSoundPlayProgress(ticket:PlaySoundTicket):void {
			if (ticket.caller == PlaySoundTicket.CALLER_CHAT && ticket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(ticket.messageUID);
				if (msgVO == null)
					return;
				if (msgVO.systemMessageVO == null)
					return;
				if (msgVO.systemMessageVO.voiceVO == null)
					return;
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				vmVO.currentTime = vmVO.duration - ticket.currentPlayed;
				if (list != null)
					list.updateItem(msgVO);
			}
		}
		
		private function updateSounds():void {
			var currentSoundTicket:PlaySoundTicket = SoundController.getCurrentSoundTicket();
			if (currentSoundTicket == null)
				return;
			if (currentSoundTicket.caller == PlaySoundTicket.CALLER_CHAT && currentSoundTicket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(currentSoundTicket.messageUID);
				if (msgVO == null || msgVO.systemMessageVO == null || msgVO.systemMessageVO.voiceVO == null) {
					currentSoundTicket.action = PlaySoundTicket.ACTION_STOP;
					SoundController.playTicket(currentSoundTicket);
					return;
				}
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				var soundStatus:SoundStatusData = SoundController.getSoundStatus(currentSoundTicket);
				if (soundStatus != null) {
					vmVO.isLoading = soundStatus.isLoading;
					vmVO.isPlaying = soundStatus.isPlaying;
					vmVO.currentTime = vmVO.duration - currentSoundTicket.currentPlayed;
				}
				if (list != null)
					list.updateItem(msgVO);
				return;
			}
			currentSoundTicket.action = PlaySoundTicket.ACTION_STOP;
			SoundController.playTicket(currentSoundTicket);
		}
		
		private function getMessage(messageUID:int):ChatMessageVO {
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().messages) {
				var length:int = ChatManager.getCurrentChat().messages.length;
				for (var i:int = 0; i < length; i++) {
					if (ChatManager.getCurrentChat().messages[i].id == messageUID) {
						return ChatManager.getCurrentChat().messages[i];
					}
				}
			}
			return null;
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//  <-  SOUND MESSAGE  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function onLightboxClose():void {
			echo("ChatScreen", "onLightboxClose", "");
			if (_isDisposed == true)
				return;
			if (LightBox.isShowing) // Beacuse we use same handler on PuzzleClose
				return;
			
			activateScreen();
		}
		
		private function onLightboxOpen():void {
			echo("ChatScreen", "onLightboxOpen", "");
			if (isDisposed)
				return;
			deactivateScreen();
		}
		
		private function onBackClicked(e:Event = null):void{
			MobileGui.changeMainScreen(RootScreen,null,ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		private function onNewMessage(data:ChatMessageVO):void {
			if (ChatManager.getCurrentChat() == null)
				return;
			if (data.chatUID != ChatManager.getCurrentChat().uid)
				return;
			if (list == null)
				return;
			echo("ChatScreen", "onNewMessage", data);
			var doScrollToBottom:Boolean;
			if (data.userUID == Auth.uid)
				doScrollToBottom = true;
			else
				doScrollToBottom = checkScrollToBottom();
			var lastMsgDate:Date = null;
			if (ChatManager.getCurrentChat().messages.length > 1)
				lastMsgDate = ChatManager.getCurrentChat().messages[ChatManager.getCurrentChat().messages.length - 2].date;
			var currentMsgDate:Date = data.date;
			if (lastMsgDate == null || (lastMsgDate.getFullYear() != currentMsgDate.getFullYear() || lastMsgDate.getMonth() != currentMsgDate.getMonth() || lastMsgDate.getDate() != currentMsgDate.getDate())) {
				list.refresh();
				list.appendItem(currentMsgDate, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey'], true);
			}
			
			list.appendItem(data, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey'], true);
			
			updatePrewChatMessage(data);
		//	NativeExtensionController.speakMessage(data.text);
			if (doScrollToBottom)
				list.scrollBottom(true);
		}
		
		private function updatePrewChatMessage(newMessage:ChatMessageVO):void {
			var lastItemNum:int;
			if (list != null && 
				newMessage != null && 
				list.data != null && 
				list.data is Array && 
				(list.data as Array).length > 1) {
					lastItemNum = (list.data as Array).length - 2;
					if (((list.data as Array)[lastItemNum] is ChatMessageVO) && 
						((list.data as Array)[lastItemNum] as ChatMessageVO).userUID == newMessage.userUID) {
							list.updateItemByIndex(list.getStock().length - 2);
					}
			}
		}
		
		private function checkScrollToBottom():Boolean {
			if (list == null)
				return false;
			if (list.getScrolling() == true) {
				if (Math.abs(list.getBoxY()) + list.height > list.innerHeight)
					return true;
				return false;
			}
			if (Math.abs(list.getBoxY()) + list.height > list.innerHeight)
				return true;
			return false;
		}
		
		private function onMessagesLoaded():void {
			echo("ChatScreen", "onMessagesLoaded");
			TweenMax.killDelayedCallsTo(addPreloader);
			if (preloader != null)
				preloader.hide();
			
			/*if (_messagesLoaded == false){
				list.view.alpha = 0;
				TweenMax.killTweensOf(list.view);
				TweenMax.to(list.view, 0.7, { alpha:1 } );
			}*/
			_messagesLoaded = true;
			var needUpdateMessages:Boolean = true;
			if (ChatManager.getCurrentChat().lastMessagesHash != null && ChatManager.getCurrentChat().lastMessagesHash == lastMessagesHash)
				needUpdateMessages = false;
			if (needUpdateMessages) {
				lastMessagesHash = ChatManager.getCurrentChat().lastMessagesHash;
				var messages:Vector.<ChatMessageVO> = ChatManager.getCurrentChat().messages;
				var listData:Array = [];
				if (messages != null && messages.length > 0) {
					var currentDate:Date;
					var oldDate:Date;
					oldDate = messages[0].date;
					listData.push(oldDate);
					listData.push(messages[0]);
					for (var i:int = 1; i < messages.length; i++) {
						if (isNaN(messages[i].id) || messages[i].id == 0) {
							listData.push(messages[i]);
							continue;
						}
						currentDate = messages[i].date;
						if (currentDate.getTime() != oldDate.getTime()) {
							listData.push(currentDate);
							oldDate = currentDate;
						}
						listData.push(messages[i]);
					}
				}
				
				list.setData(listData, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey'], null, ['imageThumbURLWithKey']);
				list.scrollBottom();
			}
			
			updateSounds();
		}
		
		private function hideHistoryLoader():void 
		{
			if (historyLoadingState)
			{
				historyLoadingState = false;
				if (historyLoadingScroller != null)
				{
					historyLoadingScroller.hide();
						}
					}
				}
		
		private function onHistoricalMessagesLoaded():void {
			echo("ChatScreen", "onHistoricalMessagesLoaded", "");
			TweenMax.killDelayedCallsTo(addPreloader);
			if (preloader != null)
				preloader.hide();
			
			hideHistoryLoader();
			
			_messagesLoaded = true;
			var listPositionY:int = list.innerHeight;
			var messages:Vector.<ChatMessageVO> = ChatManager.getCurrentChat().messages;
			var listData:Array = [];
			/*if (messages[0].num > 1)
				listData.push( { title: "button" } );*/
			if (messages != null && messages.length > 0) {
				var currentDate:Date;
				var oldDate:Date;
				oldDate = messages[0].date;
				listData.push(oldDate);
				listData.push(messages[0]);
				for (var i:int = 1; i < messages.length; i++) {
					currentDate = messages[i].date;
					if (currentDate.getTime() != oldDate.getTime()) {
						listData.push(currentDate);
						oldDate = currentDate;
					}
					listData.push(messages[i]);
				}
			}
			list.setData(listData, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey'], null, ['imageThumbURLWithKey']);
			list.setBoxY(-(list.innerHeight - listPositionY));
		}
		
		override public function clearView():void {
			echo("ChatScreen", "clearView", "");
			lastMessagesHash = null;
			if (noConnectionIndicator)
				noConnectionIndicator.dispose();
			noConnectionIndicator = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			
			
			super.clearView();
			
			if (historyLoadingScroller) {
				historyLoadingScroller.dispose();
				historyLoadingScroller = null;
			}
			
			if (LightBox.isShowing) {
				LightBox.isShowing = false;
			}
			
			TweenMax.killDelayedCallsTo(addPreloader);
		}
		
		// NO CONNECTION INDICATOR -> //
		private function onNetworkChanged():void {
			if (NetworkManager.isConnected)
				hideNoConnectionIndicator();
			else
				showNoConnectionIndicator();
		}
		
		private function hideNoConnectionIndicator():void {
			if (noConnectionIndicator == null || noConnectionIndicator.parent == null)
				return;
			PointerManager.removeTap(noConnectionIndicator, tryReconnect);
			noConnectionIndicator.parent.removeChild(noConnectionIndicator);
		}
		
		private function showNoConnectionIndicator():void {
			if (noConnectionIndicator == null) {
				noConnectionIndicator = new ConnectionIndicator();
				noConnectionIndicator.draw(_width, Config.FINGER_SIZE * .5);
				noConnectionIndicator.y = topBar.height;
			}
			_view.addChild(noConnectionIndicator);
			
			PointerManager.addTap(noConnectionIndicator, tryReconnect);
		}
		
		private function tryReconnect(e:Event = null):void 
		{
			NetworkManager.reconnect();
		}
	}
}