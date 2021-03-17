package com.dukascopy.connect.screens.dialogs.bottom 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
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
			search.setParams(Lang.TEXT_SEARCH_COUNTRY, Input.MODE_INPUT);	
			search.S_CHANGED.add(onChanged);
			container.addChild(search.view);
			search.view.x = Config.DOUBLE_MARGIN;
			search.setPadding(0);
		}
		
		private function onChanged():void {
			var value:String = search.value.toLowerCase();
			doSearch(value);
		}
		
		private function doSearch(value:String = ""):void {
			if (list == null)
				return;
			var data:Array = list.data as Array;
			if (data == null || value == null)
				return;
			for (var i:int = 0; i < data.length; i++) {
				if (data[i][0].indexOf(value) == 0) {
					list.navigateToItem(i);
					return;
				}
			}
		}
		
		override protected function getMaxContentHeight():int
		{
			return super.getMaxContentHeight() - search.height;
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
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