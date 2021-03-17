package com.dukascopy.connect.data.screenAction.customActions.chatMessageAction {
	
	import assets.CopyClipboardIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.contactsManager.ContactsManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CopyMessageAction extends ScreenAction implements IScreenAction {
		
		private var msgVO:ChatMessageVO;
		
		public function CopyMessageAction(msgVO:ChatMessageVO) {
			this.msgVO = msgVO;
			setIconClass(CopyClipboardIcon);
			setData(Lang.textCopy);
		}
		
		public function execute():void {
			if (msgVO.text != null)
			{
				if (ChatManager.getCurrentChat() != null && msgVO.linksArray != null && msgVO.linksArray.length > 0)
				{
					if (ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL || ChatManager.getCurrentChat().type == ChatRoomType.QUESTION)
					{
						var user:PhonebookUserVO = PhonebookManager.getUserModelByUserUID(msgVO.userUID);
						if (user == null)
						{
							var result:String = msgVO.text;
							for (var i:int = 0; i < msgVO.linksArray.length; i++) 
							{
								if (isBadLink(msgVO.linksArray[i].shortLink))
								{
									result = result.replace(msgVO.linksArray[i].shortLink, "");
								}
							}
							Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, result);
							
							return;
						}
					}
				}
				
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, msgVO.text);
			}
		}
		
		private function isBadLink(url:String):Boolean 
		{
			var isBad:Boolean = true;
			if (url != null)
			{
				if (url.indexOf(".dukascopy.com") != -1 ||
					url.indexOf(".dukascopy.ch") != -1 ||
					url.indexOf(".dukascopy.asia") != -1 ||
					url.indexOf(".dukascopy.asia") != -1 ||
					url.indexOf("crazy911.com") != -1)
				{
					isBad = false;
				}
			}
			return isBad;
		}
		
		override public function dispose():void {
			super.dispose();
			msgVO = null;
		}
	}
}