package com.dukascopy.connect.sys.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LinkPreviewTask 
	{
		private var message:ChatMessageVO;
		
		public function LinkPreviewTask(message:ChatMessageVO) 
		{
			this.message = message;
		}
		
		public function execute(securityKey:String):void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				message.decrypt(securityKey);
				if (message.text != null && message.text != "" && message.typeEnum != ChatSystemMsgVO.TYPE_LINK_PREVIEW)
				{
					NativeExtensionController.detectLink(message.text, message.id);
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
	}
}