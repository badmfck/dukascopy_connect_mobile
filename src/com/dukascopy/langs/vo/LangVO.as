package com.dukascopy.langs.vo {
	
	import com.dukascopy.langs.LangModel;
	
	public class LangVO extends Object {
		
		private var _id:String = LangModel.EN;
		private var _idHash:String = "";
		private var _time:Number;
		public var arrHashs:Array = [];
		
		public function LangVO() {
			
		}
		
		public function update(obj:Object):void {
			if (obj == null)
				return;
			_id = obj.id;
			_idHash = obj.idHash;
			_time = obj.time;
			arrHashs = obj.arrHashs;
		}
	}
}