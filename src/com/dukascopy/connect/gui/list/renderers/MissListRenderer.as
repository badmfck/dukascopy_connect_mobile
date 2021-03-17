package com.dukascopy.connect.gui.list.renderers {
	import assets.FlowerIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.extensions.MissData;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import white.ArrowDown;
	
	public class MissListRenderer extends UserListRenderer {
		
		public function MissListRenderer() { }
		
		private var extensions:Dictionary;
		private var flowerIcon:Sprite;
		private var num:TextField;
		private var controlExpand:Sprite;
		
		override protected function create():void {
			super.create();
			
			extensions = new Dictionary();
			
			flowerIcon = new (Style.icon(Style.ICON_FLOWER))();
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
			if (item.data is MissData && (item.data as MissData).type == MissData.CONTROL_BACK)
			{
				return Config.FINGER_SIZE * .7;
			}
			return Config.FINGER_SIZE * 1.35;
		}
		
		override protected function getItemData(itemData:Object):Object {
			if (itemData is MissData)
			{
				/*if ((itemData as MissData).type == MissData.CONTROL_EXPAND)
				{
					return itemData;
				}*/
				return (itemData as MissData).user;
			}
			
			return itemData;
		}
		
		override public function getView(item:ListItem, height:int, _width:int, highlight:Boolean = false):IBitmapDrawable {
			
			var itemData:MissData = item.data as MissData;
			
			if (itemData.type == MissData.CONTROL_EXPAND || itemData.type == MissData.CONTROL_BACK)
			{
				flowerIcon.visible = false;
				num.visible = false;
				avatar.visible = false;
				if (avatarEmpty != null && contains(avatarEmpty))
				{
					removeChild(avatarEmpty);
				}
				avatarEmpty.visible = false;
				
				if (controlExpand == null)
				{
					controlExpand = new Sprite();
					controlExpand.graphics.lineStyle(UI.getLineThickness(), Style.color(Style.COLOR_LIST_SPECIAL));
					controlExpand.graphics.moveTo(0, int(Config.FINGER_SIZE * .3));
					controlExpand.graphics.lineTo(_width, int(Config.FINGER_SIZE * .3));
					controlExpand.graphics.lineStyle(0, 0, 0);
					
					var textValue:String = "";
					if (itemData.type == MissData.CONTROL_EXPAND)
					{
						textValue = Lang.allUsers;
					}
					else if(itemData.type == MissData.CONTROL_BACK)
					{
						textValue = Lang.backToContest;
					}
					
					var textBD:ImageBitmapData = TextUtils.createTextFieldData(textValue, _width - Config.DIALOG_MARGIN * 2, 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, true, Style.color(Style.FILTER_TABS_COLOR_TAB_TEXT_SELECTED), Style.color(Style.COLOR_LIST_SPECIAL), true);
					var text:Bitmap = new Bitmap(textBD);
					controlExpand.addChild(text);
					text.x = int(_width - text.width - Config.FINGER_SIZE * .2 - Config.FINGER_SIZE * .3);
					text.y = int(Config.FINGER_SIZE * .3 - text.height * .5);
					controlExpand.graphics.beginFill(Style.color(Style.COLOR_LIST_SPECIAL));
					controlExpand.graphics.drawRoundRect(text.x - Config.FINGER_SIZE * .3, 0, text.width + Config.FINGER_SIZE * .3 * 2, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .1);
					if (itemData.type == MissData.CONTROL_EXPAND)
					{
						controlExpand.graphics.drawRoundRect(_width * .5 - Config.FINGER_SIZE * .3, 0, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .1);
					}
					controlExpand.graphics.endFill();
					if (itemData.type == MissData.CONTROL_EXPAND)
					{
						var icon:Sprite = new ArrowDown();
						UI.scaleToFit(icon, Config.FINGER_SIZE * .25, Config.FINGER_SIZE * .25);
						UI.colorize(icon, Style.color(Style.FILTER_TABS_COLOR_TAB_TEXT_SELECTED));
						controlExpand.addChild(icon);
						icon.x = int(_width * .5 - icon.width * .5);
						icon.y = int(Config.FINGER_SIZE * .3 - icon.height * .5);
					}
					addChild(controlExpand);
				//	nme.text = Lang.contestHistory;
				}
				controlExpand.visible = true;
				controlExpand.y = Config.FINGER_SIZE * .1;
				nme.x = int(Config.MARGIN * 1.58);
			}
			else
			{
				if (avatarEmpty != null && !contains(avatarEmpty))
				{
					addChild(avatarEmpty);
				}
				flowerIcon.visible = true;
				num.visible = true;
				nme.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.58);
				if (controlExpand != null)
				{
					controlExpand.visible = false;
				}
			}
			
			flowerIcon.x = _width - Config.DIALOG_MARGIN - flowerIcon.width;
			flowerIcon.y = int(height * .5 - flowerIcon.height * .5);
			num.text = (item.data as MissData).spent.toString();
			num.width = num.textWidth + 4;
			num.x = flowerIcon.x - num.width - Config.MARGIN;
			num.y = int(height * .5 - num.height * .5);
			super.getView(item, height, _width, highlight);
			nme.width = _width - Config.FINGER_SIZE * 3;
			if (itemData.type == MissData.CONTROL_EXPAND && Auth.bank_phase == "ACC_APPROVED")
			{
				nme.width = _width - Config.FINGER_SIZE;
				nme.text = Lang.contestHistory;
				nme.width = nme.textWidth + 4;
				nme.height = nme.textHeight + 4;
				nme.textColor = Style.color(Style.COLOR_TEXT);
				nme.y = int(Config.FINGER_SIZE * .6);
			}
			else if (itemData.type == MissData.WINNER)
			{
				fxnme.text = Lang.miss + " " + DateUtils.month(itemData.month, itemData.year);
				fxnme.visible = true;
				nme.y = height * .5 - nme.height - Config.FINGER_SIZE * .03;
				fxnme.y = height * .5 + Config.FINGER_SIZE * .03;
				fxnme.textColor = Style.color(Style.COLOR_SUBTITLE);
				flowerIcon.visible = false;
				num.visible = false;
			}
			else
			{
				nme.y = int(height * .5 - nme.height * .5);
			}
			
			return this;
		}
		
		override protected function setHitZones(item:ListItem):void {
			if (controlExpand != null && controlExpand.visible == true && controlExpand.numChildren > 0)
			{
				var type:String;
				var hitZones:Array = item.getHitZones();
				hitZones ||= [];
				hitZones.length = 0;
				
				if (item.data is MissData && (item.data as MissData).type == MissData.CONTROL_EXPAND)
				{
					type = HitZoneType.SHOW_ALL;
					
					hitZones.push( {
						type: HitZoneType.EXPAND,
						x: width * .5 - Config.FINGER_SIZE * .3,
						y: controlExpand.y, 
						width: Config.FINGER_SIZE * .6,
						height: Config.FINGER_SIZE * .6
					} );
				}
				else if (item.data is MissData && (item.data as MissData).type == MissData.CONTROL_BACK)
				{
					type = HitZoneType.BACK;
				}
				
				hitZones.push( {
						type: type,
						x: width - Config.FINGER_SIZE * .2 - controlExpand.getChildAt(0).width - Config.FINGER_SIZE * .6,
						y: controlExpand.y, 
						width: controlExpand.getChildAt(0).width + Config.FINGER_SIZE * .6,
						height: Config.FINGER_SIZE*.6
					} );
				
				item.setHitZones(hitZones);
			}
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
			
			if (controlExpand != null)
			{
				while (controlExpand.numChildren > 0)
				{
					UI.destroy(controlExpand.removeChildAt(0));
				}
				UI.destroy(controlExpand);
				controlExpand = null;
			}
		}
	}
}