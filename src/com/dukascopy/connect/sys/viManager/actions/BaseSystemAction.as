package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BaseSystemAction 
	{
		protected var action:RemoteMessage;
		protected var onSuccess:Function;
		protected var onFail:Function;
		
		public function BaseSystemAction() 
		{
			
		}
		
		protected function dispatchResult(success:Boolean):void 
		{
			if (success == true)
			{
				if (onSuccess != null)
				{
					onSuccess(this);
				}
			}
			else
			{
				if (onFail != null)
				{
					onFail(this);
				}
			}
		}
		
		public function getAction():RemoteMessage 
		{
			return action;
		}
	}
}