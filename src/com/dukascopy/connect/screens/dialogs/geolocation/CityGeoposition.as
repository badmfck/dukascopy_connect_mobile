package com.dukascopy.connect.screens.dialogs.geolocation {
	
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CityGeoposition {
		
		private var _cityName:String;
		private var _displayName:String;
		private var _location:Location;
		
		public function CityGeoposition(cityName:String, location:Location) {
			_cityName = cityName;
			_location = location;
			updateDisplayName();
		}
		
		public function updateDisplayName():void {
			_displayName = Lang[_cityName];
		}
		
		public function get cityName():String { return _displayName; }
		public function get location():Location { return _location; }
	}
}