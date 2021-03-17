package com.dukascopy.connect.screens.roadMap.actions 
{
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StartRTOAction extends BaseAction implements IAction 
	{
		
		public function StartRTOAction() 
		{
			if (S_ACTION_SUCCESS)
				S_ACTION_SUCCESS.dispose();
			S_ACTION_SUCCESS = null;
			if (S_ACTION_FAIL)
				S_ACTION_FAIL.dispose();
			S_ACTION_FAIL = null;
		}
		
		public function execute():void 
		{
			PayAPIManager.openSwissRTO();
		}
	}
}