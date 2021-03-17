package com.dukascopy.connect.screens.dialogs.geolocation 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CityLocationListItem 
	{
		private var _selected:Boolean;
		private var _city:CityGeoposition;
		private var _myPosition:Boolean;
		
		public function CityLocationListItem(city:CityGeoposition, selected:Boolean = false, myPosition:Boolean = false) 
		{
			this._selected = selected;
			this._myPosition = myPosition;
			this._city = city;
		}
		
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function get myPosition():Boolean 
		{
			return _myPosition;
		}
		
		public function get city():CityGeoposition 
		{
			return _city;
		}
		
		public function set city(value:CityGeoposition):void 
		{
			_city = value;
		}
		
		public function select():void
		{
			_selected = true;
		}
		
		public function unselect():void
		{
			_selected = false;
		}
		
		public function dispose():void
		{
			_city = null;
		}
	}
}