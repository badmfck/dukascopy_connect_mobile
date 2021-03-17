package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageUploader;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.vo.ChatVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CreatePuzzleAction extends ScreenAction implements IScreenAction
	{
		public function CreatePuzzleAction() 
		{
			setIconClass(Style.icon(Style.ICON_ATTACH_PUZZLE));
		}
		
		public function execute():void
		{
			DialogManager.showAddPuzzle(callBackAddInvoice);
		}
		
		private function callBackAddInvoice(i:int, paramsObj:Object):void {
			
			if (paramsObj != null)
			{
				if (i == 1)
				{
					// generate puzzle 
					var puzzleObj:Object = {};
					puzzleObj.amount = paramsObj.amount;
					puzzleObj.currency = paramsObj.currency;
					puzzleObj.isPaid = false;
					
					var chat:ChatVO = ChatManager.getChatByUID(paramsObj.chatUID);
					if (chat != null)
					{
						ImageUploader.uploadChatImage(paramsObj.image, paramsObj.chatUID, "Puzzle", chat.getImageString(), "", puzzleObj);
					}
				}
				else
				{
					if (paramsObj.image != null && paramsObj.image is ImageBitmapData)
					{
						(paramsObj.image as ImageBitmapData).dispose();
						paramsObj.image = null;
					}
				}
			}
		}
	}
}