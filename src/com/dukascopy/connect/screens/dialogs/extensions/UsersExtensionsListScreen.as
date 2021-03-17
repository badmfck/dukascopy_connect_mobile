package com.dukascopy.connect.screens.dialogs.extensions {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ContactListRenderer;
	import com.dukascopy.connect.gui.list.renderers.TopExtensionListRenderer;
	import com.dukascopy.connect.gui.list.renderers.UserExtensionListRenderer;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.sys.usersManager.extensions.ExtensionTopData;
	import com.dukascopy.connect.sys.usersManager.extensions.UserExtensionsManager;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class UsersExtensionsListScreen extends BaseScreen {
		private var topBar:TopBarScreen;
		
		private var list:List;
		private var addBotRequestId:String;
		private var createdChatUID:String;
		private var chatModel:ChatVO;
		private var screenLocked:Boolean;
		
		public function UsersExtensionsListScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
		//	_params.title = 'Select contacts screen';
			_params.doDisposeAfterClose = true;
			
			topBar.setData(Lang.flowers, true);
			
			topBar.drawView(_width);
			
			list.view.y = topBar.trueHeight;
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
			
			UserExtensionsManager.S_EXTENSIONS_LIST.add(onExtensionsLoaded);
			UserExtensionsManager.getExtensionsList();
		}
		
		private function updateList():void {
			if (list != null) {
				list.refresh();
			}
		}
		
		private function setListData(dataArray:Array):void {
			if (_isDisposed == true) 
				return;
			if (dataArray == null)
				return;
			
			list.setData(dataArray, TopExtensionListRenderer, ["avatarURL"]);
		}
		
		override protected function createView():void {
			super.createView();
			
			list = new List("UsersExtensionsListScreen.list");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.setMask(true);
			list.background = true;
			_view.addChild(list.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
		}
		
		private function lockScreen():void {
			screenLocked = true;
			list.deactivate();
		}
		
		private function unlockScreen():void {
			if (list != null) {
				list.activate();
			}
		}
		
		override protected function drawView():void {
			
		}
		
		private function onItemTap(itemData:Object, n:int):void {
			if (itemData is ExtensionTopData && (itemData as ExtensionTopData).user != null) {
				MobileGui.changeMainScreen(UserProfileScreen, {data:(itemData as ExtensionTopData).user, 
																backScreen:MobileGui.centerScreen.currentScreenClass, 
																backScreenData:data});
			}
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (list != null)
				list.dispose();
			list = null;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			
			if (topBar != null)
				topBar.activate();
			
			if (screenLocked == true) {
				return;
			}
			
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
		}
		
		private function onExtensionsLoaded(data:Array = null):void {
			setListData(data);
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
				
			if (topBar != null)
				topBar.deactivate();		

			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
		}
	}
}