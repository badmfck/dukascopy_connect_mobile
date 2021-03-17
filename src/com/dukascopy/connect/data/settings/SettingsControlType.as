package com.dukascopy.connect.data.settings 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SettingsControlType 
	{
		private var typeValue:String;
		
		static private const CREATE_CHAT:String = "private";
		static private const ADD_CHAT:String = "chat";
		static private const CALL:String = "call";
		static private const FIND:String = "find";
		
		static public var typeCreateChat:SettingsControlType = new SettingsControlType(CREATE_CHAT);
		static public var typeAddChat:SettingsControlType = new SettingsControlType(ADD_CHAT);
		static public var typeCall:SettingsControlType = new SettingsControlType(CALL);
		static public var typeFind:SettingsControlType = new SettingsControlType(FIND);
		
		public function SettingsControlType(type:String) 
		{
			if (type != CREATE_CHAT &&
				type != ADD_CHAT &&
				type != CALL &&
				type != FIND)
			{
			//	ApplicationErrors.add();
			}
			this.typeValue = type;
		}
		
		static public function getType(typeValue:String):SettingsControlType 
		{
			var type:SettingsControlType;
			switch(typeValue)
			{
				case CREATE_CHAT:
				{
					return typeCreateChat;
					break;
				}
				case ADD_CHAT:
				{
					return typeAddChat;
					break;
				}
				case CALL:
				{
					return typeCall;
					break;
				}
				case FIND:
				{
					return typeFind;
					break;
				}
			}
			if (type == null)
			{
				ApplicationErrors.add();
			//	type = new SettingsControlType(typeValue);
			}
			
			return type;
		}
		
		static public function getlabel(type:SettingsControlType):String 
		{
			var result:String;
			if (type == null)
			{
				ApplicationErrors.add();
				result = "Settings";
			}
			switch(type.typeValue)
			{
				case typeCreateChat.typeValue:
				{
					result = Lang.privacy_whoCanCreateChats;
					break;
				}
				case typeAddChat.typeValue:
				{
					result = Lang.privacy_whoCanAddToChats;
					break;
				}
				case typeCall.typeValue:
				{
					result = Lang.privacy_whoCanCallMe;
					break;
				}
				case typeFind.typeValue:
				{
					result = Lang.privacy_whoCanFindMe;
					break;
				}
			}
			
			if (result == null)
			{
				ApplicationErrors.add();
				result = type.getValue();
			}
			
			return result;
		}
		
		static public function getDefaultSelection(type:SettingsControlType):SettingsValueType 
		{
			var result:SettingsValueType;
			switch(type.getValue())
			{
				case typeCreateChat.typeValue:
				{
					result = SettingsValueType.typeVerified;
					break;
				}
				case typeAddChat.typeValue:
				{
					result = SettingsValueType.typeVerified;
					break;
				}
				case typeCall.typeValue:
				{
					result = SettingsValueType.typeVerified;
					break;
				}
				case typeFind.typeValue:
				{
					result = SettingsValueType.typeNoOne;
					break;
				}
			}
			if (result == null)
			{
				ApplicationErrors.add();
				result = SettingsValueType.typeAll;
			}
			
			return result;
		}
		
		public function getValue():String 
		{
			return typeValue;
		}
	}
}