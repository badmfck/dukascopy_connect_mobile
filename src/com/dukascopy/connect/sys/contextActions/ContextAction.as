package com.dukascopy.connect.sys.contextActions 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ContextAction 
	{
		public var reactionType:String;
		public var icon:Class;
		public var backColor:Number;
		public var type:String;
		public var text:String;
		
		static public const TYPE_BUTTON:String = "button";
		static public const TYPE_SWIPE:String = "swipe";
		
		public function ContextAction(type:String, text:String, backColor:Number, icon:Class, reactionType:String = TYPE_BUTTON) 
		{
			this.type = type;
			this.text = text;
			this.icon = icon;
			this.backColor = backColor;
			this.reactionType = reactionType;
		}
	}
}