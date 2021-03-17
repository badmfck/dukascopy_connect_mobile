package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.DeleteIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RemoveImageAction extends ScreenAction implements IScreenAction
	{
		private var msgVO:ChatMessageVO
		;
		public function RemoveImageAction(msgVO:ChatMessageVO) 
		{
			this.msgVO = msgVO;
			setIconClass(DeleteIcon);
		}
		
		public function execute():void
		{
			ChatManager.removeMessage(msgVO);
			
			if (LightBox.isShowing)
			{
				LightBox.isShowing = false;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			msgVO = null;
		}
	}
}