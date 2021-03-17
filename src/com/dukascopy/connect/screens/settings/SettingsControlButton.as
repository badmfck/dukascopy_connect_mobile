package com.dukascopy.connect.screens.settings 
{
	import com.dukascopy.connect.data.settings.SettingsControlData;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SettingsControlButton extends BitmapButton
	{
		public var data:SettingsControlData;
		
		public function SettingsControlButton(data:SettingsControlData) 
		{
			this.data = data;
			
			super();
			usePreventOnDown = false;
			setDownScale(1);
			setDownColor(NaN);
			setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
			
			callbackParam = data;
		}
		
		override public function dispose():void
		{
			data = null;
			super.dispose();
		}
	}
}