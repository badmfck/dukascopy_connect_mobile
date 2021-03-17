package com.dukascopy.connect.screens.serviceScreen
{
	
	import assets.PayLogos;
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.tutorial.TutorialData;
	import com.dukascopy.connect.data.tutorial.TutorialStep;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Power1;
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class BankTutorialScreen extends BaseScreen
	{
		private var background:Sprite;
		private var nextButton:BitmapButton;
		private var title:Bitmap;
		private var header:Bitmap;
		private var step:Bitmap;
		private var container:Sprite;
		private var line:Sprite;
		private var screenData:TutorialData;
		private var currentStepIndex:int;
		private var items:Vector.<Sprite>;
		private var itemsBitmap:Vector.<Bitmap>;
		private var icon:Bitmap;
		private var illustration:Bitmap;
		private var backHeight:Number;
		private var firstTime:Boolean;
		private var mainMask:Sprite;
		private var lineMask:Sprite;
		private var content:Sprite;
		private var iconContainer:Sprite;
		private var inAnimation:Boolean;
		private var needClose:Boolean;
		
		public function BankTutorialScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			
			background.graphics.beginFill(0x000000, 0.65);
			background.graphics.drawRect(0, 0, _width, _height);
			
			screenData = createData();
			
			currentStepIndex = 0;
			
			drawCurrentStep();
			
			iconContainer.visible = false;
			container.visible = false;
			line.visible = false;
			nextButton.visible = false;
			background.visible = false;
		}
		
		private function createData():TutorialData 
		{
			var items:Array;
			var i:int;
			
			var result:TutorialData = new TutorialData();
			result.steps = new Vector.<TutorialStep>();
			
			var step1:TutorialStep = new TutorialStep();
			step1.title = Lang.bankTutorialTitleStep1;
			step1.header = Lang.bankTutorialHeaderStep1;
			step1.items = new Vector.<String>();
			if (Lang.bankTutorialItemsStep1 != null)
			{
				items = Lang.bankTutorialItemsStep1.split(",");
				for (i = 0; i < items.length; i++) 
				{
					step1.items.push(items[i]);
				}
			}
			step1.icon = SWFSwissFlagGray;
			result.steps.push(step1);
			
			
			
			var step2:TutorialStep = new TutorialStep();
			step2.title = Lang.bankTutorialTitleStep2;
			step2.header = Lang.bankTutorialHeaderStep2;
			if (Lang.bankTutorialItemsStep2 != null)
			{
				items = Lang.bankTutorialItemsStep2.split(",");
				for (i = 0; i < items.length; i++) 
				{
					step2.items.push(items[i]);
				}
			}
			step2.icon = SWFIconBank;
			result.steps.push(step2);
			
			
			
			var step3:TutorialStep = new TutorialStep();
			step3.title = Lang.bankTutorialTitleStep3;
			step3.header = Lang.bankTutorialHeaderStep3;
			if (Lang.bankTutorialItemsStep3 != null)
			{
				items = Lang.bankTutorialItemsStep3.split(",");
				for (i = 0; i < items.length; i++) 
				{
					step3.items.push(items[i]);
				}
			}
			step3.icon = SWFUpDownArrows;
			result.steps.push(step3);
			
			
			
			var step4:TutorialStep = new TutorialStep();
			step4.title = Lang.bankTutorialTitleStep4;
			step4.items = new Vector.<String>();
			if (Lang.bankTutorialItemsStep4 != null)
			{
				items = Lang.bankTutorialItemsStep4.split(",");
				for (i = 0; i < items.length; i++) 
				{
					step4.items.push(items[i]);
				}
			}
			step4.header = Lang.bankTutorialHeaderStep4;
			step4.icon = SWFSwissFlagGray;
			step4.illustration = PayLogos;
			
			result.steps.push(step4);
			
			return result;
		}
		
		private function drawCurrentStep():void 
		{
			createIllustration();
			createStep();
			createTitle();
			createHeader();
			createContent();
			drawNextButton();
			drawBack();
			createIcon();
		}
		
		private function createIllustration():void 
		{
			if (illustration.bitmapData != null)
			{
				illustration.bitmapData.dispose();
				illustration.bitmapData = null;
			}
			
			if (screenData.steps[currentStepIndex].illustration != null)
			{
				var classIcon:Class = screenData.steps[currentStepIndex].illustration;
				if (classIcon != null)
				{
					var asset:Sprite = new classIcon() as Sprite;
					UI.scaleToFit(asset, _width - Config.DIALOG_MARGIN * 2 - Config.FINGER_SIZE, Config.FINGER_SIZE * 2);
					illustration.bitmapData = UI.getSnapshot(asset);
				}
			}
		}
		
		private function createIcon():void 
		{
			if (icon.bitmapData != null)
			{
				icon.bitmapData.dispose();
				icon.bitmapData = null;
			}
			
			line.removeChildren();
			line.graphics.clear();
			
			if (screenData.steps[currentStepIndex].icon != null)
			{
				var classIcon:Class = screenData.steps[currentStepIndex].icon;
				if (classIcon != null)
				{
					var asset:Sprite = new Sprite();
					asset.graphics.beginFill(0xFFFFFF);
					var r:int = Config.FINGER_SIZE * 0.55;
					asset.graphics.lineStyle(2, 0x849FB8);
					asset.graphics.drawCircle(r + 2, r + 2, r);
					asset.graphics.endFill();
					
					var bd:BitmapData = new BitmapData(asset.width + 1, asset.height + 1, true, 0x00000000);
					bd.draw(asset);
					
					var assetIcon:BitmapData = UI.drawAssetToRoundRect(UI.colorize(new classIcon(), 0x7DA0BB), Config.FINGER_SIZE * .6, true, "BankBotInput.swissIcon");
					bd.copyPixels(assetIcon, assetIcon.rect, new Point(bd.width * .5 - assetIcon.width * .5 + 1, bd.height * .5 - assetIcon.height * .5 + 1), null, new Point(100, 100), true);
					assetIcon.dispose();
					icon.bitmapData = bd;
					
					iconContainer.x = -Config.FINGER_SIZE * .2 + icon.width * .5;
					iconContainer.y = _height - Config.FINGER_SIZE * 2 - icon.height - Config.FINGER_SIZE * .1 + icon.height * .5;
					
					icon.x = -icon.width * .5;
					icon.y = -icon.height * .5;
					
					var triangle:Sprite = new Sprite();
					triangle.graphics.beginFill(0xFFFFFF);
					triangle.graphics.moveTo(-int(Config.FINGER_SIZE*.12), 0);
					triangle.graphics.lineTo(0, int(Config.FINGER_SIZE*.28));
					triangle.graphics.lineTo(int(Config.FINGER_SIZE * .12), 0);
					triangle.graphics.endFill();
					line.addChild(triangle);
					triangle.rotation = 40;
					
					line.y = backHeight;
					line.x = iconContainer.x + icon.width * .5;
					
					triangle.y = _height - icon.height - backHeight - container.y - Config.FINGER_SIZE * .2;
					
					line.graphics.endFill();
					line.graphics.lineStyle(2, 0xFFFFFF);
					line.graphics.moveTo(triangle.x, triangle.y);
					var h:int = (triangle.y);
					line.graphics.curveTo(triangle.x + h * .3, h * .5, triangle.x, 0);
				}
			}
		}
		
		private function drawNextButton():void 
		{
			var buttonText:String;
			if (currentStepIndex < screenData.steps.length - 1)
			{
				buttonText = Lang.BTN_NEXT_STEP.toUpperCase();
			}
			else
			{
				buttonText = Lang.done.toUpperCase();
			}
			
			var textSettings:TextFieldSettings = new TextFieldSettings(buttonText, 0xFFFFFF, Config.FINGER_SIZE * .28, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x48C26A, 1, Config.FINGER_SIZE * .5, NaN, -1);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function createContent():void 
		{
			var hMargin:int = Config.FINGER_SIZE * .5;
			
			clearItems();
			
			if (screenData.steps[currentStepIndex].items != null)
			{
				var bitmap:Bitmap;
				var item:Sprite;
				
				var l:int = screenData.steps[currentStepIndex].items.length;
				
				items = new Vector.<Sprite>();
				itemsBitmap = new Vector.<Bitmap>();
				
				for (var i:int = 0; i < l; i++) 
				{
					item = new Sprite();
					
					bitmap = new Bitmap();
					item.addChild(bitmap);
					bitmap.bitmapData = TextUtils.createTextFieldData(
															screenData.steps[currentStepIndex].items[i], _width - Config.DIALOG_MARGIN * 2 - hMargin * 2 - Config.FINGER_SIZE*.6, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															int(Config.FINGER_SIZE * .28), true, 0x284D63, 0xFFFFFF);
					
					items.push(item);
					itemsBitmap.push(bitmap);
					bitmap.x = int(Config.FINGER_SIZE * .25);
					
					item.graphics.beginFill(0x284D63);
					var radius:int = Config.FINGER_SIZE * .06;
					item.graphics.drawCircle(int(radius * .5), int(Config.FINGER_SIZE * .28 * .5 - Config.FINGER_SIZE * .01), radius);
					
					content.addChild(item);
				}
			}
		}
		
		private function clearItems():void 
		{
			if (items != null && items.length > 0)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					UI.destroy(items[i]);
					if (container != null && container.contains(items[i]))
					{
						content.removeChild(items[i]);
					}
				}
				items = null;
			}
			if (itemsBitmap != null && itemsBitmap.length > 0)
			{
				for (var i2:int = 0; i2 < itemsBitmap.length; i2++) 
				{
					UI.destroy(itemsBitmap[i2]);
				}
				itemsBitmap = null;
			}
		}
		
		private function drawBack():void 
		{
			var hMargin:int = Config.FINGER_SIZE * .5;
			var vMargin:int = Config.FINGER_SIZE * .31;
			var backWidth:int = _width - Config.DIALOG_MARGIN * 2;
			
			var corner:int = Config.FINGER_SIZE * .25;
			
			container.x = Config.DIALOG_MARGIN;
			container.y = Config.FINGER_SIZE * 2;
			
			header.x = hMargin
			header.y = vMargin;
			
			var position:int = header.y + header.height + vMargin * 2;
			
			if (screenData.steps[currentStepIndex].illustration != null)
			{
				illustration.y = position;
				illustration.x = hMargin;
				position += illustration.height + Config.FINGER_SIZE * .3;
			}
			
			step.x = hMargin;
			step.y = position
			
			title.x = int(hMargin + Config.FINGER_SIZE * .5);
			title.y = position;
			
			backHeight = title.height + vMargin * 2 + Config.FINGER_SIZE * .4;
			if (screenData.steps[currentStepIndex].illustration != null)
			{
				backHeight += illustration.height + Config.FINGER_SIZE * .4;
			}
			var titleHeight:int = int(title.y + title.height + Config.FINGER_SIZE * .4);
			if (screenData.steps[currentStepIndex].title == null)
			{
				titleHeight = title.y + Config.FINGER_SIZE * .05;
			}
			if (items != null && items.length > 0)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					if (i == 0)
					{
						items[i].y = titleHeight;
					}
					else
					{
						var difference:int = int(items[i - 1].height + Config.FINGER_SIZE * .2  - Config.FINGER_SIZE * .47);
						if (Math.abs(difference) > Config.FINGER_SIZE * .1)
						{
							items[i].y = int(items[i - 1].y + items[i - 1].height + Config.FINGER_SIZE * .2);
						}
						else
						{
							items[i].y = int(items[i - 1].y + Config.FINGER_SIZE * .47);
						}
						
					}
					items[i].x = int(hMargin + Config.FINGER_SIZE * .5);
					if (screenData.steps[currentStepIndex].title == null)
					{
						items[i].x += int(Config.FINGER_SIZE * .2);
					}
					backHeight += items[i].height + Config.FINGER_SIZE * .2;
				}
			}
			if (items == null || items.length == 0)
			{
				backHeight -= Config.FINGER_SIZE * .3;
			}
			
			if (screenData.steps[currentStepIndex].title == null)
			{
				backHeight -= Config.FINGER_SIZE * .4;
			}
			
			content.graphics.clear();
			content.graphics.beginFill(0x849FB8);
			content.graphics.drawRoundRectComplex(0, 0, backWidth, header.height + vMargin * 2, corner, corner, 0, 0);
			content.graphics.beginFill(0xFFFFFF);
			content.graphics.drawRoundRectComplex(0, header.height + vMargin * 2, backWidth, backHeight, 0, 0, corner, corner);
			
			nextButton.x = int(_width - nextButton.width - Config.DIALOG_MARGIN * 2);
			nextButton.y = int(header.height + vMargin * 2 + backHeight - Config.FINGER_SIZE * .1);
		}
		
		private function createTitle():void 
		{
			var hMargin:int = Config.FINGER_SIZE * .5;
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			if (screenData.steps[currentStepIndex].title != null)
			{
				title.bitmapData = TextUtils.createTextFieldData(
															"<b>" + screenData.steps[currentStepIndex].title + "</b>", _width - Config.DIALOG_MARGIN * 2 - hMargin * 2 - Config.FINGER_SIZE*.6, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															int(Config.FINGER_SIZE * .38), true, 0x284D63, 0xFFFFFF, false, true);
			}
		}
		
		private function createStep():void 
		{
			var hMargin:int = Config.FINGER_SIZE * .5;
			
			if (step.bitmapData != null)
			{
				step.bitmapData.dispose();
				step.bitmapData = null;
			}
			
			step.bitmapData = TextUtils.createTextFieldData(
															"<b>" + (currentStepIndex + 1).toString() + "." + "</b>", _width - Config.DIALOG_MARGIN * 2 - hMargin * 2, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															int(Config.FINGER_SIZE * .38), true, 0x284D63, 0xFFFFFF, false, true);
		}
		
		private function createHeader():void 
		{
			var hMargin:int = Config.FINGER_SIZE * .5;
			
			if (header.bitmapData != null)
			{
				header.bitmapData.dispose();
				header.bitmapData = null;
			}
			
			if (screenData.steps[currentStepIndex].header != null)
			{
				header.bitmapData = TextUtils.createTextFieldData(
															screenData.steps[currentStepIndex].header, _width - Config.DIALOG_MARGIN * 2 - hMargin * 2, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															int(Config.FINGER_SIZE * .29), true, 0xFFFFFF, 0xFFFFFF);
			}
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			container = new Sprite();
			view.addChild(container);
			
			line = new Sprite();
			container.addChild(line);
			
			content = new Sprite();
			container.addChild(content);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			container.addChild(nextButton);
			
			header = new Bitmap();
			content.addChild(header);
			
			title = new Bitmap();
			content.addChild(title);
			
			step = new Bitmap();
			content.addChild(step);
			
			items = new Vector.<Sprite>();
			itemsBitmap = new Vector.<Bitmap>();
			
			iconContainer = new Sprite();
			container.addChild(iconContainer);
			
			icon = new Bitmap();
			iconContainer.addChild(icon);
			
			illustration = new Bitmap();
			content.addChild(illustration);
			
			mainMask = new Sprite();
			view.addChild(mainMask);
			
			lineMask = new Sprite();
			container.addChild(lineMask);
		}
		
		private function nextClick():void 
		{
			if (currentStepIndex < screenData.steps.length - 1)
			{
				currentStepIndex ++;
				hideCurrentState();
			}
			else
			{
				close();
			}
		}
		
		private function hideCurrentState():void 
		{
			inAnimation = true;
			nextButton.deactivate();
			
			TweenMax.to(iconContainer, 0.2, {alpha:0, scaleX:0.3, scaleY:0.3});
			TweenMax.to(lineMask, 0.3, {y:-lineMask.height, delay:0.1});
			TweenMax.to(mainMask, 0.3, {x:_width - Config.DIALOG_MARGIN, delay:0.15});
			TweenMax.to(nextButton, 0.3, {alpha:0, x:nextButton.x + Config.FINGER_SIZE*.2, delay:0.3, onComplete:hideComplete});
		}
		
		private function hideComplete():void 
		{
			inAnimation = false;
			if (needClose == true)
			{
				needClose = false;
				processClose();
			}
			else if (_isDisposed == false && screenData != null && currentStepIndex < screenData.steps.length)
			{
				drawCurrentStep();
				animateFirst();
			}
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			clearItems();
			
			TweenMax.killTweensOf(iconContainer);
			TweenMax.killTweensOf(lineMask);
			TweenMax.killTweensOf(mainMask);
			TweenMax.killTweensOf(nextButton);
			TweenMax.killTweensOf(background);
			
			if (background != null)
			{
				UI.destroy(background);
				background = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				nextButton = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			
			if (header != null)
			{
				UI.destroy(header);
				header = null;
			}
			if (step != null)
			{
				UI.destroy(step);
				step = null;
			}
			if (line != null)
			{
				UI.destroy(line);
				line = null;
			}
			
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			if (mainMask != null)
			{
				UI.destroy(mainMask);
				mainMask = null;
			}
			
			if (iconContainer != null)
			{
				UI.destroy(iconContainer);
				iconContainer = null;
			}
			if (content != null)
			{
				UI.destroy(content);
				content = null;
			}
			if (lineMask != null)
			{
				UI.destroy(lineMask);
				lineMask = null;
			}
			
			screenData = null;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			PointerManager.addTap(background, close);
			
			if (inAnimation == false)
			{
				nextButton.activate();
			}
			
			if (firstTime == false)
			{
				firstTime = true;
				background.alpha = 0;
				animateFirst();
			}
		}
		
		private function animateFirst():void 
		{
			inAnimation = true;
			
			nextButton.deactivate();
			
			background.visible = true;
			
			nextButton.alpha = 0;
			nextButton.visible = true;
			
			nextButton.x -= Config.FINGER_SIZE * .3;
			line.visible = true;
			
			container.visible = true;
			
			TweenMax.to(background, 0.3, {alpha:1});
			
			line.mask = lineMask;
			
			iconContainer.alpha = 0;
			iconContainer.visible = true;
			iconContainer.scaleX = iconContainer.scaleY = 0.5;
			
			TweenMax.to(iconContainer, 0.5, {alpha:1, delay:0.5});
			TweenMax.to(iconContainer, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:0.5});
			
			var maskSize:int = header.height + Config.FINGER_SIZE * .31 * 2 + backHeight;
			content.mask = mainMask;
			mainMask.y = container.y;
			
			mainMask.graphics.clear();
			mainMask.graphics.beginFill(0xFF00FF);
			mainMask.graphics.moveTo(0, 0);
			mainMask.graphics.lineTo(maskSize, maskSize);
			mainMask.graphics.lineTo(maskSize * 2 + _width - Config.DIALOG_MARGIN * 2, maskSize);
			mainMask.graphics.lineTo(maskSize + _width - Config.DIALOG_MARGIN * 2, 0);
			mainMask.graphics.lineTo(0, 0);
			mainMask.graphics.endFill();
			
			mainMask.x = - mainMask.width + Config.DIALOG_MARGIN;
			
			TweenMax.to(mainMask, 0.5, {x: -maskSize + Config.DIALOG_MARGIN, delay:1.3});
			TweenMax.to(nextButton, 0.6, {alpha:1, x:nextButton.x + Config.FINGER_SIZE * .3, delay:1.4, ease:Power1.easeOut, onComplete:showComplete});
			
			lineMask.graphics.clear();
			lineMask.graphics.beginFill(0xFF00FF);
			lineMask.graphics.drawRect(0, 0, line.width + Config.FINGER_SIZE, line.height);
			lineMask.graphics.endFill();
			
			lineMask.x = line.x - Config.FINGER_SIZE * .5;
			lineMask.y = line.y + line.height;
			
			TweenMax.to(lineMask, 0.5, {y:line.y, delay:0.9});
		}
		
		private function showComplete():void 
		{
			inAnimation = false;
			if (needClose == true)
			{
				needClose = false;
				processClose();
			}
			else if (isActivated)
			{
				nextButton.activate();
			}
		}
		
		private function close(e:Event = null):void 
		{
			if (inAnimation)
			{
				needClose = true;
			}
			else
			{
				processClose();
			}
		}
		
		private function processClose():void 
		{
			hideCurrentState();
			deactivateScreen();
			TweenMax.to(background, 0.3, {alpha:0, onComplete:remove});
		}
		
		private function remove():void 
		{
			ServiceScreenManager.closeView();
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			PointerManager.removeTap(background, close);
			
			nextButton.deactivate();
		}
	}
}