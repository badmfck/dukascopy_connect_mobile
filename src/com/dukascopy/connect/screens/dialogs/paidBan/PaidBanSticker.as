package com.dukascopy.connect.screens.dialogs.paidBan 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.paidBan.PaidBanReasons;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanSticker extends Sprite
	{
		private var iconSize:int;
		private var iconPadding:int;
		private var textReason:Bitmap;
		private var textUser:Bitmap;
		private var icon:Sprite;
		
		public function PaidBanSticker() {
			iconSize = int(Config.FINGER_SIZE * .45);
			iconPadding = int(Config.FINGER_SIZE * .22);
			icon = new (Style.icon(Style.ICON_JAIL));
			UI.colorize(icon, Style.color(Style.COLOR_BACKGROUND));
			UI.scaleToFit(icon, iconSize, iconSize);
			addChild(icon);
			icon.x = int(iconPadding + Config.FINGER_SIZE * .05);
			icon.y = iconPadding;
			
			textReason = new Bitmap();
			addChild(textReason);
			
			textUser = new Bitmap();
			addChild(textUser);
		}
		
		public function draw(data:UserBan911VO, itemWidth:int):void {
			clean();
			
			var maxTextWidth:int = itemWidth - iconPadding * 2 - iconSize - Config.MARGIN * 2;
			var backColor:Number = Style.color(Style.COLOR_TIP_BACKGROUND);
			
			var reason:String = PaidBanReasons.getReason(data.reason);
			if (reason != null) {
				textReason.bitmapData = TextUtils.createTextFieldData(
														reason, maxTextWidth, 10, true, 
														TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
														Config.FINGER_SIZE * .26, true, Style.color(Style.COLOR_BACKGROUND), backColor);
				textReason.x = int(itemWidth - textReason.width - Config.MARGIN * 2);
			}
			
			var user:String;
			if (data.incognito == true) {
				user = Lang.banBy + " " + Lang.textIncognito;
			}
			else {
				if (data.payerName != null) {
					user = Lang.banBy + " " + data.payerName;
				}
			}
			
			if (user != null) {
				textUser.bitmapData = TextUtils.createTextFieldData(
														user, maxTextWidth, 10, true, 
														TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
														Config.FINGER_SIZE * .22, true, Style.color(Style.COLOR_BACKGROUND), backColor);
				textUser.x = int(itemWidth - textUser.width - Config.MARGIN * 2);
			}
			
			graphics.beginFill(backColor);
			var textVPadding:int = Config.FINGER_SIZE * .1;
			var vPadding:int = Config.FINGER_SIZE * .08;
			if (textReason.height + vPadding + textUser.height < iconSize) {
				textReason.y = int(icon.y + iconSize * .5 - (textReason.height + vPadding + textUser.height) * .5);
				textUser.y = int(textReason.y + textReason.height + vPadding);
				graphics.drawRoundRect(0, 0, itemWidth, iconSize + iconPadding * 2, (iconSize + iconPadding * 2), (iconSize + iconPadding * 2));
			}
			else {
				textReason.y = int(textVPadding);
				textUser.y = int(textReason.y + textReason.height + vPadding);
				graphics.drawRoundRect(0, 0, itemWidth, textUser.height + textReason.height + vPadding + textVPadding * 2, (iconSize + iconPadding * 2), (iconSize + iconPadding * 2));
				icon.y = int((textUser.height + textReason.height + vPadding + textVPadding * 2) * .5 - icon.height * .5);
			}
			graphics.endFill();
		}
		
		private function clean():void {
			if (textReason.bitmapData != null) {
				textReason.bitmapData.dispose();
				textReason.bitmapData = null;
			}
			
			if (textUser.bitmapData != null) {
				textUser.bitmapData.dispose();
				textUser.bitmapData = null;
			}
			
			graphics.clear();
		}
		
		public function dispose():void {
			
			if (textReason != null)
			{
				UI.destroy(textReason);
				textReason = null;
			}
			if (textUser != null)
			{
				UI.destroy(textUser);
				textUser = null;
			}
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
		}
	}
}