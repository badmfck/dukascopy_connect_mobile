package com.dukascopy.connect.screens.payments {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.payments.PayNews;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.PaymentsNewsVO;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PaymentsNewsScreen extends BaseScreen {
		
		private var bg:Shape;
		private var topBar:TopBarScreen;
		private var webView:StageWebView;
		
		protected var okButton:BitmapButton;
		protected var cancelButton:BitmapButton;
		
		private var confirmed:Boolean = false;
		
		public function PaymentsNewsScreen() {
			super();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(Lang.TEXT_BANK_NEWS, true);
			confirmed = false;
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
			if (okButton != null)
				okButton.dispose();
			okButton = null;
			if (cancelButton != null)
				cancelButton.dispose();
			cancelButton = null;
			destroyWebView();
		}
		
		public function onShowComplete():void {
			var currentNews:PaymentsNewsVO = PayNews.getCurrentNews();
			if (currentNews == null)
				return;
			if (currentNews.isRequiredConfirmation == true) {
				initOkButton();
				initCancelButton();
			}
			webView = new StageWebView();
			var webViewRect:Rectangle = new Rectangle();
			webViewRect.x = 0
			webViewRect.y = topBar.trueHeight;
			webViewRect.width = MobileGui.stage.stageWidth;
			var resHeight:int = MobileGui.stage.stageHeight - webViewRect.y
			if (currentNews.isRequiredConfirmation == true)
				resHeight -= Config.FINGER_SIZE;
			if (resHeight < 2)
				resHeight = 2;
			webViewRect.height = resHeight;
			webView.viewPort = webViewRect;
			webView.stage = MobileGui.stage;
			var convertedHtmlString:String = removeQuotationsFromString(currentNews.htmlString);
			webView.loadString(TextUtils.getHTMLTemplate(convertedHtmlString));
		}
		
		private function removeQuotationsFromString(string:String):String {
			var regExp:RegExp = /"/g;
			var res:String = string.replace(regExp, "'");
			return res;
		}
		
		private function initOkButton():void {
			var bitmap:BitmapData = UI.renderButton(
				Lang.textAccept.toUpperCase(),
				int(MobileGui.stage.stageWidth / 2),
				Config.FINGER_SIZE,
				AppTheme.WHITE,
				AppTheme.RED_MEDIUM,
				AppTheme.RED_DARK,
				0
			);
			okButton = new BitmapButton();
			okButton.setDownScale(1);
			okButton.setBitmapData(bitmap, true);
			okButton.tapCallback = onOkButtonClick;
			okButton.x = 0
			okButton.y = MobileGui.stage.stageHeight - Config.FINGER_SIZE;
			okButton.show();
			okButton.activate();
			_view.addChild(okButton);
		}
		
		private function initCancelButton():void {
			var bitmap:BitmapData = UI.renderButton(
				Lang.textCancel.toUpperCase(),
				MobileGui.stage.stageWidth - okButton.width,
				Config.FINGER_SIZE,
				AppTheme.WHITE,
				AppTheme.RED_MEDIUM,
				AppTheme.RED_DARK,
				0
			);
			cancelButton = new BitmapButton();
			cancelButton.setDownScale(1);
			cancelButton.setBitmapData(bitmap, true);
			cancelButton.tapCallback = onCancelButtonClick;
			cancelButton.x = okButton.width;
			cancelButton.y = MobileGui.stage.stageHeight - Config.FINGER_SIZE;
			cancelButton.show();
			cancelButton.activate();
			_view.addChild(cancelButton);
		}
		
		private function onOkButtonClick():void {
			confirmed = true;
			onBack();
		}
		
		private function onCancelButtonClick():void {
			onBack();
		}
		
		public function destroyWebView():void {
			if (webView == null)
				return;
			webView.stage = null;
			webView.viewPort = null;
			webView.dispose();
			webView = null;
		}
		
		override public function onBack(e:Event = null):void {
			var currentNews:PaymentsNewsVO = PayNews.getCurrentNews();
			if (currentNews == null) {
				super.onBack();
				return;
			}
			if (currentNews.isRequiredConfirmation == true && confirmed == false) {
				if (data.callback != null)
					data.callback(0);
				MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			if (data.callback != null)
				data.callback(1);
			super.onBack();
		}
	}
}