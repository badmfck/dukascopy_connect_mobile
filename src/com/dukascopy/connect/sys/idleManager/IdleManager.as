package com.dukascopy.connect.sys.idleManager {
	
	import com.dukascopy.connect.MobileGui;
	
	/**
	 * Wrapper For IdleManager sensor
	 * 
	 * @author Alexey
	 */
	
	public class IdleManager {
		
		public function IdleManager() { }
		
		public static function keepAwake(value:Boolean):void {
			if (MobileGui.dce != null)
				MobileGui.dce.setKeepAwake(value);
		}
	}
}