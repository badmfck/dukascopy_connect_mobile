package com.dukascopy.connect.screens.roadMap {
	
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
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
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
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class VerifyCryptodepositPopup extends ScrollAnimatedTitlePopup {
		
		public static const iconSize:int = Config.FINGER_SIZE * .66;
		
		private var title:Bitmap;
		private var icon_1:Bitmap;
		private var icon_2:Bitmap;
		private var step_1:Bitmap;
		private var ZBXUrl:Sprite;
		private var ZBXInfo:Sprite;
		private var questionButton:BitmapButton;
		private var step_2:Bitmap;
		private var checkerText:Bitmap;
		private var needCallback:Boolean = true;
		private var paddind:int;
		private var okButton:BitmapButton;
		private var toggler:BitmapToggleSwitch;
		private var lines:Sprite;
		private var lastResult:Boolean = false;
		private var locked:Boolean;
		private var preloader:CirclePreloader;
		private var messageClip:Sprite;
		private var messageText:Bitmap;
		private var requestsTimeout:Number = 1000 * 60 * 10;
		private var lastRequestTime:Number;
		
		public function VerifyCryptodepositPopup() { }
		
		override protected function createView():void {
			super.createView();
			
			title = new Bitmap();
			addItem(title);
			
			step_1 = new Bitmap();
			addItem(step_1);
			
			ZBXUrl = new Sprite();
			ZBXUrl.graphics.beginFill(0, 0);
			ZBXUrl.graphics.drawRect(0, 0, 1, 1);
			ZBXUrl.graphics.endFill();
			addItem(ZBXUrl);
			
			questionButton = new BitmapButton();
			questionButton.setStandartButtonParams();
			questionButton.setDownScale(1.3);
			questionButton.setDownColor(0xFFFFFF);
			questionButton.tapCallback = showZBXAbout;
			questionButton.disposeBitmapOnDestroy = true;
			questionButton.show();
			_view.addChild(questionButton);
			var icon1:Sprite = new IconHelpClip3();
			var ct:ColorTransform = new ColorTransform();
			ct.color = Color.RED;
			icon1.transform.colorTransform = ct;
			UI.scaleToFit(icon1, Config.FINGER_SIZE_DOT_35, Config.FINGER_SIZE_DOT_35);
			questionButton.setBitmapData(UI.getSnapshot(icon1, StageQuality.HIGH, "SelectBackgroundScreen.questionButton"), true);
			questionButton.setOverflow(Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25);
			UI.destroy(icon);
			icon = null;
			addItem(questionButton);
			
			step_2 = new Bitmap();
			addItem(step_2);
			
			icon_1 = new Bitmap();
			addItem(icon_1);
			
			icon_2 = new Bitmap();
			addItem(icon_2);
			
			checkerText = new Bitmap();
			addItem(checkerText);
			
			okButton = new BitmapButton();
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.setDownColor(NaN);
			okButton.setOverlay(HitZoneType.BUTTON);
			okButton.cancelOnVerticalMovement = false;
			okButton.ignoreHittest = true;
			okButton.tapCallback = onButtonOkClick;
			
			toggler = new BitmapToggleSwitch();
			toggler.setDownScale(1);
			toggler.setDownColor(0x000000);
			toggler.setOverflow(5, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, 5);
			toggler.show(0);
			
			var icon:Sprite = new SWFToggleBg2();
			UI.colorize(icon, Style.color(Style.TOGGLER_UNSELECTED));
			
			var	TOGGLERBG_BMD:ImageBitmapData = UI.renderAssetExtended(icon, Config.FINGER_SIZE * 0.60, Config.FINGER_SIZE * .4, true, "OptionSwitcher.TOGGLERBG_BMD");
			var TOGGLER_BMD:ImageBitmapData = UI.renderAssetExtended(new SWFToggler2(), Config.FINGER_SIZE * .55, Config.FINGER_SIZE * .55, true, "OptionSwitcher.TOGGLER_BMD");
			toggler.setDesignBitmapDatas(TOGGLERBG_BMD, TOGGLER_BMD, true);
			toggler.setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .2);
			toggler.isSelected = false;
			toggler.tapCallback = onTogglerTap;
			toggler.disposeBitmapOnDestroy = false;
			addItem(toggler);
			
			container.addChild(okButton);
			
			lines = new Sprite();
			addItem(lines);
			
			paddind = Config.FINGER_SIZE * 0.45;
		}
		
		private function showZBXAbout():void {
			
			var textValue:String = Lang.zbxAbout_2;
			if (data != null && "price" in data)
			{
				textValue = LangManager.replace(/%@/g, textValue, data.price);
			}
			
			DialogManager.alert(Lang.information, textValue);
		}
		
		private function onTogglerTap():void {
			drawButton();
		}
		
		private function onButtonOkClick():void {
			if (toggler.isSelected) {
				if (locked == false) {
					if (isNaN(lastRequestTime)) {
						loadLastRequestTime();
					} else if ((new Date()).getTime() - lastRequestTime > requestsTimeout) {
						requestZBX();
					} else {
						displayMessage(Lang.zbxRequestTryLater, false);
					}
				}
			}
		}
		
		private function requestZBX():void {
			lastRequestTime = (new Date()).getTime();
			Store.save(Store.ZBX_REQUEST_TIME, lastRequestTime.toString());
			locked = true;
			
			loadStatus();
		}
		
		private function loadLastRequestTime():void {
			Store.load(Store.ZBX_REQUEST_TIME, onRequestTimeLoaded);
		}
		
		private function onRequestTimeLoaded(data:String, err:Boolean):void {
			if (isDisposed == true) {
				return;
			}
			if (err == true || data == null) {
				requestZBX();
			} else {
				lastRequestTime = Number(data);
				if ((new Date()).getTime() - lastRequestTime > requestsTimeout) {
					requestZBX();
				} else {
					displayMessage(Lang.zbxRequestTryLater, false);
				}
			}
		}
		
		private function loadStatus():void {
			addLoader();
			PHP.call_checkZbx(onDataLoaded);
		}
		
		private function addLoader():void {
			if (preloader == null) {
				preloader = new CirclePreloader();
				view.addChild(preloader);
				preloader.x = int(_width * .5);
				preloader.y = int(container.y + okButton.y - Config.FINGER_SIZE * 2.5);
			}
		}
		
		private function onDataLoaded(response:PHPRespond):void {
			if (isDisposed) {
				return;
			}
			removeLoader();
			locked = false;
			if (response.error) {
				ToastMessage.display(Lang.textError);
			} else {
				if (response.data != null) {
					if (response.data == "accepted") {
						lastResult = true;
						locked = true;
						displayMessage(Lang.solvencyVerificatoinSuccess, true);
						TweenMax.delayedCall(4, close);
					} else if (response.data == "declined") {
						displayMessage(Lang.solvencyVerificatoinFail, false);
					} else if (response.data == "unknown") {
						displayMessage(Lang.solvencyVerificatoinFail, false);
					}
				} else {
					displayMessage(Lang.solvencyVerificatoinFail, false);
				}
			}
			response.dispose();
		}
		
		private function displayMessage(message:String, success:Boolean):void {
			if (isDisposed) {
				return;
			}
			
			removeMessageClip();
			
			messageClip = new Sprite();
			messageText = new Bitmap();
			messageClip.addChild(messageText);
			messageText.x = Config.DIALOG_MARGIN;
			messageText.y = Config.DIALOG_MARGIN + Config.APPLE_TOP_OFFSET;
			view.addChild(messageClip);
			
			var backColor:Number;
			if (success)
			{
				backColor = Color.GREEN;
			}
			else
			{
				backColor = Color.RED;
			}
			messageText.bitmapData = TextUtils.createTextFieldData(
				message,
				getTextWidth(),
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				true,
				Color.WHITE,
				backColor,
				false, true
			);
			messageClip.graphics.beginFill(backColor);
			messageClip.graphics.drawRect(0, 0, _width, Config.DIALOG_MARGIN * 2 + Config.APPLE_TOP_OFFSET + messageText.height);
			messageClip.y = -messageClip.height;
			TweenMax.to(messageClip, 0.3, {ease:Power3.easeOut, y:0});
			TweenMax.to(messageClip, 0.3, {ease:Power3.easeIn, y:-messageClip.height, onComplete:removeMessageClip, delay:5});
		}
		
		private function removeMessageClip():void 
		{
			TweenMax.killTweensOf(messageClip);
			
			if (messageClip != null)
			{
				if (view.contains(messageClip))
				{
					view.removeChild(messageClip);
				}
				UI.destroy(messageClip);
				messageClip = null;
			}
			if (messageText != null)
			{
				UI.destroy(messageText);
				messageText = null;
			}
		}
		
		private function removeLoader():void 
		{
			if (preloader != null)
			{
				if (view.contains(preloader))
				{
					view.removeChild(preloader);
				}
				preloader.dispose();
				preloader = null;
			}
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			drawTitle();
			drawSteps();
			drawButton();
			
			var position:int = Config.FINGER_SIZE;
			title.y = position;
			title.x = int(_width * .5 - title.width * .5);
			position += title.height + Config.FINGER_SIZE;
			
			step_1.x = paddind * 2 + iconSize;
			step_2.x = paddind * 2 + iconSize;
			checkerText.x = paddind * 2 + iconSize;
			
			step_1.y = position;
			ZBXUrl.y = position - Config.FINGER_SIZE_DOT_25;
			ZBXUrl.height = step_1.height + Config.FINGER_SIZE_DOT_5;
			ZBXUrl.width = step_1.x + step_1.width;
			questionButton.x = ZBXUrl.width + Config.MARGIN + Config.FINGER_SIZE_DOT_25;
			position += step_1.height + Config.FINGER_SIZE * .9;
			
			step_2.y = position;
			position += step_2.height + Config.FINGER_SIZE * .9;
			
			checkerText.y = position;
			
			icon_1.x = paddind;
			icon_2.x = paddind;
			toggler.x = int(paddind + iconSize * .5 - toggler.width * .5);
			
			icon_1.y = int(step_1.y + step_1.height * .5 - icon_1.height * .5);
			questionButton.y = int(step_1.y + step_1.height * .5 - questionButton.height * .5);
			icon_2.y = int(step_2.y + step_2.height * .5 - icon_2.height * .5);
			toggler.y = int(checkerText.y + checkerText.height * .5 - toggler.height * .5);
			
			lines.graphics.lineStyle(Math.max(1, int(Config.FINGER_SIZE * .04)), Style.color(Style.COLOR_ICON_SETTINGS));
			lines.graphics.lineTo(0, icon_2.y - icon_1.y - iconSize);
			lines.x = paddind + iconSize * .5;
			lines.y = int(icon_1.y + iconSize);
			
			scrollPanel.setWidthAndHeight(_width, getHeight() - headerHeight - okButton.height - Config.FINGER_SIZE * .7 - Config.APPLE_BOTTOM_OFFSET);
			
			okButton.x = paddind;
			okButton.y = getHeight() - paddind - Config.APPLE_BOTTOM_OFFSET - okButton.fullHeight;
			
			updateScroll();
		}
		
		private function drawButton():void 
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			if (toggler.isSelected)
			{
				textSettings = new TextFieldSettings(Lang.textProceed.toUpperCase(), Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, _width - paddind * 2, Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			}
			else
			{
				textSettings = new TextFieldSettings(Lang.textProceed.toUpperCase(), Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER), _width - paddind * 2, Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			}
			okButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .3;
			super.drawView();
		}
		
		private function drawSteps():void {
			step_1.bitmapData = TextUtils.createTextFieldData(
				"<u>"+Lang.openAccountZBX+"</u>",
				getTextWidth(),
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				true,
				Style.color(Style.COLOR_TEXT),
				Style.color(Style.COLOR_BACKGROUND),
				false, true
			);
			
			var textValue:String = Lang.depositeOnZBXAccount_2;
			if (data != null && "price" in data)
			{
				textValue = LangManager.replace(/%@/g, textValue, data.price);
			}
			
			step_2.bitmapData = TextUtils.createTextFieldData(
				textValue,
				getTextWidth(),
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				true,
				Style.color(Style.COLOR_TEXT),
				Style.color(Style.COLOR_BACKGROUND),
				false, true
			);
			
			checkerText.bitmapData = TextUtils.createTextFieldData(
				Lang.grandPermissionToZBXAccount,
				getTextWidth(),
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				true,
				Style.color(Style.COLOR_TEXT),
				Style.color(Style.COLOR_BACKGROUND),
				false, true
			);
			
			var iconClip:Sprite = new Step1Icon();
			UI.scaleToFit(iconClip, iconSize, iconSize);
			UI.colorize(iconClip, Style.color(Style.COLOR_ICON_SETTINGS));
			icon_1.bitmapData = UI.getSnapshot(iconClip);
			UI.destroy(iconClip);
			iconClip = null;
			
			iconClip = new Step2Icon();
			UI.scaleToFit(iconClip, iconSize, iconSize);
			UI.colorize(iconClip, Style.color(Style.COLOR_ICON_SETTINGS));
			icon_2.bitmapData = UI.getSnapshot(iconClip);
			UI.destroy(iconClip);
			iconClip = null;
		}
		
		private function getTextWidth():int 
		{
			return _width - iconSize - paddind * 3;
		}
		
		private function drawTitle():void 
		{
			title.bitmapData = TextUtils.createTextFieldData(
				"<b>" + Lang.toVerifyCryptodepositYouNeed + "</b>",
				_width - contentPadding * 2,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE*.4,
				true,
				Style.color(Style.COLOR_TEXT),
				Style.color(Style.COLOR_BACKGROUND),
				false, true
			);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			toggler.activate();
			okButton.activate();
			questionButton.activate();
			PointerManager.addTap(ZBXUrl, openZBXUrl);
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			toggler.deactivate();
			okButton.deactivate();
			questionButton.deactivate();
			PointerManager.removeTap(ZBXUrl, openZBXUrl);
		}
		
		private function openZBXUrl(...rest):void {
			navigateToURL(new URLRequest("https://www.zbx.one/"));
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1)
				{
					(data.callback as Function)(lastResult);
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killDelayedCallsTo(close);
			if (title != null)
				UI.destroy(title);
			title = null;
			if (lines != null)
				UI.destroy(lines);
			lines = null;
			if (icon_1 != null)
				UI.destroy(icon_1);
			icon_1 = null;
			if (icon_2 != null)
				UI.destroy(icon_2);
			icon_2 = null;
			if (step_1 != null)
				UI.destroy(step_1);
			step_1 = null;
			if (step_2 != null)
				UI.destroy(step_2);
			step_2 = null;
			if (checkerText != null)
				UI.destroy(checkerText);
			checkerText = null;
			if (okButton != null)
				okButton.dispose();
			okButton = null;
			if (questionButton != null)
				questionButton.dispose();
			questionButton = null;
			if (toggler != null)
				toggler.dispose();
			toggler = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			removeMessageClip();
		}
	}
}