package com.dukascopy.connect.screens.settings 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBar;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ScrollScreen extends BaseScreen {
		
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
		private var scrollBottom:Sprite;
		
		public function ScrollScreen() 
		{
			
		}
		
		override protected function createView():void {
			super.createView();
			
			topBar = new TopBarScreen();
			view.addChild(topBar);
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			view.addChild(scrollPanel.view);
			scrollBottom = new Sprite();
			scrollBottom.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			scrollBottom.graphics.drawRect(0, 0, 1, 1);
			scrollBottom.graphics.endFill();
			scrollPanel.addObject(scrollBottom);
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
			
			topBar.setData(getScreenTitle(), true);
			topBar.drawView(_width);
			scrollPanel.view.y = int(topBar.y + topBar.trueHeight);
			scrollPanel.setWidthAndHeight(_width, _height - scrollPanel.view.y);
		}
		
		protected function getScreenTitle():String 
		{
			if (data != null && "title" in data && data.title != null)
			{
				return data.title;
			}
			return "";
		}
		
		override protected function drawView():void {
			super.drawView();
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = 0;
			updateContentPositions();
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET;
		}
		
		protected function updateContentPositions():void 
		{
			
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			
			topBar.activate();
			scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			
			topBar.deactivate();
			scrollPanel.disable();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (topBar != null)
			{
				topBar.dispose();
				topBar = null;
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
		}
	}
}