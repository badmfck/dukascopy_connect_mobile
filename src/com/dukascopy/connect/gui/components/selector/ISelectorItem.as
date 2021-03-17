package com.dukascopy.connect.gui.components.selector 
{
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface ISelectorItem 
	{
		function render(data:SelectorItemData, select:Boolean = false):ImageBitmapData;
	}
}