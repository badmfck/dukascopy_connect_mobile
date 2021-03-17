package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	import flash.events.PermissionEvent;
	import flash.media.Microphone;
	import flash.permissions.PermissionStatus;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class GetAudioPermissionAction extends BaseSystemAction implements IBotSystemAction 
	{
		public function GetAudioPermissionAction(action:RemoteMessage) 
		{
			this.action = action;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void 
		{
			this.onSuccess = onSuccess;
			this.onFail = onFail;
			
			if (Microphone.isSupported)
			{
				if (Microphone.permissionStatus != PermissionStatus.GRANTED && 
					Microphone.permissionStatus != PermissionStatus.ONLY_WHEN_IN_USE && 
					(Microphone as Object).permissionStatus !== undefined)
				{
					requestPermission();
				}
				else
				{
					dispatchResult(true);
				}
			}
			else
			{
				dispatchResult(false);
			}
		}
		
		private function requestPermission():void 
		{
			var mic:Microphone = Microphone.getMicrophone();
			mic.addEventListener(PermissionEvent.PERMISSION_STATUS, onPermissionEvent);
			
			try
			{
				mic.requestPermission();
			}
			catch (err:Error)
			{
				mic.removeEventListener(PermissionEvent.PERMISSION_STATUS, onPermissionEvent);
				dispatchResult(false);
			}
		}
		
		private function onPermissionEvent(e:PermissionEvent):void 
		{
			(e.target as Microphone).removeEventListener(PermissionEvent.PERMISSION_STATUS, onPermissionEvent);
			
			if (e.status == PermissionStatus.GRANTED || e.status == PermissionStatus.ONLY_WHEN_IN_USE)
			{
				dispatchResult(true);
			}
			else
			{
				dispatchResult(false);
			}
		}
	}
}