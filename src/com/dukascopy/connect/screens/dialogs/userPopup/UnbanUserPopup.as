package com.dukascopy.connect.screens.dialogs.userPopup 
{
	import assets.IconBanPopup;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UnbanUserPopup extends UserPopup
	{
		private var bannedMark:Bitmap;
		private var reasonTitle:Bitmap;
		private var reason:Bitmap;
		private var line1:Bitmap;
		private var line2:Bitmap;
		private var moderatorAvatar:Bitmap;
		private var moderatorName:Bitmap;
		private var unbanTime:Bitmap;
		private var durationTime:Bitmap;
		private var moderatorTitle:Bitmap;
		private var moderatorBlock:Sprite;
		private var moderatorAvatarSize:Number;
		private var moderatorAvatarBD:ImageBitmapData;
		
		public function UnbanUserPopup() 
		{
			
		}
		
		override protected function preinitialize():void 
		{
			messageText = null;
			buttonRejectText = Lang.textCancel;
			buttonAcceptText = Lang.textUnban;
			iconClass = IconBanPopup;
			
			acceptButtonColor = 0x77C043;
			acceptButtonColor2 = 0x62943F;
		}
		
		override protected function createView():void
		{
			super.createView();
			
			createBannedMark();
			
			reasonTitle = new Bitmap();
			container.addChild(reasonTitle);
			
			reason = new Bitmap();
			container.addChild(reason);
			
			line1 = new Bitmap();
			line1.bitmapData = UI.getHorizontalLine(AppTheme.GREY_LIGHT);
			container.addChild(line1);
			
			line2 = new Bitmap();
			line2.bitmapData = UI.getHorizontalLine(AppTheme.GREY_LIGHT);
			container.addChild(line2);
			
			moderatorBlock = new Sprite();
			container.addChild(moderatorBlock);
			
			moderatorTitle = new Bitmap();
			moderatorBlock.addChild(moderatorTitle);
			
			moderatorAvatar = new Bitmap();
			moderatorBlock.addChild(moderatorAvatar);
			
			moderatorName = new Bitmap();
			moderatorBlock.addChild(moderatorName);
			
			durationTime = new Bitmap();
			container.addChild(durationTime);
			
			unbanTime = new Bitmap();
			container.addChild(unbanTime);
		}
		
		private function createBannedMark():void 
		{
			bannedMark = new Bitmap();
			
			
			//!TODO: переместить в UI сделать универсальную отрисовку текста на подложке с настройками;
			
			var textField:TextField = UI.getTextField();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = Config.FINGER_SIZE * .3;
			textFormat.color = MainColors.WHITE;
			
			textField.text = Lang.textBanned;
			textField.setTextFormat(textFormat);
			textField.width = textField.textWidth + 4;
			textField.height = textField.textHeight + 4;
			
			var horizontalPadding:int = Config.FINGER_SIZE * .15;
			var verticalPadding:int = Config.FINGER_SIZE * .1;
			
			var back:Shape = new Shape();
			
			textFormat.color = MainColors.WHITE;
			back.graphics.beginFill(AppTheme.GREY_DARK);
			
			var widthValue:int = Math.max((textField.width + horizontalPadding * 2), avatarSize * 2.3);
			
			back.graphics.drawRoundRect(0, 0, widthValue, textField.height + verticalPadding * 2, 0, 0);
			back.graphics.endFill();
			
			
			var bitmapData:ImageBitmapData = new ImageBitmapData("TextSelectorItem", widthValue, textField.height + verticalPadding * 2);
			bitmapData.draw(back);
			var matrix:Matrix = new Matrix();
			matrix.translate(int(widthValue*.5 - textField.width*.5), verticalPadding);
			bitmapData.draw(textField, matrix);
			
			
			bannedMark.bitmapData = bitmapData;
			container.addChild(bannedMark);
		}
		
		override protected function drawCustomContent(positionY:Number):void 
		{
			bannedMark.x = int(_width * .5 - bannedMark.width * .5);
			bannedMark.y = int(headerHeight - bannedMark.height * .5);
			
			var banData:UserBanData = additionalData as UserBanData;
			if (banData)
			{
				if (banData.reason)
				{
					drawReasonTitle(positionY);
					position += reasonTitle.height + Config.MARGIN * .5;
					positionY = position;
					
					drawReason(positionY, banData.reason);
					position += reason.height + Config.MARGIN * 2;
					positionY = position;
					
					line1.width = _width;
					line1.y = positionY;
					
					position += Config.MARGIN;
					positionY = position;
				}
				//!TODO: нет модели пользователя!;
				
				var moderatorModel:ChatUserVO;
				
				if (ChatManager.getCurrentChat().getUser(banData.moderator) != null) {
					moderatorModel = ChatManager.getCurrentChat().getUser(banData.moderator);
				}
				
				if (moderatorModel)
				{
					drawModeratorBlock(positionY, moderatorModel);
					position += moderatorBlock.height;
					positionY = position;
					
					line2.width = _width;
					line2.y = positionY;
					
					position += Config.MARGIN * 2;
					positionY = position;
				}
				
				drawTime(positionY, getBanTime(banData));
				position += durationTime.height + Config.MARGIN * 2;
				positionY = position;
			}
		}
		
		private function getBanTime(banData:UserBanData):String 
		{
			var resultText:String;
			
			if (!isNaN(banData.banEndTime) && banData.banEndTime == 0)
			{
				resultText = Lang.textPermanent;
				
			}
			else
			{
				var durationText:String = banData.getDurationText();
				var date:Date = new Date();
				date.setTime(banData.banEndTime*1000);
				resultText = "<font color='#3e4756'>" + durationText + "</font>" + "<font color='#93a2ae' size='" + int(Config.FINGER_SIZE*.26) + "'> " + Lang.textUntil + " " + date.toLocaleTimeString() + " " + date.toLocaleDateString() + "</font>";
			}
			
			return resultText;
		}
		
		private function drawTime(positionY:Number, text:String):void 
		{
			durationTime.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	_width - padding * 2, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .36, 
																	true, 
																	AppTheme.GREY_DARK, 
																	MainColors.WHITE, false, true);
			
			durationTime.x = padding;
			durationTime.y = positionY;
		}
		
		private function drawModeratorBlock(positionY:Number, moderatorModel:ChatUserVO):void 
		{
			moderatorTitle.bitmapData = TextUtils.createTextFieldData(
																	Lang.whoBanned, 
																	_width - padding * 2, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	true, 
																	AppTheme.GREY_MEDIUM, 
																	MainColors.WHITE);
			
			moderatorTitle.x = padding;
			moderatorTitle.y = Config.MARGIN;
			
			
			moderatorAvatarSize = Config.FINGER_SIZE * .28;
			moderatorAvatar.x = padding;
			moderatorAvatar.y = moderatorTitle.y + moderatorTitle.height + Config.MARGIN;
			drawModeratorAvatar(moderatorModel);
			
			moderatorName.bitmapData = TextUtils.createTextFieldData(
																	moderatorModel.name, 
																	_width - padding * 2 - moderatorAvatarSize * 2 - Config.MARGIN * .6, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .36, 
																	true, 
																	AppTheme.RED_MEDIUM, 
																	MainColors.WHITE);
			
			moderatorName.x = padding + moderatorAvatarSize * 2 + Config.MARGIN * .6;
			moderatorName.y = int(moderatorAvatar.y + moderatorAvatarSize - moderatorName.height * .5);
			
			moderatorBlock.graphics.beginFill(MainColors.WHITE);
			moderatorBlock.graphics.drawRect(0, 0, _width, moderatorTitle.y + moderatorTitle.height + Config.MARGIN * .5 + Math.max(moderatorAvatarSize * 2, moderatorName.height) + Config.MARGIN * 2);
			
			moderatorBlock.x = 0;
			moderatorBlock.y = positionY;
		}
		
		private function drawModeratorAvatar(moderatorModel:ChatUserVO):void 
		{
			if (moderatorModel.avatarURL != null && moderatorModel.avatarURL != "")
			{
				var path:String = moderatorModel.avatarURL;
				
				var smallAvatarImage:ImageBitmapData = ImageManager.getImageFromCache(path);
				
				if (smallAvatarImage)
				{
					moderatorAvatarBD = new ImageBitmapData("UnbanUserPopup.MODERATOR_AVATAR_BMD", moderatorAvatarSize * 2, moderatorAvatarSize * 2);
					ImageManager.drawCircleImageToBitmap(moderatorAvatarBD, smallAvatarImage, 0, 0, int(moderatorAvatarSize));
					moderatorAvatar.bitmapData = moderatorAvatarBD;
				}
				else
				{
					path = UsersManager.getAvatarImage(moderatorModel, path, moderatorAvatarSize * 2, 3, false);
					ImageManager.loadImage(path, onModeratorAvatarLoaded);
				}
			}
			else
			{
				//!TODO;
			}
		}
		
		private function onModeratorAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void
		{
			//TODO: отрисовать букву и в родительском классе тоже;
			
			if (isDisposed)
			{
				return;		
			}
			
			if (!success)
			{
				return;
			}
			if (bmd)
			{
				moderatorAvatarBD = new ImageBitmapData("UserPopup.LOADED_AVATAR_BMD", moderatorAvatarSize * 2, moderatorAvatarSize * 2);
				ImageManager.drawCircleImageToBitmap(moderatorAvatarBD, bmd, 0, 0, int(moderatorAvatarSize));
				moderatorAvatar.bitmapData = moderatorAvatarBD;
			}
		}
		
		private function drawReason(positionY:Number, text:String):void 
		{
			reason.bitmapData = TextUtils.createTextFieldData(
																	text, 
																	_width - padding * 2, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .36, 
																	true, 
																	AppTheme.GREY_DARK, 
																	MainColors.WHITE);
			
			reason.x = padding;
			reason.y = positionY;
		}
		
		private function drawReasonTitle(positionY:int):void 
		{
			reasonTitle.bitmapData = TextUtils.createTextFieldData(
																	Lang.textReason, 
																	_width - padding * 2, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, 
																	true, 
																	AppTheme.GREY_MEDIUM, 
																	MainColors.WHITE);
			
			reasonTitle.x = padding;
			reasonTitle.y = positionY;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
		}
		
		override public function deactivateScreen():void
		{
			if (isDisposed)
			{
				return;
			}
			super.deactivateScreen();
		}
		
		override public function dispose():void
		{
			if (isDisposed)
			{
				return;
			}
			super.dispose();
			
			if (bannedMark)
			{
				UI.destroy(bannedMark);
				bannedMark = null;
			}
			if (reasonTitle)
			{
				UI.destroy(reasonTitle);
				reasonTitle = null;
			}
			if (reason)
			{
				UI.destroy(reason);
				reason = null;
			}
			if (line1)
			{
				UI.destroy(line1);
				line1 = null;
			}
			if (line2)
			{
				UI.destroy(line2);
				line2 = null;
			}
			if (moderatorAvatar)
			{
				UI.destroy(moderatorAvatar);
				moderatorAvatar = null;
			}
			if (moderatorName)
			{
				UI.destroy(moderatorName);
				moderatorName = null;
			}
			if (unbanTime)
			{
				UI.destroy(unbanTime);
				unbanTime = null;
			}
			if (durationTime)
			{
				UI.destroy(durationTime);
				durationTime = null;
			}
			if (moderatorTitle)
			{
				UI.destroy(moderatorTitle);
				moderatorTitle = null;
			}
			if (moderatorBlock)
			{
				UI.destroy(moderatorBlock);
				moderatorBlock = null;
			}
			if (moderatorAvatarBD)
			{
				UI.disposeBMD(moderatorAvatarBD);
				moderatorAvatarBD = null;
			}
		}
	}
}