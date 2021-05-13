package com.dukascopy.connect.sys.addressbook 
{
	import com.dukascopy.connect.Config;
	import com.freshplanet.ane.airaddressbook.AirAddressBook;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Addressbook 
	{
		public static const JOB_STARTED:String = "job_started";
		public static const CONTACTS_UPDATED:String = "contacts_updated" ;
		public static const JOB_RUNNING:String = "job_running" ;
		public static const JOB_FINISHED:String = "job_finished";
		public static const ACCESS_DENIED:String = "access_denied" ;
		public static const ACCESS_GRANTED:String = "access_granted" ;
		
		public static const PERMISSION_GRANTED:int = 1 ;
		public static const PERMISSION_DENIED:int = 0 ;
		public static const PERMISSION_UNKNOWN:int = -1 ;
		
		public function Addressbook() 
		{
			
		}
		
		public static function get isSupported():Boolean
		{
			if (Config.PLATFORM_ANDROID)
			{
				return AndroidAddressbook.isSupported;
			}
			else
			{
				return AirAddressBook.isSupported;
			}
		}
		
		public static function initCache(cache:Array):void
		{
			if (Config.PLATFORM_ANDROID)
			{
				AndroidAddressbook.getInstance().initCache(cache);
			}
			else
			{
				AirAddressBook.getInstance().initCache(cache);
			}
		}
		
		public static function hasPermission():int
		{
			if (Config.PLATFORM_ANDROID)
			{
				return AndroidAddressbook.getInstance().hasPermission();
			}
			else
			{
				return AirAddressBook.getInstance().hasPermission();
			}
		}
		
		public static function check(batchSize:int):void
		{
			
			if (Config.PLATFORM_ANDROID)
			{
				AndroidAddressbook.getInstance().check(batchSize);
			}
			else
			{
				AirAddressBook.getInstance().check(batchSize);
			}
		}
		
		static public function addEventListener(event:String, callback:Function):void 
		{
			if (Config.PLATFORM_ANDROID)
			{
				AndroidAddressbook.getInstance().addEventListener(event, callback);
			}
			else
			{
				AirAddressBook.getInstance().addEventListener(event, callback);
			}
		}
		
		static public function removeEventListener(event:String, callback:Function):void 
		{
			if (Config.PLATFORM_ANDROID)
			{
				AndroidAddressbook.getInstance().removeEventListener(event, callback);
			}
			else
			{
				AirAddressBook.getInstance().removeEventListener(event, callback);
			}
		}
	}
}