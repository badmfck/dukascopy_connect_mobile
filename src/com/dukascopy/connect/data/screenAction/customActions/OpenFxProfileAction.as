package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OpenFxProfileAction extends ScreenAction implements IScreenAction
	{
		private var fxName:String;
		
		public function OpenFxProfileAction(fxName:String) 
		{
			setIconClass(IconPerson);
			this.fxName = fxName;
		}
		
		public function execute():void {
			if (fxName != null) {
				var nativeAppExist:Boolean = false;
				if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
					nativeAppExist = MobileGui.androidExtension.launchFXComm("profile", fxName);
				else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
					nativeAppExist = MobileGui.dce.launchFXComm("profile", fxName);
				if (nativeAppExist == false)
					navigateToURL(new URLRequest(Config.URL_FXCOMM_PROFILE + fxName + "&fromdcc=1&mob=1"));
			}
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}