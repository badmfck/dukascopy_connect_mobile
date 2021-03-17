package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ScreenSelectItemPopup extends DialogBaseScreen {
		
		private var itemClass:Class;
		private var listData:Array;
		private var callback:Function;
		
		private var list:List;
		
		public function ScreenSelectItemPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			list = new List("ScreenSelectItemPopup");
			list.setMask(true);
			container.addChild(list.view);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if ("callBack" in data == true && data.callBack != null)
				callback = data.callBack;
			if ("itemClass" in data == true && data.itemClass != null)
				itemClass = data.itemClass;
			if ("listData" in data == true && data.listData != null)
				listData = data.listData;
			if (itemClass != null && listData != null)
				list.setData(listData, itemClass);
			scrollPanel.view.visible = false;
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			topBar.draw(_width);
			list.view.y = topBar.y + topBar.trueHeight;
			list.setWidthAndHeight(_width, Math.min(getMaxContentHeight(), list.itemsHeight));
			
			bg.width = _width;
			bg.height = calculateBGHeight();
			setContainerVerticalPosition();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			if (scrollPanel != null)
				scrollPanel.disable();
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (_isDisposed == true)
				return;
			if (callback != null)
				callback(n);
			DialogManager.closeDialog();
		}
		
		override protected function onCloseTap():void {
			if (_isDisposed == true)
				return;
			if (callback != null)
				callback(-1);
			DialogManager.closeDialog();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
		}
		
		override protected function calculateBGHeight():int {
			return list.view.y + list.height;
		}
		
		override protected function getMaxContentHeight():int {
			return _height - topBar.trueHeight;
		}
		
		override public function dispose():void {
			super.dispose();
			if (list != null)
				list.dispose();
			list = null;
			listData = null;
			itemClass = null;
			callback = null;
		}
	}
}