/**
 * Created by aleksei.leschenko on 24.08.2016.
 */
package com.dukascopy.connect.screens.payments.managers {
	import assets.CheckEmpty;
	import assets.CheckFill;
	import assets.LockClosedGreen;
	import assets.LockClosedGrey;
	import assets.LockOpenGrey;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.image.ImageFrames;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.BitmapToggleSwitch;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;



	public class SendMoneySecureCodeItem {
		private var TXT_5_STARS:String = "*****";
		//
		public var view:Sprite;
		
		private var btnTop:BitmapButton;
		private var iconsTop:ImageFrames;
		private var iconsShowPass:ImageFrames;
		
		private var labelBitmapSecureCode:Bitmap;
		private var bitmapLockDesc:Bitmap;
		private var showPassLabel:Bitmap;
		private var btnShowPass:BitmapButton;
		
		private var LOCK_OPEN:String = "LOCK_OPEN";
		private var LOCK_CLOSE:String = "LOCK_CLOSE";
		private var LOCK_CLOSE_MATCH:String = "LOCK_CLOSE_MATCH";
		private var _enterSC:String = "";
		private var _repeatSC:String = "";
		
		private var _code:String = "";
		///// temp
		private var repeatButtonSC:BitmapButton;
		private var enterButtonSC:BitmapButton;
		
		private var containerShowPassLabal:Sprite;
		private var _isShowPass:Boolean;
		
		private static var TOGGLER_BMD:ImageBitmapData;
		private static var TOGGLERBG_BMD:ImageBitmapData;
		private var _width:Number = 1;
		public var callbackFunc:Function;
		
		public function SendMoneySecureCodeItem() {
		}
		
		private var iconLock:ImageFrames;
		private var ifShowPass:ImageFrames;
		private var toggler:BitmapToggleSwitch;
		private var iconLockOff:Bitmap;
		private var iconLockOn:Bitmap;
		private var tempView:Sprite;
		//
		private var initalized:Boolean;
		private var _isON:Boolean;
		private var _isChanged:Boolean;
		public var isShowedPopUp:Boolean = false;
		public var _pointY:int;
		
		public function createView():void {
			view = new Sprite();
			
			btnTop = new BitmapButton();
			btnShowPass = new BitmapButton();
			iconsTop = new ImageFrames();
			iconsShowPass = new ImageFrames();
			containerShowPassLabal = new Sprite();
			tempView = new Sprite();
			
			btnTop.setStandartButtonParams();
			btnTop.setDownScale(1);
			btnTop.setDownColor(0x000000);
			btnTop.usePreventOnDown = false;
			btnTop.cancelOnVerticalMovement = true;
			btnTop.show();
			btnTop.activate();
			
			btnTop.tapCallback = onBTNTopTap;
			
			btnShowPass.setStandartButtonParams();
			btnShowPass.setDownScale(1);
			btnShowPass.setDownColor(0x000000);
			btnShowPass.tapCallback = onBTNShowPassTap;
			
			//
			labelBitmapSecureCode = new Bitmap();
			bitmapLockDesc = new Bitmap();
			//
			iconLock = new ImageFrames();
			ifShowPass = new ImageFrames();
			
			TOGGLERBG_BMD ||= UI.renderAsset(new SWFToggleBg(), Config.FINGER_SIZE * .96, Config.FINGER_SIZE * .96, true, "OptionSwitcher.TOGGLERBG_BMD");
			TOGGLER_BMD ||= UI.renderAsset(new SWFToggler(), Config.FINGER_SIZE * .36, Config.FINGER_SIZE * .36, true, "OptionSwitcher.TOGGLER_BMD");
			
			if (TOGGLERBG_BMD.isDisposed) {
				TOGGLERBG_BMD = null;
				TOGGLERBG_BMD = UI.renderAsset(new SWFToggleBg(), Config.FINGER_SIZE * .96, Config.FINGER_SIZE * .96);
			}
			if (TOGGLER_BMD.isDisposed) {
				TOGGLER_BMD = null;
				TOGGLER_BMD ||= UI.renderAsset(new SWFToggler(), Config.FINGER_SIZE * .36, Config.FINGER_SIZE * .36);
			}
			// create toggles
			if (!toggler) {
				toggler = new BitmapToggleSwitch();
				toggler.setDownScale(1);
				toggler.setDownColor(0x000000);
				toggler.setOverflow(5, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, 5);
				toggler.show(0);
				toggler.setDesignBitmapDatas(TOGGLERBG_BMD, TOGGLER_BMD, true);
				toggler.setOverflow(8, 25, 25, 8);
				toggler.show();
				toggler.deactivate();
			}
			
			iconLockOff = new Bitmap();
			iconLockOn = new Bitmap();
			showPassLabel = new Bitmap();
			
			repeatButtonSC = new BitmapButton();
			enterButtonSC = new BitmapButton();
			drawSC();
			
			addToIconLock(LockClosedGreen, LOCK_CLOSE_MATCH);
			addToIconLock(LockClosedGrey, LOCK_CLOSE);
			//addToIconLock(LockClosedWhite, ICON_LOCK_CLOSED_WHITE);
			addToIconLock(LockOpenGrey, LOCK_OPEN);
			
			enterButtonSC.setStandartButtonParams();
			enterButtonSC.tapCallback = btnLockEnterHeader;
			repeatButtonSC.setStandartButtonParams();
			repeatButtonSC.tapCallback = btnLockRepeatHeader;
			////secureCodeContainer.addEventListener(MouseEvent.MOUSE_DOWN, wrapState, false, 0, true);
			showPassLabel.bitmapData = UI.renderTextShadowed(Lang.TXT_SHOW_PASS, _width - Config.DOUBLE_MARGIN * 4, 1, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .35, false, 0xffffff, 0x000000, AppTheme.GREY_MEDIUM, true, 1, false);
			////containerShowPassLabal.addEventListener(MouseEvent.MOUSE_DOWN, onShowPass, false, 0, true);
			
			addToShowPass(CheckEmpty, LOCK_CLOSE);
			addToShowPass(CheckFill, LOCK_OPEN);
			
			view.addChild(labelBitmapSecureCode);
			view.addChild(btnTop);
			view.addChild(btnShowPass);
			view.addChild(bitmapLockDesc);
			view.addChild(repeatButtonSC);
			view.addChild(enterButtonSC);
			//view.addChild(iconsShowPass);
			//
			tempView.addChild(iconLock);
			tempView.addChild(toggler);
			tempView.addChild(iconLockOff);
			tempView.addChild(iconLockOn);
			containerShowPassLabal.addChild(showPassLabel);
			containerShowPassLabal.addChild(ifShowPass);
			tempView.addChild(containerShowPassLabal);
			
			function addToIconLock(_calss:Class, frameName:String):void {
				var iconSize:int = Config.FINGER_SIZE * 0.36;//iconLockOn.height;//
				var bm:Bitmap = new Bitmap(UI.renderAsset(new _calss as MovieClip, iconSize, iconSize, true, "ImageFrames.frame"));
				iconLock.addFrame(bm as DisplayObject, frameName);
			}
			
			function addToShowPass(_calss:Class, frameName:String):void {
				var iconSize:int = Config.FINGER_SIZE * 0.35;//iconLockOn.height;//
				var bm:Bitmap = new Bitmap(UI.renderAsset(new _calss as MovieClip, iconSize, iconSize, true, "ImageFrames.frame"));
				ifShowPass.addFrame(bm as DisplayObject, frameName);
			}
		}
		
		private function drawSC():void {
			if(labelBitmapSecureCode.bitmapData != null)
			{
				UI.disposeBMD(labelBitmapSecureCode.bitmapData);
				labelBitmapSecureCode.bitmapData = UI.renderTextShadowed(Lang.codeProtection , 300, Config.FINGER_SIZE, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .21, false, 0xffffff, 0x000000, AppTheme.GREY_MEDIUM, true, 1, false);
			}
		}
		
		public function onBTNTopTap():void {
			isON = !isON;
			enterSC = "";
			repeatSC = "";
			doCallback();
			setpositionPanel(true);
		}
		
		public function onBTNShowPassTap():void {
			isShowPass = !isShowPass;
			doCallback();
		}
		
		private function doCallback():void {
			drawView();
			if (callbackFunc != null) {
				callbackFunc();
			}
		}
		
		public function drawView(width:Number = 1):void {
			if (initalized == false && width != 1) {
				initalized = true;
				_width = width;
				
				if (iconLockOff.bitmapData != null)
				{
					iconLockOff.bitmapData.dispose();
					iconLockOff.bitmapData = null;
				}
				if (iconLockOn.bitmapData != null)
				{
					iconLockOn.bitmapData.dispose();
					iconLockOn.bitmapData = null;
				}
				
				iconLockOff.bitmapData = UI.renderSettingsText(Lang.notSet, width, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.34, false, AppTheme.GREY_DARK, 0, 0);
				iconLockOn.bitmapData = UI.renderSettingsText(Lang.textEnabled, width, Config.FINGER_SIZE * .8, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.34, false, AppTheme.GREY_DARK, 0, 0);
				
				setButtonText(true, Lang.BTN_ENTER_CODE);
				setButtonText(false, Lang.BTN_REPEAT_CODE);
				if (bitmapLockDesc.bitmapData == null) {
					bitmapLockDesc.bitmapData = UI.renderTextShadowed(Lang.TEXT_LACALISATION_DESCRIPTION_SC, _width - Config.DOUBLE_MARGIN * 2, 1, true, false, TextFieldAutoSize.LEFT, TextFieldAutoSize.CENTER, Config.FINGER_SIZE * .21, true, 0xffffff, 0x000000, AppTheme.GREY_MEDIUM, true, 1, false);
				}
				
				resizeSecureCode();
				makeBitmaps();
				destroyTemp();
			}
			if (initalized) {
				createMainView();
			}
		}
		
		public function createMainView():void {
			if (_isChanged == false) return;
			
			var bm:Bitmap;
			_isChanged = false;
			
			bm = iconsTop.getCurrentBitmap();
			if (bm != null) {
				btnTop.setBitmapData(bm.bitmapData);// ;
			}
			
			btnTop.x = labelBitmapSecureCode.x;
			btnTop.y = 0;
			//
			if (isON == false) {
				btnShowPass.hide();
				btnShowPass.deactivate();
				enterButtonSC.hide();
				enterButtonSC.deactivate();
				repeatButtonSC.hide();
				repeatButtonSC.deactivate();
				
				if (btnShowPass.parent)view.removeChild(btnShowPass);
				if (bitmapLockDesc.parent)view.removeChild(bitmapLockDesc);
				if (repeatButtonSC.parent)view.removeChild(repeatButtonSC);
				if (enterButtonSC.parent)view.removeChild(enterButtonSC);
			
			} else {
				view.addChild(btnShowPass);
				view.addChild(bitmapLockDesc);
				view.addChild(repeatButtonSC);
				view.addChild(enterButtonSC);
				btnShowPass.show();
				btnShowPass.activate();
				repeatButtonSC.show();
				enterButtonSC.show();
				repeatButtonSC.activate();
				enterButtonSC.activate();
				return;
			}
			isShowPass = isON;
			//
			btnShowPass.x = btnTop.x;
			if (btnShowPass.y == 0) {
				btnShowPass.y = enterButtonSC.y + enterButtonSC.height + Config.DOUBLE_MARGIN;
			}
		}
		
		private function resizeSecureCode():void {
			iconLock.x = 6;
			iconLock.y = labelBitmapSecureCode.y + labelBitmapSecureCode.height + Config.MARGIN;
			
			iconLockOn.x = iconLock.x + iconLock.width + Config.MARGIN/*Config.DOUBLE_MARGIN*2*/;
			iconLockOn.y = iconLock.y - (iconLockOn.height - iconLock.height) * .5;
			iconLockOff.x = iconLockOn.x;
			iconLockOff.y = iconLockOn.y;
			
			bitmapLockDesc.y = iconLockOff.y + iconLockOff.height + Config.DOUBLE_MARGIN;
			
			enterButtonSC.y = bitmapLockDesc.y + bitmapLockDesc.height + Config.MARGIN;
			repeatButtonSC.y = enterButtonSC.y;
			enterButtonSC.x = 0;
			
			if (repeatButtonSC.x == 0) {
				//repeatButtonSC.x = (enterButtonSC.x +enterButtonSC.width+ Config.DOUBLE_MARGIN/**.5*/);
				repeatButtonSC.x = (_width - Config.DOUBLE_MARGIN * 2) - (repeatButtonSC.width);
			}
			toggler.x = (_width - Config.DOUBLE_MARGIN * 2) - toggler.width;
			if (toggler.height > iconLockOff.height) {
				toggler.y = iconLockOff.y - (toggler.height - iconLockOff.height) * .5;
			} else {
				toggler.y = iconLockOff.y + (toggler.height - iconLockOff.height) * .5;
			}
			//containerShowPassLabal.y = enterButtonSC.y + enterButtonSC.height + Config.DOUBLE_MARGIN;
			
			ifShowPass.y = 0;
			ifShowPass.x = 0;
			showPassLabel.x = ifShowPass.x + ifShowPass.width + Config.MARGIN;
			showPassLabel.y = ifShowPass.y + (ifShowPass.height - showPassLabel.height) * .5;
		}
		
		private function makeBitmaps():void {
			//top
			var h:Number;
			var bmd:BitmapData;
			var bm:Bitmap;
			//
			containerShowPassLabal.visible = false;
			h = ( bitmapLockDesc.y - labelBitmapSecureCode.y);//todo
			stateView(false, true, LOCK_OPEN);
			iconsTop.addFrame(bm as DisplayObject, LOCK_OPEN);
			//
			stateView(true, false, LOCK_CLOSE);
			iconsTop.addFrame(bm as DisplayObject, LOCK_CLOSE);
			//
			stateView(true, false, LOCK_CLOSE_MATCH);
			iconsTop.addFrame(bm as DisplayObject, LOCK_CLOSE_MATCH);
			UI.disposeBMD(bmd);
			
			function stateView(isToggeler:Boolean, bool:Boolean, str:String):void {
				iconLock.toFrame(str);
				toggler.isSelected = isToggeler;
				if (iconLockOff) {
					iconLockOff.visible = bool;
				}
				if (iconLockOn) {
					iconLockOn.visible = !bool;
				}
				UI.disposeBMD(bmd);
				bmd = new BitmapData(_width, h, true, 0xffffff);
				bmd.draw(tempView);
				
				bm = new Bitmap(bmd);
			}
			//
			h = containerShowPassLabal.height;//todo
			containerShowPassLabal.visible = true;
			addToShowPass(containerShowPassLabal,LOCK_OPEN);
			addToShowPass(containerShowPassLabal,LOCK_CLOSE);
			
			function addToShowPass(dObj:DisplayObject, state:String):void {
				ifShowPass.toFrame(state);
				var bm:Bitmap;
				var result:ImageBitmapData = UI.getSnapshot(dObj, StageQuality.HIGH, "ImageFrames.frame");
				bm = new Bitmap(result);
				iconsShowPass.addFrame(bm as DisplayObject, state);
				UI.destroy(bm);
			}
		}
		
		private function destroyTemp():void {
			UI.destroy(iconLockOff);
			UI.destroy(iconLockOn);
			UI.destroy(containerShowPassLabal);
			UI.destroy(tempView);
			UI.destroy(iconLockOn);
			UI.destroy(iconLockOff);
			UI.destroy(showPassLabel);
			
			containerShowPassLabal = null;
			iconLock.dispose();
			ifShowPass.dispose();
			toggler.dispose();
			
			iconLock = null;
			ifShowPass = null;
			toggler = null;
			iconLockOff = null;
			iconLockOn = null;
			showPassLabel = null;
		}
		
		private function callBackShowEnderCode(i:int, value:String):void {
			switch (i) {
				case 1: {//btnOK
					enterSC = value;
					if (repeatSC == "" && repeatSC != enterSC) {
						TweenMax.delayedCall(1, btnLockRepeatHeader);
					}
					break;
				}
				case 2: {//btnSecond->cansel
					
					break;
				}
				case 0: {//btnClose ""
					
					break;
				}
			}
			isShowedPopUp = true;
			setpositionPanel();
		}
		
		private function setpositionPanel(isFastSwitch:Boolean = false):void {
			if(isFastSwitch){
				doFunc();
			}else{
				TweenMax.killDelayedCallsTo(doFunc);
				TweenMax.delayedCall(.2,doFunc);
			}
		}
		
		private function doFunc():void {
			if(_scrollPanel){
				//_scrollPanel.setPositionY(view.y+view.height);
				if(isShowedPopUp){
					isShowedPopUp = false;
					_scrollPanel.scrollToPosition(_pointY)
				}
			}
		}
		
		private function callBackShowRepeatCode(i:int, value:String):void {
			switch (i) {
				case 1: {//btnOK
					repeatSC = value;
					
					break;
				}
				case 2: {//btnSecond->cansel
					
					break;
				}
				case 0: {//btnClose ""
					
					break;
				}
			}
			isShowedPopUp = true;
			setpositionPanel();
		}
		
		private function setButtonText(isEnterField:Boolean, txt:String):void {
			var bm:BitmapData;
			var btnSC:BitmapButton;
			var w:Number = 1;
			var ispass:Boolean;
			if (isEnterField) {//enter
				btnSC = enterButtonSC;
				ispass = !isShowPass && enterSC != "";
				if (enterSC != "") {
					txt = enterSC;
					if (ispass && txt.length > 9) {
						txt = txt.substr(0, 8);
					}
				}
			} else {//repeat
				btnSC = repeatButtonSC;
				ispass = !isShowPass && repeatSC != "";
				if (repeatSC != "") {
					txt = repeatSC;
					if (ispass && txt.length > 9) {
						txt = txt.substr(0, 8);
					}
				}
			}
			
			w = (_width - Config.DOUBLE_MARGIN * 3) * .5;
			bm = UI.renderTextShadowedUnderline(txt, w/*_width-Config.DOUBLE_MARGIN*4*/, 1, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .35, false, 0xffffff, 0x000000, AppTheme.GREY_DARK, true, 1, false, AppTheme.GREY_MEDIUM, 1, ispass);
			btnSC.setBitmapData(bm, true);
		}
		
		public function set isShowPass(value:Boolean):void {
			var bm:Bitmap;
			_isChanged = true;
			_isShowPass = value;
			if(isShowPass){
				iconsShowPass.toFrame(LOCK_OPEN)
			}else{
				iconsShowPass.toFrame(LOCK_CLOSE);
			}
			bm = iconsShowPass.getCurrentBitmap();
			if (bm != null) {
				btnShowPass.setBitmapData(bm.bitmapData);
			}
			if (_enterSC == "") {
				setButtonText(true, Lang.BTN_ENTER_CODE);
			} else {
				if (_isShowPass) {
					setButtonText(true, _enterSC);
				} else {
					setButtonText(true, TXT_5_STARS);
				}
			}
			
			if (_repeatSC == "") {
				setButtonText(false, Lang.BTN_REPEAT_CODE);
			} else {
				if (_isShowPass) {
					setButtonText(false, _repeatSC);
				} else {
					setButtonText(false, TXT_5_STARS);
				}
			}
		}
		
		private function btnLockEnterHeader():void {
			if (_scrollPanel != null)
			{
				_pointY = _scrollPanel.getPositionY();
			}
			
			isShowedPopUp = true;
			DialogManager.showSecureCode(callBackShowEnderCode, true, isShowPass, _enterSC);
		}
		
		private function btnLockRepeatHeader():void {
			if (_scrollPanel != null)
			{
				_pointY = _scrollPanel.getPositionY();
			}
			
			isShowedPopUp = true;
			DialogManager.showSecureCode(callBackShowRepeatCode, false, isShowPass, _repeatSC);
		}
		
		public function get enterSC():String {
			return _enterSC;
		}
		
		public function get repeatSC():String {
			return _repeatSC;
		}
		
		public function set enterSC(value:String):void {
			_enterSC = value;
			if (_enterSC == "") {
				setButtonText(true, Lang.BTN_ENTER_CODE);
			} else {
				if (_isShowPass) {
					setButtonText(true, _enterSC);
				} else {
					setButtonText(true, TXT_5_STARS);
				}
				
				iconsTop.toFrame((enterSC == repeatSC)?LOCK_CLOSE_MATCH:LOCK_CLOSE);
				_isChanged = true;
			}
			// switchlockState(_currStateLock);
			doCallback();
		}
		
		public function set repeatSC(value:String):void {
			_repeatSC = value;
			if (_repeatSC == "") {
				setButtonText(false, Lang.BTN_REPEAT_CODE);
			} else {
				if (_isShowPass) {
					setButtonText(false, _repeatSC);
				} else {
					setButtonText(false, TXT_5_STARS);
				}
					iconsTop.toFrame((enterSC == repeatSC)?LOCK_CLOSE_MATCH:LOCK_CLOSE);
					_isChanged = true;
			}
			doCallback();
		}
		
		public function get isShowPass():Boolean {
			return _isShowPass;
		}
		
		public function compareEnterAndRepeatSC():String {
			var isLockBnt:Boolean;
			var txtAlert:String = "";
			
			if (isON == false) {
				return txtAlert;
			}
			
			if (enterSC != "" && repeatSC != "") {
				//match
				isLockBnt = (enterSC == repeatSC) ? true : false;
				if (isLockBnt == false) {
					txtAlert = Lang.ALERT_DONT_MATCH_SC;
				}
			} else if (enterSC == "" && repeatSC != "") {
				txtAlert = Lang.ALERT_ENTER_SC;
			} else if (enterSC != "" && repeatSC == "") {
				txtAlert = Lang.ALERT_REPEAT_SC;
			} else {
				txtAlert = Lang.ALERT_ENTER_REPEAT_SC;
			}
			//TODO
			
			if (isLockBnt) {
				//btnSend.activate;
				_code = enterSC;
			} else {
				DialogManager.alert(Lang.textAlert, txtAlert);
				_code = "";
				//btnSend.deactivate;
			}
			if (isLockBnt == false) {
				DialogManager.alert(Lang.textAlert, txtAlert);
			}
			return /* isLockBnt*/txtAlert;
		}
		private var _scrollPanel:ScrollPanel;
		public function initView(isT:Boolean,scrollPanel:ScrollPanel):void {
			isON = isT;
			_scrollPanel = scrollPanel;
			drawView()
		}
		
		public function getRectangel():Rectangle {
			return new Rectangle(view.x, view.y, view.width, view.height);
		}
		
		public function activate():void {
			if (view != null && view.alpha == 0)
			{
				return;
			}
			btnTop.activate();
			btnShowPass.activate();
		}
		
		public function deactivate():void {
			btnTop.deactivate();
			btnShowPass.deactivate();
			TweenMax.killDelayedCallsTo(btnLockRepeatHeader);
		}
		
		public function dispose():void {
			_isON = false;
			initalized = false;
			if (btnTop) {
				btnTop.dispose();
			}
			if (btnShowPass) {
				btnShowPass.dispose();
			}
			if (iconsTop){
				iconsTop.dispose();
			}
			if (view) {
				view.removeChildren();
				view = null;
			}
			if (repeatButtonSC) {
				repeatButtonSC.dispose();
			}
			if (enterButtonSC) {
				enterButtonSC.dispose();
			}
			if (iconsShowPass) {
				iconsShowPass.dispose();
			}
			UI.destroy(labelBitmapSecureCode);
			UI.destroy(bitmapLockDesc);
			btnTop = null;
			btnShowPass = null;
			iconsTop = null;
			iconsShowPass = null;
			bitmapLockDesc = null;
			
			labelBitmapSecureCode = null;
			bitmapLockDesc = null;
			_scrollPanel = null;
		}
		
		public function get isON():Boolean {
			return _isON;
		}
		
		public function set isON(value:Boolean):void {
			_isChanged = true;
			if (iconsTop == null)
			{
				return;
			}
			_isON = value;
			if (isON) {
				iconsTop.toFrame(LOCK_CLOSE);
			} else {
				iconsTop.toFrame(LOCK_OPEN);
				isShowPass = false;
			}
		}
		
		public function get code():String {
			return _code;
		}
		
		public function drawViewLang():void {
			dispose();
			createView();
		}
	}
}
