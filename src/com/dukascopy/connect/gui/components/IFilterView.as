package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.data.filter.FilterData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IFilterView extends IDisposable
	{
		function setData(filtersData:Vector.<FilterData>):void;
		function setWidth(value:int):void;
		function activate():void;
		function deactivate():void;
		function update():void;
		function getHeight():int;
		function redraw():Boolean;
		
		function set y(value:Number):void;
		function set x(value:Number):void;
		function set alpha(value:Number):void;
	}
}