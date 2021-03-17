package com.dukascopy.connect.gui.list.renderers {
	
	import assets.IconDone;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class ListChatUsersSelect extends ListChatUsers {
		
		private var checkClip:Sprite;
			private var checkClipSelected:Sprite;
				private var checkClipSelectedIcon:IconDone;
		
		protected var textFormatStatusFxName:TextFormat = new TextFormat();
		
		public function ListChatUsersSelect() {
			if (initialized == false) {
				initialized = true;
				avatarSize = Config.FINGER_SIZE * .4;
				leftOffset = Config.MARGIN * 1.58;
				var selectedIconR:int = Config.FINGER_SIZE * .17;
				var selectedIconSize:int = selectedIconR * 2;
				var selectedIconY:int = (Config.FINGER_SIZE - selectedIconSize) * .5;
				avatarX = selectedIconSize + leftOffset * 2;
				avatarY = (Config.FINGER_SIZE - avatarSize * 2) * .5;
				onlineIndicatorOutR = Config.FINGER_SIZE * .11;
				onlineIndicatorInR = Config.FINGER_SIZE * .08;
				onlineIndicatorX = avatarX + avatarSize * Math.cos(Math.PI / 4) + avatarSize - onlineIndicatorOutR;
				onlineIndicatorY = avatarY + avatarSize * Math.sin(Math.PI / 4) + avatarSize - onlineIndicatorOutR;
				iconSize = Config.FINGER_SIZE * .35;
			}
			super();
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
			if ((item.data as ChatUserlistModel).status == UserStatusType.SELECTED)
				checkClipSelected.visible = true;
			else if ((item.data as ChatUserlistModel).status == UserStatusType.UNSELECTED)
				checkClipSelected.visible = false;
			return this;
		}
		
		override public function dispose():void {
			UI.destroy(checkClipSelectedIcon);
			checkClipSelectedIcon = null
			UI.destroy(checkClipSelected);
			checkClipSelected = null;
			UI.destroy(checkClip);
			checkClip = null;
			textFormatStatusFxName = null;
			super.dispose();
		}
		
		override protected function initTextFormats():void {
			super.initTextFormats();
			textFormatStatusFxName.font = Config.defaultFontName;
			textFormatStatusFxName.size = Config.FINGER_SIZE * .24;
			textFormatStatusFxName.color = AppTheme.RED_MEDIUM;
		}
	}
}