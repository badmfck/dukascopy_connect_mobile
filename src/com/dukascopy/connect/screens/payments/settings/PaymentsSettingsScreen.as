package com.dukascopy.connect.screens.payments.settings {
	
	import assets.IconArrowRight;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.groupList.GroupButtons;
	import com.dukascopy.connect.gui.components.groupList.item.ItemGroupList;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.WebViewScreen;
	import com.dukascopy.connect.screens.payments.data.PaymentsScreenData;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import white.Configure;
	import white.Info;
	import white.Lock;
	import white.Logout;
	import white.OneClick;
	import white.Right;
	import white.Text;
	import white.User;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PaymentsSettingsScreen extends BaseScreen {
		
		private var bg:Shape;
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
			private var gbMyAccount:GroupButtons;
			private var gbSecurity:GroupButtons;
			private var optSwitcherTouch:OptionSwitcher;
			private var gbAboutUs:GroupButtons;
		private var logoutIcon:DisplayObject;
		private var logout:GroupButtons;
		
		public function PaymentsSettingsScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			bg = new Shape();
			view.addChild(bg);
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			scrollPanel = new ScrollPanel();
			scrollPanel.background = false;
			_view.addChild(scrollPanel.view);
			createComponents();
		}
		
		private function createComponents():void {
			createItems();
		}
		
		private function createItems():void {
			if (gbMyAccount != null) {
				scrollPanel.removeObject(gbMyAccount);
				gbMyAccount.dispose();
			}
			gbMyAccount = new GroupButtons(false);
			gbMyAccount.add("personalDetails", openPersonalData, User, Right);
			gbMyAccount.add("verificationLimits", openLimits, Configure, Right);
			gbMyAccount.create();
			scrollPanel.addObject(gbMyAccount);
			if (gbSecurity != null) {
				scrollPanel.removeObject(gbSecurity);
				gbSecurity.dispose();
			}
			gbSecurity = new GroupButtons();
			gbSecurity.add("changePassword", openChangePass, Lock, Right);
			gbSecurity.add("oneClickPayments", openOneClick, OneClick, Right);
			if (MobileGui.touchIDManager != null && MobileGui.touchIDManager.isTouchIDAvailable == true)
			{
				if (Config.APPLE_BOTTOM_OFFSET > 0)
				{
					gbSecurity.add("signWithFaceID", openTouchID, Style.icon(Style.ICON_FACE_ID), Right);
				}
				else
				{
					gbSecurity.add("signWithTouchID", openTouchID, Style.icon(Style.ICON_TOUCH_ID), Right);
				}
			}
			else if (Config.PLATFORM_ANDROID && MobileGui.androidExtension.fingerprint_avaliable() == true)
			{
				// ANDROID
				gbSecurity.add("fingerprintLogin", openTouchID, Style.icon(Style.ICON_TOUCH_ID), Right);
			}
			gbSecurity.create();
			scrollPanel.addObject(gbSecurity);
			if (gbAboutUs != null) {
				scrollPanel.removeObject(gbAboutUs);
				gbAboutUs.dispose();
			}
			gbAboutUs = new GroupButtons();
			gbAboutUs.add("textFaq", openFAQ, Info, IconArrowRight);
			gbAboutUs.add("termsAndConditions", openTermsAndConditions, Text, Right);
			gbAboutUs.create();
			scrollPanel.addObject(gbAboutUs);
			
			if (logout != null) {
				scrollPanel.removeObject(logout);
				logout.dispose();
			}
			logout = new GroupButtons();
			logout.add("logout", onLogoutPressed, Logout);
			logout.create();
			scrollPanel.addObject(logout);	
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(Lang.textSettings, true);
		}
		
		override public function setInitialSize(width:int, height:int):void {
			super.setInitialSize(width, height);
		}
		
		override public function setWidthAndHeight(width:int, height:int):void {
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, _width, _height);
			bg.graphics.endFill();
			super.setWidthAndHeight(width, height);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			topBar.drawView(_width);
			gbMyAccount.setWidth(_width);
			gbSecurity.setWidth(_width);
			gbSecurity.y = gbMyAccount.y + gbMyAccount.height;
			gbAboutUs.setWidth(_width);
			gbAboutUs.y = gbSecurity.y + gbSecurity.height;
			logout.setWidth(_width);
			logout.y = gbAboutUs.y + gbAboutUs.height;
			scrollPanel.view.y = Config.APPLE_TOP_OFFSET + Config.TOP_BAR_HEIGHT;
			scrollPanel.setWidthAndHeight(_width, _height - (scrollPanel.view.y), true);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			if (topBar != null)
				topBar.activate();
			if (gbMyAccount != null)
				gbMyAccount.activateScreen();
			if (gbSecurity != null)
				gbSecurity.activateScreen();
			if (gbAboutUs != null)
				gbAboutUs.activateScreen();
			if (logout != null)
				logout.activateScreen();
			if (scrollPanel != null)
				scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			if (topBar != null)
				topBar.deactivate();
			if (gbMyAccount != null)
				gbMyAccount.deactivateScreen();
			if (gbSecurity != null)
				gbSecurity.deactivateScreen();
			if (gbAboutUs != null)
				gbAboutUs.deactivateScreen();
			if (logout != null)
				logout.deactivateScreen();
			if (scrollPanel != null)
				scrollPanel.disable();
		}
		
		private function openFAQ():void {
			MobileGui.changeMainScreen(
				WebViewScreen,
				{
					title:Lang.textFaq,
					backScreen:MobileGui.centerScreen.currentScreenClass,
					link:PayConfig.FAQ_URL + "?lang=" + LangManager.model.getCurrentLanguageID(),
					backScreenData:data
				}
			);
		}		
		
		private function openTermsAndConditions():void {
			MobileGui.changeMainScreen(
				WebViewScreen,
				{
					title:Lang.termsAndConditions,
					backScreen:MobileGui.centerScreen.currentScreenClass,
					link:PayConfig.TERMS_URL + "?lang=" + LangManager.model.getCurrentLanguageID(),
					backScreenData:data
				}
			);
		}
		
		private function openPersonalData():void {
			openScreen(PaymentsSettingsPersonalDetailsScreen);
		}
		
		private function openLimits():void {
			openScreen(PaymentsSettingsVerificationLimitsScreen);
		}
		
		private function openChangePass():void {
			DialogManager.showChangePayPass(onPassChangeComplete);
		}
		
		private function onPassChangeComplete(value:int, currentPass:String = "", newPass:String = ""):void {
			if (value == 1) {
				PayManager.callChangePassword(currentPass, newPass);
				return;
			}
		}
		
		private function openOneClick():void {
			openScreen(PaymentsSettingsOneClickScreen);
		}
		
		private function openTouchID():void {
			openScreen(PaymentsSettingsTouchIDScreen);
			/*if (vo.switchSelected == true) {
				if (touchIDswitch != null)
					touchIDswitch.isSelected = false;
				var value:String = "";
				if (MobileGui.touchIDManager) {
					value = MobileGui.touchIDManager.secret;
				}
				if (value == "" ) {
					if (MobileGui.touchIDManager) {
						MobileGui.touchIDManager.waite_on_switcher = true;
					}
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
			}*/
		}
		
		private function openScreen(screenClass:Class):void {
			var backScreenData:PaymentsScreenData =	new PaymentsScreenData();
			backScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			backScreenData.backScreenData = data;
			MobileGui.changeMainScreen(
				screenClass,
				backScreenData,
				ScreenManager.DIRECTION_RIGHT_LEFT
			);
		}
		
		private function onLogoutPressed():void {
			DialogManager.alert(Lang.textWarning, Lang.areYouSureLogout, onLogoutDialogClose, Lang.logout, Lang.textCancel);
		}
		
		private function onLogoutDialogClose(val:int):void {
			if (val != 1)
				return;
			PayManager.callLogout();
			PayManager.reset();
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override public function drawViewLang():void {
			if (_isDisposed == true)
				return;
			if (topBar != null)
				topBar.updateTitle(Lang.textSettings);
			if (gbMyAccount != null)
				gbMyAccount.drawView();
			if (gbSecurity != null)
				gbSecurity.drawView();
			if (gbAboutUs != null)
				gbAboutUs.drawView();
			if (logout != null)
				logout.drawView();;
			super.drawViewLang();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			UI.destroy(bg);
			bg = null
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (gbMyAccount != null)
				gbMyAccount.dispose();
			gbMyAccount = null;
			if (gbSecurity != null)
				gbSecurity.dispose();
			gbSecurity = null;
			if (gbAboutUs != null)
				gbAboutUs.dispose();
			gbAboutUs = null;
			if (logout != null)
				logout.dispose();
			logout = null;
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			UI.destroy(logoutIcon);
			logoutIcon = null;
			super.dispose();
		}
	}
}