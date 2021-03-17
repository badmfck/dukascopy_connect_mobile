package com.dukascopy.connect.sys.geolocation {
	
	import com.adobe.protocols.dict.Database;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.data.location.UserGeoposition;
	import com.dukascopy.connect.screens.dialogs.geolocation.CityGeoposition;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.langs.LangManager;
	import com.dukascopy.langs.LangModel;
	import com.telefision.sys.signals.Signal;
	import flash.events.GeolocationEvent;
	import flash.events.PermissionEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.permissions.PermissionStatus;
	import flash.sensors.Geolocation;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	
	public class GeolocationManager {
		
		static private var locationAPI:Geolocation;
		static private var locations:Vector.<UserGeoposition>;
		static private var locationPoint:com.dukascopy.connect.data.location.Location;
		static private var allUsersExist:Boolean;
		static private var locationTimeout:Number = 10000;
		static private var getLocationsTimeout:Number = 60*1000;
		static private var lastLocationTime:Number;
		static private var lastGetLocationsDataTime:Number;
		static private var attempts:int = 0;
		static private var sendLocationInProcess:Boolean;
		
		static public var S_LOCATION:Signal = new Signal("GeolocationManager.S_LOCATION");
		static public var S_STATUS:Signal = new Signal("GeolocationManager.S_STATUS");
		static public var S_LOCATIONS:Signal = new Signal("GeolocationManager.S_LOCATIONS");
		static public var S_LOCATIONS_REFRESH:Signal = new Signal("GeolocationManager.S_LOCATIONS_REFRESH");
		static public var S_LISTEN_LOCATION_START:Signal = new Signal("GeolocationManager.S_LISTEN_LOCATION_START");
		static public var S_PERMISSION_DENIED:Signal = new Signal("GeolocationManager.S_PERMISSION_DENIED");
		static public var S_ERROR:Signal = new Signal("GeolocationManager.S_ERROR");
		static public var S_NEED_PAYMENTS:Signal = new Signal("GeolocationManager.S_NEED_PAYMENTS");
		static public var S_ALL_DATA_READY:Signal = new Signal("GeolocationManager.S_ALL_DATA_READY");
		static public var S_DATA_LOAD_START:Signal = new Signal("GeolocationManager.S_DATA_LOAD_START");
		static public var S_SERVICE_MUTED:Signal = new Signal("GeolocationManager.S_SERVICE_MUTED");
		
		static public const ERROR_NEED_LOCATION:String = "geo..02";
		static public const ERROR_NEED_PAYMENTS:String = "geo..03";
		
		static private var _geoCities:Array;
		
		static private var _myCity:CityGeoposition;
		
		public function GeolocationManager() {
		
		}
		
		public static function init():void {
			Auth.S_NEED_AUTHORIZATION.add(clean);
			UsersManager.S_USERS_FULL_DATA.add(onUsersUpdated);
		}
		
		static private function onUsersUpdated():void {
			if (allUsersExist == false) {
				updateTopBansWithUserModel();
				if (allUsersExist == true && locations != null)
					S_ALL_DATA_READY.invoke();
				S_LOCATIONS_REFRESH.invoke();
			}
		}
		
		static private function clean():void {
			if (locations != null)
				clearLocations();
		}
		
		public static function getLocation():void {
			if (locationPoint != null && (new Date()).getTime() - lastLocationTime < locationTimeout) {
				getList();
				return;
			}
			if (Config.PLATFORM_APPLE == false && Config.PLATFORM_ANDROID == false) {
				onMyLocationReady(new Location(50.45466 + Math.random()*0.91, 30.5238 + Math.random()*0.91));
				return;
			}
			if (Geolocation.isSupported == true) {
				if (locationAPI == null)
					locationAPI = new Geolocation();
				if (Geolocation.permissionStatus == PermissionStatus.UNKNOWN) {
					locationAPI.addEventListener(PermissionEvent.PERMISSION_STATUS, onPermissionResponse);
					locationAPI.requestPermission();
				} else if (Geolocation.permissionStatus == PermissionStatus.GRANTED || Geolocation.permissionStatus == PermissionStatus.ONLY_WHEN_IN_USE) {
					listenLocation();
				} else if (Geolocation.permissionStatus == PermissionStatus.DENIED) {
					if (locationAPI != null) {
						locationAPI.removeEventListener(StatusEvent.STATUS, onGeoStatus);
						locationAPI.removeEventListener(GeolocationEvent.UPDATE, onGeoUpdate);
						locationAPI.removeEventListener(PermissionEvent.PERMISSION_STATUS, onPermissionResponse);
						locationAPI = null;
					}
					S_PERMISSION_DENIED.invoke();
				}
			}
		}
		
		static public function isGranted():Boolean {
			if (Config.PLATFORM_APPLE == false && Config.PLATFORM_ANDROID == false)
				return true;
			if (Geolocation.isSupported == false)
				return false;
			if (Geolocation.permissionStatus != PermissionStatus.GRANTED && Geolocation.permissionStatus != PermissionStatus.ONLY_WHEN_IN_USE)
				return false;
			return true;
		}
		
		static public function getList():void {
			onLocationSavedSuccess();
		}
		
		static private function listenLocation():void {
			S_SERVICE_MUTED.invoke(locationAPI.muted);
			
			S_LISTEN_LOCATION_START.invoke();
			locationAPI.setRequestedUpdateInterval(6000);
			locationAPI.addEventListener(StatusEvent.STATUS, onGeoStatus);
			locationAPI.addEventListener(GeolocationEvent.UPDATE, onGeoUpdate);
		}
		
		static private function onPermissionResponse(event:PermissionEvent):void {
			if (event.status == PermissionStatus.GRANTED || event.status == PermissionStatus.ONLY_WHEN_IN_USE)
				listenLocation();
			else
				S_PERMISSION_DENIED.invoke();
		}
		
		static private function onGeoUpdate(e:GeolocationEvent):void {
			if (locationPoint != null && (new Date()).getTime() - lastLocationTime < locationTimeout) {
				S_LOCATION.invoke(null);
				return;
			}
			var location:Location = new Location(e.latitude, e.longitude);
			onMyLocationReady(location);
		}
		
		static private function onMyLocationReady(location:Location):void {
			lastLocationTime = (new Date()).getTime();
			locationPoint = location;
			S_LOCATION.invoke(locationPoint);
		}
		
		static public function saveMyLocation():void {
			if (sendLocationInProcess == false) {
				sendLocationInProcess = true;
				S_DATA_LOAD_START.invoke();
				PHP.call_geo_saveCurrent(onLocationSaved, locationPoint);
			}
		}
		
		private static function onLocationSaved(respond:PHPRespond):void {
			sendLocationInProcess = false;
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				S_ALL_DATA_READY.invoke();
			} else {
				onLocationSavedSuccess();
			}
			respond.dispose();
		}
		
		static private function onLocationSavedSuccess():void {
			if ((new Date()).getTime() - lastGetLocationsDataTime > getLocationsTimeout || locations == null) {
				S_DATA_LOAD_START.invoke();
				PHP.call_geo_neighbours(onLocationsRespond);
			} else if (allUsersExist == true)
				S_ALL_DATA_READY.invoke();
			if (locations != null)
				S_LOCATIONS.invoke();
		}
		
		static public function getLocations():Vector.<UserGeoposition> {
			if (locations != null)
				return locations;
			return null;
		}
		
		static private function onLocationsRespond(respond:PHPRespond):void {
			lastGetLocationsDataTime = (new Date()).getTime();
			if (respond.error == true) {
				S_ALL_DATA_READY.invoke();
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				if (respond.errorMsg == PHP.NETWORK_ERROR) {
					
				} else if (respond.errorMsg != null && respond.errorMsg.length >= 7) {
					var code:String = respond.errorMsg.substr(0, 7);
					if (code == ERROR_NEED_LOCATION) {
						attempts++; 
						if (attempts > 10) {
							S_ERROR.invoke();
							respond.dispose();
							return;
						}
						getLocation();
					} else if (code == ERROR_NEED_PAYMENTS) {
						S_NEED_PAYMENTS.invoke();
					}
				}
			} else {
				attempts = 0;
				if ("data" in respond && respond.data != null && respond.data is Array) {
					var newLocations:Vector.<UserGeoposition> = new Vector.<UserGeoposition>();
					var l:int = (respond.data as Array).length;
					var locationItem:UserGeoposition;
					for (var i:int = 0; i < l; i++) {
						if ("uid" in respond.data[i] && respond.data[i].uid != null && respond.data[i].uid.length <= 24) {
							locationItem = new UserGeoposition(respond.data[i]);
							newLocations.push(locationItem);
						}
					}
					if (locations == null) {
						locations = newLocations;
					} else {
						var updatedLocations:Vector.<UserGeoposition> = new Vector.<UserGeoposition>();
						l = locations.length;
						var l2:int = newLocations.length;
						var exist:Boolean;
						for (var j:int = 0; j < l; j++) {
							exist = false;
							for (var k:int = 0; k < l2; k++) {
								if (locations[j].uid == newLocations[k].uid && !newLocations[k].disposed) {
									exist = true;
									locations[j].update(newLocations[k]);
									updatedLocations.push(locations[j]);
									newLocations[k].dispose();
									break;
								}
							}
							if (!exist)
								locations[j].dispose();
						}
						for (var m:int = 0; m < l2; m++) {
							if (!newLocations[m].disposed)
								updatedLocations.push(newLocations[m]);
						}
						locations = updatedLocations;
					}
					updateTopBansWithUserModel();
					if (allUsersExist == true)
						S_ALL_DATA_READY.invoke();
					fillDistencies();
					locations = locations.sort(sortAlphaNum);
					S_LOCATIONS.invoke();
				}
			}
			respond.dispose();
		}
		
		static private function sortAlphaNum(first:UserGeoposition, second:UserGeoposition):int {
			if (first.distance > second.distance)
				return 1;
			else if (first.distance < second.distance)
				return -1
			return 0;
		}
		
		static private function clearLocations():void {
			var l:int = locations.length;
			for (var i:int = 0; i < l; i++)
				locations[i].dispose();
			locations = null;
		}
		
		static private function updateTopBansWithUserModel():Boolean {
			allUsersExist = true;
			if (locations != null) {
				var l:int = locations.length;
				for (var i:int = 0; i < l; i++) {
					if (locations[i].userVO == null) {
						locations[i].userVO = UsersManager.getFullUserData(locations[i].uid, true);
						if (locations[i].userVO == null) {
							allUsersExist = false;
						} else if (locations[i].userVO.disposed == true) {
							locations[i].userVO = null;
							allUsersExist = false;
						}
					}
				}
			}
			return false;
		}
		
		static private function fillDistencies():void {
			if (locations != null && locationPoint != null) {
				var l:int = locations.length;
				for (var i:int = 0; i < l; i++) {
					locations[i].distance = getDistanceFromLatLonInKm(
						locations[i].location.latitude,
						locations[i].location.longitude,
						locationPoint.latitude,
						locationPoint.longitude
					);
				}
			}
		}
		
		static private function onGeoStatus(e:StatusEvent):void {
			S_SERVICE_MUTED.invoke(locationAPI.muted);
			S_STATUS.invoke();
		}
		
		static public function getDistanceFromLatLonInKm(lat1:Number, lon1:Number, lat2:Number, lon2:Number):Number {
			var R:Number = 6371; // Radius of the earth in km
			var dLat:Number = deg2rad(lat2 - lat1);  // deg2rad below
			var dLon:Number = deg2rad(lon2 - lon1);
			var a:Number = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
			var c:Number = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
			var d:Number = R * c; // Distance in km
			return d;
		}
		
		static public function updateDistance(userGeoposition:UserGeoposition):void {
			if (locationPoint == null || userGeoposition == null)
				return;
			userGeoposition.distance = getDistanceFromLatLonInKm(
				userGeoposition.location.latitude,
				userGeoposition.location.longitude,
				locationPoint.latitude,
				locationPoint.longitude
			);
		}
		
		static private function deg2rad(deg:Number):Number {
			return deg * (Math.PI / 180);
		}
		
		static public function refreshLangConst():void {
			if (_geoCities == null)
				return;
			
		}
		
		static public function get geoCities():Array {
			if (_geoCities == null) {
				_geoCities = [
					new CityGeoposition("cityGeneva", new Location(46.2050242, 6.1090692)),
					new CityGeoposition("cityRiga", new Location(56.947, 24.12)),
					new CityGeoposition("cityKiev", new Location(50.4016991, 30.2525129)),
					new CityGeoposition("cityMoscow", new Location(55.5807481, 36.8251338)),
					new CityGeoposition("citySaintPetersburg", new Location(59.9390095, 29.5303098)),
					new CityGeoposition("cityHongKong", new Location(22.3299165, 114.0813018)),
					new CityGeoposition("cityShanghai", new Location(31.2231338, 120.9163027)),
					new CityGeoposition("cityKualaLumpur", new Location(3.1385036, 101.616949)),
					new CityGeoposition("cityTokyo", new Location(35.6732619, 139.5703037)),
					new CityGeoposition("cityDubai", new Location(25.0750853, 54.9475564))
				];
			}
			return _geoCities;
		}
		
		static public function get myCity():CityGeoposition {
			if (_myCity != null)
				return _myCity;
			if (locationPoint != null) {
				var cities:Array/*CityGeoposition*/ = geoCities;
				var km:Number = 0;
				for (var i:int = 0; i < cities.length; i++) {
					km = getDistanceFromLatLonInKm(
						locationPoint.latitude,
						locationPoint.longitude,
						cities[i].location.latitude,
						cities[i].location.longitude
					);
					if (100 > km) {
						_myCity = cities[i];
						break;
					}
				}
				return _myCity;
			}
			getLocation();
			return null;
		}
		
		static public function getMyLocation():Location {
			return locationPoint;
		}
	}
}