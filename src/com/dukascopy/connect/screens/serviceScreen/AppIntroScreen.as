package com.dukascopy.connect.screens.serviceScreen
{
	
	import assets.AppIntroBack;
	import assets.AppIntrotextDelimiter;
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.gui.components.animation.IntroAnimation1;
	import com.dukascopy.connect.gui.components.animation.IntroAnimation2;
	import com.dukascopy.connect.gui.components.animation.IntroAnimation3;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.PageSelector;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.*;
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class AppIntroScreen extends BaseScreen
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
		
		private var image_1:IntroAnimation1;
		private var image_2:IntroAnimation2;
		private var image_3:IntroAnimation3;
		private var currentPageClip:Sprite;
		private var back:AppIntroBack;
		private var delimiter_1:AppIntrotextDelimiter;
		private var delimiter_2:AppIntrotextDelimiter;
		private var delimiter_3:AppIntrotextDelimiter;
		private var startPoint:Point;
		private var page2Created:Boolean;
		private var page3Created:Boolean;
		
		public function AppIntroScreen() { }
		
		override public function initScreen(data:Object = null):void {
			if (MobileGui.stage != null){
				MobileGui.stage.quality = StageQuality.HIGH;
			}
			
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height);
			
			var pages:Vector.<String> = new Vector.<String>();
			pages.push(PAGE_1);
			pages.push(PAGE_2);
			pages.push(PAGE_3);
			pageSelector.setData(pages);
			
			sidePadding = Config.FINGER_SIZE;
			var buttonWidth:int = (_width - Config.FINGER_SIZE * 1.5) / 2;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.skip.toUpperCase(), 0, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x81CA2E, 0, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			skipButton.setBitmapData(buttonBitmap);
			
			textSettings = new TextFieldSettings(Lang.textNext.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			nextButton.setBitmapData(buttonBitmap);
			
		//	createBack();
			
			skipButton.x = Config.FINGER_SIZE*.5;
			nextButton.x = _width - Config.FINGER_SIZE * .5 - nextButton.width;
			
			skipButton.y = int(_height - Config.FINGER_SIZE * .5 - skipButton.height - Config.APPLE_BOTTOM_OFFSET);
			nextButton.y = int(_height - Config.FINGER_SIZE * .5 - skipButton.height - Config.APPLE_BOTTOM_OFFSET);
			
			pageSelector.y = int(nextButton.y - Config.FINGER_SIZE*.4 - pageSelector.height);
			pageSelector.x = int(_width * .5 - pageSelector.width * .5);
			
			createPage1();
			
			currentPageClip = page1;
			currentPage = PAGE_1;
		}
		
		private function createBack():void {
			back = new AppIntroBack();
			var k:Number = Math.max(_width / back.width, _height / back.height);
			back.width = back.width * k;
			back.height = back.height * k;
			_view.addChild(back);
			view.setChildIndex(back, 1);
		}
		
		private function createPage3():void 
		{
			if (page3Created == true)
			{
				return;
			}
			page3Created = true;
			
			title_3.bitmapData = TextUtils.createTextFieldData(
																	Lang.appIntroTitle_3, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .44, 
																	true, 0x97AEC4, 0xFFFFFF, true);
			
			text_3.bitmapData = TextUtils.createTextFieldData(
																	Lang.appIntroText_3, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .35, 
																	true, 0x606E7B, 0xFFFFFF, true);
			
			page3.addChild(text_3);
			text_3.x = int(_width * .5 - text_3.width * .5);
			
			page3.addChild(delimiter_3);
			delimiter_3.x = int(_width * .5 - delimiter_3.width * .5);
			delimiter_3.y = int(text_3.y - Config.FINGER_SIZE * .5);
			
			page3.addChild(title_3);
			title_3.x = int(_width * .5 - title_3.width * .5);
			title_3.y = int(_height * .5 + Config.FINGER_SIZE * 0.8);
			
			text_3.y = int(title_3.y + title_3.height + Config.FINGER_SIZE * .35);
			
			var imageHeight:int = title_3.y - Config.FINGER_SIZE * .8;
			
			image_3 = new IntroAnimation3(_width, _height);
			
			page3.addChild(image_3);
			image_3.x = int(0);
			image_3.y = int(0);
		}
		
		private function getLangFrame():int 
		{
			if (LangManager.model.getCurrentLanguageID() == "ru") {
				return 1;
			}
			return 2;
		}
		
		private function createPage2():void 
		{
			if (page2Created == true)
			{
				return;
			}
			page2Created = true;
			
			title_2.bitmapData = TextUtils.createTextFieldData(
																	Lang.appIntroTitle_2, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .44, 
																	true, 0x97AEC4, 0xFFFFFF, true);
			
			text_2.bitmapData = TextUtils.createTextFieldData(
																	Lang.appIntroText_2, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .35, 
																	true, 0x606E7B, 0xFFFFFF, true);
			
			page2.addChild(text_2);
			text_2.x = int(_width*.5 - text_2.width*.5);
			
			page2.addChild(delimiter_2);
			delimiter_2.x = int(_width * .5 - delimiter_2.width * .5);
			delimiter_2.y = int(text_2.y - Config.FINGER_SIZE * .5);
			
			page2.addChild(title_2);
			title_2.x = int(_width*.5 - title_2.width*.5);
			title_2.y = int(_height * .5 + Config.FINGER_SIZE * 0.8);
			
			text_2.y = int(title_2.y + title_2.height + Config.FINGER_SIZE * .35);
			
			var imageHeight:int = title_2.y - Config.FINGER_SIZE * .8;
			
			var image:Sprite = new IntroClip2();
			
			image_2 = new IntroAnimation2(_width, _height);
			page2.addChild(image_2);
			image_2.x = 0;
			image_2.y = int(_height * .5 - image_2.height + Config.FINGER_SIZE * .5);
		}
		
		private function createPage1():void 
		{
			title_1.bitmapData = TextUtils.createTextFieldData(
																	Lang.appIntroTitle_1, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .44, 
																	true, 0x97AEC4, 0xFFFFFF, true);
			
			text_1.bitmapData = TextUtils.createTextFieldData(
																	Lang.appIntroText_1, 
																	_width - sidePadding * 2, 
																	10, true, 
																	TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .35, 
																	true, 0x606E7B, 0xFFFFFF, true);
			
			page1.addChild(text_1);
			text_1.x = int(_width * .5 - text_1.width * .5);
			
			
		//	page1.addChild(delimiter_1);
		//	delimiter_1.x = int(_width * .5 - delimiter_1.width * .5);
		//	delimiter_1.y = int(text_1.y - Config.FINGER_SIZE * .5);
			
			page1.addChild(title_1);
			title_1.x = int(_width * .5 - title_1.width * .5);
			title_1.y = int(_height * .5 + Config.FINGER_SIZE * 0.8);
			
			text_1.y = int(title_1.y + title_1.height + Config.FINGER_SIZE * .35);
			
			var imageHeight:int = title_1.y - Config.FINGER_SIZE * .8;
			
			image_1 = new IntroAnimation1(_width, _height);
			
			page1.addChild(image_1);
			image_1.x = 0;
			image_1.y = int(_height*.5 - image_1.height);
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
			
			pageSelector = new PageSelector(0x8E8E8E, 0xCBCBCB, 1);
			_view.addChild(pageSelector);
			
			page1 = new Sprite();
			_view.addChild(page1);
			
			page2 = new Sprite();
			_view.addChild(page2);
			
			page3 = new Sprite();
			_view.addChild(page3);
			
			page1.mouseChildren = false;
			page1.mouseEnabled = false;
			
			page2.mouseChildren = false;
			page2.mouseEnabled = false;
			
			page3.mouseChildren = false;
			page3.mouseEnabled = false;
			
		//	page2.visible = false;
		//	page3.visible = false;
			
			
			title_1 = new Bitmap();
			title_2 = new Bitmap();
			title_3 = new Bitmap();
			
			text_1 = new Bitmap();
			text_2 = new Bitmap();
			text_3 = new Bitmap();
			
			delimiter_1 = new AppIntrotextDelimiter();
			delimiter_2 = new AppIntrotextDelimiter();
			delimiter_3 = new AppIntrotextDelimiter();
			
			UI.scaleToFit(delimiter_1, Config.FINGER_SIZE, Config.FINGER_SIZE);
			UI.scaleToFit(delimiter_2, Config.FINGER_SIZE, Config.FINGER_SIZE);
			UI.scaleToFit(delimiter_3, Config.FINGER_SIZE, Config.FINGER_SIZE);
		}
		
		private function nextClick():void 
		{
			if (currentPage == PAGE_1)
			{
				createPage2();
				navigateToPage(PAGE_2);
			}
			else if (currentPage == PAGE_2)
			{
				createPage3();
				navigateToPage(PAGE_3);
			}
			else if (currentPage == PAGE_3)
			{
				ServiceScreenManager.closeView();
				ChatInputAndroid.S_ATTACH.invoke(ChatInputAndroid.ATTACH_GIFT);
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FillUserInfoScreen);
				ReferralProgram.promptEnterCode();
			}
		}
		
		private function navigateToPage(page:String):void 
		{
			var nextPage:String = page;
			var newPageClip:Sprite = getPageClip(nextPage);
			lockScreen();
			
			var hideTime:Number = 0.6;
			
		//	TweenMax.to(currentPageClip, hideTime, { x: -_width } );
			if (newPageClip != null)
			{
				newPageClip.x = _width;
				
				if (currentPage == PAGE_1)
				{
					TweenMax.to(newPageClip, hideTime, { x: 0, onComplete:setNewPage, onUpdate:onMoveToPage2 } );
				}
				else if (currentPage == PAGE_2)
				{
					TweenMax.to(newPageClip, hideTime, { x: 0, onComplete:setNewPage, onUpdate:onMoveToPage3 } );
				}
			}
			if (currentPage == PAGE_3)
			{
				
			}
			currentPage = page;
		}
		
		private function updateButtons():void {
			
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			var buttonWidth:int = (_width - Config.FINGER_SIZE * 1.5) / 2;
			
			if (currentPage == PAGE_3) {
				textSettings = new TextFieldSettings(Lang.appIntroStart.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8, NaN);
				nextButton.setBitmapData(buttonBitmap, true);
				TweenMax.to(skipButton, 0.3, {alpha:0});
				TweenMax.to(nextButton, 0.3, {x:(_width * .5 - nextButton.width * .5)});
			}
			else if (currentPage == PAGE_1 || currentPage == PAGE_2)
			{
				textSettings = new TextFieldSettings(Lang.skip.toUpperCase(), 0, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, 0x81CA2E, 0, Config.FINGER_SIZE * .8, NaN, buttonWidth);
				skipButton.setBitmapData(buttonBitmap, true);
				
				textSettings = new TextFieldSettings(Lang.textNext.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8, NaN, buttonWidth);
				nextButton.setBitmapData(buttonBitmap, true);
				
				skipButton.x = Config.FINGER_SIZE*.5;
				TweenMax.to(nextButton, 0.3, {x:(_width - Config.FINGER_SIZE * .5 - nextButton.width)});
				
				TweenMax.to(skipButton, 0.3, {alpha:1});
				TweenMax.to(nextButton, 0.3, {alpha:1});
			}
		}
		
		private function setNewPage():void {
		//	destroyPrewPage();
			if (pageSelector == null)
				return;
			pageSelector.select(currentPage);
			currentPageClip = getPageClip(currentPage);
			unlockScreen();
			
			if (currentPage == PAGE_3)
			{
				TweenMax.to(skipButton, 0.25, { alpha:0 } );
				TweenMax.to(nextButton, 0.25, { alpha:0, onComplete:updateButtons } );
				TweenMax.to(nextButton, 0.25, { alpha:1, delay:0.25} );
			}
		}
		
		private function destroyPrewPage():void {
			/*if (currentPage == PAGE_2) {
				destroyPage1();
			}
			else if (currentPage == PAGE_3) {
				destroyPage2();
			}*/
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
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FillUserInfoScreen);
			ReferralProgram.promptEnterCode();
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
			if (MobileGui.stage != null){
				MobileGui.stage.quality = StageQuality.LOW;
			}
			super.dispose();
			
			TweenMax.killChildTweensOf(currentPageClip);
			TweenMax.killChildTweensOf(skipButton);
			TweenMax.killChildTweensOf(nextButton);
			
			TweenMax.killChildTweensOf(view);
			
			TweenMax.killChildTweensOf(page1);
			TweenMax.killChildTweensOf(page2);
			TweenMax.killChildTweensOf(page3);
			TweenMax.killChildTweensOf(skipButton);
			TweenMax.killChildTweensOf(nextButton);
			
			if (background != null)
			{
				UI.destroy(background);
				background = null;
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
			
			destroyPage1();
			destroyPage2();
			destroyPage3();
			
			currentPage = null;
			currentPageClip = null;
		}
		
		private function destroyPage3():void {
			if (title_3 != null) {
				UI.destroy(title_3);
				title_3 = null;
			}
			
			if (text_3 != null)	{
				UI.destroy(text_3);
				text_3 = null;
			}
			
			if (page3 != null) {
				UI.destroy(page3);
				page3 = null;
			}
			
			if (image_3 != null) {
				image_3.dispose();
				image_3 = null;
			}
			
			if (delimiter_3 != null) {
				UI.destroy(delimiter_3);
				delimiter_3 = null;
			}
		}
		
		private function destroyPage2():void {
			if (title_2 != null) {
				UI.destroy(title_2);
				title_2 = null;
			}
			
			if (text_2 != null)	{
				UI.destroy(text_2);
				text_2 = null;
			}
			
			if (page2 != null) {
				UI.destroy(page2);
				page2 = null;
			}
			
			if (image_2 != null) {
				image_2.dispose();
				image_2 = null;
			}
			
			if (delimiter_2 != null) {
				UI.destroy(delimiter_2);
				delimiter_2 = null;
			}
		}
		
		private function destroyPage1():void {
			if (title_1 != null) {
				UI.destroy(title_1);
				title_1 = null;
			}
			
			if (text_1 != null)	{
				UI.destroy(text_1);
				text_1 = null;
			}
			
			if (page1 != null) {
				UI.destroy(page1);
				page1 = null;
			}
			
			if (image_1 != null) {
				image_1.dispose();
				image_1 = null;
			}
			
			if (delimiter_1 != null) {
				UI.destroy(delimiter_1);
				delimiter_1 = null;
			}
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
			
			PointerManager.removeDown(background, startMove);
			PointerManager.removeUp(background, stopMove);
			PointerManager.removeOut(background, stopMove);
			
			PointerManager.addDown(background, startMove);
			PointerManager.addUp(background, stopMove);
			PointerManager.addOut(background, stopMove);
		}
		
		private function stopMove(e:Event):void 
		{
			PointerManager.removeMove(background, onMove);
			
			lockScreen();
			
			if (currentPage == PAGE_1)
			{
				if (page1.x >= 0)
				{
					moveToPage1();
				}
				else if (page1.x < -_width*.23)
				{
					moveToPage2();
				}
				else
				{
					moveToPage1();
				}
			}
			if (currentPage == PAGE_2)
			{
				if (page2.x >= _width*.23)
				{
					moveToPage1();
				}
				else if (page2.x < -_width*.23)
				{
					moveToPage3();
				}
				else
				{
					moveToPage2();
				}
			}
			if (currentPage == PAGE_3)
			{
				if (page3.x >= _width*.23)
				{
					moveToPage2();
				}
				else if (page3.x < -_width*.23)
				{
					moveToPage3();
				}
				else
				{
					moveToPage3();
				}
			}
		}
		
		private function moveToPage3():void 
		{
			TweenMax.to(page3, 0.3, {x:0, onUpdate:onMoveToPage3, onComplete:onMoveToPage3Complete});
		}
		
		private function onMoveToPage3():void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			page2.x = page3.x - _width;
			
			updatePage2Animation();
			updatePage3Animation();
		}
		
		private function moveToPage2():void 
		{
			TweenMax.to(page2, 0.3, {x:0, onUpdate:onMoveToPage2, onComplete:onMoveToPage2Complete});
		}
		
		private function onMoveToPage1():void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			page2.x = page1.x + _width;
			
			updatePage1Animation();
			updatePage2Animation();
		}
		
		private function onMoveToPage2():void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			page3.x = page2.x + _width;
			page1.x = page2.x - _width;
			
			updatePage1Animation();
			updatePage2Animation();
			updatePage3Animation();
		}
		
		private function moveToPage1():void 
		{
			TweenMax.to(page1, 0.3, {x:0, onUpdate:onMoveToPage1, onComplete:onMoveToPage1Complete});
		}
		
		private function onMoveToPage1Complete():void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			pageSelector.select(PAGE_1);
			currentPage = PAGE_1;
			unlockScreen();
			updateButtons();
		}
		
		private function onMoveToPage3Complete():void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			pageSelector.select(PAGE_3);
			currentPage = PAGE_3;
			unlockScreen();
			updateButtons();
		}
		
		private function onMoveToPage2Complete():void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			pageSelector.select(PAGE_2);
			currentPage = PAGE_2;
			unlockScreen();
			updateButtons();
		}
		
		private function startMove(e:Event):void 
		{
			startPoint = new Point(background.mouseX, background.mouseY);
			PointerManager.addMove(background, onMove);
		}
		
		private function onMove(e:Event):void 
		{
			if (currentPage == PAGE_1)
			{
				createPage2();
				
				page1.x += background.mouseX - startPoint.x;
				startPoint.x = background.mouseX;
				
				page2.x = page1.x + _width;
				
				updatePage1Animation();
				updatePage2Animation();
			}
			
			if (currentPage == PAGE_2)
			{
				createPage3();
				
				page2.x += background.mouseX - startPoint.x;
				startPoint.x = background.mouseX;
				
				page1.x = page2.x - _width;
				page3.x = page2.x + _width;
				
				updatePage1Animation();
				updatePage2Animation();
				updatePage3Animation();
			}
			
			if (currentPage == PAGE_3)
			{
				page3.x += background.mouseX - startPoint.x;
				startPoint.x = background.mouseX;
				
				page2.x = page3.x - _width;
				
				updatePage2Animation();
				updatePage3Animation();
			}
		}
		
		private function updatePage1Animation():void 
		{
			image_1.update(page1.x);
		}
		
		private function updatePage2Animation():void 
		{
			createPage2();
			
			image_2.update(page2.x);
		}
		
		private function updatePage3Animation():void 
		{
			if (image_3 != null)
			{
				image_3.update(page3.x);
			}
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
			
			PointerManager.removeDown(background, startMove);
			PointerManager.removeUp(background, stopMove);
			PointerManager.removeOut(background, stopMove);
		}
	}
}