package com.dukascopy.connect.screens.dialogs.gifts 
{
	import assets.Panel_1;
	import assets.Panel_2;
	import assets.Panel_3;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.UserGifts;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FlowerSticker extends Sprite
	{
		private var iconSize:int;
		private var iconPadding:int;
		private var textUser:Bitmap;
		
		private var flower:Sprite;
		
		private var panel_1:Panel_1;
		private var panel_2:Panel_2;
		private var panel_3:Panel_3;
		
		public function FlowerSticker() {
			
			panel_1 = new Panel_1();
			panel_2 = new Panel_2();
			panel_3 = new Panel_3();
			
			panel_1.height = panel_2.height = panel_3.height = Config.FINGER_SIZE * 1.0;
			panel_1.scaleX = panel_1.scaleY;
			panel_3.scaleX = panel_3.scaleY;
			
			addChild(panel_1);
			addChild(panel_2);
			addChild(panel_3);
			
			panel_1.y = panel_2.y = panel_3.y = Config.FINGER_SIZE * .39;
			
			textUser = new Bitmap();
			addChild(textUser);
		}
		
		public function draw(data:UserGifts, maxWidth:int):void {
			clean();
			
			var extension:Extension = data.items[data.items.length - 1];
			var maxTextWidth:int = maxWidth - Config.FINGER_SIZE * 3;
			
			addFlower(extension);
			
			var user:String = "...";
			if (extension.incognito == true) {
				user = Lang.textIncognito;
			}
			else {
				if (extension.pname != null) {
					user = extension.pname;
				}
			}
			
			user = Lang.fromText + " " + user;
			
			if (user != null) {
				textUser.bitmapData = TextUtils.createTextFieldData(
														user, maxTextWidth, 10, true, 
														TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
														Config.FINGER_SIZE * .27, true, 0x395654, 0xFFFFFF, true);
			//	textUser.x = int(itemWidth - textUser.width - Config.MARGIN * 2);
				textUser.x = Config.FINGER_SIZE * 1.7;
				textUser.y = panel_1.y + Math.max(panel_1.height * .4 - textUser.height * .5, Config.MARGIN);
			}
			var allWidth:int = textUser.width + Config.FINGER_SIZE * 2.7;
			panel_2.width = allWidth - panel_1.width - panel_3.width;
			panel_2.x = panel_1.x + panel_1.width
			panel_3.x = panel_2.x + panel_2.width
		}
		
		private function addFlower(extension:Extension):void 
		{
			if (flower != null)
			{
				UI.destroy(flower);
				flower = null;
			}
			var imageClass:Class = extension.getImageRaw();
			if (imageClass != null)
			{
				flower = new imageClass() as Sprite;
			
				UI.scaleToFit(flower, Config.FINGER_SIZE * 0.9, Config.FINGER_SIZE * 0.9);
				flower.x = int(Config.FINGER_SIZE * .8);
				addChild(flower);
				flower.y = Config.FINGER_SIZE * 1 - flower.height;
			}
		}
		
		private function clean():void {
			if (textUser.bitmapData != null) {
				textUser.bitmapData.dispose();
				textUser.bitmapData = null;
			}
			
			graphics.clear();
		}
		
		public function dispose():void {
			if (textUser != null)
			{
				UI.destroy(textUser);
				textUser = null;
			}
			if (panel_1 != null)
			{
				UI.destroy(panel_1);
				panel_1 = null;
			}
			if (panel_2 != null)
			{
				UI.destroy(panel_2);
				panel_2 = null;
			}
			if (panel_3 != null)
			{
				UI.destroy(panel_3);
				panel_3 = null;
			}
			if (flower != null)
			{
				UI.destroy(flower);
				flower = null;
			}
		}
	}
}