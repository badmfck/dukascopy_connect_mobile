package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IBotAction 
	{
		function getResult():Vector.<ImageBitmapData>;
		function getData():String;
		function getAction():VIAction;
		function execute(onSuccess:Function, onFail:Function):void;
		function dispose():void;
	}
}