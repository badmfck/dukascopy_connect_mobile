package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.dialogs.bottom.AnimatedTitlePopup;
	import com.dukascopy.connect.sys.echo.echo;
	import com.greensock.TweenMax;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class ScreenPayWebviewDialog extends AnimatedTitlePopup {
		
		
		private var tempRect:Rectangle = new Rectangle();
		private var webView:StageWebView;
		private var executed:Boolean;
		
		public function ScreenPayWebviewDialog() { }
		
		override protected function createView():void {
			super.createView();	
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
		}
		
		override protected function animationFinished():void 
		{
			if (webView == null && "url" in data && data.url != null && !isDisposed)
			{
				showWebView(data.url);
			}
		}
		
		override protected function onRemove():void 
		{
			trace(executed == false);
			if (executed == false)
			{
				doCallBack(false);
			}
		}
		
		override protected function onCloseStart():void 
		{
			if (webView != null)
			{
				var location:String = webView.location;
				
				if (location.indexOf("status=success") > -1) {
					doCallBack(true);
				}
			}
			destroyWebView();
		}
		
		private function doCallBack(success:Boolean, dataValue:Object = null):void {
			if (this.data != null && "callback" in this.data && this.data.callback != null && executed == false)
			{
				executed = true;
				this.data.callback(success, dataValue);
			}
		}
		
		private function getHeight():int 
		{
			return _height;
		}
		
		private function showWebView(url:String):void {
			if (webView != null)
				return;
			webView ||= new StageWebView();
			
			updateViewport();
			
			webView.stage = MobileGui.stage;
			webView.loadURL(url);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, checkLocation);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, checkLocation);
			webView.addEventListener(Event.COMPLETE, checkLocation);
			webView.addEventListener(ErrorEvent.ERROR, onWebViewError);
		}
		
		private function updateViewport():void 
		{
			tempRect.x = 0;
			tempRect.y = view.y + container.y + headerHeight;
			
			tempRect.width = _width;
			tempRect.height = getHeight() - Config.FINGER_SIZE;
			webView.viewPort = tempRect;
		}
		
		public function destroyWebView():Boolean {
			var res:Boolean = false;
			if (webView != null) {
				res = true;
				webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, checkLocation);
				webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, checkLocation);
				webView.removeEventListener(Event.COMPLETE, checkLocation);
				webView.removeEventListener(ErrorEvent.ERROR, onWebViewError);
				webView.stage = null;
				webView.viewPort = null;
				webView.dispose();
			}
			webView = null;
			return res;
		}
		
		private function onWebViewError(e:ErrorEvent):void {
			echo("ScreenPayWebviewDialog", "onWebViewError", "Error: " + e.text);
		}
		
		private function checkLocation(e:Event):void {
			
			if (webView != null)
			{
				var location:String = webView.location;
				
				if (location.indexOf("status=success") > -1) {
					doCallBack(true);
					close();
				}
			}
		}
		
		override protected function drawView():void {
			if (isDisposed == true)
				return;
			var maxHeight:int = getHeight();
			
			if (webView != null)
			{
				updateViewport();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killDelayedCallsTo(drawView);
			destroyWebView();
		}
	}
}