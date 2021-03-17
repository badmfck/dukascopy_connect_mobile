package com.dukascopy.connect.screens.chat.selectAdressee {
	
	import assets.IconDone;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.UserStatusType;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ListItemSelectableChatsOrContacts extends SelectAdresseeScreenChatsListItem {
		
		private var checkClip:Sprite;
		private var checkClipSelected:Sprite;
		private var checkClipSelectedIcon:IconDone;
		
		protected var textFormatStatusFxName:TextFormat = new TextFormat();
		private var selectedIconR:int = Config.FINGER_SIZE * .17;
		
		public function ListItemSelectableChatsOrContacts() {
			if (initialized == false) {
				initialized = true;
			}
			avatarSize = Config.FINGER_SIZE * .4;
			leftOffset = Config.MARGIN * 1.58;
			
			var selectedIconSize:int = selectedIconR * 2;
			var selectedIconY:int = (Config.FINGER_SIZE - selectedIconSize) * .5;
			avatarX = selectedIconSize + leftOffset * 2;
			avatarY = (Config.FINGER_SIZE - avatarSize * 2) * .5;
			onlineIndicatorOutR = Config.FINGER_SIZE * .11;
			onlineIndicatorInR = Config.FINGER_SIZE * .08;
			onlineIndicatorX = avatarX + avatarSize * Math.cos(Math.PI / 4) + avatarSize - onlineIndicatorOutR;
			onlineIndicatorY = avatarY + avatarSize * Math.sin(Math.PI / 4) + avatarSize - onlineIndicatorOutR;
			iconSize = Config.FINGER_SIZE * .35;
			
			super();
		}
		
		private function initCheckClip():void {
			var selectedIconSize:int = selectedIconR * 2;
			var selectedIconY:int = (Config.FINGER_SIZE - selectedIconSize) * .5;
			
			checkClip = new Sprite();
			checkClip.graphics.beginFill(AppTheme.GREY_MEDIUM);
			checkClip.graphics.drawCircle(selectedIconR, selectedIconR, selectedIconR);
			checkClip.graphics.drawCircle(selectedIconR, selectedIconR, selectedIconR - 1);
			checkClip.graphics.endFill();
			
			checkClipSelected = new Sprite();
			checkClipSelected.graphics.beginFill(AppTheme.GREEN_LIGHT);
			checkClipSelected.graphics.drawCircle(selectedIconR, selectedIconR, selectedIconR);
			checkClipSelected.graphics.endFill();
			
			checkClipSelectedIcon = new IconDone();
			UI.scaleToFit(checkClipSelectedIcon, selectedIconR, selectedIconR);
			checkClipSelectedIcon.x = int((selectedIconSize - checkClipSelectedIcon.width) * .5);
			checkClipSelectedIcon.y = int((selectedIconSize - checkClipSelectedIcon.height) * .5);
			checkClipSelected.addChild(checkClipSelectedIcon);
			
			checkClip.addChild(checkClipSelected);
			checkClip.x = leftOffset;
			checkClip.y = selectedIconY;
			addChild(checkClip);
		}
		
		override public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			super.getView(item, height, width, highlight);
			statusText.setTextFormat(textFormatStatusFxName);
			var itemData:IContactsChatsSelectionListItem = item.data as IContactsChatsSelectionListItem
			if (checkClip != null) {
				if (itemData.isListSelectable == false) {
					if (checkClip.parent != null)
						removeChild(checkClip);
				} else
					addChild(checkClip);
			} else {
				if (itemData.isListSelectable == true)
					initCheckClip();
			}
			if (itemData.isListSelectable == true) {
				switch(itemData.status) {
					case UserStatusType.SELECTED:
						checkClipSelected.visible = true;
						break;
					case UserStatusType.UNSELECTED:
						checkClipSelected.visible = false;
						break;
					default:
						break;	
				}
			}
			if (statusText.text == "")
				nme.y = avatarY + avatarSize / 2;
			return this;
		}
		
		override public function dispose():void {
			super.dispose();
			if (checkClipSelectedIcon != null)
				UI.destroy(checkClipSelectedIcon);
			checkClipSelectedIcon = null;
			if (checkClipSelected != null)
				UI.destroy(checkClipSelected);
			checkClipSelected = null;
			if (checkClip != null)
				UI.destroy(checkClip);
			checkClip = null;
			textFormatStatusFxName = null;
		}
		
		override protected function initTextFormats():void {
			super.initTextFormats();
			textFormatStatusFxName.font = Config.defaultFontName;
			textFormatStatusFxName.size = Config.FINGER_SIZE * .24;
			textFormatStatusFxName.color = AppTheme.RED_MEDIUM;
		}
	}
}