package com.dukascopy.connect.gui.list.renderers 
{
	import assets.NewCloseIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import flash.display.IBitmapDrawable;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ListCountryExclude extends ListCountrySimple
	{
		private var icon:NewCloseIcon;
		private var iconSize:int;
		
		public function ListCountryExclude() 
		{
			super();
			
			createIcon();
		}
		
		private function createIcon():void 
		{
			icon = new NewCloseIcon();
			addChild(icon);
			iconSize = Config.FINGER_SIZE * .3;
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.colorize(icon, Color.RED);
		}
		
		override public function getHeight(data:ListItem, width:int):int {
			var countryData:Object;
			if (data.data is SelectorItemData)
			{
				countryData = (data.data as SelectorItemData).data;
			}
			if (countryData != null && countryData.length == 2)
				return Config.FINGER_SIZE_DOT_75;
			return itemHeight;
		}
		
		override public function getView(li:ListItem, h:int, width:int,highlight:Boolean = false):IBitmapDrawable {
			var countryData:Object;
			if (li.data is SelectorItemData)
			{
				countryData = (li.data as SelectorItemData).data;
				
				icon.visible = false;
				
				if (countryData.length == 2) {
					tfCountry.textColor = Color.RED_DARK;
					tfCountry.text = countryData[1];
					tfCountry.width = width - padding * 2;
					tfCountry.alpha = 1;
				} else {
					graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
					graphics.drawRect(0, h - 1, width, 1);
					graphics.endFill();
					tfCountry.textColor = Style.color(Style.COLOR_TEXT);
					tfCountry.text = countryData[4];
					tfCountry.width = width - tfCountry.x - padding;
					if ((li.data as SelectorItemData).selected)
					{
						icon.visible = true;
					}
				}
				
				tfCountry.y = Math.round((h - tfCountry.textHeight) * .5);
				icon.y = Math.round((h - icon.height) * .5);
				icon.x = int(width - icon.width - Config.DIALOG_MARGIN);
			}
			else
			{
				icon.visible = false;
				tfCountry.text = "";
			}
			
			return this;
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
		}
	}
}