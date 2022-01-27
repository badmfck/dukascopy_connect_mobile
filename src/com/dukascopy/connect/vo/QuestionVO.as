package com.dukascopy.connect.vo {
	
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * @author Ilya Shcherbakov
	 */
	
	public class QuestionVO {
		
		public var wasSmile:int = 0;
		public var busy:Boolean = false;
		
		public var paidStampSettings:Object;
		
		public var isRemoving:Boolean = false;
		
		private var _isDisposed:Boolean = false;
		
		private var _uid:String;
		private var _text:String;
		private var _createdTime:uint;
		private var _anonymous:Object;
		private var _answersCount:int = 0;
		private var _answersMaxCount:int = 5;
		private var _status:String;
		private var _messages:Array;
		private var _bind:Boolean;
		private var _tipsAmount:Number;
		private var _tipsCurrency:String;
		private var _categories:Array;
		private var _incognito:Boolean = false;
		private var _userVO:UserVO;
		private var _newbie:Boolean;
		private var _type:String;
		private var _subtype:String;
		private var _freshTime:Number = 0;
		
		private var _unread:Array;
		private var _isPaid:Boolean;
		private var _anonymData:Object;
		private var _isHeader:Boolean;
		
		private var _geo:Boolean = false;
		private var _geolocation:Location;
		private var _instrument:EscrowInstrument;
		private var _cryptoAmount:String;
		private var _priceCurrency:String;
		private var _price:String;
		private var _tipsCurrencyDisplay:String;
		
		public var needPayBeforeClose:Boolean;
		
		public var rulesShown:Boolean;
		
		public function QuestionVO(data:Object) {
			if (data == null)
				return;
			update(data);
		}
		
		public function update(data:Object):void {
			_uid = data.uid;
			
			_userVO = UsersManager.getUserByQuestionObject(data);
			if (_userVO != null){
				_userVO.incUseCounter();
				UsersManager.registrateUserUID(_userVO.uid);
			}
			
			_createdTime = data.ctime;
			_anonymous = data.anonymous;
			if (_anonymous == 1 && "anonymData" in data == true)
				_anonymData = data.anonymData;
			_newbie = false;
			/*if ("newbie" in data == true)
				_newbie = data.newbie;*/
			_bind = data.bind;
			if ("freshTime" in data == true)
				_freshTime = data.freshTime;
			if (isNaN(_freshTime) == true)
				_freshTime = 0;
			if ("geo" in data == true) {
				_geo = true;
				_geolocation = new Location (data.geo.latt, data.geo.long);
			}
			if ("answers" in data) {
				_answersCount = data.answers[0];
				_answersMaxCount = data.answers[1];
			}
			_isPaid = data.paid;
			if ("tips" in data == true && data.tips != null && "amount" in data.tips == true && data.tips.amount != "" && data.tips.amount != 0) {
				_tipsAmount = data.tips.amount;
				_tipsCurrency = data.tips.currency;
				if (Lang[_tipsCurrency])
				{
					_tipsCurrencyDisplay = Lang[_tipsCurrency];
				}
				else
				{
					_tipsCurrencyDisplay = _tipsCurrency;
				}
				/*if (_tipsCurrency == "DCO")
					_tipsCurrency = "DUK+";*/
				_cryptoAmount = _tipsAmount.toString();
				GD.S_ESCROW_INSTRUMENTS.add(onResult); 
				GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
			} else {
				_tipsAmount = NaN;
				_tipsCurrency = null;
				_tipsCurrencyDisplay = null;
			}
			if (isNaN(_tipsAmount) == true)
				_isPaid = true;
			_status = data.status;
			_type = data.type;
			_subtype = data.subtype;
			_unread = data.unread;
			if ("price" in data == true)
				_price = data.price;
			if (data.categories != null) {
				_categories = new Array();
				for (var key:Object in data.categories) 
				{
					_categories.push(data.categories[key]);
				}
				
				
			//	_categories = data.categories;
				if (_categories != null && _categories.length != 0)
					_priceCurrency = _categories[0];
			}
			
			_incognito = data.anonymous == 1;
			
			if ("text" in data && data.text != null) {
				var temp:Array = data.text.split(QuestionsManager.MESSAGE_BOUNDS);
				_messages = [];
				if (temp.length > 0)
					_messages.push( { createdTime:_createdTime, text:Crypter.decrypt(temp[0], QuestionsManager.MESSAGE_KEY) } );
				for (var i:int = 1; i < temp.length; i++)
					_messages.push( { createdTime:Number(temp[i].substr(0, 10)), text:Crypter.decrypt(temp[i].substring(11), QuestionsManager.MESSAGE_KEY) } );
			}
			
			if ("paidBySuspend" in data && data.paidBySuspend == false)
				needPayBeforeClose = true;
			
			busy = false;
		}
		
		private function onResult(instruments:Vector.<EscrowInstrument>):void {
			GD.S_ESCROW_INSTRUMENTS.remove(onResult);
			//!TODO: instruments == null
			if (instruments != null)
			{
				for (var i:int = 0; i < instruments.length; i++) {
					if (instruments[i].code == _tipsCurrency) {
						_instrument = instruments[i];
						return;
					}
				}
			}
			
			
		}
		
		public function get avatarURL():String {
			if (_userVO != null)
				return _userVO.getAvatarURL();
			return "";
		}
		
		public function get userUID():String {
			if (_userVO != null)
				return _userVO.uid;
			return "";
		}
		
		public function isMine():Boolean {
			if (_userVO != null)
				return Auth.uid == _userVO.uid;
			return false;
		}
		
		public function get title():String {
			if (_userVO != null)
				return _userVO.getDisplayName();
			return "";
		}
		
		public function get text():String {
			if (_messages == null)
				return "";
			return _messages[0].text;
		}
		
		public function get unread():int { return (_unread == null) ? 0 : _unread.length; }
		public function get user():UserVO { return _userVO; }
		public function get newbie():Boolean { return _newbie }
		public function get uid():String { return _uid; }
		public function get answersCount():int { return _answersCount; }
		public function get answersMaxCount():int { return _answersMaxCount; }
		public function get status():String { return _status; }
		public function get createdTime():uint { return _createdTime; }
		public function get messages():Array { return _messages; }
		public function get isDisposed():Boolean { return _isDisposed; }
		public function get bind():Boolean { return _bind; }
		public function get tipsAmount():Number { return _tipsAmount; }
		public function get tipsCurrency():String { return _tipsCurrency; }
		public function get tipsCurrencyDisplay():String { return _tipsCurrencyDisplay; }
		public function get categories():Array { return _categories; }
		public function get incognito():Boolean { return _incognito; }
		public function get isPaid():Boolean { return _isPaid; }
		public function get anonymData():Object { return _anonymData; }
		public function get type():String { return _type; }
		public function get subtype():String { return _subtype; }
		public function get freshTime():Number { return _freshTime; }
		public function get geo():Boolean { return _geo; }
		public function get geolocation():Location { return _geolocation; }
		public function get isHeader():Boolean { return _isHeader; }
		public function get instrument():EscrowInstrument { return _instrument; }
		public function get cryptoAmount():String { return _cryptoAmount; }
		public function get priceCurrency():String { return _priceCurrency; }
		public function get price():String { return _price; }
		
		public function set type(value:String):void {
			_type = value;
		}
		
		public function set subtype(value:String):void {
			_subtype = value;
		}
		
		public function set instrument(value:EscrowInstrument):void {
			_instrument = value;
		}
		
		public function set priceCurrency(value:String):void {
			_priceCurrency = value;
		}
		
		public function set price(value:String):void {
			_price = value;
		}
		
		public function set cryptoAmount(val:String):void {
			_cryptoAmount = val;
		}
		
		public function dispose():void {
			_isDisposed = true;
			
			_uid = "";
			paidStampSettings = null;
			
			UsersManager.removeUser(_userVO);
		}
		
		public function setStatus(string:String):void {
			_status = string;
		}
		
		public function removeFromUnread(uid:String):void {
			if (_unread == null)
				return;
			for (var i:int = 0; i < _unread.length; i++) {
				if (_unread[i] == uid) {
					_unread.splice(i, 1);
					return;
				}
			}
		}
		
		public function setUpdatedAnswersCount(val:int):void {
			_answersCount = val;
			if (_answersCount > _answersMaxCount)
				_answersCount = _answersMaxCount
			else if (_answersCount < 0)
				_answersCount = 0;
		}
		
		public function updateUnread(chatUID:String, action:Boolean):void {
			var i:int;
			// ADD UID TO UNREAD ARRAY
			if (action == true) {
				if (_unread == null)
					_unread = [];
				for (i = 0; i < _unread.length; i++) {
					if (_unread[i] == chatUID)
						return;
				}
				_unread.push(chatUID);
				return;
			}
			// REMOVE UID FROM UNREAD ARRAY
			if (_unread == null)
				return;
			for (i = 0; i < _unread.length; i++) {
				if (_unread[i] == chatUID) {
					_unread.splice(i, 1);
					break;
				}
			}
		}
		
		public function setHasMyAnswer():void {
			_bind = true;
		}
		
		public function setIsPaid():void {
			_isPaid = true;
		}
		
		public function setHeader():void {
			_isHeader = true;
		}
	}
}