package com.dukascopy.connect.screens.innerScreens {
	
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911ScreenAction;
	import com.dukascopy.connect.gui.lightbox.*;
	import com.dukascopy.connect.gui.list.*;
	import com.dukascopy.connect.gui.list.renderers.*;
	import com.dukascopy.connect.gui.preloader.*;
	import com.dukascopy.connect.gui.tabs.*;
	import com.dukascopy.connect.screens.*;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.*;
	import com.dukascopy.connect.sys.contactsManager.*;
	import com.dukascopy.connect.sys.dialogManager.*;
	import com.dukascopy.connect.sys.echo.*;
	import com.dukascopy.connect.sys.imageManager.*;
	import com.dukascopy.connect.sys.phonebookManager.*;
	import com.dukascopy.connect.sys.usersManager.*;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.*;
	import com.dukascopy.connect.vo.*;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.langs.*;
	import com.greensock.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InnerCallsScreen extends BaseScreen
	{
		private static const TAB_ALL:String = "all";
		private static const TAB_MISSED:String = "missed";
		
		private var tabs:FilterTabs;
		private var list:List;
		
		private var allData:Vector.<CallsHistoryItemVO>;
		private var missedData:Vector.<CallsHistoryItemVO>;
		
		private var selectedFilter:String = TAB_ALL;
		private var contactFilter:String = "";
		
		private const topHeight:int = Config.FINGER_SIZE * 1.5;
		
		private var preloader:Preloader;
		private var emptyClip:Bitmap;
		
		public function InnerCallsScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = 'Inner calls screen';
			_params.actions = getScreenActions();
			_params.doDisposeAfterClose = false;
		}
		
		private function getScreenActions():Vector.<IScreenAction> {
			var array:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			var open911ScreenAction:IScreenAction = new Open911ScreenAction();
			array.push(open911ScreenAction);
			return array;
		}
		
		override protected function createView():void {
			super.createView();	
			echo("InnerCallsScreen", "createView", "");
			list = new List("CallsHistory");
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			list.view.y = Config.FINGER_SIZE*1.2;
			_view.addChild(list.view);
			createTabs();
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeedAuthorization);
		}
		
		private function createTabs ():void {
			tabs = new FilterTabs();
			tabs.add(Lang.textAll, TAB_ALL, true, "l");
			tabs.add(Lang.textMissed, TAB_MISSED, false, "r");
			_view.addChild(tabs.view);
			_view.addChild(tabs.view);
		}
		
		override public function drawViewLang():void {
			tabs.dispose();
			createTabs();
			tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			tabs.setSelection(selectedFilter);
			//super.drawViewLang();
		}
		
		private function onAuthNeedAuthorization():void {
			echo("InnerCallsScreen", "onAuthNeedAuthorization");
			
			if (list != null)
				list.setData(null,null);
			if (emptyClip != null && emptyClip.parent != null)
				emptyClip.parent.removeChild(emptyClip);
		}
		
		override protected function drawView():void {
			tabs.setWidthAndHeight(_width, Config.FINGER_SIZE * .85);
			list.view.y = (tabs.view.visible) ? tabs.height : 0;
			list.setWidthAndHeight(_width, _height - list.view.y);
		}
		
		private function showEmptyClip():void {
			if (emptyClip == null) {
				emptyClip = new Bitmap(new BitmapData(_width, _height - tabs.height, false, 0xFFFFFFFF));
				emptyClip.y = tabs.height;
				var txtSnapshot:BitmapData = UI.renderText(Lang.youDontHaveCalls, _width, 1, true, TextFormatAlign.CENTER, TextFieldAutoSize.CENTER, Config.FINGER_SIZE_DOT_35, true, 0x666666);
				var srcBMD:BitmapData = new SWFContactImage();
				var destScale:Number = UI.getMinScale(srcBMD.width, srcBMD.height, emptyClip.bitmapData.rect.width - Config.FINGER_SIZE, emptyClip.bitmapData.rect.height - Config.FINGER_SIZE * 3 - txtSnapshot.height);
				var img:BitmapData = UI.scaleManual( srcBMD,destScale,true);
				var rect:Rectangle = new Rectangle(0, Config.FINGER_SIZE, txtSnapshot.width, txtSnapshot.height);
				ImageManager.drawImageToBitmap(emptyClip.bitmapData, txtSnapshot, rect, 1);
				emptyClip.bitmapData.copyPixels(img, img.rect, new Point(int((_width - img.rect.width ) * .5), Config.FINGER_SIZE * 2 + txtSnapshot.rect.height));
				srcBMD = null;
				img.dispose();
				img = null;
			}
			if (emptyClip.parent == null)
				view.addChild(emptyClip);
		}
		
		private function hideEmptyClip():void {
			if (emptyClip == null)
				return;
			if (emptyClip.parent != null)
				emptyClip.parent.removeChild(emptyClip);
			if (emptyClip.bitmapData != null)
				emptyClip.bitmapData.dispose();
			emptyClip.bitmapData = null;
			emptyClip = null;
		}
		
		override public function clearView():void {
			echo("InnerCallsScreen", "clearView", "");
			super.clearView();
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (list != null)
				list.dispose();
			list = null;
		}
		
		override public function dispose():void {
			echo("InnerCallsScreen", "dispose", "");
			super.dispose();
			hidePreloader();
			selectedFilter = TAB_ALL;
			Auth.S_NEED_AUTHORIZATION.remove(onAuthNeedAuthorization);
		}
		
		override public function activateScreen():void {
			echo("InnerCallsScreen", "activateScreen", "");
			if (_isDisposed)
				return;
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}	
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
			
			CallsHistoryManager.activate();
			CallsHistoryManager.S_CALLS.add(onCallsLoaded);
			CallsHistoryManager.getCalls();
			CallsHistoryManager.markNewAsSeen();
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void 
		{
			if (isDisposed || list == null)
			{
				return;
			}
			
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS)
			{
				var item:ListItem;
				var l:int = list.getStock().length;
				var itemData:CallsHistoryItemVO;
				
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) 
				{
					item = list.getItemByNum(j);
					if (item && item.liView && item.liView.visible)
					{
						if (item.data is CallsHistoryItemVO)
						{
							itemData = item.data as CallsHistoryItemVO;
							if (itemData.userUID == status.uid)
							{
								if (list.getScrolling())
								{
									list.refresh();
								}
								else
								{
									item.draw(list.width, !list.getScrolling());
								}
								break;
							}
						}
					}
					else
					{
						break;
					}
				}
				itemData = null;
				item = null;
			}
		}
		
		override public function deactivateScreen():void {
			echo("InnerCallsScreen", "deactivateScreen", "");
			if (_isDisposed)
				return;
			if (list != null)
			{
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			
			CallsHistoryManager.S_CALLS.remove(onCallsLoaded);
			CallsHistoryManager.deactivate();
		}
		
		private function onUserlistOnlineStatusChanged():void 
		{
			if (list)
			{
				list.refresh();
			}
		}
		
		private function onAllUsersOffline():void
		{
			if (list)
			{
				list.refresh();
			}
		}
		
		private function showTabs(value:Boolean):void {
			echo("InnerCallsScreen", "showTabs", "");
			tabs.view.visible = value;
			list.view.y = (tabs.view.visible) ? tabs.height : 0;
			list.setWidthAndHeight(_width, _height - list.view.y);
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("InnerCallsScreen", "onItemTap", "");
			if (data is CallsHistoryItemVO == false)
				return;
			var item:ListItem = list.getItemByNum(n);
			var chiVO:CallsHistoryItemVO = data as CallsHistoryItemVO;
			var chatScreenData:ChatScreenData;
			if (item && item.getLastHitZone() == HitZoneType.CALL_USER) {
				if (chiVO.pid > 0) {
					chatScreenData = new ChatScreenData();
					chatScreenData.pid = (data as CallsHistoryItemVO).pid;
					chatScreenData.type = ChatInitType.SUPPORT;
					chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
					MobileGui.showChatScreen(chatScreenData);
					return;
				}
				if (WS.connected == false) {
					DialogManager.alert(Lang.textAttention, Lang.checkNetworkStatus);
					return;
				}
				CallManager.place(chiVO.userUID, RootScreen, data, chiVO.title, chiVO.avatarURL);				
			} else {
				if (chiVO.pid > 0) {
					chatScreenData = new ChatScreenData();
					chatScreenData.pid = (data as CallsHistoryItemVO).pid;
					chatScreenData.type = ChatInitType.SUPPORT;
					chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
					MobileGui.showChatScreen(chatScreenData);
					return;
				}
				
				MobileGui.changeMainScreen(UserProfileScreen, { data:(data as CallsHistoryItemVO).user, backScreen:RootScreen, backScreenData:data } );	
			}
		}
		
		private function displayPopup():void {
			DialogManager.alert(Lang.textWarning, Lang.invitationSmsText_appleWithLink);
		}
		
		private function onTabItemSelected(id:String):void {
			echo("InnerCallsScreen", "onTabItemSelected", "");
			selectedFilter = id;
			setListData();
		}
		
		private function onCallsLoaded():void {
			echo("InnerCallsScreen", "onCallsLoaded", "");
			allData = null;
			missedData = null;
			setListData();
		}
		
		private function setListData():void {
			echo("InnerCallsScreen", "setListData", "");
			if (selectedFilter == TAB_ALL) {
				if (allData == null || allData.length > 1 && allData[1] is ContactVO && allData[1].id == "")
					allData = CallsHistoryManager.getAllCalls();
				list.setData(allData, ListCallRenderer, ["avatarURL"]);
			}else if (selectedFilter == TAB_MISSED) {
				if (missedData == null || missedData.length != 0 && missedData[0] is ContactVO && missedData[0].id == "")
					missedData = CallsHistoryManager.getMissedCalls();
				list.setData(missedData, ListCallRenderer, ["avatarURL"]);				
			}
			TweenMax.killDelayedCallsTo(checkForEmptyClipNeed);
			if (list.data != null && list.data.length != 0) {
				checkForEmptyClipNeed();
				return;
			}
			TweenMax.delayedCall(1, checkForEmptyClipNeed);
		}
		
		private function checkForEmptyClipNeed():void {
			echo("InnerCallsScreen", "checkForEmptyClipNeed");
			if (list.data == null || list.data.length == 0) {
				showEmptyClip();
				return;
			}
			hideEmptyClip();
		}
		
		private function showPreloader():void {
			echo("InnerCallsScreen", "showPreloader", "");
			if (preloader == null)
				preloader = new Preloader();
			_view.addChild(preloader);
			preloader.show(false);
			setPreloaderCoords();
		}
		
		private function hidePreloader():void {
			if (preloader != null)
				preloader.hide();
		}
		
		private function setPreloaderCoords():void {
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = (_height + list.getStartVerticalSpace()) * .5;
			}
		}
		
		override public function getAdditionalDebugInfo():String {
			return "InnerCallsScreen > " + selectedFilter;
		}
	}
}