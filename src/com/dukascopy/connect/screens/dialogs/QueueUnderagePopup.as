package com.dukascopy.connect.screens.dialogs {
	
	import assets.CardCheckIllustration;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.newDialogs.DialogBaseScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class QueueUnderagePopup extends DialogBaseScreen {
		
		private var backButton:BitmapButton;
		private var nextButton:BitmapButton;
		
		private var padding:int;
		private var horizontalLoader:HorizontalPreloader;
		private var locked:Boolean;
		private var illustration:Bitmap;
		private var title:Bitmap;
		private var description:Bitmap;
		private var bottomClip:Sprite;
		private var currentID:String;
		
		public function QueueUnderagePopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(nextButton);
			
			
			illustration = new Bitmap();
			scrollPanel.addObject(illustration);
			
			title = new Bitmap();
			scrollPanel.addObject(title);
			
			description = new Bitmap();
			scrollPanel.addObject(description);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			container.addChild(horizontalLoader);
			
			bottomClip = new Sprite();
			bottomClip.graphics.beginFill(0xFFFFFF);
			bottomClip.graphics.drawRect(1, 1, 1, 1);
			bottomClip.graphics.endFill();
			scrollPanel.addObject(bottomClip);
		}
		
		override protected function onCloseTap():void {
			rejectPopup();
		}
		
		override public function isModal():Boolean {
			return locked;
		}
		
		private function nextClick():void {
			horizontalLoader.start();
			PHP.call_loyaltyRegister(onLoyaltyRegister);
		}
		
		private function onWebViewCallback(success:Boolean):void{
			if (success == true) {
				//	thank you your transaction in progress
				Store.save(Store.LOYALTY_PENDING, (new Date()).getTime().toString());
				ServiceScreenManager.closeView();
				DialogManager.closeDialog();
				PHP.call_statVI("fastTrackSuccess","underage");
			} else {
				ServiceScreenManager.closeView();
				DialogManager.closeDialog();
			}
		}
		
		private function backClick():void {
			ServiceScreenManager.closeView();
			DialogManager.closeDialog();
		}
		
		private function rejectPopup():void {
			ServiceScreenManager.closeView();
			DialogManager.closeDialog();
		}
		
		override public function onBack(e:Event = null):void {
			rejectPopup();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void {
			if (data == null) {
				data = new Object();
				data.title = Lang.skipTheQueue;
			}
			super.initScreen(data);
			
			padding = Config.DIALOG_MARGIN;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			
			componentsWidth = _width - padding * 2;
			
			drawNextButton(Lang.textNext);
			drawBackButton();
			
			drawIllustration();
			drawTitle();
			drawDescription();
		}
		
		private function onLoyaltyRegister(respond:PHPRespond):void {
			if (isDisposed)
				return;
			horizontalLoader.stop();
			if (respond.error == true) {
				ToastMessage.display(Lang.serverError + ": " + respond.errorMsg);
				ApplicationErrors.add(respond.errorMsg);
				onCloseTap();
			} else if (respond.data == null || ("link" in respond.data) == false) {
				ToastMessage.display(Lang.serverError);
			} else {
				locked = false;
				activateScreen();
				currentID = respond.data.link as String;
				showWebView();
			}
			respond.dispose();
		}
		
		private function showWebView():void {
			PHP.call_statVI("fastTrackRequest", "underage");
			DialogManager.showDialog(
				ScreenWebviewDialogBase, 
				{
					preventCloseOnBgTap: true, 
					url:currentID, 
					callback: onWebViewCallback, 
					label: Lang.sendByCart
				}
			);
		}
		
		private function drawDescription():void {
			PHP.get_countryDeposite(onCountryDesposite, Auth.countryCode);
		}
		
		private function onCountryDesposite(phpRespond:PHPRespond):void {
			if (_isDisposed == true)
				return;
			var currency:String = "EUR";
			var price:int = Config.FAST_TRACK_COST;
			if (phpRespond.error == false && phpRespond.data != null) {
				if ("price" in phpRespond.data == true)
					price = phpRespond.data.price;
				if ("currency" in phpRespond.data == true)
					currency = phpRespond.data.currency;
			}
			description.bitmapData = TextUtils.createTextFieldData(
				Lang.underageFasttrackDescription1.replace(/%@/g, price + " " + currency),
				_width - padding * 2,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .28,
				true,
				0x697485,
				0xFFFFFF,
				false,
				true
			);
			drawView();
		}
		
		private function drawIllustration():void {
			var image:CardCheckIllustration = new CardCheckIllustration();
			UI.scaleToFit(image, _width - padding * 2 - Config.FINGER_SIZE * 1.5, Config.FINGER_SIZE * 5);
			illustration.bitmapData = UI.getSnapshot(image, StageQuality.HIGH, "QueueUnderagePopup.illustration");
			illustration.x = int(_width * .5 - illustration.width * .5);
		}
		
		private function drawTitle():void {
			title.bitmapData = TextUtils.createTextFieldData(
				Lang.underageFasttrackTitle,
				_width - padding * 2,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .32,
				true,
				0x697485
			);
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - vPadding * 2 - nextButton.height;
		}
		
		override protected function calculateBGHeight():int {
			var value:int = scrollPanel.view.y + scrollPanel.height + vPadding * 2 + nextButton.height;
			return value;
		}
		
		private function drawNextButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textCancel, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFCFCFC, 1, Config.FINGER_SIZE * .8, 0xEDEDED, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			
			var position:int = Config.FINGER_SIZE * .27;
			illustration.y = position;
			
			position += illustration.height + Config.FINGER_SIZE * .5;
			
			title.x = padding;
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .4;
			
			description.x = padding;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .55;
			
			bottomClip.y = position;
			
			super.drawView();
			
			backButton.x = padding;
			nextButton.x = int(backButton.x + backButton.width + Config.MARGIN);
			
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			backButton.y = nextButton.y = scrollPanel.view.y + scrollPanel.height + vPadding;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			if (locked)
				return;
			super.activateScreen();
			backButton.activate();
			nextButton.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			backButton.deactivate();
			nextButton.deactivate();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			Overlay.removeCurrent();
			if (horizontalLoader != null)
				horizontalLoader.dispose();
			horizontalLoader = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			if (nextButton != null)
				nextButton.dispose();
			nextButton = null;
			if (illustration != null)
				UI.destroy(illustration);
			illustration = null;
			if (title != null)
				UI.destroy(title);
			title = null;
			if (description != null)
				UI.destroy(description);
			description = null;
			if (bottomClip != null)
				UI.destroy(bottomClip);
			bottomClip = null;
		}
	}
}