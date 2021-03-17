package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IBotSystemAction 
	{
		function getAction():RemoteMessage;
		function execute(onSuccess:Function, onFail:Function):void;
	}
	
}