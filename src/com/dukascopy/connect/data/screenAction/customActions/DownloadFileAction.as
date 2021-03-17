package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.dialogs.newDialogs.FileDownloadPopup;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.vo.chat.FileMessageVO;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class DownloadFileAction extends ScreenAction implements IScreenAction {
		
		private var url:URLRequest;
		private var fileData:FileMessageVO;
		
		public function DownloadFileAction(url:URLRequest, fileData:FileMessageVO) {
			this.url = url;
			this.fileData = fileData;
			setIconClass(Style.icon(Style.ICON_FILE));
		}
		
		public function execute():void {
			if (Config.PLATFORM_ANDROID == true || Config.PLATFORM_WINDOWS == true) {
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, FileDownloadPopup, 
					{
						fileData:fileData,
						request:(url)
					}
				);
			} else if (Config.PLATFORM_APPLE == true) {
				navigateToURL(url);
			}
			dispose();
		}
		
		override public function dispose():void {
			fileData = null;
			super.dispose();
		}
	}
}