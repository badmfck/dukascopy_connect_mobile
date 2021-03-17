package com.dukascopy.connect.gui.button {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class SimpleButton extends BitmapButton {
		private var label:String;
		public function SimpleButton(label:String="BUTTON",callBack:Function=null) {
			this.label = label;
			setStandartButtonParams();	
			usePreventOnDown = false;
			cancelOnVerticalMovement = true;
			tapCallback = callBack;	
			//var overflow:int = Config.FINGER_SIZE * 2;
			//setOverflow(overflow,overflow,overflow,overflow);
		}
		
		public function setSize(w:int, h:int = -1):void {
			if (h < 1)
				h = Config.FINGER_SIZE;
			setBitmapData(UI.renderButtonOld(label, w, h,0xffffff, 0xee4131, 0xd23a2c, Config.FINGER_SIZE * .3),true);
		}
		
	}

}