package com.dukascopy.connect.screens.dialogs.paidBan 
{
	import assets.ProtectionAddedIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class PaidProtectionInfoUserPopup extends BaseScreen
	{
		protected var container:Sprite;
		private var bg:Shape;
		private var userName:Bitmap;
		private var fxName:Bitmap;
		private var acceptButton:BitmapButton;
		private var avatar:CircleAvatar;
		private var userModel:UserVO;
		private var avatarSize:int;
		private var verticalMargin:Number;
		private var scrollPanel:ScrollPanel;
		private var description:Bitmap;
		private var protectionData:PaidBanProtectionData;
		private var shieldImage:ProtectionAddedIcon;
		private var bottomScrollPanelMarker:Sprite;
		protected var componentsWidth:int;
		
		public function PaidProtectionInfoUserPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			avatarSize = Config.FINGER_SIZE;
			
			avatar = new CircleAvatar();
			container.addChild(avatar);
			
			userName = new Bitmap();
			container.addChild(userName);
			
			fxName = new Bitmap();
			container.addChild(fxName);
			
			scrollPanel = new ScrollPanel();
			container.addChild(scrollPanel.view);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			container.addChild(acceptButton);
			
			shieldImage = new ProtectionAddedIcon();
			UI.scaleToFit(shieldImage, Config.FINGER_SIZE * 1.5, Config.FINGER_SIZE * 2);
			scrollPanel.addObject(shieldImage);
			
			description = new Bitmap();
			scrollPanel.addObject(description);
			
			bottomScrollPanelMarker = new Sprite();
			scrollPanel.addObject(bottomScrollPanelMarker);
			bottomScrollPanelMarker.graphics.beginFill(0);
			bottomScrollPanelMarker.graphics.drawRect(0, 0, 1, 1);
			bottomScrollPanelMarker.graphics.endFill();
			bottomScrollPanelMarker.alpha = 0;
			
			_view.addChild(container);
		}
		
		override public function onBack(e:Event = null):void {
			InvoiceManager.stopProcessInvoice();
			ServiceScreenManager.closeView();
		}
		
		private function nextClick():void {
			onBack();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		private function drawAvatar():void {
			var avatarUrl:String = userModel.getAvatarURLProfile(avatarSize);
			//!TODO: инкогнито
			avatar.x = int(_width * .5 - avatarSize);
			avatar.setData(userModel, avatarSize);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "user" in data && data.user != null && data.user is UserVO) {
				userModel = data.user as UserVO;
			}
			
			if (data != null && "protectionData" in data && data.protectionData != null && data.protectionData is PaidBanProtectionData) {
				protectionData = data.protectionData as PaidBanProtectionData;
			}
			
			if (userModel == null || protectionData == null) {
				ServiceScreenManager.closeView();
				ApplicationErrors.add("empty init data");
				return;
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawAvatar();
			drawUserName();
			drawFxName();
			drawProtectionInfo();
			drawAcceptButton(Lang.textOk);
		}
		
		private function drawProtectionInfo():void {
			if (description.bitmapData != null) {
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			var text:String = Lang.paidBanProtectionWillBeValidFor;
			
			if (!isNaN(protectionData.canceled)) {
				var date:Date = new Date();
				var difference:Number = protectionData.canceled * 1000 - date.getTime();
				if (difference > 0) {
					text += "\n" + DateUtils.getComfortTimeRepresentation(difference);
				}
				else {
					text = Lang.paidBanProtectionIsOver;
				}
			}
			
			description.bitmapData = TextUtils.createTextFieldData(
																text, componentsWidth, 10, false, TextFormatAlign.CENTER, 
																TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, 
																true, 0x76848C, 0xDEDEDE, true);
		}
		
		private function drawAcceptButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(_width * .5 - acceptButton.width * .5);
		}
		
		private function drawFxName():void {
			var fxNameText:String;
			if (userModel.phone != null && userModel.phone != "") {
				fxNameText = "+" + userModel.phone;
			} else if (userModel.login != null) {
				fxNameText = userModel.login;
			}
			
			if (fxName.bitmapData != null) {
				fxName.bitmapData.dispose();
				fxName.bitmapData = null;
			}
			
			if (fxNameText != null)	{
				fxName.bitmapData = TextUtils.createTextFieldData(fxNameText, componentsWidth, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .30, false, 0xDA2627, 0xffffff, false);
				fxName.x = int(_width * .5 - fxName.width * .5);
			}
		}
		
		private function drawUserName():void {
			var userNameText:String;
			
			userNameText = userModel.getDisplayName();
			
			if (userName.bitmapData != null) {
				userName.bitmapData.dispose();
				userName.bitmapData = null;
			}
			
			userName.bitmapData = TextUtils.createTextFieldData(userNameText, componentsWidth, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .40, false, 0x3E4756, 0xffffff, false);
			
			userName.x = int(_width * .5 - userName.width * .5);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			bg.width = _width;
			
			verticalMargin = Config.MARGIN * 1.5;
			
			var position:int;
			
			position = verticalMargin + avatarSize * 2;
			
			userName.y = position;
			position += userName.height;
			
			if (userModel.login != null) {
				position += verticalMargin * .5;
				fxName.y = position;
				position += fxName.height;
			}
			position += verticalMargin * 1.3;
			
			scrollPanel.view.y = position;
			
			var maxContentHeight:int = _height - position - acceptButton.height - verticalMargin * 1.8 * 2;
			var contentPosition:int = 0;
			
			shieldImage.x = int(_width * .5 - shieldImage.width * .5);
			contentPosition += shieldImage.height + verticalMargin;
			
			if (description.height > 0) {
				description.y = contentPosition;
				description.x = int(_width * .5 - description.width * .5);
			}
			
			contentPosition += description.height + Config.FINGER_SIZE*.5;
			bottomScrollPanelMarker.y = contentPosition;
			
			scrollPanel.setWidthAndHeight(_width, Math.min(maxContentHeight, scrollPanel.itemsHeight));
			scrollPanel.update();
			position += scrollPanel.height + verticalMargin;
			
			acceptButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			bg.height = position - avatarSize;
			
			bg.y = avatarSize;
			
			container.y = _height - position;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			acceptButton.activate();
			scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			acceptButton.deactivate();
			scrollPanel.disable();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (description != null) {
				UI.destroy(description);
				description = null;
			}
			if (scrollPanel != null) {
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (acceptButton != null) {
				acceptButton.dispose();
				acceptButton = null;
			}
			if (avatar != null) {
				avatar.dispose();
				avatar = null;
			}
			if (fxName != null) {
				UI.destroy(fxName);
				fxName = null;
			}
			if (userName != null) {
				UI.destroy(userName);
				userName = null;
			}
			if (bg != null) {
				UI.destroy(bg);
				bg = null;
			}
			if (container != null) {
				UI.destroy(container);
				container = null;
			}
			if (shieldImage != null) {
				UI.destroy(shieldImage);
				shieldImage = null;
			}
			if (bottomScrollPanelMarker != null) {
				UI.destroy(bottomScrollPanelMarker);
				bottomScrollPanelMarker = null;
			}
			userModel = null;
		}
	}
}