/**
 * Created by aleksei.leschenko on 12.12.2016.
 */
package com.dukascopy.connect.screens.payments.component {
	import com.dukascopy.connect.sys.echo.echo;

	import flash.events.ErrorEvent;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.payments.PayConfig;

	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;

	public class WebViewComponent {

		private var webView:StageWebView;
		public var initialized:Boolean;
		private static var tempRect:Rectangle = new Rectangle();


		public function WebViewComponent() {
		}

		public function showWebView(url:String, rect:Rectangle, isSID:Boolean):void {
			if (webView == null) {
				webView = new StageWebView();

				tempRect.x = rect.x;//0;
				tempRect.y = rect.y;//topHeight;
				tempRect.width =rect.width;// MobileGui.stage.stageWidth;
				tempRect.height = rect.height; //MobileGui.stage.stageHeight - topHeight;

				webView.viewPort = tempRect;
				webView.stage = MobileGui.stage;
				if (isSID) {
					webView.loadURL(url + "&sid=" + PayConfig.PAY_SESSION_ID);
				} else {
					webView.loadURL(url);
				}
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, checkLocation);
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, checkLocation);
				webView.addEventListener(ErrorEvent.ERROR, onWebViewError);
				webView.addEventListener(Event.COMPLETE, checkLocation);
				initialized = true;
			}
		}

		public function destroyWebView():void {
			if (webView != null) {
				webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, checkLocation);
				webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, checkLocation);
				webView.removeEventListener(Event.COMPLETE, checkLocation);
				webView.removeEventListener(ErrorEvent.ERROR, onWebViewError);
				webView.stage = null;
				webView.viewPort = null;
				webView.dispose();
			}
			webView = null;
			initialized = false;
		}

		private function onCancelWebView(e:Event = null):void {
			destroyWebView();
		}

		private function checkLocation(e:Event):void {
			var location:String = webView.location;
			if (location.indexOf("&close-webview=1") > -1) {
				destroyWebView();
				e.stopImmediatePropagation();
				e.preventDefault();
			}
		}

		private function onWebViewError(e:ErrorEvent):void {
			echo("PaymentsCardDetailsScreen", "onWebViewError", "Error: " + e.text);
		}
	}
}
