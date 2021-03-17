package com.dukascopy.connect.screens.payments.settings {

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.groupList.GroupListComponent;
	import com.dukascopy.connect.gui.components.groupList.item.ItemGroupList;
	import com.dukascopy.connect.gui.components.groupList.item.vo.VOItemGL;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormatAlign;
	import white.OneClick;
	
	public class PaymentsSettingsOneClickScreen extends PaymentsBaseScreen {
		
		private var _groupListComponent:GroupListComponent;
		private var _limitSetting:LimitWithoutSetting;
		private var preloader:CirclePreloader;
		private var syncButton:BitmapButton;
		
		private var busyIndicator:Bitmap = new Bitmap(new BitmapData(15, 15, false, 0xff0000));
		
		private static var ID_oneClickPayments:String = "oneClickPayments";
		
		public function PaymentsSettingsOneClickScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
		}
		
		override public function initScreen(data:Object = null):void {
			resetTitleText();
			updateLimitsState();
			showPreloader();
			PaymentsManager.S_ACCOUNT.add(onAccountInfoReady);
			PaymentsManager.S_BACK.add(onBack);
			PaymentsManager.S_ERROR.add(onPaymentsError);
			if (PaymentsManager.activate() == false && PayManager.accountInfo != null)
				onAccountInfoReady();
			PayManager.S_ACCOUNT_SETTINGS_POST.add(onAccountSettingsChange);
			PayManager.S_ACCOUNT_SETTINGS_CHANGE_RESPOND.add(onAccountSettingsChangeRespond);
			super.initScreen(data);
			
			createComponenets();
		}
		
		private function onAccountInfoReady():void {
			createComponenets();
			resetTitleText();
			updateLimitsState();
			drawView();
			hidePreloader();
			if (isActivated == true)
			{
				_limitSetting.activateScreen();
				_groupListComponent.activateScreen();
			}
		}
		
		private function updateLimitsState():void {
			if (PayManager.accountInfo == null)
				return;
			var whatNext:Boolean = (PayManager.accountInfo.settings != null && PayManager.accountInfo.settings.PWP_ENABLED == true);
			if (_groupListComponent != null)
				_groupListComponent.changeState(ItemGroupList.TYPE_SWITCH, ID_oneClickPayments, whatNext);
			if (whatNext == true)
				showLimitSetting();
			else
				hideLimitSetting();
		}
		
		private function onBtnSync(e:Event = null):void {
			if (!PayManager.isInitialized)
				return;
			showPreloader();
			syncButton.deactivate();
			syncButton.hide(.2);
			syncButton.visible  = false;
			if (PayManager.systemOptions == null)
				PayManager.callGetSystemOptions();
			PayManager.callGetAccountInfo();
		}
		
		private function createComponenets():void{
			_view.addChild(busyIndicator);
			busyIndicator.alpha = 0;
			busyIndicator.visible = false;
			busyIndicator.y = 100;
			var SYNC_BMD:BitmapData = UI.renderAsset(UI.colorize(new SWFPaymentsRefreshIcon(),AppTheme.RED_MEDIUM), Config.FINGER_SIZE, Config.FINGER_SIZE, true, "PaymentsScreen.SYNC_BMD");
			syncButton ||= new BitmapButton();
			syncButton.setStandartButtonParams();
			syncButton.setBitmapData(SYNC_BMD, false);
			syncButton.setOverflow(Config.FINGER_SIZE_DOT_35, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE*.2);
			syncButton.x = _width * .5 - SYNC_BMD.width * .5;
			syncButton.y = _height * .5 - SYNC_BMD.height * .5;
			view.addChild(syncButton);
			syncButton.hide();
			syncButton.tapCallback = onBtnSync;
			if (PayManager.accountInfo == null)
				return;
			if (PayManager.systemOptions == null)
				return;
			if (_groupListComponent == null){
				_groupListComponent = new GroupListComponent();
				var vectTemp:Vector.<ItemGroupList>;
				vectTemp = new <ItemGroupList>[];
				vectTemp.push(new ItemGroupList(new OneClick(), Lang.oneClickPayments, ID_oneClickPayments, callbackItemGroupList, ItemGroupList.TYPE_SWITCH));
				_groupListComponent.add("", vectTemp);
				_groupListComponent.setWidthAndHeight(_width, _height);
				scrollPanel.addObject(_groupListComponent);
			}
			_limitSetting ||= new LimitWithoutSetting();
			_limitSetting.setWidthAndHeight(_width - Config.DOUBLE_MARGIN * 2);
			_limitSetting.x = Config.DOUBLE_MARGIN;
		}
		
		override protected function addScrollPanel():void {
			super.addScrollPanel();
			_view.addChild(scrollPanel.view);
		}
		
		private var id:String;
		private var locked:Boolean;
		
		private function callbackItemGroupList(vo:VOItemGL):void {
			if (vo == null)
				return;
			switch(vo.id) {
				case ID_oneClickPayments: {
					var isON:Boolean;
					isON = vo.switchSelected;
					if (isON){
						var termsBodyText:String = Lang.oneClickPaymentsDescSWISS;	
						DialogManager.alert(Lang.oneClickPayments  + " " + Lang.termsAndConditions, termsBodyText , callbackOneClick, Lang.iAgree, Lang.textCancel);
					}else{
						_groupListComponent.changeState(ItemGroupList.TYPE_SWITCH, ID_oneClickPayments, false);
						hideLimitSetting();
						callPostAccountSettings(0);
						return;
					}
					break;
				}
			}
			_groupListComponent.changeState(ItemGroupList.TYPE_SWITCH, ID_oneClickPayments, true);
		}
		
		private function callPostAccountSettings(enabled:int = -1, amount:int = -1, daily:int = -1):void {
			lock();
			id = new Date().getTime().toString();
			showBusyIndicator(); 
			PayManager.callPostAccountSettings(id, enabled,amount,daily);
		}
		
		private function showBusyIndicator():void {
			busyIndicator.visible  = true;
		}
		
		private function hideBusyIndicator():void {
			busyIndicator.visible  = false;
		}
		
		private function hideLimitSetting():void {
			if(scrollPanel && _limitSetting) {
				_limitSetting.hide();
				scrollPanel.removeObject(_limitSetting);
			}
		}
		
		private function showLimitSetting():void {
			if(scrollPanel && _limitSetting){
				scrollPanel.addObject(_limitSetting);
				_limitSetting.show();
			}
		}
		
		private function callbackOneClick(i:int):void {
			if (i == 1) {
				_groupListComponent.changeState(ItemGroupList.TYPE_SWITCH, ID_oneClickPayments, true);
				showLimitSetting();
				callPostAccountSettings(1);
			} else {
				_groupListComponent.changeState(ItemGroupList.TYPE_SWITCH, ID_oneClickPayments, false);
				hideLimitSetting();
				callPostAccountSettings(0);
			}
		}
		
		private function createIconByMCandName(mc:Sprite, nameIcon:String, isBlock = false, color:uint = 0xFFFFFF):BitmapData {
			var topBarBtnSize:Number = Config.FINGER_SIZE * .4;
			if (isBlock) {
				var myColorTransform:ColorTransform = new ColorTransform();
				myColorTransform.color = color;
				mc.transform.colorTransform = myColorTransform;
			}
			return UI.renderAsset(mc, topBarBtnSize, topBarBtnSize, true, nameIcon);
		}
		
		override public function setWidthAndHeight(_width:int, height:int):void {			
			if(_groupListComponent != null)
				_groupListComponent.setWidthAndHeight(_width, height);
			if (_limitSetting != null)
				_limitSetting.setWidthAndHeight(_width - Config.DOUBLE_MARGIN * 2);
			super.setWidthAndHeight(_width,height);
		}
		
		override protected function drawView():void {
			var posY:Number = 0;
			if (_groupListComponent != null) {				
				posY =  drawViewItem(_groupListComponent, posY);
				_groupListComponent.drawView();
			}
			if (_limitSetting != null) {
				_limitSetting.drawView();
				_limitSetting.y = _groupListComponent.y + _groupListComponent.height;
			}
			if (syncButton != null) {
				syncButton.x = _width * .5 - syncButton.width * .5;
				syncButton.y = _height * .5 - syncButton.height * .5;
			}
			super.drawView();
		}
		
		private function drawViewItem(item:GroupListComponent,lastPos:int):Number {
			item.drawView();
			item.x = 0;
			item.y = lastPos;
			return item.y + item.height + Config.DOUBLE_MARGIN;
		}
		
		override public function drawViewLang():void {
			resetTitleText();
			super.drawViewLang();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			if (locked == true)
			{
				return;
			}
			if(_groupListComponent != null)				
				_groupListComponent.activateScreen();
			if (_limitSetting != null)
				_limitSetting.activateScreen();
			updateLimitsState();
		}
		
		private function onAccountSettingsChange(data:*):void{
			if (data is Boolean == false) {
				if (data != null) {
					if (PayManager.accountInfo != null)
						PayManager.accountInfo.updateSettings(data);
				}
			}
			hideBusyIndicator();
			updateLimitsState();
		}
		
		private function onAccountSettingsChangeRespond(respond:PayRespond):void {
			if (isDisposed == true)
			{
				return;
			}
			unlock();
			if (respond.error == true && respond.errorMsg != null)
			{
				ToastMessage.display(respond.errorMsg);
			}
			
			if (_limitSetting != null)
				_limitSetting.onServerRespond(respond.savedRequestData.callID, respond.error);
		}
		
		private function lock():void 
		{
			showPreloader();
			locked = true;
			
			if (_limitSetting != null)
			{
				_limitSetting.deactivateScreen();
			}
			if (_groupListComponent != null)
			{
				_groupListComponent.deactivateScreen();
			}
		}
		
		private function unlock():void 
		{
			hidePreloader();
			locked = false;
			if (isActivated == true)
			{
				if (_limitSetting != null)
				{
					_limitSetting.activateScreen();
				}
				if (_groupListComponent != null)
				{
					_groupListComponent.activateScreen();
				}
			}
		}
		
		private function callbackTouchID(val:int, secret:String = ""):void {
			if (val == 0)
				DialogManager.showPayPass(callBackShowPayPass);
			else
				callBackShowPayPass(val, secret);
			
			if (MobileGui.touchIDManager != null)
			{
				MobileGui.touchIDManager.callbackFunction = null;
			}
		}
		
		private function callBackShowPayPass(val:int, pass:String):void {
			if (_isDisposed == true)
				return;
			switch (val) {
				case 1:
				{
					PayManager.callPass(pass);
					break;
				}
				case 3:
				{
					TweenMax.delayedCall(.7, function ():void {
						echo("PaymentsSettingsOneClickScreen", "onNeedPassword", "TweenMax.delayedCall");
						if (!PayManager.isInsidePaymentsScreenNow)
							return;
						var bodyText:String = Lang.ALERT_FORGOT_PASSWORD_SWISS;
						var phone:String = Lang.BANK_PHONE_SWISS;
						DialogManager.alert(Lang.forgotPassword, Lang.ALERT_FORGOT_PASSWORD, function (val:int):void {
							if (val == 1) {
								navigateToURL(new URLRequest("tel:"+phone));
							}
						}, Lang.textCall, Lang.textClose.toUpperCase(), null, TextFormatAlign.CENTER, true);
					});
					break;
				}
				case 0:
				case 2:
				{
					PayManager.onDismissPasswordEnter(PayManager.respondThatTriggeredAuthorization);
					break;
				}
			}
		}
		
		private function onCancelWrongPass(...rest):void {
			hidePreloader();
			if (PayManager.accountInfo == null)	{
				syncButton.show(.3);
				syncButton.activate();
				syncButton.visible  = true;
				return;
			}
			syncButton.deactivate();
			syncButton.hide(.2);
			syncButton.visible = false;
		}
		
		private function showPreloader():void {
			if (preloader == null)
				preloader = new CirclePreloader();
			preloader.x = int(_width * .5);
			preloader.y = int(_height * .5);
			_view.addChild(preloader);
		}
		
		private function hidePreloader(r:PayRespond = null):void {
			if (preloader != null) {
				if (preloader.parent != null)
					_view.removeChild(preloader);
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (_groupListComponent != null)
				_groupListComponent.deactivateScreen();
			if (_limitSetting != null)
				_limitSetting.deactivateScreen();
		}
		
		override public function dispose():void {
			super.dispose();
			
			PayManager.S_ACCOUNT_SETTINGS_POST.remove(onAccountSettingsChange);
			PayManager.S_ACCOUNT_SETTINGS_CHANGE_RESPOND.remove(onAccountSettingsChangeRespond);	
			
			PaymentsManager.S_ACCOUNT.remove(onAccountInfoReady);
			PaymentsManager.S_BACK.remove(onBack);
			PaymentsManager.S_ERROR.remove(onPaymentsError);
			
			PaymentsManager.deactivate();
			
			UI.destroy(busyIndicator);
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			busyIndicator = null;
			if (syncButton != null)
				syncButton.dispose();
			syncButton = null;
			if (_groupListComponent != null)
				_groupListComponent.dispose();
			_groupListComponent = null;
			if (_limitSetting != null)
				_limitSetting.dispose();
			_limitSetting = null;
		}
		
		private function onPaymentsError(...rest):void {
			onCancelWrongPass();
		}
		
		override public function onBack(e:Event = null):void {
			if (data.autofillData != null && data.autofillData.invokedFromMainSetting == true)
				MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
			else
				super.onBack(e);
		}
		
		override protected function resetTitleText():void {
			txtTitle = Lang.oneClickPayments;
		}
		
		override protected function showWebView(url:String, isMyCard:Boolean = false):void {
			super.showWebView(url, isMyCard);
		}
	}
}