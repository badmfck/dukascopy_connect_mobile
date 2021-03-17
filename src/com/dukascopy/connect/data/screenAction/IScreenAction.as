package com.dukascopy.connect.data.screenAction 
{
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IScreenAction extends IAction
	{
		function getIconClass():Class;
		function setIconClass(iconClass:Class):void;
		function getIconScale():Number;
		function getIconColor():Number;
	}
}