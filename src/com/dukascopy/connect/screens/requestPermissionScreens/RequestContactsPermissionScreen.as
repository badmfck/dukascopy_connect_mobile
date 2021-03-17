package com.dukascopy.connect.screens.requestPermissionScreens {
	
	import assets.ContactsNotifications;
	import com.dukascopy.connect.sys.permissionsManager.PermissionCheckUtil;
	import com.dukascopy.connect.sys.permissionsManager.PermissionsManager;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class RequestContactsPermissionScreen extends BaseRequestPermissionScreen {
		
		public function RequestContactsPermissionScreen() {
			initBackground();
			super();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen();
			if (PermissionsManager.isContactsPermissionDenied == true) {
				onPermissionDenied();
			} else {
				super.setTexts(Lang.textAddFriendsFromYourAdressBook, Lang.textEasyWayToFindYourFriends);
			}
		}
		
		override protected function onTapRequest():void {
			if (_isCloseOnTapContinue == true) {
				PermissionsManager.notifyCloseRequesPermissionScreen(PermissionsManager.PERMISSION_TYPE_CONTACTS, _isNeverAskAgain);
				return;
			}
			PermissionsManager.requestContactsPermission(onPermissionGranted, onPermissionDenied);
		}
		
		private function onPermissionGranted():void {
			PermissionsManager.onContactPermissionRequested(PermissionsManager.ON_PERMISSION_GRANTED);
		}
		
		override protected function onTapBack():void {
			PermissionsManager.onContactPermissionRequested(PermissionsManager.ON_PERMISSION_DENIED);
			PermissionsManager.notifyCloseRequesPermissionScreen(PermissionsManager.PERMISSION_TYPE_CONTACTS, _isNeverAskAgain);
		}
		
		override protected function initBackground():void{
			backGround = new ContactsNotifications();
		}
	}
}