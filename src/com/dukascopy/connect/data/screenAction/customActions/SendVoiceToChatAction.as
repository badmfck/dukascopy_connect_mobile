package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.RemoteSoundFileData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.errors.ApplicationError;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SendVoiceToChatAction extends ScreenAction implements IScreenAction
	{
		public function SendVoiceToChatAction() 
		{
			
		}
		
		public function execute():void
		{
			if (data && (data is RemoteSoundFileData))
			{
				var fileData:Object = new Object();
				
				fileData.uid = (data as RemoteSoundFileData).id;
				fileData.duration = (data as RemoteSoundFileData).duration;
				
				var messageObject:Object = new Object();
				messageObject.title = "voice";
				messageObject.additionalData = fileData;
				messageObject.type = "voice";
				messageObject.method = "voiceSent";
				
				ChatManager.sendMessage(Config.BOUNDS + JSON.stringify(messageObject));
			}
			else
			{
				throw new ApplicationError(ApplicationError.SEND_VOICE_ACTION_WRONG_DATA);
			}
			dispose();
		}
	}
}