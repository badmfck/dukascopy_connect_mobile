package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListPayFilter extends BaseRenderer implements IListRenderer{
		
		private var tfLabel:TextField;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat=new TextFormat("Tahoma", itemHeight * .28);
		private var icon:Bitmap;
		
		public function ListPayFilter() {
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = padding;
			tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
			addChild(tfLabel);
			
			icon = new Bitmap();
			addChild(icon);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var data:Object = li.data;
			graphics.clear();
			if (highlight) {
				graphics.beginFill(AppTheme.GREY_MEDIUM);
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
				tfLabel.textColor = 0xFFFFFF;
			} else {
				tfLabel.textColor = AppTheme.GREY_DARK;
			}
			graphics.beginFill(0, 0.2);
			graphics.drawRect(0, itemHeight - 1, width, 1);
			tfLabel.text = li.data.label;
			//!TODO: replace with vector;
			data.img = null;
			var iconClass:Class = data.icon;
			if (iconClass != null) {
				var iconInstance:Sprite = new iconClass();
				UI.scaleToFit(iconInstance, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .3);
				if (icon.bitmapData) {
					UI.disposeBMD(icon.bitmapData);
					icon.bitmapData = null;
				}
				icon.bitmapData = UI.getSnapshot(iconInstance, StageQuality.HIGH, "ListPayFilter.icon");
				UI.destroy(iconInstance)
				iconInstance = null;
				
				icon.x = int(Config.MARGIN * 2 + Config.FINGER_SIZE*.2 - icon.width*.5);
				icon.y = int(getHeight(li, width) * .5 - icon.height * .5);
				
				tfLabel.x = int(Config.MARGIN*4 + Config.FINGER_SIZE * .4);
				tfLabel.width = width - tfLabel.x - padding - Config.MARGIN*4 - icon.width;	
			} else {
				tfLabel.x = padding;
				tfLabel.width = width - tfLabel.x - padding;
			}
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			format = null;
			
			if (icon)
			{
				UI.destroy(icon);
				icon = null;
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}