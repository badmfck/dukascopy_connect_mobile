package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class PreviewMessagesAction extends ScreenAction implements IScreenAction {
		
		public function PreviewMessagesAction() {
			setIconClass(null);
		}
		
		public function execute():void {
			S_ACTION_SUCCESS.invoke();
		}
	}
}