package com.dukascopy.connect.screens.payments.settings {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.payments.component.WebViewComponent;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class PaymentsBaseScreen extends BaseScreen {
		
		protected var webViewComponent:WebViewComponent;
		
		private var topBar:TopBarScreen;
		
		private var screenBackground:Bitmap;
		private var screenBGScroll:Bitmap;
		
		public var scrollPanel:ScrollPanel;
		
		private var preloader:Preloader;
		
		public var swipeAllowed:Boolean = true;
		
		private var lastCallID:String;
		private var _txtTitle:String = "";
		
		public function PaymentsBaseScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = false;
			// Background
			createViewBG();
			createViewBGscroll();
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			addScrollPanel();
			showPreloader();
		}
		
		protected function createViewBG():void {
			if (screenBackground != null)
				return;
			screenBackground = new Bitmap();
			screenBackground.bitmapData = new ImageBitmapData(
				"PaymentsCardDetailsScreen.screenBackground",
				1,
				1,
				false,
				Style.color(Style.COLOR_BACKGROUND)
			);
			_view.addChild(screenBackground);
		}
		
		protected function createViewBGscroll():void {
			if (screenBGScroll != null)
				return;
			screenBGScroll = new Bitmap();
			screenBGScroll.bitmapData = new ImageBitmapData(
				"PaymentsCardDetailsScreen.screenBGScroll",
				1,
				1,
				false,
				Style.color(Style.COLOR_BACKGROUND)
			);
			_view.addChild(screenBGScroll)
		}
		
		protected function addScrollPanel():void {
			_view.addChild(scrollPanel.view);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(_txtTitle, true);
			topBar.drawView(_width);
			hidePrelaoder();
		}

		override public function setWidthAndHeight(width:int, height:int):void {
			super.setWidthAndHeight(width, height);
			if (scrollPanel != null)
				scrollPanel.updateObjects();
		}
		
		override protected function drawView():void {
			
			if (screenBackground != null) {
				screenBackground.width = _width;
				screenBackground.height = _height;
			}
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = _height * .5;
			}
			if (scrollPanel != null) {
				scrollPanel.view.y = topBar.trueHeight;
				scrollPanel.setWidthAndHeight(_width, _height - (scrollPanel.view.y), true);
				if (screenBGScroll != null) {
					screenBGScroll.y = scrollPanel.view.y;
					screenBGScroll.width = scrollPanel.view.width ;
					screenBGScroll.height = _height - scrollPanel.view.y;
				}
			}
		}
		
		override public function activateScreen():void {
			if (_isDisposed)
				return;
			if (topBar != null)
				topBar.activate();
			if (scrollPanel != null)
				scrollPanel.enable();
			super.activateScreen();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed)
				return;
			if (topBar != null)
				topBar.deactivate();
			if (scrollPanel != null)
				scrollPanel.disable();
			super.deactivateScreen();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			lastCallID = "";
			destroyWebView();
			UI.destroy(screenBackground);
			screenBackground = null;
			UI.destroy(screenBGScroll);
			screenBGScroll = null;
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
		}
		
		override public function onBack(e:Event = null):void {
			if (webViewComponent != null && webViewComponent.initialized == true) {
				destroyWebView();
				return;
			}
			if (data != null && data.backScreen != null)
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
			else
				MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		private function showPreloader():void {
			if (preloader == null)
				preloader = new Preloader();
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			_view.addChild(preloader);
			preloader.show();
		}
		
		private function hidePrelaoder(dispose:Boolean = false):void {
			if (preloader != null) {
				preloader.hide(dispose);
				if (preloader.parent)
					_view.removeChild(preloader);
			}
		}
		
		protected function showWebView(url:String, isMyCard:Boolean = false):void {
			if (webViewComponent == null) {
				webViewComponent = new WebViewComponent();
				swipeAllowed = false;
			}
			webViewComponent.showWebView(
				url,
				new Rectangle(
					0,
					topBar.trueHeight,
					MobileGui.stage.stageWidth,
					MobileGui.stage.stageHeight - topBar.trueHeight
				),
				isMyCard
			);
		}
		
		protected function destroyWebView():void {
			if (webViewComponent != null)
				webViewComponent.destroyWebView();
			swipeAllowed = true;
		}
		
		public function get txtTitle():String {
			return _txtTitle;
		}
		
		public function set txtTitle(value:String):void {
			_txtTitle = value;
		}
		
		protected function resetTitleText():void {
			_txtTitle = " ";
		}
	}
}