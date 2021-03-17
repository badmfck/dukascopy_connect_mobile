package com.dukascopy.connect.screens.userProfile 
{
	import assets.EditIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.EditUserNameDialog;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.UserProfileVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserSearchResult extends Sprite
	{
		public var tap:Function;
		private var avatarSize:Number;
		private var iconInSystem:IconLogoCircle;
		private var avatar:Sprite;
		private var title:Bitmap;
		private var subtitle:Bitmap;
		private var data:ContactVO;
		private var itemWidth:int;
		private var itemHeight:int;
		private var back:Sprite;
		private var editUserNameButton:BitmapButton;
		private var currentNameValue:String;
		private var titleContainer:Sprite;
		private var subtitleContainer:Sprite;
		private var customNameValue:String;
		
		public function UserSearchResult() 
		{
			construct();
		}
		
		private function construct():void 
		{
			avatarSize = Config.FINGER_SIZE * .4;
			
			back = new Sprite();
			back.graphics.beginFill(MainColors.WHITE);
			back.graphics.drawRect(0, 0, 10, 10);
			back.graphics.endFill();
			
			avatar = new Sprite();
			addChild(avatar);
			
			title = new Bitmap();
			titleContainer = new Sprite();
			addChild(titleContainer);
			titleContainer.addChild(title);
			
			subtitle = new Bitmap();
			subtitleContainer = new Sprite();
			addChild(subtitleContainer);
			subtitleContainer.addChild(subtitle);
			
			iconInSystem = new IconLogoCircle();
			iconInSystem.width = Config.FINGER_SIZE * 0.28;
			iconInSystem.height = Config.FINGER_SIZE * 0.28;
			iconInSystem.visible = true;
			addChild(iconInSystem);
			
			editUserNameButton = new BitmapButton();
			editUserNameButton.usePreventOnDown = false;
			editUserNameButton.setStandartButtonParams();
			editUserNameButton.setDownScale(1);
			editUserNameButton.setDownColor(0xFFFFFF);
			editUserNameButton.tapCallback = editName;
			editUserNameButton.disposeBitmapOnDestroy = true;
			editUserNameButton.show();
			addChild(editUserNameButton);
			
			var editIcon:EditIcon = new EditIcon();
			UI.scaleToFit(editIcon, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
			editUserNameButton.setBitmapData(UI.getSnapshot(editIcon, StageQuality.HIGH, "SettingsScreen.editUsernameButton"), true);
			
			var horizontalOverflow:int = Math.max(0, (Config.FINGER_SIZE - editUserNameButton.width) * .5);
			var verticalOverflow:int = Math.max(0, (Config.FINGER_SIZE - editUserNameButton.height) * .5);
			editUserNameButton.setHitZone(editUserNameButton.width, editUserNameButton.height);
			editUserNameButton.setOverflow(verticalOverflow, horizontalOverflow, horizontalOverflow, verticalOverflow);
		}
		
		private function editName():void 
		{
			DialogManager.showDialog(EditUserNameDialog, { callBack:
				function(val:int, name:String):void
				{
					if (val == 1)
					{
						if (name != null && name != "")
						{
							currentNameValue = name;
							customNameValue = name;
							draw(data, itemWidth, itemHeight);
						}
					}
				}, title:Lang.enterName, buttonOk: Lang.confirm, curentValue:currentNameValue} );
		}
		
		public function draw(data:ContactVO, itemWidth:int, itemHeight:int):void
		{
			this.itemWidth = itemWidth;
			this.itemHeight = itemHeight;
			
			this.data = data;
			
			clean();
			
			back.width = itemWidth;
			back.height = itemHeight;
			
			if (data) {
				if (customNameValue != null)
					currentNameValue = customNameValue;
				else
					currentNameValue = data.name;
				
				var path:String = data.avatarURL;
				
				if (path)
					ImageManager.loadImage(path, onAvatarLoaded);
				else
					displaySimpleAvatar(currentNameValue);
				
				avatar.y = int(itemHeight*.5 - avatarSize)
				
				editUserNameButton.visible = false;
				
				var titleWidth:int = itemWidth - iconInSystem.width - avatar.x - avatarSize * 2 - Config.MARGIN * 3;
				var titleString:String = currentNameValue;
				if (titleString == "") {
					editUserNameButton.visible = true;
					titleWidth -= editUserNameButton.width - Config.MARGIN;
					titleString = Lang.nameNotSet;
				}
				
				var titleHeight:int = Config.FINGER_SIZE * .36;
				var subtitleHeight:int = Config.FINGER_SIZE * .27;
				
				var subtitleText:String = "";
				if (data.fxName != null)
					subtitleText += '<font color="#d92626">' + data.fxName + ' </font>';
				
				if (!isNaN(data.getPhone()))
					subtitleText += '<font color="#93a2ae">+' + data.getPhone().toString() + '</font>';
				
				title.bitmapData = TextUtils.createTextFieldData(titleString, titleWidth, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, titleHeight, false, MainColors.DARK_BLUE, MainColors.WHITE);
				
				if (subtitleText != null)
					subtitle.bitmapData = TextUtils.createTextFieldData(subtitleText, itemWidth - iconInSystem.width, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, subtitleHeight, false, AppTheme.RED_MEDIUM, MainColors.WHITE, false, true);
				
				titleContainer.y = int(itemHeight * .5 - (titleHeight + subtitleHeight + Config.MARGIN ) * .5);
				subtitleContainer.y = int(titleContainer.y + titleHeight + subtitleHeight - subtitle.height + Config.MARGIN);
				
				titleContainer.x = int(subtitleContainer.x = avatar.x + avatarSize * 2 + Config.MARGIN * 2);
				
				iconInSystem.x = int(itemWidth - iconInSystem.width);
				iconInSystem.y = int(itemHeight * .5 - iconInSystem.height * .5);
				
				editUserNameButton.x = int(titleContainer.x + title.width + Config.MARGIN);
				editUserNameButton.y = int(titleContainer.y + title.height * .5 - editUserNameButton.height * .5);
			}
		}
		
		public function getHeight():int 
		{
			return itemHeight;
		}
		
		private function displaySimpleAvatar(text:String):void 
		{
			if(text != null && text.length > 0 && AppTheme.isLetterSupported(text.charAt(0)))
			{
				var avatarLettertext:TextField = new TextField();
				avatar.addChild(avatarLettertext);
				var textFormat:TextFormat = new TextFormat();
				textFormat.font = Config.defaultFontName;
				textFormat.color = MainColors.WHITE;
				textFormat.size = Config.FINGER_SIZE*.36;
				textFormat.align = TextFormatAlign.CENTER;
				avatarLettertext.defaultTextFormat = textFormat;
				avatarLettertext.selectable = false;
				avatarLettertext.width = avatarSize * 2;
				avatarLettertext.multiline = false;
				avatarLettertext.text = text.charAt(0).toUpperCase();
				avatarLettertext.height = avatarLettertext.textHeight + 4;
				avatarLettertext.y = int(avatarSize - (avatarLettertext.textHeight + 4) * .5);			
				UI.drawElipseSquare(avatar.graphics, avatarSize*2, avatarSize, AppTheme.getColorFromPallete(text));		
				avatar.graphics.endFill();
				
			}
			else
			{
				ImageManager.drawGraphicCircleImage(avatar.graphics, 
													avatarSize, 
													avatarSize, 
													avatarSize, 
													UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2), 
													ImageManager.SCALE_PORPORTIONAL);
			}
		}
		
		private function onAvatarLoaded(url:String, bitmapData:ImageBitmapData, success:Boolean):void 
		{
			if (!success)
			{
				displaySimpleAvatar(currentNameValue);
			}
			else
			{
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, bitmapData, ImageManager.SCALE_PORPORTIONAL);
			}
		}
		
		public function activate():void
		{
			editUserNameButton.activate();
			PointerManager.addDown(avatar, onDown);
			PointerManager.addDown(titleContainer, onDown);
			PointerManager.addDown(subtitleContainer, onDown);
		}
		
		public function deactivate():void
		{
			editUserNameButton.deactivate();
			PointerManager.removeDown(avatar, onDown);
			PointerManager.removeDown(titleContainer, onDown);
			PointerManager.removeDown(subtitleContainer, onDown);
		}
		
		private function onDown(e:Event):void 
		{
			if (tap)
			{
				tap.call();
			}
		}
		
		public function dispose():void
		{
			if (avatar)
			{
				UI.destroy(avatar);
				avatar = null;
			}
			
			if (titleContainer)
			{
				UI.destroy(titleContainer);
				titleContainer = null;
			}
			
			if (subtitleContainer)
			{
				UI.destroy(subtitleContainer);
				subtitleContainer = null;
			}
			
			if (iconInSystem)
			{
				UI.destroy(iconInSystem);
				iconInSystem = null;
			}
			
			if (title)
			{
				UI.destroy(title);
				title = null;
			}
			
			if (subtitle)
			{
				UI.destroy(subtitle);
				subtitle = null;
			}
			
			if (editUserNameButton)
			{
				editUserNameButton.dispose();
				editUserNameButton = null;
			}
			
			tap = null;
		}
		
		public function clean():void 
		{
			avatar.graphics.clear();
			avatar.removeChildren();
			
			if (title.bitmapData)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			if (subtitle.bitmapData)
			{
				subtitle.bitmapData.dispose();
				subtitle.bitmapData = null;
			}
			
			tap = null;
		}
		
		public function getData():ContactVO 
		{
			return data;
		}
	}
}