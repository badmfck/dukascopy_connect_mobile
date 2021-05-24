package com.dukascopy.connect.screens.dialogs.bottom.implementation {
	
	import assets.AddItemButton;
	import assets.IconHelpClip3;
	import assets.Step1Icon;
	import assets.Step2Icon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.BitmapToggleSwitch;
	import com.dukascopy.connect.screens.dialogs.bottom.base.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.TextEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BottomConfirmPopup extends BottomAlertPopup {
		
		private var cancelButton:BitmapButton;
		private var success:Boolean = false;
		private var illustration:Bitmap;
		
		public function BottomConfirmPopup() { }
		
		override protected function createView():void {
			super.createView();
			
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.setDownScale(1);
			cancelButton.setDownColor(NaN);
			cancelButton.setOverlay(HitZoneType.BUTTON);
			cancelButton.tapCallback = onButtonCancelClick;
			container.addChild(cancelButton);
			
			illustration = new Bitmap();
			addItem(illustration);
		}
		
		private function onButtonCancelClick():void 
		{
			success = false;
			close();
		}
		
		override protected function onButtonOkClick():void {
			success = true;
			close();
		}
		
		override protected function getButtonWidth():int 
		{
			return (_width - paddind * 3) * .5;
		}
		
		override protected function drawOtherContent():void 
		{
			if (data != null && "illustration" in data && data.illustration != null)
			{
				drawIllustration(data.illustration);
			}
			
			if (data != null && "rejectButton" in data && data.rejectButton != null)
			{
				drawCancelButton(data.rejectButton);
			}
		}
		
		override protected function getButtonLabel():String 
		{
			return Lang.textOk;
		}
		
		private function drawCancelButton(text:String):void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_SECONDARY), getButtonWidth(), Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			cancelButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawIllustration(illustrationClass:Class):void 
		{
			if (illustration.bitmapData != null)
			{
				illustration.bitmapData.dispose();
				illustration.bitmapData = null;
			}
			
			var clip:Sprite = new illustrationClass();
			UI.scaleToFit(clip, int(Config.FINGER_SIZE * 2), int(Config.FINGER_SIZE * 2));
			illustration.bitmapData = UI.getSnapshot(clip);
			clip = null;
		}
		
		override protected function updatePositions():void 
		{
			var position:int = Config.FINGER_SIZE * .3;
			
			if (data != null && "illustration" in data && data.illustration != null)
			{
				position += Config.FINGER_SIZE * .5;
				illustration.x = int(_width * .5 - illustration.width * .5);
				illustration.y = position;
				position += illustration.height + Config.FINGER_SIZE * .7;
			}
			
			messageText.y = position;
			messageText.x = paddind;
			position += messageText.height + Config.FINGER_SIZE * .3;
			
			scrollPanel.setWidthAndHeight(_width, getHeight() - headerHeight - okButton.height - Config.FINGER_SIZE * .7 - Config.APPLE_BOTTOM_OFFSET);
			
			
			if (data != null && "rejectButton" in data && data.rejectButton != null)
			{
				okButton.x = getButtonWidth() + paddind * 2;
				cancelButton.x = paddind;
				cancelButton.y = okButton.y = getHeight() - paddind - Config.APPLE_BOTTOM_OFFSET - okButton.fullHeight;
			}
			else
			{
				okButton.x = paddind;
				okButton.y = getHeight() - paddind - Config.APPLE_BOTTOM_OFFSET - okButton.fullHeight;
			}
			
			updateScroll();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			cancelButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			cancelButton.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1)
				{
					(data.callback as Function)(success);
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			if (cancelButton != null)
				cancelButton.dispose();
			cancelButton = null;
			
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
		}
	}
}