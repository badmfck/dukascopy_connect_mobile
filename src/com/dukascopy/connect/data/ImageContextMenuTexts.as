package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.type.ImageContextMenuType;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author ...
	 */
	public class ImageContextMenuTexts 
	{
		
		public function ImageContextMenuTexts() 
		{
			
		}
		
		static public function getText(value:int):String 
		{
			switch(value)
			{
				case ImageContextMenuType.FORWARD:
				{
					return Lang.textForward;
					break;
				}
				case ImageContextMenuType.SAVE:
				{
					return Lang.saveImage;
					break;
				}
				case ImageContextMenuType.OPEN:
				{
					return Lang.openInGallery;
					break;
				}
				case ImageContextMenuType.OPEN_FX_PROFILE:
				{
					return Lang.openProfile;
					break;
				}
				case ImageContextMenuType.REMOVE_MESSAGE:
				{
					return Lang.textRemove;
					break;
				}
			}
			return "";
		}
	}
}