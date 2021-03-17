package com.dukascopy.connect.sys.php 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.utils.TextUtils;
	import connect.DukascopyExtension;
	import flash.events.StatusEvent;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class IosServerLoadersManager 
	{
		static private var nativeBriedge:*;
		static private var inited:Boolean;
		static private var calls:Dictionary;
		
		public function IosServerLoadersManager() 
		{
			
		}
		
		public static function processCall(callRequest:IOSServerDataLoader):void
		{
			if (!inited)
			{
				init();
			}
			calls[callRequest.requestId] = callRequest;
			
			if ((callRequest.data.method.toString() as String).indexOf("report.add") != -1)
			{
				return;
			}
			nativeBriedge.loadURL(callRequest.url, callRequest.getRequestData(), callRequest.requestId, callRequest.crypt);
		}
		
		static private function init():void 
		{
			inited = true;
			nativeBriedge = MobileGui.dce;
			calls = new Dictionary();
			if (nativeBriedge)
			{
				nativeBriedge.addEventListener(StatusEvent.STATUS, onNativeResponce);
			}
			else
			{
				ApplicationErrors.add("native extension missed");
			}
		}
		
		static private function onNativeResponce(e:StatusEvent):void 
		{
			const eventCodeSuccess:String = "ios_network_didLoadSuccessful";
			const eventCodeFailed:String = "ios_network_didFailToLoad";
			const eventCodeFailedGeneral:String = "didFailToLoad";
			
			var data:Object;
			var callId:uint;
			
			if (e.code == eventCodeSuccess || e.code == eventCodeFailed || e.code == eventCodeFailedGeneral)
			{
				if (e.level != null)
				{
					try {
						data = JSON.parse(e.level);
					}
					catch (e:Error)
					{
						ApplicationErrors.add("json error");
					}
					if (data && ("callId" in data))
					{
						callId = uint(data.callId);
						if (calls != null && calls[callId]  != null)
						{
							if (e.code == eventCodeSuccess)
							{
								if (data && ("data" in data) && data.data)
								{
									(calls[callId] as IOSServerDataLoader).onDataLoaded(data.data);
								}
								else {
									ApplicationErrors.add("ewrong data format");
								}
							}
							else if (e.code == eventCodeFailed)
							{
								(calls[callId] as IOSServerDataLoader).onDataLoadFailed(data.data);
							}
							else if (e.code == eventCodeFailedGeneral)
							{
								(calls[callId] as IOSServerDataLoader).onDataLoadFailed(data.data);
							}
							
							calls[callId] = null;
							delete calls[callId];
						}
					}
				}
			}
		}
	}
}