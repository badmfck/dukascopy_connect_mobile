package com.dukascopy.connect.screens.dialogs.userPopup 
{
	import assets.IconBanPopup;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.data.UserPopupData;
	import com.dukascopy.connect.gui.components.selector.Selector;
	import com.dukascopy.connect.gui.components.textEditors.TitleTextEditor;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanUserPopup extends UserPopup
	{
		private var selector:Selector;
		private var reason:TitleTextEditor;
		private var disreaseDurationButton:BitmapButton;
		private var increaseDurationButton:BitmapButton;
		private var durationText:Bitmap;
		private var incognitoSwitcher:OptionSwitcher;
		private var priceText:Bitmap;
		
		public function PaidBanUserPopup() 
		{
			
		}
		
		override protected function preinitialize():void 
		{
			messageText = null;
			buttonRejectText = Lang.textCancel;
			buttonAcceptText = Lang.textBan;
			iconClass = IconBanPopup;
			
			acceptButtonColor = 0xAD1F1E;
			acceptButtonColor2 = 0x8B1718;
		}
		
		override protected function updateResultData():void 
		{
			if ((data as UserPopupData).resultData && ((data as UserPopupData).resultData is UserBanData))
			{
				if (reason.value != reason.prompt)
				{
					((data as UserPopupData).resultData as UserBanData).reason = reason.value;
				}
				
				((data as UserPopupData).resultData as UserBanData).duration = selector.getSelectedData() as String;
			}
		}
		
		override protected function createView():void
		{
			super.createView();
			
			reason = new TitleTextEditor(false);
			container.addChild(reason);
			
			disreaseDurationButton = new BitmapButton();
			disreaseDurationButton.setStandartButtonParams();
			disreaseDurationButton.setDownScale(1);
			disreaseDurationButton.cancelOnVerticalMovement = true;
			disreaseDurationButton.tapCallback = discreaseDuration;
			container.addChild(disreaseDurationButton);
			
			increaseDurationButton = new BitmapButton();
			increaseDurationButton.setStandartButtonParams();
			increaseDurationButton.setDownScale(1);
			increaseDurationButton.cancelOnVerticalMovement = true;
			increaseDurationButton.tapCallback = increaseDuration;
			container.addChild(increaseDurationButton);
			
			durationText = new Bitmap();
			container.addChild(durationText);
			
			incognitoSwitcher = new OptionSwitcher();
			incognitoSwitcher.onSwitchCallback = onIncognitoChanged;
			container.addChild(incognitoSwitcher);
			
			priceText = new Bitmap();
			container.addChild(priceText);
		}
		
		private function onIncognitoChanged(selected:Boolean):void 
		{
			((data as UserPopupData).resultData as UserBan911VO).secret = selected;
			updatePriceText();
		}
		
		private function increaseDuration():void 
		{
			var value:int = ((data as UserPopupData).resultData as UserBan911VO).duration;
			if (value < 6){
				value ++;
				((data as UserPopupData).resultData as UserBan911VO).duration = value;
				updateDurationText();
				updatePriceText();
			}
		}
		
		private function discreaseDuration():void 
		{
			var value:int = ((data as UserPopupData).resultData as UserBan911VO).duration;
			if (value > 1){
				value --;
				((data as UserPopupData).resultData as UserBan911VO).duration = value;
				updateDurationText();
				updatePriceText();
			}
		}
		
		private function drawReason(positionY:int):void 
		{
			reason.draw(_width - padding * 2);
			reason.prompt = Lang.reasonForBan;
			reason.x = padding;
			reason.y = positionY;
		}
		
		override protected function drawCustomContent(positionY:Number):void 
		{
			drawReason(positionY);
			position += reason.height + Config.MARGIN * 2;
			
			var discreaseText:TextFieldSettings = new TextFieldSettings("-", 0xFFFFFF, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
			disreaseDurationButton.setBitmapData(TextUtils.createbutton(discreaseText, 0x77BF43, 1, -1, NaN, Config.FINGER_SIZE * .7));
			
			var inccreaseText:TextFieldSettings = new TextFieldSettings("+", 0xFFFFFF, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
			increaseDurationButton.setBitmapData(TextUtils.createbutton(inccreaseText, 0x77BF43, 1, -1, NaN, Config.FINGER_SIZE * .7));
			
			disreaseDurationButton.y = position;
			disreaseDurationButton.x = padding;
			
			updateDurationText();
			
			durationText.y = position;
			
			increaseDurationButton.y = position;
			increaseDurationButton.x = (disreaseDurationButton.x + disreaseDurationButton.width + Config.FINGER_SIZE);
			position += disreaseDurationButton.height;
			
			incognitoSwitcher.create(_width - padding * 2, Config.FINGER_SIZE * .8, null, Lang.textIncognito);
			incognitoSwitcher.x = padding;
			incognitoSwitcher.y = position;
			position += incognitoSwitcher.height + Config.MARGIN;
			
			updatePriceText();
			priceText.y = position;
			position += priceText.height + Config.MARGIN;
		}
		
		private function updateDurationText():void 
		{
			if (durationText.bitmapData != null){
				durationText.bitmapData.dispose();
				durationText.bitmapData = null;
			}
			
			durationText.bitmapData = TextUtils.createTextFieldData(getCurrentDurationValue(), Config.FINGER_SIZE - Config.MARGIN*2, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .45, false, 0x3E4756, 0x00FFFF);
			durationText.x = int(disreaseDurationButton.x + disreaseDurationButton.width + Config.FINGER_SIZE * .5 - durationText.width * .5);
		}
		
		private function updatePriceText():void 
		{
			if (priceText.bitmapData != null){
				priceText.bitmapData.dispose();
				priceText.bitmapData = null;
			}
			
			priceText.bitmapData = TextUtils.createTextFieldData(getCurrentPriceValue(), _width - padding * 2, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .45, false, 0x3E4756, 0x00FFFF);
			priceText.x = int(_width - priceText.width - padding);
		}
		
		private function getCurrentPriceValue():String 
		{
			var price:Number = ((data as UserPopupData).resultData as UserBan911VO).duration * 1;
			if (((data as UserPopupData).resultData as UserBan911VO).secret == true){
				price = price * 2;
			}
			return price.toString() + " EUR";
		}
		
		private function getCurrentDurationValue():String 
		{
			return ((data as UserPopupData).resultData as UserBan911VO).duration.toString();
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			reason.activate();
			increaseDurationButton.activate();
			disreaseDurationButton.activate();
			incognitoSwitcher.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (isDisposed)
			{
				return;
			}
			super.deactivateScreen();
			
			reason.deactivate();
			
			increaseDurationButton.deactivate();
			disreaseDurationButton.deactivate();
			incognitoSwitcher.deactivate();
		}
		
		override public function dispose():void
		{
			if (isDisposed)
			{
				return;
			}
			super.dispose();
			
			if (reason)
			{
				reason.dispose();
				reason = null;
			}
		}
	}
}