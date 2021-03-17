package com.dukascopy.connect.screens.geolocation {
	
	import assets.BoredIllustrationClip;
	import assets.MapIllustration;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.data.location.UserGeoposition;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListLocations;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.geolocation.GeolocationManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * @author Sergey Dobarin.
	 */
	
	public class Geolocation911Screen extends BaseScreen {
		
		static public const STATE_PERMISSION:String = "statePermission";
		static public const STATE_SEND_LOCATION:String = "stateSendLocation";
		static public const STATE_CONTENT:String = "stateContent";
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var allUsers:Vector.<ChatUserVO>;
		private var permissionTitle:Bitmap;
		private var permissionDescription:Bitmap;
		private var nextButton:BitmapButton;
		private var background:Sprite;
		private var illustration:Bitmap;
		private var preloader:Preloader;
		private var backButton:BitmapButton;
		private var paymentsButton:BitmapButton;
		private var permissionGranted:Boolean;
		private var paymentsNeeded:Boolean;
		private var buttonClicked:Boolean;
		private var noUsersDescription:Bitmap;
		private var noUsersIllustration:Bitmap;
		private var noUsersDescriptionBack:Sprite;
		private var currentState:String;
		private var accountsPreloader:HorizontalPreloader;
		private var isMuted:Boolean;
		
		static public const TAB_ALL:String = "TAB_ALL";
		static public const TAB_M:String = "TAB_M";
		static public const TAB_W:String = "TAB_W";
		static public const DATE_TODAY:String = "dateToday";
		static public const DATE_MONTH:String = "dateMonth";
		static public const DATE_ALL:String = "dateAll";
		
		private var tabs:FilterTabs;
		private var selectedFilter:String;
		private var dateButton:BitmapButton;
		private var dateFilter:String;
		
		public function Geolocation911Screen() { }
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			_view.addChild(background);
			
			topBar = new TopBarScreen();
			
			list = new List("ChatUsersScreen.list");
			list.setContextAvaliable(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			
			tabs = new FilterTabs();
		//	tabs.setTabsWidthByText(true);
			tabs.add(Lang.all, TAB_ALL, true, "l");
			tabs.add(LocalAvatars.MEN, TAB_M);
			tabs.add(LocalAvatars.WOMAN, TAB_W, false, "r");
			_view.addChild(tabs.view);
			tabs.view.y = topBar.trueHeight;
			
			_view.addChild(list.view);
			_view.addChild(topBar);
			
			illustration = new Bitmap();
			_view.addChild(illustration);
			
			permissionTitle = new Bitmap();
			_view.addChild(permissionTitle);
			
			permissionDescription = new Bitmap();
			_view.addChild(permissionDescription);
			
			noUsersDescriptionBack = new Sprite();
			_view.addChild(noUsersDescriptionBack);
			
			noUsersDescription = new Bitmap();
			_view.addChild(noUsersDescription);
			
			noUsersIllustration = new Bitmap();
			_view.addChild(noUsersIllustration);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = getPermissions;
			nextButton.disposeBitmapOnDestroy = true;
			view.addChild(nextButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = onBack;
			backButton.disposeBitmapOnDestroy = true;
			view.addChild(backButton);
			
			paymentsButton = new BitmapButton();
			paymentsButton.setStandartButtonParams();
			paymentsButton.setDownScale(1);
			paymentsButton.setDownColor(0);
			paymentsButton.tapCallback = goPayments;
			paymentsButton.disposeBitmapOnDestroy = true;
			view.addChild(paymentsButton);
			
			accountsPreloader = new HorizontalPreloader(0x629DB7);
			view.addChild(accountsPreloader);
			
			background.alpha = 0;
			
			dateButton = new BitmapButton();
			dateButton.setStandartButtonParams();
			dateButton.setDownScale(1);
			dateButton.setDownColor(0);
			dateButton.tapCallback = selectDate;
			dateButton.disposeBitmapOnDestroy = true;
			view.addChild(dateButton);
			
			dateFilter = DATE_ALL;
		}
		
		private function selectDate():void 
		{
			var items:Array = new Array();
			items.push({fullLink:Lang.textToday != null ? Lang.textToday.toLowerCase():"today", id:DATE_TODAY});
			items.push({fullLink:Lang.textMonth != null ? Lang.textMonth.toLowerCase():"month", id:DATE_MONTH});
			items.push({fullLink:Lang.duringAllTime != null ? Lang.duringAllTime.toLowerCase():"all time", id:DATE_ALL});
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
				if (data != null && data.id != -1)
				{
					dateFilter = data.id;
					updateListData();
					drawDateButton();
					dateButton.x = int(_width - dateButton.width - Config.MARGIN);
					dateButton.y = int(tabs.view.y + tabs.height * .5 - dateButton.height * .5);
				}
			}, data:items, itemClass:ListLink, multilineTitle:false } );
		}
		
		private function goPayments():void 
		{
			MobileGui.showRoadMap();
		}
		
		private function getPermissions():void 
		{
			buttonClicked = true;
			if (permissionGranted == false)
			{
				openApplicationSettings();
				return;
			}
			GeolocationManager.getLocation();
		}
		
		private function drawNextButton():void 
		{
			var textDone:TextFieldSettings = new TextFieldSettings(Lang.sendLocation, 0xCF3F43, Config.FINGER_SIZE * .35, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textDone, 0xDBF3EE, 0, Config.FINGER_SIZE * .8, 0xCF3F43);
			nextButton.setBitmapData(buttonBitmap, true);
			nextButton.x = int(_width * .5 - nextButton.width * .5);
		}
		
		override protected function drawView():void {
			topBar.drawView(_width);
			
			accountsPreloader.y = topBar.trueHeight;
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(Lang.usersNear, true);
			_params.doDisposeAfterClose = true;
			
			view.graphics.beginFill(0xFFFFFF);
			view.graphics.drawRect(0, 0, _width, _height);
			view.graphics.endFill();
			
			tabs.setWidthAndHeight(_width * .5, Config.TOP_BAR_HEIGHT);
			list.view.y = topBar.trueHeight + tabs.height;
			list.setWidthAndHeight(_width, _height - list.view.y - Config.APPLE_BOTTOM_OFFSET);
			
			drawDateButton();
			dateButton.x = int(_width - dateButton.width - Config.MARGIN);
			dateButton.y = int(tabs.view.y + tabs.height * .5 - dateButton.height * .5);
			
			paymentsNeeded = false;
			permissionGranted = true;
			
			accountsPreloader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			GeolocationManager.S_LOCATION.add(onLocation);
		//	GeolocationManager.S_STATUS.add(onLocationStatus);
			GeolocationManager.S_LOCATIONS.add(showContent);
			GeolocationManager.S_LOCATIONS_REFRESH.add(updateList);
			GeolocationManager.S_ERROR.add(onGlobalError);
			GeolocationManager.S_PERMISSION_DENIED.add(onPermissionDenied);
			GeolocationManager.S_NEED_PAYMENTS.add(onPaymentsNeeded);
			GeolocationManager.S_ALL_DATA_READY.add(allDataReady);
			GeolocationManager.S_DATA_LOAD_START.add(showLoader);
			GeolocationManager.S_LISTEN_LOCATION_START.add(showLoader);
			GeolocationManager.S_SERVICE_MUTED.add(onMuted);
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
			
			updateState();
		}
		
		private function drawDateButton():void 
		{
			var clip:Sprite = new Sprite();
			
			var text:ImageBitmapData = TextUtils.createTextFieldData(getDateText(), _width * .5 - Config.MARGIN, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0x000000, 0xFFFFFF);
			
			clip.graphics.beginFill(0xFFFFFF);
			clip.graphics.drawRect(0, 0, text.width + Config.FINGER_SIZE * .5, text.height + Config.FINGER_SIZE * .2);
			clip.graphics.endFill();
			
			var positionArrow:Point = new Point(Config.FINGER_SIZE * .1 + text.width + Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .13 + text.height * .5);
			
			clip.graphics.beginFill(0x9CA9B6);
			clip.graphics.moveTo(int(positionArrow.x - Config.FINGER_SIZE*.1), int(positionArrow.y - Config.FINGER_SIZE*.1));
			clip.graphics.lineTo(int(positionArrow.x + Config.FINGER_SIZE*.1), int(positionArrow.y - Config.FINGER_SIZE*.1));
			clip.graphics.lineTo(int(positionArrow.x), int(positionArrow.y));
			clip.graphics.lineTo(int(positionArrow.x - Config.FINGER_SIZE*.1), int(positionArrow.y - Config.FINGER_SIZE*.1));
			clip.graphics.endFill();
			
			var buttonImage:ImageBitmapData = UI.getSnapshot(clip);
			buttonImage.copyPixels(text, text.rect, new Point(int(Config.FINGER_SIZE * .1), int(Config.FINGER_SIZE * .1)), null, null, true);
			
			text.dispose();
			text = null;
			
			dateButton.setBitmapData(buttonImage, true);
		}
		
		private function getDateText():String 
		{
			var result:String = "";
			if (dateFilter == DATE_TODAY)
			{
				result = Lang.textToday;
			}
			else if (dateFilter == DATE_MONTH)
			{
				result = Lang.textMonth;
			}
			else if (dateFilter == DATE_ALL)
			{
				result = Lang.duringAllTime;
			}
			return result.toLowerCase();
		}
		
		private function onMuted(value:Boolean):void 
		{
			var needUpdate:Boolean = false;
			if (isMuted != value && currentState != STATE_CONTENT)
			{
				needUpdate = true;
			}
			if (list.view.visible && list.data != null)
			{
				needUpdate = false;
			}
			isMuted = value;
			if (needUpdate)
			{
				updateState();
			}
		}
		
		private function onActivate(e:Event = null):void {
			if (permissionGranted == false)
			{
				updateState();
			}
		}
		
		private function onPaymentsNeeded():void 
		{
			paymentsNeeded = true;
			showPermission();
		}
		
		private function onPermissionDenied():void 
		{
			if (isDisposed)
			{
				return;
			}
			hidePreloader();
			if (buttonClicked == true)
			{
				buttonClicked = false;
				openApplicationSettings();
			}
			permissionGranted = false;
			showPermission();
		}
		
		private function onGlobalError():void 
		{
			if (isDisposed)
			{
				return;
			}
			onBack();
		}
		
		private function updateList():void 
		{
			if (isDisposed)
			{
				return;
			}
			if (list != null)
			{
				list.refresh(true, true);
			}
		}
		
		private function updateState():void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (GeolocationManager.isGranted() && paymentsNeeded == false)
			{
				if (isMuted)
				{
					showPermission();
				}
				else{
					
					illustration.visible = false;
					permissionTitle.visible = false;
					permissionDescription.visible = false;
					nextButton.visible = false;
					background.graphics.clear();
					noUsersIllustration.visible = false;
					noUsersDescription.visible = false;
					
					if (GeolocationManager.getLocations() != null)
					{
						list.setData(filter(GeolocationManager.getLocations()), ListLocations);
						if (_isActivated == true){
							list.activate();
						}
					}
					sendLocation();
				}
			}
			else{
				showPermission();
			}
		}
		
		private function filter(locations:Vector.<UserGeoposition>):Vector.<UserGeoposition> 
		{
			var result:Vector.<UserGeoposition>;
			var l:int;
			var item:UserGeoposition;
			var filter:String;
			if (selectedFilter == TAB_M)
			{
				filter = "male";
			}
			else if (selectedFilter == TAB_W)
			{
				filter = "female";
			}
			if (filter != null)
			{
				result = new Vector.<UserGeoposition>();
				l = locations.length;
				for (var i:int = 0; i < l; i++) 
				{
					item = locations[i];
					if (item.userVO != null && item.userVO.gender == filter)
					{
						result.push(item);
					}
				}
			}
			else
			{
				result = locations;
			}
			
			var dateRange:Number = NaN;
			var date:Date;
			if (dateFilter == DATE_MONTH)
			{
				dateRange = 30 * 24 * 60 * 60;
			}
			else if (dateFilter == DATE_TODAY)
			{
				date = new Date();
				dateRange = date.getHours() * 60 * 60 + date.getMinutes() * 60 + date.getSeconds();
			}
			
			if (!isNaN(dateRange))
			{
				var resultDate:Vector.<UserGeoposition> = new Vector.<UserGeoposition>();
				l = result.length;
				for (var j:int = 0; j < l; j++) 
				{
					if (date == null)
					{
						date = new Date();
					}
					item = result[j];
					if (date.getTime()/1000 - item.ctime < dateRange)
					{
						resultDate.push(item);
					}
				}
				result = resultDate;
				resultDate = null;
			}
			
			return result;
		}
		
		private function onLocationStatus():void 
		{
			if (isDisposed)
			{
				return;
			}
			updateState();
		}
		
		private function showContent():void 
		{
			if (isDisposed)
			{
				return;
			}
			
			illustration.visible = false;
			permissionTitle.visible = false;
			permissionDescription.visible = false;
			//!TODO dispose?
			
		//	hidePreloader();
			
			var items:Vector.<UserGeoposition> = GeolocationManager.getLocations();
			
			if (items == null || items.length == 0)
			{
				if (currentState == STATE_CONTENT)
				{
					return;
				}
				
				background.graphics.beginFill(0xDBF3EE);
				background.graphics.drawRect(0, 0, _width, _height);
				background.graphics.endFill();
				
				nextButton.visible = false;
				backButton.visible = true;
				
				drawBackButton();
				drawNoUserIllustration();
				drawNoUserDescription();
				drawBackButton();
				
				var position:int = _height - Config.FINGER_SIZE * 1.5;
				position -= backButton.height;
				
				backButton.y = position;
				
				noUsersDescription.y = topBar.trueHeight + int((position - topBar.height) * .5 - (noUsersDescriptionBack.height + noUsersIllustration.height) * .5);
				noUsersDescriptionBack.y = int(noUsersDescription.y + noUsersDescription.height * .5 - noUsersDescriptionBack.height * .5);
				noUsersDescriptionBack.x = int(noUsersDescription.x + noUsersDescription.width * .5 - noUsersDescriptionBack.width * .5);
				
				var clipHeight:int = noUsersDescriptionBack.height;
				noUsersDescriptionBack.graphics.beginFill(0xE6FFF9);
				noUsersDescriptionBack.graphics.moveTo(noUsersDescriptionBack.width - Config.FINGER_SIZE * 1.3, clipHeight);
				noUsersDescriptionBack.graphics.lineTo(noUsersDescriptionBack.width - Config.FINGER_SIZE * 1.4, clipHeight + Config.FINGER_SIZE * .6);
				noUsersDescriptionBack.graphics.lineTo(noUsersDescriptionBack.width - Config.FINGER_SIZE * .95, clipHeight);
				noUsersDescriptionBack.graphics.lineTo(noUsersDescriptionBack.width - Config.FINGER_SIZE * 1.3, clipHeight);
				noUsersDescriptionBack.graphics.endFill();
				
				noUsersIllustration.y = int(noUsersDescriptionBack.y + noUsersDescriptionBack.height - Config.MARGIN);
				background.visible = true;
				
				hideList();
				
				noUsersIllustration.alpha = 0;
				noUsersDescription.alpha = 0;
				noUsersDescriptionBack.alpha = 0;
				TweenMax.to(background, 0.5, {alpha:1});
				TweenMax.to(noUsersIllustration, 0.5, {alpha:1, delay:0.1});
				TweenMax.to(noUsersDescription, 0.5, {alpha:1, delay:0.3});
				TweenMax.to(noUsersDescriptionBack, 0.5, {alpha:1, delay:0.2});
			}
			else
			{
				nextButton.visible = false;
				showList();
				
				list.setData(filter(GeolocationManager.getLocations()), ListLocations);
				if (_isActivated == true){
					list.activate();
				}
			}
			
			currentState = STATE_CONTENT;
		}
		
		private function showList():void 
		{
			list.view.visible = true;
			tabs.view.visible = true;
			dateButton.visible = true;
		}
		
		private function drawNoUserIllustration():void 
		{
			if (noUsersIllustration.bitmapData != null) {
				noUsersIllustration.bitmapData.dispose();
				noUsersIllustration.bitmapData = null;
			}
			
			var icon:Sprite = new BoredIllustrationClip();
			UI.scaleToFit(icon, Math.min(_width - Config.FINGER_SIZE, Config.FINGER_SIZE * 4), Config.FINGER_SIZE * 10);
			noUsersIllustration.bitmapData = UI.getSnapshot(icon, StageQuality.HIGH, "Geolocation911Screen.illustrationNoUser");
			noUsersIllustration.x = int(_width * .5 - noUsersIllustration.width * .5);
			noUsersIllustration.visible = true;
		}
		
		private function drawBackButton():void 
		{
			var textDone:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x5C6664, Config.FINGER_SIZE * .35, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textDone, 0xDBF3EE, 0, Config.FINGER_SIZE * .8, 0x5C6664);
			backButton.setBitmapData(buttonBitmap, true);
			backButton.x = int(_width * .5 - backButton.width * .5);
		}
		
		private function drawNoUserDescription():void 
		{
			if (noUsersDescription.bitmapData != null) {
				noUsersDescription.bitmapData.dispose();
				noUsersDescription.bitmapData = null;
			}
			
			//!TODO width
			noUsersDescription.visible = true;
			noUsersDescription.bitmapData = TextUtils.createTextFieldData(Lang.noUsersWithGeolocation, _width - Config.FINGER_SIZE * 2, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .30, 
															true, 0x697472, 0xE6FFF9, true);
			noUsersDescription.x = int(_width * .5 - noUsersDescription.width * .5);
			permissionTitle.visible = true;
			
			noUsersDescriptionBack.graphics.clear();
			noUsersDescriptionBack.graphics.beginFill(0xE6FFF9);
			noUsersDescriptionBack.graphics.drawRoundRect(0, 0, noUsersDescription.width + Config.FINGER_SIZE * .7, 
																noUsersDescription.height + Config.FINGER_SIZE * .7, 
																Config.FINGER_SIZE, 
																Config.FINGER_SIZE);
			noUsersDescriptionBack.graphics.endFill();
		}
		
		private function hidePreloader():void 
		{
			accountsPreloader.stop();
		}
		
		private function sendLocation():void 
		{
			if (currentState == STATE_SEND_LOCATION)
			{
				return;
			}
			currentState = STATE_SEND_LOCATION;
			GeolocationManager.getLocation();
		}
		
		private function showLoader():void 
		{
			if (currentState == STATE_CONTENT || (list.view.visible && list.data != null))
			{
				return;
			}
			accountsPreloader.start();
			if (currentState == STATE_PERMISSION)
			{
				var time:Number = 0.3;
				TweenMax.to(illustration, time, {alpha:0});
				TweenMax.to(permissionTitle, time, {alpha:0})
				TweenMax.to(permissionDescription, time, {alpha:0})
				TweenMax.to(nextButton, time, {alpha:0})
				TweenMax.to(background, time, {alpha:0})
				TweenMax.to(noUsersIllustration, time, {alpha:0})
				TweenMax.to(noUsersDescription, time, {alpha:0})
				nextButton.deactivate();
			}
		}
		
		private function openApplicationSettings():void {
		//	NativeExtensionController.tryGetGeoPermission();
			NativeExtensionController.openSettings();
		}
		
		private function showPermission():void 
		{
			if (currentState == STATE_PERMISSION)
			{
				return;
			}
			currentState = STATE_PERMISSION;
			
			background.alpha = 1;
			drawPermissionTitle();
			drawPermissionText();
			
			var position:int;
			
			if (isMuted)
			{
				nextButton.visible = false;
				paymentsButton.visible = true;
				
				position = _height - Config.FINGER_SIZE * 1.5;
				position -= paymentsButton.height;
				paymentsButton.y = position;
			}
			else if (paymentsNeeded)
			{
				drawPaymentsButton();
				nextButton.visible = false;
				paymentsButton.visible = true;
				
				position = _height - Config.FINGER_SIZE * 1.5;
				position -= paymentsButton.height;
				paymentsButton.y = position;
			}
			else {
				drawNextButton();
				nextButton.visible = true;
				paymentsButton.visible = false;
				
				position = _height - Config.FINGER_SIZE * 1.5;
				position -= nextButton.height;
				nextButton.y = position;
			}
			
			position -= permissionDescription.height + Config.FINGER_SIZE;
			permissionDescription.y = position;
			
			position -= permissionTitle.height + Config.MARGIN * 3;
			permissionTitle.y = position;
			
			var maxHeight:int = position - topBar.height + Config.FINGER_SIZE;
			
			drawIllustration(maxHeight);
			
			illustration.y = int(position * .5 - illustration.height * .5) + Config.FINGER_SIZE * 1.5 + topBar.y;
			position += illustration.height;
			
			hideList();
			
			background.graphics.beginFill(0xDBF3EE);
			background.graphics.drawRect(0, 0, _width, _height);
			background.graphics.endFill();
		}
		
		private function hideList():void 
		{
			list.view.visible = false;
			tabs.view.visible = false;
			dateButton.visible = false;
		}
		
		/*private function drawBackButton():void 
		{
			var text:TextFieldSettings = new TextFieldSettings(Lang.CANCEL, 0xCF3F43, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(text, 0xDBF3EE, 0, Config.FINGER_SIZE * .8, 0xCF3F43);
			backButton.setBitmapData(buttonBitmap, true);
		}*/
		
		private function drawPaymentsButton():void 
		{
			var text:TextFieldSettings = new TextFieldSettings(Lang.openAccount, 0xCF3F43, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(text, 0xDBF3EE, 0, Config.FINGER_SIZE * .8, 0xCF3F43);
			paymentsButton.setBitmapData(buttonBitmap, true);
			paymentsButton.x = int(_width * .5 - paymentsButton.width * .5);
		}
		
		private function drawIllustration(maxHeight:int):void 
		{
			if (illustration.bitmapData != null) {
				illustration.bitmapData.dispose();
				illustration.bitmapData = null;
			}
			
			var icon:Sprite = new MapIllustration();
			UI.scaleToFit(icon, _width, maxHeight);
			illustration.bitmapData = UI.getSnapshot(icon, StageQuality.HIGH, "Geolocation911Screen.illustration");
			illustration.x = int(_width * .5 - illustration.width * .5);
			illustration.visible = true;
		}
		
		private function drawPermissionTitle():void 
		{
			if (permissionTitle.bitmapData != null) {
				permissionTitle.bitmapData.dispose();
				permissionTitle.bitmapData = null;
			}
			
			permissionTitle.bitmapData = TextUtils.createTextFieldData(Lang.geolocationTitle, _width - Config.FINGER_SIZE * 2, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .46, 
															true, 0xCD3F43, 0xDBF3EE, true);
			permissionTitle.x = int(_width * .5 - permissionTitle.width * .5);
			permissionTitle.visible = true;
		}
		
		private function drawPermissionText():void 
		{
			if (permissionDescription.bitmapData != null) {
				permissionDescription.bitmapData.dispose();
				permissionDescription.bitmapData = null;
			}
			
			var text:String = Lang.geolocationDescription;
			
			if (permissionGranted == false)
			{
				text = Lang.needGeopositionPermissions;
			}
			else if (onPaymentsNeeded)
			{
				text += " " + Lang.identifiedUserDescription;
			}
			if (isMuted)
			{
				text = Lang.turnOnGeolocation;
			}
			
			permissionDescription.bitmapData = TextUtils.createTextFieldData(text, _width - Config.FINGER_SIZE, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, 
															true, 0x666666, 0xDBF3EE, true);
			permissionDescription.x = int(_width * .5 - permissionDescription.width * .5);
			permissionDescription.visible = true;
		}
		
		private function onLocation(location:Location):void {
			if (isDisposed)
				return;
			if (location != null)
				GeolocationManager.saveMyLocation();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			
			updateState();
			
			if (list != null && list.view.visible == true) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				
				if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			}
			if (topBar != null)
				topBar.activate();
			if (nextButton.visible == true)
			{
				nextButton.activate();
			}
			if (paymentsButton.visible == true)
			{
				paymentsButton.activate();
			}
			if (backButton.visible == true)
			{
				backButton.activate();
			}
			if (dateButton != null)
			{
				dateButton.activate();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (topBar != null)
				topBar.deactivate();
			nextButton.deactivate();
			paymentsButton.deactivate();
			backButton.deactivate();
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			if (dateButton != null)
			{
				dateButton.deactivate();
			}
		}
		
		private function onTabItemSelected(id:String):void {			
			selectedFilter = id;
			
			updateListData();
		}
		
		private function updateListData():void 
		{
			if (list != null && list.view.visible == true)
			{
				list.setData(filter(GeolocationManager.getLocations()), ListLocations);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			TweenMax.killTweensOf(background);
			TweenMax.killTweensOf(noUsersIllustration);
			TweenMax.killTweensOf(noUsersDescription);
			TweenMax.killTweensOf(noUsersDescriptionBack);
			
			GeolocationManager.S_LOCATION.remove(onLocation);
		//	GeolocationManager.S_STATUS.remove(onLocationStatus);
			GeolocationManager.S_LOCATIONS.remove(showContent);
			GeolocationManager.S_LOCATIONS_REFRESH.remove(updateList);
			GeolocationManager.S_ERROR.remove(onGlobalError);
			GeolocationManager.S_PERMISSION_DENIED.remove(onPermissionDenied);
			GeolocationManager.S_NEED_PAYMENTS.remove(onPaymentsNeeded);
			GeolocationManager.S_ALL_DATA_READY.remove(allDataReady);
			GeolocationManager.S_DATA_LOAD_START.remove(showLoader);
			GeolocationManager.S_LISTEN_LOCATION_START.remove(showLoader);
			GeolocationManager.S_SERVICE_MUTED.remove(onMuted);
			
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivate);
			
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			if (list != null)
				list.dispose();
			list = null;
			if (permissionTitle != null){
				UI.destroy(permissionTitle);
				permissionTitle = null;
			}
			if (permissionDescription != null){
				UI.destroy(permissionDescription);
				permissionDescription = null;
			}
			if (illustration != null){
				UI.destroy(illustration);
				illustration = null;
			}
			if (noUsersDescription != null){
				UI.destroy(noUsersDescription);
				noUsersDescription = null;
			}
			if (noUsersIllustration != null){
				UI.destroy(noUsersIllustration);
				noUsersIllustration = null;
			}
			if (noUsersDescriptionBack != null){
				UI.destroy(noUsersDescriptionBack);
				noUsersDescriptionBack = null;
			}
			if (background != null){
				UI.destroy(background);
				background = null;
			}
			if (nextButton != null){
				nextButton.dispose();
				nextButton = null;
			}
			if (preloader != null){
				preloader.dispose();
				preloader = null;
			}
			if (backButton != null){
				backButton.dispose();
				backButton = null;
			}
			if (paymentsButton != null){
				paymentsButton.dispose();
				paymentsButton = null;
			}
			if (accountsPreloader != null){
				accountsPreloader.dispose();
				accountsPreloader = null;
			}
			if (dateButton != null){
				dateButton.dispose();
				dateButton = null;
			}
			
			allUsers = null;
		}
		
		private function allDataReady():void 
		{
			hidePreloader();
			updateListData();
		}
		
		// !TODO:
		private function onItemTap(data:Object, n:int):void {
			
			if (data == null || (data is UserGeoposition) == false)
				return;
			
			var user:UserGeoposition = data as UserGeoposition;
			
			if (user.userVO == null || user.userVO.uid == Auth.uid)
				return;
			
			if (user.userVO.type != UserType.BOT) {
				MobileGui.changeMainScreen(UserProfileScreen, { data:user.userVO, 
																backScreen:MobileGui.centerScreen.currentScreenClass, 
																backScreenData:this.data
				} );
			}
		}
		
		private function onUserlistOnlineStatusChanged():void {
			if (list)
				list.refresh();
		}
		
		private function onAllUsersOffline():void {
			if (list)
				list.refresh();
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void {
			if (isDisposed || list == null)
				return;
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS) {
				var item:ListItem;
				var l:int = list.getStock().length;
				var itemData:UserGeoposition;
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) {
					item = list.getItemByNum(j);
					if (item && item.liView && item.liView.visible) {
						if (item.data is UserGeoposition) {
							itemData = item.data as UserGeoposition;
							if (itemData.userVO && itemData.userVO.uid == status.uid) {
								if (list.getScrolling())
									list.refresh();
								else
									item.draw(list.width, !list.getScrolling());
								break;
							}
						}
					}
					else
						break;
				}
				itemData = null;
				item = null;
			}
		}
	}
}