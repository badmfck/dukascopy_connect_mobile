package com.dukascopy.connect.gui.input 
{
	import assets.ClearTextIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InputWithClearButton extends Input
	{
		private var buttonClear:BitmapButton;
		
		public function InputWithClearButton() 
		{
			buttonClear = new BitmapButton();
			buttonClear.setStandartButtonParams();
			buttonClear.setDownScale(1);
			buttonClear.setDownColor(0xFFFFFF);
			buttonClear.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);
			buttonClear.tapCallback = onClearTextTap;
			buttonClear.disposeBitmapOnDestroy = true;
			buttonClear.show();
			
			super();
		}
		
		private function onClearTextTap():void 
		{
			value = "";
			onFocusOut();
			S_CHANGED.invoke();
		}
		
		override public function activate():void {
			super.activate();
			buttonClear.activate();
		}
		
		override public function deactivate():void {
			super.deactivate();
			buttonClear.deactivate();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (buttonClear)
			{
				buttonClear.dispose();
				buttonClear = null;
			}
		}
		
		override protected function drawView():void {
			
			super.drawView();
			
			if (!_view.contains(buttonClear))
			{
				_view.addChild(buttonClear);
			}
			
			var icon:ClearTextIcon = new ClearTextIcon();
			icon.height = int(_height * .5);
			icon.width = int(_height * .5);
			buttonClear.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "InputWithClearButton.icon"));
			UI.destroy(icon);
			icon = null;
			
			var iboxPadd:int = 0;
			if (infoBox != null)
				iboxPadd = infoBoxSrc.width + padding * .5;
			
			var buttonPadding:int = _height * .5 - buttonClear.height * .5;
				
			textField.width = _width - padding * 2 - iboxPadd - buttonClear.width - buttonPadding;
			buttonClear.x = int(width - buttonClear.width - buttonPadding);
			buttonClear.y = buttonPadding;
		}
	}

}