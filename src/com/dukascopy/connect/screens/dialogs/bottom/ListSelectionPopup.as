package com.dukascopy.connect.screens.dialogs.bottom 
{
	import com.dukascopy.connect.Config;
	//import com.dukascopy.connect.data.ICollection;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.sys.style.Style;
	import com.greensock.TweenMax;
	import flash.events.Event;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ListSelectionPopup extends ResizeAnimatedTitlePopup
	{
		protected var list:List;
		private var needCallback:Boolean;
		private var selectedItem:Object;
		private var selectedNum:int;
		
		public function ListSelectionPopup() 
		{
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			list = new List("ListSelectionPopup");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.setMask(true);
			list.background = true;
			list.setOverlayReaction(true);
			
			container.addChild(list.view);
		}
		
		override public function onBack(e:Event = null):void
		{
			close();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			list.view.y = headerHeight;
			
			setListData();
		}
		
		private function setListData():void 
		{
			if (data != null && "items" in data && data.items != null)
			{
				if ("renderer" in data && data.renderer != null && data.renderer is Class)
				{
					drawList(data.renderer as Class, data.items);
				}
			}
		}
		
		private function drawList(renderer:Class, itemsData:Object):void 
		{
			list.setWidthAndHeight(_width, getMaxContentHeight());
			list.setData(itemsData, renderer);
			updateListSize();
		}

		protected function updateListSize():void
		{
			list.setWidthAndHeight(_width, int(Math.min(getMaxContentHeight(), list.itemsHeight)));
			if (list.itemsHeight > list.height)
			{
				list.setAdditionalBottomHeight(Config.APPLE_BOTTOM_OFFSET);
			}
			else
			{
				list.setWidthAndHeight(_width, int(Math.min(getMaxContentHeight(), list.height + Config.APPLE_BOTTOM_OFFSET)));
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
		}
		
		protected function onItemTap(data:Object, n:int):void {
			needCallback = true;
			selectedItem = getSelectedData(data);
			selectedNum = n;
			if (list.data != null)
			{
				for (var i:int = 0; i < list.data.length; i++) 
				{
					if ("selected" in list.data[i])
					{
						list.data[i].selected = false;
					}
				}
			}
			if ("selected" in selectedItem)
			{
				selectedItem.selected = true;
			}
			list.refresh();
			deactivateScreen();
			TweenMax.delayedCall(0.2, close);
		}
		
		override protected function animationFinished():void 
		{
			if (list != null)
			{
				list.updateView();
			}
		}
		
		override protected function onRemove():void{
			if (needCallback == true){

				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function)
				{
					if ((data.callback as Function).length == 1)
					{
						data.callback(selectedItem);
					}
					else if((data.callback as Function).length == 2)
					{
						if (data != null && "data" in data)
						{
							data.callback(selectedItem, data.data);
						}
						else
						{
							data.callback(selectedItem, selectedNum);
						}
						data.callback(selectedItem, selectedNum);
					}
					else if((data.callback as Function).length == 3)
					{
						data.callback(selectedItem);
					}
					selectedItem = null;
				}
			}
		}

		protected function getSelectedData(item:Object):Object{
			return item;
		}
		
		override public function dispose():void {
			super.dispose();
			
			TweenMax.killDelayedCallsTo(close);
			
			if (list != null)
			{
				list.dispose();
				list = null;
			}
		}
	}
}