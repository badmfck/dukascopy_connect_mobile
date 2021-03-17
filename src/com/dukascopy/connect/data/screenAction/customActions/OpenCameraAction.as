package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.AttachCamIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.sys.style.Style;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OpenCameraAction extends ScreenAction implements IScreenAction
	{
		public function OpenCameraAction() 
		{
			setIconClass(Style.icon(Style.ICON_ATTACH_CAMERA));
		}
		
		public function execute():void
		{
			ChatInputAndroid.S_ATTACH.invoke(ChatInputAndroid.ATTACH_CAMERA);
			dispose();
		}
	}
}