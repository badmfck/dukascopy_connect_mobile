package com.dukascopy.connect.sys.permissionsManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import flash.events.StatusEvent;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class NotificationPermissionManager {
		
		public static const STATE_NEVER_ASK:String = "stateNeverAsk";
		public static const STATE_DENIED:String = "stateDenied";
		public static const STATE_AUTHORIZED:String = "stateAuthorized";
		
		private static const currentNotificationPermissionStateCode:String = "notificationAuthorizationStatus";
		private static const currentNotificationPermissionBoolStateCode:String = "notificationAuthorizationBoolStatus";
		private static const ios10AuthorizationStatusNotDetermined:String = "0";
		private static const ios10AuthorizationStatusDenied:String = "1";
		private static const ios10AuthorizationStatusAuthorized:String = "2";
		private static const iosOldAuthorizationStatusAuthorized:String = "1";
		private static const iosOldAuthorizationStatusNotAuthorized:String = "0";
		
		private static const requestNotificationAuthorizationCode:String = "requestNotificationAuthorization";
		
		private var _onRequestPermissionStateCallback:Function;
		private var _onRequestPermissionCallback:Function;
		
		public function NotificationPermissionManager():void {
			if (MobileGui.dce != null)
				MobileGui.dce.addEventListener(StatusEvent.STATUS, onStatusEvent);
		}
		
		public function requestNotificationState(onRequestPermissionStateCallback):void {
			_onRequestPermissionStateCallback = onRequestPermissionStateCallback;
			if (MobileGui.dce != null)
				MobileGui.dce.pushNotificationAuthorizationStatus();
		}
		
		public function requestNotificationPermission(onRequestPermissionCallback:Function):void {
			if(Config.PLATFORM_ANDROID == true) {
				onRequestPermissionCallback(true);
				return;
			}
			_onRequestPermissionCallback = onRequestPermissionCallback;
			if (MobileGui.dce != null)
				MobileGui.dce.requestPushNotificationAuthorization();
		}
		
		private function onStatusEvent(e:StatusEvent):void {
			var currentState:String
			if (e.code == currentNotificationPermissionStateCode) {
				currentState = convertCurrentState(e.level);
				_onRequestPermissionStateCallback(currentState);
				return;
			}
			if (e.code == currentNotificationPermissionBoolStateCode) {
				currentState = convertCurrentStateForOldIos(e.level);
				_onRequestPermissionStateCallback(currentState);
				return;
			}
			if (e.code == requestNotificationAuthorizationCode) {
				var o:Object = JSON.parse(e.level);
				if (o.response  == true) {
					_onRequestPermissionCallback(true);
					return;
				}
				_onRequestPermissionCallback(false);
				return;
			}
		}
		
		private function convertCurrentState(currentStateFromEvent:String):String {
			switch(currentStateFromEvent){
				case ios10AuthorizationStatusNotDetermined:
					return STATE_NEVER_ASK;
				case ios10AuthorizationStatusAuthorized:
					return STATE_AUTHORIZED;
				case ios10AuthorizationStatusDenied:
					return STATE_DENIED;
				default:
					return STATE_DENIED;
			}
		}
		
		private function convertCurrentStateForOldIos(currentStateFromEvent:String):String {
			switch(currentStateFromEvent) {
				case iosOldAuthorizationStatusAuthorized:
					return STATE_AUTHORIZED;
				case iosOldAuthorizationStatusNotAuthorized:
					return STATE_NEVER_ASK;
				default:
					return STATE_DENIED;
			}
		}
	}
}