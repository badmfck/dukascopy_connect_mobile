package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListLinkWithIcon extends ListLink {
		
		private var icon:Bitmap;
		
		public function ListLinkWithIcon() {
			super();
			
			icon = new Bitmap();
			addChild(icon);
		}
		
		override public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			super.getView(li, h, width, highlight);
			
			var data:Object = getData(li);			
			var iconClass:Class;
			if (data.icon is String) {
				try {
					iconClass = Class(getDefinitionByName(data.icon));
				} catch (err:Error) {
					echo("ListLinkWithIcon", "getView", "Can't get icon class");
				}
			} else {
				iconClass = data.icon;
			}
			
			var leftOffset:int;
			
			if (iconClass != null) {
				var iconInstance:Sprite = new iconClass();
				UI.scaleToFit(iconInstance, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
				if (icon.bitmapData) {
					UI.disposeBMD(icon.bitmapData);
					icon.bitmapData = null;
				}
				var ct:ColorTransform = new ColorTransform();
				if (data.iconColor == null) {
					ct.color = AppTheme.GREY_MEDIUM;
					iconInstance.transform.colorTransform = ct;
				} else if (data.iconColor != -1) {
					ct.color = data.iconColor;
					iconInstance.transform.colorTransform = ct;
				}
				icon.bitmapData = UI.getSnapshot(iconInstance, StageQuality.HIGH, "ListLinkWithIcon.icon");
				UI.destroy(iconInstance)
				iconInstance = null;
				
				icon.x = Config.DOUBLE_MARGIN;
				icon.y = int(getHeight(li, width) * .5 - icon.height * .5);
				
				leftOffset = Config.DOUBLE_MARGIN + icon.x + icon.width;
			}
			else
			{
				if (icon.bitmapData) {
					UI.disposeBMD(icon.bitmapData);
					icon.bitmapData = null;
				}
				leftOffset = Config.DOUBLE_MARGIN;
			}
			
			tfLabel.x = leftOffset;
			
			tfLabel.width = width - tfLabel.x - Config.DOUBLE_MARGIN;			
			return this;
		}
		
		override public function dispose():void {
			super.dispose();
			if (icon)
				UI.destroy(icon);
			icon = null;
		}
	}
}