package com.dukascopy.connect.gui.topBar.x.controller 
{
	import com.dukascopy.connect.gui.topBar.x.TopBar;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IBarController 
	{
		function setView(view:TopBar):void;
		function dispose():void;
		function update():void;
		function onBack():void;
	}
}