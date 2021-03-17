package com.dukascopy.connect.screens.dialogs {
	
	import assets.CloseButtonIcon;
	import assets.CloseButtonIconWhite;
	import assets.IconDone;
	import assets.SecureIcon;
	import assets.SecureImage;
	import com.adobe.utils.IntUtil;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.input.InputWithClearButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.StrenghtIndicator;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.pool.Pool;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.PlatformDependingClassFactory;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.easing.Back;
	import com.greensock.easing.Quint;
	import com.telefision.shapes.ShapeBox;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class ScreenVideoSettingsDialog extends BaseScreen {
		
		private var buttonClose:BitmapButton;
		private var message:Bitmap;
		private var title:Bitmap;
		private var callback:Function;


		// quality 
		private var btnHighQuality:BitmapButton;
		private var btnMediumQuality:BitmapButton;
		private var btnLowQuality:BitmapButton;
		private var btnSlideshow:BitmapButton;
		private var underlineBitmap:Bitmap;
		
		public function ScreenVideoSettingsDialog() {
			super();
		}
		
		override protected function createView():void
		{
			super.createView();	
			
			var btnSize:int = Config.FINGER_SIZE*.4;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			// TITLE 
			title = new Bitmap();
			view.addChild(title);
			
			// UNDERLINE
			underlineBitmap = new Bitmap(new ImageBitmapData("ScreenVideoSettingsDialog.underlineBitmap", 1, 2, false, AppTheme.GREY_DARK));
			view.addChild(underlineBitmap);
			
			//CLOSE button;
			buttonClose = new BitmapButton();
			buttonClose.setStandartButtonParams();
			buttonClose.tapCallback = onCloseTap;
			buttonClose.disposeBitmapOnDestroy = true;
			buttonClose.hide();
			view.addChild(buttonClose);			
			var iconClose:CloseButtonIconWhite = new CloseButtonIconWhite();
			var ct:ColorTransform = new ColorTransform();
			ct.color = AppTheme.GREY_MEDIUM;
			iconClose.transform.colorTransform = ct;
			iconClose.width = iconClose.height = btnSize;
			buttonClose.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "ScreenVideoSettingsDialog.closeButton"), true);
			buttonClose.setOverflow(btnOffset, int(btnOffset * .6), Config.FINGER_SIZE, btnOffset);
			UI.destroy(iconClose);
			iconClose = null;			
			ct = null;
			
			// HIFI 
			btnHighQuality = new BitmapButton();
			btnHighQuality.setStandartButtonParams();
			btnHighQuality.tapCallback = onQualitySelect;
			btnHighQuality.callbackParam = CallManager.QUALITY_HIGH;
			btnHighQuality.disposeBitmapOnDestroy = true;
			btnHighQuality.hide();
			view.addChild(btnHighQuality);				
			
			// MEDIUM 
			btnMediumQuality = new BitmapButton();		
			btnMediumQuality.setStandartButtonParams();
			btnMediumQuality.tapCallback = onQualitySelect;
			btnMediumQuality.callbackParam = CallManager.QUALITY_MEDIUM;
			btnMediumQuality.disposeBitmapOnDestroy = true;
			btnMediumQuality.hide();			
			view.addChild(btnMediumQuality);				
			
			// LOW 
			btnLowQuality = new BitmapButton();			
			btnLowQuality.setStandartButtonParams();
			btnLowQuality.tapCallback = onQualitySelect;
			btnLowQuality.callbackParam = CallManager.QUALITY_LOW;
			btnLowQuality.disposeBitmapOnDestroy = true;		
			btnLowQuality.hide();		
			view.addChild(btnLowQuality);		
			
			// SLIDESHOW 
			btnSlideshow = new BitmapButton();			
			btnSlideshow.setStandartButtonParams();
			btnSlideshow.tapCallback = onQualitySelect;
			btnSlideshow.callbackParam = CallManager.QUALITY_FPS;
			btnSlideshow.disposeBitmapOnDestroy = true;		
			btnSlideshow.hide();		
			view.addChild(btnSlideshow);		
			
			
			
		
		}
		
		/**
		 * Init Screen
		 * @param	data
		 */
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			callback = data.callBack;
			
			// title 
			var titleBMD:BitmapData = UI.renderText(Lang.videoQuality, _width, Config.FINGER_SIZE, false, TextFormatAlign.LEFT, TextFieldAutoSize.NONE, Config.FINGER_SIZE * .32, false, AppTheme.GREY_MEDIUM, 0x000000, true);
			title.bitmapData = titleBMD;
			title.y = Config.APPLE_TOP_OFFSET + Config.DOUBLE_MARGIN;// + Config.FINGER_SIZE;
			title.x = Config.DOUBLE_MARGIN;
			
			// underline
			underlineBitmap.x = Config.DOUBLE_MARGIN;
			underlineBitmap.width = _width - Config.DOUBLE_MARGIN * 2;
			underlineBitmap.y = title.y + title.height;
			
			
			var currentlySelected:String = CallManager.currentCameraQuality; // GET CURRENT MODE
			var hiSelected:Boolean = currentlySelected == CallManager.QUALITY_HIGH;
			var midSelected:Boolean = currentlySelected == CallManager.QUALITY_MEDIUM;
			var lowSelected:Boolean = currentlySelected == CallManager.QUALITY_LOW;
			var slideshowSelected:Boolean = currentlySelected == CallManager.QUALITY_FPS; // TODO scheck 
			
			var hiColor:uint = hiSelected?Style.color(Style.COLOR_BUTTON_SECONDARY):Color.RED;
			var hiColorShadow:int = hiColor;
			
			var midColor:uint = midSelected?Style.color(Style.COLOR_BUTTON_SECONDARY):Color.RED;
			var midColorShadow:int = midColor;
			
			var lowColor:uint = lowSelected?Style.color(Style.COLOR_BUTTON_SECONDARY):Color.RED;
			var lowColorShadow:int = lowColor;
			
			var slideshowColor:uint =  slideshowSelected?Style.color(Style.COLOR_BUTTON_SECONDARY):Color.RED;
			var slideshowColorShadow:int = slideshowColor;
			
			// render buttons 
			var HI:BitmapData = UI.renderButton(Lang.btnHigh, _width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, Color.WHITE, hiColor, hiColorShadow, Style.size(Style.SIZE_BUTTON_CORNER));
			var MID:BitmapData = UI.renderButton(Lang.btnMedium , _width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, Color.WHITE, midColor, midColorShadow, Style.size(Style.SIZE_BUTTON_CORNER));
			var LOW:BitmapData = UI.renderButton(Lang.btnLow, _width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, Color.WHITE, lowColor ,lowColorShadow, Style.size(Style.SIZE_BUTTON_CORNER));
			var SLIDESHOW:BitmapData = UI.renderButton(Lang.btnSlideshow, _width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE, Color.WHITE, slideshowColor ,slideshowColorShadow, Style.size(Style.SIZE_BUTTON_CORNER));
			
			btnLowQuality.setBitmapData(LOW, true);
			btnMediumQuality.setBitmapData(MID, true);
			btnHighQuality.setBitmapData(HI,true);		
			btnSlideshow.setBitmapData(SLIDESHOW,true);		
			
			btnLowQuality.show();	
			btnMediumQuality.show();
			btnHighQuality.show();	
			btnSlideshow.show();
			buttonClose.show();
		}
		
		/**
		 * Draw View 
		 */
		override protected function drawView():void {
			// CLOSE 
			buttonClose.x = _width - Config.DOUBLE_MARGIN - buttonClose.width;
			buttonClose.y =  Config.APPLE_TOP_OFFSET +Config.DOUBLE_MARGIN;
			
			// TITLE 
			title.y = Config.APPLE_TOP_OFFSET + Config.DOUBLE_MARGIN;// + Config.FINGER_SIZE;
			title.x = Config.DOUBLE_MARGIN;
		
			// UNDERLINE
			underlineBitmap.x = Config.DOUBLE_MARGIN;
			underlineBitmap.width = _width - Config.DOUBLE_MARGIN * 2;
			underlineBitmap.y = title.y + title.height;
			
			// BUTTONS REDRAW
			btnHighQuality.y = underlineBitmap.y+underlineBitmap.height+ Config.DOUBLE_MARGIN*2;
			btnMediumQuality.y = btnHighQuality.y+btnHighQuality.height+Config.MARGIN;
			btnLowQuality.y =  btnMediumQuality.y + btnMediumQuality.height+Config.MARGIN;			
			btnSlideshow.y =  btnLowQuality.y + btnLowQuality.height + Config.MARGIN;	
			
			btnHighQuality.x = Config.DOUBLE_MARGIN;
			btnMediumQuality.x = Config.DOUBLE_MARGIN;
			btnLowQuality.x =  Config.DOUBLE_MARGIN;		
			btnSlideshow.x =  Config.DOUBLE_MARGIN;		
			
		}
		
	
		
		/**
		 * On Button click 
		 * @param	param
		 */
		private function onQualitySelect(param:String):void	{
			CallManager.changeQuality(param);
			callBack();
		}
		
		/**
		 * Close Clicked
		 */
		private function onCloseTap():void {
			callBack();
			
		}
		
		private function callBack(e:Event=null):void {
			DialogManager.closeDialog();
		}
		
		override public function activateScreen():void {
			super.activateScreen();	
			
			var currentlySelected:String = CallManager.currentCameraQuality // TODO ger current mode
			
			var hiSelected:Boolean = currentlySelected == CallManager.QUALITY_HIGH;
			var midSelected:Boolean = currentlySelected == CallManager.QUALITY_MEDIUM;
			var lowSelected:Boolean = currentlySelected == CallManager.QUALITY_LOW;
			var slideshowSelected:Boolean = currentlySelected == CallManager.QUALITY_FPS;
			
			if (!hiSelected)
				btnHighQuality.activate();	
				
			if (!midSelected)
				btnMediumQuality.activate();
				
			if (!lowSelected)
				btnLowQuality.activate();	
				
			if (!slideshowSelected)
				btnSlideshow.activate();	
				
				
			buttonClose.activate();				
			
		}
		
		override public function deactivateScreen():void {
			if (isDisposed) return;
			super.deactivateScreen();
			buttonClose.deactivate();
			btnLowQuality.deactivate();
			btnMediumQuality.deactivate();
			btnHighQuality.deactivate();			
			btnSlideshow.deactivate();			
		}
		
		private function close():void 	{
			if (isDisposed) return;
			DialogManager.closeDialog();
		}		
		
		override public function dispose():void {
			if (isDisposed) return;
			super.dispose();
			
			if (buttonClose)
				buttonClose.dispose();
			buttonClose = null;
			
			if (btnLowQuality)
				btnLowQuality.dispose();
			btnLowQuality = null;
			
			if (btnMediumQuality)
				btnMediumQuality.dispose();
			btnMediumQuality = null;
			
			if (btnHighQuality)
				btnHighQuality.dispose();
			btnHighQuality = null;
			
			if (btnSlideshow)
				btnSlideshow.dispose();
			btnSlideshow = null;
			
			UI.destroy(underlineBitmap);
			underlineBitmap = null;
		
			callback = null;
			
			if (title)
				UI.destroy(title);
			title = null;
		
			
		}
	}
}