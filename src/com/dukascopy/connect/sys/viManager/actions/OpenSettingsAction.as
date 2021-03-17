package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OpenSettingsAction extends BaseSystemAction implements IBotSystemAction
	{
		private var targetScreen:BaseScreen;
		
		public function OpenSettingsAction(action:RemoteMessage, targetScreen:BaseScreen) 
		{
			this.targetScreen = targetScreen;
			this.action = action;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void 
		{
			NativeExtensionController.openSettings();
			
			dispatchResult(true);
		}
	}
}