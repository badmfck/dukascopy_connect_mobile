package com.dukascopy.connect.screens.dialogs.x.base.bottom
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SearchListSelectionPopup extends ListSelectionPopup
	{
		private var search:Input;
		
		public function SearchListSelectionPopup() 
		{
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			search = new Input();
			search.S_CHANGED.add(onChanged);
			container.addChild(search.view);
			search.view.x = Config.DOUBLE_MARGIN;
			search.setTextStart(0);
		}
		
		private function getSearchpromt():String
		{
			if (data != null && "searchText" in data && data.searchText != null)
			{
				return data.searchText;
			}
			return Lang.TEXT_SEARCH_COUNTRY;
		}

		private function onChanged():void {
			var value:String = search.value.toLowerCase();
			doSearch(value);
		}
		
		protected function doSearch(value:String = ""):void {
			if (list == null)
				return;
			var data:Object = list.data;
			if (data == null || value == null)
				return;
			if ("length" in data)
			{
				var item:Object;
				for (var i:int = 0; i < data.length; i++) {
					item = data[i];
					if ("label" in item && item.label != null && item.label is String)
					{
						if ((item.label as String).toLowerCase().indexOf(value.toLowerCase()) == 0) {
							list.navigateToItem(i);
							return;
						}
					}
					else if (item != null && item is Array && (item as Array).length > 0)
					{
						if (item[0].indexOf(value) == 0) {
							list.navigateToItem(i);
							return;
						}
					}
				}
			}
		}
		
		override protected function getMaxContentHeight():int
		{
			return super.getMaxContentHeight() - search.height;
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			search.setParams(getSearchpromt(), Input.MODE_INPUT);
			search.view.y = headerHeight;
			search.width = _width - Config.DOUBLE_MARGIN * 2;
			list.view.y = search.view.y + search.height;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			search.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			search.deactivate();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (search != null)
			{
				search.S_CHANGED.remove(onChanged);
				search.dispose();
				search = null;
			}
		}
	}
}