package com.dukascopy.connect.data.screenAction.customActions.chatMessageAction {
	
	import assets.EditIcon;
	import assets.ReduseIcon;
	import assets.ReplyIcon;
	import com.dukascopy.connect.data.ListRenderInfo;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ReplyMessageAction extends ScreenAction implements IScreenAction {
		
		private var item:ChatMessageVO;
		private var callback:Function;
		
		public function ReplyMessageAction(item:ChatMessageVO, callback:Function) {
			this.item = item;
			this.callback = callback;
			setIconClass(ReplyIcon);
			setData(Lang.reply);
		}
		
		public function execute():void {
			if (callback != null)
			{
				callback(item);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			callback = null;
			item = null;
		}
	}
}