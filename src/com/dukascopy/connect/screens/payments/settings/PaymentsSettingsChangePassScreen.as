/**
 * Created by aleksei.leschenko on 28.03.2017.
 */
package com.dukascopy.connect.screens.payments.settings {

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.groupList.item.vo.VOItemGL;
	import com.dukascopy.connect.gui.image.ImageFrames;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	public class PaymentsSettingsChangePassScreen extends PaymentsBaseScreen {

		private var STATE_OK:String = "STATE_OK";
		private var STATE_ATTENTION3:String = "STATE_ATTENTION3";
		private var STATE_CANCEL:String = "STATE_CANCEL";

		private static var ID_personalDetails:String = "personalDetails";
		private static var ID_notifications:String = "notifications";
		private static var ID_verficationLimits:String = "verificationLimits";

		private var _ficCurrentPass:FieldInputComponent;
		private var _ficNewPass:FieldInputComponent;
		private var _ficConfirmPass:FieldInputComponent;


		private var iconState_1:ImageFrames;
		private var iconState_2:ImageFrames;
		private var iconState_3:ImageFrames;
		private var iconState_4:ImageFrames;

		private var iconStateBM_1:Bitmap;
		private var iconStateBM_2:Bitmap;
		private var iconStateBM_3:Bitmap;
		private var iconStateBM_4:Bitmap;

		private var btnChangePassword:BitmapButton;

		private var paramCurr:String = "";
		private var paramNP:String = "";
		private var paramRP:String = "";

		public function PaymentsSettingsChangePassScreen() {
			super();
		}

		override public function initScreen(data:Object = null):void {
			PaymentsManager.activate();
			resetTitleText();
			drawBTNChangePassword();
			super.initScreen(data);
			PayManager.S_PASS_CHANGED.add(callbackPass);
			PayManager.S_PASS_CHANGE_RESPOND.add(callbackPassCR);
		}

		override protected function createView():void {
			super.createView();
			_ficNewPass = new FieldInputComponent(Lang.TEXT_ENTER_NEW_PASS, Input.MODE_PASSWORD, ficNewPassCallback, new IconEYE(), TextFormatAlign.RIGHT, true);
			_ficConfirmPass = new FieldInputComponent(Lang.confirmPassword, Input.MODE_PASSWORD, ficConfirmPassCallback, new IconEYE(), TextFormatAlign.RIGHT, true);
			_ficCurrentPass = new FieldInputComponent(Lang.TEXT_ENTER_CURR_PASS, Input.MODE_PASSWORD, ficCurrentPassCallback, new IconEYE(), TextFormatAlign.RIGHT, true);

			btnChangePassword = new BitmapButton();
			btnChangePassword.setOverflow(10, Config.FINGER_SIZE, Config.FINGER_SIZE, 10);
			btnChangePassword.setStandartButtonParams();
			btnChangePassword.setDownScale(1.03);
			btnChangePassword.setDownColor(Style.color(Style.COLOR_BUTTON_RED_DOWN));
			btnChangePassword.setOverflow(10, 10, 10, 10);
			btnChangePassword.usePreventOnDown = false;
			btnChangePassword.cancelOnVerticalMovement = true;
			btnChangePassword.tapCallback = onBTNChangePassword;
			btnChangePassword.disposeBitmapOnDestroy = true;
			btnChangePassword.x = Config.DOUBLE_MARGIN;
			btnChangePassword.show();

			drawBTNChangePassword();
			//
			iconState_1 = new ImageFrames();
			iconState_2 = new ImageFrames();
			iconState_3 = new ImageFrames();
			iconState_4 = new ImageFrames();

			iconStateBM_1 = new Bitmap();
			iconStateBM_2 = new Bitmap();
			iconStateBM_3 = new Bitmap();
			iconStateBM_4 = new Bitmap();

			iconStateBM_1.bitmapData = UI.renderSettingsText(Lang.TEXT_MARKER_1, 300, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.3, false, Style.color(Style.COLOR_TEXT), 0, 0);
			iconStateBM_2.bitmapData = UI.renderSettingsText(Lang.TEXT_MARKER_2, 300, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.3, false, Style.color(Style.COLOR_TEXT), 0, 0);
			iconStateBM_3.bitmapData = UI.renderSettingsText(Lang.TEXT_MARKER_3, 300, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.3, false, Style.color(Style.COLOR_TEXT), 0, 0);
			iconStateBM_4.bitmapData = UI.renderSettingsText(Lang.passNotMatch, 300, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.3, false, Style.color(Style.COLOR_TEXT), 0, 0);

			addToIconLock(iconState_1, IconOK, STATE_OK);
			addToIconLock(iconState_1, IconAttention3, STATE_ATTENTION3);
			addToIconLock(iconState_1, IconCancel, STATE_CANCEL);

			addToIconLock(iconState_2, IconOK, STATE_OK);
			addToIconLock(iconState_2, IconAttention3, STATE_ATTENTION3);
			addToIconLock(iconState_2, IconCancel, STATE_CANCEL);

			addToIconLock(iconState_3, IconOK, STATE_OK);
			addToIconLock(iconState_3, IconAttention3, STATE_ATTENTION3);
			addToIconLock(iconState_3, IconCancel, STATE_CANCEL);

			addToIconLock(iconState_4, IconOK, STATE_OK);
			addToIconLock(iconState_4, IconAttention3, STATE_ATTENTION3);
			addToIconLock(iconState_4, IconCancel, STATE_CANCEL);

			iconState_1.toFrame(STATE_ATTENTION3);
			iconState_2.toFrame(STATE_ATTENTION3);
			iconState_3.toFrame(STATE_ATTENTION3);
			iconState_4.toFrame(STATE_CANCEL);


			scrollPanel.addObject(_ficNewPass);
			scrollPanel.addObject(_ficConfirmPass);
			scrollPanel.addObject(_ficCurrentPass);

			scrollPanel.addObject(iconState_1);
			scrollPanel.addObject(iconState_2);
			scrollPanel.addObject(iconState_3);
			scrollPanel.addObject(iconStateBM_1);
			scrollPanel.addObject(iconStateBM_2);
			scrollPanel.addObject(iconStateBM_3);


			scrollPanel.addObject(btnChangePassword);

			visibleIconState4(false);
		}

		private function visibleIconState4(b:Boolean):void {
			if (b) {
				scrollPanel.addObject(iconState_4);
				scrollPanel.addObject(iconStateBM_4);
			} else {
				scrollPanel.removeObject(iconState_4);
				scrollPanel.removeObject(iconStateBM_4);
			}
			drawBTNPos();
			if(scrollPanel)scrollPanel.updateObjects();
		}

		private function onBTNChangePassword():void {
			if(paramCurr.length >= 6){
				PayManager.callChangePassword(paramCurr, paramNP);
				deactivateScreen();
			}else{
				DialogManager.alert(Lang.textAlert, Lang.TEXT_ENTER_CURR_PASS)
			}
		}

		private function callbackPassCR(respond:PayRespond):void {
			if (respond.error)
				DialogManager.alert(Lang.textAlert, respond.errorMsg);
			callbackPass();
		}

		private function callbackPass():void {
			onBack();
		}

		private function addToIconLock(iconState_1:ImageFrames, _calss:Class, frameName:String):void {
			var iconSize:int = Config.FINGER_SIZE * 0.36;//iconLockOn.height;//
			var bm:Bitmap = new Bitmap(UI.renderAsset(new _calss as MovieClip, iconSize, iconSize, true, "PaymentsSettingsChangePassScreen.ImageFrames.frame"));
			iconState_1.addFrame(bm as DisplayObject, frameName);
		}

		private function ficCurrentPassCallback(obj:Object = null):void {
			if (_ficCurrentPass) {
				paramCurr = _ficCurrentPass.value;
			}
		}

		private function ficNewPassCallback(obj:Object = null):void {
			if (_ficConfirmPass && obj is Boolean) {
				_ficConfirmPass.isMode = obj;
			} else if (_ficNewPass) {
				var value:String = _ficNewPass.value;
				if (paramNP != value) {
					paramNP = value;
					checkState();
				}
			}
		}

		private function ficConfirmPassCallback(obj:Object = null):void {
			if (_ficNewPass && obj is Boolean) {
				_ficNewPass.isMode = obj;
			} else if (_ficConfirmPass) {
				var value:String = _ficConfirmPass.value;
				if (paramRP != value) {
					paramRP = value;
					checkState();
				}
			}
		}

		private function checkState():void {
			//deactive btn
			if (btnChangePassword) {
				btnChangePassword.deactivate();
				btnChangePassword.alpha = 0.5;
			}
			//
			if (paramNP == "" && paramRP == "") {
				iconState_1.toFrame(STATE_ATTENTION3);
				iconState_2.toFrame(STATE_ATTENTION3);
				iconState_3.toFrame(STATE_ATTENTION3);
				//iconState_4.toFrame(STATE_CANCEL);
				visibleIconState4(false);
			} else if (paramNP == "" && paramRP != "") {
				iconState_1.toFrame(STATE_ATTENTION3);
				iconState_2.toFrame(STATE_ATTENTION3);
				iconState_3.toFrame(STATE_ATTENTION3);
				iconState_4.toFrame(STATE_CANCEL);
				visibleIconState4(true);
			} else if (paramNP != "" && paramRP == "") {
				//check
				iconState_1.toFrame(check1p()?STATE_OK : STATE_CANCEL);
				iconState_2.toFrame(check2p()?STATE_OK : STATE_CANCEL);
				iconState_3.toFrame(check3p()?STATE_OK : STATE_CANCEL);
				visibleIconState4(false);
			} else {
				iconState_1.toFrame(check1p()?STATE_OK : STATE_CANCEL);
				iconState_2.toFrame(check2p()?STATE_OK : STATE_CANCEL);
				iconState_3.toFrame(check3p()?STATE_OK : STATE_CANCEL);
				iconState_4.toFrame(paramNP == paramRP ? STATE_OK : STATE_CANCEL);
				visibleIconState4(true);
				//
				if(iconState_1.currentFrame == STATE_OK && iconState_2.currentFrame == STATE_OK && iconState_3.currentFrame == STATE_OK && iconState_4.currentFrame == STATE_OK ){
					//active btn
					if (btnChangePassword) {
						btnChangePassword.activate();
						btnChangePassword.alpha = 1;
					}
				}
			}
		}

		private function check1p():Boolean {
			return paramNP.length >= 6;
		}


		private function check2p():Boolean {
			if(paramNP.length < 4)
			{
				return false;
			}
			var arr :Array = paramNP.split("");
			var arrTemp :Array = [];
			var str:String = "";
			str = arr.pop();
			arrTemp.push(str);
			var count:int = 0;
			while ( arr.length>0) {
				str = arr.pop();
				count = 0;
				for (var j:int = 0; j < arrTemp.length; j++) {
					if(str != arrTemp[j]){
						count ++;
					}
				}
				if(count == arrTemp.length){
					arrTemp.push(str);
				}
			}
			return arrTemp.length>=4
		}

		private function check3p():Boolean {
			var n:Number=Number(paramNP);
			if (isNaN(n)){
//				trace("not a number");
				return true;
			} else {
//				trace("number="+n);
				return false;
			}

		}

		override protected function addScrollPanel():void {
			// Add scroll panel
			super.addScrollPanel();
			_view.addChild(scrollPanel.view);
		}

		private function drawBTNChangePassword():void {
			btnChangePassword.setBitmapData(UI.renderButton(Lang.changePassword, _width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, Style.color(Style.COLOR_BUTTON_TEXT), 
					Style.color(Style.COLOR_BUTTON_RED), Style.color(Style.COLOR_BUTTON_RED_DOWN), Style.size(Style.SIZE_BUTTON_CORNER)), true);
			btnChangePassword.setHitZone(_width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE);

			btnChangePassword.x = Config.DOUBLE_MARGIN;
			btnChangePassword.y = _ficConfirmPass.y + _ficConfirmPass.height + Config.DOUBLE_MARGIN;
		}

		private function callbackItemGroupList(vo:VOItemGL):void {
			if (vo == null) {
				//error func logic
				return;
			}

		}

		private function createIconByMCandName(mc:Sprite, nameIcon:String, isBlock:Boolean = false, color:uint = 0xFFFFFF):BitmapData {
			var topBarBtnSize:Number = Config.FINGER_SIZE * .4;
			if (isBlock) {
				var myColorTransform:ColorTransform = new ColorTransform();
				myColorTransform.color = color;
				mc.transform.colorTransform = myColorTransform;
			}
			return UI.renderAsset(mc, topBarBtnSize, topBarBtnSize, true, nameIcon);
		}

		override public function setWidthAndHeight(width:int, height:int):void {
			_ficNewPass.setWidthAndHeight(width - Config.DIALOG_MARGIN * 2);
			_ficConfirmPass.setWidthAndHeight(width - Config.DIALOG_MARGIN * 2);
			_ficCurrentPass.setWidthAndHeight(width - Config.DIALOG_MARGIN * 2);
			drawIconStateBM();
			super.setWidthAndHeight(width, height);
		}

		override protected function drawView():void {
			_ficCurrentPass.x = Config.DIALOG_MARGIN;
			_ficCurrentPass.y = Config.DOUBLE_MARGIN;
			_ficNewPass.x = Config.DIALOG_MARGIN;
			_ficNewPass.y = _ficCurrentPass.y + _ficCurrentPass.height /*+ Config.DOUBLE_MARGIN*/;
			_ficConfirmPass.x = Config.DIALOG_MARGIN;
			_ficConfirmPass.y = _ficNewPass.y + _ficNewPass.height /*+ Config.DOUBLE_MARGIN*/;
			_ficNewPass.drawView();
			_ficConfirmPass.drawView();
			_ficCurrentPass.drawView();
			//
			iconState_1.y = _ficConfirmPass.y + _ficConfirmPass.height + Config.MARGIN;
			iconState_2.y = iconState_1.y + iconState_1.height + Config.MARGIN;
			iconState_3.y = iconState_2.y + iconState_2.height + Config.MARGIN;
			//
			iconState_1.x = iconState_2.x = iconState_3.x = Config.DOUBLE_MARGIN;
			iconStateBM_1.x = iconStateBM_2.x = iconStateBM_3.x = iconState_1.x + iconState_1.width + Config.DOUBLE_MARGIN;
			//
			iconStateBM_1.y = iconState_1.y;
			iconStateBM_2.y = iconState_2.y;
			iconStateBM_3.y = iconState_3.y;
			//
			drawBTNPos();
			//
			super.drawView();
		}

		private function drawBTNPos():void {
			btnChangePassword.x = Config.DOUBLE_MARGIN;
			if(iconStateBM_4.parent == null ){
				btnChangePassword.y = iconStateBM_3.y + iconStateBM_3.height + Config.DOUBLE_MARGIN * 2;
			}else{
				iconState_4.x =  Config.DOUBLE_MARGIN;
				iconStateBM_4.x = iconStateBM_1.x;
				iconState_4.y = iconState_3.y + iconState_3.height + Config.MARGIN;
				iconStateBM_4.y = iconState_4.y;
				btnChangePassword.y = iconStateBM_4.y + iconStateBM_4.height + Config.DOUBLE_MARGIN * 2;
			}
		}

		override public function drawViewLang():void {
			resetTitleText();
			drawIconStateBM();

			super.drawViewLang();
		}

		private function drawIconStateBM():void {
			if(iconStateBM_1.bitmapData){
				UI.disposeBMD(iconStateBM_1.bitmapData);
			}
			if(iconStateBM_2.bitmapData){
				UI.disposeBMD(iconStateBM_2.bitmapData);
			}
			if(iconStateBM_3.bitmapData){
				UI.disposeBMD(iconStateBM_3.bitmapData);
			}
			if(iconStateBM_4.bitmapData){
				UI.disposeBMD(iconStateBM_4.bitmapData);
			}
			if(iconStateBM_1)iconStateBM_1.bitmapData = UI.renderSettingsText(Lang.TEXT_MARKER_1, _width, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.3, false, Style.color(Style.COLOR_SUBTITLE), 0, 0);
			if(iconStateBM_2)iconStateBM_2.bitmapData = UI.renderSettingsText(Lang.TEXT_MARKER_2, _width, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.3, false, Style.color(Style.COLOR_SUBTITLE), 0, 0);
			if(iconStateBM_3)iconStateBM_3.bitmapData = UI.renderSettingsText(Lang.TEXT_MARKER_3, _width, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.3, false, Style.color(Style.COLOR_SUBTITLE), 0, 0);
			if(iconStateBM_4)iconStateBM_4.bitmapData = UI.renderSettingsText(Lang.passNotMatch, _width, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.3, false, Style.color(Style.COLOR_SUBTITLE), 0, 0);

		}

		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;

			//your code
			_ficNewPass.activateScreen();
			_ficConfirmPass.activateScreen();
			_ficCurrentPass.activateScreen();
			if (btnChangePassword != null) {
				btnChangePassword.activate();
			}
		}

		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			_ficCurrentPass.deactivateScreen();
			_ficNewPass.deactivateScreen();
			_ficConfirmPass.deactivateScreen();
			//your code
			if (btnChangePassword != null) {
				btnChangePassword.deactivate();
			}

		}

		override public function clearView():void {
			super.clearView();
		}

		override public function dispose():void {
			super.dispose();
			PaymentsManager.deactivate();
			//your code
			PayManager.S_PASS_CHANGED.remove(callbackPass);
			PayManager.S_PASS_CHANGE_RESPOND.remove(callbackPassCR);

			_ficCurrentPass.dispose();
			_ficNewPass.dispose();
			_ficConfirmPass.dispose();
			if (btnChangePassword != null)
				btnChangePassword.dispose();
			btnChangePassword = null;

			if (iconState_1) {
				iconState_1.dispose();
			}
			if (iconState_2) {
				iconState_2.dispose();
			}
			if (iconState_3) {
				iconState_3.dispose();
			}
			if (iconStateBM_1) {
				UI.destroy(iconStateBM_1);
			}
			if (iconStateBM_2) {
				UI.destroy(iconStateBM_2);
			}
			if (iconStateBM_3) {
				UI.destroy(iconStateBM_3);
			}
		}

		override public function onBack(e:Event = null):void {
			super.onBack(e);
			//
		}

		override protected function resetTitleText():void {
			txtTitle = Lang.changePassword;
		}

		// WEB VIEW METHODS ==============================================================================
		// ===============================================================================================

		override protected function showWebView(url:String, isMyCard:Boolean = false):void {
			super.showWebView(url, isMyCard);
		}

	}
}
