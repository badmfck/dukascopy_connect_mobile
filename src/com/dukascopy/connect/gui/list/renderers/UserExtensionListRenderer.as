package com.dukascopy.connect.gui.list.renderers {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	public class UserExtensionListRenderer extends UserListRenderer {
		
		public function UserExtensionListRenderer() { }
		
		private var extensions:Dictionary;
		
		override protected function create():void {
			super.create();
			
			extensions = new Dictionary();
		}
		
		override protected function getTitleWidth():int {
			var titleWidth:Number = width - nme.x - Config.MARGIN;
			
			return titleWidth;
		}
		
		override public function getHeight(item:ListItem, width:int):int {
			return Config.FINGER_SIZE * 1.35;
		}
		
		override public function getView(item:ListItem, height:int, _width:int, highlight:Boolean = false):IBitmapDrawable {
			
			if (extensions != null)
			{
				for each (var extensionClip:Sprite in extensions) 
				{
					extensionClip.visible = false;
				}
			}
			
			var itemData:Extension = item.data as Extension;
			
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
			}
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
		}
	}
}