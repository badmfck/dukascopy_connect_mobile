package com.dukascopy.connect.screens.gifts
{
	
	import assets.GiftTutorial_1;
	import assets.GiftTutorial_2;
	import assets.GiftTutorial_3;
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.PageSelector;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.*;
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class GiftsTutorialScreen extends BaseScreen
	{
		static public const PAGE_1:String = "page1";
		static public const PAGE_2:String = "page2";
		static public const PAGE_3:String = "page3";
		
		private var background:Sprite;
		private var skipButton:BitmapButton;
		private var pageSelector:PageSelector;
		private var locked:Boolean = false;
		private var nextButton:BitmapButton;
		private var sidePadding:Number;
		private var currentPage:String;
		private var page1:Sprite;
		private var page2:Sprite;
		private var page3:Sprite;
		
		private var title_1:Bitmap;
		private var title_2:Bitmap;
		private var title_3:Bitmap;
		
		private var text_1:Bitmap;
		private var text_2:Bitmap;
		private var text_3:Bitmap;
		
		private var image_1:Bitmap;
		private var image_2:Bitmap;
		private var image_3:Bitmap;
		private var currentPageClip:Sprite;
		
		public function GiftsTutorialScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height);
			
			var pages:Vector.<String> = new Vector.<String>();
			pages.push(PAGE_1);
			pages.push(PAGE_2);
			pages.push(PAGE_3);
			pageSelector.setData(pages);
			
			sidePadding = Config.FINGER_SIZE * 0.6;
			var buttonWidth:int = (_width - sidePadding * 3)/2;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.skip, 0, Config.FINGER_SIZE * .36, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x81CA2E, 0, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			skipButton.setBitmapData(buttonBitmap);
			
			textSettings = new TextFieldSettings(Lang.textNext, 0xFFFFFF, Config.FINGER_SIZE * .36, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			nextButton.setBitmapData(buttonBitmap);
			
			skipButton.x = sidePadding;
			nextButton.x = sidePadding * 2 + buttonWidth;
			
			skipButton.y = int(_height - sidePadding - skipButton.height);
			nextButton.y = int(_height - sidePadding - skipButton.height);
			
			pageSelector.y = int(nextButton.y - sidePadding*.8 - pageSelector.height);
			pageSelector.x = int(_width * .5 - pageSelector.width * .5);
			
			createPage1();
			createPage2();
			createPage3();
			
			currentPageClip = page1;
			currentPage = PAGE_1;
		}
		
		private function createPage3():void 
		{
			title_3.bitmapData = TextUtils.createTextFieldData(
																	Lang.giftsTitleStep3, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .42, 
																	true, 0x3B4453, 0xFFFFFF);
			
			text_3.bitmapData = TextUtils.createTextFieldData(
																	Lang.giftsTextStep3, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .3, 
																	true, 0x94A2AD, 0xFFFFFF);
			
			var imageHeight:int = pageSelector.y - Config.FINGER_SIZE*1.6 - title_3.height - text_3.height - Config.FINGER_SIZE * 1.5;
			
			
			
			var image:GiftTutorial_3 = new GiftTutorial_3();
			UI.scaleToFit(image, imageHeight, imageHeight);
			image_3.bitmapData = UI.getSnapshot(image, StageQuality.HIGH, "GiftsTutorialScreen.image_3");
			
			page3.addChild(image_3);
			image_3.x = int(_width*.5 - image_3.width*.5);
			image_3.y = int(Config.FINGER_SIZE*1.3);
			
			page3.addChild(title_3);
			title_3.x = int(_width*.5 - title_3.width*.5);
			title_3.y = int(image_3.y + image_3.height + Config.FINGER_SIZE*.8);
			
			page3.addChild(text_3);
			text_3.x = int(_width*.5 - text_3.width*.5);
			text_3.y = int(title_3.y + title_3.height + Config.FINGER_SIZE * .5);
		}
		
		private function createPage2():void 
		{
			title_2.bitmapData = TextUtils.createTextFieldData(
																	Lang.giftsTitleStep2, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .42, 
																	true, 0x3B4453, 0xFFFFFF);
			
			text_2.bitmapData = TextUtils.createTextFieldData(
																	Lang.giftsTextStep2, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .3, 
																	true, 0x94A2AD, 0xFFFFFF);
			
			var imageHeight:int = pageSelector.y - Config.FINGER_SIZE*1.6 - title_2.height - text_2.height - Config.FINGER_SIZE * 1.5;
			
			
			
			var image:GiftTutorial_2 = new GiftTutorial_2();
			UI.scaleToFit(image, imageHeight, imageHeight);
			image_2.bitmapData = UI.getSnapshot(image, StageQuality.HIGH, "GiftsTutorialScreen.image_2");
			
			page2.addChild(image_2);
			image_2.x = int(_width*.5 - image_2.width*.5);
			image_2.y = int(Config.FINGER_SIZE*1.3);
			
			page2.addChild(title_2);
			title_2.x = int(_width*.5 - title_2.width*.5);
			title_2.y = int(image_2.y + image_2.height + Config.FINGER_SIZE*.8);
			
			page2.addChild(text_2);
			text_2.x = int(_width*.5 - text_2.width*.5);
			text_2.y = int(title_2.y + title_2.height + Config.FINGER_SIZE * .5);
		}
		
		private function createPage1():void 
		{
			title_1.bitmapData = TextUtils.createTextFieldData(
																	Lang.giftsTitleStep1, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .42, 
																	true, 0x3B4453, 0xFFFFFF);
			
			text_1.bitmapData = TextUtils.createTextFieldData(
																	Lang.giftsTextStep1, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .3, 
																	true, 0x94A2AD, 0xFFFFFF);
			
			var imageHeight:int = pageSelector.y - Config.FINGER_SIZE*1.6 - title_1.height - text_1.height - Config.FINGER_SIZE * 1.5;
			
			
			
			var image:GiftTutorial_1 = new GiftTutorial_1();
			UI.scaleToFit(image, imageHeight, imageHeight);
			image_1.bitmapData = UI.getSnapshot(image, StageQuality.HIGH, "GiftsTutorialScreen.image_1");
			
			page1.addChild(image_1);
			image_1.x = int(_width*.5 - image_1.width*.5);
			image_1.y = int(Config.FINGER_SIZE*1.3);
			
			page1.addChild(title_1);
			title_1.x = int(_width*.5 - title_1.width*.5);
			title_1.y = int(image_1.y + image_1.height + Config.FINGER_SIZE*.8);
			
			page1.addChild(text_1);
			text_1.x = int(_width*.5 - text_1.width*.5);
			text_1.y = int(title_1.y + title_1.height + Config.FINGER_SIZE * .5);
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			skipButton = new BitmapButton();
			skipButton.setStandartButtonParams();
			skipButton.setDownScale(1);
			skipButton.setDownColor(0);
			skipButton.tapCallback = skipClick;
			skipButton.disposeBitmapOnDestroy = true;
			view.addChild(skipButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			view.addChild(nextButton);
			
			pageSelector = new PageSelector();
			_view.addChild(pageSelector);
			
			page1 = new Sprite();
			_view.addChild(page1);
			
			page2 = new Sprite();
			_view.addChild(page2);
			
			page3 = new Sprite();
			_view.addChild(page3);
			
			page2.visible = false;
			page3.visible = false;
			
			
			title_1 = new Bitmap();
			title_2 = new Bitmap();
			title_3 = new Bitmap();
			
			text_1 = new Bitmap();
			text_2 = new Bitmap();
			text_3 = new Bitmap();
			
			image_1 = new Bitmap();
			image_2 = new Bitmap();
			image_3 = new Bitmap();
		}
		
		private function nextClick():void 
		{
			if (currentPage == PAGE_1)
			{
				navigateToPage(PAGE_2);
			}
			else if (currentPage == PAGE_2)
			{
				navigateToPage(PAGE_3);
			}
			else if (currentPage == PAGE_3)
			{
				ServiceScreenManager.closeView();
				ChatInputAndroid.S_ATTACH.invoke(ChatInputAndroid.ATTACH_GIFT);
			}
		}
		
		private function navigateToPage(page:String):void 
		{
			currentPage = page;
			var newPageClip:Sprite = getPageClip(currentPage);
			lockScreen();
			
			var hideTime:Number = 0.3;
			
			TweenMax.to(currentPageClip, hideTime, { x: -_width } );
			if (newPageClip != null)
			{
				newPageClip.visible = true;
				newPageClip.x = _width;
				TweenMax.to(newPageClip, hideTime, { x: 0, onComplete:setNewPage } );
			}
			if (currentPage == PAGE_3)
			{
				TweenMax.to(skipButton, hideTime * .5, { alpha:0 } );
				TweenMax.to(nextButton, hideTime * .5, { alpha:0, onComplete:updateButtons } );
				TweenMax.to(nextButton, hideTime * .5, { alpha:1, delay:hideTime * .5} );
			}
		}
		
		private function updateButtons():void 
		{
			if (currentPage == PAGE_3)
			{
				var textSettings:TextFieldSettings = new TextFieldSettings(Lang.praiseNow, 0xFFFFFF, Config.FINGER_SIZE * .36, TextFormatAlign.CENTER);
				var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8, NaN);
				nextButton.setBitmapData(buttonBitmap, true);
				nextButton.x = _width * .5 - nextButton.width * .5;
			}
		}
		
		private function setNewPage():void 
		{
			pageSelector.select(currentPage);
			currentPageClip = getPageClip(currentPage);
			unlockScreen();
		}
		
		public function getPageClip(page:String):Sprite 
		{
			switch(page)
			{
				case PAGE_1:
				{
					return page1;
					break;
				}
				case PAGE_2:
				{
					return page2;
					break;
				}
				case PAGE_3:
				{
					return page3;
					break;
				}
			}
			
			return null;
		}
		
		private function skipClick():void 
		{
			ServiceScreenManager.closeView();
			ChatInputAndroid.S_ATTACH.invoke(ChatInputAndroid.ATTACH_GIFT);
		}
		
		private function lockScreen():void {
			locked = true;
			skipButton.deactivate();
			nextButton.deactivate();
		}
		
		private function unlockScreen():void {
			locked = false;
			skipButton.activate();
			nextButton.activate();
		}
		
		override protected function drawView():void {
			super.drawView();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			TweenMax.killChildTweensOf(currentPageClip);
			TweenMax.killChildTweensOf(skipButton);
			TweenMax.killChildTweensOf(nextButton);;
			
			if (background != null)
			{
				UI.destroy(background);
				background = null;
			}
			if (title_3 != null)
			{
				UI.destroy(title_3);
				title_3 = null;
			}
			if (title_2 != null)
			{
				UI.destroy(title_2);
				title_2 = null;
			}
			if (title_1 != null)
			{
				UI.destroy(title_1);
				title_1 = null;
			}
			if (text_3 != null)
			{
				UI.destroy(text_3);
				text_3 = null;
			}
			if (text_2 != null)
			{
				UI.destroy(text_2);
				text_2 = null;
			}
			if (text_1 != null)
			{
				UI.destroy(text_1);
				text_1 = null;
			}
			if (page3 != null)
			{
				UI.destroy(page3);
				page3 = null;
			}
			if (page2 != null)
			{
				UI.destroy(page2);
				page2 = null;
			}
			if (page1 != null)
			{
				UI.destroy(page1);
				page1 = null;
			}
			if (image_3 != null)
			{
				UI.destroy(image_3);
				image_3 = null;
			}
			if (image_2 != null)
			{
				UI.destroy(image_2);
				image_2 = null;
			}
			if (image_1 != null)
			{
				UI.destroy(image_1);
				image_1 = null;
			}
			if (skipButton != null)
			{
				skipButton.dispose();
				skipButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (pageSelector != null)
			{
				pageSelector.dispose();
				pageSelector = null;
			}
			
			currentPage = null;
			currentPageClip = null;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			if (locked)
			{
				return;
			}
			
			skipButton.activate();
			nextButton.activate();
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed)
			{
				return;
			}
			
			skipButton.deactivate();
			nextButton.deactivate();
		}
	}
}