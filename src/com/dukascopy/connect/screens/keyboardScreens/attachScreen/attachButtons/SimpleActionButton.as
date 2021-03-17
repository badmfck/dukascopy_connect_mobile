package com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.type.HitZoneType;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SimpleActionButton extends AttachScreenButtonLabel
	{
		public var callback:Function;
		
		public function SimpleActionButton(action:IScreenAction) 
		{
			super(action);
			buttonClip.setOverlay(HitZoneType.CIRCLE);
			buttonClip.setOverlayPadding(Config.FINGER_SIZE * .6);
		}
		
		override protected function onClick():void {
			if (callback != null)
			{
				callback(action);
			}
		}
		
		override public function deactivate():void {
		//	alpha = 0.4;
			/*if (buttonClip)
				buttonClip.deactivate();*/
		}
		
		override protected function getAdditionalContentHeight():int {
			return 0;//int(labelClip.height + Config.FINGER_SIZE* .1);
		}
		
		override public function dispose():void
		{
			if (labelClip)
				UI.destroy(labelClip);
			labelClip = null;
			if (buttonClip)
				buttonClip.dispose();
			buttonClip = null;
			
			callback = null;
		}
	}
}