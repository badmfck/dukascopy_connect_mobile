package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class AddVideoAction extends BaseSystemAction implements IBotSystemAction
	{
		private var targetScreen:BaseScreen;
		
		public function AddVideoAction(action:RemoteMessage, targetScreen:BaseScreen) 
		{
			this.targetScreen = targetScreen;
			this.action = action;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void 
		{
			if (targetScreen != null && (targetScreen as Object).hasOwnProperty("addVideo"))
			{
				(targetScreen as Object).addVideo();
			}
			
			dispatchResult(true);
		}
	}
}