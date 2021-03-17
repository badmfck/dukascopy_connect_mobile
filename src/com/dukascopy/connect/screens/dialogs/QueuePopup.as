package com.dukascopy.connect.screens.dialogs 
{
	import assets.IllustrationQueue;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.calendar.SelectRecognitionDatePopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.DialogBaseScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
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
	public class QueuePopup extends DialogBaseScreen
	{
		private var backButton:BitmapButton;
		private var nextButton:BitmapButton;
		
		private var padding:int;
		private var horizontalLoader:HorizontalPreloader;
		private var locked:Boolean;
		private var illustration:Bitmap;
		private var titleQueue:Bitmap;
		private var titleTrack:Bitmap;
		private var descriptionQueue:Bitmap;
		private var descriptionTrack:Bitmap;
		private var bottomClip:Sprite;
		private var currentID:String;
		private var attention:Bitmap;
		
		public function QueuePopup()
		{
			
		}
		
		override protected function createView():void
		{
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
			
			titleQueue = new Bitmap();
			scrollPanel.addObject(titleQueue);
			
			titleTrack = new Bitmap();
			scrollPanel.addObject(titleTrack);
			
			descriptionQueue = new Bitmap();
			scrollPanel.addObject(descriptionQueue);
			
			descriptionTrack = new Bitmap();
			scrollPanel.addObject(descriptionTrack);
			
			attention = new Bitmap();
			scrollPanel.addObject(attention);
			
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
		
		override public function isModal():Boolean 
		{
			return locked;
		}
		
		private function nextClick():void {
			horizontalLoader.start();
			PHP.call_loyaltyRegister(onLoyaltyRegister);
		}
		
		private function onWebViewCallback(success:Boolean):void
		{
			if (success == true)
			{
				//	thank you your transaction in progress
				Store.save(Store.LOYALTY_PENDING, (new Date()).getTime().toString());
				ServiceScreenManager.closeView();
				DialogManager.closeDialog();
				PHP.call_statVI("fastTrackSuccess","queue");

			} else {
				ServiceScreenManager.closeView();
				DialogManager.closeDialog();
			}
		}
		
		private function backClick():void {
			
			ServiceScreenManager.closeView();
			
			DialogManager.closeDialog();
			
			if (data.queueLength > Config.MAX_IDENTIFICATION_QUEUE_ALL)
			{
				DialogManager.showDialog(SelectRecognitionDatePopup, null);
			}
			else if(Auth.isFromSNG() && data.queueLength > Config.MAX_IDENTIFICATION_QUEUE_SNG)
			{
				DialogManager.showDialog(SelectRecognitionDatePopup, null);
			}
			else
			{
				if (data.startVI != null )
				{
					data.startVI();
				}
			}
		}
		
		private function rejectPopup():void 
		{
			ServiceScreenManager.closeView();
			DialogManager.closeDialog();
		}
		
		override public function onBack(e:Event = null):void
		{
			rejectPopup();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			if (data == null)
			{
				data = new Object();
				data.title = Lang.skipTheQueue;
				
			//	data.queueLength = 100;
			//	data.queueTime = 200;
			}
			super.initScreen(data);
			
			padding = Config.DIALOG_MARGIN;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			
			componentsWidth = _width - padding * 2;
			
			drawNextButton(Lang.skipTheQueue);
			drawBackButton();
			
			drawIllustration();
			drawQueueTitle();
			drawQueueDescription();
			drawTrackTitle();
			drawTrackDescription();
			
			if (LangManager.model.getCurrentLanguageID() == "en")
			{
				drawAttention();
			}
			
			var position:int = Config.FINGER_SIZE * .27;
			illustration.x = padding;
			illustration.y = position;
			
			position += illustration.height + Config.FINGER_SIZE * .4;
			
			titleQueue.x = padding;
			titleQueue.y = position;
			position += titleQueue.height + Config.FINGER_SIZE * .23;
			
			descriptionQueue.x = padding;
			descriptionQueue.y = position;
			position += descriptionQueue.height + Config.FINGER_SIZE * .55;
			
			titleTrack.x = padding;
			titleTrack.y = position;
			position += titleTrack.height + Config.FINGER_SIZE * .23;
			
			descriptionTrack.x = padding;
			descriptionTrack.y = position;
			position += descriptionTrack.height + Config.FINGER_SIZE * .55;
			
			if (LangManager.model.getCurrentLanguageID() == "en")
			{
				attention.x = padding;
				attention.y = position;
				position += attention.height + Config.FINGER_SIZE * .55;
			}
			
			bottomClip.y = position;
			
			backButton.x = padding;
			nextButton.x = int(backButton.x + backButton.width + Config.MARGIN);
			
		//	locked = true;
		}
		
		private function drawAttention():void 
		{
			attention.bitmapData = TextUtils.createTextFieldData(Lang.fastTrackInEnglish, _width - padding * 2, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE*.30, true, 0xFF001E, 0xFFFFFF, false, true);
		}
		
		private function onLoyaltyRegister(respond:PHPRespond):void 
		{
			if (isDisposed)
			{
				return;
			}
			horizontalLoader.stop();
			
			if (respond.error == true)
			{
				ToastMessage.display(Lang.serverError + ": " + respond.errorMsg);
				ApplicationErrors.add(respond.errorMsg);
				onCloseTap();
			}
			else if (respond.data == null || ("link" in respond.data) == false)
			{
				ToastMessage.display(Lang.serverError);
			}
			else
			{
				locked = false;
				activateScreen();
				currentID = respond.data.link as String;
				showWebView();
			}
			respond.dispose();
		}
		
		private function showWebView():void 
		{
			PHP.call_statVI("fastTrackRequest", "queue");
			DialogManager.showDialog(ScreenWebviewDialogBase, 
										{
											preventCloseOnBgTap: true, 
											url:currentID, 
											callback: onWebViewCallback, 
											label: Lang.sendByCart
										});
		}
		
		private function drawQueueDescription():void 
		{
			var textValue:String = Lang.queueLengthDescription;
			
			descriptionQueue.bitmapData = TextUtils.createTextFieldData(Lang.queueLengthDescription, _width - padding * 2, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE*.27, true, 0x48525C, 0xFFFFFF, false, true);
		}
		
		private function drawIllustration():void 
		{
			var image:IllustrationQueue = new IllustrationQueue();
			UI.scaleToFit(image, _width - padding * 2 - Config.FINGER_SIZE * .5, Config.FINGER_SIZE * 10);
			illustration.bitmapData = UI.getSnapshot(image, StageQuality.HIGH, "QueuePopup.illustration");
		}
		
		private function drawTrackDescription():void 
		{
			var textValue:String = Lang.fastTrackDescription;
			textValue = LangManager.replace(Lang.regExtValue, textValue, "<font color='#FA0A01'>" + "5 EUR" + "</font>");
			descriptionTrack.bitmapData = TextUtils.createTextFieldData(textValue, _width - padding * 2, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE*.27, true, 0x48525C, 0xFFFFFF, false, true);
		}
		
		private function drawQueueTitle():void 
		{
			titleQueue.bitmapData = TextUtils.createTextFieldData(Lang.waitingForIdVerification, _width - padding * 2, 10, false, 
															TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE*.35, false, 0x48525C);
		}
		
		private function drawTrackTitle():void 
		{
			titleTrack.bitmapData = TextUtils.createTextFieldData(Lang.getFastTrack + ":", _width - padding * 2, 10, false, 
															TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE*.35, false, 0x48525C);
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - vPadding * 2 - nextButton.height;
		}
		
		override protected function calculateBGHeight():int {
			var value:int = scrollPanel.view.y + scrollPanel.height + vPadding * 2 + nextButton.height;
			return value;
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.willWait, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFCFCFC, 1, Config.FINGER_SIZE * .8, 0xEDEDED, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			super.drawView();
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			backButton.y = nextButton.y = scrollPanel.view.y + scrollPanel.height + vPadding;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			if (locked)
			{
				return;
			}
			super.activateScreen();
			
			backButton.activate();
			nextButton.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			nextButton.deactivate();
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			Overlay.removeCurrent();
			
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (attention != null)
			{
				UI.destroy(attention);
				attention = null;
			}
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			if (titleQueue != null)
			{
				UI.destroy(titleQueue);
				titleQueue = null;
			}
			if (titleTrack != null)
			{
				UI.destroy(titleTrack);
				titleTrack = null;
			}
			if (descriptionQueue != null)
			{
				UI.destroy(descriptionQueue);
				descriptionQueue = null;
			}
			if (descriptionTrack != null)
			{
				UI.destroy(descriptionTrack);
				descriptionTrack = null;
			}
			if (bottomClip != null)
			{
				UI.destroy(bottomClip);
				bottomClip = null;
			}
		}
	}
}