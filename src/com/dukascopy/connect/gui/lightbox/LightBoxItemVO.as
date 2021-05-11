package com.dukascopy.connect.gui.lightbox 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	/**
	 * Stores data for Lightbox Item To Display
	 * @author Alexey
	 */
	public class LightBoxItemVO 
	{
		public var URL:String = "";
		public var crypt:Boolean = false;
		public var name:String = "";
		public var okCallback:Function;
		public var cancelCallback:Function;
		public var bitmapData:ImageBitmapData;
		public var loaded:Boolean = false;
		public var cryptKey:String;
		public var previewURL:String;
		public var imageActions:Vector.<IScreenAction>;
		public var disposed:Boolean = false;
		
		public function LightBoxItemVO() {}		
		
		public function reset():void
		{	 
			URL = "";
			crypt = false;
			name = "";
			okCallback = null;
			cancelCallback = null;	
			bitmapData = null;
			loaded = false;
			
			if (imageActions)
			{
				for (var i:int = 0; i < imageActions.length; i++) 
				{
					imageActions[i].dispose();
				}
			}
			imageActions = null;
		}
	}
}