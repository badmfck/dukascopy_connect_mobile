package com.dukascopy.connect.data.location 
{
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class Location 
	{
		public var latitude:Number;
		public var longitude:Number;
		
		public function Location(latitude:Number, longitude:Number) 
		{
			this.latitude = latitude;
			this.longitude = longitude;
		}
	}
}