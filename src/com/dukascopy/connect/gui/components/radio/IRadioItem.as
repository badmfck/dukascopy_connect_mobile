package com.dukascopy.connect.gui.components.radio 
{
	import com.dukascopy.connect.data.SelectorItemData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IRadioItem
	{
		function draw(selectorItemData:SelectorItemData, itemWidth:int):void;
		function activate():void;
		function dispose():void;
		function select():void;
		function unselect():void;
		function getData():SelectorItemData;
		function set y(value:Number):void;
		function set x(value:Number):void;
		function get height():Number;
	}
}