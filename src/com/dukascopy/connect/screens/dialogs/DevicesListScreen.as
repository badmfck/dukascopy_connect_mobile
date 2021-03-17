package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListBanUserRenderer;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class DevicesListScreen extends BaseScreen {
		private var topBar:TopBarScreen;
		
		private var list:List;
		
		public function DevicesListScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = true;
			
			topBar.setData(getScreenTitle(), true);
			
			Auth.S_DEVICES.add(updateList);
			
			updateList();
		}
		
		private function updateList():void {
			setListData(Auth.getDevices());
		}
		
		private function setListData(devices:Array):void {
			if (_isDisposed == true) 
				return;
			if (devices == null)
				return;
			
			list.setData(devices, ListBanUserRenderer);
		}
		
		override protected function createView():void {
			super.createView();
			
			list = new List("DevicesListScreen.list");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.setMask(true);
			list.background = true;
			_view.addChild(list.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
		}
		
		override protected function drawView():void {
			topBar.drawView(_width);
			
			list.view.y = topBar.trueHeight;
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
		}
		
		private function getScreenTitle():String {
			if (data !=null && data.title != null)
				return data.title;
			return Lang.myDevices;
		}
		
		private function onItemTap(itemData:Object, n:int):void {
			if (itemData is UserBan911VO  && 
				(itemData as UserBan911VO).user != null && 
				(itemData as UserBan911VO).user.getDisplayName() != null) {
				MobileGui.changeMainScreen(UserProfileScreen, {data:(itemData as UserBan911VO).user, 
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
			
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
		}
		
		private function onBansLoaded(data:Array = null):void {
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