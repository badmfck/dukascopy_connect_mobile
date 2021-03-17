package com.dukascopy.connect.sys 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.greensock.TweenMax;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class WebViewHidden 
	{
		private var webView:StageWebView;
		
		public function WebViewHidden() 
		{
			if (ConfigManager.config == null)
			{
				ConfigManager.S_CONFIG_READY.add(onConfigReady);
			}
			else
			{
				execute();
			}
		}
		
		private function onConfigReady():void 
		{
			ConfigManager.S_CONFIG_READY.remove(onConfigReady);
			execute();
		}
		
		public function execute():void
		{
			TweenMax.killDelayedCallsTo(loadURL);
			TweenMax.delayedCall(2, loadURL);
		}
		
		private function loadURL():void 
		{
			TweenMax.killDelayedCallsTo(destroy);
			if (ConfigManager.config == null)
			{
				return;
			}
			
			if (Config.START_URL == null || Config.START_URL == "")
			{
				destroy();
				return;
			}
			
			webView = new StageWebView(true, false);
			var tempRect:Rectangle = new Rectangle()
			tempRect.x = 0;
			tempRect.y = 0;
			if (MobileGui.stage != null)
			{
				tempRect.width = MobileGui.stage.stageWidth;
				tempRect.height = MobileGui.stage.stageHeight;
			}
			else
			{
				tempRect.width = 500;
				tempRect.height = 500;
			}
			
			webView.viewPort = tempRect;
			//webView.stage = MobileGui.stage;
			//trace("Web view stage:"+webView.stage);
			webView.loadURL(Config.START_URL + "?key=" + Auth.key);
			//trace(Config.START_URL + "?key=" + Auth.key);
			webView.addEventListener(Event.COMPLETE, onComplete);
			webView.addEventListener(ErrorEvent.ERROR, onWebViewError);
		}
		
		private function onComplete(e:Event):void {
			TweenMax.killDelayedCallsTo(destroy);
			TweenMax.delayedCall(15, destroy);
			//trace('WebView complete');
		//	destroy();
		}
		
		private function onWebViewError(e:ErrorEvent):void {
			destroy();
		}
		
		public function destroy():void {
			TweenMax.killDelayedCallsTo(destroy);
			TweenMax.killDelayedCallsTo(loadURL);
			
			ConfigManager.S_CONFIG_READY.remove(onConfigReady);
			
			if (webView == null)
				return;
			webView.removeEventListener(Event.COMPLETE, onComplete);
			webView.removeEventListener(ErrorEvent.ERROR, onWebViewError);
			webView.stage = null;
			webView.viewPort = null;
			webView.dispose();
			webView = null;
		}
	}
}