package com.dukascopy.connect.gui.chat {
	
	import assets.IconAttention;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ConnectionIndicator extends Sprite {
		
		private var connectionText:Bitmap;
		private var icon:Bitmap;
		
		public function ConnectionIndicator()
		{
			connectionText = new Bitmap();
			addChild(connectionText);
			
			icon = new Bitmap();
			addChild(icon);
		}
		
		public function draw(itemWidth:int, itemHeight:int):void
		{
			if (icon.bitmapData)
			{
				icon.bitmapData.dispose();
				icon.bitmapData = null;
			}
			
			var iconClip:IconAttention = new IconAttention();
			UI.scaleToFit(iconClip, itemHeight * .6, itemHeight * .6);
			icon.bitmapData = UI.getSnapshot(iconClip, StageQuality.HIGH, "ConnectionIndicator.icon");
			UI.destroy(iconClip);
			iconClip = null;
			icon.y = int(itemHeight * .5 - icon.height * .5);
			
			graphics.clear();
			if (connectionText.bitmapData) {
				UI.disposeBMD(connectionText.bitmapData);
				connectionText.bitmapData = null;
			}
			connectionText.bitmapData = TextUtils.createTextFieldData(Lang.noConnection, 
																	itemWidth,
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	true, 
																	MainColors.WHITE, 
																	0, 
																	true, 
																	false, 
																	true);
			
			icon.x = int(itemWidth * .5 - (connectionText.width + Config.MARGIN + icon.width)*.5);
			
			connectionText.x = int(icon.x + icon.width + Config.MARGIN);
			connectionText.y = int(itemHeight * .5 - connectionText.height * .5);
			
			graphics.beginFill(0, 0.6);
			graphics.drawRect(0, 0, itemWidth, itemHeight);
			graphics.endFill();
		}
		
		public function dispose():void
		{
			UI.destroy(connectionText);
			connectionText = null;
			
			graphics.clear();
			
			UI.destroy(icon);
			icon = null;
			
			UI.destroy(this);
		}
	}
}