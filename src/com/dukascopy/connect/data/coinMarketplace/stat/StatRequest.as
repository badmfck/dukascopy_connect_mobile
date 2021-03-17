package com.dukascopy.connect.data.coinMarketplace.stat 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.store.Store;
	import com.telefision.sys.signals.Signal;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StatRequest 
	{
		public var COMPLETE:Signal = new Signal ('StatRequest.COMPLETE');
		public var last:Boolean;
		public var since:Number;
		public var until:Number;
		
		private var loader:URLLoader;
		
		private var request:URLRequest;
		private var type:String;
		
		public function StatRequest(request:URLRequest, type:String) 
		{
			this.request = request;
			this.type = type;
		}
		
		public function dispose():void 
		{
			if (loader)
			{
				try
				{
					loader.close();
				}
				catch (e:Error)
				{
					ApplicationErrors.add();
				}
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				loader = null;
			}
		}
		
		public function execute():void 
		{
			if (last == true)
			{
				load();
			}
			else
			{
				Store.load(Store.COIN_STAT + getName(), onLocalDataLoaded)
			}
		}
		
		private function load():void 
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			loader.load(request);
		}
		
		private function onLocalDataLoaded(data:Object, err:Boolean):void {
			if (err == false && data != null)
			{
				COMPLETE.invoke(true, data, type, since, until, last);
			}
			else
			{
				load();
			}
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void 
		{
			COMPLETE.invoke(false, null, type, since, until, last);
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{
			COMPLETE.invoke(false, null, type, since, until, last);
		}
		
		private function onComplete(e:Event):void 
		{
			if (last == false)
			{
				Store.save(Store.COIN_STAT + getName(), loader.data, null);
			}
			
			COMPLETE.invoke(true, loader.data, type, since, until, last);
		}
		
		private function getName():String 
		{
			return "_" + type + "_" + since + "_" + until;
		}
	}
}