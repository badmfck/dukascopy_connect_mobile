package com.dukascopy.connect.screens.dialogs.x.base.bottom 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.AnimatedTitlePopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ScrollAnimatedTitlePopup extends AnimatedTitlePopup
	{
		protected var scrollPanel:ScrollPanel;
		protected var scrollBottom:Sprite;
		private var scrollUp:Sprite;
		private var horizontalLoader:HorizontalPreloader;
		
		public function ScrollAnimatedTitlePopup() 
		{
			
		}
		
		override protected function createView():void {
			super.createView();
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
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
		
		override protected function animationFinished():void 
		{
			updateScroll();
		}
		
		protected function showPreloader():void
		{
			if (horizontalLoader == null)
			{
				horizontalLoader = new HorizontalPreloader(Color.GREEN);
				horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
				container.addChild(horizontalLoader);
				horizontalLoader.y = headerHeight;
			}
			horizontalLoader.start();
		}
		
		protected function hidePreloader():void
		{
			if (horizontalLoader != null)
			{
				horizontalLoader.stop();
			}
		}
		
		protected function updateScroll():void
		{
			if (scrollPanel != null)
			{
				scrollPanel.update();
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
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			scrollPanel.view.y = headerHeight;
			updateScrollSize();
		}
		
		protected function updateScrollSize():void
		{
			scrollBottom.y = 0;
			scrollPanel.setWidthAndHeight(_width, getHeight() - headerHeight - getBottomPadding());
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET;
			scrollPanel.update();
		}
		
		protected function getBottomPadding():int 
		{
			return 0;
		}
		
		override protected function drawView():void {
			super.drawView();
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = 0;
			updateContentPositions();
			updateScrollSize();
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET;
		}
		
		protected function updateContentPositions():void 
		{
			
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			
			scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			
			scrollPanel.disable();
		}
		
		override public function dispose():void {
			super.dispose();
			
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
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
		}
	}
}