package com.dukascopy.connect.gui.components.slideSelector 
{
	import assets.IconArrowWhiteLeft;
	import assets.IconArrowWhiteRight;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.selector.ISelectorItem;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SlideSelector extends Sprite
	{
		private var items:Vector.<SlideSelectorItemData>;
		private var componentWidth:int;
		private var componentHeight:int;
		private var currentImage:Bitmap;
		private var nextImage:Bitmap;
		private var prewButton:BitmapButton;
		private var nextButton:BitmapButton;
		private var currentItemIndex:Number;
		private var locked:Boolean;
		
		public function SlideSelector() 
		{
			
		}
		
		public function setData(items:Vector.<SlideSelectorItemData>, componentWidth:int, componentHeight:int):void
		{
			this.items = items;
			this.componentWidth = componentWidth;
			this.componentHeight = componentHeight;
			
			clean();
			
			construct();
		}
		
		private function construct():void 
		{
			if (prewButton == null)
			{
				prewButton = new BitmapButton();
				prewButton.setStandartButtonParams();
				prewButton.setDownScale(1);
				prewButton.setDownColor(0);
				prewButton.setOverflow(Config.FINGER_SIZE*.5, Config.FINGER_SIZE*.5, Config.FINGER_SIZE*.5, Config.FINGER_SIZE*.5);
				prewButton.tapCallback = prewClick;
				prewButton.disposeBitmapOnDestroy = true;
				addChild(prewButton);
				
				var icon:Sprite = new IconArrowWhiteLeft();
				UI.colorize(icon, 0xBFCBD5);
				var iconSize:int = Config.FINGER_SIZE * .8;
				UI.scaleToFit(icon, iconSize, iconSize);
				prewButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "SlideSelector.prewButton"));
				
				
			}
			if (nextButton == null)
			{
				nextButton = new BitmapButton();
				nextButton.setStandartButtonParams();
				nextButton.setDownScale(1);
				nextButton.setDownColor(0);
				nextButton.setOverflow(Config.FINGER_SIZE*.5, Config.FINGER_SIZE*.5, Config.FINGER_SIZE*.5, Config.FINGER_SIZE*.5);
				nextButton.tapCallback = nextClick;
				nextButton.disposeBitmapOnDestroy = true;
				addChild(nextButton);
				
				icon = new IconArrowWhiteRight();
				UI.colorize(icon, 0xBFCBD5);
				UI.scaleToFit(icon, iconSize, iconSize);
				nextButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "SlideSelector.nextButton"));
				
				prewButton.x = 0;
				prewButton.y = int(componentHeight * .5 - prewButton.height * .5);
				
				nextButton.x = int(componentWidth - nextButton.width);
				nextButton.y = int(componentHeight * .5 - nextButton.height * .5);
			}
			
			currentImage = new Bitmap();
			addChild(currentImage);
			
			nextImage = new Bitmap();
			addChild(nextImage);
			
			currentItemIndex = 0;
			drawItem();
		}
		
		private function drawItem(direction:int = 1, time:Number = 0.3):void 
		{
			var imageClass:Class = items[currentItemIndex].data.getImageRaw();
			if (imageClass != null)
			{
				var clip:Sprite;
				try
				{
					clip = new imageClass();
				}
				catch (e:Error)
				{
					ApplicationErrors.add();
				}
				if (clip != null)
				{
					UI.scaleToFit(clip, componentWidth - prewButton.width - nextButton.width - Config.DIALOG_MARGIN * 4, componentHeight);
					if (currentImage.bitmapData == null)
					{
						currentImage.bitmapData = UI.getSnapshot(clip, StageQuality.HIGH, "SlideSelector.item");
						currentImage.x = int(componentWidth * .5 - currentImage.width * .5);
						currentImage.y = int(componentHeight * .5 - currentImage.height * .5);
						currentImage.alpha = 1;
					}
					else
					{
						nextImage.bitmapData = UI.getSnapshot(clip, StageQuality.HIGH, "SlideSelector.item");
						nextImage.x = int(componentWidth * .5 - nextImage.width * .5) + Config.FINGER_SIZE * direction;
						nextImage.y = int(componentHeight * .5 - nextImage.height * .5);
						nextImage.alpha = 0;
						
						locked = true;
						TweenMax.to(nextImage, time, {alpha:1, x:int(componentWidth * .5 - nextImage.width * .5)});
						TweenMax.to(currentImage, time, {alpha:0, onComplete:imageSwapped});
					}
				}
			}
		}
		
		private function imageSwapped():void 
		{
			if (currentImage.bitmapData != null)
			{
				currentImage.bitmapData.dispose();
				currentImage.bitmapData = null;
			}
			var image:Bitmap = currentImage;
			currentImage = nextImage;
			nextImage = image;
			locked = false;
		}
		
		private function prewClick():void 
		{
			if (locked == true)
			{
				return;
			}
			
			currentItemIndex --;
			if (currentItemIndex < 0)
			{
				currentItemIndex = items.length - 1;
			}
			drawItem(-1);
		}
		
		private function nextClick():void 
		{
			if (locked == true)
			{
				return;
			}
			
			currentItemIndex ++;
			if (currentItemIndex >= items.length)
			{
				currentItemIndex = 0;
			}
			drawItem(1);
		}
		
		private function clean():void 
		{
			if (currentImage != null)
			{
				UI.destroy(currentImage);
				currentImage = null;
			}
			if (nextImage != null)
			{
				UI.destroy(nextImage);
				nextImage = null;
			}
		}
		
		public function activate():void
		{
			nextButton.activate();
			prewButton.activate();
		}
		
		public function deactivate():void
		{
			nextButton.deactivate();
			prewButton.deactivate();
		}
		
		public function dispose():void
		{
			clean();
			
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (prewButton != null)
			{
				prewButton.dispose();
				prewButton = null;
			}
			
			items = null;
		}
		
		public function refresh():void 
		{
			
		}
		
		public function getSelected():SlideSelectorItemData 
		{
			return items[currentItemIndex];
		}
		
		public function getSelectedIndex():int 
		{
			return currentItemIndex;
		}
		
		public function select(index:int):void 
		{
			if (index != -1)
			{
				currentItemIndex = index;
				drawItem(1, 0);
			}
		}
	}
}