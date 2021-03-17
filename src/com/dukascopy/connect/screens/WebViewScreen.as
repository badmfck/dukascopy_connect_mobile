package com.dukascopy.connect.screens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.dccext.DCCExt;
	import com.dukascopy.dccext.DCCExtCommand;
import com.dukascopy.dccext.DCCExtMethod;
import com.dukascopy.langs.Lang;
	import flash.display.Shape;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class WebViewScreen extends BaseScreen {
		
		private var bg:Shape;
		private var topBar:TopBarScreen;
		
		private var webView:StageWebView;
		
		public function WebViewScreen() {
			
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData((data.title != undefined) ? data.title : Lang.TEXT_LINK_CARDS, true);
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
			var tempRect:Rectangle = new Rectangle()
			tempRect.x = 0;
			tempRect.y = topBar.trueHeight;
			tempRect.width = MobileGui.stage.stageWidth;
			tempRect.height = MobileGui.stage.stageHeight - tempRect.y;

			if (Config.PLATFORM_APPLE == true) {
				if(showWebViewIOS(tempRect))
					return;

				return; // TODO - REMOVE IN LIVE BUILD
			}

			webView = new StageWebView();
			webView.viewPort = tempRect;
			webView.stage = MobileGui.stage;
			webView.loadURL(data.link);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, locationChange);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, locationChanging);
			webView.addEventListener(Event.COMPLETE, checkLocation);
			webView.addEventListener(ErrorEvent.ERROR, onWebViewError);
		}
		
		private function showWebViewIOS(rect:Rectangle):Boolean {
			return DCCExt.call(new DCCExtCommand(DCCExtMethod.WEB_VIEW_OPEN,{
				url:data.link,
				instanceID:"webView",
				rect:{
					x:rect.x,
					y:rect.y,
					width:rect.width,
					height:rect.height
				}
			}))
		}
		
		private function locationChange(e:LocationChangeEvent):void {
			
		}
		
		private function locationChanging(e:LocationChangeEvent):void {
			if (e.location != null && e.location.indexOf(NativeExtensionController.open_link_in_browser_mark) != -1) {
				e.preventDefault();
				e.stopPropagation();
				navigateToURL(new URLRequest(e.location));
			}
		}
		
		private function checkLocation(e:Event):void {
			
		}
		
		private function onWebViewError(e:ErrorEvent):void {
			
		}
		
		public function destroyWebView():void {
			if(Config.PLATFORM_APPLE) {
				DCCExt.call(new DCCExtCommand(DCCExtMethod.WEB_VIEW_CLOSE, {
					url: data.link,
					instanceID: "webView"
				}));
			}
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