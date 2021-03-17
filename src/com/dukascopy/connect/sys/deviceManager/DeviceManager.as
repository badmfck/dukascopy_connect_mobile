package com.dukascopy.connect.sys.deviceManager {
	
	import com.dukascopy.connect.Config;
	import flash.media.Microphone;
	
	/**
	 * @author Alexey
	 */
	
	public class DeviceManager {
		
		public function DeviceManager() { }
		
		public static function supportsEnhancedMicrophone():Boolean	{	
			if (Config.PLATFORM_WINDOWS == true)
				return true;
			return Microphone.getEnhancedMicrophone() != null;
		}
	}
}