package com.dukascopy.connect.screens.dialogs.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapToggleSwitch;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Toggle extends Sprite
	{
		private var toggler:BitmapToggleSwitch;
		private var onChange:Function;
		
		public function Toggle(onChange:Function) 
		{
			this.onChange = onChange;
			
			toggler = new BitmapToggleSwitch();
			toggler.setDownScale(1);
			toggler.setDownColor(0x000000);
			toggler.setOverflow(5, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, 5);
			toggler.show(0);
			
			var icon:Sprite = new SWFToggleBg2();
			UI.colorize(icon, Style.color(Style.TOGGLER_UNSELECTED));
			
			var	TOGGLERBG_BMD:ImageBitmapData = UI.renderAssetExtended(icon, Config.FINGER_SIZE * 0.60, Config.FINGER_SIZE * .4, true, "OptionSwitcher.TOGGLERBG_BMD");
			var TOGGLER_BMD:ImageBitmapData = UI.renderAssetExtended(new SWFToggler2(), Config.FINGER_SIZE * .55, Config.FINGER_SIZE * .55, true, "OptionSwitcher.TOGGLER_BMD");
			toggler.setDesignBitmapDatas(TOGGLERBG_BMD, TOGGLER_BMD, true);
			toggler.setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .2);
			toggler.isSelected = false;
			toggler.tapCallback = onTogglerTap;
			toggler.disposeBitmapOnDestroy = false;
			addChild(toggler);
		}
		
		private function onTogglerTap():void {
			if (onChange != null)
			{
				onChange();
			}
		}
		
		public function activate():void
		{
			toggler.activate();
		}
		
		public function deactivate():void
		{
			toggler.deactivate();
		}
		
		public function dispose():void
		{
			onChange = null;
			
			if (toggler != null)
			{
				toggler.dispose();
				toggler = null;
			}
		}
		
		public function isSelected():Boolean 
		{
			if (toggler != null)
			{
				return toggler.isSelected;
			}
			return false;
		}
		
		public function getWidth():int 
		{
			if (toggler != null)
			{
				return toggler.width;
			}
			return 0;
		}
		
		public function getHeight():int 
		{
			if (toggler != null)
			{
				return toggler.height;
			}
			return 0;
		}
	}
}