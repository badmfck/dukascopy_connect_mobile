package com.dukascopy.connect.screens.roadMap {
	
	import com.dukascopy.connect.gui.payments.AccountRoadMap;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.langs.Lang;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class RoadMapScreen extends BaseScreen {
		
		private var _screenDeactivated:Boolean = true;
		private var roadMapComponent:AccountRoadMap;
		private var topBar:TopBarScreen;
		private var topHeight:int;
			
		public function RoadMapScreen() {}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(Lang.MY_ACCOUNT_TITLE, true);
			roadMapComponent.y = topHeight;
			roadMapComponent.setSize(_width, _height-topHeight);
			roadMapComponent.init();
			roadMapComponent.show();
		}
		
		override protected function createView():void {
			super.createView();
			roadMapComponent = new AccountRoadMap();
			view.addChild(roadMapComponent);
			topBar = new TopBarScreen();
			topHeight = topBar.trueHeight;
			_view.addChild(topBar);
		}
		
		override public function drawViewLang():void {
			if (roadMapComponent != null){
				roadMapComponent.onLangChange();
			}
			super.drawViewLang();
		}
		
		override public function activateScreen():void {
			if (_isDisposed) return;
			super.activateScreen();
			if (roadMapComponent != null)
				roadMapComponent.activate();
			if (topBar != null)
				topBar.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed) return;
			super.deactivateScreen();
			if(roadMapComponent!=null)
				roadMapComponent.deactivate();
			if (topBar != null)
				topBar.deactivate();
		}
		
		override protected function drawView():void {
			if (_isDisposed) return;
			roadMapComponent.y = topHeight;
			roadMapComponent.setSize(_width, _height-topHeight);
			topBar.drawView(_width);
		}
		
		override public function dispose():void {
			if (_isDisposed) return;
			if (roadMapComponent != null){
				roadMapComponent.dispose();
				roadMapComponent = null;
			}
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			_isDisposed = true;
			super.dispose();
		}
	}
}