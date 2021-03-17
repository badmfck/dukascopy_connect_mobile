package com.dukascopy.connect.utils 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.input.InputWithClearButton;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PlatformDependingClassFactory 
	{
		
		public function PlatformDependingClassFactory() 
		{
			
		}
		
		public static function getInputWithClearButton():Input
		{
			if (Config.PLATFORM_APPLE)
			{
				return new Input();
			}
			else if(Config.PLATFORM_ANDROID)
			{
				return new InputWithClearButton();
			}
			else if(Config.PLATFORM_WINDOWS)
			{
				return new InputWithClearButton();
			}
			return new Input();
		}
		
	}

}