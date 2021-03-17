package com.dukascopy.connect.screens.shop {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.paidChat.CreatePaidChatPopup;
	import com.dukascopy.connect.screens.dialogs.paidChat.PaidChatBuyersPopup;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class PaidChatsScreen extends BaseScreen {
		
		private var topBar:TopBarScreen;
		private var scroll:ScrollPanel;
		private var switchButton:BitmapButton;
		private var unsuccessChatsButton:BitmapButton;
		private var description:Bitmap;
		private var descriptionChats:Bitmap;
		private var line:Bitmap;
		
		public function PaidChatsScreen() { }
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarScreen();
			view.addChild(topBar);
			
			scroll = new ScrollPanel();
			view.addChild(scroll.view);
			
			scroll.view.y = topBar.y + topBar.trueHeight;
			
			switchButton = new BitmapButton();
			switchButton.setStandartButtonParams();
			switchButton.setDownScale(1);
			switchButton.setDownColor(0);
			switchButton.tapCallback = switchClick;
			switchButton.disposeBitmapOnDestroy = true;
			switchButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			scroll.addObject(switchButton);
			
			unsuccessChatsButton = new BitmapButton();
			unsuccessChatsButton.setStandartButtonParams();
			unsuccessChatsButton.setDownScale(1);
			unsuccessChatsButton.setDownColor(0);
			unsuccessChatsButton.tapCallback = showChatsClick;
			unsuccessChatsButton.disposeBitmapOnDestroy = true;
			unsuccessChatsButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			scroll.addObject(unsuccessChatsButton);
			
			description = new Bitmap();
			scroll.addObject(description);
			
			descriptionChats = new Bitmap();
			scroll.addObject(descriptionChats);
			
			line = new Bitmap();
			scroll.addObject(line);
			
			line.bitmapData = UI.getHorizontalLine(1, 0xDCE5EE);
			
			line.visible = false;
		}
		
		private function showChatsClick():void 
		{
			MobileGui.changeMainScreen(PaidChatBuyersPopup);
		}
		
		private function switchClick():void 
		{
			Overlay.removeCurrent();
			
			if (Shop.getMyPaidChatData() == null)
			{
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, CreatePaidChatPopup);
			}
			else
			{
				Shop.disablePaidChat();
			}
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .33, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x3599CD, 1, Config.FINGER_SIZE * .8);
			switchButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawChatsButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .33, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x3599CD, 1, Config.FINGER_SIZE * .8);
			unsuccessChatsButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void {
			super.drawView();
			topBar.drawView(_width);
			
			var position:int = 0;
			
			position += Config.FINGER_SIZE * .4;
			
			description.x = Config.DIALOG_MARGIN;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .5;
			
			switchButton.y = position;
			switchButton.x = int(_width * .5 - switchButton.width * .5);
			position += switchButton.height + Config.FINGER_SIZE * .3;
			
			if (Shop.getMyPaidChatData() != null)
			{
				line.y = position;
			}
			else
			{
				line.y = 0;
			}
			position += Config.FINGER_SIZE * .3;
			
			descriptionChats.x = Config.DIALOG_MARGIN;
			descriptionChats.y = position;
			position += descriptionChats.height + Config.FINGER_SIZE * .5;
			
			unsuccessChatsButton.y = position;
			unsuccessChatsButton.x = int(_width * .5 - unsuccessChatsButton.width * .5);
			
			scroll.update();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(Lang.myPaidChats, true);
			_params.doDisposeAfterClose = true;
			
			scroll.setWidthAndHeight(_width, _height - Config.APPLE_BOTTOM_OFFSET + topBar.trueHeight);
			
			Shop.S_MY_PAID_CHAT_UPDATE.add(update);
			if (Shop.getMyPaidChatData() != null)
			{
				update();
			}
			else
			{
				//!TODO: show preloader;
				Shop.updateMyPaidBan();
			}
			
			line.width = _width;
		}
		
		private function update():void 
		{
			if (Shop.getMyPaidChatData() == null)
			{
				drawDescription(Lang.paidChatsDescription);
				drawNextButton(Lang.enablePaidChat);
				line.visible = false;
			}
			else
			{
				drawDescription(Lang.existingPaidChatsDescription);
				drawNextButton(Lang.disablePaidChat);
				drawDescriptionChats(Lang.unsuccessPaidChatDescription);
				drawChatsButton(Lang.unsuccessChats);
				line.visible = true;
			}
			
			drawView();
		}
		
		private function drawDescription(text:String):void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			description.bitmapData = TextUtils.createTextFieldData(
																	text, _width - Config.DIALOG_MARGIN * 2, 10, true, 
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .32, true, 0x6B7A8A);
		}
		
		private function drawDescriptionChats(text:String):void 
		{
			if (descriptionChats.bitmapData != null)
			{
				descriptionChats.bitmapData.dispose();
				descriptionChats.bitmapData = null;
			}
			descriptionChats.bitmapData = TextUtils.createTextFieldData(
																	text, _width - Config.DIALOG_MARGIN * 2, 10, true, 
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .32, true, 0x6B7A8A);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			
			if (topBar != null)
				topBar.activate();
			
			scroll.enable();
			switchButton.activate();
			unsuccessChatsButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			
			if (topBar != null)
				topBar.deactivate();
				
			scroll.disable();
			switchButton.deactivate();
			unsuccessChatsButton.deactivate();
		}
		
		override public function dispose():void {
			super.dispose();
			
			Shop.S_MY_PAID_CHAT_UPDATE.remove(update);
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (switchButton != null)
				switchButton.dispose();
			switchButton = null;
			
			if (unsuccessChatsButton != null)
				unsuccessChatsButton.dispose();
			unsuccessChatsButton = null;
			
			if (description != null)
				UI.destroy(description);
			description = null;
			
			if (descriptionChats != null)
				UI.destroy(descriptionChats);
			descriptionChats = null;
			
			if (line != null)
				UI.destroy(line);
			line = null;
			
			if (scroll != null)
				scroll.dispose();
			scroll = null;
		}
	}
}