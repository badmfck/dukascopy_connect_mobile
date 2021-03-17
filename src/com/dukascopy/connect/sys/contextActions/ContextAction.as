package com.dukascopy.connect.sys.contextActions 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ContextAction 
	{
		public var icon:Class;
		public var backColor:Number;
		public var type:String;
		public var text:String;
		
		public function ContextAction(type:String, text:String, backColor:Number, icon:Class) 
		{
			this.type = type;
			this.text = text;
			this.icon = icon;
			this.backColor = backColor;
		}
	}
}