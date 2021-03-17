package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SystemInfo 
	{
		public var totalMemory:Number;
		public var FEATURE_TOUCHSCREEN:Boolean;
		public var FEATURE_LOCATION_GPS:Boolean;
		public var FEATURE_SENSOR_ACCELEROMETER:Boolean;
		public var FEATURE_TELEPHONY:Boolean;
		public var FEATURE_BLUETOOTH:Boolean;
		public var FEATURE_CONSUMER_IR:Boolean;
		public var FEATURE_FAKETOUCH:Boolean;
		public var FEATURE_MICROPHONE:Boolean;
		public var FEATURE_NFC:Boolean;
		public var FEATURE_SENSOR_BAROMETER:Boolean;
		public var FEATURE_SENSOR_COMPASS:Boolean;
		public var FEATURE_SENSOR_GYROSCOPE:Boolean;
		public var FEATURE_SENSOR_LIGHT:Boolean;
		public var FEATURE_SENSOR_PROXIMITY:Boolean;
		public var FEATURE_TOUCHSCREEN_MULTITOUCH:Boolean;
		public var FEATURE_SENSOR_HEART_RATE:Boolean;
		public var FEATURE_LEANBACK:Boolean;
		public var FEATURE_SENSOR_RELATIVE_HUMIDITY:Boolean;
		public var FEATURE_SENSOR_AMBIENT_TEMPERATURE:Boolean;
		public var FEATURE_CAMERA_LEVEL_FULL:Boolean;
		public var FEATURE_AUDIO_PRO:Boolean;
		public var FEATURE_FINGERPRINT:Boolean;
		public var FEATURE_PICTURE_IN_PICTURE:Boolean;
		public var FEATURE_IRIS:Boolean;
		public var FEATURE_FACE:Boolean;
		public var CPU_CORES:int;
		public var width:int;
		public var height:int;
		public var xDpi:int;
		public var yDpi:int;
		public var camerasNum:int;
		public var sdkVersion:int;
		public var manufacturer:String;
		public var model:String;
		public var name:String;
		public var cpu:String;
		
		public var rawData:Object;
		
		public function SystemInfo(rawData:Object) 
		{
			if (rawData != null)
			{
				width = rawData.width;
				height = rawData.height;
				xDpi = rawData.xDpi;
				yDpi = rawData.yDpi;
				camerasNum = rawData.camerasNum;
				sdkVersion = rawData.sdkVersion;
				manufacturer = rawData.manufacturer;
				model = rawData.model;
				name = rawData.name;
				cpu = rawData.cpu;
				totalMemory = rawData.totalMemory;
				FEATURE_TOUCHSCREEN = rawData.FEATURE_TOUCHSCREEN;
				FEATURE_LOCATION_GPS = rawData.FEATURE_LOCATION_GPS;
				FEATURE_SENSOR_ACCELEROMETER = rawData.FEATURE_SENSOR_ACCELEROMETER;
				FEATURE_TELEPHONY = rawData.FEATURE_TELEPHONY;
				FEATURE_BLUETOOTH = rawData.FEATURE_BLUETOOTH;
				FEATURE_CONSUMER_IR = rawData.FEATURE_CONSUMER_IR;
				FEATURE_FAKETOUCH = rawData.FEATURE_FAKETOUCH;
				FEATURE_MICROPHONE = rawData.FEATURE_MICROPHONE;
				FEATURE_NFC = rawData.FEATURE_NFC;
				FEATURE_SENSOR_BAROMETER = rawData.FEATURE_SENSOR_BAROMETER;
				FEATURE_SENSOR_COMPASS = rawData.FEATURE_SENSOR_COMPASS;
				FEATURE_SENSOR_GYROSCOPE = rawData.FEATURE_SENSOR_GYROSCOPE;
				FEATURE_SENSOR_LIGHT = rawData.FEATURE_SENSOR_LIGHT;
				FEATURE_SENSOR_PROXIMITY = rawData.FEATURE_SENSOR_PROXIMITY;
				FEATURE_TOUCHSCREEN_MULTITOUCH = rawData.FEATURE_TOUCHSCREEN_MULTITOUCH;
				FEATURE_SENSOR_HEART_RATE = rawData.FEATURE_SENSOR_HEART_RATE;
				FEATURE_LEANBACK = rawData.FEATURE_LEANBACK;
				FEATURE_SENSOR_RELATIVE_HUMIDITY = rawData.FEATURE_SENSOR_RELATIVE_HUMIDITY;
				FEATURE_SENSOR_AMBIENT_TEMPERATURE = rawData.FEATURE_SENSOR_AMBIENT_TEMPERATURE;
				FEATURE_CAMERA_LEVEL_FULL = rawData.FEATURE_CAMERA_LEVEL_FULL;
				FEATURE_AUDIO_PRO = rawData.FEATURE_AUDIO_PRO;
				FEATURE_FINGERPRINT = rawData.FEATURE_FINGERPRINT;
				FEATURE_PICTURE_IN_PICTURE = rawData.FEATURE_PICTURE_IN_PICTURE;
				FEATURE_IRIS = rawData.FEATURE_IRIS;
				FEATURE_FACE = rawData.FEATURE_FACE;
				CPU_CORES = rawData.CPU_CORES;
			}
			this.rawData = rawData;
		}
	}
}