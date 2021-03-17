package com.dukascopy.connect.sys.viManager.data {
	
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import flash.display.BitmapData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class RemoteMessage {
		
		public var type:String;
		public var signal:String;
		public var actions:Vector.<VIAction>;
		public var message:String;
		
		public var mine:Boolean = false;
		public var menuLayout:String = "vertical";
		public var buttons:Array;
		public var photo:ImageBitmapData;
		public var sound:String;
		public var disabled:Boolean;
		public var action:String;
		public var successAction:String;
		public var failAction:String;
		public var name:String;
		public var photos:Array;
		
		public function RemoteMessage(rawData:Object = null) {
			if (rawData != null) {
				parse(rawData);
			}
		}
		
		private function parse(rawData:Object):void {
			if ("type" in rawData && rawData.type != null)
			{
				type = rawData.type;
			}
			if ("signal" in rawData && rawData.signal != null)
			{
				signal = rawData.signal;
			}
			if ("message" in rawData && rawData.message != null)
			{
				message = rawData.message;
			}
			if ("sound" in rawData && rawData.sound != null)
			{
				sound = rawData.sound;
			}
			if ("action" in rawData && rawData.action != null)
			{
				action = rawData.action;
			}
			if ("successAction" in rawData && rawData.successAction != null)
			{
				successAction = rawData.successAction;
			}
			if ("failAction" in rawData && rawData.failAction != null)
			{
				failAction = rawData.failAction;
			}
			if ("name" in rawData && rawData.name != null)
			{
				name = rawData.name;
			}
			if ("actions" in rawData && rawData.actions != null)
			{
				actions = new Vector.<VIAction>();
				for (var i:int = 0; i < rawData.actions.length; i++) 
				{
					actions.push(new VIAction(rawData.actions[i]));
				}
			}
		}
		
		public function getRaw():Object {
			var raw:Object = new Object();
			
			if (successAction != null)
			{
				raw.successAction = successAction;
			}
			if (failAction != null)
			{
				raw.failAction = failAction;
			}
			if (type != null)
			{
				raw.type = type;
			}
			if (signal != null)
			{
				raw.signal = signal;
			}
			if (sound != null)
			{
				raw.sound = sound;
			}
			if (message != null)
			{
				raw.message = message;
			}
			if (action != null)
			{
				raw.action = action;
			}
			if (photos != null)
			{
				raw.photos = photos;
			}
			
			if (actions != null && actions.length > 0)
			{
				raw.actions = new Array();
				var actionRaw:Object;
				for (var i:int = 0; i < actions.length; i++) 
				{
					raw.actions.push(actions[i].getRaw());
				}
			}
			
			return raw;
		}
	}
}