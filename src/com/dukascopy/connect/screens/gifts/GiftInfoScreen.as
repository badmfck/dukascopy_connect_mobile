package com.dukascopy.connect.screens.gifts
{
	
	import assets.Confeti;
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.*;
	import com.greensock.TweenMax;
	import fl.motion.Color;
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class GiftInfoScreen extends BaseScreen
	{
		private var background:Sprite;
		private var doneButton:BitmapButton;
		private var locked:Boolean = false;
		private var giftData:GiftData;
		private var giftImage:Bitmap;
		private var title:Bitmap;
		private var userName:Bitmap;
		private var avatarBD:ImageBitmapData;
		private var comment:Bitmap;
		private var avatarSize:int;
		private var avatar:Bitmap;
		private var fxName:Bitmap;
		private var colors:Array;
		private var confeti:Confeti;
		
		public function GiftInfoScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = true;
			
			avatarSize = Config.FINGER_SIZE * .8;
			
			if (data != null && "giftModel" in data && data.giftModel != null)
			{
				giftData = data.giftModel as GiftData;
			}
			
			if (giftData == null)
			{
				ApplicationErrors.add("empty giftData");
				ServiceScreenManager.closeView();
				return;
			}
			
			colors = Gifts.getColors(giftData.type);
			
			drawBackground();
			drawTitle();
			drawUsername();
			drawDoneButton();
			drawGift();
			drawComment();
			drawFxName();
			drawAvatar();
		}
		
		private function drawBackground():void 
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_width, _height, Math.PI / 2);
			background.graphics.beginGradientFill(GradientType.LINEAR, colors, [1, 1], [0x00, 0xFF], matrix);
			background.graphics.drawRect(0, 0, _width, _height);
			
			UI.scaleToFit(confeti, _width, _height);
		}
		
		private function drawGift():void 
		{
			var giftClip:Sprite = Gifts.getGiftImage(giftData.type);
			if (giftClip != null)
			{
				UI.scaleToFit(giftClip, Config.FINGER_SIZE * 4.5, Config.FINGER_SIZE * 4.5);
				var color:Color = new Color();
				color.setTint(colors[1], 0.20);
				giftClip.transform.colorTransform = color;
				giftClip.rotation = 30 * Math.PI / 180;
				giftImage.bitmapData = UI.getSnapshot(giftClip);
				giftImage.x = _width - giftImage.width * 0.8;
				giftImage.y = -giftImage.height * .1;
			}
		}
		
		private function drawTitle():void 
		{
			var currency:String = "€";
			if (giftData.type == GiftType.GIFT_X && giftData.currency != TypeCurrency.EUR && giftData.currency != null && giftData.currency != "")
			{
				if (giftData.currency == "DCO")
				{
					currency = "DUK+ ";
				}
				else
				{
					currency = giftData.currency + " ";
				}
			}
			
			var str:String = Lang.youWerePraisedAndSendGift;
			str = LangManager.replace(Lang.regExtValue, str, giftData.getValue().toString());
			str = LangManager.replace(Lang.regExtValue, str, currency);
			title.bitmapData = TextUtils.createTextFieldData(
															str, 
															_width - Config.DOUBLE_MARGIN * 4, 
															10, 
															true, 
															TextFormatAlign.CENTER, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .36, 
															true, 0xFFFFFF, 0, true);
			title.x = int(_width * .5 - title.width * .5);
		}
		
		private function drawComment():void 
		{
			if (giftData.comment != null && giftData.comment != "")
			{
				comment.bitmapData = TextUtils.createTextFieldData(
															giftData.comment, 
															_width - Config.DOUBLE_MARGIN * 2, 
															Config.FINGER_SIZE*3, 
															true, 
															TextFormatAlign.CENTER, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .36, 
															true, 0xFFFFFF, 0, true);
				comment.x = int(_width * .5 - comment.width * .5);
			}
		}
		
		private function drawDoneButton():void 
		{
			var textDone:TextFieldSettings = new TextFieldSettings(Lang.done, 0xFFFFFF, Config.FINGER_SIZE * .35, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textDone, 0x81CA2E, 0, Config.FINGER_SIZE * .8, 0xFFFFFF);
			doneButton.setBitmapData(buttonBitmap);
		}
		
		private function drawUsername():void 
		{
			var userNameText:String;
			if (giftData.recieverSecret == true)
			{
				userNameText = Lang.textIncognito;
			}
			else {
				userNameText = giftData.user.getDisplayName();
			}
			
			userName.bitmapData = TextUtils.createTextFieldData(
															userNameText, 
															_width - Config.DOUBLE_MARGIN * 2, 
															10, 
															true, 
															TextFormatAlign.CENTER, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .40, 
															true, 0xFFFFFF, 0, true);
			userName.x = int(_width * .5 - userName.width * .5);
		}
		
		private function drawFxName():void 
		{
			if (giftData.recieverSecret == true)
			{
				return;
			}
			
			var text:String;
			if (giftData.user.phone != null && giftData.user.phone != "")
			{
				text = "+" + giftData.user.phone;
			}
			else if (giftData.user.login != null)
			{
				text = giftData.user.login;
			}
			if (text != null && text != "")
			{
				var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFCDCC, Config.FINGER_SIZE * .22, TextFormatAlign.CENTER);
				var bd:ImageBitmapData = TextUtils.createbutton(textSettings, 0xDB2728, 1, Config.FINGER_SIZE * .2, NaN, -1, Config.FINGER_SIZE*.03);
				fxName.bitmapData = bd;
				fxName.x = int(_width * .5 - fxName.width * .5);
			}
		}
		
		private function drawAvatar():void
		{
			var avatarUrl:String = giftData.user.getAvatarURL();
			
			if (giftData.recieverSecret == true)
			{
				avatarUrl = LocalAvatars.SECRET;
			}
			
			avatar.x = int(_width * .5 - avatarSize);
			
			if (avatarUrl != null && avatarUrl != "")
			{
				var path:String;
				
				//!TODO: можно складывать все загруженные на данный момент аватарки относящиеся к пользователю в один менеджер и выбирать наиболее подходящую;
				var smallAvatarImage:ImageBitmapData;
				if (!smallAvatarImage)
				{
					//берём маленькую аватарку из списка контактов;
					path = UsersManager.getAvatarImage(giftData.user, avatarUrl, int(Config.FINGER_SIZE * .7), 3);
					smallAvatarImage = ImageManager.getImageFromCache(path);
				}
				if (!smallAvatarImage)
				{
					//берём маленькую аватарку по умолчанию (размер 60px если она из коммуны);
					smallAvatarImage = ImageManager.getImageFromCache(avatarUrl);
				}
				
				if (smallAvatarImage)
				{
					avatarBD = new ImageBitmapData("CreateGiftPopup.LOADED_AVATAR_BMD", avatarSize * 2, avatarSize * 2);
					ImageManager.drawCircleImageToBitmap(avatarBD, smallAvatarImage, 0, 0, int(avatarSize));
					avatar.bitmapData = avatarBD;
				}
				else
				{
					path = UsersManager.getAvatarImage(giftData.user, avatarUrl, avatarSize * 2, 3, false);
					ImageManager.loadImage(path, onAvatarLoaded);
				}
			}
			else
			{
				//avatarBD = UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
				avatarBD = UI.drawAssetToRoundRect(new SWFEmptyAvatar(), avatarSize * 2);
				avatar.bitmapData = avatarBD;
			}
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void
		{
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
				avatarBD = new ImageBitmapData("CreateGiftPopup.LOADED_AVATAR_BMD", avatarSize * 2, avatarSize * 2);
				ImageManager.drawCircleImageToBitmap(avatarBD, bmd, 0, 0, int(avatarSize));
				avatar.alpha = 0;
				TweenMax.to(avatar, 0.5, {alpha: 1, delay:0.5});
				avatar.bitmapData = avatarBD;
			}
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			confeti = new Confeti();
			view.addChild(confeti);
			confeti.alpha = 0.3;
			
			doneButton = new BitmapButton();
			doneButton.setStandartButtonParams();
			doneButton.setDownScale(1);
			doneButton.setDownColor(0xFFFFFF);
			doneButton.tapCallback = skipClick;
			doneButton.disposeBitmapOnDestroy = true;
			doneButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			view.addChild(doneButton);
			
			giftImage = new Bitmap();
			view.addChild(giftImage);
			
			title = new Bitmap();
			view.addChild(title);
			
			comment = new Bitmap();
			view.addChild(comment);
			
			userName = new Bitmap();
			view.addChild(userName);
			
			avatar = new Bitmap();
			view.addChild(avatar);
			
			fxName = new Bitmap();
			view.addChild(fxName);
		}
		
		private function skipClick():void 
		{
			ServiceScreenManager.closeView();
		}
		
		private function onButtonCancelClick():void {
			ServiceScreenManager.closeView();
		}
		
		private function lockScreen():void {
			locked = true;
		}
		
		private function unlockScreen():void {
			locked = false;
		}
		
		override protected function drawView():void {
			super.drawView();
			
			var position:int = _height;
			position = _height - Config.MARGIN * 3 - doneButton.height;
			
			doneButton.x = int(_width * .5 - doneButton.width * .5);
			doneButton.y = position;
			
			if (giftData.comment != null && giftData.comment != "")
			{
				position -= comment.height + Config.FINGER_SIZE * .5;
				comment.y = position;
			}
			else
			{
				position -= Config.FINGER_SIZE * 1.5;
			}
			
			position -= Config.FINGER_SIZE * .5;
			
			if ((giftData.user.phone != null && giftData.user.phone != "") || giftData.user.login != null)
			{
				position -= fxName.height;
				fxName.y = position;
			}
			
			position -= userName.height + Config.MARGIN;
			userName.y = position;
			
			position -= avatarSize * 2 + Config.DOUBLE_MARGIN;
			avatar.y = position;
			
			position -= title.height + Config.DOUBLE_MARGIN * 2;
			title.y = position;
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			if (isDisposed)
			{
				return;
			}
			
			super.dispose();
			
			Overlay.removeCurrent();
			
			if (background)
			{
				UI.destroy(background);
				background = null;
			}
			if (title)
			{
				UI.destroy(title);
				title = null;
			}
			if (userName)
			{
				UI.destroy(userName);
				userName = null;
			}
			if (fxName)
			{
				UI.destroy(fxName);
				fxName = null;
			}
			if (avatar)
			{
				UI.destroy(avatar);
				avatar = null;
			}
			if (giftImage)
			{
				UI.destroy(giftImage);
				giftImage = null;
			}
			if (comment)
			{
				UI.destroy(comment);
				comment = null;
			}
			if (doneButton)
			{
				doneButton.dispose();
				doneButton = null;
			}
			if (avatarBD != null)
			{
				UI.disposeBMD(avatarBD);
				avatarBD = null;
			}
			if (confeti != null)
			{
				UI.destroy(confeti);
				confeti = null;
			}
			
			colors = null;
			
			giftData = null;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			if (locked)
			{
				return;
			}
			
			doneButton.activate();
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed)
			{
				return;
			}
		}
	}
}