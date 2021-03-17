package com.dukascopy.connect.gui.list.renderers.viBot {
	
	import assets.SupportIconNew;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererImage;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.InChatMessageRendererImageDisplay;
	import com.dukascopy.connect.gui.list.renderers.viBot.sections.MenuForVIMessageSection;
	import com.dukascopy.connect.gui.list.renderers.viBot.sections.TextForVIMessageSection;
	import com.dukascopy.connect.gui.list.renderers.viBot.sections.VIAccountElementSectionBase;
	import com.dukascopy.connect.gui.list.renderers.viBot.sections.ViImageRenderer;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.BankMessageVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListVIMessage extends BaseRenderer implements IListRenderer {
		
		private var trueHeight:int;
		
		private var avatar:Sprite;
		private var avatarBankIBMD:ImageBitmapData;
		private var avatarSize:int = Config.FINGER_SIZE * .46;
		private var avatarSizeDouble:int = avatarSize * 2;
		
		private var sectionText:TextForVIMessageSection;
		
		private var menuSections:Array/*BAETextSection*/;
		private var buttonSections:Array/*BAETextSection*/;
		
		private var horizoltalMenu:Boolean;
		private var horizoltalButtons:Boolean;
		private var menuCount:int;
		private var tapped:Boolean;
		private var photoSection:ViImageRenderer;
		
		public function ListVIMessage() {
			sectionText = new TextForVIMessageSection();
			sectionText.setFitToContent();
			
			avatarBankIBMD = UI.renderAsset(new SupportIconNew(), avatarSizeDouble, avatarSizeDouble, true, "ListVIMessage.avatarBank");
			
			avatar = new Sprite();
			avatar.x = Config.MARGIN;
			
			ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarBankIBMD, ImageManager.SCALE_PORPORTIONAL);
		}
		
		public function getHeight(li:ListItem, width:int):int {
			setData(li, width);
			return trueHeight + ((li.num == 0) ? Config.DOUBLE_MARGIN + Config.FINGER_SIZE*.3 : Config.FINGER_SIZE*.3);
		}
		
		private function setData(li:ListItem, width:int):void {
			tapped = false;
			
			if (photoSection != null && contains(photoSection))
			{
		//		photoSection.clearImage();
				removeChild(photoSection);
			}
			
			
			var bmVO:RemoteMessage = li.data as RemoteMessage;
			
			var sectionWidth:int = width - avatar.x - avatarSizeDouble - Config.DIALOG_MARGIN;
			var sectionMenuWidth:int = sectionWidth - sectionText.getBirdSize() * 2 - Config.FINGER_SIZE;
			if (bmVO.mine == false)
				sectionWidth = width;
			
			trueHeight = 0;
			
			var field:String;
			if (bmVO.message != null)
			{
				field = "message";
			}
			
			if (sectionText.setData(bmVO, field) == true) {
				sectionText.setWidth(sectionWidth - avatar.x - avatarSizeDouble - Config.DIALOG_MARGIN * 2);
				sectionText.setMine(bmVO.mine);
				sectionText.fillData(li);
				trueHeight += sectionText.getTrueHeight();
				if (sectionText.parent == null)
					addChild(sectionText);
			} else if (sectionText.parent != null) {
				sectionText.parent.removeChild(sectionText);
			}
			
			if (bmVO.photo != null) {
				if (sectionText.parent != null)
					trueHeight += Config.MARGIN;
				oldtrueHeight = trueHeight;
				
				var previewSize:int = Config.FINGER_SIZE * 3;
				
				if (photoSection == null)
				{
					photoSection = new ViImageRenderer(Config.FINGER_SIZE * .5);
					
				}
				addChild(photoSection);
				
				photoSection.drawImage(bmVO.photo, previewSize, previewSize, null);
				
				photoSection.x = width - previewSize - Config.DIALOG_MARGIN;
				photoSection.y = oldtrueHeight;
				
				trueHeight = oldtrueHeight + previewSize + Config.FINGER_SIZE * .3;
			}
			
			var maxWidthForH:int;
			var maxWidth:int;
			var currentWidth:int;
			var j:int;
			var oldtrueHeight:int;
			horizoltalMenu = false;
			var i:int = 0;
			var l:int = 0;
			if (bmVO.actions != null && bmVO.actions.length != 0) {
				if (sectionText.parent != null)
					trueHeight += Config.MARGIN + int(Config.FINGER_SIZE * .3);
				oldtrueHeight = trueHeight;
				menuSections ||= [];
				l = bmVO.actions.length;
				var trueLength:int;
				var menuSection:MenuForVIMessageSection;
				for (i = 0; i < l; i++) {
					menuSection = null;
					/*if (bmVO.actions[i].disabled == true)
						continue;*/
					if (menuSections.length > trueLength)
						menuSection = menuSections[trueLength];
					if (menuSection == null)
						menuSection = menuSections[menuSections.push(new MenuForVIMessageSection()) - 1];
					menuSection.setIndex(i);
					
					if (bmVO.actions[i].text != null) {
						field = "text";
					}
					
					menuSection.setData(bmVO.actions[i], field);
					menuSection.alpha = 1;
					if (bmVO.actions[i].tapped == true)
						tapped = true;
					menuSection.setWidth(sectionMenuWidth);
					menuSection.fillData(li);
					trueHeight += menuSection.getTrueHeight();
					if (menuSection.parent == null)
						addChild(menuSection);
					currentWidth = menuSection.getTextfieldWithPaddingWidth();
					if (currentWidth > maxWidth)
						maxWidth = currentWidth;
					trueLength++;
				}
				maxWidthForH = sectionMenuWidth / trueLength;
				if (maxWidthForH > maxWidth && bmVO.menuLayout!="vertical") {
					horizoltalMenu = true;
					trueHeight = oldtrueHeight + menuSections[0].getTrueHeight();
					maxWidth = maxWidthForH;
				}
				if (horizoltalMenu == true)
					for (j = 0; j < i; j++)
						menuSections[j].setContentWidth(maxWidth);
			}
			if (menuSections != null && menuSections.length != 0) {
				i = trueLength;
				for (i; i < menuSections.length; i++) {
					if (menuSections[i].parent != null)
						menuSections[i].parent.removeChild(menuSections[i]);
				}
			}
			i = 0;
			maxWidth = 0;
			horizoltalButtons = false;
			if (bmVO.buttons != null && bmVO.buttons.length != 0) {
				buttonSections ||= [];
				l = bmVO.buttons.length;
				maxWidthForH = (sectionMenuWidth - Config.MARGIN * (l - 1)) / l;
				if (trueHeight > 0)
					oldtrueHeight = trueHeight;
				var buttonSection:MenuForVIMessageSection;
				for (i = 0; i < l; i++) {
					buttonSection = null;
					if (buttonSections.length > i)
						buttonSection = buttonSections[i];
					if (buttonSection == null)
						buttonSection = buttonSections[buttonSections.push(new MenuForVIMessageSection()) - 1];
					buttonSection.setData(bmVO.buttons[i], "text");
					buttonSection.alpha = 1;
					if (bmVO.buttons[i].tapped == true)
						tapped = true;
					buttonSection.setWidth(sectionMenuWidth);
					buttonSection.fillData(li);
					trueHeight += buttonSection.getTrueHeight() + Config.MARGIN;
					if (buttonSection.parent == null)
						addChild(buttonSection);
					currentWidth = buttonSection.getTextfieldWithPaddingWidth();
					if (currentWidth > maxWidth)
						maxWidth = currentWidth;
				}
				if (maxWidthForH > maxWidth) {
					horizoltalButtons = true;
					trueHeight = oldtrueHeight + buttonSections[0].getTrueHeight() + Config.MARGIN;
					maxWidth = maxWidthForH;
				}
				if (horizoltalButtons == true)
					for (j = 0; j < i; j++)
						buttonSections[j].setContentWidth(maxWidth);
			}
			if (buttonSections != null && buttonSections.length != 0) {
				for (i; i < buttonSections.length; i++) {
					if (buttonSections[i].parent != null)
						buttonSections[i].parent.removeChild(buttonSections[i]);
				}
			}
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			setData(li, width);
			graphics.clear();
			
			var sectionY:int = 0;
			
			if (sectionText.parent != null) {
				sectionText.y = sectionY;
				sectionText.setFirst(true);
				sectionText.setLast(true);
				sectionText.draw();
				if (li.data.mine) {
					if (avatar != null && avatar.parent != null)
						avatar.parent.removeChild(avatar);
					sectionText.x = width - sectionText.getTrueWidth() - Config.DIALOG_MARGIN + Config.FINGER_SIZE * .3;
				} else {
					if (avatar != null && avatar.parent == null)
						addChild(avatar);
					avatar.y = sectionY + sectionText.height - avatarSizeDouble;
					sectionText.x = int(avatar.x + avatarSizeDouble + Config.MARGIN * .5);
				}
				sectionY = sectionText.getTrueHeight();
				//trace("!", sectionY);
			}
			var hitZones:Array;
			var i:int;
			var l:int;
			var sectionX:int = sectionText.getBirdSize() + Config.FINGER_SIZE;
			hitZones = li.getHitZones();
			hitZones ||= [];
			hitZones.length = 0;
			
			if (menuSections != null && menuSections.length != 0 && menuSections[0].parent != null) {
				if (sectionY != 0)
					sectionY += int(Config.FINGER_SIZE * .2);
				menuSections[0].setFirst(true);
				l = menuSections.length;
				for (i = 0; i < l; i++) {
					if (menuSections[i].parent != null) {
						if (tapped == true && menuSections[i].getData().tapped != true)
							menuSections[i].alpha = .3;
						menuSections[i].setHorizontal(horizoltalMenu);
						menuSections[i].draw();
						menuSections[i].y = sectionY;
						menuSections[i].x = int(width * .5 - menuSections[i].getContentWidth() * .5);
						hitZones.push( {
							type: HitZoneType.BOT_MENU,
							param: menuSections[i]["getIndex"](),
							x: menuSections[i].x,
							y: sectionY, 
							width: menuSections[i].getContentWidth(),
							height: menuSections[i].getTrueHeight()
						} );
						if (horizoltalMenu == false)
							sectionY += menuSections[i].getTrueHeight();
						else
							sectionX += menuSections[i].getContentWidth();
					} else {
						break;
					}
				}
				menuSections[i - 1].setLast(true);
				menuSections[i - 1].draw();
				if (horizoltalMenu == true)
					sectionY += menuSections[0].getTrueHeight();
			}
			sectionX = sectionText.getBirdSize() + Config.FINGER_SIZE;
			if (buttonSections != null && buttonSections.length != 0 && buttonSections[0].parent != null) {
				l = buttonSections.length;
				if (sectionY != 0)
					sectionY += Config.MARGIN;
				for (i = 0; i < l; i++) {
					if (tapped == true && buttonSections[i].getData().tapped != true)
						buttonSections[i].alpha = .4;
					buttonSections[i].setFirst(true);
					buttonSections[i].setLast(true);
					buttonSections[i].setHorizontal(horizoltalMenu);
					if (buttonSections[i].parent != null) {
						buttonSections[i].draw();
						buttonSections[i].y = sectionY;
						buttonSections[i].x = sectionX;
						hitZones.push( {
							type: HitZoneType.BOT_MENU_BUTTON,
							param: i,
							x: buttonSections[i].x,
							y: sectionY, 
							width: buttonSections[i].getContentWidth(),
							height: buttonSections[i].getTrueHeight()
						} );
						if (horizoltalButtons == false)
							sectionY += buttonSections[i].getTrueHeight() + Config.MARGIN;
						else
							sectionX += buttonSections[i].getTrueWidth() + Config.MARGIN;
					} else {
						break;
					}
				}
				buttonSections[i - 1].setLast(true);
				buttonSections[i - 1].draw();
			}
			// Add avatar hitozne
			hitZones.push( {
				type: HitZoneType.AVATAR,
				param:i,
				x: avatar.x,
				y: avatar.y, 
				width: avatarSizeDouble,
				height: avatarSizeDouble
			} );
			
			li.setHitZones(hitZones);
			
			return this;
		}
		
		private function selectItem(sections:Array, data:Object, sx:int, sy:int, hitZones:Array, hitZonesType:String):int {
			if (sections == null || sections.length == 0 || sections[0].parent == null)
				return sy;
			if (sy != 0)
				sy += Config.MARGIN;
			if (data != null && "param" in data == true && data.param != null)
				data = data.param;
			var l:int = sections.length;
			var i:int;
			graphics.beginFill(0xFFFFFF, (tapped == true) ? .4 : 1);
			graphics.drawRoundRect(
				sx,
				sy,
				sections[0].getWidth(),
				sections[i].getHeight() * l,
				VIAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
				VIAccountElementSectionBase.CORNER_RADIUS_DOUBLE
			);
			graphics.endFill();
			for (i = 0; i < l; i++) {
				if (tapped == true) {
					if (sections[i].getData() != data) {
						sections[i].alpha = .4;
					} else {
						graphics.beginFill(0xFFFFFF);
						if (i == 0) {
							if (i == sections.length - 1) {
								graphics.drawRoundRect(
									sx,
									sy,
									sections[0].getWidth(),
									sections[i].getHeight(),
									VIAccountElementSectionBase.CORNER_RADIUS_DOUBLE,
									VIAccountElementSectionBase.CORNER_RADIUS_DOUBLE
								);
							} else {
								graphics.drawRoundRectComplex(
									sx,
									sy,
									sections[0].getWidth(),
									sections[i].getHeight(),
									VIAccountElementSectionBase.CORNER_RADIUS,
									VIAccountElementSectionBase.CORNER_RADIUS,
									0,
									0
								);
							}
						} else if (i == sections.length - 1) {
							graphics.drawRoundRectComplex(
								sx,
								sy,
								sections[0].getWidth(),
								sections[i].getHeight(),
								0,
								0,
								VIAccountElementSectionBase.CORNER_RADIUS,
								VIAccountElementSectionBase.CORNER_RADIUS
							);
						} else {
							graphics.drawRect(
								sx,
								sy,
								sections[0].getWidth(),
								sections[i].getHeight()
							);
						}
					}
				}
				sections[i].x = sx;
				sections[i].y = sy;
				if ("isTotal" in sections[i] == false || sections[i].isTotal == false) {
					hitZones.push( {
						type: hitZonesType,
						param: i,
						x: sections[i].x,
						y: sy, 
						width: sections[i].getWidth(),
						height: sections[i].getHeight()
					} );
				}
				sy += sections[i].getHeight();
			}
			graphics.endFill();
			return sy;
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData {
			var zones:Array = listItem.getHitZones();
			var data:Object = listItem.data;
			getView(listItem, getHeight(listItem, listItem.width), listItem.width, false);
			
			var result:HitZoneData = new HitZoneData();
			
			const MENU_BUTTON:String = "botMenuButton";
			const MENU:String = "botMenu";
			
			if (zones != null && itemTouchPoint != null && data != null && data is RemoteMessage) {
				var messageData:RemoteMessage = data as RemoteMessage;
				if (messageData.disabled == true) {
					result.disabled = true;
					return result;
				}
				var l:int = zones.length;
				var zone:Object;
				var selectedIndex:int = -1;
				for (var i:int = 0; i < l; i++) {
					zone = zones[i];
					if (zone.x <= itemTouchPoint.x && zone.y <= itemTouchPoint.y && zone.x + zone.width >= itemTouchPoint.x && zone.y + zone.height >= itemTouchPoint.y) {
						selectedIndex = zones[i].param;
						break;
					}
				}
				if (selectedIndex != -1) {
					var length:int;
					var item:Sprite;
					zone = zones[i];
					
					if (zone.type == MENU_BUTTON && messageData.buttons != null && messageData.buttons.length > selectedIndex)
					{
						result.radius = VIAccountElementSectionBase.CORNER_RADIUS;
						result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						
						if (buttonSections != null && buttonSections.length > selectedIndex)
						{
							item = buttonSections[selectedIndex];
						}
						
						if (item != null)
						{
							result.x = item.x;
							result.y = item.y;
							result.width = item.width;
							result.height = item.height;
							return result;
						}
					}
					
					else if (zone.type == MENU && messageData.actions != null && messageData.actions.length > selectedIndex)
					{
						result.radius = VIAccountElementSectionBase.CORNER_RADIUS;
						if (messageData.actions.length == 1)
						{
							result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
						}
						else if (selectedIndex == 0)
						{
							result.type = HitZoneType.MENU_FIRST_ELEMENT;
						}
						else if (selectedIndex == messageData.actions.length - 1)
						{
							result.type = HitZoneType.MENU_LAST_ELEMENT;
						}
						else{
							result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
						}
						
						if (menuSections != null && menuSections.length > selectedIndex)
						{
							item = menuSections[selectedIndex];
						}
						
						if (item != null)
						{
							result.x = item.x;
							result.y = item.y;
							result.width = item.width;
							result.height = item.height;
							return result;
						}
					}
				}
			}
			
			result.disabled = true;
			return result;
		}
		
		public function get isTransparent():Boolean {
			return true;
		}
		
		public function dispose():void {
			
			if (avatarBankIBMD != null)
			{
				avatarBankIBMD.dispose();
				avatarBankIBMD = null;
			}
			
			if (avatar != null)
			{
				UI.destroy(avatar);
				avatar = null;
			}
		}
	}
}