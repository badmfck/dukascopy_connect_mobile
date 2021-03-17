package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	import flash.events.PermissionEvent;
	import flash.media.Camera;
	import flash.permissions.PermissionStatus;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CheckVideoPermissionAction extends BaseSystemAction implements IBotSystemAction 
	{
		public function CheckVideoPermissionAction(action:RemoteMessage) 
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
					dispatchResult(false);
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
	}
}