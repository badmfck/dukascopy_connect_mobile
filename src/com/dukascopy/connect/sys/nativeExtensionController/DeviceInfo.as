package com.dukascopy.connect.sys.nativeExtensionController 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class DeviceInfo 
	{
		public var manufacturer:String;    // "Samsung"
        public var marketName:String;      // "Galaxy S8+"
        public var model:String;           // "SM-G955W"
        public var codename:String ;       // "dream2qltecan"
        public var deviceName:String;      // "Galaxy S8+"
		
		public function DeviceInfo(rawData:Object) 
		{
			if (rawData != null)
			{
				manufacturer = rawData.manufacturer;
				marketName = rawData.name;
				model = rawData.model;
				codename = rawData.codename;
				deviceName = rawData.deviceName;
			}
		}
	}
}