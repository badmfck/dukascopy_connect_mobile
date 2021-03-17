package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.AttachPayIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.style.Style;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class SendMoneyAction extends ScreenAction implements IScreenAction {
		
		public function SendMoneyAction() {
			setIconClass(Style.icon(Style.ICON_ATTACH_MONEY));
		}
		
		public function execute():void {
			if (Config.PLATFORM_ANDROID == true)
			{
				ChatInputAndroid.S_CLOSE_MEDIA_KEYBOARD.invoke();
			}
			Gifts.startSendMoney();
		}
	}
}