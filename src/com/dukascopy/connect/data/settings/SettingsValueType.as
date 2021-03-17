package com.dukascopy.connect.data.settings 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SettingsValueType 
	{
		private var typeValue:String;
		
		static private const ALL:String = "all";
		static private const VERIFIED:String = "approved";
		static private const NO_ONE:String = "none";
		
		static public var typeAll:SettingsValueType = new SettingsValueType(ALL);
		static public var typeVerified:SettingsValueType = new SettingsValueType(VERIFIED);
		static public var typeNoOne:SettingsValueType = new SettingsValueType(NO_ONE);
		
		public function SettingsValueType(type:String) 
		{
			if (type != ALL &&
				type != VERIFIED &&
				type != NO_ONE)
			{
				ApplicationErrors.add();
			}
			this.typeValue = type;
		}
		
		public function getValue():String 
		{
			return typeValue;
		}
		
		static public function getType(typeValue:String):SettingsValueType 
		{
			var type:SettingsValueType;
			switch(typeValue)
			{
				case ALL:
				{
					return typeAll;
					break;
				}
				case VERIFIED:
				{
					return typeVerified;
					break;
				}
				case NO_ONE:
				{
					return typeNoOne;
					break;
				}
			}
			if (type == null)
			{
				ApplicationErrors.add();
				type = new SettingsValueType(typeValue);
			}
			
			return type;
		}
	}
}