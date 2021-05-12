package com.dukascopy.connect.data.screenAction.customActions{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	
	public class CallSettingsAction extends ScreenAction implements IScreenAction{
		public function CallSettingsAction(){
		}
		
		public function execute():void{
			NativeExtensionController.openSettings();
		}
	}
}