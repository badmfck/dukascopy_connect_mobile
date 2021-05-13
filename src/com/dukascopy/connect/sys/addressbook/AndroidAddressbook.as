package com.dukascopy.connect.sys.addressbook 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.langs.Lang;
	import com.freshplanet.ane.airaddressbook.AirAddressBookContactsEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class AndroidAddressbook extends EventDispatcher
	{
		private static var _instance : AndroidAddressbook;
		private var created:Boolean;
		
		public function AndroidAddressbook() 
		{
			echo("book:", "AndroidAddressbook");
			if (!_instance)
			{
				createContextIfNull();
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}
		
		public static function get isSupported() : Boolean
		{
			return true;
		}
		
		public static function getInstance():AndroidAddressbook
		{
			return _instance ? _instance : new AndroidAddressbook();
		}
		
		public function initCache(cache:Array):void {
			echo("book:", "initCache");
			createContextIfNull();
			if (MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.initAddressbook(cache, Lang.addressbookPermisionRequired, Lang.provideAccessToContacts, Lang.textOk);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function hasPermission():int
		{
			return Addressbook.PERMISSION_GRANTED;
		}
		
		public function check(batchSize:int):void {
			echo("book:", "check");
			createContextIfNull() ;
			if (MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.checkAddressbook(batchSize);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function createContextIfNull():void {
			if(!created)
			{
				created = true;
				if (MobileGui.androidExtension != null)
				{
					MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, onStatus);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
		}
		
		private function onStatus( event:StatusEvent ) : void
		{
			echo("book: [AirAddressBook] onStatus: ", event.code, event.level);
			
			if( event.code == Addressbook.JOB_RUNNING ||
				event.code == Addressbook.ACCESS_DENIED
			) {
				this.dispatchEvent( new ErrorEvent(event.code) ) ;
			} else if ( event.code == Addressbook.ACCESS_GRANTED || event.code == Addressbook.JOB_STARTED || event.code == Addressbook.JOB_FINISHED){
				this.dispatchEvent( new Event( event.code ) ) ;
			} else if ( event.code == Addressbook.CONTACTS_UPDATED ) {
				
				var raw:String = event.level ;
				
				try {
					var dat:Object = JSON.parse( raw ) ;
					var isLast:Boolean = dat.hasOwnProperty('__parseEnd') && dat['__parseEnd'] == "true" ;
					delete dat['__parseEnd'] ;
					this.dispatchEvent( new AirAddressBookContactsEvent( dat, isLast ) ) ;
				} catch (e:Error) {
					trace("[Peter][AirAddressBook] " + e.message + "\n" + raw);
				}
			}
		}
	}
}