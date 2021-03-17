package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.AttachImageIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.style.Style;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenGalleryAction extends ScreenAction implements IScreenAction {
		
		public function OpenGalleryAction() {
			setIconClass(Style.icon(Style.ICON_ATTACH_GALLERY));
		}
		
		public function execute():void {
			PhotoGaleryManager.takeImage(false, true);
			dispose();
		}
	}
}