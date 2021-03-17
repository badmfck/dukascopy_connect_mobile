package com.dukascopy.connect.sys.notifier 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.sys.Utils;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.sqlite.SQLRespond;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.vo.ChatVO;
	import com.telefision.sys.signals.Signal;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatGroupHandler 
	{
		private const STATE_NONE:int = 1;
		private const STATE_DATABASE_WAITING:int = 2;
		private const STATE_DATABASE_CREATION:int = 3;
		private const STATE_DATABASE_LOADING:int = 4;
		private const STATE_READY:int = 5;
		private const STATE_ERROR:int = 6;
		
		private var chatsData:Dictionary = new Dictionary();
		private var pendingInitialData:Array;
		
		private var handlerType:HandlerType;
		
		static public var S_UPDATE:Signal = new Signal('NewMessageNotifier.S_UPDATE');
		
		private var state:int = STATE_NONE;
		
		private var maskFirstDataReaded:Boolean;
		private var chatDataToStore:Array;
		
		
		public function ChatGroupHandler(handlerType:HandlerType) 
		{
			this.handlerType = handlerType;
			
			//!TODO: загрузка на старте?;
		}
		
		public function clear():void 
		{
			state = STATE_NONE;
			
			chatsData = new Dictionary();
			pendingInitialData = new Array();
			chatDataToStore = new Array();
			
			SQLite.S_DATABASE_CREATED.remove(onDatabaseCreated);
		}
		
		public function onChatOpened():void 
		{
			var chat:ChatVO = ChatManager.getCurrentChat();
			if (chat != null)
			{
				var lastMessageNum:uint = 0;
				if (chat.messageVO != null)
				{
					lastMessageNum = chat.messageVO.num;
				}
				setValue(NewMessageNotifier.getUID(chat), lastMessageNum);
				
				storeChatData(new ChatLastMessageData(NewMessageNotifier.getUID(chat), lastMessageNum));
			}
		}
		
		private function setValue(uID:String, lastMessageNum:uint):void 
		{
			chatsData[uID] = lastMessageNum;
		}
		
		private function storeChatData(value:ChatLastMessageData):void 
		{
			if (state != STATE_READY)
			{
				if (chatDataToStore == null)
				{
					chatDataToStore = new Array();
				}
				chatDataToStore.push(value);
				
				checkState();
				return;
			}
			
			if (chatDataToStore == null || chatDataToStore.length == 0)
			{
				sendChatDataToDatabase(value);
			}
			else
			{
				if (chatDataToStore == null)
				{
					chatDataToStore = new Array();
				}
				chatDataToStore.push(value);
			}
		}
		
		private function sendChatDataToDatabase(value:ChatLastMessageData):void 
		{
			SQLite.call_storeChatUnredData(handlerType, value, onChatDataStored);
		}
		
		private function onChatDataStored(respond:SQLRespond):void 
		{
			saveNextPendingChatData();
		}
		
		private function saveNextPendingChatData():void 
		{
			if (chatDataToStore != null && chatDataToStore.length > 0)
			{
				sendChatDataToDatabase(chatDataToStore.shift());
			}
		}
		
		public function getChatLastReaded(chatUID:String, lastReceived:Number):Number
		{
			if (state != STATE_READY)
			{
				return -7;
			}
			
			if (isNaN(chatsData[chatUID]) == true)
			{
				return -8;
				/*chatsData[chatUID] = 0;
				storeChatData(new ChatLastMessageData(chatUID, 0));*/
			}
			
			return chatsData[chatUID];
		}
		
		public function getChatUnreaded(chatUID:String, lastReceived:Number):Number
		{
			if (state != STATE_READY)
			{
				return 0;
			}
			
			if (isNaN(chatsData[chatUID]) == true)
			{
				return 0;
				/*chatsData[chatUID] = 0;
				storeChatData(new ChatLastMessageData(chatUID, 0));*/
			}
			
			/*if (handlerType == NewMessageNotifier.type_911)
			{
				trace("unread", chatUID, lastReceived, chatsData[chatUID]);
			}*/
			
			return Math.max(lastReceived - chatsData[chatUID], 0);
		}
		
		private function loadLocalData():void
		{
			SQLite.call_getUnreadMessages(handlerType, onLocalDataLoaded);
		}
		
		public function setInitialData(initialData:ChatsInitialData):void 
		{
			if (state != STATE_READY)
			{
				storeInitialData(initialData);
				checkState();
				return;
			}
			
			processInitialData(initialData);
		}
		
		public function onNewMessage(chatVO:ChatVO, messageNum:uint):void 
		{
			/*if (handlerType == NewMessageNotifier.type_911)
			{
				trace("onNewMessage", chatVO.uid, messageNum);
			}*/
			
			if (ChatManager.getCurrentChat() != null && NewMessageNotifier.getUID(ChatManager.getCurrentChat()) == NewMessageNotifier.getUID(chatVO) && Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreen))
			{
				setChatLastReaded(NewMessageNotifier.getUID(chatVO), messageNum);
				storeChatData(new ChatLastMessageData(NewMessageNotifier.getUID(chatVO), messageNum));
			}
			else
			{
				if (chatVO.messageWriterUID == Auth.uid)
				{
					setChatLastReaded(NewMessageNotifier.getUID(chatVO), messageNum);
					storeChatData(new ChatLastMessageData(NewMessageNotifier.getUID(chatVO), messageNum));
				}
				
				
				S_UPDATE.invoke(NewMessageNotifier.getUID(chatVO));
				NewMessageNotifier.dispatchUpdateLater();
			}
		}
		
		public function getUnreded():int 
		{
			return 1;
		}
		
		public function addNewChat(chat:ChatVO):void 
		{
			/*if (handlerType == NewMessageNotifier.type_911)
			{
				trace("addNewChat", chat.uid);
			}*/
			
			if (chatsData[NewMessageNotifier.getUID(chat)] != null)
			{
				// all ok;
			}
			else
			{
				setInitialData(new ChatsInitialData([chat], true, false));
				S_UPDATE.invoke(NewMessageNotifier.getUID(chat));
				NewMessageNotifier.dispatchUpdateLater();
			//	processInitialData();
			}
		}
		
		public function onNewMessagePrivate(chatUID:String):void 
		{
			if (state == STATE_READY)
			{
				setValue(chatUID, 0);
				
				var saveData:ChatLastMessageData = new ChatLastMessageData(chatUID, 0);
				SQLite.call_storeChatUnredData(handlerType, saveData, null);
			}
		}
		
		public function markAllAsRead():void 
		{
			if (state == STATE_READY)
			{
				if (chatsData != null)
				{
					var chatVO:ChatVO;
					for (var uid:String in chatsData) 
					{
						chatVO = ChatManager.getChatByUID(uid);
						if (chatVO != null && chatVO.messageVO != null)
						{
							setValue(uid, chatVO.messageVO.num);
							var saveData:ChatLastMessageData = new ChatLastMessageData(uid, chatVO.messageVO.num);
							storeChatData(saveData);
						//	SQLite.call_storeChatUnredData(handlerType, saveData, null);
						}
					}
				}
			}
			else
			{
				//!TODO:;
			}
		}
		
		private function processInitialData(initialData:ChatsInitialData):void 
		{
			var l:int = initialData.chats.length;
			
			var lastReadedMessage:uint;
			var lastMessageNum:uint;
			var chatsToStore:Vector.<ChatLastMessageData> = new Vector.<ChatLastMessageData>();
			for (var i:int = 0; i < l; i++) 
			{
				if (NewMessageNotifier.getUID(initialData.chats[i]) in chatsData)
				{
					if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == initialData.chats[i].uid && initialData.chats[i].messageVO != null && Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreen))
					{
						lastReadedMessage = initialData.chats[i].messageVO.num;
						setValue(NewMessageNotifier.getUID(initialData.chats[i]), lastReadedMessage);
					}
					
					if (initialData.chats[i].messageWriterUID == Auth.uid)
					{
						lastReadedMessage = initialData.chats[i].messageVO.num;
						setValue(NewMessageNotifier.getUID(initialData.chats[i]), lastReadedMessage);
					}
				}
				else
				{
					if (maskFirstDataReaded == true)
					{
						if (initialData.chats[i].messageVO != null)
						{
						//	lastReadedMessage = initialData.chats[i].messageVO.num;
							
							if (initialData.chats[i].unreaded > 0)
							{
								if (initialData.chats[i].messageVO != null)
								{
									trace(initialData.chats[i].uid, initialData.chats[i].unreaded);
									lastReadedMessage = Math.max(initialData.chats[i].messageVO.num - initialData.chats[i].unreaded, 0);
								}
								else
								{
									lastReadedMessage = initialData.chats[i].messageVO.num;
								}
							}
							else
							{
								lastReadedMessage = initialData.chats[i].messageVO.num;
							}
							
						}
						else
						{
							if (initialData.chats[i].unreaded > 0)
							{
								if (initialData.chats[i].messageVO != null)
								{
									lastReadedMessage = Math.max(initialData.chats[i].messageVO.num - initialData.chats[i].unreaded, 0);
								}
								else
								{
									lastReadedMessage = 0;
								}
							}
							else
							{
								lastReadedMessage = 0;
							}
						}
					}
					else
					{
						if (initialData.chats[i].unreaded > 0)
						{
							if (initialData.chats[i].messageVO != null)
							{
								lastReadedMessage = Math.max(initialData.chats[i].messageVO.num - initialData.chats[i].unreaded, 0);
							}
							else
							{
								lastReadedMessage = 0;
							}
						}
						else
						{
							if (initialData.chats[i].messageVO != null)
							{
								lastReadedMessage = Math.max(initialData.chats[i].messageVO.num - initialData.chats[i].unreaded, 0);
							}
							else
							{
								lastReadedMessage = 0;
							}
						}
					}
					
					if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == initialData.chats[i].uid && initialData.chats[i].messageVO != null)
					{
						lastReadedMessage = initialData.chats[i].messageVO.num;
					}
					
					chatsToStore.push(new ChatLastMessageData(NewMessageNotifier.getUID(initialData.chats[i]), lastReadedMessage));
					setValue(NewMessageNotifier.getUID(initialData.chats[i]), lastReadedMessage);
				}
			}
			
			storeChatsData(chatsToStore);
			
			if (initialData.fromPHP == true && initialData.firstTime == false)
			{
				maskFirstDataReaded = false;
			}
			
			processNextPendingInitialData();
		}
		
		private function processNextPendingInitialData():void 
		{
			if (pendingInitialData != null && pendingInitialData.length > 0)
			{
				processInitialData(pendingInitialData.shift());
			}
			else
			{
				if (state != STATE_READY)
				{
					tryLoadLocalData();
				}
			}
		}
		
		private function checkState():void 
		{
			if (state == STATE_NONE)
			{
				if (SQLite.isReady)
				{
					tryLoadLocalData();
				}
				else
				{
					state = STATE_DATABASE_WAITING;
					
					SQLite.S_READY.add(onDatabaseReady);
				}
			}
		}
		
		private function tryLoadLocalData():void 
		{
			if (isDatabaseExist())
			{
				state = STATE_DATABASE_LOADING;
				
				loadLocalData();
			}
			else
			{
				state = STATE_DATABASE_CREATION;
				
				SQLite.S_DATABASE_CREATED.add(onDatabaseCreated);
				
				SQLite.createUnreadedDatabase(handlerType);
			}
		}
		
		private function onDatabaseCreated(type:String):void 
		{
			maskFirstDataReaded = true;
			
		//	trace("onDatabaseCreated", handlerType.value);
			
			if (type == handlerType.value)
			{
				SQLite.S_DATABASE_CREATED.remove(onDatabaseCreated);
				
				if (pendingInitialData != null && pendingInitialData.length > 0)
				{
					processNextPendingInitialData();
				}
				else
				{
					tryLoadLocalData();
				}
			}
		}
		
		private function isDatabaseExist():Boolean 
		{
			return SQLite.isUnreadedDatabaseExist(handlerType.value);
		}
		
		private function onDatabaseReady():void 
		{
			tryLoadLocalData();
		}
		
		private function onLocalDataLoaded(response:SQLRespond):void 
		{
			if (response.error == true)
			{
				state = STATE_ERROR;
				
				// CRIT;
				ApplicationErrors.add();
			}
			else
			{
				state = STATE_READY;
			//	trace(handlerType.value);
				
				if (response.data != null && response.data is Array)
				{
					var l:int = response.data.length;
					for (var i:int = 0; i < l; i++) 
					{
						setValue(response.data[i].chat_uid, response.data[i].msg_num);
					}
					
					applyPendingChatData();
					saveNextPendingChatData();
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			NewMessageNotifier.dispatchUpdateLater();
		}
		
		private function applyPendingChatData():void 
		{
			if (chatDataToStore != null && chatDataToStore.length > 0)
			{
				var l:int = chatDataToStore.length;
				for (var i:int = 0; i < l; i++) 
				{
					setValue((chatDataToStore[i] as ChatLastMessageData).chatUid, (chatDataToStore[i] as ChatLastMessageData).lastReaded);
				}
			}
			
			NewMessageNotifier.dispatchUpdateLater();
		}
		
		private function setChatLastReaded(chatUID:String, messageNum:int):void 
		{
			setValue(chatUID, messageNum);
		}
		
		private function storeChatsData(chatsToStore:Vector.<ChatLastMessageData>):void 
		{
			if (chatsToStore.length > 0)
			{
				SQLite.call_storeChatsUnredData(handlerType, chatsToStore, onChatsDataStored);
			}
		}
		
		private function onChatsDataStored(respond:SQLRespond):void 
		{
			//!TODO: возможно очередь;
		}
		
		private function storeInitialData(initialData:ChatsInitialData):void 
		{
			if (pendingInitialData == null)
			{
				pendingInitialData = new Array();
			}
			pendingInitialData.push(initialData);
		}
	}
}