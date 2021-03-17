package com.dukascopy.connect.data.screenAction 
{
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IAction 
	{
		function execute():void;
		function dispose():void;
		function setData(value:Object):void;
		function getData():Object;
		
		function setAdditionalData(value:Object):void;
		function getAdditionalData():Object;
		
		function getSuccessSignal():Signal;
		function getFailSignal():Signal;
	}
}