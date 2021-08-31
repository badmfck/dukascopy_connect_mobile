package com.dukascopy.connect.vo {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.Entry;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.screenAction.customActions.CallChatInfoAction;
	import com.dukascopy.connect.data.screenAction.customActions.CallGetEuroAction;
	import com.dukascopy.connect.managers.escrow.EscrowDealManager;
	import com.dukascopy.connect.sys.applicationShop.parser.ShopProductDataParser;
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.LocalChatsSynchronizer;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.video.VideoUploader;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
	import com.dukascopy.langs.Lang;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class ChatVO {
		
		static public const LOCAL_CHAT_FLAG:String = "#LOCAL_";
		
		private var _hasQuestionAnswer:Boolean = false;
		
		private var _pin:String;
		private var _isDisposed:Boolean = false;
		private var _messages:Vector.<ChatMessageVO>;
		private var _uid:String = null;
		private var _ownerUID:String = null;
		private var _chatSecurityKey:String = null;
		private var _avatar:String = null;
		private var _securityKey:String = null;
		private var _type:String = null;
		private var _accessed:Number = 0;
		private var _title:String = 'Damaged chat';
		private var _imageKey:Array = [];
		private var _messageVO:ChatMessageVO = null;
		
		private var _unreaded:int = 0;
		
		private var _users:Vector.<ChatUserVO> = null;
		private var _questionID:String = null;
		
		private var _pid:int = -1;
		private var _created:Number = 0;
		private var _stat:Array;
		private var _pushAllowed:Boolean = true;
		
		private var _complain:String = null;
		
		private var _truncatedTitle:String = "";
		private var truncatedTitles:Object;
		private var raw:String = "";
		private var wasGroupTitle:Boolean = false;
		
		private var _settings:ChatSettingsRemote;
		
		private var euroActionMessageVO:ChatMessageVO;
		
		public var inTrash:Boolean;
		
		public var subscription:ShopProduct;
		
		public function ChatVO(data:Object = null) {
			_messages = new Vector.<ChatMessageVO>();
			if (data != null)
				setData(data);
		}
		
		private function fillData(keyvar:String, keyobj:String,obj:Object):Boolean{
			if (keyvar in this && keyobj in obj) {
				if (this[keyvar] != obj[keyobj]) {
					this[keyvar] = obj[keyobj];
					return true;
				}
			}
			return false;
		}
		
		public function setStoped():void {
			_complain = "stop";
		}
		
		public function setData(obj:Object):void {
			wasGroupTitle = false;
			_truncatedTitle = null;
			
			if ('complaint' in obj && obj.complaint != null) {
				_complain = obj['complaint'];
			}
			_unreaded = obj['unreaded'];
			_uid = obj['uid'];
			_avatar = obj['avatar'];
			if (_avatar != null)
				_avatar = _avatar.replace("http://www.dukascopy.com", "https://www.dukascopy.com");
			if ("created" in obj)
				_created = obj['created'] * 1000;
			updateSecurityKey(obj['securityKey']);
			_type = obj['type'];
			if (_type == ChatRoomType.CHANNEL)
				channelData = new ChannelData();
			
			_accessed = obj['accessed'];
			_users = null;
			//company 
			_ownerUID = obj['ownerID'];
			if ("pointID" in obj)
				setEPID(int(obj.pointID));
			if ('users' in obj)
				createUserList(obj['users'] as Array);
			//last message
			if ('message' in obj && obj.message != null && obj.message.text != null)
				setMessage(obj.message);
			if ('pushAllowed' in obj)
				_pushAllowed = Boolean(obj['pushAllowed']);
			if ("qUID" in obj)
				_questionID = obj.qUID;
			if ("qStatus" in obj && obj.qStatus == "rejected")
				_queStatus = true;
			 
			// Calculate title
			_title = 'Empty chat';
			
			if (_type == ChatRoomType.PRIVATE || _type == ChatRoomType.QUESTION) {
				if (_users != null && _users.length > 0) {
					for (var i:int = 0; i < _users.length; i++) {
						if (_users[i].uid == Auth.uid) {
							continue;
						}
						if (_users[i].uid == Config.NOTEBOOK_USER_UID) {
							_title = "(" + Lang.notebookName + ") ";
							if (Auth.myProfile != null) {
								_title += Auth.myProfile.getDisplayName();
							}
							
							break;
						}
						// зачем это в цикле если переписывается;
						if (_users[i].secretMode == true)
							_title = "Secret chat";
						else if (_users[i].name)
							_title = _users[i].name;
						else
							_title = getUsername(_users[i].name, _users[i].uid);
					}
				}
			} else if (_type == ChatRoomType.GROUP) {
				if (obj.title != null && obj.title != undefined && obj.title.length > 0 && obj.title.toLowerCase() != "private chat") {
					if (obj.title.substr(0, 1) == "!")
						_title = Crypter.decrypt(obj.title.substr(1), chatSecurityKey);
					else
						_title = obj.title;
					wasGroupTitle = true;
				} else {
					_title = Lang.groupChat;
					/*if (_users != null && _users.length > 0) {
						_title = '';
						for (var m:int = 0; m < _users.length; m++) {
							if (_users[m].secretMode == true)
								continue;
							if (m > 0)
								_title+= ', ';
							_title += getUsername(_users[m].name, _users[m].uid);
						}
						if (_title == "")
							_title = "Secret chat";
					}*/
				}
			}
			if (_title == null)
				_title = 'unknown chat';
			if (_type == ChatRoomType.COMPANY || _type == ChatRoomType.CHANNEL)
			{
				_title = obj["title"];
				
				var rex:RegExp = /[\s\r\n]+/gim;
				var key:String = "text" + _title.replace(rex, '');
				if (Lang[key] != null)
				{
					_title = Lang[key];
				}
			}
			if ((_title == null || _title =='Empty chat') && "title" in obj && obj["title"] != null) {
				_title = obj["title"];
			}
			if ("settings" in obj)
				settings = new ChatSettingsRemote(obj.settings);
			else if(settings == null)
				settings = new ChatSettingsRemote();
			/*if (("messagesHash" in obj) && obj.messagesHash != null)
				_messagesHash = obj.messagesHash;*/
			
			//Paid chat;
			if ("restricted" in obj && obj.restricted != null) {
				var parser:ShopProductDataParser = new ShopProductDataParser();
				subscription = parser.parse(obj.restricted, new ProductType(ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION));
				parser = null;
			}
		}
		
		private function createUserList(rawUsers:Array):void {
			_users ||= new Vector.<ChatUserVO>();
			_users.length = 0;
			if (rawUsers != null) {
				var usersNum:int = rawUsers.length;
				var user:ChatUserVO;
				for (var i:int = 0; i < usersNum; i++) {
					if (rawUsers[i] != null && rawUsers[i] is String == false)
					{
						user = new ChatUserVO(rawUsers[i], _type != ChatRoomType.CHANNEL);
						if (_ownerUID && _ownerUID == user.uid)
							user.setRole(ChatUserVO.ROLE_OWNER);
						// маркер подписки на канал - наличие в users своего пользователя с ролью user;
						if (type == ChatRoomType.CHANNEL && user.uid == Auth.uid && (user.role == ChatUserVO.ROLE_USER || user.userVO.type == ChatUserVO.ROLE_USER)) {
							if (channelData != null)
								channelData.subscribed = true;
						}
						if (type == ChatRoomType.PRIVATE) {
							if ("alarm" in rawUsers[i]) {
								reports = rawUsers[i].alarm;
							}
						}
						_users.push(user);
					}
				}
				user = null;
			}
		}
		
		private function updateUserList(rawUsers:Array):void {
			_users ||= new Vector.<ChatUserVO>();
			_users.length = 0;
			if (rawUsers != null) {
				var usersNum:int = rawUsers.length;
				var user:ChatUserVO;
				for (var i:int = 0; i < usersNum; i++) {
					if (users != null) {
						user = getUser(rawUsers[i].uid);
						if (user  != null) {
							user.update(rawUsers[i]);
						}
					}
					if (user == null) {
						user = new ChatUserVO(rawUsers[i]);
						if (_ownerUID && _ownerUID == user.uid)
							user.setRole(ChatUserVO.ROLE_OWNER);
						// маркер подписки на канал - наличие в users своего пользователя с ролью user;
						if (type == ChatRoomType.CHANNEL && user.uid == Auth.uid && user.role == ChatUserVO.ROLE_USER) {
							if (channelData != null)
								channelData.subscribed = true;
						}
						_users.push(user);
					}
				}
				user = null;
			}
		}
		
		public function updateTitle():Boolean {
			var oldTitle:String = _title;
			if (_type == ChatRoomType.PRIVATE || _type == ChatRoomType.QUESTION) {
				for (var i:int = 0; i < _users.length; i++) {
					if (_users[i].uid == Auth.uid)
						continue;
					// зачем это в цикле если переписывается;
					if (_users[i].name)
						_title = _users[i].name;
					else
						_title = getUsername(_users[i].name, _users[i].uid);
				}
			} else if (type == ChatRoomType.GROUP) { 
				if (wasGroupTitle)
					return false;
				_truncatedTitle = "";
				if (_users.length > 0) {
					_title = '';
					for (var m:int = 0; m < _users.length; m++) {
						if (m > 0)
							_title+= ', ';
						_title += _users[m].name;
					}
				}
			}
			if (title != oldTitle)
				return true;
			return false;
		}
		
		private function getUsername(username:String, userUID:String):String {
			var m:MemberVO = Auth.getCompanyMemberByUID(userUID);
			if (m != null)
				return m.name;
			if (username.substr(0, 4) != "user")
				return username;
			var newName:String = username;
			while (newName.length > 0 && isNaN(Number(newName.charAt(0))))
				newName = newName.substr(1);
			if (isNaN(Number(newName)))
				return username;
			var res:String = PhonebookManager.getUsernameByPhone(newName);
			if (res == "")
				return username;
			return res;
		}
		
		public function disposeMessages():void {
			if (_messages != null)
				for (var n:String in _messages)
					_messages[n].dispose();
			if (_messageVO != null && _messageVO.id == 0) {
				_messageVO.dispose();
				_messageVO = null;
			}
			_messages = new Vector.<ChatMessageVO>();
			lastMessagesHash = null;
			euroActionMessageVO = null;
		}
		
		public function addQuestionData(data:Object):void {
			questionMsgs = data;
		}
		
		public function setMessages(data:Array):Boolean {
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(data);
			var hash:String = MD5.hashBytes(bytes);
			if (lastMessagesHash != null && hash == lastMessagesHash)
			{
				return false;
			}
 			if (data && data[0]) {
				var cm:ChatMessageVO = new ChatMessageVO(data[0]);
				if (cm.text == null && cm.name == null && cm.userUID == null)
					echo("ChatVO", "setMessages", "DAMAGED DATA");
				cm.dispose();
				cm = null;
			}
			disposeMessages();
			lastMessagesHash = hash;
			var companyChat:Boolean = type == ChatRoomType.COMPANY;
			if (companyChat == true)
				addCompanyMessage(true);
			if (data == null || data.length == 0) {
				addQuestionMessages();
				return true;
			}
			var companyAvatar:String = "";
			var cmVO:ChatMessageVO;
			var userAvatar:String;
			var l:int = data.length;
			while (l--) {
				cmVO = new ChatMessageVO(data[l]);
				if (companyChat == true) {
					cmVO.avatar = companyAvatar;
				} else {
					userAvatar = getUserAvatar(cmVO.userUID);
					if (userAvatar != null && userAvatar != "")
						cmVO.avatar = userAvatar;
				}
				_messages.push(cmVO);
			}
			_lattestMsgID = _messages[0].id;
			addQuestionMessages();
			return true;
		}
		
		public function addMessages(data:Array):void {
			if (data == null || data.length == 0)
				return;
			var companyAvatar:String;
			/*if (type == ChatRoomType.COMPANY) {
				var epModel:EntryPointVO = Auth.getPhaseByID(pid);
				if (epModel != null)
					companyAvatar = epModel.avatarURL;
			}*/
			var i:int = 0;
			var l:int = 0;
			var firstIndex:int = 0;
			if (_messages != null && _messages.length != 0) {
				l = _messages.length;
				for (i = 0; i < l; i++) {
					if (isNaN(_messages[i].id) == true || _messages[i].id == 0)
						continue;
					firstIndex = i;
					break;
				}
			}
			l = data.length;
			var message:ChatMessageVO;
			var userAvatar:String;
			for (i = 0; i < l; i++) {
				if (data[i] != null) {
					if (type == ChatRoomType.COMPANY)
						data[i].user_avatar = companyAvatar;
					message = new ChatMessageVO(data[i]);
					userAvatar = getUserAvatar(message.userUID);
					if (userAvatar != null && userAvatar != "")
						message.avatar = userAvatar;
					_messages.insertAt(firstIndex, message);
				}
			}
			_lattestMsgID = _messages[firstIndex].id;
			lastMessagesHash = null;
		}
		
		private function needRemoveMessage(rawMessage:Object):Boolean {
			if (rawMessage == null)
				return true;
			if (rawMessage.id < 0 && rawMessage.text != null && rawMessage.text != "") {
				if ((rawMessage.text as String).charAt(0) == "|") {
					if (VideoUploader.existUploaderWithId(rawMessage.id) == false) {
						return true;
					}
				}
			}
			return false;
		}
		
		public function getUserAvatar(userUID:String):String {
			if (!usersAvatars)
				usersAvatars = new Dictionary();
			if (userUID in usersAvatars)
				return usersAvatars[userUID];
			var avatar:String;
			var userModel:UserVO = UsersManager.getFullUserData(userUID, false);
			if (userModel && userModel.getAvatarURL() != null) {
				avatar = userModel.getAvatarURL();
			} else {
				var chatUser:ChatUserVO = getUser(userUID);
				if (chatUser && chatUser.avatarURL) {
					avatar = chatUser.avatarURL;
				}
			}
			if (avatar) {
				usersAvatars[userUID] = avatar;
				return avatar;
			}
			return null;
		}
		
		private function addQuestionMessages():void {
			if (type != ChatRoomType.QUESTION)
				return;
			_hasQuestionAnswer = (_messages.length > 0);
			if (_qVO == null)
				return;
			if (_messages == null)
				_messages = new Vector.<ChatMessageVO>();
			if (_messages.length > 0 && _messages[0].id == 0)
				return;
			lastMessagesHash = null;
			var messageData:Object = { };
			/*if (_qVO.userUID != Auth.uid) {
				var createdTime:Number = (_qVO.messages != null && _qVO.messages.length > 0) ? _qVO.messages[0].createdTime : _qVO.createdTime;
				messageData.created = createdTime;
				
				var actionQuestion:ChatMessageVO = new ChatMessageVO(messageData);
				actionQuestion.action = new CallChatInfoAction();
				actionQuestion.action.setData(Lang.repostAbuse);
				_messages.unshift(actionQuestion);
				
				var actionEuro:ChatMessageVO = new ChatMessageVO(messageData);
				actionEuro.action = new CallGetEuroAction();
				actionEuro.action.setData(Lang.questionInfoButton);
				
				if (isNaN(_qVO.tipsAmount) == false) {
					var tipsData:Entry = new Entry();
					tipsData.title = Lang.extraTipsTitle.toUpperCase() + ":";
					tipsData.value = _qVO.tipsAmount + " " + _qVO.tipsCurrency.toUpperCase();
					actionEuro.action.setAdditionalData(tipsData);
				}
				euroActionMessageVO = actionEuro;
				_messages.unshift(actionEuro);
			}*/
			
			var userAvatar:String;
			
			if (_qVO.messages != null) {
				var qml:int = _qVO.messages.length;
				for (var j:int = 0; j < qml; j++) {
					messageData = { };
					messageData.id = 0;
					
					var marketPrice:Number;
					
					if (_qVO.instrument != null)
					{
						marketPrice = EscrowDealManager.getPrice(_qVO.instrument.code, _qVO.priceCurrency);
					}
					
					userAvatar = getUserAvatar(_qVO.userUID);
					if (userAvatar) {
						messageData.user_avatar = userAvatar;
					} else {
						messageData.user_avatar = _qVO.avatarURL;
					}
					
					var userName:String = "";
					if (_qVO.user != null)
						userName = _qVO.user.getDisplayName();
					messageData.user_name = userName;
					
					var text:String;
					var isPercent:Boolean = false;
					var realPrice:String;
					if (_qVO.price != null && _qVO.price.indexOf("%") != -1)
					{
						isPercent = true;
						realPrice = _qVO.price.replace("%", "");
						if (!isNaN(Number(realPrice)) && Number(realPrice) == 0)
						{
							text = Lang.escrow_ad_intro_message_at_market_price;
							if (!isNaN(marketPrice))
							{
								text += " (" + Lang.price_per_coin.replace("%@", NumberFormat.formatAmount(marketPrice, _qVO.priceCurrency)) + ")";
							}
						}
						else
						{
							text = Lang.escrow_ad_intro_message_percent;
						}
					}
					else
					{
						text = Lang.escrow_ad_intro_message;
					}
					
					if (_qVO.subtype == "buy")
					{
						text = text.replace("%@1", Lang.escrow_buy);
					}
					else
					{
						text = text.replace("%@1", Lang.escrow_sell);
					}
					text = text.replace("%@2", _qVO.cryptoAmount + " " + _qVO.tipsCurrencyDisplay);
					
					
					var price:String = _qVO.price;
					
					if (isPercent)
					{
						text = text.replace("%@4", price);
						
						if (Number(realPrice) > 0)
						{
							text = text.replace("%@5", Lang.above);
						}
						else
						{
							text = text.replace("%@5", Lang.below);
						}
						
						if (!isNaN(marketPrice))
						{
							price = NumberFormat.formatAmount(marketPrice * (1 + Number(realPrice)/100), _qVO.priceCurrency);
						}
						else
						{
							price = "@MKT";
						}
					}
					else
					{
						price += " " + _qVO.priceCurrency;
					}
					
					text = text.replace("%@3", price);
					
					messageData.text = text;
					messageData.usePlainText = true;
					messageData.created = _qVO.messages[j].createdTime;
					messageData.user_uid = _qVO.userUID;
					_messages.splice(j, 0, new ChatMessageVO(messageData));
				}
			}
		}
		
		private var test:int = 0;
		public function addCompanyMessage(needToSetMessage:Boolean = false):Boolean {
			if (type != ChatRoomType.COMPANY)
				return false;
			if (pid < 0)
				return false;
			if (_messageVO != null)
				return false;
			var msg:String = null;
			if (pid == Config.EP_VI_DEF && Auth.bank_phase == "VIDID")
				msg = Lang.vididWelcomeMSG;
			if (msg == null)
				return false;
			var messageData:Object = {
				id: 0,
				usePlainText: true,
				created: int((new Date()).getTime() / 1000),
				user_avatar: avatar,
				user_name: title,
				text: msg,
				qwerty: test
			};
			test++;
			if (needToSetMessage)
				setMessage(messageData);
			_messages.push(new ChatMessageVO(messageData));
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(messageData);
			lastMessagesHash = MD5.hashBytes(bytes);
			return true;
		}
		
		private var addedHash:Object = { };
		private var questionMsgs:Object;
		private var _qVO:QuestionVO;
		private var _queStatus:Boolean = false;
		private var _messageRaw:Object;
		private var usersAvatars:Dictionary;
		private var _lattestMsgID:Number;
		public var reports:int;
		public var channelData:ChannelData;
		
		public var lastMessagesHash:String;
		public var credentialMessageWasSent:Boolean=false;
		public var incomeLocal:Boolean;
		
		public function setEPID(id:int):void {
			_pid = id;
		}
		
		public function updateSecurityKey(key:String):void {
			_securityKey = key;
			if (_securityKey == null) {
				_imageKey = null;
				_chatSecurityKey = null;
			}else{
				_chatSecurityKey = _securityKey.substr(0, 32);
				if(_securityKey.length>32)
					_imageKey = Crypter.parseImageKey(_securityKey);
			}
		}
		
		private function setMessage(message:Object):void {
			if (message == null) {
				_messageVO.dispose();
				_messageVO = null;
				return;
			}
			if (_messageVO != null && _messageVO.num > message.num)
			{
				return;
			}
			_messageVO ||= new ChatMessageVO();
			_messageVO.setData(message);
			if (_messageVO.id > 0) {
				if (_qVO != null)
					_qVO.setHasMyAnswer();
				_hasQuestionAnswer = true;
			}
			_messageRaw = message;
			
			if (_messageVO.userUID == Auth.uid)
				_unreaded = 0;
		}
		
		public function setNewUreadedMessage(data:Object, incUnreadCount:Boolean):void {
			setMessage(data);
			if (_messageVO != null && Auth.uid == _messageVO.userUID)
				_unreaded = 0;
			else if (incUnreadCount == true)
				_unreaded++;
		}
		
		public function resetUnreaded():void {
			_unreaded = 0;
		}
		
		public function getDate():Date {
			if (_messageVO != null && _messageVO.created != 0)
				return _messageVO.date;
			var date:Date = new Date();
				date.setTime(_created);
			date.setHours(0, 0, 0, 0);
			return date;
		}
		
		public function getPrecenceDate():Date {
			if (_messageVO != null && _messageVO.created != 0)
				return _messageVO.datePrecence;
			var date:Date = new Date();
				date.setTime(_created);
			return date;
		}
		
		public function getTime():Number {
			if (_messageVO != null && _messageVO.created != 0)
				return _messageVO.created * 1000;
			return _created;
		}
		
		public function getMessageById(messageId:Number):ChatMessageVO {
			if (messages == null)
				return null;
			var l:int = _messages.length;
			for (var i:int = 0; i < l; i++) {
				if (_messages[i].id == messageId) {
					return _messages[i];
				}
			}
			return null;
		}
		
		public function updateMessage(data:Object, mid:Boolean = false):ChatMessageVO {
			if (_messageVO != null && _messageVO.id == data.id)
				_messageVO.setData(data);
			if (messages == null)
				return null;
			var l:int = _messages.length;
			for (var i:int = 0; i < l; i++) {
				if (mid == true) {
					if (("mid" in data) && data.mid != "" && _messages[i].id == -data.mid && data.id >= 0) {
						_messages[i].setData(data);
						return _messages[i];
					}
				} else {
					if (_messages[i].id == data.id) {
						_messages[i].updateText(data.text);
						_messages[i].setStatus(data.status);
						return _messages[i];
					} else if (("mid" in data) && data.mid != "" && data.mid != null && _messages[i].id == -data.mid && data.id >= 0) {
						_messages[i].setData(data);
						return _messages[i];
					}
				}
			}
			return null;
		}
		
		public function setPin(pin:String):void {
			_pin = pin;
			if (messages == null)
				return;
			var l:int = _messages.length;
			for (var i:int = 0; i < l; i++)
				_messages[i].setPin();
		}
		
		public function markMessagesRead(uid:String, messageID:String):void
		{
			/*if (_stat == null)
				return;
			
			var lastMessageId:Number;
			if (messageVO != null && messageVO.id > messageID)
			{
				lastMessageId = messageVO.id;
			}
			else
			{
				lastMessageId = messageID;
			}
			var vl:int = _stat.length;
			for (var i:int = 0; i < vl; i++) {
				if (_stat[i].uid == uid) {
					_stat[i].lastID = lastMessageId;
				}
			}*/
		}
		
		public function addStat(val:Array):Boolean {
			if (val == null)
				return false;
			if (_stat == null) {
				_stat = val;
				return true;
			}
			var vl:int = val.length;
			var was:Boolean = false;
			var userIn:Boolean;
			for (var i:int = 0; i < vl; i++) {
				userIn = false;
				for (var j:int = 0; j < _stat.length; j++) {
					if (_stat[j].uid == val[i].uid) {
						if (val[i].lastID != null && _stat[j].lastID != val[i].lastID && _stat[j].lastID < val[i].lastID) {
							_stat[j].lastID = val[i].lastID;
							was = true;
						}
						userIn = true;
					}
				}
				if (userIn == false)
					_stat.push(val[i]);
			}
			return was;
		}
		
		public function getMsgStatusCode(id:Number):String {
			if (id < 0)
				return ChatMessageVO.STATUS_SENDING;
			if (type == ChatRoomType.CHANNEL)
				return null;
			if (_stat == null)
				return null;
			var count:int = 0;
			var readCount:int = 0;
			for (var i:int = 0; i < stat.length; i++) {
				if (_stat[i].uid == Auth.uid)
					continue;
				count++;
				if (!(stat[i].lastID < id))
					readCount++;
			}
			if (count == readCount)
				return ChatMessageVO.STATUS_READ;
			else
				return ChatMessageVO.STATUS_SENT;
		}
		
		public function toString():String {
			return raw;
		}
		
		public function removeUser(uid:String):void {
			if (_users.length > 0) {
				for (var m:int = 0; m < _users.length;m++) {
					if (_users[m].uid == uid) {
						if (type == ChatRoomType.CHANNEL) {
							if (_users[m].userVO != null && _users[m].userVO.type == UserType.BOT) {
								_users.removeAt(m);
							} else if (_users[m].isChatModerator()) {
								_users[m].setRole(ChatUserVO.ROLE_USER);
							}
						}
						else {
							_users.removeAt(m);
						}
						
						updateTitle();
						return;
					}
				}
			}
		}
		
		public function get messages():Vector.<ChatMessageVO>{ return _messages; }
		public function get uid():String { return _uid; }
		public function get chatSecurityKey():String { return _chatSecurityKey; }
		public function get securityKey():String { return _securityKey; }
		public function get accessed():Number { return _accessed; }
		
		public function get title():String { return _title; }
		public function get imageKey():Array { return _imageKey; }
		public function get unreaded():int { return _unreaded; }
		public function get isDisposed():Boolean { return _isDisposed; }
		public function get users():Vector.<ChatUserVO> { 	return _users; }
		public function get locked():Boolean { return !(_pin == null || _pin == "----") }
		public function get type():String { return _type; }
		public function get pid():int { return _pid; }
		public function get ownerUID():String {	return _ownerUID; }
		
		public function get pin():String {	return _pin; }
		public function get stat():Array { return _stat; }
		public function get truncatedTitle():String { return _truncatedTitle; }
		
		public function set truncatedTitle(value:String):void { _truncatedTitle = value; }
		
		public function get avatarURL():String {
			if (type == ChatRoomType.GROUP) {
				if (_avatar != null && _avatar.length != 0)
					return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=" + Auth.key + "&uid=" + avatar + "&type=image";
				return null;	
			}
			var url:String = avatar;
			if (url == null)
				return null;
			else if (LocalAvatars.isLocal(url))
				return avatar;
			if (url.indexOf("no_photo") != -1)
				return null;
			if (url.indexOf("vk.me") != -1)
				return url;
			if (url.indexOf("method=files.get") != -1 &&  url.indexOf("http://dccapi.dukascopy.com") != -1)
				return url;
			var avatarSize:int = int(Config.FINGER_SIZE * .92);
			var userCode:Array = url.split("/");
			if (url.indexOf("graph.facebook.com") != -1) {
				if (userCode.length > 4)
					return "https://graph.facebook.com/" + userCode[3] + "/picture?width=" + avatarSize + "&height=" + avatarSize;
			} else {
				if (userCode.length > 5 && url.indexOf("wb-dev.telefision") == -1)
					return Config.URL_IMAGE + userCode[5] + "/" + avatarSize + "_3/image.jpg";
			}
			return Config.URL_PHP_CORE_SERVER + "?method=img.get&url=" + escape(url) + "&key=web";
		}
		
		public function get avatar():String {
			if (type == ChatRoomType.PRIVATE && getUser(Config.DUKASCOPY_INFO_SERVICE_UID) != null)
			{
				return LocalAvatars.BANK;
			}
			if (_avatar == null || _avatar.length == 0) {
				if ((type == ChatRoomType.PRIVATE || type == ChatRoomType.QUESTION) && _users != null && _users.length > 0) {
					var user:ChatUserVO = UsersManager.getInterlocutor(this);
					if (user != null) {
						if (user.uid == Config.NOTEBOOK_USER_UID && Auth.myProfile != null)
							return Auth.myProfile.getAvatarURL();
						return user.avatarURL;
					}
				}
				return null;
			}
			if (_avatar.indexOf("no_photo") != -1)
				return null;
			if (_avatar.indexOf("graph.facebook.com") != -1) {
				var userCode:Array = _avatar.split("/");
				if (userCode.length > 4)
					return "http://graph.facebook.com/" + userCode[3] + "/" + userCode[4];
			}
			return _avatar;
		}
		
		public function set title(value:String):void {
			truncatedTitle = null;
			_title = value;
		}
		
		public function set avatar(value:String):void {
			_avatar = value;
		}
		
		public function set type(value:String):void {
			_type = value;
		}
		
		public function get created():Number 
		{
			return _created;
		}
		
		public function set created(value:Number):void {
			_created = value;
		}
		
		public function getPushAllowed():Boolean {
			return _pushAllowed;
		}
		
		public function setPushAllowed(value:Boolean):void {
			_pushAllowed = value;
		}
		
		public function getImageString():String {
			return _chatSecurityKey;
		}
		
		public function getQuestion():QuestionVO {
			return _qVO;
		}
		
		public function getQuestionUserUID():String {
			if (questionMsgs == null)
				return "";
			return questionMsgs.user_uid;
		}
		
		public function setQuestion(qVO:QuestionVO):Boolean {
			if (qVO != null && _qVO == qVO) {
				if (_hasQuestionAnswer == false) {
					if (_qVO.answersCount > 0)
						return false;
					disposeMessagesWithoutID();
					addQuestionMessages();
				}
				return true;
			}
			_qVO = qVO;
			if (_qVO == null)
				return false;
			QuestionsManager.setInOut(true);
			_qVO.removeFromUnread(uid);
			addQuestionMessages();
			
			if (_qVO.incognito == true && _qVO.type == QuestionsManager.QUESTION_TYPE_PUBLIC && users != null){
				var user:ChatUserVO = getUser(ownerUID);
				if (user != null){
					user.setSecret(true);
				}
			}
			
			return true;
		}
		
		public function disposeMessagesWithoutID():void {
			euroActionMessageVO = null;
			if (_messages != null) {
				while (_messages.length) {
					if (isNaN(_messages[0].id) || _messages[0].id == 0) {
						_messages[0].dispose();
						_messages.splice(0, 1);
					} else {
						break;
					}
				}
			}
		}
		
		public function setQuestionStatus():void {
			_queStatus = true;
		}
		
		public function getUser(userUID:String):ChatUserVO {
			if (users) {
				for (var i:int = 0; i < users.length; i++) {
					if (users[i].uid == userUID) {
						return users[i];
					}
				}
			}
			return null;
		}
		
		public function getRawData():Object {
			var raw:Object = new Object();
			
			if (_complain) {
				raw.complaint = _complain;
			}
			
			raw.unreaded = _unreaded;
			raw.uid = _uid;
			raw.avatar = avatar;
			raw.created = _created / 1000;
			
			raw.securityKey = _securityKey;
			raw.type = _type;
			raw.accessed = _accessed;
			raw.ownerID = _ownerUID;
			raw.users = new Array();
			if (_users)
			{
				var usersNum:int = _users.length;
				var rawuserData:Object;
				for (var i:int = 0; i < usersNum; i++) 
				{
					rawuserData = _users[i].getRawData();
					if (rawuserData)
					{
						raw.users.push(rawuserData);
					}
				}
			}
			
			raw.pushAllowed = _pushAllowed;
			raw.qUID = _questionID;
			//???
			raw.qStatus = (_queStatus == true)?"rejected":"";
			raw.title = _title;
			raw._unreaded = unreaded;
			if (_messageRaw)
			{
				raw.message = _messageRaw;
			}
			if (settings)
			{
				raw.settings = settings.getRawData();
			}
			//raw.messagesHash = messagesHash;
			
			return raw;
		}
		
		public function isLocal():Boolean {
			if (uid == null)
				return false;
			return (uid.indexOf(LOCAL_CHAT_FLAG) != -1);
		}
		
		public function deleteMessage(messageIdToDelete:Number):Boolean 
		{
			var deleted:Boolean = false;
			if (_messages)
			{
				var l:int = _messages.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (_messages[i].id == messageIdToDelete)
					{
						_messages.splice(i, 1);
						deleted = true;
						break;
					}
				}
			}
			if (_messageVO != null && _messageVO.id == messageIdToDelete) {
				if (_messages && _messages.length > 0) {
					setMessage(_messages[_messages.length - 1].rawObject);
				} else {
					setMessage(null);
				}
			}
			if (deleted == true) {
				lastMessagesHash = null;
				//messagesHash = null;
			}
			return deleted;
		}
		
		public function isOwner(uid:String):Boolean {
			return _ownerUID == uid;
		}
		
		public function isModerator(uid:String):Boolean {
			if (_users) {
				var l:int = _users.length;
				for (var i:int = 0; i < l; i++) {
					if (_users[i] && ("uid" in _users[i]) && _users[i].uid == uid) {
						return _users[i].isChatModerator();
					}
				}	
			}
			return false;
		}
		
		public function addUser(userData:ChatUserVO):void {
			if (_users != null) {
				var l:int = _users.length;
				for (var i:int = 0; i < l; i++) {
					if (_users[i].uid == userData.uid) {
						_users.removeAt(i);
						break;
					}
				}
				_users.push(userData);
			}
		}
		
		public function getLastSentMessageId():Number {
			if (_stat == null)
				return null;
			for (var i:int = 0; i < stat.length; i++) {
				if (_stat[i].uid == Auth.uid)
					continue;
				return _stat[i].dlvID;
			}
			return null;
		}
		
		public function getLastReadMessageId():Number {
			if (_stat == null)
				return null;
			for (var i:int = 0; i < stat.length; i++) {
				if (_stat[i].uid == Auth.uid)
					continue;
				return _stat[i].lastID;
			}
			return null;
		}
		
		public function get questionID():String {
			if (_questionID == null)
				return "";
			return _questionID;
		}
		
		public function get queStatus():Boolean {
			return _queStatus;
		}
		
		public function get complainStatus():String {
			return _complain;
		}
		
		public function set uid(value:String):void {
			_uid = value;
		}
		
		public function set accessed(value:Number):void {
			_accessed = value;
		}
		
		public function set ownerUID(value:String):void {
			_ownerUID = value;
		}
		
		/*public function get messagesHash():String {
			return _messagesHash;
		}
		
		public function set messagesHash(value:String):void {
			_messagesHash = value;
		}*/
		
		public function get hasQuestionAnswer():Boolean {
			return _hasQuestionAnswer;
		}
		
		public function get messageVO():ChatMessageVO {
			return _messageVO;
		}
		
		public function get message():String {
			if (_messageVO == null)
				return "";
			if (_messageVO.crypted == true)
				_messageVO.decrypt(_chatSecurityKey, pin, incomeLocal);
			if (_messageVO.crypted == true)
				return Lang.cryptedMessage;
			if (_messageVO.status == "cleaned" && (_messageVO.text == null || _messageVO.text == ""))
				return Lang.cleanedMessage;
			if (_messageVO.status == "deleted")
				return Lang.deletedMessage;
			return _messageVO.textSmall;
		}
		
		public function get messageStatus():String { return (_messageVO != null) ? _messageVO.status : ""; }
		public function get messageWriterUID():String {	return (_messageVO != null) ? _messageVO.userUID : ""; }
		public function get messageType():String { return (_messageVO != null) ? _messageVO.type : ""; }
		public function get messageID():int { return (_messageVO != null) ? _messageVO.id : 0; }
		public function get wasSmile():int { return (_messageVO != null) ? _messageVO.wasSmile : 1; }
		public function set wasSmile(val:int):void {
			if (_messageVO == null)
				return;
			_messageVO.wasSmile = val;
		}
		
		public function get lattestMsgID():Number { return _lattestMsgID; }
		
		public function get settings():ChatSettingsRemote 
		{
			return _settings;
		}
		
		public function set settings(value:ChatSettingsRemote):void 
		{
			if (value != null && isNaN(value.backgroundBrightness) && _settings != null && !isNaN(_settings.backgroundBrightness))
			{
				value.backgroundBrightness = _settings.backgroundBrightness;
			}
			_settings = value;
		}
		
		public function getEuroActionMessageVO():ChatMessageVO {
			return euroActionMessageVO;
		}
		
		public function getTruncatedTitle(width:int):String {
			if (truncatedTitles == null)
				return null;
			if (width in truncatedTitles)
				return truncatedTitles[width];
			return null;
		}
		
		public function setTruncatedTitle(text:String, width:int):void {
			truncatedTitles ||= { };
			truncatedTitles[width] = text;
		}
		
		public function dispose():void {
			disposeMessages();
			_messages = null;
			_uid = null;
			_chatSecurityKey = null;
			_avatar = null;
			_securityKey = null;
			_type = null;
			lastMessagesHash = null;
			_accessed = 0;
			_truncatedTitle = null;
			_title = null;
			_isDisposed = true;
			_messageRaw = null;
			_qVO = null;
			settings = null;
			
			if (_users) {
				var usersNum:int = _users.length;
				for (var i:int = 0; i < usersNum; i++) {
					_users[i].dispose();
				}
			}
			
			_users = null;
			usersAvatars = null;
		}
		
		public function getLastMessageId():void {
			
		}
		
		public function isIncomingLocalChat():Boolean 
		{


			if (securityKey == null)
			{
				return false;
			}
			//return  false;
			return securityKey.indexOf(LocalChatsSynchronizer.LOCAL_INCOME_CHAT_FLAG) == 0;
		}
		
		public function isLocalIncomeChat():Boolean 
		{
			if (_chatSecurityKey == null)
			{
				return false;
			}
			return _chatSecurityKey.indexOf(LocalChatsSynchronizer.LOCAL_INCOME_CHAT_FLAG) == 0;
		}
	}
}