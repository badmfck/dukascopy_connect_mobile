package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.TakePhotoIcon;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.utils.actionsSequence.ActionsSequence;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TakePhotoAction extends ScreenAction implements IScreenAction
	{
		private var changeCoverImageSequence:ActionsSequence;
		public function TakePhotoAction() 
		{
			setIconClass(TakePhotoIcon);
		}
		
		public function execute():void
		{
			changeCoverImageSequence = new ActionsSequence(onCoverChangeSuccess, onCoverChangeFail);
			
			var selectImageAction:IAction = new TakeUploadPhotoAction();
			var previewImageAction:IAction = new CropImageAction(0, 0, 0.76);
			var uploadAction:IAction = new UploadPublicImageAction(1600, 1600);
			
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
		
		override public function dispose():void
		{
			super.dispose();
			if (changeCoverImageSequence != null)
			{
				changeCoverImageSequence.dispose();
				changeCoverImageSequence = null;
			}
		}
	}
}