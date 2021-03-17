package com.dukascopy.connect.screens.dialogs.bot 
{
	import assets.IconInfoClip;
	import assets.NextArrowIcon2;
	import assets.ProtectionAddedIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.BotProfileScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.swiper.Swiper;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.BotVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class BotInfoPopup extends BaseScreen
	{
		protected var container:Sprite;
		private var bg:Shape;
		private var backButton:BitmapButton;
		private var avatar:CircleAvatar;
		private var avatarSize:int;
		private var botName:flash.display.Bitmap;
		private var subscribeText:flash.display.Bitmap;
		private var subscribeNum:flash.display.Bitmap;
		private var infoButton:com.dukascopy.connect.gui.menuVideo.BitmapButton;
		private var openChatButton:RoundedButton;
		private var ownerText:flash.display.Bitmap;
		private var ownerAvatar:com.dukascopy.connect.gui.chat.CircleAvatar;
		private var ownerName:flash.display.Bitmap;
		private var botModel:com.dukascopy.connect.vo.users.adds.BotVO;
		private var description:flash.display.Bitmap;
		private var ownerClip:flash.display.Sprite;
		private var componentsWidth:Number;
		private var verticalMargin:Number;
		private var nextArrow:assets.NextArrowIcon2;
		private var ownerAvatarSize:Number;
		private var padding:int;
		private var leftPadding:int;
		private var ownerButton:com.dukascopy.connect.gui.menuVideo.BitmapButton;
		private var swiper:com.dukascopy.connect.sys.swiper.Swiper;
		
		public function BotInfoPopup() {
			
		}
		
		override protected function createView():void {
			
			super.createView();
			
			avatarSize = Config.FINGER_SIZE * .7;
			ownerAvatarSize = Config.FINGER_SIZE * .4;
			
			container = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
			avatar = new CircleAvatar();
			container.addChild(avatar);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			container.addChild(backButton);
			
			ownerButton = new BitmapButton();
			ownerButton.setStandartButtonParams();
			ownerButton.setDownScale(1);
			ownerButton.setDownColor(0);
			ownerButton.tapCallback = ownerClick;
			ownerButton.disposeBitmapOnDestroy = true;
			container.addChild(ownerButton);
			
			botName = new Bitmap();
			container.addChild(botName);
			
			description = new Bitmap();
			container.addChild(description);
			
			subscribeNum = new Bitmap();
			container.addChild(subscribeNum);
			
			subscribeText = new Bitmap();
			container.addChild(subscribeText);
			
			infoButton = new BitmapButton();
			infoButton.setStandartButtonParams();
			infoButton.setDownScale(1);
			infoButton.setDownColor(0);
			infoButton.tapCallback = infoClick;
			infoButton.disposeBitmapOnDestroy = true;
			container.addChild(infoButton);
			
			openChatButton = new RoundedButton(Lang.open, 0x77C043, 0x77C043, null, Config.FINGER_SIZE * .1, 0, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .28);
			openChatButton.setStandartButtonParams();
			openChatButton.setDownScale(1);
			openChatButton.cancelOnVerticalMovement = true;
			openChatButton.tapCallback = openChatClick;
			container.addChild(openChatButton);
			
			ownerText = new Bitmap();
			container.addChild(ownerText);
			
			ownerClip = new Sprite();
		//	container.addChild(ownerClip);
			
			ownerAvatar = new CircleAvatar();
			ownerClip.addChild(ownerAvatar);
			
			ownerName = new Bitmap();
			ownerClip.addChild(ownerName);
			
			nextArrow = new NextArrowIcon2();
			ownerClip.addChild(nextArrow);
			
			_view.addChild(container);
			
			/*stickersSM = new ScreenManager("Stickers");
				stickersSM.setBackground(false);
			_view.addChild(stickersSM.view);
			stickersGroupsBG = new Shape();
				stickersGroupsBG.graphics.beginFill(0xECEEEF);
				stickersGroupsBG.graphics.drawRect(0, 0, 1, 1);
				stickersGroupsBG.graphics.endFill();
			_view.addChild(stickersGroupsBG);
			
			swiper = new Swiper("BotInfoScreen");*/
		}
		
		private function ownerClick():void 
		{
			if (botModel.owner == null)
			{
				return;
			}
			MobileGui.changeMainScreen(UserProfileScreen, {data:botModel.owner,
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:MobileGui.centerScreen.currentScreen.data});
			
			DialogManager.closeDialog();
		}
		
		private function openChatClick():void 
		{
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.usersUIDs = [botModel.uid];
			chatScreenData.type = ChatInitType.USERS_IDS;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
			
			DialogManager.closeDialog();
		}
		
		private function infoClick():void 
		{
			MobileGui.changeMainScreen(
				BotProfileScreen,
				{
					data:botModel, 
					backScreen:MobileGui.centerScreen.currentScreenClass, 
					backScreenData:MobileGui.centerScreen.currentScreen.data
				}
			);
			
			DialogManager.closeDialog();
		}
		
		private function backClick():void 
		{
			DialogManager.closeDialog();
		}
		
		override public function onBack(e:Event = null):void {
			DialogManager.closeDialog();
		}
		
		private function nextClick():void {
			onBack();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		private function drawAvatar():void {
			avatar.x = int(_width - avatarSize * 2 - padding);
			avatar.y = padding;
			avatar.setData(null, avatarSize, false, false, botModel.bigAvatarURL);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && data is BotVO) {
				botModel = data as BotVO;
			}
			
			padding = Config.FINGER_SIZE * .25;
			leftPadding = Config.FINGER_SIZE * .3;
			
			componentsWidth = _width - padding - leftPadding;
			
			drawBotName();
			drawBotDescription();
			drawAvatar();
			
			drawSubscribeButton();
			drawInfoButton();
			
			drawSubscribersNum();
			drawSubscribersText();
			
			drawOwnerText();
			drawOwnerClip();
			drawBackButton();
			
			var position:int = Config.FINGER_SIZE * .3;
			
			botName.x = leftPadding;
			botName.y = position;
			position += botName.height + Config.FINGER_SIZE * .3;
			
			description.x = leftPadding;
			description.y = position;
			
			position = int(Math.max(description.y + description.height + 6, avatar.y + avatarSize * 2) + Config.FINGER_SIZE * .5);
			
			subscribeNum.x = leftPadding;
			subscribeNum.y = position;
			
			openChatButton.x = int(componentsWidth - openChatButton.getWidth() + leftPadding);
			infoButton.x = int(openChatButton.x - infoButton.width - Config.FINGER_SIZE * .13);
			infoButton.y = int(openChatButton.y = position - Config.FINGER_SIZE * .1);
			
			position += subscribeNum.height + Config.FINGER_SIZE * .18;
			
			subscribeText.x = leftPadding;
			subscribeText.y = position;
			position += subscribeText.height + Config.FINGER_SIZE * .4;
			
			ownerText.x = leftPadding;
			ownerText.y = position;
			position += ownerText.height + Config.FINGER_SIZE * .16;
			
			ownerButton.x = leftPadding;
			ownerButton.y = position;
			position += ownerButton.height + Config.FINGER_SIZE * .4;
			
			backButton.x = int(_width * .5 - backButton.width * .5);
			backButton.y = position;
			position += Config.FINGER_SIZE * .7;
			
			var bgDrawPosition:int = int(Math.max(description.y + description.height, avatar.y + avatarSize * 2) + Config.FINGER_SIZE * .07);
			bg.graphics.clear();
			bg.graphics.beginFill(0xF5F7FA);
			bg.graphics.drawRect(0, 0, _width, bgDrawPosition);
			bg.graphics.endFill();
			
			var gradientHeight:int = Config.FINGER_SIZE * .2;
			var colors:Array = [0xF5F7FA, 0xDFE1E4];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_width, gradientHeight, Math.PI / 2, 0, bgDrawPosition);
			bg.graphics.beginGradientFill(GradientType.LINEAR, colors, [1, 1], [0x00, 0xFF], matrix);
			bg.graphics.drawRect(0, bgDrawPosition, _width, gradientHeight);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bgDrawPosition + gradientHeight, _width, position - bgDrawPosition + gradientHeight);
			bg.graphics.endFill();
			
			container.y = int(_height * .5 - position * .5);
		}
		
		private function drawOwnerClip():void 
		{
			var clipHeight:int = int(Config.FINGER_SIZE * 1);
			
			ownerClip.graphics.clear();
			ownerClip.graphics.beginFill(0xE5F1FF);
			ownerClip.graphics.drawRoundRect(0, 0, componentsWidth, clipHeight, Config.FINGER_SIZE * .1, Config.FINGER_SIZE * .1);
			ownerClip.graphics.endFill();
			
			ownerAvatar.setData(botModel.owner, ownerAvatarSize);
			
			if (ownerName.bitmapData != null) {
				ownerName.bitmapData.dispose();
				ownerName.bitmapData = null;
			}
			
			var ownerNameText:String;
			if (botModel != null && botModel.owner != null)
			{
				ownerNameText = botModel.owner.getDisplayName();
			}
			else
			{
				ownerNameText = Lang.textOwner;
			}
			
			UI.scaleToFit(nextArrow, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
			nextArrow.x = int(_width - padding * 2 - Config.MARGIN * 2.5 - nextArrow.width);
			nextArrow.y = int(clipHeight * .5 - nextArrow.height * .5);
			
			ownerName.bitmapData = TextUtils.createTextFieldData(
														ownerNameText, componentsWidth - ownerAvatarSize*2 - nextArrow.width - Config.MARGIN * 3, 10, false, TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, 
														false, 0x8192A4, 0xE5F1FF, true);
			
			ownerAvatar.x = Config.MARGIN;
			ownerAvatar.y = int(clipHeight * .5 - ownerAvatarSize);
			ownerName.x = int(ownerAvatar.x + ownerAvatarSize * 2 + Config.MARGIN * 1.5);
			ownerName.y = int(clipHeight * .5 - ownerName.height * .5);
			
			ownerButton.setBitmapData(UI.getSnapshot(ownerClip, StageQuality.HIGH, "BotInfoPopup.ownerButton"), true);
		}
		
		private function drawOwnerText():void 
		{
			if (ownerText.bitmapData != null) {
				ownerText.bitmapData.dispose();
				ownerText.bitmapData = null;
			}
			
			ownerText.bitmapData = TextUtils.createTextFieldData(
														Lang.textOwner + ":", componentsWidth, 10, false, TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, 
														false, 0x6F7C8C, 0xFFFFFF, true);
		}
		
		private function drawSubscribersText():void 
		{
			if (subscribeText.bitmapData != null) {
				subscribeText.bitmapData.dispose();
				subscribeText.bitmapData = null;
			}
			
			subscribeText.bitmapData = TextUtils.createTextFieldData(
														Lang.subscribers, componentsWidth - infoButton.width - openChatButton.width - Config.MARGIN * 2, 10, 
														false, TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .22, 
														false, 0x6F7C8C, 0xFFFFFF, true);
		}
		
		private function drawSubscribeButton():void 
		{
			openChatButton.draw();
		//	openChatButton.setBitmapData(TextUtils.butt);
		}
		
		private function drawInfoButton():void 
		{
			var clip:Sprite = new Sprite();
			clip.graphics.beginFill(0x93B2C9);
			clip.graphics.drawRoundRect(0, 0, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .8, Config.FINGER_SIZE*.1, Config.FINGER_SIZE*.1);
			clip.graphics.endFill();
			
			var icon:IconInfoClip = new IconInfoClip();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			clip.addChild(icon);
			icon.x = int(Config.FINGER_SIZE * .4 - icon.width * .5);
			icon.y = int(Config.FINGER_SIZE * .4 - icon.height * .5);
			
			infoButton.setBitmapData(UI.getSnapshot(clip, StageQuality.HIGH, "BotInfoPopup.infoButton"), true);
			
			UI.destroy(clip);
		}
		
		private function drawSubscribersNum():void 
		{
			if (subscribeNum.bitmapData != null) {
				subscribeNum.bitmapData.dispose();
				subscribeNum.bitmapData = null;
			}
			
			subscribeNum.bitmapData = TextUtils.createTextFieldData(
														botModel.chatCnt.toString(), componentsWidth - infoButton.width - openChatButton.width -Config.MARGIN * 2, 
														10, false, TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .46, 
														false, 0x6F7C8C, 0xFFFFFF, true);
		}
		
		private function drawBotName():void 
		{
			if (botName.bitmapData != null) {
				botName.bitmapData.dispose();
				botName.bitmapData = null;
			}
			
			botName.bitmapData = TextUtils.createTextFieldData(
														botModel.getDisplayName(), componentsWidth - leftPadding - padding - avatarSize*2, 10, true, TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .36, 
														true, 0x657280, 0xF5F7FA, true);
		}
		
		private function drawBotDescription():void 
		{
			if (description.bitmapData != null) {
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			var text:String = botModel.description;
			if (text != null && text.length > 300)
			{
				text = text.slice(0, 300);
			}
			
			if (text != null && text != "")
			{
				description.bitmapData = TextUtils.createTextFieldData(
														text, componentsWidth - leftPadding - padding - avatarSize * 2, 
														10, true,
														TextFormatAlign.LEFT, 
														TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .25, 
														true, 0x8190A3, 0xF5F7FA, true);
			}
		}
		
		private function drawProtectionInfo():void {
			if (description.bitmapData != null) {
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			var text:String = Lang.paidBanProtectionWillBeValidFor;
			
			description.bitmapData = TextUtils.createTextFieldData(
														text, componentsWidth, 10, false, TextFormatAlign.CENTER, 
														TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, 
														true, 0x76848C, 0xDEDEDE, true);
		}
		
		private function drawBackButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x6B7587, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, 0x6B7587, (componentsWidth - padding) * .5);
			backButton.setBitmapData(buttonBitmap, true);
			backButton.x = int(_width * .5 - backButton.width * .5);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			backButton.activate();
			infoButton.activate();
			openChatButton.activate();
			ownerButton.activate();
			
			/*if (swiper != null) {
				swiper.S_ON_SWIPE.add(onSwipe);
				swiper.activate();
				swiper.setBounds(_width, _height, MobileGui.stage, 0, stickersSM.view.localToGlobal(new Point()).y);
			}*/
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			infoButton.deactivate();
			openChatButton.deactivate();
			ownerButton.deactivate();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (backButton != null) {
				backButton.dispose();
				backButton = null;
			}
			if (avatar != null) {
				avatar.dispose();
				avatar = null;
			}
			if (infoButton != null) {
				infoButton.dispose();
				infoButton = null;
			}
			if (openChatButton != null) {
				openChatButton.dispose();
				openChatButton = null;
			}
			if (ownerAvatar != null) {
				ownerAvatar.dispose();
				ownerAvatar = null;
			}
			if (ownerButton != null) {
				ownerButton.dispose();
				ownerButton = null;
			}
			if (container != null) {
				UI.destroy(container);
				container = null;
			}
			if (bg != null) {
				UI.destroy(bg);
				bg = null;
			}
			if (botName != null) {
				UI.destroy(botName);
				botName = null;
			}
			if (subscribeText != null) {
				UI.destroy(subscribeText);
				subscribeText = null;
			}
			if (subscribeNum != null) {
				UI.destroy(subscribeNum);
				subscribeNum = null;
			}
			if (ownerText != null) {
				UI.destroy(ownerText);
				ownerText = null;
			}
			if (ownerName != null) {
				UI.destroy(ownerName);
				ownerName = null;
			}
			if (description != null) {
				UI.destroy(description);
				description = null;
			}
			if (ownerClip != null) {
				UI.destroy(ownerClip);
				ownerText = null;
			}
			if (nextArrow != null) {
				UI.destroy(nextArrow);
				nextArrow = null;
			}
			
			botModel = null;
		}
	}
}