package com.dukascopy.connect.sys.permissionsManager {
	
	import com.dukascopy.connect.Config;
	import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class PermissionCheckUtil {
		
		private static var _permissionsCheck:PermissionCheck;
		
		private static function get permissionsCheck():PermissionCheck{
			if (Config.PLATFORM_ANDROID == false && Config.PLATFORM_APPLE == false)
				return null;
			_permissionsCheck ||= new PermissionCheck();
			return _permissionsCheck;
		}
		
		public static function get isContactsPermissionsPossibleToRequest():Boolean{
			return getIsPossibleToRequest(PermissionCheck.SOURCE_CONTACTS);
		}
		
		public static function requestPermission(permissionType:String, onSuccessCallback:Function, onFailCallback:Function):void{
			if (Config.PLATFORM_ANDROID == false && Config.PLATFORM_APPLE == false) {
				onSuccessCallback();
				return;
			}
			var permissionState:int = permissionsCheck.check(permissionType);	
			if (permissionState == PermissionCheck.PERMISSION_GRANTED) {
				onSuccessCallback();
				return;
			} else if (permissionState == PermissionCheck.PERMISSION_OS_ERR) {
				onFailCallback();
				return;
			}
			permissionsCheck.request(permissionType, function(res:int):void {
				if (res == PermissionCheck.PERMISSION_GRANTED) {
					onSuccessCallback();
					return;
				}
				onFailCallback();
			} );
		}
		
		public static function getIsPermissionGranted(permissionType:String):Boolean {
			if (Config.PLATFORM_ANDROID == false && Config.PLATFORM_APPLE == false)
				return true;
			var permissionState:int = permissionsCheck.check(permissionType);
			if (permissionState == PermissionCheck.PERMISSION_GRANTED || permissionState == PermissionCheck.PERMISSION_OS_ERR)
				return true;
			return false;
		}
		
		public static function getIsPermissionDenied(permissionType:String):Boolean {
			if (Config.PLATFORM_APPLE == false)
				return false;
			var permissionState:int = permissionsCheck.check(permissionType);
			if (permissionState == PermissionCheck.PERMISSION_DENIED)
				return true;
			return false;
		}
		
		private static function getIsPossibleToRequest(permissionType:String):Boolean {
			if (Config.PLATFORM_ANDROID == false && Config.PLATFORM_APPLE == false)
				return false;
			var permissionState:int = permissionsCheck.check(permissionType);
			if (permissionState == PermissionCheck.PERMISSION_OS_ERR)
				return false;
			return true;
		}
	}
}