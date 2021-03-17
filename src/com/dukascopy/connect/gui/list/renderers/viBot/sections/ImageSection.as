package com.dukascopy.connect.gui.list.renderers.viBot.sections 
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ImageSection 
	{
		private var curentData:BitmapData;
		
		public function ImageSection() 
		{
			
		}
		
		public function setData(value:BitmapData):void
		{
			if (currentData != null)
			{
				currentData.dispose();
			}
			curentData = value;
		}
	}
}