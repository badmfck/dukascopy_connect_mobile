package com.dukascopy.connect.sys.ws{
	
	import com.dukascopy.connect.Config;
import com.dukascopy.connect.GD;
import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.ErrorData;
	import com.dukascopy.connect.data.MessageData;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.data.escrow.EscrowEventType;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.connection.WebRTCChannel;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.messagesController.MessagesController;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.type.ErrorCode;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.telefision.sys.etc.Print_r;
	import com.telefision.sys.signals.Signal;
	import flash.text.TextField;
	import mx.core.Singleton;
	import com.dukascopy.connect.sys.php.PHP;
	import com.telefision.sys.etc.Print_r;

	/**
	 * ...
	 * @author Igor Bloom. Telefision TEAM Riga.
	 */
	
	public class WSClient {
		
		//CONNECTION MANAGEMENT
		static public var S_AUTHORIZED:Signal = new Signal('WSClient.S_AUTHORIZED');
		static public var S_AUTHORIZED_ERROR:Signal = new Signal('WSClient.S_AUTHORIZED_ERROR');
		
		//CHAT MANAGEMENT
		static public var S_CHAT_USER_ENTER:Signal = new Signal('WSClient.S_CHAT_USER_ENTER');
		static public var S_CHAT_USER_EXIT:Signal = new Signal('WSClient.S_CHAT_USER_EXIT');
		static public var S_CHAT_MSG:Signal = new Signal('WSClient.S_CHAT_MSG');
		static public var S_CHAT_MSG_UPDATED:Signal = new Signal('WSClient.S_CHAT_MSG_UPDATED');
		static public var S_CHAT_MSG_REMOVED:Signal = new Signal('WSClient.S_CHAT_MSG_REMOVED');
		static public var S_CHAT_USERS_ADD:Signal = new Signal('WSClient.S_CHAT_USERS_CHANGED');
		static public var S_CHAT_USER_REMOVE:Signal = new Signal('WSClient.S_CHAT_USER_REMOVE');
		static public var S_USER_WRITING:Signal = new Signal('WSClient.S_USER_WRITING');
		static public var S_MESSAGE_REACTION:Signal = new Signal('WSClient.S_MESSAGE_REACTION');
		
		static public var S_BLACK_HOLE:Signal = new Signal('WSClient.S_BLACK_HOLE');
		static public var S_RID:Signal = new Signal('WSClient.S_RID');
		
		// only for monitoring, do not use in your code
		static public var S_MESSAGE:Signal = new Signal('WSClient.S_MESSAGE');
		
		// BUSINESS LISTS MANAGEMENT
		static public var S_BL_ENTRY_POINTS_NOTIFICATIONS:Signal = new Signal('WSClient.S_BL_ENTRY_POintS_NOTIFICATIONS');
		static public var S_BL_NOTIFICATION_UPDATED:Signal = new Signal('WSClient.S_BL_NOTIFICATION_UPDATED');
		static public var S_BL_COMPANY_ONLINE_USER_STATUS:Signal = new Signal('WSClient.S_BL_COMPANY_ONLINE_USER_STATUS');
		static public var S_BL_COMPANY_ONLINE_USERS:Signal = new Signal('WSClient.S_BL_COMPANY_ONLINE_USERS');
		static public var S_BL_NOTIFICATION_ACCEPTED_ERR:Signal = new Signal('WSClient.S_BL_NOTIFICATION_ACCEPTED_ERR');
		static public var S_BL_NOTIFICATION_ADD:Signal = new Signal('WSClient.S_BL_NOTIFICATION_ADD');
		static public var S_BL_ENTRY_POINT_CANCEL:Signal = new Signal('WSClient.S_BL_ENTRY_POint_CANCEL');
		static public var S_BL_ENTRY_POINT_FORVARD:Signal = new Signal('WSClient.S_BL_ENTRY_POint_FORVARD');
		static public var S_BL_ADD_TO_COMPANY_CHAT_BY_REQUEST:Signal = new Signal('WSClient.S_BL_ADD_TO_COMPANY_CHAT_BY_REQUEST');
		static public var S_SIGNALING:Signal = new Signal('WSClient.S_SIGNALING');
		
		static public var S_ONLINE_USERS:Signal = new Signal('WSClient.S_ONLINE_USERS');
		static public var S_ONLINE_USER:Signal = new Signal('WSClient.S_ONLINE_USER');
		static public var S_ONLINE_USER_UPDATE:Signal = new Signal('WSClient.S_ONLINE_USER_UPDATE');
		static public var S_OFFLINE_USER:Signal = new Signal('WSClient.S_OFFLINE_USER');
		
		static public var S_USER_TOAD:Signal = new Signal('WSClient.S_USER_TOAD');
		static public var S_USER_PROFILE_UPDATE:Signal = new Signal('WSClient.S_USER_PROFILE_UPDATE');
		
		static public var S_CHAT_TITLE_CHANGE:Signal = new Signal('WSClient.S_CHAT_CHANGES');
		static public var S_CHAT_AVATAR_CHANGE:Signal = new Signal('WSClient.S_CHAT_AVATAR_CHANGE');
		static public var S_USER_CREATED:Signal = new Signal('WSClient.S_USER_CREATED');
		
		static public var S_USERS_STATUS:Signal = new Signal("WSClient.S_USERS_STATUS");
		static public var S_USER_BLOCK_STATUS:Signal = new Signal("WSClient.S_USER_BLOCK_STATUS");
		static public var S_PUSH_GLOBAL_STATUS:Signal = new Signal("WSClient.S_PUSH_GLOBAL_STATUS");
		static public var S_PUSH_CHAT_STATUS:Signal = new Signal("WSClient.S_PUSH_CHAT_STATUS");
		static public var S_UPDATE_ENTRY_POINTS:Signal = new Signal("WSClient.S_UPDATE_ENTRY_POINTS");
		
		static public var S_QUESTION_UPDATED:Signal = new Signal("WSClient.S_ANSWER_UPDATED");
		static public var S_QUESTION_NEW:Signal = new Signal("WSClient.S_QUESTION_NEW");
		static public var S_QUESTION_CLOSED:Signal = new Signal("WSClient.S_QUESTION_CLOSED");
		static public var S_MSG_ADD_ERROR:Signal = new Signal("WSClient.S_MSG_ADD_ERROR");
		
		static public var S_DUPLICATED_MESSAGE:Signal = new Signal("WSClient.S_DUPLICATED_MESSAGE");
		static public var S_BLOCKED_MESSAGE:Signal = new Signal("WSClient.S_BLOCKED_MESSAGE");
		static public var S_REMOVE_MESSAGE:Signal = new Signal("WSClient.S_REMOVE_MESSAGE");
		static public var S_BLOCKED_NO_SLOTS_MESSAGE:Signal = new Signal("WSClient.S_BLOCKED_NO_SLOTS_MESSAGE");
		
		static public var S_CHANNEL_UPDATE:Signal = new Signal("WSClient.S_CHANNEL_UPDATE");
		static public var S_MESSAGE_SENT_ADDITIONAL:Signal = new Signal("WSClient.S_MESSAGE_SENT_ADDITIONAL_invoke");
		static public var S_PUZZLE_PAID:Signal = new Signal('WSClient.S_PUZZLE_PAID');
		
		static public var S_CHANNEL_NEW:Signal = new Signal("WSClient.S_CHANNEL_NEW");
		static public var S_CHANNEL_CLOSED:Signal = new Signal("WSClient.S_CHANNEL_CLOSED");
		
		static public var S_PAID_BAN_USER_BANNED:Signal = new Signal("WSClient.S_PAID_BAN_USER_BANNED");
		static public var S_PAID_BAN_USER_UNBANNED:Signal = new Signal("WSClient.S_PAID_BAN_USER_UNBANNED");
		
		static public var S_LOCATION_UPDATE:Signal = new Signal("WSClient.S_LOCATION_UPDATE");
		
		static public var S_USER_PHASE_CHANGED:Signal = new Signal("WSClient.S_USER_PHASE_CHANGED");
		static public var S_PAID_MODERATOR_BAN_USER_CHANGE:Signal = new Signal("WSClient.S_PAID_MODERATOR_BAN_USER_CHANGE");
		static public var S_MODERATOR_BAN_USER_CHANGE:Signal = new Signal("WSClient.S_MODERATOR_BAN_USER_CHANGE");
		static public var S_IDENTIFICATION_QUEUE:Signal = new Signal("WSClient.S_IDENTIFICATION_QUEUE");
		static public var S_LOYALTY_CHANGE:Signal = new Signal("WSClient.S_LOYALTY_CHANGE");
		static public var S_ACTIVITY:Signal = new Signal("WSClient.S_ACTIVITY");
		static public var S_ESCROW_DEAL_EVENT:Signal = new Signal("WSClient.S_ESCROW_DEAL_EVENT");
		static public var S_ESCROW_OFFER_EVENT:Signal = new Signal("WSClient.S_ESCROW_OFFER_EVENT");
		static public var S_OFFER_CREATE_FAIL:Signal = new Signal("WSClient.S_OFFER_CREATE_FAIL");
		static public var S_OFFER_CREATED:Signal = new Signal("WSClient.S_OFFER_CREATED");
		
		static private var wasMessage:Boolean;

		static private var isGuestWasConnected:Boolean=false;
		static private var lastGuestUID:String=null;

		static public function getWasMessage():Boolean {
			return wasMessage;
		}
		
		static public function call_authorize(key:String):void {
			var ver:int=parseInt(Config.VERSION.replace(/\D/gi,""));
			var sdk:int = NativeExtensionController.getVersion();
			
			var data:Object = new Object();
			data.authKey = key;
			
			if (key == "web")
			{
				data.guestUID = Auth.uid;
				data.guestName = "Guest";
				isGuestWasConnected=true;
				lastGuestUID=Auth.uid;
			}
			else
			{
				data.mobileVersion = ver;
				data.platform = Config.PLATFORM;
				data.sdk = sdk;
				data.lang = LangManager.model.getCurrentLanguageID();
				if(isGuestWasConnected){
					isGuestWasConnected=false;
					PHP.call_statVI("switchGuest",lastGuestUID);
				}
			}
			
			send('auth', data );
		}
		
		static public function call_getCompanyOnlineUsers():void {
			send('getCompanyOnlineUsers');
		}
		
		static public function call_getEntryPointNotifications():void {
			send('getEntryPointNotifications');
		}
		
		static public function call_chatUserAdd(chatUID:String, userUIDs:Array):Boolean {
			return send("chatUserAdd", { chatUID:chatUID, userUid:userUIDs } );
		}
		
		static public function call_chatUserExit(chatUID:String):Boolean {
			return send("chatUserExit", { chatUID:chatUID } );
		}
		
		static public function call_chatUserEnter(chatUID:String):Boolean {
			return send("chatUserEnter", { chatUID:chatUID } );
		}
		
		static public function call_chatUserRemove(chatUID:String, userUID:String = null):Boolean {
			return send("chatUserRemove", { chatUID:chatUID, userUid:userUID } );
		}

		static public function call_setLang(lang:String):Boolean{
			return send("setLang", { lang:lang } );
		}
		
		static public function call_sendQMessage(chatUID:String, text:String, anonymous:Boolean = false):Boolean {
			return send('msgAdd', { chatUID:chatUID, text:text, qa:1, anonymous:anonymous } );
		}
		
		static public function call_updateTextMessage(chatUID:String, text:String, msgID:Number, updateLocaly:Boolean = false):Boolean {
			if (updateLocaly == true) {
				S_CHAT_MSG_UPDATED.invoke({ chatUID:chatUID, text:text, id:msgID, nsws:true });
				return true;
			}
			return send('msgChange', { chatUID:chatUID, text:text, id:msgID } );
		}
		
		static public function call_removeMessage(chatUID:String, msgID:Number):Boolean {
			return send('msgRemove', { chatUID:chatUID, id:msgID } );
		}
		
		static public function call_entryPointAccept(chatUID:String):Boolean {
			return send('entryPointAccept', { chatUID:chatUID } );
		}
		
		static public function call_entryPointCancel(chatUID:String):Boolean {
			return send("entryPointCancel", { chatUID:chatUID } );
		}
		
		static public function call_entryPointFinish(chatUID:String):Boolean {
			return send("entryPointFinish", { chatUID:chatUID } );
		}
		
		static public function call_entryPointForward(userUid:String, chatUID:String):Boolean {
			return send("entryPointForward", { userUid:userUid, chatUID:chatUID } );
		}
		
		static public function call_entryPointStart(pointID:int, chatUID:String, text:String = null):Boolean {
			return send('entryPointStart', { pointId:pointID, chatUID:chatUID, text:text } );
		}
		
		static public function call_addMemberToCompanyChat(userUIDs:Array, chatUID:String):Boolean {
			return send('blackHole', { mode:userUIDs, data: { method:"addToCompanyChat", chatUID:chatUID } } );
		}
		
		static public function call_chatTitleChanged(userUIDs:Array, chatUID:String, value:String):Boolean {
			return send('blackHole', { mode:userUIDs, data: { method:WSMethodType.CHAT_TITLE_CHANGE, chatUID:chatUID, topic: value } } );
		}
		
		static public function call_chatAvatarChanged(userUIDs:Array, chatUID:String, value:String):Boolean {
			return send('blackHole', { mode:userUIDs, data: { method:WSMethodType.CHAT_AVATAR_CHANGE, chatUID:chatUID, avatar: value } } );
		}
		
		static public function call_blackHole(userUIDs:Array, method:String, data:Object):Boolean {
			return send("blackHole", { mode:(userUIDs == null) ? "user" : userUIDs, data: { method:method, data:data } } );
		}
		
		static public function call_blackHoleWebRTC(userUIDs:Array, method:String, data:Object):Boolean {
			return send("blackHole", { mode:(userUIDs == null) ? "user" : userUIDs, data: { method:method, message:data } } );
		}
		
		static public function call_blackHoleToGroup(group:String, action:String, scope:String = null, method:String = null, data:Object = null):Boolean {
			return send("blackHole", { mode:"group", group:group, action:action, scope:scope, data: { method:method, data:data } } );
		}
		
		static public function call_chatSendAll(chatUID:String, data:Object):Boolean {
			return send("blackHole", { mode:"chat", chatUID:chatUID, data:data } );
		}
		
		static public function call_contactsOnline(usersUIDs:Array, flag:Number, chatUID:String = null):Boolean {
			return send('usersOnline', { uids:usersUIDs, flag:flag, chatUID:chatUID } );
		}
		
		static public function call_pushToUser(usersUIDs:Array, type:String = "call", sound:String = "42.caf", customData:Object = null):Boolean {
			return send('pushToUser', { uid:usersUIDs, type:type, sound:sound, customData:customData } );
		}
		
		static public function call_notificationBadgeCount(count:int):void {
			send('msgPushBadge', { badge:count } );
		}
		
		static public function call_userObserve(uids:Array):void {
			send("userObserve", { uids:uids } );
		}
		
		static public function call_getIdentificationQueue():void {
			send(WSMethodType.GET_IDENTIFICATION_QUEUE_LENGTH);
		}
		
		static public function call_sleepMode(val:Boolean):void {
			send("sleepStatus", { sleep:val } );
		}
		
		static public function call_changeNotoficationsMode(value:Boolean, chatUID:String = ""):void {
			var data:Object = new Object();
			data.mode = value;
			if (chatUID)
				data.chatUID = chatUID;
			send("pushAllow", data);
		}
		
		static public function call_sendTextMessages(chatUID:String, messages:Array):void {
			send('msgsAdd', { chatUID:chatUID, msgs:messages } );
		}
		
		static public function channel_user_ban(channelUid:String, userUid:String, reason:String, durationTime:Number):void {
			var data:Object = {};
			data.chatUID = channelUid;
			data.userUid = userUid;
			if (reason)
				data.reason = reason;
			if (!isNaN(durationTime))
				data.time = durationTime;
			else
				data.time = null;
			send(WSMethodType.CHAT_USER_BAN, data);
		}
		
		static public function channel_user_kick(channelUid:String, userUid:String):void {
			var data:Object = { };
			data.chatUID = channelUid;
			data.userUid = userUid;
			send(WSMethodType.CHAT_USER_KICK, data );
		}
		
		static public function channel_user_unban(channelUid:String, userUid:String):void {
			var data:Object = { };
			data.chatUID = channelUid;
			data.userUid = userUid;
			send(WSMethodType.CHAT_USER_UNBAN, data);
		}
		
		static public function channel_notify_background_changed(channelUid:String, background:String):void {
			//notify all users in channel;
			var data:Object = { };
			data.mode = "chat";
			data.chatUID = channelUid;
			data.data = { };
			data.data.method = WSMethodType.BH_METHOD_CHANNEL_BACKGROUND_CHANGED;
			data.data.chatUID = channelUid;
			data.data.back = background;
			send('blackHole', data);
		}
		
		static public function channel_notify_avatar_changed(channelUid:Object, avatar:String):void {
			//notify all users in channel;
			var data:Object = { };
			data.mode = "chat";
			data.chatUID = channelUid;
			data.data = { };
			data.data.method = WSMethodType.BH_METHOD_CHANNEL_AVATAR_CHANGED;
			data.data.chatUID = channelUid;
			data.data.avatar = avatar;
			send('blackHole', data);
		}
		
		static public function channel_notify_title_changed(channelUid:Object, title:String):void {
			//notify all users in channel;
			var data:Object = { };
			data.mode = "chat";
			data.chatUID = channelUid;
			data.data = {};
			data.data.method = WSMethodType.BH_METHOD_CHANNEL_TITLE_CHANGED;
			data.data.chatUID = channelUid;
			data.data.title = title;
			send('blackHole', data);
		}
		
		static public function channel_change_mode(channelUid:String, newValue:String):void {
			var data:Object = { };
			data.chatUID = channelUid;
			data.mode = newValue;
			send(WSMethodType.CHAT_MODE_SET, data);
		}
		
		static public function channel_add_moderator(channelUid:String, userUID:String):void {
			var data:Object = {};
			data.chatUID = channelUid;
			data.userUid = userUID;
			data.set = true;
			send(WSMethodType.CHAT_MODERATOR_SET, data);
		}
		
		static public function channel_remove_moderator(channelUid:String, userUID:String):void {
			var data:Object = { };
			data.chatUID = channelUid;
			data.userUid = userUID;
			data.set = false;
			send(WSMethodType.CHAT_MODERATOR_SET, data);
		}
		
		static public function updateUserStatus():void {
			send(WSMethodType.MY_STATUS, { } );
		}
		
		static public function call_addAnswerInvoice(chatUID:String, invoiceString:String):void {
			send("addAnswerInvoice", { chatUID:chatUID, text:invoiceString } );
		}
		
		static public function call_sendTextMessage(chatUID:String, text:String, existingMid:Number = -1, 
													addLocallyOnNetworkFailed:Boolean = true, senderId:String = null, 
													doNotSendToWS:Boolean = false, userUID:String = null, messageId:Object = null):Boolean {
			GD.S_DEBUG_WS.invoke("WSC: trying to send msg");
			wasMessage = true;
			var needBackMessage:Boolean = false;
			var mid:Number = existingMid;
			if (mid == -1) {
				needBackMessage = true;
				mid = new Date().getTime();
			}
			var networkSendResult:Boolean;
			if (WS.connected == false || NetworkManager.isConnected == false) {
				GD.S_DEBUG_WS.invoke("WSC: can't send, ws.connected: "+WS.connected+", Network: "+NetworkManager.isConnected);
				networkSendResult = false;
			} else {
				var data:Object = {};
				data.chatUID = chatUID;
				data.text = text;
				data.mid = mid;
				if (ChatManager.isAnon(chatUID) == true)
					data.anonymous = true;
				if (doNotSendToWS == false) {
					networkSendResult = send('msgAdd', data);
					GD.S_DEBUG_WS.invoke("WSC: SEND! "+networkSendResult);
				}
				else
					networkSendResult = true;
			}

			if (needBackMessage == false)
				return networkSendResult;
			
			if (networkSendResult == true && messageId != null)
			{
				messageId.id = mid;
			}
			
			if (networkSendResult == true || addLocallyOnNetworkFailed == true) {
				if (existingMid == -1) {
					if (senderId != null) {
						S_MESSAGE_SENT_ADDITIONAL.invoke(senderId, mid);
					}
					var backMessage:Object = createBackMessage(chatUID, text, mid);
					if (doNotSendToWS == true)
						backMessage.nsws = true;
					
					if (networkSendResult == true && doNotSendToWS == false) {
						MessagesController.newLocalMessage(backMessage);
					}
					backMessage.text = backMessage.text.substr(backMessage.text.indexOf("^", 1) + 1);
					S_CHAT_MSG.invoke(backMessage);
					GD.S_DEBUG_WS.invoke("WSC: SENT!");
				}else{
					GD.S_DEBUG_WS.invoke("WSC: msg already in view!");
				}
			}else{
				GD.S_DEBUG_WS.invoke("WSC: nothing to add to view");
			}

			return networkSendResult;
		}
		
		static public function call_addMessageReaction(message:Object):void {
			send(WSMethodType.CHAT_MESSAGE_REACTION, message);
		}
		
		static public function call_removeMessageReaction(message:Object):void {
			send(WSMethodType.CHAT_MESSAGE_REACTION, message);
		}
		
		static private function createBackMessage(chatUID:String, text:String, mid:Number):Object {
			echo("WSClient", "createBackMessage", "START");
			var backMessage:Object = {
				chat_uid:chatUID,
				chatUID:chatUID,
				created:int(mid/1000),
				delivery:"created",
				id:-mid,
				num:uint.MAX_VALUE,
				mid:mid,
				platform:"mob",
				status:"created",
				text:text,
				user_avatar:Auth.avatar,
				user_name:Auth.username,
				user_uid:Auth.uid
			}
			echo("WSClient", "createBackMessage", "END");
			return backMessage;
		}
		
		static private function onUserStatusRecieved(object:Object):void {
			/*pack : Object {
				data : Object {
					channel : Object {
						ban : Array {
							0 : "WgWcWoWjWxIuWI" 
						}
						moderators : Array {
							0 : "WgDaW3W0DUIvW5" 
						}
					}
				}
				method : "myStatus" 
			}*/
		}
		
		static private function onChannelModeChanged(data:Object):void {
			if (("chatUID" in data) && ("mode" in data))
				S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_MODE_CHANGED, data.chatUID, data.mode);
		}
		
		static private function onChannelModeratorResponse(data:Object):void {
			if (("error" in data)) {
				var message:String = "";
				if (("reason" in data))
					message = data.reason;
				if ("set" in data) {
					if (Boolean(data["set"]) == true)
						ToastMessage.display(Lang.failedAddModerator + ": " + message);
					else
						ToastMessage.display(Lang.failedRemoveModerator + ": " + message);
				} else
					ToastMessage.display(Lang.failedMamageModerator + ": " + message);
				return;
			}
			
			if (("chatUID" in data) && ("avatar" in data) && ("moderatorUID" in data) && ("name" in data) && ("set" in data) && ("userUid" in data)) {
				if (Boolean(data["set"]) == true)
					S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_MODERATOR_ADDED, data.chatUID, new ChatUserVO({uid:data.userUid, name:data.name, avatar:data.avatar}));
				else
					S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_MODERATOR_REMOVED, data.chatUID, data.userUid);
			}
		}
		
		static private function onChannelUserBanResponse(data:Object):void {
			if ("error" in data) {
				if ("reason" in data) {
					var errorText:String = data.reason;
					ToastMessage.display(Lang.failedUserBan + ": " + errorText);
				}
				return;
			}
			if (("chatUID" in data) && ("userUid" in data)) {
				var banData:UserBanData = new UserBanData();
				if (("banEndTime" in data) && ("banCreateTime" in data) && ("moderatorUID" in data) && ("reason" in data)) {
					banData.banEndTime = Number(data.banEndTime)/1000;
					banData.banCreatedTime = Number(data.banCreateTime)/1000;
					banData.moderator = data.moderatorUID;
					banData.reason = data.reason;
					banData.uid = data.userUid;
				}
				S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_BANNED, data.chatUID, banData);
			}
		}
		
		static private function onChannelBackgroundChanged(data:Object):void {
			if (("chatUID" in data) && ("back" in data))
				S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_BACKGROUND_CHANGED, data.chatUID, data.back);
		}
		
		
		static private function onChannelTitleChanged(data:Object):void {
			if (("chatUID" in data) && ("title" in data))
				S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_TITLE_CHANGED, data.chatUID, data.title);
		}
		
		static private function onChannelAvatarChanged(data:Object):void {
			if (("chatUID" in data) && ("avatar" in data))
				S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_AVATAR_CHANGED, data.chatUID, data.avatar);
		}
		
		static private function onChannelYouAddedToModerators(data:Object):void {
			if (("chatUID" in data) && ("channelTitle" in data))
				S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_ADDED_TO_MODERATORS, data.chatUID, data.channelTitle);
		}
		
		static private function onChannelUserUnbanResponse(data:Object):void {
			if (("chatUID" in data) && ("userUid" in data))
				S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_UNBAN, data.chatUID, data.userUid);
		}
		
		static private function onChannelUserKickResponse(data:Object):void {
			if ("error" in data) {
				if ("reason" in data) {
					var errorText:String = data.reason;
					ToastMessage.display(Lang.failedUserKick + ": " + errorText);
				}
			} else if (("chatUID" in data) && ("userUid" in data))
				S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_KICKED, data.chatUID, data.userUid);
		}
		
		
		
		static private function send(method:String, data:Object = null):Boolean {
			if (method != "pong")
				echo("WSClient", "send", method);
			return WS.send(method, data);
		}
		
		static public function handlePacket(pack:Object):void {
			// only for monitoring, do not use in your code
			// S_MESSAGE.invoke(pack);
			
			S_ACTIVITY.invoke();
			if (pack.method == 'ping') {
				send('pong', pack.data);
				return;
			}
			if (pack.method == "usersOnline") {
				S_ONLINE_USERS.invoke(pack.data);
				return;
			}
			if (pack.method == 'userOnline') {
				S_ONLINE_USER.invoke(pack.data);
				return;
			}
			if (pack.method == "userStatus") {
				S_USERS_STATUS.invoke(pack.data);
				return;
			}
			if (pack.method == 'userOffline') {
				S_OFFLINE_USER.invoke(pack.data.uid);
				return;
			}
			if (pack.method == 'chatUserEnter')
			{
				if ("error" in pack.data)
				{
					if ("reason" in pack.data)
					{
						var errorText:String = pack.data.reason;
						if (errorText == "User has been banned")
						{
							//узнать в каком чате забанен и обновить статус для чата в Auth;
						}
					}
				}
				else
				{
					S_CHAT_USER_ENTER.invoke(pack.data);
				}
				
				return;
			}
			if (pack.method == 'userPhase') {
				S_USER_PHASE_CHANGED.invoke( { phase: pack.data.phase, name: "ch_pp", steps:pack.data.steps } );
				return;
			}
			
			if (pack.method == 'userPhaseBank') {
				S_USER_PHASE_CHANGED.invoke( { phase: pack.data.phase, name: "ch_bank", steps:pack.data.steps } );
				return;
			}
			
			if (pack.method == 'userPhaseEU') {
				S_USER_PHASE_CHANGED.invoke( { phase: pack.data.phase, name: "eu_pp", steps:pack.data.steps } );
				return;
			}
			
			if (pack.method == 'userPhaseEU') {
				S_USER_PHASE_CHANGED.invoke( { phase: pack.data.phase, name: "eu_pp", steps:pack.data.steps } );
				return;
			}
			
			if (pack.method == "userCreated") {
				S_USER_CREATED.invoke(pack.data.phone, pack.data.name);
				return;
			}
			if (pack.method == "userProfileUpdate") {
				var update:Object;
				try {
					update = JSON.parse(pack.data);
				} catch (err:Error) {
					echo("WSClient", "handlePacket", "userProfileUpdate: JSON ERROR!!!");
					return;
				}
				S_USER_PROFILE_UPDATE.invoke(update);
			}
			if (pack.method == 'init') {
				try{
					var dbg:String = ""; // Print_r.show(pack, true);
					echo("WSClient","handlePacket","\nAuthorized on socket: \n"+dbg+"\n");9
				}catch(e:Error){}

				S_AUTHORIZED.invoke();
				return;
			}
			// AUTH ERROR
			if (pack.method == 'auth') {
				var err:String = 'Auth error';
				if ('data' in pack && 'error' in pack) {
					// AUTHORIZATION ERROR!!!
					if ('info' in pack.data){
						err = pack.data.info;
						if(err.indexOf("core..")!=-1)
							S_AUTHORIZED_ERROR.invoke(err);
						return;
					}
				}

				try{
					var dbg2:String=Print_r.show(pack,true);
					echo("WSClient","handlePacket","\nAuthorized on socket: \n"+dbg2+"\n");
				}catch(e:Error){}

				// NEED CLOSE WS AND RECONNECT
				// Sergey Nosov sad: WS will be immediately closed after auth error (2018.04.12)
				//WS.onClose();
				return;
			}
			
			
			if (pack.method == WSMethodType.MY_STATUS) {
				onUserStatusRecieved(pack.data);
				return;
			}
			if (pack.method == 'userToad') {
				S_USER_TOAD.invoke(pack.data);
				return;
			}
			
			trace("");
			trace("------------------------");
			trace(pack.method);
			traceObject(pack.data);
			trace("------------------------");
			
			if (pack.method == "changedLoyalty") {
				if (!pack.data || !pack.data.loyalty){
					//!TODO: error;
					return;
				}
				S_LOYALTY_CHANGE.invoke(pack.data.loyalty);
				return;
			}
			// изменение режима пуш сообщений - получать или нет. общая настройка или конкретно по указанному чату;
			if (pack.method == "pushAllow") {
				if (!pack.data)
				{
					//!TODO: error;
					return;
				}
				if ("mode" in pack.data)
				{
					if("chatUID" in pack.data && pack.data.chatUID != null)
					{
						S_PUSH_CHAT_STATUS.invoke( { status:pack.data.mode, chatUID:pack.data.chatUID } );
					}
					else {
						S_PUSH_GLOBAL_STATUS.invoke( { status:pack.data.mode } );
					}
				}
				
				return;
			}
			
			if (pack.method == "userUnblock") {
				if (!pack.data || !pack.data.uid)
				{
					//!TODO: error;
					return;
				}
				S_USER_BLOCK_STATUS.invoke( { uid:pack.data.uid, block:false } );
				return;
			}
			
			if (pack.method == 'blackHole') {
				checkBlackHoleMethod(pack);
				return;
			}
			if (pack.method == 'epEvent') {
				S_BL_NOTIFICATION_UPDATED.invoke(pack.data);
				return;
			}
			if (pack.method == 'entryPointStart') {
				S_BL_NOTIFICATION_ADD.invoke(pack.data);
				return;
			}
			if (pack.method == 'entryPointForward') {
				S_BL_ENTRY_POINT_FORVARD.invoke(pack.data);
				return;
			}
			if (pack.method == 'entryPointAccept') {
				S_BL_NOTIFICATION_ACCEPTED_ERR.invoke(pack.data);
				return;
			}
			if (pack.method == "entryPointCancel") {
				S_BL_ENTRY_POINT_CANCEL.invoke(pack.data);
				return;
			}
			if (pack.method == 'getCompanyOnlineUsers') {
				S_BL_COMPANY_ONLINE_USERS.invoke(pack.data);
				return;
			}
			if (pack.method == 'getCompanyUserOnlineStatus') {
				S_BL_COMPANY_ONLINE_USER_STATUS.invoke(pack.data);
				return;
			}
			
			//!TODO:
			/*if (pack.method == 'msgsAdd') {
				if (pack.data.error == true) {
					if (pack.data.reason == "You are blocked") {
						
					}
				}
			}*/
			
			if (pack.method == 'msgAdd') {
				if (pack.data.error == true) {
					echo("WSClinet", "onMessage.msgAdd", pack.data.reason, true);
					if (pack.data.reason == "Wrong status") {
						if (("chatUID" in pack.data) && ("mid" in pack.data)) {
							S_REMOVE_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().uid == pack.data.chatUID) {
								S_MSG_ADD_ERROR.invoke(ErrorCode.QUESTION_CLOSED);
							}
						}
					}
					if (pack.data.reason == "You are blocked") {
						if (("chatUID" in pack.data) && ("mid" in pack.data)) {
							S_BLOCKED_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							S_REMOVE_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().uid == pack.data.chatUID) {
								S_MSG_ADD_ERROR.invoke(ErrorCode.YOU_BLOCKED_IN_CHAT);
							}
						}
					}
					if (pack.data.reason == "No free slots") {
						if (("chatUID" in pack.data) && ("mid" in pack.data)) {
							S_BLOCKED_NO_SLOTS_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							S_MSG_ADD_ERROR.invoke(ErrorCode.NO_FREE_SLOTS_IN_QUESTION);
						}
					}
					if (pack.data.reason == "Moderated channel") {
						if (("chatUID" in pack.data) && ("mid" in pack.data)) {
							S_BLOCKED_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							S_REMOVE_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().uid == pack.data.chatUID) {
								S_MSG_ADD_ERROR.invoke(ErrorCode.NO_RIGHTS_SEND_IN_CHANNEL);
							}
						}
					} else if (pack.data.reason == "You don't have right") {
						if (("chatUID" in pack.data) && ("mid" in pack.data)) {
							S_REMOVE_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().uid == pack.data.chatUID) {
								S_MSG_ADD_ERROR.invoke(ErrorCode.NO_RIGHTS_SEND_IN_CHANNEL_BLOCKED);
							}
						}
					} else if (pack.data.reason == "You are banned") {
						if (("chatUID" in pack.data) && ("mid" in pack.data)) {
							//!TODO: получить инфо по бану;
							
							S_CHANNEL_UPDATE.invoke(ChannelsManager.EVENT_BANNED, pack.data.chatUID, null);
							S_BLOCKED_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							S_REMOVE_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
							
							if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().uid == pack.data.chatUID) {
								S_MSG_ADD_ERROR.invoke(ErrorCode.YOU_BANNED);
							}
						}
					}
					else if (pack.data.reason == "Duplicate key") {
						// удаление глючного сообщения из базы, должно быть обновлено в текущее состояние от сервера;
						if (("chatUID" in pack.data) && ("mid" in pack.data)) {
							S_DUPLICATED_MESSAGE.invoke(new MessageData(pack.data.chatUID, Number(pack.data.mid)));
						}
					} else {
						//!TODO: не отправлять в текущей сессии;
					}
					return;
				}
				
				if (pack.data.text.indexOf(Config.BOUNDS + "{\"method\":\"form\"") == 0)
					return;
				
				S_CHAT_MSG.invoke(pack.data);
				return;
			}
			
			if (pack.method == "msgChange") {
				S_CHAT_MSG_UPDATED.invoke(pack.data);
				return;
			}
			
			if (pack.method == "msgRemove") {
				S_CHAT_MSG_REMOVED.invoke(pack.data);
				return;
			}
			
			if (pack.method == 'getEntryPointNotifications') {
				S_BL_ENTRY_POINTS_NOTIFICATIONS.invoke(pack.data);
				return;
			}
			
			if (pack.method == 'chatUserAdd') {
				if (pack.data.error == true) {
					echo("WSClient","onMessage.chatUserAdd ", pack.data.reason, true);
					return;
				}
				
				S_CHAT_USERS_ADD.invoke(pack.data);
				return;
			}
			
			if (pack.method == "chatUserRemove") {
				if (pack.data.error == true) {
					echo("WSClient","onMessage.chatUserRemove ",pack.data.reason, true);
					return;
				}	
				S_CHAT_USER_REMOVE.invoke(pack.data);
				return;
			}
			
			
			if (pack.method == 'chatUserExit')
			{
				S_CHAT_USER_EXIT.invoke(pack.data);
				return;
			}
			
			if (pack.method == WSMethodType.CHAT_USER_KICK_RESPONSE)
			{
				onChannelUserKickResponse(pack.data);
				return;
			}
			if (pack.method == WSMethodType.CHAT_USER_BAN_RESPONSE)
			{
				onChannelUserBanResponse(pack.data);
				return;
			}
			if (pack.method == WSMethodType.CHAT_USER_UNBAN_RESPONSE)
			{
				onChannelUserUnbanResponse(pack.data);
				return;
			}
			if (pack.method == WSMethodType.CHAT_CHANGE_MODE_RESPONSE)
			{
				onChannelModeChanged(pack.data);
				return;
			}
			
			if (pack.method == WSMethodType.CHAT_MODERATOR_SET_RESPONSE)
			{
				onChannelModeratorResponse(pack.data);
				return;
			}
			
			if (pack.method == WSMethodType.CHAT_MESSAGE_REACTION)
			{
				S_MESSAGE_REACTION.invoke(pack.data);
				return;
			}
			
			if (pack.method == WSMethodType.PAID_BAN_BANNED) {
				S_PAID_BAN_USER_BANNED.invoke(pack.data);
				return;
			}
			if (pack.method == WSMethodType.PAID_BAN_UNBANNED) {
				S_PAID_BAN_USER_UNBANNED.invoke(pack.data);
				return;
			}
			
			if (pack.method == WSMethodType.MODERATOR_PAID_BAN_UNBANNED ||
				pack.method == WSMethodType.MODERATOR_PAID_BAN_BANNED) {
				S_PAID_MODERATOR_BAN_USER_CHANGE.invoke(pack.data);
				return;
			}
			
			if (pack.method == WSMethodType.MAIN_BAN)
			{
				S_MODERATOR_BAN_USER_CHANGE.invoke(pack.data);
				/*if (pack.data != null)
				{
					
				}
				data : Object {
					action : "unban" 
					user : "WSDJWuW0DOIv" 
				}*/
			}
			if (pack.method == WSMethodType.GET_IDENTIFICATION_QUEUE_LENGTH) {
				S_IDENTIFICATION_QUEUE.invoke(pack.total);
				return;
			}
			
			if (pack.method == WSMethodType.ESCROW_OFFER_ACCEPT)
			{
				return;
			}
			if (pack.method == WSMethodType.ESCROW_OFFER_CREATE_SUCCESS)
			{
				// !TODO: нет такого сигнала?;
				return;
			}
			if (pack.method == WSMethodType.ESCROW_OFFER_CREATE)
			{
				S_OFFER_CREATED.invoke(pack.data.offer);
				S_ESCROW_OFFER_EVENT.invoke(EscrowEventType.OFFER_CREATED, pack.data.offer);
				return;
			}
			if (pack.method == WSMethodType.ESCROW_OFFER_ERROR)
			{
				var errorObject:Object;
				if ("data" in pack && pack.data != null &&
					"error" in pack.data && pack.data.error != null)
				{
					errorObject = pack.data.error;
				}
				S_OFFER_CREATE_FAIL.invoke(new ErrorData(errorObject));
				
				/*pack : Object {
					data : Object {
						error : Object {
							code : "PAYAPI03" 
							msg : "Payment API Error: Wrong response" 
						}
						offer : Object {
							amount : 1 
							chatUID : "WLDIDRWmDNW5WPWe" 
							crypto_user_uid : "WLDNWrWbWoIxIbWI" 
							debit_account : "314931366384" 
							instrument : "DCO" 
							mca_ccy : "EUR" 
							mca_user_uid : "I6D5WsWZDLWj" 
							offer_id : 1630916498828 [0x17bba32d58c] 
							price : 1.15 
							side : "buy" 
							type : "typeCp2pOffer" 
						}
					}
					method : "cp2pOfferError" 
				}*/
				
				return;
			}
			if (pack.method == WSMethodType.ESCROW_OFFER_CANCEL)
			{
				S_ESCROW_OFFER_EVENT.invoke(EscrowEventType.CANCEL, pack.data.offer);
				/*pack : Object {
					data : Object {
						offer : Object {
							amount : 1 
							chatUID : "WLDIDRWmDNW5WPWe" 
							crypto_user_uid : "I6D5WsWZDLWj" 
							deal_uid : null 
							debit_account : "380867781292" 
							instrument : "DCO" 
							mca_ccy : "EUR" 
							mca_user_uid : "WLDNWrWbWoIxIbWI" 
							msg_id : 35651395 [0x21fff43] 
							offer_id : 1630928952116 [0x17bbaf0db34] 
							price : 1.42 
							side : "buy" 
							status : "canceled" 
							type : "typeCp2pOffer" 
							userUID : null 
						}
						reason : "canceled" 
					}
					method : "cp2pOfferCancel" 
				}*/
				
				
				return;
			}
			if (pack.method == WSMethodType.ESCROW_EVENT)
			{
				if (pack.action == "cp2p_deal_created" && pack.data != null && pack.data.event != null && pack.data.event.type == EscrowEventType.CREATED)
				{
					S_ESCROW_DEAL_EVENT.invoke(EscrowEventType.CREATED, pack.data.deal);
				}
				if (pack.action == "cp2p_deal_created" && pack.data != null && pack.data.event != null && pack.data.event.type == EscrowEventType.HOLD_MCA)
				{
					S_ESCROW_DEAL_EVENT.invoke(EscrowEventType.HOLD_MCA, pack.data.deal);
				}
				return;
			}
		}
		
		static private function traceObject(raw:Object, keyRaw:String = " "):void 
		{
			if (raw != null)
			{
				if (raw is Object)
				{
					for (var key:String in raw) 
					{
						if (raw[key] is String || raw[key] is Number || raw[key] is int || raw[key] == null)
						{
							trace(keyRaw + " | " + key + " = " + raw[key]);
						}
						else
						{
							traceObject(raw[key], keyRaw + key + " ");
						}
					}
				}
			}
		}
		
		static public function sendLocationUpdate(uid:String, location:Location):void 
		{
			call_chatSendAll(ChatManager.getCurrentChat().uid, {
				method: WSMethodType.LOCATION_UPDATE,
				userUID: Auth.uid,
				userName: Auth.username,
				chatUID: ChatManager.getCurrentChat().uid,
				lat:location.latitude,
				lon:location.longitude
			} );
		}
		
		static public function call_accept_offer(id:Number, debitAccount:String, cryptoWallet:String):void 
		{
			var request:Object = new Object();
			request.msg_id = id;
			if (debitAccount != null)
			{
				request.debit_account = debitAccount;
			}
			if (cryptoWallet != null)
			{
				request.crypto_wallet = cryptoWallet;
			}
			send(WSMethodType.ESCROW_OFFER_ACCEPT, request);
		}
		
		static public function call_create_offer(dataObject:Object, cryptoWallet:String):void 
		{
			if (cryptoWallet != null)
			{
				dataObject.crypto_wallet = cryptoWallet;
			}
			send(WSMethodType.ESCROW_OFFER_CREATE, dataObject);
		}
		
		static public function call_cancel_offer(id:Number):void 
		{
			send(WSMethodType.ESCROW_OFFER_CANCEL, {msg_id:id});
		}
		
		static private function checkBlackHoleMethod(pack:Object):void {
			var bhMethod:String;
			if ("data" in pack == false || pack.data == null)
				return;
			if ("data" in pack.data == false || pack.data.data == null)
				return;
			if ("method" in pack.data.data == false || pack.data.data.method == null || pack.data.data.method == "")
				return;
			bhMethod = pack.data.data.method;
			var bhData:Object;
			if ("data" in pack.data.data == true && pack.data.data.data != null) {
				bhData = pack.data.data.data;
				if ("cpt" in bhData == true && bhData.cpt != null && bhData.cpt.length != 0)
					bhData = JSON.parse(Crypter.decrypt(bhData.cpt, "123"));
			}
			if (bhMethod == WebRTCChannel.METHOD_BLACK_HOLE) {
				if ("sender" in pack.data == false || pack.data.sender == null || pack.data.sender == Auth.uid)
					return;
				if (bhData == null)
					return;
				S_SIGNALING.invoke(bhData);
				return;
			}
			if (bhMethod == WSMethodType.QUESTION_CREATED) {
				if (bhData == null)
					return;
				S_QUESTION_NEW.invoke(bhData);
				return;
			}
			if (bhMethod == WSMethodType.QUESTION_UPDATED) {
				if (bhData == null)
					return;
				S_QUESTION_UPDATED.invoke(bhData);
				GD.S_ESCROW_AD_UPDATED.invoke(bhData);
				return;
			}
			if (bhMethod == WSMethodType.QUESTION_CLOSED) {
				if (bhData == null || "quid" in bhData == false || bhData.quid == null || bhData.quid.length == 0)
					return;
				S_QUESTION_CLOSED.invoke(bhData.quid);
				return;
			}
			if (bhMethod == WSMethodType.PUZZLE_PAID) {
				if (bhData == null)
					return;
				S_PUZZLE_PAID.invoke(bhData);
				return;
			}
			if (bhMethod == WSMethodType.CHAT_USER_WRITING) {
				bhData = pack.data.data;
				if ("chatUID" in bhData == false || bhData.chatUID == null || bhData.chatUID == "")
					return;
				if ("userUID" in bhData == false || bhData.userUID == null || bhData.userUID == "" || bhData.userUID == Auth.uid)
					return;
				if ("userName" in bhData == false || bhData.userName == null || bhData.userName == "")
					return;
				S_USER_WRITING.invoke( { chatUID:pack.data.data.chatUID, userUID:pack.data.data.userUID, userName:pack.data.data.userName } );
				return;
			}
			if (bhMethod == WSMethodType.CHAT_TITLE_CHANGE) {
				bhData = pack.data.data;
				if ("chatUID" in bhData == false || bhData.chatUID == null || bhData.chatUID == "")
					return;
				if ("topic" in bhData == false || bhData.topic == null || bhData.topic == "")
					return;
				S_CHAT_TITLE_CHANGE.invoke( { chatUID:pack.data.data.chatUID, title: pack.data.data.topic } );
				return;
			}
			if (bhMethod == WSMethodType.CHAT_AVATAR_CHANGE) {
				bhData = pack.data.data;
				if ("chatUID" in bhData == false || bhData.chatUID == null || bhData.chatUID == "")
					return;
				if ("avatar" in bhData == false || bhData.avatar == null || bhData.avatar == "")
					return;
				S_CHAT_AVATAR_CHANGE.invoke( { chatUID:pack.data.data.chatUID, avatar: pack.data.data.avatar } );
				return;
			}
			if (bhMethod == WSMethodType.BH_METHOD_CHANNEL_BACKGROUND_CHANGED) {
				onChannelBackgroundChanged(pack.data.data);
				return;
			}
			if (bhMethod == WSMethodType.BH_METHOD_CHANNEL_AVATAR_CHANGED) {
				onChannelAvatarChanged(pack.data.data);
				return;
			}
			if (bhMethod == WSMethodType.BH_METHOD_CHANNEL_TITLE_CHANGED) {
				onChannelTitleChanged(pack.data.data);
				return;
			}
			if (bhMethod == WSMethodType.ADD_TO_COMPANY_CHAT) {
				S_BL_ADD_TO_COMPANY_CHAT_BY_REQUEST.invoke(pack.data.data.chatUID);
				return;
			}
			if (bhMethod == WSMethodType.SET_PHASE) {
				S_UPDATE_ENTRY_POINTS.invoke(pack.data.data);
				return;
			}
			if (bhMethod == WSMethodType.CHANNEL_CREATED) {
				if (bhData == null || "cuid" in bhData == false || bhData.cuid == null || bhData.cuid.length == 0)
					return;
				S_CHANNEL_NEW.invoke(bhData);
				return;
			}
			if (bhMethod == WSMethodType.CHANNEL_CLOSED) {
				if (bhData == null || "cuid" in bhData == false || bhData.cuid == null || bhData.cuid.length == 0)
					return;
				S_CHANNEL_CLOSED.invoke(bhData);
				return;
			}
			if (bhMethod == WSMethodType.LOCATION_UPDATE) {
				bhData = pack.data.data;
				if ("chatUID" in bhData == false || bhData.chatUID == null || bhData.chatUID == "")
					return;
				if ("userUID" in bhData == false || bhData.userUID == null || bhData.userUID == "" || bhData.userUID == Auth.uid)
					return;
				if ("userName" in bhData == false || bhData.userName == null || bhData.userName == "")
					return;
				S_LOCATION_UPDATE.invoke( { chatUID:pack.data.data.chatUID, userUID:pack.data.data.userUID, userName:pack.data.data.userName, location:(new Location(pack.data.data.lat, pack.data.data.lon)) } );
				return;
			}
			
			if (bhMethod == "rid" && "data" in pack && "data" in pack.data && "sender" in pack.data && (pack.data.sender == "WmWrWYW5WRIk" || pack.data.sender == "WdW6DJI1WbWo")){
				pack.data.data.sender = pack.data.sender;
				WSClient.S_RID.invoke(pack.data.data);
			}
			
			if ("data" in pack == true && pack.data != null)
				if ("data" in pack.data == true && pack.data.data != null)
					if ("data" in pack.data.data == true && pack.data.data.data != null)
						if ("cpt" in pack.data.data.data && pack.data.data.data.cpt != null)
							pack.data.data.data = bhData;
			S_BLACK_HOLE.invoke(pack.data);
		}
	}
}