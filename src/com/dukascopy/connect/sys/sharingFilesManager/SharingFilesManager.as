package com.dukascopy.connect.sys.sharingFilesManager 
{
	import flash.desktop.InvokeEventReason;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	/**
	 * @author david.gnatkivskij
	 */
	public class SharingFilesManager 
	{
		public static function init():void
		{
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		}
		
		public static function onInvoke(e:InvokeEvent):void
		{
			trace("JKLMN");
		}

	}

}