package com.dukascopy.connect.screens.chat.selectAdressee {
	
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public interface IContactsChatsSelectionListItem {
		
		function get avatarURL():Object;
		function get title():String;
		function get titleFirstLetter():String;
		function get isBlocked():Boolean;
		function get isEmpty():Boolean;
		function get onlineStatus():OnlineStatus;
		function get statusText():String;
		function get status():int;
		function set status(value:int):void;
		function get isListSelectable():Boolean;
		
		function dispose():void;
	}
}