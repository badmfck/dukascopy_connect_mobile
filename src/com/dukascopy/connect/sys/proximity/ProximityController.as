package com.dukascopy.connect.sys.proximity {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import flash.events.StatusEvent;
	
	/**
	 * Wrapper For proximity sensor
	 * 
	 * @author Alexey
	 */
	
	public class ProximityController {
		
		public static var proximityCallback:Function;
		
		public function ProximityController() { }
		
		public static function init():void	{
			if (MobileGui.dce != null)
				MobileGui.dce.addEventListener(StatusEvent.STATUS, onProximityStatus);
		}
		
		public static function start():void	{
			if (MobileGui.dce != null)
				MobileGui.dce.startProximityObserving();
		}
		
		public static function stop():void	{
			if (MobileGui.dce != null)
				MobileGui.dce.stopProximityObserving();
		}
		
		static private function onProximityStatus(e:StatusEvent):void {
			if (proximityCallback != null)
				proximityCallback(e.level);
		}
	}
}