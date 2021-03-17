package com.dukascopy.connect.vo {
	
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class QuestionsStatVO {
		
		private var _hash:String;
		private var _questions:int=0;
		private var _answers:int=0;
		private var _accepted:int=0;
		private var _banned:int=0;
		private var _alarms:int=0;
		private var _rating:Number = 0;
		private var _selfPayer:Boolean;
		private var _complains:Object;
		private var _money:Object;
		private var _banReason:String; 
		private var _ready:Boolean = false; 
		private var _since:Number;
		
		public function QuestionsStatVO() { }
		
		public function setData(raw:Object):void {
			if (raw == null)
				return;
			_hash = raw.hash;
			if (raw.stat == null)
				return;
			_questions = raw.stat.questions;
			_answers = raw.stat.answers;
			_accepted = raw.stat.accepted;
			_banned = raw.stat.banned;
			_banReason = raw.stat.banReason;
			_rating = raw.stat.rating;
			_selfPayer = raw.stat.selfPayer;
			_complains = raw.stat.complaints;
			_money = raw.stat.money;
			_since = raw.stat.created;
			_alarms = raw.stat.alarms;
			_ready = true;
		}
		
		public function dispose():void {
			_hash = null;
			_questions = 0;
			_answers = 0;
			_accepted = 0;
			_banned = 0;
			_alarms = 0;
			_rating = NaN;
			_selfPayer = false;
			_complains = null;
			_money = null;
		}
		
		public function get isReady():Boolean { return _ready; }
		public function get hash():String { return _hash; }
		public function get questions():int { return _questions; }
		public function get answers():int { return _answers; }
		public function get accepted():int { return _accepted; }
		public function get banned():int { return _banned; }
		public function get alarms():int { return _alarms; }
		public function get banReason():String { return _banReason == "" ? Lang.noReason : _banReason; }
		public function get rating():Number { return _rating; }
		public function get selfPayer():Boolean { return _selfPayer; }
		public function get complains():Object { return _complains; }
		public function get abuse():int { return (_complains == null) ? 0 : _complains.abuse; }
		public function get block():int { return (_complains == null) ? 0 : _complains.block; }
		public function get spam():int { return (_complains == null) ? 0 : _complains.spam; }
		public function get stop():int { return (_complains == null) ? 0 : _complains.stop; }
		public function get complainsTotal():int { return (_complains == null) ? 0 : _complains.total; }
		public function get money():Object { return _money; }
		public function get expected():Number { return (_money == null) ? 0 : _money.expected; }
		public function get pending():Number { return (_money == null) ? 0 : _money.pending; }
		public function get received():Number { return (_money == null) ? 0 : _money.received; }
		public function get wasted():Number { return (_money == null) ? 0 : _money.wasted; }
		public function get since():Number { return _since; }
	}
}