package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.langs.Lang;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class UpdateChannelSettingsAction extends ScreenAction implements IScreenAction {
		
		private var channelUID:String;
		private var settingName:String;
		
		public function UpdateChannelSettingsAction(channelUID:String, settingName:String) {
			this.channelUID = channelUID;
			this.settingName = settingName;
			setIconClass(null);
		}
		
		public function execute():void {
			PHP.irc_updateSetting(onServerResponse, channelUID, settingName, (getData() as String));
		}
		
		private function onServerResponse(phpRespond:PHPRespond):void {
			if (disposed) {
				phpRespond.dispose();
				return;
			}
			if (phpRespond.error) {
				var message:String;
				if (phpRespond.errorMsg == PHP.NETWORK_ERROR) {
					message = Lang.alertProvideInternetConnection;
				} else {
					message = Lang.textWarning + " " + phpRespond.errorMsg;
				}
				S_ACTION_FAIL.invoke(message);
			} else {
				S_ACTION_SUCCESS.invoke(getData());
			}
			phpRespond.dispose();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}