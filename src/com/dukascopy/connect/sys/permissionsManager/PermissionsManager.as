package com.dukascopy.connect.sys.permissionsManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.screens.requestPermissionScreens.RequestContactsPermissionScreen;
	import com.dukascopy.connect.screens.requestPermissionScreens.RequestNotificationsPermissionScreen;
	import com.dukascopy.connect.sys.notificationManager.PushNotificationsNative;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class PermissionsManager {
		
		public static const ON_PERMISSION_GRANTED:String =  "ON_PERMISSION_GRANTED";
		public static const ON_PERMISSION_DENIED:String =  "ON_PERMISSION_DENIED";
		
		public static const PERMISSION_TYPE_CONTACTS:String = "PERMISSION_TYPE_CONTACTS";
		public static const PERMISSION_TYPE_NOTIFICATIONS:String = "PERMISSION_TYPE_NOTIFICATIONS";
		
		public static var S_SHOW:Signal = new Signal('PermissionsManager.S_SHOW');
		public static var S_CLOSE:Signal = new Signal('PermissionsManager.S_CLOSE');
		
		private static var _screensStack:Vector.<Class>
		private static var currentScreen:Class;
		private static var _askPermissionsStateVO:AskPermissionsStateVO;
		private static var _notificationsPermissionManager:NotificationPermissionManager;
		
		private static var _isCallOnConactsRequested:Boolean = false;
		private static var _isCallOnNotificationsRequested:Boolean = false;
		
		private static var _isContactsAlreadyGranted:Boolean;
		private static var _isAlreadyReadingFromStore:Boolean = false;
		
		public static function init():void {
			_notificationsPermissionManager = new NotificationPermissionManager();
		}
		
		private static function showScreen(screenClass:Class):void {
			screensStack.push(screenClass);
			updateNextScreen();
		}
		
		private static function updateNextScreen():void {
			if (currentScreen != null)
				return;
			if (screensStack.length == 0)
				return;
			currentScreen = screensStack[0];
			screensStack.splice(0, 1);
			S_SHOW.invoke(currentScreen);
		}
		
		private static function closeCurrentScreen():void {
			S_CLOSE.invoke();
			currentScreen = null;
			updateNextScreen();
		}
		
		private static function get screensStack():Vector.<Class> {
			_screensStack ||= new Vector.<Class>();
			return _screensStack;
		}
		
		public static function requestPermissionInitiation(permissionType:String):void {
			if (permissionType == PERMISSION_TYPE_CONTACTS)
				_isCallOnConactsRequested = true;
			else if (permissionType == PERMISSION_TYPE_NOTIFICATIONS)
				_isCallOnNotificationsRequested = true;
			readVOFromStore();
		}
		
		private static function onNotificationsRequested():void {
			if (_askPermissionsStateVO != null && _askPermissionsStateVO.isAbleToRequestNotificatioins == false)
				return;
			if (Config.PLATFORM_ANDROID == true) {
				PushNotificationsNative.initNotifications();
				return;
			}
			_notificationsPermissionManager.requestNotificationState(onCurrentNotificationPermissionStateGet);
		}
		
		private static function onCurrentNotificationPermissionStateGet(state:String):void {
			if (state == NotificationPermissionManager.STATE_AUTHORIZED) {
				PushNotificationsNative.initNotifications();
				return;
			}
			if (state == NotificationPermissionManager.STATE_NEVER_ASK) {
				showScreen(RequestNotificationsPermissionScreen);
				return;
			}
		}
		
		public static function requestNotificationsPermission(callback:Function):void {
			_notificationsPermissionManager.requestNotificationPermission(callback);
		}
		
		public static function onNotificationPermissionRequested(val:String):void {
			if (val == ON_PERMISSION_GRANTED) {
				PushNotificationsNative.initNotifications();
				closeCurrentScreen();
			}
		}
		
		private static function onContactsRequested():void {
			if (_askPermissionsStateVO != null && !_askPermissionsStateVO.isAbleToRequestContacts) {
				PhonebookManager.onPhonebookAccessDenied();
				return;
			}
			if (isContactsPermissionGranted || !PermissionCheckUtil.isContactsPermissionsPossibleToRequest) {
				if(_isContactsAlreadyGranted == false) {
					PhonebookManager.onPhonebookAccessGranted();
					_isContactsAlreadyGranted = true;
				}
				return;
			}
			if (isContactsPermissionDenied == false)
				showScreen(RequestContactsPermissionScreen);
		}
		
		public static function onContactPermissionRequested(resState:String):void {
			switch (resState) {
				case ON_PERMISSION_GRANTED:
					if (_isContactsAlreadyGranted == false) {
						PhonebookManager.onPhonebookAccessGranted();
						_isContactsAlreadyGranted = true;
					}
					closeCurrentScreen();
					break;
				case ON_PERMISSION_DENIED:
					PhonebookManager.onPhonebookAccessDenied();
					break;	
			}
		}
		
		public static function notifyCloseRequesPermissionScreen(screenType:String, neverAskAgain:Boolean):void {
			if (_askPermissionsStateVO == null)
				_askPermissionsStateVO = new AskPermissionsStateVO();
			if (neverAskAgain == true) {
				if (screenType == PERMISSION_TYPE_CONTACTS)
					_askPermissionsStateVO.isAbleToRequestNotificatioins = false;
				else if (screenType == PERMISSION_TYPE_CONTACTS)
					_askPermissionsStateVO.isAbleToRequestContacts = false;
				saveVOToStore();
			}
			closeCurrentScreen();
		}
		
		public static function readVOFromStore():void {
			if (_askPermissionsStateVO != null) {
				executeOnReadFromStoreCallbacks();
				return;
			}
			if (_isAlreadyReadingFromStore == true)
				return;
			_isAlreadyReadingFromStore = true;
			Store.load(Store.VAR_REQUEST_PERMISSION_ABILITY_STATES, onGotVoFromStore);
		}
		
		private static function onGotVoFromStore(res:Object, err:Boolean):void {
			_isAlreadyReadingFromStore = false;
			_askPermissionsStateVO = new AskPermissionsStateVO(res);
			executeOnReadFromStoreCallbacks();
		}
		
		private static function executeOnReadFromStoreCallbacks():void {
			if (_isCallOnConactsRequested == true) {
				onContactsRequested();
				_isCallOnConactsRequested = false;
			}
			if (_isCallOnNotificationsRequested == true) {
				onNotificationsRequested();
				_isCallOnNotificationsRequested = false;
			}
		}
		
		private static function saveVOToStore():void {
			if (_askPermissionsStateVO == null)
				return;
			Store.save(Store.VAR_REQUEST_PERMISSION_ABILITY_STATES, _askPermissionsStateVO.getData());
		}
		
		public static function get isContactsPermissionGranted():Boolean {
			return PermissionCheckUtil.getIsPermissionGranted(PermissionCheck.SOURCE_CONTACTS);
		}
		
		public static function get isContactsPermissionDenied():Boolean {
			return PermissionCheckUtil.getIsPermissionDenied(PermissionCheck.SOURCE_CONTACTS);
		}
		
		public static function requestContactsPermission(onSuccessCallback:Function, onFailCallback:Function):void{
			PermissionCheckUtil.requestPermission(PermissionCheck.SOURCE_CONTACTS, onSuccessCallback, onFailCallback);
		}
	}
}