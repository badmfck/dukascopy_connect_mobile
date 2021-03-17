package com.dukascopy.connect.gui.list.renderers {
	import assets.FlowerIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.sys.usersManager.extensions.ExtensionTopData;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	public class TopExtensionListRenderer extends UserListRenderer {
		
		public function TopExtensionListRenderer() { }
		
		private var extensions:Dictionary;
		private var flowerIcon:assets.FlowerIcon;
		private var num:flash.text.TextField;
		
		override protected function create():void {
			super.create();
			
			extensions = new Dictionary();
			
			flowerIcon = new FlowerIcon();
			UI.colorize(flowerIcon, 0x7DA0BB);
			UI.scaleToFit(flowerIcon, Config.FINGER_SIZE*.45, Config.FINGER_SIZE*.45);
			addChild(flowerIcon);
			
			
			num = new TextField();
				num.selectable = false;
				format1.size = Config.FINGER_SIZE * .3;
				num.defaultTextFormat = format1;
				num.textColor = 0x7DA0BB;
				num.text = "Pp";
				num.height = num.textHeight + 4;
				num.text = "";
				num.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.58);
				num.wordWrap = false;
				num.multiline = false;
			addChild(num);
		}
		
		override protected function getTitleWidth():int {
			var titleWidth:Number = width - nme.x - Config.MARGIN;
			
			return titleWidth;
		}
		
		override public function getHeight(item:ListItem, width:int):int {
			return Config.FINGER_SIZE * 1.35;
		}
		
		override protected function getItemData(itemData:Object):Object {
			if (itemData is ExtensionTopData)
			{
				return (itemData as ExtensionTopData).user;
			}
			
			return itemData;
		}
		
		override public function getView(item:ListItem, height:int, _width:int, highlight:Boolean = false):IBitmapDrawable {
			
			/*if (extensions != null)
			{
				for each (var extensionClip:Sprite in extensions) 
				{
					extensionClip.visible = false;
				}
			}
			
			var itemData:Extension = item.data as ExtensionTopData;
			
			avatar.visible = true;
			avatarEmpty.visible = true;
			nme.visible = true;
			fxnme.visible = false;
			
		//	checkOnlineStatus(itemData.user_uid);
			nme.text = itemData.name;
			
			nme.width = getTitleWidth();
			TextUtils.truncate(nme);
			
			nme.textColor = MainColors.DARK_BLUE;
			
			var itemSize:int = Config.FINGER_SIZE * .7;
			var sourceClass:Class = itemData.getSmallImage();
			var source:Sprite;
			if (sourceClass != null)
			{
				if (extensions[sourceClass.toString()] == null)
				{
					source = new sourceClass() as Sprite;
					UI.scaleToFit(source, itemSize, itemSize);
					
					addChild(source);
					source.x = _width - source.width - Config.DIALOG_MARGIN;
					source.y = int(height * .5 - source.height * .5);
					
					extensions[sourceClass.toString()] = source;
				}
				else
				{
					extensions[sourceClass.toString()].visible = true;
				}
			}*/
			
		//	var itemData:Extension = item.data as ExtensionTopData;
			
			flowerIcon.x = _width - Config.DIALOG_MARGIN - flowerIcon.width;
			flowerIcon.y = int(height * .5 - flowerIcon.height * .5);
			num.text = (item.data as ExtensionTopData).amount.toString();
			num.width = num.textWidth + 4;
			num.x = flowerIcon.x - num.width - Config.MARGIN;
			num.y = int(height * .5 - num.height * .5);
			
			return super.getView(item, height, _width, highlight);
		}
		
		override protected function setHitZones(item:ListItem):void {
			
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (extensions != null)
			{
				for (var key:String in extensions) 
				{
					UI.destroy(extensions[key]);
					delete extensions[key];
				}
				extensions = null;
			}
			
			if (flowerIcon != null)
			{
				UI.destroy(flowerIcon);
				flowerIcon = null;
			}
			
			if (num != null)
			{
				UI.destroy(num);
				num = null;
			}
		}
	}
}