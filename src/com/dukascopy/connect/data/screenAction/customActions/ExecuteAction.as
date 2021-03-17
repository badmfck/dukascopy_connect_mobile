package com.dukascopy.connect.data.screenAction.customActions
{
	import assets.IconGroupChat;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.chat.SelectContactsScreen;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ExecuteAction extends ScreenAction implements IScreenAction
	{
		public function ExecuteAction()
		{
			setIconClass(null);
		}
		
		public function execute():void
		{
			if (getSuccessSignal() != null)
			{
				getSuccessSignal().invoke();
			}
		}
	}
}