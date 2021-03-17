package com.dukascopy.connect.sys.applicationShop.serverTask 
{
	import com.dukascopy.connect.data.screenAction.IAction;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IServerTask extends IAction
	{
		function getStatus():String;
	}
}