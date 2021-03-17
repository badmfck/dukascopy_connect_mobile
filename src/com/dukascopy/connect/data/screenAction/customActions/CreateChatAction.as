package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.IconGroupChat;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.chat.SelectContactsScreen;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CreateChatAction extends ScreenAction implements IScreenAction
	{
		public function CreateChatAction() 
		{
			setIconClass(Style.icon(Style.ICON_GROUP_CHAT));
		}
		
		public function execute():void
		{
			MobileGui.changeMainScreen(SelectContactsScreen, {
															title:Lang.startChatWith, 
															data:null}, 
															ScreenManager.DIRECTION_RIGHT_LEFT);
			dispose();
		}
		
		override public function getIconScale():Number { return 26/30; }
	}

}