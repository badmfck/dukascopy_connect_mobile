package com.dukascopy.connect.screens.layout 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ScrollScreen extends TitleScreen
	{
		private var scrollPanel:ScrollPanel;
		private var scrollStart:Sprite;
		private var scrollStop:Sprite;
		
		public function ScrollScreen() 
		{
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			_view.addChild(scrollPanel.view);
			
			scrollStart = new Sprite();
			scrollStart.graphics.beginFill(0, 0);
			scrollStart.graphics.drawRect(0, 0, 1, 1);
			scrollStart.graphics.endFill();
			scrollPanel.addObject(scrollStart);
			
			scrollStop = new Sprite();
			scrollStop.graphics.beginFill(0, 0);
			scrollStop.graphics.drawRect(0, 0, 1, 1);
			scrollStop.graphics.endFill();
			scrollPanel.addObject(scrollStop);
		}
		
		protected function scrollToPosition(position:int):void 
		{
			if (scrollPanel != null)
			{
				scrollPanel.scrollToPosition(position, false);
			}
		}
		
		protected function isVisible(clip:Sprite):Boolean 
		{
			if (scrollPanel != null)
			{
				return scrollPanel.isItemVisible(clip);
			}
			return false;
		}
		
		override public function setWidthAndHeight(width:int, height:int):void {
			super.setWidthAndHeight(width, height);
			if (scrollPanel != null)
				scrollPanel.updateObjects();
		}
		
		protected function addObject(value:DisplayObject):void 
		{
			if (scrollPanel != null)
			{
				scrollPanel.addObject(value);
			}
		}
		
		protected function removeObject(value:DisplayObject):void 
		{
			if (scrollPanel != null)
			{
				scrollPanel.removeObject(value);
			}
		}
		
		override protected function drawView():void {
			super.drawView();
			if (scrollPanel != null) {
				scrollPanel.view.y = getContentPosition();
				scrollPanel.setWidthAndHeight(_width, _height - scrollPanel.view.y - getScrollBottomPadding(), true);
			}
			if (scrollStop != null)	{
				scrollStop.y = 0;
				scrollStop.y = int(scrollPanel.itemsHeight + getAppleBottomPadding() + getScrollBottomMargin());
			}
			scrollPanel.update();
		}
		
		protected function getScrollBottomMargin():int
		{
			return Config.FINGER_SIZE * .5;
		}

		private function getScrollBottomPadding():int
		{
			if (getBottomConfigHeight() > 0)
			{
				return getBottomConfigHeight() + Config.APPLE_BOTTOM_OFFSET;
			}
			else
			{
				return 0;
			}
		}
		
		private function getAppleBottomPadding():int 
		{
			if (getBottomConfigHeight() > 0)
			{
				return 0;
			}
			else
			{
				return Config.APPLE_BOTTOM_OFFSET;
			}
		}
		
		protected function getBottomConfigHeight():int 
		{
			return 0;
		}
		
		override public function activateScreen():void {
			if (_isDisposed)
				return;
			if (scrollPanel != null)
				scrollPanel.enable();
			super.activateScreen();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed)
				return;
			if (scrollPanel != null)
				scrollPanel.disable();
			super.deactivateScreen();
		}
		
		override public function dispose():void {
			super.dispose();
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			
			if (scrollStart != null)
				UI.destroy(scrollStart);
			scrollStart = null;
			
			if (scrollStop != null)
				UI.destroy(scrollStop);
			scrollStop = null;
		}
	}
}