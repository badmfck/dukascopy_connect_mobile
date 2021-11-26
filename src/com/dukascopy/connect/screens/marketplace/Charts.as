package com.dukascopy.connect.screens.marketplace 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.langs.Lang;
	import flash.display.Shape;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class Charts extends BaseScreen{
		
		private var bg:Shape;
		protected var topBar:TopBarScreen;
		private var webView:StageWebView;
		
		private var actions:Array = [
			{ id:"refreshBtn", img:SWFPaymentsRefreshIcon, callback:onRefresh }
		];
		
		public function Charts() {
			
		}
		
		protected function onRefresh():void{
			topBar.showAnimationOverButton("refreshBtn", false);
			if (webView != null)
				webView.loadURL(Config.CRYPTO_CHART_URL);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			topBar.setData(Lang.dukCharts, true);
			topBar.setActions(actions);
		}
		
		override protected function createView():void {
			super.createView();
			
			bg = new Shape();
			bg.graphics.beginFill(0xF5F5F5);
			bg.graphics.drawRect(0, 0, 10, 10);
			_view.addChild(bg);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
		} 
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			
			if (topBar != null)
				topBar.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (topBar != null)
				topBar.deactivate();
		}
		
		override protected function drawView():void {
			bg.width = _width;
			bg.height = _height;
			
			topBar.drawView(_width);
		}
		
		override public function dispose():void {
			super.dispose();			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (bg != null)
				bg.graphics.clear();
			bg = null;
			destroyWebView();
		}
		
		public function onShowComplete():void {
			webView = new StageWebView(true, false);
			var tempRect:Rectangle = new Rectangle()
			tempRect.x = 0;
			tempRect.y = topBar.trueHeight;
			tempRect.width = MobileGui.stage.stageWidth;
			tempRect.height = MobileGui.stage.stageHeight - tempRect.y;
			webView.viewPort = tempRect;
			webView.stage = MobileGui.stage;
			webView.viewPort = tempRect;
			webView.stage = MobileGui.stage;
			webView.loadURL(Config.CRYPTO_CHART_URL); //
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, checkLocation);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, checkLocation);
			webView.addEventListener(Event.COMPLETE, checkLocation);
			webView.addEventListener(ErrorEvent.ERROR, onWebViewError);
			
			//NativeExtensionController.callWebView(Config.CRYPTO_CHART_URL, true);
		}
		
		private function checkLocation(e:Event):void {
			topBar.hideAnimation();
		}
		
		private function onWebViewError(e:ErrorEvent):void {
			topBar.hideAnimation();
		}
		
		public function destroyWebView():void {
			if (webView == null)
				return;
			webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, checkLocation);
			webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, checkLocation);
			webView.removeEventListener(Event.COMPLETE, checkLocation);
			webView.removeEventListener(ErrorEvent.ERROR, onWebViewError);
			webView.stage = null;
			webView.viewPort = null;
			webView.dispose();
			webView = null;
		}
	}
}