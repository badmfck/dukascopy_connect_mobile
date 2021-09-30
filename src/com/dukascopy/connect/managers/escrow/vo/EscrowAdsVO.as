package com.dukascopy.connect.managers.escrow.vo {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class EscrowAdsVO {
		
		static public const SIDE_BUY:String = "buy";
		static public const SIDE_SELL:String = "sell";
		
		static public const STATUS_CLOSED:String = "closed";
		static public const STATUS_CREATED:String = "created";
		static public const STATUS_PROCESSED:String = "processed";
		static public const STATUS_RESOLVED:String = "resolved";
		static public const STATUS_EDITED:String = "edited";
		
		private var _uid:String;
		private var _crypto:String;
		private var _amount:Number;
		private var _instrument:EscrowInstrument;
		private var _side:String;
		private var _userUid:String;
		private var _price:String;
		private var _currency:String;
		private var _created:Number;
		private var _answersCount:int;
		private var _answersMax:int;
		private var _mine:Boolean;
		private var _status:String;
		private var _isRemoving:Boolean;
		
		public function EscrowAdsVO(data:Object) {
			if ("uid" in data == true && data.uid != null && data.uid is String)
				_uid = data["uid"];
			if ("tips" in data == true && data.tips != null) {
				if ("currency" in data.tips == true && data.tips.currency != null && data.tips.currency is String)
					_crypto = data.tips.currency;
				if ("amount" in data.tips == true && data.tips.amount != null && isNaN(data.tips.amount) == false)
					_amount = data.tips.amount;
			}
			if ("ctime" in data && data.ctime != null && isNaN(data.ctime) == false)
				_created = data.ctime;
			if ("user" in data && data.user != null && "uid" in data.user && data.user.uid != null)
				_userUid = data.user.uid;
			if ("subtype" in data && data.subtype != null)
				_side = data.subtype;
			if ("price" in data && data.price != null)
				_price = data.price + "";
			if ("categories" in data && data.categories != null) {
				var categories:Array = [];
				for (var key:Object in data.categories)
					categories.push(data.categories[key]);
				if (categories.length != 0)
					_currency = categories[0];
			}
			if ("answers" in data && data.answers != null && data.answers.length == 2) {
				_answersCount = data.answers[0];
				_answersMax = data.answers[1];
			}
		}
		
		public function get instrument():EscrowInstrument { return _instrument; }
		public function set instrument(escrowInstrument:EscrowInstrument):void {
			_instrument = escrowInstrument;
		}
		
		public function get mine():Boolean { return _mine; }
		public function set mine(val:Boolean):void {
			_mine = val;
		}
		
		public function get isRemoving():Boolean { return _isRemoving; }
		public function set isRemoving(val:Boolean):void {
			_isRemoving = val;
		}
		
		public function get status():String { return _status; }
		public function set status(val:String):void {
			_status = val;
		}
		
		public function get currency():String { return _currency; }
		public function get side():String { return _side; }
		public function get uid():String { return _uid; }
		public function get crypto():String { return _crypto; }
		public function get amount():Number { return _amount; }
		public function get answersMax():int { return _answersMax; }
		public function get answersCount():int { return _answersCount; }
		public function get created():Number { return _created; }
		public function get userUid():String { return _userUid; }
		
		public function get isDisposed():Boolean { return _uid == null; }
		
		public function get price():Number {
			if (isNaN(Number(_price)) == false)
				return Number(_price);
			if (_instrument == null)
				return 0;
			var l:int = _instrument.price.length;
			for (var i:int = 0; i < l; i++) {
				if (_instrument.price[i].name == _currency)
					return _instrument.price[i].value * (1 + Number(_price.substr(0, _price.length - 1)));
			}
			return 0;
		}
		
		public function dispose():void {
			_uid = null;
			_crypto = null;
			_amount = 0;
			_instrument = null;
			_side = null;
			_userUid = null;
			_price = null;
			_currency = null;
			_created = 0;
			_answersCount = 0;
			_answersMax = 0;
		}
	}
}