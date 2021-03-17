package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDuration;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDurationCollection;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class DurationListItem extends BaseRenderer implements IListRenderer{
		
		private var tfLabel:TextField;
		private var padding:int = Config.FINGER_SIZE * .3;
		private var itemHeight:int = Config.FINGER_SIZE * 1;
		private var LINE_HEIGHT:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat(Config.defaultFontName, LINE_HEIGHT * .3);
		
		public function DurationListItem() {
			
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = padding;
			tfLabel.y = Math.round((LINE_HEIGHT - tfLabel.textHeight) * .5);
			
			addChild(tfLabel);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			var data:SubscriptionDuration = li.data as SubscriptionDuration;
			
			graphics.clear();
			
			if (highlight) {
				graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
				tfLabel.textColor = 0xFFFFFF;
			} else {
				tfLabel.textColor = AppTheme.GREY_MEDIUM;
			}
			
			graphics.beginFill(0, .2);
			graphics.drawRect(0, h - 1, width, 1);
			graphics.endFill();
			
			tfLabel.text = data.getLabel();
			
			tfLabel.width = width - tfLabel.x - padding;
			tfLabel.x = padding;
			tfLabel.y = (itemHeight - tfLabel.height) * .5;
			
			return this;
		}
			
		public function dispose():void {
			graphics.clear();
			
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			format = null
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}