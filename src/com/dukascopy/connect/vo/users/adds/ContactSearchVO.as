package com.dukascopy.connect.vo.users.adds 
{
	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	public class ContactSearchVO
	{
		public var contact:ContactVO;
		public var phoneBook:PhonebookUserVO;
		
		private var _searchText:String;
		private var _entry:Object;
		
		public function ContactSearchVO(filter:String, entry:Object) 
		{
			_searchText = filter;
			_entry = entry;
			
			/* Do not need it yet 
			if (entry is ContactVO) contact = entry as ContactVO;
			if (entry is PhonebookUserVO) phoneBook = entry as PhonebookUserVO;
			*/
		}
		
		public function dispose():void {
			if(entry != null)
			entry.dispose();
			contact = null;
			phoneBook = null;
		}
		
		public function get searchText():String{ return _searchText; }
		public function set searchText(value:String):void  { _searchText = value; }
		
		public function get entry():Object  { return _entry; }
		public function get avatarURL():Object  { return entry.avatarURL; }
		
		public function get phone():Object  { return _entry.phone; }
		
		
		
	}

}