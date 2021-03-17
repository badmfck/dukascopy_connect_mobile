package com.dukascopy.connect.sys.notifier 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.ChatScreenBankInfo;
	import com.dukascopy.connect.sys.Utils;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class NewMessageNotifier 
	{
		static public var S_UPDATE:Signal = new Signal('NewMessageNotifier.S_UPDATE');
		static public var S_UPDATE_EXIST:Signal = new Signal('NewMessageNotifier.S_UPDATE_EXIST');
		
		static public const type_911:HandlerType = new HandlerType(HandlerType.CHAT_911);
		static public const type_LATEST:HandlerType = new HandlerType(HandlerType.LATEST);
		static public const type_CHANNELS:HandlerType = new HandlerType(HandlerType.CHANNELS);
		static public const type_CHANNELS_TRASH:HandlerType = new HandlerType(HandlerType.CHANNELS_TRASH);
		
		static private var handler_911:ChatGroupHandler = new ChatGroupHandler(type_911);
		static private var handler_LATEST:ChatGroupHandler = new ChatGroupHandler(type_LATEST);
		static private var handler_CHANNELS:ChatGroupHandler = new ChatGroupHandler(type_CHANNELS);
		static private var handler_CHANNELS_TRASH:ChatGroupHandler = new ChatGroupHandler(type_CHANNELS_TRASH);
		static private var pendingUpdate:Array;
		static public var needUpdate:Boolean;
		
		public static function init():void
		{
			Auth.S_NEED_AUTHORIZATION.add(clear);
			ChatManager.S_CHAT_OPENED.add(onChatOpened);
		}
		
		static private function clear():void 
		{
			handler_LATEST.clear();
			handler_CHANNELS.clear();
			handler_CHANNELS_TRASH.clear();
			handler_911.clear();
		}
		
		static public function markAllAsRead():void
		{
			handler_911.markAllAsRead();
			handler_LATEST.markAllAsRead();
			handler_CHANNELS.markAllAsRead();
			handler_CHANNELS_TRASH.markAllAsRead();
		}
		
		static private function getHandler(type:HandlerType):ChatGroupHandler 
		{
			if (type == null)
			{
				return null;
			}
			
			switch(type.value)
			{
				case HandlerType.LATEST:
				{
					return handler_LATEST;
					break;
				}
				case HandlerType.CHAT_911:
				{
					return handler_911;
					break;
				}
				case HandlerType.CHANNELS:
				{
					return handler_CHANNELS;
					break;
				}
				case HandlerType.CHANNELS_TRASH:
				{
					return handler_CHANNELS_TRASH;
					break;
				}
			}
			
			return null;
		}
		
		static private function onChatOpened():void {
			if (MobileGui.centerScreen != null &&
				MobileGui.centerScreen.currentScreen != null &&
				(Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreen) ||
				 Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreenBankInfo))) {
					
					needUpdate = true;
					
					var type:HandlerType = getType(ChatManager.getCurrentChat());
					var handler:ChatGroupHandler = getHandler(type);
					if (handler != null) {
						handler.onChatOpened();
					}
				
				NativeExtensionController.markChatRead(ChatManager.getCurrentChat());
			}
		}
		
		static private function getType(chatVO:ChatVO):HandlerType {
			if (chatVO == null) {
				return null;
			}
			if (chatVO.type == ChatRoomType.PRIVATE) {
				return type_LATEST;
			}
			if (chatVO.type == ChatRoomType.CHANNEL) {
				if (chatVO.questionID != "" && chatVO.questionID != null) {
					return type_911;
				}
				if (chatVO.inTrash == true) {
					return type_CHANNELS_TRASH;
				} else {
					return type_CHANNELS;
				}
			} else if (chatVO.type == ChatRoomType.GROUP) {
				return type_LATEST;
			} else if (chatVO.type == ChatRoomType.QUESTION) {
				return type_911;
			}
			if (chatVO.type == ChatRoomType.COMPANY) {
				return type_LATEST;
			}
			return null;
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		//----------------------------------------------------------------------------------------------------//
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		public static function onNewMessage(messageNum:int, chatVO:ChatVO):void 
		{
			var type:HandlerType = getType(chatVO);
			var handler:ChatGroupHandler = getHandler(type);
			if (handler != null)
			{
				handler.onNewMessage(chatVO, messageNum);
			}
			else
			{
				ApplicationErrors.add();
			}
			
			onUpdate(getUID(chatVO));
		}
		
		static private function onUpdate(uid:String = null):void 
		{
			if (pendingUpdate == null)
			{
				pendingUpdate = new Array();
			}
			if (uid != null)
			{
				pendingUpdate.push(uid);
			}
			
			TweenMax.killDelayedCallsTo(dispatchUpdate);
			TweenMax.delayedCall(0.01, dispatchUpdate);
		}
		
		static public function dispatchUpdate():void 
		{
			TweenMax.killDelayedCallsTo(dispatchUpdate);
			S_UPDATE.invoke(pendingUpdate);
			pendingUpdate = null;
		}
		
		public static function getChatUnreaded(lastReceived:Number, chatVO:ChatVO):Number {
			if (chatVO == null) {
				return 0;
			}
			var type:HandlerType = getType(chatVO);
			var handler:ChatGroupHandler = getHandler(type);
			if (handler != null) {
				return handler.getChatUnreaded(getUID(chatVO), lastReceived);
			} else {
				return 0;
			}
		}
		
		public static function setInitialData(type:HandlerType, chats:Array/*com.dukascopy.connect.vo.ChatVO*/, fromPHP:Boolean, firstTime:Boolean):void {
			var handler:ChatGroupHandler = getHandler(type);
			if (handler != null) {
				handler.setInitialData(new ChatsInitialData(chats, fromPHP, firstTime));
			}
		}
		
		static public function getUnreaded(type:HandlerType, filter:String = null):int {
			var handler:ChatGroupHandler = getHandler(type);
			if (handler == null) {
				return 0;
			}
			var source:Array;
			if (type.value == HandlerType.LATEST)
				source = ChatManager.getLatestChatsAndDatesFilter(filter);
			else if (type.value == HandlerType.CHAT_911)
				source = AnswersManager.getAllAnswers();
			if (source != null) {
				var unreadExist:Boolean = false;
				var l:int = source.length;
				var chat:ChatVO;
				for (var i:int = 0; i < l; i++) {
					if (source[i] is ChatVO)
					{
						chat = source[i] as ChatVO;
						if (chat.messageVO != null && handler.getChatUnreaded(getUID(chat), chat.messageVO.num) > 0)
						{
							unreadExist = true;
							break;
						}
					}
				}
				if (unreadExist == true) {
					return 1;
				}
			}
			return 0;
		}
		
		static public function getUID(chat:ChatVO):String 
		{
			if (chat != null)
			{
				if (chat.type == ChatRoomType.COMPANY)
				{
					return chat.pid.toString();
				}
				else
				{
					return chat.uid;
				}
			}
			else
			{
				ApplicationErrors.add();
			}
			return null;
		}
		
		static public function addNewChat(chat:ChatVO):void 
		{
			var type:HandlerType = getType(chat);
			var handler:ChatGroupHandler = getHandler(type);
			if (handler != null)
			{
				handler.addNewChat(chat);
			}
		}
		
		static public function onNewMessagePrivate(chatUID:String):void 
		{
			var handler:ChatGroupHandler = getHandler(type_LATEST);
			if (handler != null)
			{
				handler.onNewMessagePrivate(chatUID);
			}
		}
		
		static public function getChatLastReaded(lastReceived:int, chatVO:ChatVO):Number 
		{
			if (chatVO == null)
			{
				return -5;
			}
			
			var type:HandlerType = getType(chatVO);
			var handler:ChatGroupHandler = getHandler(type);
			if (handler != null)
			{
			//	trace(type.value, getUID(chatVO), handler.getChatUnreaded(getUID(chatVO), lastReceived));
				return handler.getChatLastReaded(getUID(chatVO), lastReceived);
			}
			else
			{
				return -6;
			}
		}
		
		static public function dispatchUpdateLater():void 
		{
			onUpdate();
		}
	}
}