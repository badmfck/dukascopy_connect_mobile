package com.dukascopy.connect.gui.input 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ViewContainer extends Sprite
	{
		public var target:Object;
		
		public function ViewContainer(target:Object = null) 
		{
			this.target = target;
		}
	}
}