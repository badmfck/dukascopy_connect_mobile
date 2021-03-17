package com.dukascopy.connect.screens.support {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.screens.MainScreen;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.swiper.Swiper;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class SupportScreen extends BaseScreen {
		
		private var btnBack:Sprite;
		private var bg:Sprite;
		private var boxTop:Sprite;
		private var boxTopBG:Bitmap;
		private var topTF:TextField;
		private var topHeight:int;
		
		private var content:Shape;
		private var contentTF:TextField;
		
		private var swiper:Swiper;
		
		public function SupportScreen() {
			
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
		}
		
		override protected function createView():void {
			super.createView();
			
			bg = new Sprite();
			bg.graphics.beginFill(0xF5F5F5);
			bg.graphics.drawRect(0, 0, 11, 11);
			_view.addChild(bg);
			
			topHeight = Config.FINGER_SIZE * 1.5;
			var topBarBtnSize:int = Config.FINGER_SIZE * .5;
			
			boxTop = new Sprite();
			_view.addChild(boxTop);
			
			boxTopBG = new Bitmap(Assets.getAsset(Assets.BG_SEARCH));
			boxTop.addChild(boxTopBG);
			
			btnBack = new Sprite();
			ImageManager.drawGraphicImage(btnBack.graphics, 0, 0, topBarBtnSize, topBarBtnSize, Assets.getAsset(Assets.ICON_LEFT, 0xFFFFFF), ImageManager.SCALE_INNER_PROP);
			btnBack.x = Config.DOUBLE_MARGIN;
			btnBack.y = Config.APPLE_TOP_OFFSET + Math.round((Config.FINGER_SIZE - topBarBtnSize) * .5);
			boxTop.addChild(btnBack);
			
			var tf:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .38, 0xFFFFFF, null, true, null, null, null, TextFormatAlign.CENTER);
			topTF = new TextField();
			topTF.defaultTextFormat = tf;
			topTF.text = Lang.dukascopySupport;//"Dukascopy support ";
			topTF.height = topTF.textHeight + 4;
			topTF.x = Config.DOUBLE_MARGIN * 2 + topBarBtnSize;
			topTF.y = Config.APPLE_TOP_OFFSET + int((Config.FINGER_SIZE - topTF.height) * .5);
			//topTF.border = true;
			topTF.multiline = false;
			topTF.wordWrap = false;
			boxTop.addChild(topTF);
			
			content = new Shape();
			ImageManager.drawGraphicCircleImage(content.graphics, Config.FINGER_SIZE, Config.FINGER_SIZE, Config.FINGER_SIZE, Assets.getAsset(Assets.ICON_SUPPORT), ImageManager.SCALE_PORPORTIONAL);
			tf.color = 0x999999;
			tf.italic = false;
			contentTF = new TextField();
			contentTF.defaultTextFormat = tf;
			contentTF.text = Lang.notAvailableInCountry;//"Not available in your\ncountry yet.";
			contentTF.multiline = true;
			contentTF.wordWrap = true;
			contentTF.x = Config.DOUBLE_MARGIN;
			view.addChild(content);
			view.addChild(contentTF);
			swiper = new Swiper("SupportScreen");
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			PointerManager.addTap(btnBack, onBtnBack);
			swiper.activate();
			swiper.S_ON_SWIPE.add(onSwipe);
		}
		
		private function onSwipe(direction:String):void {
			if (direction == Swiper.DIRECTION_RIGHT)
				MobileGui.changeMainScreen(MainScreen, null, 1);
		}
		
		override public function deactivateScreen():void {

			super.deactivateScreen();
			swiper.deactivate();
			swiper.S_ON_SWIPE.remove(onSwipe);
			PointerManager.removeTap(btnBack, onBtnBack);
		}
		
		private function onBtnBack(e:Event = null):void {
			MobileGui.changeMainScreen(MainScreen, null, 1);
		}
		
		
		override protected function drawView():void {
			bg.width = _width;
			bg.height = _height;
			
			ImageManager.resizeBitmap(boxTopBG, _width, topHeight, ImageManager.SCALE_PORPORTIONAL);
			boxTopBG.y = topHeight - boxTopBG.height;
			topTF.width = _width - topTF.x * 2;
			
			contentTF.width = _width - contentTF.x * 2;
			contentTF.height = contentTF.textHeight + 4;
			
			content.x = int((_width - content.width) * .5);
			content.y = int((_height - topHeight - (content.height + contentTF.height + Config.DOUBLE_MARGIN)) * .5) + topHeight;
			contentTF.y = content.y + content.height + Config.DOUBLE_MARGIN;
		}
		
		override public function dispose():void {
		
			super.dispose();
			if (btnBack != null)
				btnBack.graphics.clear();
			btnBack = null;
			if (bg != null)
				bg.graphics.clear();
			bg = null;
			if (boxTop != null)
				boxTop.graphics.clear();
			boxTop = null;
			if (topTF != null)
				topTF.text = "";
			topTF = null;
			if (boxTopBG != null && boxTopBG.bitmapData != null) {
				boxTopBG.bitmapData.dispose();
				boxTopBG.bitmapData = null;
			}
			boxTopBG = null;
			if (content != null)
				content.graphics.clear();
			content = null;
			if (swiper != null)
				swiper.dispose();
			swiper = null;
		}
	}
}