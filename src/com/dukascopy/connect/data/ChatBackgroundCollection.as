package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.sys.assets.Assets;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatBackgroundCollection 
	{
		
		private static var backgroundModels:Vector.<BackgroundModel> = new <BackgroundModel>[
					
					new BackgroundModel("1", Assets.CHAT_BACK_10, Assets.CHAT_BACK_THUMB_10, 0x94c5e5, 0x000000),
					new BackgroundModel("2", Assets.CHAT_BACK_11, Assets.CHAT_BACK_THUMB_11, 0x94c5e5, 0x000000),
					new BackgroundModel("3", Assets.CHAT_BACK_12, Assets.CHAT_BACK_THUMB_12, 0x94c5e5, 0x000000),
					new BackgroundModel("4", Assets.CHAT_BACK_13, Assets.CHAT_BACK_THUMB_13, 0x94c5e5, 0x000000),
					new BackgroundModel("5", Assets.CHAT_BACK_14, Assets.CHAT_BACK_THUMB_14, 0x94c5e5, 0x000000),
					new BackgroundModel("6", Assets.CHAT_BACK_15, Assets.CHAT_BACK_THUMB_15, 0x94c5e5, 0x000000),
					
					new BackgroundModel("7", Assets.CHAT_BACK_1, Assets.CHAT_BACK_THUMB_1, 0x94c5e5, 0x000000), // second color param is text color of chat bottom "User is typing ..."
					new BackgroundModel("8", Assets.CHAT_BACK_2, Assets.CHAT_BACK_THUMB_2, 0x99212a, 0xffffff),
					new BackgroundModel("9", Assets.CHAT_BACK_3, Assets.CHAT_BACK_THUMB_3, 0xa8e9e3, 0x000000),
					new BackgroundModel("10", Assets.CHAT_BACK_4, Assets.CHAT_BACK_THUMB_4, 0x4d1f44, 0xffffff),
					new BackgroundModel("11", Assets.CHAT_BACK_5, Assets.CHAT_BACK_THUMB_5, 0x205f8b, 0xffffff),
					new BackgroundModel("12", Assets.CHAT_BACK_6, Assets.CHAT_BACK_THUMB_6, 0x43a0b2, 0xffffff),
					new BackgroundModel("13", Assets.CHAT_BACK_7, Assets.CHAT_BACK_THUMB_7, 0xffb07f, 0x000000),
					new BackgroundModel("14", Assets.CHAT_BACK_8, Assets.CHAT_BACK_THUMB_8, 0xfe8a8b, 0xffffff),
					new BackgroundModel("15", Assets.CHAT_BACK_9, Assets.CHAT_BACK_THUMB_9, 0xaa3021, 0xffffff)
		];
		
		public function ChatBackgroundCollection() 
		{
			
		}
		
		public static function getBackground(id:String):BackgroundModel
		{
			var length:int = backgroundModels.length;
			for (var i:int = 0; i < length; i++) 
			{
				if (backgroundModels[i].id == id)
				{
					return backgroundModels[i];
				}
			}
			return null;
		}
		
		static public function getCollection():Vector.<BackgroundModel> 
		{
			return backgroundModels;
		}
	}

}