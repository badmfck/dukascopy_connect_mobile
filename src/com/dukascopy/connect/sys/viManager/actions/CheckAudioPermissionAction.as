package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	import flash.media.Microphone;
	import flash.permissions.PermissionStatus;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CheckAudioPermissionAction extends BaseSystemAction implements IBotSystemAction 
	{
		public function CheckAudioPermissionAction(action:RemoteMessage) 
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