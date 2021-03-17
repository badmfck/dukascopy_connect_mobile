package com.dukascopy.connect.screens.chat.selectAdressee {
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class SelectAdresseeResultVO {
		
		private var _selectedUserIDs:Vector.<String>;
		private var _selectedChatIDs:Vector.<String>;
		
		public function SelectAdresseeResultVO(userIDs:Vector.<String> = null,chatIDs:Vector.<String> = null) {
			_selectedChatIDs = chatIDs;
			_selectedUserIDs = userIDs;
		}
		
		public function get isAnyAdresseeSelected():Boolean {
			return selectedChatIDs.length != 0 || selectedUserIDs.length != 0;
		}
		
		public function get selectedUserIDs():Vector.<String> { return _selectedUserIDs; }
		public function get selectedChatIDs():Vector.<String> { return _selectedChatIDs; }
		
		public function dispose():void {
			_selectedChatIDs = null;
			_selectedUserIDs = null;
		}
	}
}