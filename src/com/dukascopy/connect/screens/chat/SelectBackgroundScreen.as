package com.dukascopy.connect.screens.chat {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.BackgroundModel;
	import com.dukascopy.connect.data.ChatBackgroundCollection;
	import com.dukascopy.connect.data.ChatSettingsModel;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListItemBackgrounds;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class SelectBackgroundScreen extends BaseScreen
	{
		private var topBar:TopBarScreen;
		
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private var lineDelimiter:Sprite;
		
		private var FIT_WIDTH:int;
		private var list:List;
		private var needToUpdate:Boolean = false;
		private var colCount:int;
		
		public function SelectBackgroundScreen()
		{
			
		}
		
		override public function initScreen(data:Object = null):void
		{
			needToUpdate = true;
			super.initScreen(data);
			_params.title = 'Select background screen';
			_params.doDisposeAfterClose = true;
			topBar.setData(Lang.backgroundsGallery, true);
			setListData();
		}
		
		private function setListData():void 
		{
			var items:Vector.<BackgroundModel> = ChatBackgroundCollection.getCollection();
			
			var count:int = 3;
			if (needToUpdate == true || count != colCount) {
				colCount = count;
				
				var lData:Array = [];
				var colIndex:int = 0;
				var rowIndex:int = 0;
				for (var i:int = 0; i < items.length; i++) {
					if (lData.length == rowIndex)
						lData.push( { data:[] } );
					lData[rowIndex].data.push( { model:items[i], currentBackgroundId: this.data.data.currentBackgroundId} );
					colIndex ++;
					if (colIndex == colCount) {
						lData[rowIndex].data.push(colCount);
						rowIndex ++;
						colIndex = 0;
					}
				}
				if (lData.length != rowIndex)
					lData[rowIndex].data.push(colCount);
				list.setData(lData, ListItemBackgrounds);
			}
		}
		
		override protected function createView():void
		{
			super.createView();
			
			list = new List("Backgrounds");
			list.setMask(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			_view.addChild(list.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
		}
		
		override protected function drawView():void
		{
			topBar.drawView(_width);
			updateList();
		}
		
		private function updateList():void 
		{
			list.view.y = topBar.trueHeight;
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
		}
		
		private function onChatBackgroundUpdated(data:Object):void
		{
			if (this.data.backScreenData)
			{
				(this.data.backScreenData.data.chatSettings as ChatSettingsModel).chatBackId = data.id;
			}
			
			if (_isDisposed)
			{
				return;
			}
			unlockList();
 			if (!isDisposed && data.chatUID == this.data.data.chatId)
			{
				this.data.data.currentBackgroundId = data.id;
				var length:int = (list.data as Array).length;
				var lengthRow:int;
				var item:Array;
				for (var i:int = 0; i < length; i++) 
				{
					item = list.data[i].data as Array;
					lengthRow = (item as Array).length - 1;
					for (var j:int = 0; j < lengthRow; j++) 
					{
						item[j].currentBackgroundId = this.data.data.currentBackgroundId;
					}
				}
				list.refresh();
			}
		}
		
		private function onItemTap(data:Object, n:int):void {
			var hz:String = list.getItemByNum(n).getLastHitZone();
			if (hz == null)
				return;
		//	lockList();
			
			(this.data.backScreenData.data.chatSettings as ChatSettingsModel).chatBackId = (list.data[n].data[int(hz)].model as BackgroundModel).id;
			
			ChatManager.setBackgroundImage(this.data.data.chatId, (list.data[n].data[int(hz)].model as BackgroundModel).id);
			
			onBack();
		}
		
		private function lockList():void
		{
			list.S_ITEM_TAP.remove(onItemTap);
		}
		
		private function unlockList():void
		{
			if(list && isActivated)
				list.S_ITEM_TAP.add(onItemTap);
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			UI.destroy(lineDelimiter);
			
			if (list != null)
				list.dispose();
			list = null;
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			if (_isDisposed)
				return;
				
			if (topBar != null)
				topBar.activate();
				
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
		//	ChatManager.UPDATE_CHAT_BACKGROUND.add(onChatBackgroundUpdated);
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed)
				return;
				
			if (topBar != null)
				topBar.deactivate();		
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
		//	ChatManager.UPDATE_CHAT_BACKGROUND.remove(onChatBackgroundUpdated);
		}
	}
}