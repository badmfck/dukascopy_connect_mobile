package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.AttachImageIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.utils.FilesSaveUtility;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OpenImageAction extends ScreenAction implements IScreenAction
	{
		private var url:String;
		
		public function OpenImageAction(url:String) 
		{
			this.url = url;
			setIconClass(AttachImageIcon);
		}
		
		public function execute():void
		{
			if (FilesSaveUtility.getIsFileExists(url))
			{
				FilesSaveUtility.openGalleryIfFileExists(url);
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}