package com.dukascopy.connect.screens.dialogs
{
	import assets.PassportIllustration;
	import assets.PassportMrzZoneAnimation;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mrz.MrzBridge;
	import com.dukascopy.connect.sys.mrz.MrzResult;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class InfoStepsPopup extends BaseScreen
	{
		protected var container:Sprite;
		private var bg:Shape;
		private var title:Bitmap;
		private var componentsWidth:Number;
		private var nextButton:BitmapButton;
		private var padding:int;
		private var items:Array;
		private var lines:Array;
		private var stepsImages:Array;
		private var numbers:Array;
		private var scrollPanel:ScrollPanel;
		
		public function InfoStepsPopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			container = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			container.addChild(nextButton);
			
			title = new Bitmap();
			container.addChild(title);
			
			scrollPanel = new ScrollPanel();
			container.addChild(scrollPanel.view);
			
			items = new Array();
			
			_view.addChild(container);
		}
		
		private function nextClick():void
		{
			DialogManager.closeDialog();
		}
		
		private function makePhoto():void 
		{
			
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			var titleText:String = Lang.information;
			var stepsArray:Array = new Array();
			if (data != null && "title" in data && data.title != null)
			{
				titleText = data.title;
			}
			if (data != null && "steps" in data && data.steps != null)
			{
				stepsArray = data.steps as Array;
			}
			
			padding = Config.DIALOG_MARGIN;
			
			componentsWidth = _width - padding * 2;
			
			drawTitle(titleText);
			drawSteps(stepsArray, _width - Config.FINGER_SIZE * 2);
			drawNextButton(Lang.textOk);
			
			var position:int = Config.FINGER_SIZE * .35;
			
			title.x = padding;
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .6;
			
			scrollPanel.view.y = position;
			var scrollItemsPosition:int = 0;
			
			var l:int = stepsImages.length;
			for (var i:int = 0; i < l; i++) 
			{
				stepsImages[i].y = scrollItemsPosition;
				numbers[i].y = int(scrollItemsPosition - Config.FINGER_SIZE * .01);
				numbers[i].x = int(Config.DIALOG_MARGIN);
				stepsImages[i].x = int(Config.FINGER_SIZE * 1.3);
				scrollItemsPosition += stepsImages[i].height + Config.FINGER_SIZE * .3;
				if (l > 1 && i < l - 1)
				{
					lines[i].y = scrollItemsPosition;
					scrollItemsPosition += Config.FINGER_SIZE * .3;
				}
			}
			var maxScrollHeight:int = _height - Config.DIALOG_MARGIN * 2 - nextButton.height - Config.FINGER_SIZE - title.height;
			scrollPanel.setWidthAndHeight(_width, Math.min(scrollPanel.itemsHeight, maxScrollHeight));
			
			position += scrollPanel.height + Config.FINGER_SIZE * .3;
			
			nextButton.y = position;
			position += nextButton.height + Config.FINGER_SIZE * .3;
			
			nextButton.x = int(_width * .5 - nextButton.width * .5);
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = int(_height - position);
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawTitle(text:String, maxWidth:Number = NaN):void
		{
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, true, 0x47515B, 0xFFFFFF, true);
		}
		
		private function drawSteps(steps:Array, maxWidth:Number = NaN):void
		{
			if (steps == null)
			{
				return;
			}
			
			clearSteps();
			clearLines();
			clearNumbers();
			
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			var l:int = steps.length;
			for (var i:int = 0; i < l; i++) 
			{
				drawStep(steps[i], maxTextWidth, i);
			}
			
			if (l > 1)
			{
				for (i = 0; i < l - 1; i++) 
				{
					drawLine();
				}
			}
		}
		
		private function clearNumbers():void 
		{
			if (numbers != null)
			{
				var l:int = numbers.length;
				for (var i:int = 0; i < l; i++) 
				{
					UI.destroy(numbers[i]);
					try
					{
						container.removeChild(numbers[i]);
					}
					catch (e:Error)
					{
						
					}
				}
			}
			
			numbers = new Array();
		}
		
		private function clearLines():void 
		{
			if (lines != null)
			{
				var l:int = lines.length;
				for (var i:int = 0; i < l; i++) 
				{
					UI.destroy(lines[i]);
					try
					{
						container.removeChild(lines[i]);
					}
					catch (e:Error)
					{
						
					}
				}
			}
			
			lines = new Array();
		}
		
		private function drawLine():void 
		{
			var lineImage:Bitmap = new Bitmap();
			lineImage.bitmapData = UI.getHorizontalLine(0xD9E5F0);
			lineImage.width = int(_width - Config.FINGER_SIZE * 1.4);	
			lines.push(lineImage);
			scrollPanel.addObject(lineImage);
			lineImage.height = int(Config.FINGER_SIZE * .03);
			lineImage.x = int(_width * .5 - lineImage.width * .5);
		}
		
		private function drawStep(stepText:String, maxTextWidth:int, index:int):void 
		{
			var stepNumberImage:Bitmap = new Bitmap();
			
			var circle:Sprite = new Sprite();
			circle.graphics.beginFill(0xFF7173);
			var r:int = Config.FINGER_SIZE * .27;
			circle.graphics.drawCircle(r, r, r);
			circle.graphics.endFill();
			stepNumberImage.bitmapData = UI.getSnapshot(circle);
			
			
			var textBD:ImageBitmapData = TextUtils.createTextFieldData(
															(index + 1).toString(), maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, true, 0xFFFFFF, 0xFF7173, true, false);
			
			stepNumberImage.bitmapData.copyPixels(textBD, textBD.rect, new Point(circle.width * .5 - textBD.width * .5, circle.height * .5 - textBD.height * .5), null, null, true);
			numbers.push(stepNumberImage);
			scrollPanel.addObject(stepNumberImage);
			
			var stepImage:Bitmap = new Bitmap();
			stepImage.bitmapData = TextUtils.createTextFieldData(
															stepText, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, true, 0x6B7A8A, 0xFFFFFF, false, true);
			stepsImages.push(stepImage);
			scrollPanel.addObject(stepImage);
			textBD.dispose();
		}
		
		private function clearSteps():void 
		{
			var l:int;
			if (stepsImages != null)
			{
				l = stepsImages.length;
				for (var i:int = 0; i < l; i++) 
				{
					UI.destroy(stepsImages[i]);
					try
					{
						container.removeChild(stepsImages[i]);
					}
					catch (e:Error)
					{
						
					}
				}
			}
			
			stepsImages = new Array();
			
			if (numbers != null)
			{
				l = numbers.length;
				for (var i2:int = 0; i2 < l; i2++) 
				{
					UI.destroy(numbers[i2]);
					try
					{
						container.removeChild(numbers[i2]);
					}
					catch (e:Error)
					{
						
					}
				}
			}
			
			numbers = new Array();
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			scrollPanel.enable();
			nextButton.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			scrollPanel.disable();
			nextButton.deactivate();
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			clearSteps();
			clearLines();
			
			lines = null;
			stepsImages = null;
			
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (scrollPanel != null)
			{
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
		}
	}
}