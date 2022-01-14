package com.dukascopy.connect.gui.list.renderers{
	import assets.CloseButtonIconSmall;
	import assets.GeoIcon;
	import assets.HelpIcon3;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.screens.dialogs.geolocation.CityLocationListItem;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.langs.Lang;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ListCityRenderer extends BaseRenderer implements IListRenderer{
		
		private var title:TextField;
		private var format:TextFormat;
		private var format2:TextFormat;
		private var icon:GeoIcon;
		private var maxTitleWidth:int;
		private var itemHeight:int;
		private var clearSelectionIcon:CloseButtonIconSmall;
		private var selectedBack:Sprite;
		private var helpIcon:HelpIcon3;
		private var findText:TextField;
		
		public function ListCityRenderer() {
			
			itemHeight = Config.FINGER_SIZE * 0.9;
			
			selectedBack = new Sprite();
			selectedBack.graphics.beginFill(0xEEEEEE);
			selectedBack.graphics.drawRect(0, 0, 10, 10);
			selectedBack.graphics.endFill();
			addChild(selectedBack);
			
			format = new TextFormat(Config.defaultFontName);
			format.color = 0x545C6A;
			format.size = int(Config.FINGER_SIZE * .3);
			
			format2 = new TextFormat(Config.defaultFontName);
			format2.color = 0x697780;
			format2.size = int(Config.FINGER_SIZE * .25);
			
			icon = new GeoIcon();
			UI.colorize(icon, 0xAAAEB5);
			UI.scaleToFit(icon, Config.FINGER_SIZE * .32, Config.FINGER_SIZE * .32);
			icon.x = Config.DIALOG_MARGIN;
			icon.y = int(itemHeight * .5 - icon.height * .5);
			addChild(icon);
			
			helpIcon = new HelpIcon3();
			UI.scaleToFit(helpIcon, Config.FINGER_SIZE * .26, Config.FINGER_SIZE * .26);
			helpIcon.x = Config.DIALOG_MARGIN;
			helpIcon.y = int(itemHeight * .5 - icon.height * .5);
			addChild(helpIcon);
			
			title = new TextField();
				title.selectable = false;
				title.defaultTextFormat = format;
				title.text = "Pp";
				title.height = title.textHeight + 4;
				title.text = "";
				title.x = int(Config.DIALOG_MARGIN + icon.width + Config.FINGER_SIZE * .2);
				title.y = int(itemHeight * .5 - title.height * .5);
				title.wordWrap = false;
				title.multiline = false;
			addChild(title);
			
			findText = new TextField();
				findText.selectable = false;
				findText.defaultTextFormat = format2;
				findText.text = "Pp";
				findText.height = title.textHeight + 4;
				findText.text = "";
				findText.x = int(Config.DIALOG_MARGIN + icon.width + Config.FINGER_SIZE * .2);
				findText.wordWrap = true;
				findText.multiline = true;
			addChild(findText);
			
			clearSelectionIcon = new CloseButtonIconSmall();
			UI.scaleToFit(clearSelectionIcon, Config.FINGER_SIZE * .25, Config.FINGER_SIZE * .25);
			UI.colorize(clearSelectionIcon, 0x97A6B4);
			addChild(clearSelectionIcon);
			clearSelectionIcon.y = int(itemHeight * .5 - clearSelectionIcon.height * .5);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		protected function setHitZones(item:ListItem):void {
			var hitZones:Vector.<HitZoneData> = new Vector.<HitZoneData>();
			var data:CityLocationListItem = item.data as CityLocationListItem;
			if (data != null && data.myPosition == true && data.city == null)
			{
				var hz:HitZoneData= new HitZoneData();
				hz.type = HitZoneType.GET;
				hz.x = icon.x - Config.MARGIN;
				hz.y = icon.y - Config.MARGIN;
				hz.width = (icon.width + Config.MARGIN * 3 + title.width);
				hz.height = (title.height + Config.MARGIN * 2);
				hitZones.push(hz);
			}
				
			if (hitZones.length > 0)
				item.setHitZones(hitZones);
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			
			var data:CityLocationListItem = li.data as CityLocationListItem;
			
			graphics.clear();
			
			maxTitleWidth = w;
			
			if (data != null)
			{
				if (data.myPosition == true)
				{
					if (data.city == null)
					{
						title.text = Lang.find;
						title.width = Math.min(title.textWidth + 4, w * .45);
						title.x = int(w - title.width - Config.DIALOG_MARGIN);
						icon.x = int(title.x - icon.width - Config.FINGER_SIZE * .06);
						UI.colorize(icon, 0xF1543F);
						helpIcon.visible = true;
						icon.visible = true;
						
						selectedBack.visible = false;
						clearSelectionIcon.visible = false;
						findText.wordWrap = true;
						findText.multiline = true;
						findText.visible = true;
						findText.width = w;
						findText.text = Lang.yourLocation;
						findText.width = Math.min(findText.textWidth + 4, w * .4);
						findText.height = findText.textHeight + 4;
						findText.y = int(h*.5 - findText.height*.5);
					}
					else
					{
						title.x = int(Config.DIALOG_MARGIN + icon.width + Config.FINGER_SIZE * .2);
						icon.x = Config.DIALOG_MARGIN;
						helpIcon.visible = false;
						icon.visible = true;
						
						findText.wordWrap = false;
						findText.multiline = false;
						findText.visible = true;
						findText.width = w;
						findText.text = Lang.yourLocation;
						findText.width = Math.min(findText.textWidth + 4, w - Config.DIALOG_MARGIN - icon.width);
						findText.height = findText.textHeight + 4;
						title.y = int(h * .5 - (title.height + findText.height - Config.FINGER_SIZE * .07) * .5);
						findText.y = int(title.y + title.height - Config.FINGER_SIZE * .07);
					}
				}
				else
				{
					title.y = int(itemHeight * .5 - title.height * .5);
					findText.visible = false;
					helpIcon.visible = false;
					icon.visible = true;
					icon.x = Config.DIALOG_MARGIN;
					title.x = int(Config.DIALOG_MARGIN + icon.width + Config.FINGER_SIZE * .2);
				}
				
				
				if (data.city != null && data.city.cityName != null)
				{
					title.width = w;
					title.text = data.city.cityName;
				}
				title.width = Math.min(title.textWidth + 4, maxTitleWidth);
				
				if (data.selected == true)
				{
					selectedBack.visible = true;
					selectedBack.width = w;
					selectedBack.height = h;
					clearSelectionIcon.visible = true;
					UI.colorize(icon, 0xF1543F);
					clearSelectionIcon.x = int(w - Config.DIALOG_MARGIN - clearSelectionIcon.width);
				}
				else
				{
					if (data.city == null && data.myPosition == true)
					{
						UI.colorize(icon, 0xF1543F);
					}
					else
					{
						UI.colorize(icon, 0xAAAEB5);
					}
					
					selectedBack.visible = false;
					clearSelectionIcon.visible = false;
				}
			}
			else
			{
				clearSelectionIcon.visible = false;
				selectedBack.visible = false;
				findText.text = "";
				findText.visible = false;
				helpIcon.visible = false;
				icon.visible = false;
				title.text = "";
			}
			
			setHitZones(li);
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			if (title != null)
				title.text = "";
			title = null;
			
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			
			if (clearSelectionIcon != null)
			{
				UI.destroy(clearSelectionIcon);
				clearSelectionIcon = null;
			}
			
			if (selectedBack != null)
			{
				UI.destroy(selectedBack);
				selectedBack = null;
			}
			
			if (helpIcon != null)
			{
				UI.destroy(helpIcon);
				helpIcon = null;
			}
			
			if (findText != null)
				findText.text = "";
			findText = null;
			
			format = null;
			format2 = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}