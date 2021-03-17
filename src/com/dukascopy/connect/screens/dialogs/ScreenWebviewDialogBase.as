package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.events.StatusEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class ScreenWebviewDialogBase extends BaseScreen {
		
		private var topIBD:ImageBitmapData;
		protected var topBox:Sprite;
		protected var closeBtn:BitmapButton;
		
		private var messageBitmap:Bitmap;
		private var atentionIcon:SWFAttentionIcon;
		private var atentionIconBitmap:Bitmap;
		
		private var tempRect:Rectangle = new Rectangle();
		private var webView:StageWebView;
		private var shown:Boolean = false;
		private var customHeight:int = 0;
		private var realHeight:int = 0;
		
		public function ScreenWebviewDialogBase() { }
		
		override protected function createView():void {
			super.createView();	
			topBox = new Sprite();
			_view.addChild(topBox);
			closeBtn = new BitmapButton();
			closeBtn.setBitmapData(UI.renderAsset(new SWFCloseIconThin(), Config.FINGER_SIZE_DOT_35, Config.FINGER_SIZE_DOT_35, true, "ScreenPayDialog.closeBtn"));
			closeBtn.setOverflow(Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_25);
			closeBtn.setStandartButtonParams();
			_view.addChild(closeBtn);
			closeBtn.show();
			closeBtn.tapCallback = onCloseBtnClick;
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "webViewClose")
			{
				onWebViewClosed(e.level);
			}
			if (e.code == "inputAndroid")
			{
				
				var args:Object;
				try
				{
					args = JSON.parse(e.level);
				}
				catch (e:Error)
				{
					
				}
				
				if (args != null && args.hasOwnProperty("method"))
				{
					switch (args.method)
					{
						case "positionChange": 
						{
							realHeight = args.value;
							updateOnNative();
							break;
						}
					}
				}
			}
		}
		
		private function updateOnNative():void 
		{
			TweenMax.killDelayedCallsTo(drawView);
			TweenMax.delayedCall(0.5, drawView);
		}
		
		private function updatePosition(trueHeight:int):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (webView == null)
			{
				return;
			}
			
			tempRect.x = 0;
			tempRect.y = view.y;
			if (this.view.parent != null && this.view.parent.parent != null) {
				tempRect.y = this.view.parent.parent.y + Config.FINGER_SIZE;
				tempRect.x = this.view.parent.parent.x;
			}
			tempRect.width = _width;
			tempRect.height = trueHeight - Config.FINGER_SIZE;
			webView.viewPort = tempRect;
		}
		
		private function update():void 
		{
			TweenMax.killDelayedCallsTo(drawView);
			TweenMax.delayedCall(0.5, drawView);
		}
		
		override public function isModal():Boolean 
		{
			return true;
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			_params.title = data.label;
			
			SoftKeyboard.S_OPENED.add(update);
			SoftKeyboard.S_CLOSED.add(update);
			if (Config.PLATFORM_ANDROID == true)
			{
				view.visible = false;
				MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
		}
		
		override public function activateScreen():void{
			super.activateScreen();
			if (closeBtn != null)
				closeBtn.activate();
			
			if (!shown)
			{
				shown = true;
				showWebView(data.url);
			}
		}
		
		private function onCloseBtnClick():void {
			DialogManager.closeDialog();
			doCallBack();
		}
		
		private function onDialogClose():void {
			onCloseBtnClick();
		}
		
		protected function doCallBack():void {
			if (webView != null && webView.location != null && _data != null && _data.callback != null && webView.location.indexOf("status=success") != -1)
			{
				var callbackFunction:Function = _data.callback;
				_data.callback = null;
				callbackFunction(true);
			}
			else
			{
				if ( _data.callback != null)
				{
					var callbackFunction2:Function = _data.callback;
					_data.callback = null;
					callbackFunction2(false);
				}
			}
		}
		
		private function showMessage(str:String = ""):void {
			if (str != "") {
				if (messageBitmap == null)
					messageBitmap = new Bitmap();
				if (atentionIconBitmap == null) {
					atentionIconBitmap = new Bitmap();
					atentionIcon ||= new SWFAttentionIcon();
					UI.scaleToFit(atentionIcon, Config.FINGER_SIZE_DOT_5, Config.FINGER_SIZE_DOT_5);
					UI.colorize(atentionIcon, AppTheme.RED_MEDIUM);
					atentionIconBitmap.bitmapData = UI.renderAsset(
						atentionIcon,
						Config.FINGER_SIZE_DOT_5,
						Config.FINGER_SIZE_DOT_5,
						true
					);					
					view.addChild(atentionIconBitmap);
					atentionIcon = null;
				}
				UI.disposeBMD(messageBitmap.bitmapData);
				messageBitmap.bitmapData =  UI.renderTextPlane(
					str, 
					_width-Config.DOUBLE_MARGIN*2,
					Config.FINGER_SIZE_DOT_5,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.LEFT,
					Config.FINGER_SIZE * .3,
					true,
					AppTheme.GREY_DARK,
					0xF4F4F4,
					0xF4F4F4,
					0,
					0,
					0,
					0,
					null,
					false,
					true,
					0
				);
				view.addChild(messageBitmap);
				messageBitmap.x  = (_width - messageBitmap.width) * .5;
				messageBitmap.y  = (_height - messageBitmap.height) * .5;
				atentionIconBitmap.x = (_width - atentionIconBitmap.width) * .5;
				atentionIconBitmap.y = messageBitmap.y - atentionIconBitmap.height - Config.DOUBLE_MARGIN;
			} else {
				if (messageBitmap != null) {
					UI.disposeBMD(messageBitmap.bitmapData);
					if (messageBitmap.parent != null)
						messageBitmap.parent.removeChild(messageBitmap);
				}
			}
		}
		
		private function showWebView(url:String):void{
			
			if (Config.PLATFORM_ANDROID == true){
			//	NativeExtensionController.S_WEB_VIEW_CLOSED.add(onWebViewClosed);
				NativeExtensionController.showWebView(url, _params.title);
				return;
			}

			if(!Config.PLATFORM_ANDROID && !Config.PLATFORM_APPLE){
				navigateToURL(new URLRequest(url));
				return;
			}
			
			if (webView != null)
				return;

			webView ||= new StageWebView();
			tempRect.x = 0;
			tempRect.y = view.y;
			if (this.view.parent != null && this.view.parent.parent != null) {
				tempRect.y = this.view.parent.parent.y + Config.FINGER_SIZE;
				tempRect.x = this.view.parent.parent.x;
			}
			tempRect.width = _width;
			tempRect.height = _height - Config.FINGER_SIZE;
			webView.viewPort = tempRect;
			webView.stage = MobileGui.stage;
			webView.loadURL(url);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, checkLocation);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, checkLocation);
			webView.addEventListener(Event.COMPLETE, checkLocation);
			webView.addEventListener(ErrorEvent.ERROR, onWebViewError);
		}
		
		private function onWebViewClosed(url:String):void{
			if (url != null && _data != null && _data.callback != null && url.indexOf("status=success") != -1)
			{
				var callbackFunction:Function = _data.callback;
				_data.callback = null;
				callbackFunction(true);
			}
			DialogManager.closeDialog();
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
			echo("ScreenWebviewDialogBase", "onWebViewError", "Error: " + e.text);
		}
		
		private function onCancelWebView(e:Event = null):void {
			destroyWebView();
		}
		
		private function checkLocation(e:Event):void {
			var location:String = webView.location;
			/*if (location.indexOf("status=success") > -1) {
				doCallBack(true);
				DialogManager.closeDialog();
				return;
			}*/
		}
		
		override protected function drawView():void {
			if (isDisposed == true)
				return;
			var maxHeight:int = _height;
			if (realHeight > 100)
			{
				maxHeight = realHeight - Config.DOUBLE_MARGIN * 2;
			}
			topBox.graphics.clear();
			
			var tf:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25, AppTheme.GREY_DARK,false);
			if (topIBD != null && topIBD.isDisposed == false)
				topIBD.dispose();
			topIBD = null;
			topIBD = ImageManager.drawTextFieldToGraphic(
				topBox.graphics,
				Config.DOUBLE_MARGIN,
				Config.MARGIN * 2.5,
				_params.title.toLocaleUpperCase(),
				_width - Config.DOUBLE_MARGIN - Config.FINGER_SIZE,
				tf
			);
			topBox.graphics.beginFill(AppTheme.GREY_LIGHT);
			topBox.graphics.drawRect(0, 0, _width, int(topBox.height + Config.FINGER_SIZE*.3));
		//	topBox.graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
		//	topBox.graphics.drawRect(Config.DOUBLE_MARGIN, topBox.height - 2, _width-Config.DOUBLE_MARGIN*2, 2);
			topBox.graphics.endFill();
			topIBD = ImageManager.drawTextFieldToGraphic(
				topBox.graphics,
				Config.DOUBLE_MARGIN,
				int(trueY + (Config.FINGER_SIZE - topIBD.height) * .5),
				_params.title.toLocaleUpperCase(),
				_width - Config.DOUBLE_MARGIN - Config.FINGER_SIZE,
				tf
			);
			tf = null;
			var trueHeight:int = maxHeight;
			var trueY:int = int((maxHeight - trueHeight) * .5)
			view.graphics.clear();
			view.graphics.beginFill(AppTheme.GREY_LIGHT);
			view.graphics.drawRect(0, trueY, _width, trueHeight);
			view.graphics.endFill();
			
			topBox.y = trueY;
			closeBtn.x = int(_width - closeBtn.width - closeBtn.LEFT_OVERFLOW);
			closeBtn.y = int(trueY + (Config.FINGER_SIZE - closeBtn.height) * .5);
			
			updatePosition(trueHeight);
		}
		
		override public function dispose():void
		{
			doCallBack();
			
			NativeExtensionController.S_WEB_VIEW_CLOSED.remove(onWebViewClosed);
			TweenMax.killDelayedCallsTo(drawView);
			
			SoftKeyboard.S_OPENED.remove(update);
			SoftKeyboard.S_CLOSED.remove(update);
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			
			super.dispose();
			destroyWebView();
			topIBD.disposeNow();
			UI.destroy(atentionIconBitmap);
			atentionIconBitmap = null;
			UI.destroy(messageBitmap);
			messageBitmap = null;
			if (closeBtn != null)
				closeBtn.dispose();
			closeBtn = null;
		}
	}
}