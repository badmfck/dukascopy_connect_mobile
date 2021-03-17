package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.AttachImageIcon;
	import assets.galleryIcon;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.utils.actionsSequence.ActionsSequence;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class TakeGalleryAction extends ScreenAction implements IScreenAction {
		
		public function TakeGalleryAction() {
			setIconClass(galleryIcon);
		}
		
		public function execute():void
		{
			var changeCoverImageSequence:ActionsSequence = new ActionsSequence(onCoverChangeSuccess, onCoverChangeFail);
			
			var selectImageAction:IAction = new TakeUploadGalleryAction();
			var previewImageAction:IAction = new CropImageAction(0, 0, 0.76);
			var uploadAction:IAction = new UploadPublicImageAction();
			
			changeCoverImageSequence.addAction(selectImageAction);
			changeCoverImageSequence.addAction(previewImageAction);
			changeCoverImageSequence.addAction(uploadAction);
			
			changeCoverImageSequence.execute();
		}
		
		private function onCoverChangeFail(data:Object = null):void 
		{
			getFailSignal().invoke(data);
		}
		
		private function onCoverChangeSuccess(data:Object):void 
		{
			getSuccessSignal().invoke(data);
		}
	}
}