package com.dukascopy.connect.screens.serviceScreen {
	
	import assets.NewCloseIcon;

	import avmplus.finish;

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.dccext.DCCExt;
	import com.dukascopy.dccext.wkWebKit.WKWebKit;
	import com.dukascopy.dccext.DCCExtCommand;
	import com.dukascopy.dccext.DCCExtMethod;
	import com.dukascopy.dccext.wkWebKit.WKWebKit;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class WebViewReactionPopup extends BaseScreen {
		
		private var webView:StageWebView;
		private var closeButton:BitmapButton;
		private var padding:int;
		private var wkWebKit:WKWebKit;

		public function WebViewReactionPopup() {}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			closeButton.x = int(_width - padding - closeButton.width);
			closeButton.y = padding;
			
			view.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			view.graphics.drawRect(0, 0, _width,  _height);
			view.graphics.endFill();
		}
		
		override protected function createView():void {
			super.createView();
			
			padding = Config.FINGER_SIZE * .2;
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.setDownColor(NaN);
			closeButton.setDownScale(0.7);
			closeButton.setOverlay(HitZoneType.CIRCLE);
			closeButton.cancelOnVerticalMovement = true;
			closeButton.tapCallback = onButtonCloseClick;
			closeButton.setOverflow(Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			closeButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			view.addChild(closeButton);
			
			var icon:NewCloseIcon = new NewCloseIcon();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .3), int(Config.FINGER_SIZE * .3));
			closeButton.setBitmapData(UI.getSnapshot(UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS))));
			UI.destroy(icon);
		}
		
		private function onButtonCloseClick():void {
			fireCallback(false, null);
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			closeButton.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			
			closeButton.deactivate();
		}
		
		override protected function drawView():void {
			
		}
		
		override public function isModal():Boolean {
			return true;
		}
		
		override public function dispose():void {
			super.dispose();
			destroyWebView();
			if (closeButton != null)
				closeButton.dispose();
			closeButton = null;
		}
		
		public function onShowComplete():void {


			var tempRect:Rectangle = new Rectangle()
			var point:Point = new Point(view.x, view.y);
			point = view.localToGlobal(point);
			tempRect.x = point.x;
			tempRect.y = point.y + closeButton.y + closeButton.height + padding;
			tempRect.width = _width;
			tempRect.height = _height - closeButton.y - closeButton.height - padding;


			if(Config.PLATFORM_APPLE){
				wkWebKit=WKWebKit.getInstance();
				wkWebKit.onComplete=function (url:String):void{
					if(url!=data.link)
						fireCallback(true,url);
				}
				wkWebKit.show(tempRect,data.link);
				return;
			}


			webView = new StageWebView();
			webView.viewPort = tempRect;
			webView.stage = MobileGui.stage;
			/*webView.viewPort = tempRect;
			webView.stage = MobileGui.stage;*/
			webView.loadURL(data.link);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, locationChange);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, locationChanging);
			webView.addEventListener(ErrorEvent.ERROR, onWebViewError);
		}
		
		private function locationChange(e:LocationChangeEvent):void {
			locationChanging(e);
		}
		
		private function locationChanging(e:LocationChangeEvent):void {
			if (checkLocation(e.location)) {
				e.preventDefault();
				e.stopPropagation();
				
				fireCallback(true, e.location);
			}
		}
		
		private function fireCallback(result:Boolean, url:String):void 
		{
			if (data != null && data.callback != null && data.callback is Function && (data.callback as Function).length == 2)
			{
				(data.callback as Function)(result, url);
			}
			close();
		}
		
		private function close():void 
		{
			if (manager == DialogManager){
				DialogManager.closeDialog();
			}else if(manager == ServiceScreenManager){
				ServiceScreenManager.closeView();
			}else{
				ServiceScreenManager.closeView();
			}
		}
		
		private function checkLocation(url:String):Boolean {
			if (data != null && data.action != null && url != null && url.indexOf(data.action) != -1)
			{
				return true;
			}
			return false;
		}
		
		private function onWebViewError(e:ErrorEvent):void {
			
		}
		
		public function destroyWebView():void {

			if(Config.PLATFORM_APPLE){
				if(wkWebKit!=null)
					wkWebKit.close();
				wkWebKit=null;
			}

			if(webView==null)
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