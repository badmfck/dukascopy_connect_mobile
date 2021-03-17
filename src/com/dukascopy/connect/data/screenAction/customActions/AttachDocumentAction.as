package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.AttachImageIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.style.Style;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AttachDocumentAction extends ScreenAction implements IScreenAction {
		
		private var chatUID:String;
		
		public function AttachDocumentAction(chatUID:String) {
			this.chatUID = chatUID;
			setIconClass(Style.icon(Style.ICON_ATTACH_FILE));
		}
		
		public function execute():void {
			NativeExtensionController.pickFile(chatUID);
			dispose();
		}
	}
}