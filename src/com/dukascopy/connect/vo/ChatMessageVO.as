package com.dukascopy.connect.vo {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ChatSystemMessageData;
	import com.dukascopy.connect.data.ListRenderInfo;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.OverlayData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.LocalChatsSynchronizer;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.sys.usersManager.extensions.ExtensionType;
	import com.dukascopy.connect.type.ChatMessageReactionType;
	import com.dukascopy.connect.utils.ImageCrypterOld;
	import com.dukascopy.connect.vo.chat.ChatMessageReaction;
	import com.dukascopy.connect.vo.chat.ReplayMessageVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.mteamapp.StringFunctions;
	
	
	/**
	 * Main value object for chat message
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ChatMessageVO {
		
		static public const TYPE_SYSTEM:String = "system";

		static public const STATUS_SENDING:String = "statusSending";
		static public const STATUS_SENT:String = "statusSent";
		static public const STATUS_READ:String = "statusRead";
		
		static public const STICKING_NOT_DEFINED:int = 0;
		static public const STICKING_YES:int = 1;
		static public const STICKING_NO:int = 2;
		static public const BOUND_BIG_MESSAGE:String = "_#@%";
		static public const BOUND_COLOR:String = "#";
		
		static private var _mainPattern:RegExp = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig;
		static private var _secondaryPattern:RegExp = /\'www/g;
		static private var _mailPattern:RegExp = /([a-z0-9._-]+)@([a-z0-9.-]+)\.([a-z]{2,4})/g;
		
		private var _rawObject:Object;
		private var _status:String = '';
		private var _id:Number;
		private var _avatar:String;
		private var _name:String;
		private var _userUID:String;
		private var _delivery:String;
		private var _created:Number;
		private var _text:String;
		private var _originalText:String;
		private var _crypted:Boolean = true;
		private var _paranoic:Boolean;
		private var _type:String = "";
		private var _num:int = -1;
		private var _systemMessageVO:ChatSystemMsgVO;
		private var _linksArray:Array;
		private var _chatUID:String;
		private var _usePlainText:Boolean;
		private var _precenceDate:Date;
		private var _date:Date;
		
		public var isEntryMessage:Boolean = false;
		public var action:IScreenAction;
		
		public var wasSmile:int = 0;
		
		public var phonebookName:String = null;
		public var fxId:uint = 0;
		
		public var systemMessage:ChatSystemMessageData;
		public var stiking:int;
		
		private var chatImageKey:String = "";
		
		private var failedPin:Boolean;
		public var reactions:Vector.<ChatMessageReaction>;
		
		private var _userVO:UserVO;
		
		public var isMenuPressed:Boolean = false;
		public var selectedMenuIndex:int = -1;
		public var renderInfo:ListRenderInfo;
		public var checkForImmediatelyMessage:Boolean;
		
		public function ChatMessageVO(data:Object = null) {
			if (data != null)
				setData(data);
		}
		
		public function getClone():ChatMessageVO {
			var res:ChatMessageVO = new ChatMessageVO();
			res.setData(_rawObject);
			return res;
		}
		
		public function setData(obj:Object):void {
			_rawObject = obj;
			_id = obj['id'];
			_num = obj['num'];
			_avatar = obj['user_avatar'];
			_name = obj['user_name'];
			_userUID = obj['user_uid'];
			_delivery = obj['delivery'];
			
			_created = obj['created'];
			_text = "";
			var originalText:String = "";
			if ("text" in obj && obj.text != null)
				originalText = obj.text;
			if (originalText != null && originalText!= "") {
				if (_id < 0 && originalText.charAt(0) == "|") {
					originalText = originalText.substr(1);
				}
			}
			_originalText = removeCustomMessageBound(originalText);
			_status = obj['status'];
			_chatUID = obj['chat_uid'];
			if ("fxId" in obj)
				fxId = uint(obj["fxId"]);
			if ("isEntryMessage" in obj)
				isEntryMessage = obj["isEntryMessage"];
			if (_avatar != null && _avatar !="")
				_avatar = _avatar.replace("http://www.dukascopy.com", "https://www.dukascopy.com");
			_usePlainText = false;
			if ("usePlainText" in obj)
				_usePlainText = true;
			_crypted = true;
			wasSmile = 0;
			
			_date = null;
			_precenceDate = null;
			
			if (_systemMessageVO != null)
				_systemMessageVO.dispose();
			_systemMessageVO = null;
			
			if ("reaction" in obj && obj.reaction != null) {
				try {
					var reactionObject:Object = JSON.parse(obj.reaction);
					if (reactionObject != null)	{
						reactions = new Vector.<ChatMessageReaction>();
						var l:int = reactionObject.like;
						var reaction:ChatMessageReaction;
						for (var i:int = 0; i < l; i++) {
							reaction = new ChatMessageReaction();
							reaction.id = _id;
							reaction.chatUID = _chatUID;
							reaction.reaction = ChatMessageReactionType.LIKE;
							reactions.push(reaction);
						}
						if ("mine" in reactionObject && reactionObject.mine != null && reactions.length > 0) {
							reactions[0].userUID = Auth.uid;
						}
					}
				} catch (e:Error) {
					
				}
			}
			if (_userVO == null && _userUID != null && _userUID.length != 0) {
				_userVO = UsersManager.getUserByMessageObject(this);
				_userVO.incUseCounter();
			}
		}
		
		private function removeCustomMessageBound(message:String):String {
			if (message.indexOf(Config.BOUNDS_INVOICE) != -1)
				return message.substr(Config.BOUNDS_INVOICE.length);
			if (message.indexOf(Config.BOUNDS_ESCROW) != -1)
				return message.substr(Config.BOUNDS_ESCROW.length);
			return message;
		}
		
		public function dispose():void {
			_id = NaN;
			_avatar = null;
			_name = null;
			_userUID = null;
			_delivery = null;
			_created = NaN;
			renderInfo = null;
			_text = null;
			_linksArray = null;
			_precenceDate = null;
			_date = null;
			_rawObject = null;
			_status = null;
			_crypted = false;
			_paranoic = false;
			_type = null;
			_num = 0;
			_chatUID = null;
			_usePlainText = false;
			
			isEntryMessage = false;
			wasSmile = 0;
			phonebookName = null;
			fxId = 0;
			stiking = 0;
			chatImageKey = null;
			reactions = null;
			
			if (_userVO != null)
				UsersManager.removeUser(_userVO);
			_userVO = null;
			
			if (action != null)
				action.dispose();
			action = null;
			if (systemMessage != null)
				systemMessage.dispose();
			systemMessage = null;
			if (_systemMessageVO != null)
				_systemMessageVO.dispose();
			_systemMessageVO = null;
		}
		
		public function decrypt(chatSecrutiyKey:String, pin:String = null, isLocalIncomeChat:Boolean = false):void {
			if (isLocalIncomeChat == true || (chatSecrutiyKey != null && chatSecrutiyKey.indexOf(LocalChatsSynchronizer.LOCAL_INCOME_CHAT_FLAG) == 0)) {
				_text = Lang.cryptedMessage;
				_crypted = false;
				return;
			}
			if (_crypted == false)
				return;
			if (_originalText == null) {
				_text = "";
				return;
			}
			if (_usePlainText == true) {
				_text = _originalText;
			} else {
				_paranoic = _originalText.substr(0, 1) == "!";
				if (_paranoic == true) {
					if (pin == null || pin.length == 0 || pin == '----') {
						return;
					} else if (failedPin == true) {
						return;
					} else {
						wasSmile = 0;
						_text = Crypter.decrypt(_originalText.substr(1), chatSecrutiyKey);
						var unpin:String = Crypter.decryptAES(_text, pin);
						if (unpin == null || unpin == "") {
							failedPin = true;
							return;
						}
						_text = unpin;
					}
				} else
					_text = Crypter.decrypt(_originalText, chatSecrutiyKey);
			}
			if (_text.indexOf(Config.BOUNDS) == 0) {
				var _message:String = _text.substr(Config.BOUNDS.length);
				var _additionalData:Object = null;
				try {
					_additionalData = JSON.parse(_message);
				} catch (err:Error) {
					echo("ChatMessageVO", "decrypt", "JSON ERROR (SystemMessage)", true);
				}
				if (_additionalData != null) {
					_systemMessageVO = new ChatSystemMsgVO(_additionalData, chatUID, id);
				}
			}
			if (_systemMessageVO == null || _systemMessageVO.newsVO == null) {
				var txt:String = _text;
				txt = detectLink(txt);
				txt = detectMail(txt);
				grabAllLinks(txt);
				if (isEntryMessage)
					_text = txt;
				txt = null;
				_crypted = false;
				if (_text != null && _text.indexOf(BOUND_BIG_MESSAGE) == 0) {
					_text = _text.substr(BOUND_BIG_MESSAGE.length);
					renderInfo = new ListRenderInfo();
					renderInfo.renderInforenderBigFont = true;
					if (_text != null && _text.indexOf(BOUND_COLOR) == 0 && _text.length > 7) {
						var textColorString:String = _text.substr(1, 6);
						if (!isNaN(Number("0x" + textColorString)))
						{
							_text = _text.substr(7);
							renderInfo.color = Number("0x" + textColorString);
						}
					}
				}
			}
			
			if (_text != null && _text.indexOf(ChatSystemMsgVO.REPLAY_START_BOUND) == 0 && _text.indexOf(ChatSystemMsgVO.REPLAY_END_BOUND) != -1)
			{
				var replayVO:ReplayMessageVO = new ReplayMessageVO(_text);
				_systemMessageVO = new ChatSystemMsgVO(null, chatUID, id);
				_systemMessageVO.replayMessage = replayVO;
				_systemMessageVO.type = ChatSystemMsgVO.TYPE_REPLY;
				_text = replayVO.text;
			}
			
			var result:String = text;
			if (_systemMessageVO != null && _systemMessageVO.escrow != null)
			{
				result = _systemMessageVO.escrow.toJsonString();
			}
		}
		
		private function detectLink(str:String):String {
			var links:Array = str.match(/<a(.*?)>(.*?)<\/a>/g);
			var res:String = str.replace(/<a(.*?)>(.*?)<\/a>/g, "|@lnk|");
			var splited:Array = res.split("|@lnk|");
			res = "";
			for (var i:int = 0; i < splited.length; i++) {
				splited[i] = splited[i].replace(_mainPattern, "<u><a target='_blank' href='$&'>$&</a></u>");
				splited[i] = splited[i].replace(_secondaryPattern, "'https://www");
				res += splited[i];
				if (i + 1 != splited.length)
					res += "<u>" + links[i] + "</u>";
			}
			return res;
		}
		
		private function detectMail(str:String):String {
			str = str.replace(_mailPattern, "<a href='mailto:$&'><u>$&</u></a>");
			return str;
		}
		
		private function grabAllLinks(srcText:String):void {
			if (_linksArray != null) {
				_linksArray = null;
			}
			var links:Array = srcText.match(/<a(.*?)>(.*?)<\/a>/g);
			if (links == null || links.length == 0)
				return;
			_linksArray = [];
			var linkFull:String;
			var linkShort:String;
			for (var i:int = 0; i < links.length; i++) {

				linkFull = links[i];
				if(linkFull==null)
					continue;
				
				var m:Array=linkFull.match(/href=(.*?)[>,\s]/);
				
				if(m==null || m.length==0 || m[0]==null)
					continue;

				linkShort = m[0];
				linkShort = linkShort.substring(6, linkShort.length - 2);
				_linksArray.push( {
					fullLink:linkFull,
					shortLink:linkShort
				} );
			}
		}
		
		public function updateText(val:String):void {
			_text = "";
			wasSmile = 0;
			
			if (val != null && val!= "")
			{
				if (val.charAt(0) == "|")
				{
					val = val.substr(1);
				}
			}
			
			_originalText = removeCustomMessageBound(val);
			_crypted = true;
			_systemMessageVO = null;
			stiking = 0;
		}
		
		public function setStatus(val:String):void {
			_status = val;
			if (_status == "deleted")
				_linksArray = null;
		}
		
		public function setPin():void {
			if (_originalText == null)
				return;
			if (_originalText.charAt(0) != "!")
				return;
			_text = "";
			_crypted = true;
			failedPin = false;
		}
		
		public function setId(newID:Number):void 
		{
			_id = newID;
		}
		
		public function addReaction(reaction:ChatMessageReaction):void {
			if (reactions == null)
				reactions = new Vector.<ChatMessageReaction>();
			if (reaction != null)
				reactions.push(reaction);
		}
		
		public function removeReaction(reaction:ChatMessageReaction):void {
			if (reactions != null && reaction != null) {
				var l:int = reactions.length;
				if (reaction.userUID == Auth.uid) {
					for (var i:int = 0; i < l; i++) 
					{
						if (reactions[i].userUID == Auth.uid)
						{
							reactions.splice(i, 1);
							return;
						}
					}
				}
				else {
					//!TOODO: remove correct reaction based on new valid server data for message reactions, not possible now;
					
					for (var i2:int = 0; i2 < l; i2++) 
					{
						if (reactions[i2].userUID != Auth.uid)
						{
							reactions.splice(i2, 1);
							return;
						}
					}
				}
			}
		}
		
		public function setDelivery(val:String):void {
			_delivery = val;
		}
		
		public function get rawObject():Object { return _rawObject; }
		public function get num():int { return _num; }
		public function get systemMessageVO():ChatSystemMsgVO { return _systemMessageVO; }
		public function get userUID():String { return _userUID; }
		
		public function set userUID(value:String):void 
		{
			_userUID = value;
			_userUID = value;
		}
		public function get delivery():String { return _delivery; }
		public function get text():String {
			if (_systemMessageVO != null)
			{
				if (_systemMessageVO.type == ChatSystemMsgVO.TYPE_REPLY)
				{
					return _text;
				}
			}
			return (_systemMessageVO != null) ? _systemMessageVO.text : _text; 
		}
		public function get textSmall():String { return (_systemMessageVO != null) ? _systemMessageVO.textSmall : _text; }
		public function get unparsedText():String { return _text; }
		public function get typeEnum():String {return (_systemMessageVO != null) ? _systemMessageVO.type : ChatSystemMsgVO.TYPE_TEXT; }
		public function get paranoic():Boolean { return _paranoic; }
		public function get status():String { return _status; }
		public function get type():String { return _type; }
		public function get linksArray():Array { return _crypted ? null : _linksArray; }
		public function get chatUID():String { return _chatUID; }
		public function get originalText():String { return _originalText; }
		public function get created():Number { return _created; }
		public function get crypted():Boolean { return _crypted; }
		public function get id():Number { return _id; }
		public function get name():String { return _name; }
		
		public function get avatar():String {
			if (_avatar == null)
				return null;
			if (_avatar.indexOf("no_photo") != -1)
				return null;
			else if (_avatar.indexOf("vk.me") != -1)
				return _avatar;
			var avatarSize:int = int(Config.FINGER_SIZE * .35)*2;
			var userCode:Array = _avatar.split("/");
			if (_avatar.indexOf("graph.facebook.com") != -1) {
				if (userCode.length > 4)
					return "https://graph.facebook.com/" + userCode[3] + "/picture?width=" + avatarSize + "&height=" + avatarSize;
			} else {
				if (_avatar.indexOf("?method=files.get") != -1)
					return _avatar;
				else if (userCode.length > 4)
					return Config.URL_IMAGE + userCode[5] + "/" + avatarSize + "_3/image.jpg";
			}
			return _avatar;
		}
		
		public function get avatarForChat():String {
			
			if (typeEnum == ChatSystemMsgVO.TYPE_CHAT_SYSTEM && 
				systemMessageVO != null && 
				systemMessageVO.method == ChatSystemMsgVO.METHOD_TIPS_PAID && 
				systemMessageVO.giftVO != null &&
				systemMessageVO.giftVO.user != null)
			{
				return systemMessageVO.giftVO.user.getAvatarURL();
			}
			
			if (typeEnum == ChatSystemMsgVO.TYPE_CHAT_SYSTEM && 
				systemMessageVO != null && 
				systemMessageVO.method == ChatSystemMsgVO.METHOD_CALL && 
				systemMessageVO.callVO != null)
			{
				return systemMessageVO.callVO.avatarForChat;
			}
			
			if (userUID == Config.DUKASCOPY_INFO_SERVICE_UID)
				return LocalAvatars.BANK;
			
			if (userUID == Auth.uid)
				return null;
			
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().users != null) {
				var user:ChatUserVO = ChatManager.getCurrentChat().getUser(userUID);
				if (user != null && user.secretMode == true)
					return LocalAvatars.SECRET;
			}
			var baseAvatar:String = avatar;
			if (avatar == null || avatar == "") {
				if (userVO != null){
					return userVO.getAvatarURL();
				}
			}
			return avatar;
		}
		
		public function set avatar(value:String):void {
			_avatar = value;
		}
		
		public function get imageURLWithKey():String {
			if (systemMessageVO == null || systemMessageVO.imageURL == null)
				return null;
			return systemMessageVO.imageURL + ImageCrypterOld.imageKeyFlag + getChatImageKey();
		}
		
		public function get imageThumbURLWithKey():String {
			if (systemMessageVO == null)
				return null;
			// image from bot message;
			if (systemMessageVO.method == ChatSystemMsgVO.METHOD_NEWS && systemMessageVO.newsVO != null && systemMessageVO.newsVO.image != null){
				return systemMessageVO.newsVO.image;
			}else if (systemMessageVO.method == ChatSystemMsgVO.METHOD_BOT_MENU && systemMessageVO.botMenu != null && systemMessageVO.botMenu.image != null){
				return systemMessageVO.botMenu.image;
			}
			else if ( systemMessageVO.imageThumbURL == null){
				return null;
			}
			return systemMessageVO.imageThumbURL + ImageCrypterOld.imageKeyFlag + getChatImageKey();
		}
		
		private function getChatImageKey():String {
			if (chatImageKey != "")
				return chatImageKey;
			var chatModel:ChatVO = ChatManager.getCurrentChat();
			if (chatModel == null || chatModel.uid != _chatUID)
				chatModel = ChatManager.getChatByUID(_chatUID);
			if (chatModel != null)
				chatImageKey = chatModel.getImageString();
			return chatImageKey;
		}
		
		public function get date():Date {
			if (_date == null) {
				_date = new Date;
				_date.setTime(_created * 1000);
				_date.setHours(0, 0, 0, 0);
			}
			return _date;
		}
		
		public function get datePrecence():Date {
			if (_precenceDate == null) {
				_precenceDate = new Date;
				_precenceDate.setTime(_created * 1000);
			}
			return _precenceDate;
		}
		
		public function get userVO():UserVO {
			return _userVO;
		}
		
		public function set userVO(value:UserVO):void 
		{
			_userVO = value;
		}
		
		public function get numMenuItems():int{
			if (systemMessageVO == null) return 0;
			if (systemMessageVO.botMenu == null) return 0;
			if (systemMessageVO.botMenu.items == null || systemMessageVO.botMenu.items == "") return 0;			
			return  systemMessageVO.botMenu.items.length;
		}
		
		public function set usePlainText(value:Boolean):void 
		{
			_usePlainText = value;
			_usePlainText = value;
		}
		
		public function getOverlay():OverlayData
		{
			if (userVO != null && userVO.uid != Auth.uid)
			{
				var overlay:OverlayData;
				if (userVO.missDC == true)
				{
					overlay ||= new OverlayData();
					overlay.crown = true;
				}
				if (UsersManager.checkForToad(userVO.uid) == true)
				{
					overlay ||= new OverlayData();
					overlay.toad = true;
				}
				if (userVO.ban911VO != null && userVO.ban911VO.status != "buyout")
				{
					overlay ||= new OverlayData();
					overlay.jail = true;
				}
				
				/*if (user.userVO.payRating != 0) {
					ratingIcon.visible = true;
					ratingIcon.gotoAndStop(user.userVO.payRating);
				}*/
				
				
				if (userVO.gifts != null && !userVO.gifts.empty())
				{
					overlay ||= new OverlayData();
					
					var itemType:String = userVO.gifts.items[userVO.gifts.items.length - 1].type.value;
					if (itemType == ExtensionType.FLOWER_1)
					{
						overlay.flower_1 = true;
					}
					else if (itemType == ExtensionType.FLOWER_2)
					{
						overlay.flower_2 = true;
					}
					else if (itemType == ExtensionType.FLOWER_3)
					{
						overlay.flower_3 = true;
					}
					else if (itemType == ExtensionType.FLOWER_4)
					{
						overlay.flower_4 = true;
					}
				}
				
				return overlay;
			}
			return null;
		}

		public  function toString():String{
			return "id: "+_id+", "
			+"\nuserType:"+(_userVO)?_userVO.type:"unknown, "
			+"\nisSystemMsg: "+(_systemMessageVO!=null)+", "
			+"\ncheckForImmediatelyMessage: "+checkForImmediatelyMessage+", "
			+"\nuserUID"+userUID
		}
	}
}