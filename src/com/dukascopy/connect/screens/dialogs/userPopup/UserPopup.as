package com.dukascopy.connect.screens.dialogs.userPopup 
{
	import assets.CloseButtonIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.UserPopupData;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.errors.ApplicationError;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.ScreenLayer;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.greensock.TweenMax;
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
	public class UserPopup extends BaseScreen
	{
		private var message:Bitmap;
		private var userName:Bitmap;
		private var fxName:Bitmap;
		protected var headerHeight:int;
		protected var userModel:UserVO;
		protected var padding:int;
		protected var avatarSize:int;
		protected var position:Number;
		private var buttonClose:BitmapButton;
		private var avatar:Bitmap;
		private var avatarBD:ImageBitmapData;
		private var iconClip:Sprite;
		private var rejectButton:RoundedButton;
		private var acceptButton:RoundedButton;
		private var resultData:Object;
		protected var additionalData:Object;
		protected var iconClass:Class;
		protected var container:Sprite;
		
		protected var buttonRejectText:String;
		protected var buttonAcceptText:String;
		protected var messageText:String;
		
		protected var acceptButtonColor:Number;
		protected var acceptButtonColor2:Number;
		
		public const BUTTONS_NO_LAYOUT:int = 0;
		public const BUTTONS_HORIZONTAL:int = 1;
		public const BUTTONS_VERTICAL:int = 2;
		
		static public const RESPONSE_REJECT:String = "responseReject";
		static public const RESPONSE_ACCEPT:String = "responseAccept";
		
		protected var currentLayout:int = 0;
		
		public function UserPopup() 
		{
			
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			headerHeight = Config.FINGER_SIZE * 1.5;
			
			padding = Config.MARGIN * 2;
			
			if (data is UserPopupData) {
				userModel = (data as UserPopupData).data;
				resultData = (data as UserPopupData).resultData;
				additionalData = (data as UserPopupData).additionalData;
			}
			else {
				throw new ApplicationError(ApplicationError.USER_POPUP_WRONG_DATA);
			}
			
			if (userModel != null){
				drawAvatar();
				position = headerHeight + avatarSize + Config.MARGIN * 2;
				
				drawUserName(position);
				position += userName.height + Config.MARGIN;
				
				if (userModel.fxID != 0 && userModel.login != null)
				{
					drawFxName(position);
					position += fxName.height + Config.MARGIN * 2;
				}
				else
				{
					position += Config.MARGIN * 2;
				}
			}
			
			if (messageText)
			{
				drawMessage(position);
				position += message.height + Config.MARGIN * 2;
			}
			
			drawCustomContent(position);
			
			drawButtons();
			
			if (iconClass != null)
			{
				iconClip = new iconClass();
				container.addChild(iconClip);
				var ct:ColorTransform = new ColorTransform();
				ct.color = 0x8B1718;
				iconClip.transform.colorTransform = ct;
				UI.scaleToFit(iconClip, headerHeight * 2, headerHeight * .9);
				container.setChildIndex(iconClip, container.getChildIndex(avatar) - 1);
			}
		}
		
		protected function repositionButtons():void	{
			var buttonsAreaWidth:int = 0;
			
			var i:int = 0;
			
			var buttons:Array = new Array();
			buttons.push(acceptButton);
			buttons.push(rejectButton);
			
			
			for (i = 0; i < buttons.length; i++ )
			{
				buttonsAreaWidth += (buttons[i] as RoundedButton).getWidth();
			}
			buttonsAreaWidth += padding * (buttons.length - 1);
			
			if (currentLayout == BUTTONS_HORIZONTAL)
			{
				for (i = buttons.length - 1; i >= 0 ; i-- )
				{
					(buttons[i] as RoundedButton).y = (position + Config.MARGIN * 2);
					(buttons[i] as RoundedButton).x = int((i == buttons.length - 1)?(_width * .5 - buttonsAreaWidth * .5):((buttons[i + 1] as RoundedButton).x + (buttons[i + 1] as RoundedButton).getWidth()) + padding);
				}
			}
			else if (currentLayout == BUTTONS_VERTICAL)
			{
				for (i = buttons.length - 1; i >= 0 ; i-- )
				{
					(buttons[i] as RoundedButton).x = int(_width * .5 - (buttons[i] as RoundedButton).getWidth() * .5);
					(buttons[i] as RoundedButton).y = int((i == buttons.length - 1)?
												(position + Config.MARGIN * 2):
												((buttons[i + 1] as RoundedButton).y + (buttons[i + 1] as RoundedButton).getHeight() + padding));
				}
			}
		}
		
		protected function resizeButtons(layout:int):void {
			if (layout == BUTTONS_NO_LAYOUT) {
				layout = BUTTONS_HORIZONTAL;
			}
			currentLayout = layout;
			
			var maxButtonWidth:int;
			
			var buttons:Array = new Array();
			buttons.push(acceptButton);
			buttons.push(rejectButton);
			
			var maxButtonsAreaWidth:int = (_width - padding * (buttons.length - 1) - padding * 2);
			
			if (currentLayout == BUTTONS_HORIZONTAL) {
				maxButtonWidth = maxButtonsAreaWidth / buttons.length;
			}
			else if (currentLayout == BUTTONS_VERTICAL) {
				maxButtonWidth = maxButtonsAreaWidth;
			}
			
			acceptButton.setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			rejectButton.setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			
			
			var isTextCropped:Boolean = false;
			
			var i:int = 0;
			
			for (i = 0; i < buttons.length; i++ ) {
				isTextCropped = isTextCropped?true:(buttons[i] as RoundedButton).isTextCropped();
			}
			
			if (isTextCropped && currentLayout == BUTTONS_HORIZONTAL) {
				currentLayout = BUTTONS_VERTICAL;
				
				resizeButtons(currentLayout);
			}
			else {
				maxButtonWidth = 0;
				for (i = 0; i < buttons.length; i++ ) {
					(buttons[i] as RoundedButton).draw();
					maxButtonWidth = Math.max(maxButtonWidth, Math.ceil((buttons[i] as RoundedButton).getWidth()));
				}
				for (i = 0; i < buttons.length; i++ ) {
					(buttons[i] as RoundedButton).setSizeLimits(maxButtonWidth, maxButtonWidth);
					(buttons[i] as RoundedButton).draw();
				}
			}
		}
		
		private function drawAvatar():void {
			var avatarUrl:String = userModel.getAvatarURLProfile(avatarSize * 2);
			
			avatar.x = int(_width * .5 - avatarSize);
			avatar.y = int(headerHeight - avatarSize);
			
			if (avatarUrl != null && avatarUrl != "") {
				var path:String;
				
				//!TODO: можно складывать все загруженные на данный момент аватарки относящиеся к пользователю в один менеджер и выбирать наиболее подходящую;
				var smallAvatarImage:ImageBitmapData;
				if (!smallAvatarImage) {
					//берём маленькую аватарку из списка контактов;
					path = UsersManager.getAvatarImage(userModel, avatarUrl, int(Config.FINGER_SIZE * .7), 3);
					smallAvatarImage = ImageManager.getImageFromCache(path);
				}
				if (!smallAvatarImage) {
					//берём маленькую аватарку по умолчанию (размер 60px если она из коммуны);
					smallAvatarImage = ImageManager.getImageFromCache(avatarUrl);
				}
				
				if (smallAvatarImage) {
					avatarBD = new ImageBitmapData("UserPopup.LOADED_AVATAR_BMD", avatarSize * 2, avatarSize * 2);
					ImageManager.drawCircleImageToBitmap(avatarBD, smallAvatarImage, 0, 0, int(avatarSize));
					avatar.bitmapData = avatarBD;
				}
				else {
					path = UsersManager.getAvatarImage(userModel, avatarUrl, avatarSize * 2, 3, false);
					ImageManager.loadImage(path, onAvatarLoaded);
				}
			}
			else {
				//!TODO;
			}
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			if (isDisposed)
				return;		
			
			if (!success)
				return;
			
			if (bmd) {
				avatarBD = new ImageBitmapData("UserPopup.LOADED_AVATAR_BMD", avatarSize * 2, avatarSize * 2);
				ImageManager.drawCircleImageToBitmap(avatarBD, bmd, 0, 0, int(avatarSize));
				avatar.alpha = 0;
				TweenMax.to(avatar, 0.5, {alpha:1} );
				avatar.bitmapData = avatarBD;
			}
		}
		
		protected function initCloseButton():void {
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
			ct.color = MainColors.WHITE;
			iconClose.transform.colorTransform = ct;
			
			buttonClose.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "PopupDialogBase,iconClose"), true);
			buttonClose.setOverflow(btnOffset, int(btnOffset * .6), Config.FINGER_SIZE, btnOffset);
			UI.destroy(iconClose);
			iconClose = null;
		}
		
		protected function getCloseButtonIcon():Sprite {
			return new CloseButtonIcon();
		}
		
		protected function onCloseButtonClick():void {
			closeDialog();
		}
		
		protected function drawCustomContent(position:Number):void {
			
		}
		
		private function drawButtons():void {
			currentLayout = BUTTONS_NO_LAYOUT;
			resizeButtons(currentLayout);
			repositionButtons();
			position = acceptButton.y + acceptButton.height + padding;
		}
		
		private function drawMessage(position:int):void {
			if (message.bitmapData)
			{
				message.bitmapData.dispose();
				message.bitmapData = null;
			}
			
			message.bitmapData = TextUtils.createTextFieldData(messageText, _width - padding * 2, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .40, true, AppTheme.GREY_DARK, MainColors.WHITE);
			message.x = int(_width * .5 - message.width * .5);
			message.y = position;
		}
		
		private function drawFxName(position:int):void {
			if (fxName.bitmapData)
			{
				fxName.bitmapData.dispose();
				fxName.bitmapData = null;
			}
			
			fxName.bitmapData = TextUtils.createTextFieldData(userModel.login, _width - padding * 2, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .25, true, AppTheme.RED_MEDIUM, MainColors.WHITE);
			fxName.x = int(_width * .5 - fxName.width * .5);
			fxName.y = position;
		}
		
		private function drawUserName(position:int):void {
			if (userName.bitmapData)
			{
				userName.bitmapData.dispose();
				userName.bitmapData = null;
			}
			
			userName.bitmapData = TextUtils.createTextFieldData(userModel.getDisplayName(), _width - padding * 2, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .35, true, AppTheme.GREY_DARK, MainColors.WHITE);
			userName.x = int(_width * .5 - userName.width * .5);
			userName.y = position;
		}
		
		override protected function createView():void {
			avatarSize = Config.FINGER_SIZE * 0.85;
			
			super.createView();
			
			preinitialize();
			
			container = new Sprite();
			view.addChild(container);
			
			message = new Bitmap();
			container.addChild(message);
			
			userName = new Bitmap();
			container.addChild(userName);
			
			fxName = new Bitmap();
			container.addChild(fxName);
			
			avatar = new Bitmap();
			container.addChild(avatar);
			
			initCloseButton();
			
			createRejectButton();
			createAcceptButton();
		}
		
		protected function preinitialize():void {
			
		}
		
		private function createAcceptButton():void {
			acceptButton = new RoundedButton(buttonAcceptText, acceptButtonColor, acceptButtonColor2, null, Config.FINGER_SIZE*.1, Config.FINGER_SIZE*.06, Config.FINGER_SIZE);
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.cancelOnVerticalMovement = true;
			acceptButton.tapCallback = onAccept;
			container.addChild(acceptButton);
		}
		
		private function onAccept():void {
			if ((data as UserPopupData).callback != null){
				updateResultData();
				(data as UserPopupData).callback(RESPONSE_ACCEPT, data);
			}
			(data as UserPopupData).dispose();
			closeDialog();
		}
		
		private function closeDialog():void {
			if ((data is UserPopupData) && (data as UserPopupData).screenLayer == ScreenLayer.SERVICE_LAYER){
				ServiceScreenManager.closeView();
			}
			else{
				DialogManager.closeDialog();
			}
		}
		
		protected function updateResultData():void {
			
		}
		
		private function createRejectButton():void {
			rejectButton = new RoundedButton(buttonRejectText, AppTheme.GREY_MEDIUM, 0x6B7F8E, null, Config.FINGER_SIZE*.1, Config.FINGER_SIZE*.06, Config.FINGER_SIZE);
			rejectButton.setStandartButtonParams();
			rejectButton.setDownScale(1);
			rejectButton.cancelOnVerticalMovement = true;
			rejectButton.tapCallback = onReject;
			container.addChild(rejectButton);
		}
		
		private function onReject():void {
			if ((data as UserPopupData).callback != null) {
				(data as UserPopupData).callback(RESPONSE_REJECT, data);
			}
			(data as UserPopupData).dispose();
			closeDialog();
		}
		
		override protected function drawView():void {
			updateBack();
			buttonClose.x = int(_width - padding - buttonClose.width);
			buttonClose.y = int(padding);
			
			iconClip.x = (_width * .5 - iconClip.width - avatarSize * .5);
			iconClip.y = int(headerHeight - iconClip.height);
		}
		
		protected function updateBack():void {
			var backHeight:Number = position;
			
			container.graphics.clear();
			
			container.graphics.beginFill(/*0xAE1E1E*/0xcd3f43);
			container.graphics.drawRect(0, 0, _width, headerHeight);
			
			container.graphics.beginFill(MainColors.WHITE);
			container.graphics.drawRect(0, headerHeight, _width, backHeight - headerHeight);
			
			container.graphics.endFill();
			
			container.y = int(_height*.5 - Math.min(backHeight, _height)*.5);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			buttonClose.activate();
			acceptButton.activate();
			rejectButton.activate();
		}
		
		override public function deactivateScreen():void {
			if (isDisposed)
				return;
			
			super.deactivateScreen();
			
			buttonClose.deactivate();
			acceptButton.deactivate();
			rejectButton.deactivate();
		}
		
		override public function dispose():void {
			if (isDisposed)
				return;
			
			super.dispose();
			TweenMax.killTweensOf(avatar);
			if (data && (data is UserPopupData)){
				(data as UserPopupData).dispose();
			}
			if (message != null){
				UI.destroy(message);
				message = null;
			}
			if (userName != null){
				UI.destroy(userName);
				userName = null;
			}
			if (fxName != null){
				UI.destroy(fxName);
				fxName = null;
			}
			if (buttonClose != null){
				buttonClose.dispose();
				buttonClose = null;
			}
			if (avatar != null){
				UI.destroy(avatar);
				avatar = null;
			}
			if (iconClip != null){
				UI.destroy(iconClip);
				iconClip = null;
			}
			if (container != null){
				UI.destroy(container);
				container = null;
			}
			userModel = null;
			iconClass = null;
			if (avatarBD != null){
				avatarBD.dispose();
				avatarBD = null;
			}
			
			if (rejectButton != null){
				rejectButton.dispose();
				rejectButton = null;
			}
			if (acceptButton != null){
				acceptButton.dispose();
				acceptButton = null;
			}
		}
	}
}