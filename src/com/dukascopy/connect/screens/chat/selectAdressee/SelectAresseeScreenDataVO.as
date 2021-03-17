package com.dukascopy.connect.screens.chat.selectAdressee {
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 * VO for opening selectAdressee screen
	 */
	
	public class SelectAresseeScreenDataVO {
		
		public static const SELECT_ADRESSEE_TYPE_BOTH:String = "SELECT_ADRESSEE_TYPE_BOTH";
		public static const SELECT_ADRESSEE_TYPE_CONTACTS:String = "SELECT_ADRESSEE_TYPE_CONTACTS";
		public static const SELECT_ADRESSEE_TYPE_CHATS:String = "SELECT_ADRESSEE_TYPE_CHATS";
		
		private var _selectAdresseeType:String;
		private var _ignoringUserIDs:Vector.<String>;
		private var _ignoringChatIDs:Vector.<String>;
		private var _title:String;
		private var _callback:Function;
		private var _isSelectSingleAdressee:Boolean;
		private var _backScreen:Class;
		private var _backScreenData:Object;
		
		public function SelectAresseeScreenDataVO(callback:Function, backScreenClass:Class, backScreenDataObject:Object = null, isSingleAdressee:Boolean = true, title:String = null, selectionType:String = SELECT_ADRESSEE_TYPE_BOTH, ignoringUserIDS:Vector.<String> = null, ignoringChatIDS:Vector.<String> = null) {
			if (selectionType == null || 
				selectionType != SELECT_ADRESSEE_TYPE_BOTH && 
				selectionType != SELECT_ADRESSEE_TYPE_CHATS && 
				selectionType != SELECT_ADRESSEE_TYPE_CONTACTS)
					selectionType = SELECT_ADRESSEE_TYPE_BOTH;
			_backScreen = backScreenClass;
			_backScreenData = backScreenDataObject;
			_callback = callback;
			_isSelectSingleAdressee = isSingleAdressee;
			_selectAdresseeType = selectionType;
			_title = title;
			_ignoringChatIDs = ignoringChatIDS;
			_ignoringUserIDs = ignoringUserIDs;
		}
		
		public function executeCallback(screenActivityResult:SelectAdresseeResultVO):void {
			if (_callback != null)
				_callback(screenActivityResult);
		}
		
		public function get backScreenData():Object { return _backScreenData; }
		public function set backScreenData(value:Object):void {
			_backScreenData = value;
		}
		
		public function get selectAdresseeType():String { return _selectAdresseeType; }
		public function get ignoringUserIDs():Vector.<String> { return _ignoringUserIDs; }
		public function get ignoringChatIDs():Vector.<String> { return _ignoringChatIDs; }
		public function get title():String { return _title; }
		public function get isSelectSingleAdressee():Boolean { return _isSelectSingleAdressee; }
		public function get backScreen():Class { return _backScreen; }
		
		public function dispose():void {
			_selectAdresseeType = null;
			_ignoringUserIDs = null;
			_ignoringChatIDs = null;
			_title = null;
			_callback = null;
			_backScreen = null;
			_backScreenData = null;
		}
	}
}