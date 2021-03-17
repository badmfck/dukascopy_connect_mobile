package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	import flash.events.PermissionEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.permissions.PermissionStatus;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class GetVideoPermissionAction extends BaseSystemAction implements IBotSystemAction 
	{
		public function GetVideoPermissionAction(action:RemoteMessage) 
		{
			this.action = action;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void 
		{
			this.onSuccess = onSuccess;
			this.onFail = onFail;
			
			if (Camera.isSupported)
			{
				if (Camera.permissionStatus != PermissionStatus.GRANTED && 
					Camera.permissionStatus != PermissionStatus.ONLY_WHEN_IN_USE && 
					(Camera as Object).permissionStatus !== undefined)
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
			var camera:Camera = Camera.getCamera();
		//	camera.addEventListener(PermissionEvent.PERMISSION_STATUS, onPermissionEvent);
			
			camera.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void {
				if (e.status == PermissionStatus.GRANTED || e.status == PermissionStatus.ONLY_WHEN_IN_USE)
				{
					dispatchResult(true);
				}
				else
				{
					dispatchResult(false);
				}
			});
			
			try
			{
				camera.requestPermission();
			}
			catch (err:Error)
			{
			//	camera.removeEventListener(PermissionEvent.PERMISSION_STATUS, onPermissionEvent);
				dispatchResult(false);
			}
		}
		
		/*private function onPermissionEvent(e:PermissionEvent):void 
		{
			(e.target as Camera).removeEventListener(PermissionEvent.PERMISSION_STATUS, onPermissionEvent);
			
			if (e.status == PermissionStatus.GRANTED || e.status == PermissionStatus.ONLY_WHEN_IN_USE)
			{
				dispatchResult(true);
			}
			else
			{
				dispatchResult(false);
			}
		}*/
	}
}