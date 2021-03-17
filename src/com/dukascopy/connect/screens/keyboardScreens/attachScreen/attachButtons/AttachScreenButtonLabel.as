package com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.AttachScreenButton;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AttachScreenButtonLabel extends AttachScreenButton {
		
		protected var labelClip:Bitmap;
		
		public function AttachScreenButtonLabel(action:IScreenAction) {
			super(action);
		}	
		
		override protected function create():void {
			super.create();
			
			labelClip = new Bitmap();
			addChild(labelClip);
		}
		
		override public function draw():void {
			var labelText:String = "";
			if (action && action.getData() != null)
				labelText = (action.getData() as String);
			labelClip.bitmapData = UI.renderText(labelText, mainWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .27, 
													true, Style.color(Style.COLOR_TITLE), 
													Style.color(Style.COLOR_BACKGROUND));
			
			super.draw();
			
			labelClip.y = buttonClip.y + buttonClip.height + Config.MARGIN * .3;
			labelClip.x = int(mainWidth * .5 - labelClip.width * .5);
		}
		
		override protected function getAdditionalContentHeight():int {
			return int(labelClip.height + Config.MARGIN * .5);
		}
		
		override public function dispose():void {
			super.dispose();
			if (labelClip)
				UI.destroy(labelClip);
			labelClip = null;
		}
		
		override public function show(_time:Number = 0, _delay:Number = 0, overrideAnimation:Boolean = true):void {
			if (buttonClip != null)
				buttonClip.show(_time, _delay, overrideAnimation);
		}
	}
}