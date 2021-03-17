package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ChatSystemMessageData 
	{
		public var message:String;
		public var buttons:Vector.<ButtonActionData>;
		public var title:String;
		public var backAlpha:Number = 1;
		
		static public const YOU_BANNED:String = "youBanned";
		static public const YOU_BLOCKED:String = "youBlocked";
		
		public var type:String;
		
		public function ChatSystemMessageData() 
		{
			buttons = new Vector.<ButtonActionData>();
		}
		
		public function dispose():void 
		{
			message = null;
			title = null;
			if (buttons)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].dispose();
				}
				buttons = null;
			}
		}
		
		public function addButton(buttonData:ButtonActionData):void 
		{
			if (buttons)
			{
				buttons.push(buttonData);
			}
		}
	}
}