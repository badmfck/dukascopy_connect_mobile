package com.dukascopy.connect.screens.payments.settings {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.loader.DotLoader;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class ItemSubWithoutSetting extends Sprite {
		
		public static const STATE_OPEN:String = "STATE_OPEN";
		public static const STATE_BTNS:String = "STATE_BTNS";
		public static const STATE_SAVED:String = "STATE_SAVED";
		public static const STATE_WAIT:String = "STATE_WAIT";
		
		public static const PWP_LIMIT_AMOUNT:String = "PWP_LIMIT_AMOUNT";
		public static const PWP_LIMIT_DAILY:String = "PWP_LIMIT_DAILY";
		
		private var label:Bitmap;
		private var input:Input;
		private var iconOpen:Bitmap;
		private var iconSaved:Bitmap;
		private var btnSave:BitmapButton;
		private var btnCancel:BitmapButton;
		private var dotLoader:DotLoader;
		
		private var state:String = STATE_OPEN;
		
		private var trueWidth:Number = 320;
		private var type:String;
		private var labelText:String;
		
		private var curValue:int;
		private var maxValue:int;
		
		private var lastCallID:String = "-1";
		
		private var activated:Boolean = false;
		
		public function ItemSubWithoutSetting(type:String) {
			this.type = type;
			
			curValue = getPWPLimitValue();
			maxValue = getMaxPWPLimit();
			
			input = new Input(Input.MODE_DIGIT_DECIMAL);
			input.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			input.setTextColor(Style.color(Style.COLOR_TEXT));
			input.setTextStart(0);
			input.setMaxValue(maxValue);
			addChild(input.view);
			setInputValue(curValue + "");
			
			iconOpen = new Bitmap(
				UI.renderAsset(
					new SWFRoundTickWhiteGrey(),
					Config.FINGER_SIZE * 0.4,
					Config.FINGER_SIZE * 0.4,
					true,
					"LimitWithoutSetting.iconOpen"
				),
				"auto",
				true
			);
			setState(STATE_OPEN);
		}
		
		private function createBTNs():void {
			if (btnSave != null)
				return;
			btnSave = new BitmapButton();
			btnSave.setStandartButtonParams();
			btnSave.usePreventOnDown = false;
			btnSave.cancelOnVerticalMovement = true;
			btnSave.tapCallback = onSave;
			btnSave.show();
			btnSave.setBitmapData(
				UI.renderAsset(
					new SWFRoundTickWhiteGreen(),
					Config.FINGER_SIZE * 0.4,
					Config.FINGER_SIZE * 0.4,
					true,
					"LimitWithoutSetting.iconSave"
				),
				true
			);
			btnCancel = new BitmapButton();
			btnCancel.setStandartButtonParams();
			btnCancel.usePreventOnDown = false;
			btnCancel.cancelOnVerticalMovement = true;
			btnCancel.tapCallback = onCancel;
			btnCancel.show();
			btnCancel.setBitmapData(
				UI.renderAsset(
					new SWFRoundCrossIconWhiteRed(),
					Config.FINGER_SIZE * 0.4,
					Config.FINGER_SIZE * 0.4,
					true,
					"LimitWithoutSetting.iconCancel"
				),
				true
			);
			btnCancel.x = iconOpen.x;
			btnCancel.y = iconOpen.y;
			btnSave.x = btnCancel.x - btnSave.width - Config.DIALOG_MARGIN;
			btnSave.y = iconOpen.y;
			if (activated == true) {
				btnSave.activate();
				btnCancel.activate();
			}
		}
		
		private function createSavedIcon():void {
			if (iconSaved != null)
				return;
			iconSaved = new Bitmap(
				UI.renderAsset(
					new SWFRoundTickGreenWhite(),
					Config.FINGER_SIZE * 0.4,
					Config.FINGER_SIZE * 0.4,
					true,
					"LimitWithoutSetting.iconSaved"
				),
				"auto",
				true
			);
			iconSaved.x = iconOpen.x;
			iconSaved.y = iconOpen.y;
		}
		
		private function createDotLoader():void {
			if (dotLoader != null)
				return;
			dotLoader = new DotLoader();
			dotLoader.x = trueWidth - (dotLoader.width);
			dotLoader.y = int(input.view.y + (input.height - dotLoader.height) * .5);
		}
		
		private function setState(state:String):void {
			this.state = state;
			switch (state) {
				case STATE_OPEN: {
					if (btnCancel != null && btnCancel.parent != null)
						btnCancel.parent.removeChild(btnCancel);
					if (btnSave != null && btnSave.parent != null)
						btnSave.parent.removeChild(btnSave);
					if (iconSaved != null && iconSaved.parent != null)
						iconSaved.parent.removeChild(iconSaved);
					if (dotLoader != null) {
						dotLoader.stopAnim();
						if (dotLoader.parent != null)
							dotLoader.parent.removeChild(dotLoader);
					}
					addChild(iconOpen);
					if (activated == true)
						input.activate();
					break;
				}
				case STATE_SAVED: {
					if (btnCancel != null && btnCancel.parent != null)
						btnCancel.parent.removeChild(btnCancel);
					if (btnSave != null && btnSave.parent != null)
						btnSave.parent.removeChild(btnSave);
					if (iconOpen != null && iconOpen.parent != null)
						iconOpen.parent.removeChild(iconOpen);
					if (dotLoader != null) {
						dotLoader.stopAnim();
						if (dotLoader.parent != null)
							dotLoader.parent.removeChild(dotLoader);
					}
					createSavedIcon()
					addChild(iconSaved);
					if (activated == true)
						input.activate();
					break;
				}
				case STATE_WAIT : {
					if (btnCancel != null && btnCancel.parent != null)
						btnCancel.parent.removeChild(btnCancel);
					if (btnSave != null && btnSave.parent != null)
						btnSave.parent.removeChild(btnSave);
					if (iconSaved != null && iconSaved.parent != null)
						iconSaved.parent.removeChild(iconSaved);
					if (iconOpen != null && iconOpen.parent != null)
						iconOpen.parent.removeChild(iconOpen);
					createDotLoader();
					dotLoader.startAnim();
					addChild(dotLoader);
					input.deactivate();
					break;
				}
				case STATE_BTNS : {
					if (iconSaved != null && iconSaved.parent != null)
						iconSaved.parent.removeChild(iconSaved);
					if (iconOpen != null && iconOpen.parent != null)
						iconOpen.parent.removeChild(iconOpen);
					if (dotLoader != null) {
						dotLoader.stopAnim();
						if (dotLoader.parent != null)
							dotLoader.parent.removeChild(dotLoader);
					}
					createBTNs();
					addChild(btnSave);
					addChild(btnCancel);
					if (activated == true)
						input.activate();
					break;
				}
			}
		}
		
		private function onCancel():void {
			setInputValue(curValue + "");
			setState(STATE_OPEN);
		}
		
		private function onSave():void {
			setState(STATE_WAIT);
			lastCallID = new Date().getTime().toString() + "_pwp";
			if (type == PWP_LIMIT_AMOUNT)
				PayManager.callPostAccountSettings(lastCallID , -1, int(input.value), -1);
			else
				PayManager.callPostAccountSettings(lastCallID , -1, -1, int(input.value));
		}
		
		public function onServerRespond(callID:String = "", hasError:Boolean = false):void {
			if (lastCallID != callID)
				return;
			if (hasError == true) {
				setInputValue(curValue + "");
				setState(STATE_OPEN);
				return;
			}
			curValue = Number(input.value);
			setState(STATE_SAVED);
		}
		
		public function drawLabel(value:String):void {
			if (value == null)
				return;
			labelText = value;
			if (label == null) {
				label = new Bitmap();
				addChild(label);
			}
			if (label.bitmapData != null)
				UI.disposeBMD(label.bitmapData);
			label.bitmapData = UI.renderText(
				value,
				trueWidth,
				Config.FINGER_SIZE,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				false,
				Style.color(Style.COLOR_SUBTITLE),
				Style.color(Style.COLOR_BACKGROUND),
				true,
				"ListWithoutSetting.label"
			);
			drawView(false);
		}
		
		public function activateScreen():void {
			if (activated == true)
				return;
			activated = true;
			input.activate();
			input.S_CHANGED.add(onValueChanged);
			input.S_KEYBOARD_CLOSED.add(checkForEmptyValue);
			if (btnSave != null)
				btnSave.activate();
			if (btnCancel != null)
				btnCancel.activate();
		}
		
		public function deactivateScreen():void {
			if (activated == false)
				return;
			activated = false;
			input.S_CHANGED.remove(onValueChanged);
			input.S_KEYBOARD_CLOSED.remove(checkForEmptyValue);
			input.deactivate();
			if (btnSave != null)
				btnSave.deactivate();
			if (btnCancel != null)
				btnCancel.deactivate();
		}
		
		private function onValueChanged():void {
			var tempValue:Number = Number(input.value);
			if (tempValue != curValue) {
				if (tempValue > 0 && tempValue < maxValue + 1) {
					setState(STATE_BTNS);
					return;
				}
				if (tempValue > maxValue) {
					ToastMessage.display(LangManager.replace(Lang.regExtValue, Lang.maxValueDecsription, String(maxValue)));
					setState(STATE_OPEN);
					return
				}
				if (tempValue < 1)
					setState(STATE_OPEN);
			} else
				setState(STATE_OPEN);
		}
		
		private function checkForEmptyValue():void {
			if (input.value == "")
				setInputValue(curValue + "");
		}
		
		public function setWidthAndHeight(w:int):void {
			if (trueWidth == w)
				return;
			trueWidth = w;
			input.width = int(trueWidth);
			drawView();
		}
		
		private function drawView(redrawLabel:Boolean = true):void {
			if (label != null) {
				if (redrawLabel == true)
					drawLabel(labelText);
				input.view.y = label.y + label.height + Config.MARGIN;
			}
			
			iconOpen.x = trueWidth - iconOpen.width;
			iconOpen.y = int(input.view.y + (input.height - iconOpen.height) * .5);
			if (iconSaved != null) {
				iconSaved.x = iconOpen.x;
				iconSaved.y = iconOpen.y;
			}
			if (btnCancel != null) {
				btnCancel.x = iconOpen.x;
				btnCancel.y = iconOpen.y;
			}
			if (btnSave != null) {
				btnSave.x = btnCancel.x - btnSave.width;
				btnSave.y = iconOpen.y;
			}
			if (dotLoader != null) {
				dotLoader.x = trueWidth - dotLoader.width;
				dotLoader.y = iconOpen.y;
			}
		}
		
		override public function get width():Number {
			return trueWidth;
		}
		
		public function setInputValue(value:String):void {
			input.value = value;
		}
		
		private function getPWPLimitValue():int {
			if (type == PWP_LIMIT_AMOUNT)
				return PayManager.accountInfo.settings.PWP_LIMIT_AMOUNT;
			else
				return PayManager.accountInfo.settings.PWP_LIMIT_DAILY;
		}
		
		private function getMaxPWPLimit():int {
			if (type == PWP_LIMIT_AMOUNT)
				return PayManager.accountInfo.settings.maxPWPLimitAmount;
			else
				return PayManager.accountInfo.settings.maxPWPLimitDaily;
		}
		
		public function dispose():void {
			graphics.clear();
			if (btnCancel != null) {
				btnCancel.dispose();
				btnCancel = null;
			}
			if (btnSave != null) {
				btnSave.dispose();
				btnSave = null;
			}
			if(dotLoader != null) {
				dotLoader.dispose();
				dotLoader = null;
			}
			if(label != null) {
				UI.destroy(label);
				label = null;
			}
			if(iconOpen != null) {
				UI.destroy(iconOpen);
				iconOpen = null;
			}
			if(iconSaved != null) {
				UI.destroy(iconSaved);
				iconSaved = null;
			}
		}
	}
}