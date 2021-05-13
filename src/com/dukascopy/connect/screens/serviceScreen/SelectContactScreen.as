package com.dukascopy.connect.screens.serviceScreen {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsers;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.bottom.SearchListSelectionPopup;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.UserStatusType;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class SelectContactScreen extends SearchListSelectionPopup {
		
		private var users:Array;
		
		public function SelectContactScreen() { }

		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.title = 'Select contacts';
			_params.doDisposeAfterClose = true;

			PhonebookManager.S_PHONES.add(onPhonesLoaded);
			PhonebookManager.getPhones();
		}

		override public function dispose():void {
			super.dispose();
			
			PhonebookManager.S_PHONES.remove(onPhonesLoaded);

			clearUsers();
		}
		
		override protected function getSelectedData(item:Object):Object
		{
			if (item is ChatUserlistModel)
			{
				return (item as ChatUserlistModel).contact;
			}

			return item;
		}
		
		private function onPhonesLoaded():void {
			clearUsers();
			var oldDelimiter:String = "";
			var newDelimiter:String = "";
			var cData:Array = PhonebookManager.getConnectContacts(true, true);
			cData.sort(sortUsers);
			var cDataNew:Array = [];
			var listItemModel:ChatUserlistModel;
			var contactsNum:int = cData.length;
			for (var i:int = 0; i < contactsNum; i++) {
				newDelimiter = String(cData[i].userVO.getDisplayName()).substr(0, 1).toUpperCase();
				if (newDelimiter != oldDelimiter) {
					oldDelimiter = newDelimiter;
					cDataNew.push([oldDelimiter.toLowerCase(), oldDelimiter]);
				}
				listItemModel = new ChatUserlistModel();
				listItemModel.contact = cData[i].userVO;
				listItemModel.status = UserStatusType.UNSELECTED;
				cDataNew.push(listItemModel);
			}
			users = cDataNew;
			list.setData(cDataNew, ListChatUsers);
			cDataNew = null;
			cData = null;

			updateListSize();
		}
		
		private function clearUsers():void {
			if (users == null)
				return;
			var count:int = users.length;
			for (var i:int = 0; i < count; i++) {
				if (users[i] is ChatUserlistModel)
					users[i].dispose();
			}
			users = null;
		}
		
		private function sortUsers(a:Object, b:Object):int {
			if (a.userVO.getDisplayName() < b.userVO.getDisplayName())
				return -1;
			else if (a.userVO.getDisplayName() > b.userVO.getDisplayName())
				return 1;
			return 0;
		}
		
		override protected function doSearch(value:String = ""):void {
			if (list == null)
				return;
			var data:Array = list.data as Array;
			if (data == null || value == null)
				return;
			for (var i:int = 0; i < data.length; i++) {
				if (data[i] is Array) {
					if(data[i][0].indexOf(value.toLowerCase()) == 0) {
						list.navigateToItem(i);
						return;
					}
					continue;
				}
				if (data[i].contact.getDisplayName().toLowerCase().indexOf(value.toLowerCase()) == 0) {
					list.navigateToItem(i);
					return;
				}
			}
		}
	}
}