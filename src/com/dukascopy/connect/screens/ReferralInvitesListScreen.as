package com.dukascopy.connect.screens {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.ReferralProgramInviteData;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsers;
	import com.dukascopy.connect.gui.list.renderers.ListReferralInviteRenderer;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class ReferralInvitesListScreen extends BaseScreen {
		
		private var topBar:TopBarScreen;
		private var list:List;
		
		public function ReferralInvitesListScreen() { }
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarScreen();
			
			list = new List("ReferralInvitesScreen.list");
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
			topBar.setData(Lang.invites, true);
			_params.title = 'Referral invites screen';
			_params.doDisposeAfterClose = true;
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
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
			var listData:Vector.<ReferralProgramInviteData> = ReferralProgram.myPromoData.invites;
			list.setData(listData, ListReferralInviteRenderer);
		}
		
		private function onItemTap(data:Object, n:int):void {
			
			if (data == null || (data is ReferralProgramInviteData) == false)
				return;
			
			var user:UserVO = (data as ReferralProgramInviteData).user;
			
			if (user == null)
				return;
			
			var item:ListItem;
			
			item = list.getItemByNum(n);
			var itemHitZone:String;
			if (item != null)
				itemHitZone = item.getLastHitZone();
					
			if (itemHitZone == HitZoneType.INVITE_BUTTON && (data as ReferralProgramInviteData).reminded == false) {
				(data as ReferralProgramInviteData).reminded = true;
				ChatManager.sendMessageToUser(user.uid, Lang.remindUserRegister);
				list.refresh();
				return;
			}
			
			MobileGui.changeMainScreen(UserProfileScreen, { data:user, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:this.data
			} );
		}
	}
}