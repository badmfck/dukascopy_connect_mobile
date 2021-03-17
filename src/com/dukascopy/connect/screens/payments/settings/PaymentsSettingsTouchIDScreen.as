package com.dukascopy.connect.screens.payments.settings {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PaymentsSettingsTouchIDScreen extends BaseScreen {
		
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		private const BTN_ICON_SIZE:int = Config.FINGER_SIZE * 0.36;
		
		private var bg:Shape;
		private var topBar:TopBarScreen;
		private var switcherTouchID:OptionSwitcher;
		
		private var tempPass:String = "";
		
		public function PaymentsSettingsTouchIDScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			PaymentsManager.activate();
			
			if (Config.PLATFORM_APPLE)
			{
				topBar.setData((Config.APPLE_BOTTOM_OFFSET > 0) ? Lang.TEXT_FACE_ID : Lang.TEXT_TOUCH_ID, true);
			}
			else if (Config.PLATFORM_ANDROID)
			{
				topBar.setData(Lang.TEXT_FINGERPRINT);
			}
			
			var IconClass:Class;
			if (Config.APPLE_BOTTOM_OFFSET > 0)
			{
				IconClass = Style.icon(Style.ICON_FACE_ID);
			}
			else
			{
				IconClass = Style.icon(Style.ICON_TOUCH_ID);
			}
			
			var iconLIBMD:ImageBitmapData = UI.renderAsset(
				UI.colorize(new IconClass(), Style.color(Style.ICON_COLOR)),
				BTN_ICON_SIZE,
				BTN_ICON_SIZE,
				true,
				"PaymentsSettingsTouchIDScreen.iconSign"
			);
			
			var controlText:String;
			if (Config.APPLE_BOTTOM_OFFSET > 0)
			{
				controlText = Lang.TEXT_FACE_ID;
			}
			else
			{
				controlText = Lang.TEXT_TOUCH_ID;
			}
			if (Config.PLATFORM_ANDROID)
			{
				controlText = Lang.useFingerprint;
			}
			
			switcherTouchID.create(_width - Config.DOUBLE_MARGIN*2, OPTION_LINE_HEIGHT, iconLIBMD, 
									controlText, 
									false, true, Style.color(Style.COLOR_TEXT));
			switcherTouchID.onSwitchCallback = changeTouchIDState;
			
			if (Config.PLATFORM_APPLE)
			{
				if (MobileGui.touchIDManager != null && MobileGui.touchIDManager.isTouchIDAvailable == true)
				{
					switcherTouchID.isSelected = MobileGui.touchIDManager.useTouchID;
				}
			}
			else if (Config.PLATFORM_ANDROID)
			{
				Store.load(Store.USE_FINGERPRINT, 
					function(data:Boolean, error:Boolean):void
					{		
						if (data == true)
						{
							switcherTouchID.isSelected = true;
						}
						else
						{
							switcherTouchID.isSelected = false;
						}
						trace("fingerprint status", data, error, switcherTouchID.isSelected);
					});
			}
		}
		
		override protected function createView():void {
			super.createView();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, 10, 10);
			_view.addChild(bg);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			switcherTouchID = new OptionSwitcher();
			switcherTouchID.x = Config.DOUBLE_MARGIN;
			_view.addChild(switcherTouchID);
		} 
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			if (topBar != null)
				topBar.activate();
			if (switcherTouchID != null)
				switcherTouchID.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (topBar != null)
				topBar.deactivate();
			if (switcherTouchID != null)
				switcherTouchID.deactivate();
		}
		
		override protected function drawView():void {
			bg.width = _width;
			bg.height = _height;
			
			topBar.drawView(_width);
			
			switcherTouchID.y = topBar.trueHeight + Config.MARGIN;
		}
		
		private function changeTouchIDState(val:Boolean):void {
			if (Config.PLATFORM_APPLE)
			{
				if (val == true) {
					switcherTouchID.isSelected = false;
					var value:String = "";
					if (MobileGui.touchIDManager)
						value = MobileGui.touchIDManager.secret;
					if (value == "") {
						if (MobileGui.touchIDManager)
							MobileGui.touchIDManager.waite_on_switcher = true;
						TweenMax.delayedCall(.3, function ():void { DialogManager.showPayPass(callBackShowPayPass) } );
					} else {
						TweenMax.delayedCall(.3, function ():void { DialogManager.showPayPassTouchID(callBackSavePass) } );
					}
				} else {
					if (MobileGui.touchIDManager != null) {
						MobileGui.touchIDManager.waite_on_switcher = false;
						MobileGui.touchIDManager.switchOnOff(false);
						MobileGui.touchIDManager.clear(false);
					}
				}
			}
			else if (Config.PLATFORM_ANDROID)
			{
				trace("fingerprint select", val);
				Store.save(Store.USE_FINGERPRINT, val);
				if (val == false)
				{
					NativeExtensionController.clearFingerprint();
				}
				else
				{
					if (MobileGui.androidExtension.fingerprint_pinExist() == false && MobileGui.androidExtension.fingerprint_avaliable() == true)
					{
						Store.save(Store.DONT_ASK_FINGERPRINT, false);
					}
				}
			}
		}
		
		private function callBackShowPayPass(val:int, pass:String):void {
			if (val == 1) {
				PayManager.S_PASS_AUTHORIZE_SUCESS.add(onPasswordAuthorizeSucess);
				PayManager.S_PASS_RESPONDED.add(onPasswordCheckRespond);
				PayManager.callPass(pass);
			}
		}
		
		private function onPasswordAuthorizeSucess():void {
			PayManager.S_PASS_AUTHORIZE_SUCESS.remove(onPasswordAuthorizeSucess);
			if (MobileGui.touchIDManager != null)
			{
				MobileGui.touchIDManager.switchOnOff(true);
			}
			else if (Config.PLATFORM_ANDROID)
			{
				Store.save(Store.USE_FINGERPRINT, true);
			}
			switcherTouchID.isSelected = true;
		}
		
		private function onPasswordCheckRespond(respond:PayRespond):void {
			PayManager.S_PASS_RESPONDED.remove(onPasswordAuthorizeSucess);
			if (respond.errorCode == PayRespond.ERROR_PASSWORD_INVALID)
				TweenMax.delayedCall(.3, showAlertPass);
		}
		
		private function showAlertPass():void{
			DialogManager.alert(Lang.TEXT_PASS_INVALID, Lang.wouldYouTryAgain, function (val:int):void {
				if (val == 1) {
					if (MobileGui.touchIDManager) {
						var value:String = MobileGui.touchIDManager.secret;
						if (value == "" && tempPass!= "") {
							callBackShowPayPass(1, tempPass);
							tempPass = "";
						} else {
							TweenMax.delayedCall(.3, function ():void { DialogManager.showPayPassTouchID(callBackSavePass) } );
						}
					}
				}
			}, Lang.btnTryAgain, Lang.textCancel.toUpperCase(), null, TextFormatAlign.CENTER, true);
		}
		
		private function callBackSavePass(val:int, pass:String):void {
			if (val != 1)
				return;
			if (MobileGui.touchIDManager != null) {
				var value:String = MobileGui.touchIDManager.secret;
				if (value == pass) {
					MobileGui.touchIDManager.saveTouchID(pass,false);
					MobileGui.touchIDManager.switchOnOff(true);
					TweenMax.delayedCall(.3, function ():void {
						if (switcherTouchID != null)
							switcherTouchID.isSelected = true;
					});
					ToastMessage.display(Lang.textSuccess);
				} else if (value == "") {
					tempPass = pass;
					TweenMax.delayedCall(.3, showAlertPass);
				} else {
					tempPass = pass;
					callBackShowPayPass(1, tempPass);
					tempPass = "";
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			PaymentsManager.deactivate();
			PayManager.S_PASS_AUTHORIZE_SUCESS.remove(onPasswordAuthorizeSucess);
			PayManager.S_PASS_RESPONDED.remove(onPasswordAuthorizeSucess);
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (bg != null)
				bg.graphics.clear();
			bg = null;
		}
	}
}