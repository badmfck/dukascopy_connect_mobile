package com.dukascopy.connect.vo 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.utils.Base64Modified;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatSettingsRemote 
	{
		private var rawData:Object;
		
		private var categories:Array;
		private var languages:Array;
		public var dataReady:Boolean;
		public var info:String;
		public var mode:String;
		public var writeMode:String;
		public var background:String;
		public var cover:String;
		public var backgroundBrightness:Number;
		
		public function ChatSettingsRemote(rawData:Object = null) {
			if (rawData) {
				dataReady = true;
				this.rawData = rawData;
				parse(rawData);
			}
		}
		
		public function getRawData():Object 
		{
			return rawData;
		}
		
		private function parse(data:Object):void 
		{
			var bytes:ByteArray;
			if ((ChannelsManager.CHANNEL_SETTINGS_INFO in data) && data[ChannelsManager.CHANNEL_SETTINGS_INFO] != null) {
				bytes = Base64Modified.decode(data[ChannelsManager.CHANNEL_SETTINGS_INFO]);
				bytes.position = 0;
				info = bytes.readUTFBytes(bytes.length);
			}
			if ("writeMode" in data  == true) {
				writeMode = data.writeMode;
			}
			if ((ChannelsManager.CHANNEL_SETTINGS_MODE in data) && data[ChannelsManager.CHANNEL_SETTINGS_MODE] != null) {
				mode = data[ChannelsManager.CHANNEL_SETTINGS_MODE];
			}
			
			if ((ChannelsManager.CHANNEL_SETTINGS_BACKGROUND in data) && data[ChannelsManager.CHANNEL_SETTINGS_BACKGROUND] != null)
			{
				background = data[ChannelsManager.CHANNEL_SETTINGS_BACKGROUND];
			}
			
			if ((ChannelsManager.CHANNEL_SETTINGS_COVER in data) && data[ChannelsManager.CHANNEL_SETTINGS_COVER] != null)
			{
				cover = data[ChannelsManager.CHANNEL_SETTINGS_COVER];
			}
			
			if ((ChannelsManager.CHANNEL_SETTINGS_CATEGORIES in data) && data[ChannelsManager.CHANNEL_SETTINGS_CATEGORIES] != null)
			{
				var categoriesString:String = data[ChannelsManager.CHANNEL_SETTINGS_CATEGORIES];
				if (categoriesString != null)
				{
					categories = categoriesString.split(",");
				}
			}
			
			if ((ChannelsManager.CHANNEL_SETTINGS_LANGUAGES in data) && data[ChannelsManager.CHANNEL_SETTINGS_LANGUAGES] != null)
			{
				var languagesString:String = data[ChannelsManager.CHANNEL_SETTINGS_LANGUAGES];
				if (languagesString != null)
				{
					languages = languagesString.split(",");
				}
			}
		}
		
		public function get coverURL(): String
		{
			if (cover == null || cover == "")
			{
				return null;
			}
			
			return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + cover;
		}
		
		public function get backgroundURL(): String
		{
			if (background == null || background == "")
			{
				return null;
			}
			
			return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + background;
		}
		
		public function get backgroundThumbURL(): String
		{
			if (background == null || background == "")
			{
				return null;
			}
			return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + background + "&thumb=1";
		}
	}
}