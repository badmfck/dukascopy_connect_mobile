package com.dukascopy.connect.screens.dialogs.userPopup 
{
	import assets.CloseButtonIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.errors.ApplicationError;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BanInfoPopup extends BaseScreen
	{
		private var banModel:UserBanData;
		
		private var reasonTitle:Bitmap;
		private var reason:Bitmap;
		private var line1:Bitmap;
		private var line2:Bitmap;
		private var moderatorBlock:Sprite;
		private var moderatorTitle:Bitmap;
		private var moderatorAvatar:Bitmap;
		private var moderatorName:Bitmap;
		private var durationTime:Bitmap;
		private var unbanTime:Bitmap;
		private var headerHeight:Number;
		private var padding:Number;
		private var position:Number;
		private var moderatorAvatarSize:Number;
		private var moderatorAvatarBD:ImageBitmapData;
		private var buttonClose:BitmapButton;
		private var container:Sprite;
		private var popupTitle:Bitmap;
		
		public function BanInfoPopup() 
		{
			
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			
			headerHeight = Config.FINGER_SIZE;
			
			padding = Config.MARGIN * 2;
			
			if (data is UserBanData)
			{
				banModel = data as UserBanData;
			}
			else
			{
				throw new ApplicationError(ApplicationError.BAN_INFO_POPUP_WRONG_DATA);
			}
			
			drawHeader();
			
			position = headerHeight + Config.MARGIN * 2;
			
			if (banModel.reason)
			{
				drawReasonTitle(position);
				position += reasonTitle.height + Config.MARGIN * .5;
				
				drawReason(position, banModel.reason);
				position += reason.height + Config.MARGIN * 2;
				
				line1.width = _width;
				line1.y = position;
				
				position += Config.MARGIN;
			}
			else
			{
				line1.visible = false;
			}
			
			if (banModel && banModel.moderator)
			{
				var moderatorModel:ChatUserVO = ChatManager.getCurrentChat().getUser(banModel.moderator);
				if (moderatorModel != null)
				{
					drawModeratorBlock(position, moderatorModel);
					position += moderatorBlock.height;
					
					line2.width = _width;
					line2.y = position;
					
					position += Config.MARGIN * 2;
				}
			}
			
			drawTime(position, getBanTime(banModel));
			position += durationTime.height + Config.MARGIN * 3;
		}
		
		private function drawHeader():void 
		{
			popupTitle.bitmapData = TextUtils.createTextFieldData(Lang.banDetails, _width - padding * 3 - buttonClose.width, 10, false, 
																TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .34, false, 
																Color.WHITE, /*0xAE1E1E*/Color.RED);
			
			popupTitle.x = padding;
			popupTitle.y = int(headerHeight * .5 - popupTitle.height * .5);
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
																	Style.color(Style.COLOR_TEXT), 
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			
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
																	Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND));
			
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
																	Color.RED, 
																	Style.color(Style.COLOR_BACKGROUND));
			
			moderatorName.x = padding + moderatorAvatarSize * 2 + Config.MARGIN * .6;
			moderatorName.y = int(moderatorAvatar.y + moderatorAvatarSize - moderatorName.height * .5);
			
			moderatorBlock.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
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
																	Style.color(Style.COLOR_TEXT), 
																	Style.color(Style.COLOR_BACKGROUND));
			
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
																	Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND));
			
			reasonTitle.x = padding;
			reasonTitle.y = positionY;
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
		
		protected function initCloseButton():void
		{
			var btnSize:int = Config.FINGER_SIZE*.4;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			buttonClose = new BitmapButton();
			buttonClose.setStandartButtonParams();
			buttonClose.setDownScale(1.3);
			buttonClose.setDownColor(0xFFFFFF);
			buttonClose.tapCallback = onCloseButtonClick;
			buttonClose.disposeBitmapOnDestroy = true;
			buttonClose.show();
			container.addChild(buttonClose);
			var iconClose:Sprite = getCloseButtonIcon();
			iconClose.width = iconClose.height = btnSize;
			
			var ct:ColorTransform = new ColorTransform();
			ct.color = Color.WHITE;
			iconClose.transform.colorTransform = ct;
			
			buttonClose.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "PopupDialogBase,iconClose"), true);
			buttonClose.setOverflow(btnOffset, int(btnOffset * .6), Config.FINGER_SIZE, btnOffset);
			UI.destroy(iconClose);
			iconClose = null;
		}
		
		protected function getCloseButtonIcon():Sprite 
		{
			return new CloseButtonIcon();
		}
		
		protected function onCloseButtonClick():void
		{
			DialogManager.closeDialog();
		}
		
		override protected function createView():void
		{
			super.createView();
			
			container = new Sprite();
			view.addChild(container);
			
			popupTitle = new Bitmap();
			container.addChild(popupTitle);
			
			initCloseButton();
			
			reasonTitle = new Bitmap();
			container.addChild(reasonTitle);
			
			reason = new Bitmap();
			container.addChild(reason);
			
			line1 = new Bitmap();
			line1.bitmapData = UI.getHorizontalLine(Style.color(Style.COLOR_SEPARATOR));
			container.addChild(line1);
			
			line2 = new Bitmap();
			line2.bitmapData = UI.getHorizontalLine(Style.color(Style.COLOR_SEPARATOR));
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
		
		override protected function drawView():void
		{
			updateBack();
			buttonClose.x = int(_width - padding - buttonClose.width);
			buttonClose.y = int(padding);
		}
		
		protected function updateBack():void
		{
			var backHeight:Number = position;
			
			container.graphics.clear();
			
			container.graphics.beginFill(/*0xAE1E1E*/0xcd3f43);
			container.graphics.drawRect(0, 0, _width, headerHeight);
			
			container.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			container.graphics.drawRect(0, headerHeight, _width, backHeight - headerHeight);
			
			container.graphics.endFill();
			
			container.y = int(_height*.5 - Math.min(backHeight, _height)*.5);
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			buttonClose.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (isDisposed)
			{
				return;
			}
			super.deactivateScreen();
			
			buttonClose.deactivate();
		}
		
		override public function dispose():void
		{
			if (isDisposed)
			{
				return;
			}
			super.dispose();
			
			banModel = null;
			
			if (buttonClose)
			{
				buttonClose.dispose();
				buttonClose = null;
			}
			if (popupTitle)
			{
				UI.destroy(popupTitle);
				popupTitle = null;
			}
			if (container)
			{
				UI.destroy(container);
				container = null;
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