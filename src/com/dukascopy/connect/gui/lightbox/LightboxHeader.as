package com.dukascopy.connect.gui.lightbox {
	
	import assets.DotsButton;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.AttachScreenButton;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.utils.FilesSaveUtility;
	import com.dukascopy.connect.utils.TextUtils;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageOrientation;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author SergeyDobarin
	 */
	public class LightboxHeader extends Sprite
	{
		private var componentWidth:int;
		private var componentHeight:int;
		private var backround:Shape;
		private var backButton:BitmapButton;
		private var title:Bitmap;
		private var settingsButton:BitmapButton;
		private var currentTitle:String;
		private var buttonsData:Vector.<IScreenAction>;
		private var buttons:Vector.<AttachScreenButton>;
		private var rotationValue:Number;
		private var rightGap:Number;
		
		public const S_ON_BACK:Signal = new Signal("LightboxHeader.S_ON_BACK");
		public var shown:Boolean = true;
		public var settingsCallback:Function;
		
		public function LightboxHeader(componentWidth:int, componentHeight:int) {
			this.componentWidth = componentWidth;
			this.componentHeight = componentHeight;
			
			construct();
		}
		
		private function construct():void {
			echo("LightboxHeader", "construct", "START");
			backround = new Shape();
			backround.graphics.lineStyle(2, 0xFFFFFF);
			backround.graphics.beginFill(0, 0.8);
			backround.graphics.drawRect(0, 0, componentWidth, componentHeight);
			backround.graphics.endFill();
			addChild(backround);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1.3);
			backButton.setDownColor(0xFFFFFF);
			backButton.tapCallback = onBtnBackTap;
			backButton.disposeBitmapOnDestroy = true;
			backButton.show();
			addChild(backButton);
			var iconBack:IconBack = new IconBack();
			iconBack.width = iconBack.height = Config.FINGER_SIZE * .38 * .85;
			backButton.setBitmapData(UI.getSnapshot(iconBack, StageQuality.HIGH, "Lightbox.backButon"), true);
			UI.destroy(iconBack);
			iconBack = null;
			var buttonOffset:int = (componentHeight - backButton.height) * .5;
			backButton.setOverflow(buttonOffset, buttonOffset, buttonOffset, buttonOffset);
			
			var leftGap:int = 0;
			rightGap = 0;
			rotationValue = 0;
			if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT) {
				rotationValue = 0;
				leftGap = 0;
				rightGap = 0;
			} else if (MobileGui.currentOrientation == StageOrientation.ROTATED_RIGHT) {
				rotationValue = -90;
				leftGap = 0;
				rightGap = Config.APPLE_TOP_OFFSET;
			} else if (MobileGui.currentOrientation == StageOrientation.ROTATED_LEFT) {
				rotationValue = 90;
				leftGap = Config.APPLE_TOP_OFFSET;
				rightGap = 0;
			}
			
			backButton.x = buttonOffset + leftGap;
			backButton.y = buttonOffset;
			backButton.rotationAdded = rotationValue;
			backButton.activate();
			
		//	createSettingsButton();
			
			title = new Bitmap();
			title.x = backButton.x + backButton.width + Config.MARGIN * 2;
			addChild(title);
			echo("LightboxHeader", "construct", "END");
			
			FilesSaveUtility.signalOnImageSaved.add(onImageSaved);
		}
		
		private function onImageSaved():void {
			createButtons(buttonsData);
		}
		
		private function createSettingsButton():void {
			settingsButton = new BitmapButton();
			settingsButton.rotationAdded = rotationValue;
			settingsButton.setStandartButtonParams();
			settingsButton.setDownScale(1);
			settingsButton.setDownColor(0xFFFFFF);
			settingsButton.tapCallback = onBtnSettingsTap;
			settingsButton.disposeBitmapOnDestroy = true;
			
			addChild(settingsButton);
			var iconSettings:DotsButton = new DotsButton();
			UI.scaleToFit(iconSettings, Config.FINGER_SIZE * .38 * .85, Config.FINGER_SIZE * .38 * .85);
			settingsButton.setBitmapData(UI.getSnapshot(iconSettings, StageQuality.HIGH, "Lightbox.settingsButon"), true);
			UI.destroy(iconSettings);
			iconSettings = null;
			var buttonOffset:int = (componentHeight - settingsButton.height) * .5;
			settingsButton.setOverflow(buttonOffset, buttonOffset + Config.FINGER_SIZE*.5, buttonOffset, buttonOffset);
			settingsButton.x = int(componentWidth - componentHeight*.5 + settingsButton.width*.5 - rightGap);
			settingsButton.y = buttonOffset;
			
			if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT) {
				settingsButton.activate();
				settingsButton.show();
			} else {
				settingsButton.hide();
			}
		}
		
		private function onBtnSettingsTap():void {
			if (settingsCallback)
				settingsCallback();
		}
		
		public function setData(title:String, buttonsData:Vector.<IScreenAction>):void {
			this.buttonsData = buttonsData;
			createButtons(buttonsData, getRightGap());
			setTitle(title);
		}
		
		private function getRightGap():int {
			rightGap = 0;
			if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT) {
				rightGap = 0;
			} else if (MobileGui.currentOrientation == StageOrientation.ROTATED_RIGHT) {
				rightGap = Config.APPLE_TOP_OFFSET;
			} else if (MobileGui.currentOrientation == StageOrientation.ROTATED_LEFT) {
				rightGap = 0;
			}
			return rightGap;
		}
		
		private function createButtons(buttonsData:Vector.<IScreenAction>, rightGap:int = 0):void {
			clearButtons();
			if (buttonsData != null) {
				buttons = new Vector.<AttachScreenButton>();
				var button:AttachScreenButton;
				var l:int = buttonsData.length;
				var position:int = componentWidth - rightGap;
				for (var i:int = 0; i < l; i++) {
					button = createButton(buttonsData[i]);
					position -= button.width;
					button.x = position;
					button.activate();
					buttons.push(button);
					addChild(button);
					button.show();
				}
			}
		}
		
		private function createButton(buttonAction:IScreenAction):AttachScreenButton {
			var button:AttachScreenButton = new AttachScreenButton(buttonAction);
			button.setSizes(componentHeight, componentHeight, Config.FINGER_SIZE*.5);
			button.draw();
			button.setRotation(rotationValue);
			return button;
		}
		
		private function clearButtons():void {
			if (buttons != null) {
				var l:int = buttons.length;
				for (var i:int = 0; i < l; i++) {
					buttons[i].dispose();
					if (contains(buttons[i])) {
						removeChild(buttons[i]);
					}
				}
				buttons = null;
			}
		}
		
		private function setTitle(value:String):void {
			echo("LightboxHeader", "setTitle", "START");
			if (!value)	{
				return;
			}
			currentTitle = value;
			if (title != null) {
				if (title.bitmapData) {
					title.bitmapData.dispose();
					title.bitmapData = null;
				}
				
				var titleWidth:int = componentWidth - backButton.x - backButton.width - Config.MARGIN * 3;
				if (settingsButton != null && settingsButton.visible) {
					titleWidth -= settingsButton.width + componentHeight*.5 - Config.MARGIN;
				}
				
				if (buttons != null) {
					var l:int = buttons.length;
					for (var i:int = 0; i < l; i++) {
						titleWidth -= buttons[i].width;
					}
				}
				
				title.bitmapData = TextUtils.createTextFieldData(currentTitle, titleWidth, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .38, false, 0xFFFFFF, 0, true);
				title.y = int(componentHeight * .5 - title.height * .5);
			}
			echo("LightboxHeader", "setTitle", "END");
		}
		
		public function getHeight():Number {
			return componentHeight;
		}
		
		public function showSettingsButton():void {
			echo("LightboxHeader", "showSettingsButton", "START");
			if (settingsButton != null) {
				settingsButton.visible = true;
				setTitle(currentTitle);
			}
			echo("LightboxHeader", "showSettingsButton", "END");
		}
		
		public function hideSettingsButton():void {
			if (settingsButton != null) {
				settingsButton.visible = false;
			}
		}
		
		public function activate():void {
			if (settingsButton != null)
				settingsButton.activate();
			backButton.activate();
			if (buttons != null) {
				var l:int = buttons.length;
				for (var i:int = 0; i < l; i++) {
					buttons[i].activate();
				}
			}
		}
		
		public function deactivate():void {
			if (settingsButton != null)
				settingsButton.deactivate();
			backButton.deactivate();
			if (buttons != null) {
				var l:int = buttons.length;
				for (var i:int = 0; i < l; i++) {
					buttons[i].deactivate();
				}
			}
		}
		
		public function setSize(viewWidth:int, viewHeight:int):void {
			echo("LightboxHeader", "setSize", "START");
			this.componentWidth = viewWidth;
			this.componentHeight = viewHeight;
			
			if (backround != null)
			{
				backround.graphics.clear();
				backround.graphics.beginFill(0, 0.8);
				backround.graphics.drawRect(0, 0, componentWidth, componentHeight);
				backround.graphics.endFill();
			}
			
			var leftGap:int = 0;
			var rightGap:int = 0;
			var rotationValue:Number = 0;
			if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT)
			{
				rotationValue = 0;
				leftGap = 0;
				rightGap = 0;
			}
			else if (MobileGui.currentOrientation == StageOrientation.ROTATED_RIGHT)
			{
				rotationValue = -90;
				leftGap = 0;
				rightGap = Config.APPLE_TOP_OFFSET;
			}
			else if (MobileGui.currentOrientation == StageOrientation.ROTATED_LEFT)
			{
				rotationValue = 90;
				leftGap = Config.APPLE_TOP_OFFSET;
				rightGap = 0;
			}
			
			if (settingsButton != null)	{
				if (MobileGui.currentOrientation == StageOrientation.UPSIDE_DOWN || MobileGui.currentOrientation == StageOrientation.DEFAULT) {
					settingsButton.show();
					settingsButton.activate();
				}
				else {
					settingsButton.hide();
					settingsButton.deactivate();
				}
				
				settingsButton.rotationAdded = rotationValue;
				settingsButton.x = int(componentWidth - componentHeight*.5 + settingsButton.width*.5 - rightGap);
			}
			
			createButtons(buttonsData, rightGap);
			
			if (backButton != null)	{
				var buttonOffset:int = (componentHeight - backButton.height) * .5;
				backButton.rotationAdded = rotationValue;
				backButton.x = buttonOffset + leftGap;
				backButton.y = buttonOffset;
			}
			
			title.x = backButton.x + backButton.width + Config.MARGIN * 2;
			
			setTitle(currentTitle);
			
			echo("LightboxHeader", "setSize", "END");
		}
		
		private function onBtnBackTap(e:Event = null):void {
			S_ON_BACK.invoke();
		}
		public function dispose():void {
			clearButtons();
			
			if (title != null) {
				UI.destroy(title);
				title = null;
			}
			
			if (backButton != null) {
				backButton.dispose();
				backButton = null;				
			}
			
			if (settingsButton != null){
				settingsButton.dispose();
				settingsButton = null;				
			}
			if (backround != null){
				UI.destroy(backround);
				backround = null;
			}
			settingsCallback = null;
			
			FilesSaveUtility.signalOnImageSaved.remove(onImageSaved);
		}
	}
}