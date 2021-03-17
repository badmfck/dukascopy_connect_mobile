package com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.IUpdatableAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class HorizontalActionButton extends AttachScreenButtonLabel
	{
		private var itemWidth:int;
		public var callback:Function;
		
		public function HorizontalActionButton(action:IScreenAction, itemWidth:int) 
		{
			this.itemWidth = itemWidth;
			super(action);
			buttonClip.setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
			buttonClip.setDownAlpha(0);
		}
		
		override protected function onClick():void {
			if (callback != null)
			{
				callback(action);
			}
		}
		
		override public function draw():void {
			
			var itemHeight:int = Config.FINGER_SIZE;
			var bitmap:ImageBitmapData = new ImageBitmapData("contextBottomButton", itemWidth, itemHeight);
			
			var icon:MovieClip;
			if (buttonClip && action && action.getIconClass() != null) {
				
				var labelText:String = "";
				if (action && action.getData() != null)
					labelText = (action.getData() as String);
				
				if (action is IUpdatableAction)
				{
					if ((action as IUpdatableAction).enable == true)
					{
						buttonClip.alpha = 1;
					}
					else
					{
						labelText += " (" + (action as IUpdatableAction).currentTime + ")";
						buttonClip.alpha = 0.5;
					}
				}
				
				icon = new (action.getIconClass())();
				UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
				UI.scaleToFit(icon, Config.FINGER_SIZE * .36, Config.FINGER_SIZE * .36);
				var iconBD:ImageBitmapData = UI.getSnapshot(icon);
				bitmap.copyPixels(iconBD, iconBD.rect, new Point(int(Config.FINGER_SIZE * .4), int(itemHeight * .5 - iconBD.height * .5)));
				
				var textBD:ImageBitmapData = UI.renderText(labelText, itemWidth, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
														Config.FINGER_SIZE * .28, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND));
				bitmap.copyPixels(textBD, textBD.rect, new Point(int(Config.FINGER_SIZE), int(itemHeight * .5 - textBD.height * .5)));
				
				var lineBD:ImageBitmapData = new ImageBitmapData("line", itemWidth, 1, false, Style.color(Style.COLOR_SEPARATOR));
				bitmap.copyPixels(lineBD, lineBD.rect, new Point(0, itemHeight - 1));
				
				buttonClip.setBitmapData(bitmap, true);
				
				iconBD.dispose();
				iconBD = null;
				
				textBD.dispose();
				textBD = null;
				
				lineBD.dispose();
				lineBD = null;
			}
		}
		
		override public function deactivate():void {
		//	alpha = 0.4;
			/*if (buttonClip)
				buttonClip.deactivate();*/
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
		
		public function update():void 
		{
			draw();
		}
		
		public function getAction():IScreenAction 
		{
			return action;
		}
	}
}