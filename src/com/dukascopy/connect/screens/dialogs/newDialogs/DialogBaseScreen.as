package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarDialog;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class DialogBaseScreen extends BaseScreen {
		protected var vPadding:int;
		protected var hPadding:int;
		
		protected var container:Sprite;
		protected var topBar:TopBarDialog;
		protected var bg:Shape;
		protected var scrollPanel:ScrollPanel;
		
		protected var componentsWidth:int;
		
		public function DialogBaseScreen() {
			
		}
		
		override protected function createView():void {
			super.createView();
			
			vPadding = Config.FINGER_SIZE * .32;
			hPadding = Config.FINGER_SIZE * .35;
			
			container = new Sprite();
				bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 50, 50);
			container.addChild(bg);
				topBar = new TopBarDialog(hPadding);
				topBar.x = 0;
			container.addChild(topBar);
				scrollPanel = new ScrollPanel();
				scrollPanel.view.x = 0;
				scrollPanel.background = false;
			container.addChild(scrollPanel.view);
			_view.addChild(container);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			componentsWidth = _width - hPadding * 2;
			
			if (data != null)
			{
				topBar.init(data.title, onCloseTap);
			}
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			topBar.draw(_width);
			scrollPanel.view.y = topBar.trueHeight + vPadding;
			var maxContentHeight:int = getMaxContentHeight();
			maxContentHeight = Math.min(maxContentHeight, scrollPanel.itemsHeight + 1);
			scrollPanel.setWidthAndHeight(_width, maxContentHeight);
			bg.width = _width;
			bg.height = calculateBGHeight();
			setContainerVerticalPosition();
			scrollPanel.hideScrollBar();
		} 
		
		protected function setContainerVerticalPosition():void {
			container.y = int((_height - bg.height) * .5);
		}
		
		protected function calculateBGHeight():int {
			return scrollPanel.view.y + scrollPanel.height + Config.MARGIN;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			topBar.activate();
			scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
				return;
			super.deactivateScreen();
			topBar.deactivate();
			scrollPanel.disable();
		}
		
		protected function onCloseTap():void {
			if (_isDisposed == true)
				return;
			if (data.callback != null)
				data.callback(0);
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			container = null;
		}
		
		protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - Config.MARGIN;
		}
	}
}