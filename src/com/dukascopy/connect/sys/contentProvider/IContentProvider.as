package com.dukascopy.connect.sys.contentProvider 
{
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public interface IContentProvider 
	{
		function setData(value:Object):void
		function get S_COMPLETE():Signal;
		function get S_ERROR():Signal;
		function getResult():Array;
		function dispose():void;
		function execute():void;
	}
}