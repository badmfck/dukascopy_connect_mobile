package com.dukascopy.connect.sys.usersManager.extensions.config
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.usersManager.extensions.FlowerData;
	import com.dukascopy.connect.sys.usersManager.extensions.UserExtensionsManager;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FlowersConfig
	{
		static public var ready:Boolean;
		static public var loaded:Boolean;
		
		static public const TYPE:String = "FlowersConfig";
		static private var configData:FlowersConfigData;
		
		public function FlowersConfig()
		{
			PHP.loadFlowersConfig(onConfigLoaded);
		}
		
		public function getFlowerData(productId:int):FlowerData
		{
			if (configData != null)
			{
				return configData.getFlower(productId);
			}
			else
			{
				ApplicationErrors.add();
				return null;
			}
		}
		
		private static function onConfigLoaded(respond:PHPRespond):void
		{
			loaded = true;
			if (respond.error == true)
			{
				onCongigChanged(false);
			}
			else if ("data" in respond && respond.data != null)
			{
				var parser:FlowersConfigParser = new FlowersConfigParser();
				configData = parser.parse(respond.data);
				onCongigChanged(true);
				parser = null;
			}
			
			respond.dispose();
		}
		
		static private function onCongigChanged(success:Boolean):void
		{
			ready = success;
			UserExtensionsManager.S_UPDATED.invoke(TYPE);
		}
	}
}