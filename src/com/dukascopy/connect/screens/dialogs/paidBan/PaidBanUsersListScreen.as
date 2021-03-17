package com.dukascopy.connect.screens.dialogs.paidBan {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListBanUserRenderer;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
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
	
	public class PaidBanUsersListScreen extends BaseScreen {
		private var topBar:TopBarScreen;
		
		private var list:List;
		private var addBotRequestId:String;
		private var createdChatUID:String;
		private var chatModel:ChatVO;
		private var screenLocked:Boolean;
		
		public function PaidBanUsersListScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = 'Select contacts screen';
			_params.doDisposeAfterClose = true;
			
			topBar.setData(getScreenTitle(), true);
			
			UsersManager.S_USERS_FULL_DATA.add(updateList);
			
			if (data.userUID != null) {
				PaidBan.S_BANS_LIST.add(onBansLoaded);
				PaidBan.getBans(data.userUID);
			}
			else {
				PaidBan.S_BANS_TOP_LIST.add(onBansLoaded);
			//	PaidBan.getTopBans();
			}
		}
		
		private function updateList():void {
			if (list != null) {
				list.refresh();
			}
		}
		
		private function setListData(bans:Array):void {
			if (_isDisposed == true) 
				return;
			if (bans == null)
				return;
			
			list.setData(bans, ListBanUserRenderer);
		}
		
		override protected function createView():void {
			super.createView();
			
			list = new List("PaidBanUsersListScreen.list");
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
			topBar.drawView(_width);
			
			list.view.y = topBar.trueHeight;
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
		}
		
		private function getScreenTitle():String {
			if (data !=null && data.title != null)
				return data.title;
			return Lang.addBot;
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
			
			if (screenLocked == true) {
				return;
			}
			
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