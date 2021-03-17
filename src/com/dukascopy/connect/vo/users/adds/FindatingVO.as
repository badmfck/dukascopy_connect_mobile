package com.dukascopy.connect.vo.users.adds {
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	public class FindatingVO {
		
		private var _uid:String = "";
		private var _type:String = "";
		private var _avatarURL:String = "";
		private var _fxID:uint = 0;
		private var _fxName:String = "";
		private var _fdFN:String = "";
		private var _fdLN:String = "";
		private var _isExhibitor:String = "";
		private var _companyID:String;
		
		public function FindatingVO(data:Object) {
			_uid = data.uid;
			//_type = data.type;
			if ("fxdata" in data && data.fxdata != null) {
				if ("avatar" in data.fxdata && data.fxdata.avatar != null)
					_avatarURL = data.fxdata.avatar;
				if ("user_id" in data.fxdata && data.fxdata.user_id != null)
					_fxID = uint(data.fxdata.user_id);
			}
			if ("avatar" in data && data.avatar != null && data.avatar != "")
				_avatarURL = data.avatar;
				
			if(_avatarURL!=null)
				_avatarURL = _avatarURL.replace("http://www.dukascopy.com", "https://www.dukascopy.com");
			
			_fxName = data.username;
			_fdFN = data.name;
			_fdLN = data.surname;
			_isExhibitor = data.isExhibitor;
			_companyID = data.companyID;
		}
		
		public function dispose():void {
			_uid = "";
			_type = "";
			_avatarURL = "";
			_fxID = 0;
			_fxName = "";
			_fdFN = "";
			_fdLN = "";
		}
		
		public function get uid():String { return _uid; }
		public function get type():String { return _type; }
		public function get avatarURL():String { return _avatarURL; }
		public function get fxID():uint { return _fxID; }
		public function get fxName():String { return _fxName; }
		public function get fxcommFN():String { return _fdFN; }
		public function get fxcommLN():String { return _fdLN; }
		public function get name():String {
			var res:String = "";
			if (_fdFN != '')
				res = _fdFN;
			if (_fdLN != '') {
				if (res != '')
					res += " ";
				res += _fdLN;
			}
			if (res == "")
				return _fxName;
			return res;
		}
	}
}