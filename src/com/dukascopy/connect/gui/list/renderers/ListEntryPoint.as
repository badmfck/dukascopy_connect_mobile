package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListEntryPoint extends Sprite implements IListRenderer{
		
		private var tfLabel:TextField;
		
		private var padding:int = Config.FINGER_SIZE * .3;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat=new TextFormat("Tahoma", itemHeight * .28, null, null, null, null, null, null, TextFormatAlign.CENTER);
		
		public function ListEntryPoint() {
			tfLabel = new TextField();
			tfLabel.defaultTextFormat = format;
			tfLabel.alpha = .5;
			tfLabel.x = padding;
			
			addChild(tfLabel);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			if (data.data.id == -1)
				return Config.FINGER_SIZE_DOUBLE * 2 + Config.DOUBLE_MARGIN * 4;
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			var data:EntryPointVO = li.data as EntryPointVO;
			
			var isSelected:Boolean = false;
			tfLabel.width = width - padding * 2;
			tfLabel.visible = true;
			graphics.clear();
			if (highlight && data.id != -1) {
				graphics.beginFill(AppTheme.RED_MEDIUM);
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
				tfLabel.textColor = 0xFFFFFF;
			} else {
				tfLabel.textColor = 0;
			}
			
			if (data.id == -1) {
				tfLabel.visible = false;
				var imagePos:int = Config.FINGER_SIZE_DOUBLE;
				ImageManager.drawGraphicCircleImage(graphics, width * 0.5, imagePos + Config.DOUBLE_MARGIN * 2, imagePos, Assets.getAsset(Assets.ICON_SUPPORT), ImageManager.SCALE_INNER_PROP);
				graphics.beginFill(0xFF0000);
				graphics.drawRect(0, h - 3, width, 3);
				graphics.endFill();
				return this;
			}
			tfLabel.alpha = .5;
			graphics.beginFill(0, .2);
			graphics.drawRect(0, h - 1, width, 1);
			graphics.endFill();
			tfLabel.text = data.title;
			tfLabel.width = width - tfLabel.x - padding;
			tfLabel.y = Math.round((h - tfLabel.textHeight) * .5);
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			format = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}