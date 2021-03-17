package com.dukascopy.connect.data.settings 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SettingsValue 
	{
		public var type:SettingsValueType;
		public var label:String;
		
		public function SettingsValue(type:SettingsValueType, label:String) 
		{
			this.type = type;
			this.label = label;
		}
		
		public function dispose():void 
		{
			type = null;
			label = null;
		}
	}
}