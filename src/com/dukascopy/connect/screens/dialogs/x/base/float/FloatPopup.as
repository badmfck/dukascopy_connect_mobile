package com.dukascopy.connect.screens.dialogs.x.base.float 
{
	import assets.NewCloseIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.AnimatedTitlePopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Power1;
	import com.greensock.easing.Power2;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FloatPopup extends BaseScreen
	{
		protected var background:Sprite;
		protected var backgroundContent:Sprite;
		protected var container:Sprite;
		private var firstTime:Boolean = true;
		private var needExecute:Boolean;
		private var backAnimation:Object;
		private var showTime:Number = 0.25;
		
		protected var closeButton:BitmapButton;
		protected var contentPadding:int;
		protected var contentPaddingV:int;
		
		protected var scrollPanel:ScrollPanel;
		protected var scrollBottom:Sprite;
		private var scrollUp:Sprite;
		protected var mainPadding:Number;
		private var topColorClip:Sprite;
		private var preloader:CirclePreloader;
		protected var colorDelimiterPosition:int = -1;
		
		protected var topColor:Number = Style.color(Style.COLOR_BACKGROUND);
		protected var bottomColor:Number = Style.color(Style.COLOR_LIST_SPECIAL);
		
		public function FloatPopup() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			
			contentPadding = Config.FINGER_SIZE * .3;
			contentPaddingV = Config.FINGER_SIZE * .26;
			
			background.graphics.beginFill(0x000000, 0.45);
			background.graphics.drawRect(0, 0, _width, _height);
			background.alpha = 0;
			
			closeButton.x = int(getWidth() - contentPadding - closeButton.width);
			closeButton.y = contentPadding;
			
			scrollPanel.view.y = closeButton.y + closeButton.height + Config.FINGER_SIZE * .1;
			
			recreateLayout();
			
			container.alpha = 0;
			backgroundContent.alpha = 0;
		}
		
		protected function recreateLayout():void 
		{
			drawContent();
			
			makePositions();
		}
		
		protected function makePositions():void 
		{
			updateContentPositions();
			updateScroll();
			
			drawBack(getBackHeight());
			
			container.x = mainPadding;
			backgroundContent.x = mainPadding;
			
			var startPosition:int = _height - backgroundContent.height - mainPadding - Config.APPLE_BOTTOM_OFFSET;
			container.y = startPosition;
			backgroundContent.y = startPosition;
		}
		
		protected function drawContent():void 
		{
			// to override;
		}
		
		override protected function createView():void {
			super.createView();
			
			mainPadding = Config.FINGER_SIZE * .17;
			
			background = new Sprite();
			view.addChild(background);
			
			backgroundContent = new Sprite();
			view.addChild(backgroundContent);
			
			container = new Sprite();
			view.addChild(container);
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.setDownColor(NaN);
			closeButton.setDownScale(0.7);
			closeButton.setOverlay(HitZoneType.CIRCLE);
			closeButton.cancelOnVerticalMovement = true;
			closeButton.tapCallback = onButtonCloseClick;
			closeButton.setOverflow(Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			closeButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			container.addChild(closeButton);
			
			var icon:NewCloseIcon = new NewCloseIcon();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .3), int(Config.FINGER_SIZE * .3));
			closeButton.setBitmapData(UI.getSnapshot(UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS))));
			UI.destroy(icon);
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = false;
			scrollPanel.hideScrollBar();
			container.addChild(scrollPanel.view);
			
			scrollBottom = new Sprite();
			scrollBottom.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			scrollBottom.graphics.drawRect(0, 0, 1, 1);
			scrollBottom.graphics.endFill();
			scrollPanel.addObject(scrollBottom);
			
			scrollUp = new Sprite();
			scrollUp.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			scrollUp.graphics.drawRect(0, 0, 1, 1);
			scrollUp.graphics.endFill();
			scrollPanel.addObject(scrollUp);
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
			
			scrollBottom.y = 0;
			updateContentPositions();
			updateBottomScrollClip();
			
			makePositions();
		}
		
		private function updateBottomScrollClip():void 
		{
			scrollBottom.y = 0;
			scrollBottom.y = scrollPanel.itemsHeight - scrollBottom.height;
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			
			showFirstTime();
			
			PointerManager.addTap(background, close);
			closeButton.activate();
			scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			PointerManager.removeTap(background, close);
			closeButton.deactivate();
			scrollPanel.disable();
		}
		
		private function showFirstTime():void 
		{
			if (firstTime) {
				
				firstTime = false;
				showTime = 0.5;
				
				var endPositionBack:int = backgroundContent.y;
				var endPositionContent:int = container.y;
				
				backgroundContent.y = endPositionBack + Config.FINGER_SIZE * 0.6;
				container.y = endPositionContent + Config.FINGER_SIZE * 0.6;
				
				var backEndHeight:int = backgroundContent.height;
				var currentBackHeight:int = backEndHeight - Config.FINGER_SIZE * 1.0;
				
				if (backAnimation != null)
				{
					TweenMax.killTweensOf(backAnimation);
				}
				backAnimation = new Object();
				backAnimation.height = currentBackHeight;
				TweenMax.to(backAnimation, showTime, { height:backEndHeight, onUpdate:redrawBack, ease:Back.easeOut });
				
				TweenMax.to(backgroundContent, showTime * .5, { alpha:1 } );
				TweenMax.to(container, showTime * .5, { alpha:1 } );
				
				TweenMax.to(backgroundContent, showTime, { y:endPositionBack, ease:Back.easeOut } );
				TweenMax.to(container, showTime, { y:endPositionContent, ease:Back.easeOut, onComplete:animationFinished} );
				
				TweenMax.to(background, showTime, { alpha:1 } );
			}
		}
		
		private function getBackHeight():int 
		{
			return Math.min(getMaxBackHeight(), scrollPanel.view.y + scrollPanel.height + contentPadding);
		}
		
		private function getMaxBackHeight():int 
		{
			return getHeight() - mainPadding * 2 - Config.APPLE_BOTTOM_OFFSET - Config.APPLE_TOP_OFFSET;
		}
		
		protected function drawBack(heightValue:int):void 
		{
			var radius:int = Style.size(Style.FLOAT_POOPUP_RADIUS);
			backgroundContent.graphics.clear();
			
			var colorPosition:int = -1;
			if (colorDelimiterPosition != -1)
			{
				colorPosition = colorDelimiterPosition + scrollPanel.view.y;
			}
			
			if (colorPosition == -1 || colorPosition - contentPadding >= heightValue)
			{
				backgroundContent.graphics.beginFill(topColor);
				backgroundContent.graphics.drawRoundRect(0, 0, getWidth(), heightValue, radius, radius);
				backgroundContent.graphics.endFill();
			}
			else
			{
				if (topColor != Style.color(Style.COLOR_BACKGROUND) && bottomColor == Style.color(Style.COLOR_BACKGROUND))
				{
					if (topColorClip == null)
					{
						topColorClip = new Sprite();
						topColorClip.graphics.beginFill(topColor);
						topColorClip.graphics.drawRect(0, 0, getWidth(), colorPosition - scrollPanel.view.y);
						topColorClip.graphics.endFill();
						addItem(topColorClip);
						toBack(topColorClip);
					}
					if (scrollPanel != null)
					{
						scrollPanel.blockTopOvermove();
					}
					backgroundContent.graphics.beginFill(bottomColor);
					backgroundContent.graphics.drawRoundRect(0, 0, getWidth(), heightValue, radius, radius);
					backgroundContent.graphics.endFill();
					
					backgroundContent.graphics.beginFill(topColor);
					backgroundContent.graphics.drawRoundRectComplex(0, 0, getWidth(), scrollPanel.view.y, radius * .5, radius * .5, 0, 0);
					backgroundContent.graphics.endFill();
				}
				else
				{
					backgroundContent.graphics.beginFill(topColor);
					backgroundContent.graphics.drawRoundRectComplex(0, 0, getWidth(), colorPosition, radius * .5, radius * .5, 0, 0);
					backgroundContent.graphics.endFill();
					backgroundContent.graphics.beginFill(bottomColor);
					backgroundContent.graphics.drawRoundRectComplex(0, colorPosition, getWidth(), heightValue - colorPosition, 0, 0, radius * .5, radius * .5);
					backgroundContent.graphics.endFill();
				}
			}
		}
		
		protected function animationFinished():void 
		{
			updateScroll();
		}
		
		private function redrawBack():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (backAnimation == null)
			{
				return;
			}
			drawBack(backAnimation.height);
		}
		
		protected function getHeight():int 
		{
			return _height - Config.FINGER_SIZE * .5;
		}
		
		protected function getWidth():int 
		{
			return _width - mainPadding * 2;
		}
		
		protected function close(e:Event = null):void {
			if (isDisposed == true)
			{
				return;
			}
			
			TweenMax.killDelayedCallsTo(close);
			
			onCloseStart();
			
			deactivateScreen();
			TweenMax.to(container, 0.3, { y:getContentHidePosition(), onComplete:remove, ease:Power2.easeIn } );
			TweenMax.to(backgroundContent, 0.3, { y:_height, ease:Power2.easeIn } );
			TweenMax.to(background, 0.3, { alpha:0 } );
		}
		
		protected function onCloseStart():void 
		{
			
		}
		
		protected function getContentHidePosition():int
		{
			return _height;
		}
		
		private function remove():void {
			
			if (manager == DialogManager)
			{
				DialogManager.closeDialog();
			}
			else if(manager == ServiceScreenManager)
			{
				ServiceScreenManager.closeView();
			}
			else
			{
				ServiceScreenManager.closeView();
			}
			onRemove();
		}
		
		protected function onRemove():void
		{
			
		}
		
		private function onButtonCloseClick():void
		{
			close();
		}
		
		protected function updateScroll():void
		{
			if (scrollPanel != null)
			{
				scrollPanel.update();
				scrollPanel.setWidthAndHeight(getWidth(), getContentheight());
			}
		}
		
		private function getContentheight():int
		{
			return Math.min(getMaxContentHeight(), getScrollContentHeight());
		}
		
		private function getScrollContentHeight():Number
		{
			scrollBottom.y = 0;
			var value:int = scrollPanel.itemsHeight;
			updateBottomScrollClip();
			return value;
		}
		
		private function getMaxContentHeight():int
		{
			return getMaxBackHeight() - contentPadding - closeButton.y - closeButton.height - Config.FINGER_SIZE * .1;
		}
		
		protected function toBack(item:DisplayObject):void 
		{
			if (scrollPanel != null)
			{
				scrollPanel.toBack(item);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function addItem(item:DisplayObject):void 
		{
			if (scrollPanel != null)
			{
				scrollPanel.addObject(item);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function removeItem(item:DisplayObject):void 
		{
			if (scrollPanel != null)
			{
				scrollPanel.removeObject(item);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		protected function getBottomPadding():int 
		{
			return 0;
		}
		
		protected function updateContentPositions():void 
		{
			
		}
		
		protected function hidePreloader():void 
		{
			if (!isDisposed)
			{
				TweenMax.to(container, 0.2, {ease:Power1.easeIn, colorTransform:{brightness: 1}});
				TweenMax.to(backgroundContent, 0.2, {ease:Power1.easeIn, colorTransform:{brightness: 1}});
				if (preloader != null)
				{
					preloader.dispose();
					if (view != null)
					{
						view.removeChild(preloader);
					}
					preloader = null;
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		protected function showPreloader():void 
		{
			if (!isDisposed)
			{
				TweenMax.to(container, 0.2, {ease:Power1.easeIn, colorTransform:{brightness: 1.3}});
				TweenMax.to(backgroundContent, 0.2, {ease:Power1.easeIn, colorTransform:{brightness: 1.3}});
				if (preloader == null)
				{
					preloader = new CirclePreloader();
					if (view != null)
					{
						view.addChild(preloader);
					}
					else
					{
						ApplicationErrors.add();
					}
					
					preloader.x = int(container.x + container.width * .5);
					preloader.y = int(container.x + container.height * .5);
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killDelayedCallsTo(close);
			TweenMax.killTweensOf(container);
			TweenMax.killTweensOf(background);
			TweenMax.killTweensOf(backgroundContent);
			if (backAnimation != null)
			{
				TweenMax.killTweensOf(backAnimation);
			}
			if (background != null)
				UI.destroy(background);
			background = null;
			if (container != null)
				UI.destroy(container);
			container = null;
			if (backgroundContent != null)
				UI.destroy(backgroundContent);
			backgroundContent = null;
			if (closeButton != null)
			{
				closeButton.dispose();
				closeButton = null;
			}
			if (scrollPanel != null)
			{
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (scrollBottom != null)
			{
				UI.destroy(scrollBottom);
				scrollBottom = null;
			}
			if (scrollUp != null)
			{
				UI.destroy(scrollUp);
				scrollUp = null;
			}
			if (topColorClip != null)
			{
				UI.destroy(topColorClip);
				topColorClip = null;
			}
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
		}
	}
}