package com.dukascopy.connect.data.screenAction.customActions.chatMessageAction {
	
	import assets.EditIcon;
	import assets.ReduseIcon;
	import com.dukascopy.connect.data.ListRenderInfo;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class MinimizeMessageAction extends ScreenAction implements IScreenAction {
		
		private var msgVO:ChatMessageVO;
		private var list:List;
		
		public function MinimizeMessageAction(msgVO:ChatMessageVO, list:List) {
			this.msgVO = msgVO;
			this.list = list;
			setIconClass(ReduseIcon);
			setData(Lang.reduceText);
		}
		
		public function execute():void {
			if (list != null && msgVO != null)
			{
				if (msgVO.renderInfo == null)
				{
					msgVO.renderInfo = new ListRenderInfo();							
				}
				msgVO.renderInfo.renderInforenderBigFont = !msgVO.renderInfo.renderInforenderBigFont;
				
				list.refresh(true);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			msgVO = null;
			list = null;
		}
	}
}