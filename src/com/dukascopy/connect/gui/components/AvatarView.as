package com.dukascopy.connect.gui.components {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.UserListRenderer;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AvatarView extends Sprite {
		
		private var size:int;
		private var avatarSupport:Bitmap;
		private var avatarWithLetter:Sprite;
		private var avatarLettertext:TextField;
		private var avatarEmpty:Shape;
		private var emptyAvatarBD:ImageBitmapData;
		private var avatar:Shape;
		
		public function AvatarView(size:int) {
			this.size = size;
			
			create();
		}
		
		private function create():void {
			avatarEmpty = new Shape();
			emptyAvatarBD = UI.getEmptyAvatarBitmapData(size * 2, size * 2);
			ImageManager.drawGraphicCircleImage(avatarEmpty.graphics, 
													size, 
													size, 
													size, 
													emptyAvatarBD, 
													ImageManager.SCALE_PORPORTIONAL);
			avatarEmpty.x = 0;
			addChild(avatarEmpty);
			
			avatarWithLetter = new Sprite();
			avatarLettertext = new TextField();
			avatarWithLetter.addChild(avatarLettertext);
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = Style.color(Style.COLOR_BACKGROUND);
			textFormat.size = Config.FINGER_SIZE*.36;
			textFormat.align = TextFormatAlign.CENTER;
			avatarLettertext.defaultTextFormat = textFormat;
			avatarLettertext.selectable = false;
			avatarLettertext.width = size * 2;
			avatarLettertext.multiline = false;
			avatarLettertext.text = "A";
			avatarLettertext.height = avatarLettertext.textHeight + 4;
			avatarLettertext.y = int(size - (avatarLettertext.textHeight + 4) * .5);
			avatarLettertext.text = "";
			
			UI.drawElipseSquare(avatarWithLetter.graphics, size * 2, size, AppTheme.GREY_MEDIUM);		
			addChild(avatarWithLetter);
			avatarWithLetter.visible = false;
			
			avatarSupport = new Bitmap();
			avatarSupport.bitmapData = UI.drawAssetToRoundRect(new SWFSupportAvatar(), size * 2);
			avatarSupport.x = 0;
			addChild(avatarSupport);	
			
			avatar = new Shape();
			avatarWithLetter.x = avatar.x = avatarEmpty.x;
			addChild(avatar);
		}
		
		public function draw(itemData:Object, item:ListItem, renderer:UserListRenderer, field:String = "avatarURL"):void
		{
			avatarSupport.visible = false;
			avatar.visible = false;
			avatarEmpty.visible = false;
			avatarLettertext.visible = false;
			
			if (itemData is PhonebookUserVO || itemData is ContactVO || itemData is ChatUserVO || itemData is UserVO || itemData is IScreenAction)
			{
				avatar.visible = true;
				avatarEmpty.visible = true;
			}
			else if (itemData is EntryPointVO || itemData is MemberVO)
			{
				avatar.visible = true;
				avatarEmpty.visible = true;
			}
			else if(itemData is String)
			{
				avatar.visible = false;
				avatarEmpty.visible = false;
			}
			
			if (itemData != null && ("uid" in itemData && itemData.uid != "") || itemData is EntryPointVO || (itemData is ContactVO && (itemData as ContactVO).action != null))
				item.addImageFieldForLoading(field);
			
			avatar.visible = false;
			avatarEmpty.visible = false;
			
			var avatarImage:ImageBitmapData = item.getLoadedImage(field);
			if (avatarImage != null && avatarImage.isDisposed == false) {
				avatar.visible = true;
				avatar.graphics.clear();
				ImageManager.drawGraphicCircleImage(avatar.graphics, size, size, size, avatarImage, ImageManager.SCALE_PORPORTIONAL);
			} else {
				if (itemData != null && itemData is EntryPointVO) {
					if ((itemData as EntryPointVO).avatar && (itemData as EntryPointVO).avatar != "") {
						
					}
					avatarSupport.visible = true;
				} else {
					if (itemData != null && ("action" in itemData) && itemData.action != null && (itemData.action as IScreenAction).getIconClass() != null) {
						var actionIcon:Sprite = new ((itemData.action as IScreenAction).getIconClass())();
						avatar.visible = true;
						var customBD:ImageBitmapData;
						var bitmapName:String = "UserListRenderer." + (itemData.action as IScreenAction).getIconClass().toString();
						if (renderer.customBitmaps[bitmapName]) {
							customBD = renderer.customBitmaps[bitmapName];
						} else {
							if (actionIcon) {
								UI.scaleToFit(actionIcon, size*2, size*2);
							}
							customBD = UI.getSnapshot(actionIcon, StageQuality.HIGH, bitmapName);
							renderer.customBitmaps[bitmapName] = customBD;
						}
						ImageManager.drawGraphicCircleImage(avatar.graphics, size, size, size, customBD, ImageManager.SCALE_PORPORTIONAL);
						customBD = null;
					} else if (itemData != null && "name" in itemData && itemData.name != null && String(itemData.name).length > 0 && AppTheme.isLetterSupported(String(itemData.name).charAt(0))) {
						avatarLettertext.text = String(itemData.name).charAt(0).toUpperCase();
						UI.drawElipseSquare(avatarWithLetter.graphics, size*2,size,AppTheme.getColorFromPallete(String(itemData.name)));
						avatarWithLetter.visible = true;
						avatarEmpty.visible = false;
					} else {
						avatarEmpty.visible = true;
					}
				}
			}
		}
		
		public function dispose():void {
			if (avatar != null)
				avatar.graphics.clear();
			UI.destroy(avatar);
			avatar = null;
			if (avatarEmpty != null)
				avatarEmpty.graphics.clear();
			UI.destroy(avatarEmpty);
			avatarEmpty = null;
			if (avatarSupport)
				UI.destroy(avatarSupport);
			avatarSupport = null;
			if (avatarLettertext)
				avatarLettertext.text = "";
			avatarLettertext = null;
			if (avatarWithLetter)
				UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
		}
	}
}