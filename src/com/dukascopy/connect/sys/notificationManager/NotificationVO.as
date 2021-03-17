package com.dukascopy.connect.sys.notificationManager 
{
	/**
	 * ...
	 * @author Alexey
	 */
	public class NotificationVO 
	{
		static public const TYPE_DEFAULT:int = -1;
		static public const TYPE_NEW_MESSAGE:int = 1;
		static public const TYPE_BUISSINESS_MESSAGE:int = 2;
		static public const TYPE_FILE:int = 3;
		
		public var type:int = TYPE_DEFAULT;
		public var hasIcon:Boolean = false;
		public var message:String = "";
		public var callback:Function;
		public var callbackData:Object;
		
		public var NOTIFICATION_BG_COLOR:uint = 0xFFFFFF;
		public var NOTIFICATION_TEXT_COLOR:uint = 0x000000;
		public var iconType:int =1;
		

		public function NotificationVO() 	{	}
		
		// RESET ALL DATA 
		public function reset():void {
			type = TYPE_DEFAULT;
			message = "";
			callback = null;
			hasIcon = false;
			iconType = 1;
			callbackData = null;
			
		}
		
		
		
	}

}