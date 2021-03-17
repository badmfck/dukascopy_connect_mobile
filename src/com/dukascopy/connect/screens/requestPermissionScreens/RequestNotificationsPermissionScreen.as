package com.dukascopy.connect.screens.requestPermissionScreens {
	
	import assets.IllustrationNotifications;
	import com.dukascopy.connect.sys.permissionsManager.PermissionsManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 *@author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class RequestNotificationsPermissionScreen extends BaseRequestPermissionScreen {
		
		public function RequestNotificationsPermissionScreen() {
			initBackground()
			super();
			super.commentsTextsColor = AppTheme.GREY_DARK;
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen();
			super.setTexts(Lang.textGetNotified, Lang.textStayInTouch);
		}
		
		override protected function onTapRequest():void {
			if (_isCloseOnTapContinue == true) {
				PermissionsManager.notifyCloseRequesPermissionScreen(PermissionsManager.PERMISSION_TYPE_NOTIFICATIONS, _isNeverAskAgain);
				return;
			}
			PermissionsManager.requestNotificationsPermission(onNotificationPermissionRequested);
		}
		
		private function onNotificationPermissionRequested(resState:Boolean):void {
			var res:String;
			if (resState == true) {
				res = PermissionsManager.ON_PERMISSION_GRANTED;
			} else {
				res = PermissionsManager.ON_PERMISSION_DENIED;
				super.onPermissionDenied();
			}
			PermissionsManager.onNotificationPermissionRequested(res);
		}
		
		override protected function onTapBack():void {
			PermissionsManager.onNotificationPermissionRequested(PermissionsManager.ON_PERMISSION_DENIED);
			PermissionsManager.notifyCloseRequesPermissionScreen(PermissionsManager.PERMISSION_TYPE_NOTIFICATIONS, _isNeverAskAgain);
			onPermissionDenied();
		}
		
		override protected function initBackground():void{
			backGround = new IllustrationNotifications();
		}
	}
}