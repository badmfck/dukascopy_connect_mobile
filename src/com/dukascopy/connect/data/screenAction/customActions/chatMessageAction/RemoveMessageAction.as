package com.dukascopy.connect.data.screenAction.customActions.chatMessageAction 
{
	import assets.DeleteIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RemoveMessageAction extends ScreenAction implements IScreenAction
	{
		private var msgVO:ChatMessageVO;
		
		public function RemoveMessageAction(msgVO:ChatMessageVO) {
			this.msgVO = msgVO;
			setIconClass(DeleteIcon);
			setData(Lang.textRemove);
		}
		
		public function execute():void {
			DialogManager.alert(Lang.textConfirm, Lang.alertConformDeleteMessage, onDialogResponse, Lang.textDelete.toUpperCase(), Lang.textCancel);
		}
		
		private function onDialogResponse(val:int):void {
			if (val != 1)
				return;
			ChatManager.removeMessage(msgVO);
			msgVO = null;
			LightBox.close();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}