package com.dukascopy.connect.screens.shop {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsers;
	import com.dukascopy.connect.gui.list.renderers.ListOrderItem;
	import com.dukascopy.connect.gui.list.renderers.ListProductItem;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.paidChat.PaidChannelBuyersPopup;
	import com.dukascopy.connect.sys.applicationShop.Order;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class ProductsScreen extends BaseScreen {
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var allUsers:Vector.<ChatUserVO>;
		private var chatUid:String;
		
		public function ProductsScreen() { }
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarScreen();
			
			list = new List("ChatUsersScreen.list");
			list.setContextAvaliable(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			list.view.y = topBar.trueHeight;
			_view.addChild(list.view);
			_view.addChild(topBar);
		}
		
		override protected function drawView():void { topBar.drawView(_width); }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(Lang.myPaidChats, true);
			_params.doDisposeAfterClose = true;
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
			
			Shop.S_PRODUCTS.add(updateList);
			setListData();
		}
		
		private function updateList():void 
		{
			if (isDisposed)
			{
				return;
			}
			setListData();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			if (topBar != null)
				topBar.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (topBar != null)
				topBar.deactivate();		
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
		
		private function setListData():void {
			
			var subscriptions:Vector.<ShopProduct> = Shop.getProducts();
			list.setData(subscriptions, ListProductItem, ["avatarURL"]);
		}
		
		private function onItemTap(data:Object, n:int):void {
			
			if (data == null || (data is ShopProduct) == false)
				return;
			
			DialogManager.showDialog(PaidChannelBuyersPopup, {product : data});
		}
		
		private function onUserlistOnlineStatusChanged():void {
			if (list)
				list.refresh();
		}
		
		private function onAllUsersOffline():void {
			if (list)
				list.refresh();
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void {
			if (isDisposed || list == null)
				return;
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS) {
				var item:ListItem;
				var l:int = list.getStock().length;
				var itemData:ChatUserlistModel;
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) {
					item = list.getItemByNum(j);
					if (item && item.liView && item.liView.visible) {
						if (item.data is ChatUserlistModel) {
							itemData = item.data as ChatUserlistModel;
							if (itemData.contact && itemData.contact.uid == status.uid) {
								if (list.getScrolling())
									list.refresh();
								else
									item.draw(list.width, !list.getScrolling());
								break;
							}
						}
					}
					else
						break;
				}
				itemData = null;
				item = null;
			}
		}
	}
}