package com.dukascopy.connect.screens.dialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.selector.Selector;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.type.MainColors;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserPopup extends BaseScreen
	{
		private var contentHeight:Number;
		private var selector:Selector;
		private var container:Sprite;
		
		public function UserPopup() 
		{
			
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			selector.maxWidth = _width - Config.MARGIN * 2;
			selector.x = Config.MARGIN;
			selector.y = Config.MARGIN;
			
			selector.dataProvider = ["Hour", "Day", "Month", "Permanent"];
		}
		
		override protected function createView():void
		{
			super.createView();
			
			container = new Sprite();
			view.addChild(container);
			
			selector = new Selector();
			container.addChild(selector);
		}
		
		override protected function drawView():void
		{
			updateBack();
		}
		
		protected function updateBack():void 
		{
			contentHeight = 300;
			
			container.graphics.clear();
			container.graphics.beginFill(MainColors.WHITE);
			container.graphics.drawRect(0, 0, _width, Math.min(contentHeight, _height));
			container.graphics.endFill();
			
			container.y = int(_height*.5 - Math.min(contentHeight, _height)*.5);
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			
		}
		
		override public function deactivateScreen():void
		{
			if (isDisposed) return;
			super.deactivateScreen();
			
			
		}
		
		override public function dispose():void
		{
			if (isDisposed) return;
			super.dispose();			
			
			
		}
	}
}