package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.AttachVoiceIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ComposeVoiceMessageAction extends ScreenAction implements IScreenAction
	{
		
		public function ComposeVoiceMessageAction()
		{
			setIconClass(AttachVoiceIcon);
		}
		
		public function execute():void
		{
			ChatInputAndroid.S_ATTACH.invoke(ChatInputAndroid.ATTACH_VOICE_MESSAGE);
			dispose();
		}
	}
}