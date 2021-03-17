package com.dukascopy.connect.vo {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.businessListManager.BusinessListManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.vo.users.adds.MemberVO;

	/**
	 * ...
	 * @author ...
	 */
	public class BLNotificationVO {

		public static const EVENT_STARTED:String = 'started';
		public static const EVENT_MESSAGE:String = 'msg';
		public static const EVENT_CANCELED:String = 'canceled';
		public static const EVENT_FINISHED:String = 'finished';
		public static const EVENT_TIMEOUT:String = 'timeout';
		public static const EVENT_CANCELED_BY_CLIENT:String = 'canceled_by_client';
		public static const EVENT_OCCUPIED:String = 'occupied';
		
		private var acceptorsString:String = null;
		
		public var pointID:int;
		public var clientName:String;
		public var clientUID:String;
		public var chatUID:String;
		public var createTime:Number=0;
		public var lastCancelTime:Number=0;
		public var event:String;
		public var acceptors:Array;
		public var occupiedBy:String;
		public var pid:int;
		public var geo:Object = null;
		
		public var msg:String = null;
		public var msgSender:String;
		public var msgSenderUID:String;
		public var msgTime:Number = 0;
		
		public var unreadedMessages:int = 0;
		public var lastMsg:String = '';
		private var lastMsgHash:String = '';
		private var _isDisposed:Boolean = false;
		
		public function BLNotificationVO(data:Object) {
			acceptors = [];
			update(data);
		}
		
		public function getObject():Object {
			return {
				pointID:pointID,
				clientName:clientName,
				clientUID:clientUID,
				chatUID:chatUID,
				createTime:createTime,
				lastCancelTime:lastCancelTime,
				event:event,
				pid:pid,
				acceptors:acceptors,
				lastMsg:lastMsg
			}
		}
		
		public function update(data:Object):void {
			geo = data.geo;
			pointID = data.pointId;
			clientName = data.client.name;
			clientUID = data.client.uid;
			chatUID = data.chatUID;
			occupiedBy = data.occupied;
			createTime = data.createTime* 1000;
			lastCancelTime = data.lastCancelTime * 1000;
			event = data.event;
			pid = data.pid;
			
			acceptors = data.acceptor;
			acceptorsString = null;
			
			var paranoic:Boolean;
			if ("msg" in data && data.msg != null) {
				if ('text' in data.msg && data.msg.text != null && data.msg.text.indexOf(Config.BOUNDS) != 0) {
					paranoic = false;
					if (data.msg.text.charAt(0) == '.')
						paranoic = true;
					else if (BusinessListManager.company != null)
						msg = Crypter.decrypt(data.msg.text, BusinessListManager.company.securityKey.substr(0, 32));
				} else
					msg = data.msg.text;
				if (msg != null && msg.indexOf(Config.BOUNDS) == 0)
					msg = 'System message.';
				if (paranoic)
					msg = 'Crypted message.';
				/*if ("text" in data.msg && data.msg.text != null && data.msg.text != ""){
					msg = data.msg.text;
					if (msg.substr(0, 9) == Config.BOUNDS) {
						msg  = data.msg.text;
					}else{
						msg = Crypter.decrypt(data.msg.text, BusinessListManager.company.securityKey.substr(0, 32));
					}
					
				}else{
					msg = "";
				}*/
				lastMsg = msg; // ILYA SHCHERBAKOV 13.01.2015
				if ("username" in data.msg && data.msg.username != null)
					msgSender = data.msg.username;
				else
					msgSender = "";
				if ("uid" in data.msg && data.msg.uid != null)
					msgSenderUID = data.msg.uid;
				else
					msgSenderUID = "";
				if ("time" in data.msg && data.msg.time != null)
					msgTime = data.msg.time * 1000;
				else
					msgTime = 0;
			}else {
				lastMsg = '';
				msg = '';
				msgSender = '';
				msgSenderUID = '';
				msgTime = 0;
			}
			
			/*if (ChatManager.currentChat.uid != chatUID) {
				var mh:String = msg + '' + msgTime+'' + msgSender ;
				if (mh != lastMsgHash) {
					lastMsgHash = mh;
					unreadedMessages++;
				}
			} else {
				unreadedMessages = 0;
				lastMsgHash = '';
			}*/
		}
		
		public function getAcceptors():String {
			if (acceptorsString == null) {
				acceptorsString = "";
				if (acceptors != null && acceptors.length > 0) {
					var n:int = 0;
					var l:int = acceptors.length;
					for (var a:Object in acceptors) {
						var m:MemberVO = null;
						var index:int = BusinessListManager.getMemberIndexByUserUid(a.uid);
						if (index == -1) {
							if (a.uid == BusinessListManager.company.me.userUID)
								m = BusinessListManager.company.me;
							else
								continue;
						} else
							m = BusinessListManager.company.members[index];
						acceptorsString += m.fxName + ((n + 1 < l)?', ':'');
						n++;
					}
				}
				if (acceptorsString == '')
					acceptorsString = 'NONE';
						else
							acceptorsString = acceptorsString;
			}
			return acceptorsString;
		}
		
		public function dispose():void {
			_isDisposed = true;
		}
		
		public function get isDisposed():Boolean { return _isDisposed; }
	}
}