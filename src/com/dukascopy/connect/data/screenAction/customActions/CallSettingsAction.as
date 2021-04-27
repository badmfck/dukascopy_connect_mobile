package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CallSettingsAction extends ScreenAction implements IScreenAction
	{
		public function CallSettingsAction() 
		{
		//	setIconClass(IconInfoClip);
		}
		
		public function execute():void
		{
			NativeExtensionController.openSettings();
		}
	}
}