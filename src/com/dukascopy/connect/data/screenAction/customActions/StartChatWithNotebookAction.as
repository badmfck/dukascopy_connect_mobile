package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class StartChatWithNotebookAction extends StartChatWithUidAction implements IScreenAction {
		public function StartChatWithNotebookAction() {
			super();
		}
		
		override public function getData():Object
		{
			var result:String = "(" + Lang.notebookName + ") ";
			if (Auth.myProfile != null)
			{
				result += Auth.myProfile.getDisplayName();
			}
			return result;
		}
	}
}