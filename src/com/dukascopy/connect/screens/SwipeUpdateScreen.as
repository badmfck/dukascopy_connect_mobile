package com.dukascopy.connect.screens 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SwipeUpdateScreen extends BaseScreen
	{
		private var updateLoadingState:Boolean;
		private var historyLoadingScroller:Preloader;
		private var loadHistoryOnMouseUp:Boolean;
		
		public function SwipeUpdateScreen() 
		{
			
		}
		
		protected function onListTouchUp():void {
			if (loadHistoryOnMouseUp) {
				loadHistoryOnMouseUp = false;
				
				updateLoadingState = true;
				if (historyLoadingScroller != null)
					historyLoadingScroller.startAnimation();
				update();
				
			} else {
				if (historyLoadingScroller != null)
					historyLoadingScroller.hide();
			}
		}
		
		protected function update():void
		{
			
		}
		
		protected function onListMove(position:Number):void {
			if (position > 0) {
				if (!updateLoadingState) {
					var positionScroller:int = Config.FINGER_SIZE * .65 + Config.APPLE_TOP_OFFSET + position - Config.FINGER_SIZE;
					if (positionScroller > Config.FINGER_SIZE * 2) {
						loadHistoryOnMouseUp = true;
						positionScroller = Config.FINGER_SIZE * 2;
					} else {
						loadHistoryOnMouseUp = false;
					}
					
					if (historyLoadingScroller == null) {
						var loaderSize:int = Config.FINGER_SIZE * 0.6;
						if (loaderSize % 2 == 1)
							loaderSize ++;
						historyLoadingScroller = new Preloader(loaderSize, ListLoaderShape);
						_view.addChild(historyLoadingScroller);
						/*if (chatTop != null && chatTop.view != null && _view.contains(chatTop.view)) {
							_view.setChildIndex(chatTop.view, _view.numChildren - 1);
						}*/
					}
					historyLoadingScroller.y = Config.FINGER_SIZE * .65 + Config.APPLE_TOP_OFFSET - Config.FINGER_SIZE * .5;
					historyLoadingScroller.x = int(_width * .5);
					historyLoadingScroller.show(true, false);
					historyLoadingScroller.rotation = positionScroller * 100 / (Config.FINGER_SIZE * .5);
					historyLoadingScroller.y = positionScroller;
				}
			}
		}
		
		protected function hideHistoryLoader():void 
		{
			if (updateLoadingState)
			{
				updateLoadingState = false;
				if (historyLoadingScroller != null)
				{
					historyLoadingScroller.hide();
				}
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (historyLoadingScroller) {
				historyLoadingScroller.dispose();
				historyLoadingScroller = null;
			}
		}
	}
}