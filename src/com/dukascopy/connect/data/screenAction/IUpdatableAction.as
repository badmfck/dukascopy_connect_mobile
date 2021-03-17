package com.dukascopy.connect.data.screenAction 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IUpdatableAction extends IScreenAction
	{
		function get enable():Boolean;
		function get currentTime():int;
	}
}