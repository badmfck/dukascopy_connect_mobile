package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.EscrowScreenData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.radio.RadioGroup;
	import com.dukascopy.connect.gui.components.radio.RadioItemBack;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.events.Event;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class EscrowReportScreen extends ScrollAnimatedTitlePopup {
		
		private var nextButton:BitmapButton;
		private var needCallback:Boolean;
		
		private var radio:RadioGroup;
		private var radioSelection:Vector.<SelectorItemData>;
		
		private var escrowOffer:EscrowMessageData;
		private var selectedReason:SelectorItemData;
		private var alertText:AlertTextArea;
		
		public function EscrowReportScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createNextButton();
			createRadio();
			createAlert();
		}
		
		private function createAlert():void 
		{
			alertText = new AlertTextArea();
			addItem(alertText);
		}
		
		private function createRadio():void 
		{
			radio = new RadioGroup(onRadioSelection);
			radio.gap = Config.FINGER_SIZE * .2;
			addItem(radio);
		}
		
		private function onRadioSelection(value:SelectorItemData):void 
		{
			nextButton.alpha = 1;
			selectedReason = value;
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createNextButton():void 
		{
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.tapCallback = onNextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setDownScale(1);
			nextButton.setOverlay(HitZoneType.BUTTON);
			container.addChild(nextButton);
			
			nextButton.alpha = 0.5;
		}
		
		private function onNextClick():void 
		{
			if (selectedReason != null)
			{
				needCallback = true;
				close();
			}
			else
			{
				ToastMessage.display(Lang.please_select_reason);
			}
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			drawControls();
			updatePositions();
			updateScroll();
			
			var screenData:EscrowScreenData = data as EscrowScreenData;
			escrowOffer = screenData.escrowOffer;
		}
		
		override protected function getBottomPadding():int 
		{
			var result:int = 0;
			
			result = nextButton.height + contentPadding * 2;
			
			return result;
		}
		
		private function updatePositions():void 
		{
			var position:int;
			
			position = Config.FINGER_SIZE * .2;
			
			radio.x = contentPadding;
			radio.y = position;
			position += radio.height + contentPaddingV;
			
			alertText.x = contentPadding;
			alertText.y = position;
			position += alertText.height + contentPaddingV;
			
			nextButton.x = contentPadding;
			nextButton.y = int(getHeight() - nextButton.height - contentPadding);
		}
		
		private function drawControls():void
		{
			radioSelection = getSelection();
			
			radio.draw(radioSelection, _width - contentPadding * 2, RadioItemBack);
		//	radio.select(radioSelection[0]);
			
			alertText.draw(_width - contentPadding * 2, Lang.investigation_alert, null);
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.escrow_report, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function getSelection():Vector.<SelectorItemData> 
		{
			var result:Vector.<SelectorItemData> = new Vector.<SelectorItemData>();
			
			if (ConfigManager.config.escrowReportType != null)
			{
				var items:Array;
				try{
					items = JSON.parse(ConfigManager.config.escrowReportType) as Array;
				}
				catch (e:Error)
				{
					ApplicationErrors.add();
				}
				if (items != null)
				{
					var itemData:Object;
					var item:SelectorItemData;
					for (var i:int = 0; i < items.length; i++) 
					{
						itemData = items[i];
						if (itemData != null && "label" in itemData && "label" in itemData && itemData.label != null && Lang[itemData.label] != null)
						{
							item = new SelectorItemData(Lang[itemData.label], itemData.code);
							result.push(item);
						}
						else
						{
							ApplicationErrors.add();
						}
					}
				}
			}
			
			return result;
		}
		
		private function getButtonWidth():int 
		{
			return _width - contentPadding * 2;
		}
		
		override protected function updateContentPositions():void 
		{
			updatePositions();
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .3;
			super.drawView();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			
			radio.activate();
			nextButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			radio.deactivate();
			nextButton.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 2 && selectedReason != null)
				{
					(data.callback as Function)(escrowOffer, selectedReason);
				}
				selectedReason = null;
				escrowOffer = null;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (radio != null)
			{
				radio.dispose();
				radio = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (alertText != null)
			{
				alertText.dispose();
				alertText = null;
			}
			
			radioSelection = null;
		}
	}
}