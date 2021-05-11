package com.dukascopy.connect.screens.serviceScreen {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListChatUsers;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
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
	
	public class SelectContactScreen extends BaseScreen {
		
		private var list:List
		private var search:Input;
		private var topIBD:ImageBitmapData;
		
		private var topBox:Sprite;
		private var closeBtn:BitmapButton; 
		private var minHeight:int = 300; // Adding for small screens
		
		private var users:Array;
		private var isDialog:Boolean;
		
		public function SelectContactScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			search = new Input();
			search.view.y = Config.FINGER_SIZE;
			search.setParams(Lang.TEXT_SEARCH_CONTACT, Input.MODE_INPUT);
			search.S_CHANGED.add(onChanged);
			_view.addChild(search.view);
			
			list = new List("ContactPicker");
			list.background = true;
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.setMask(true);
			list.view.y = Config.FINGER_SIZE + search.view.height;
			_view.addChild(list.view);
			
			topBox = new Sprite();
			_view.addChild(topBox);
			
			closeBtn = new  BitmapButton();
			closeBtn.setBitmapData(UI.getIconByFrame(20, Config.FINGER_SIZE, Config.FINGER_SIZE));
			_view.addChild(closeBtn);
			closeBtn.show();
			closeBtn.tapCallback = onBack;
		}
		
		override protected function drawView():void {
			if (_height < minHeight)
				_height = minHeight;
			view.graphics.clear();
			view.graphics.beginFill(0xF5F5f5);
			view.graphics.drawRoundRect(0, 0, _width, _height, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			view.graphics.endFill();
			
			search.width = _width;
			list.setWidthAndHeight(_width, _height - Config.FINGER_SIZE_DOUBLE);
			
			topBox.graphics.clear();
			topBox.graphics.beginFill(AppTheme.RED_MEDIUM);
			topBox.graphics.drawRoundRectComplex(0, 0, _width, Config.FINGER_SIZE, Config.MARGIN, Config.MARGIN, 0, 0);
			topBox.graphics.endFill();
			
			// Вынести в глобальные переменные, сделать приватным. нахера же так делать то
			var tf:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25, 0xFFFFFF, true);
			if (topIBD != null && topIBD.isDisposed == false)
				topIBD.dispose();
			topIBD = null;
			topIBD = ImageManager.drawTextFieldToGraphic(topBox.graphics, Config.DOUBLE_MARGIN, Config.MARGIN * 2.5, Lang.selectContact, _width - Config.DOUBLE_MARGIN, tf);
			tf = null;
			
			closeBtn.x = _width - Config.FINGER_SIZE;
		}
		
		override public function setWidthAndHeight(width:int, height:int):void {
			super.setWidthAndHeight(width, height - Config.APPLE_TOP_OFFSET);
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.title = 'Select contacts';
			_params.doDisposeAfterClose = true;
			
			if (data != null && ("dialog" in data) && data.dialog == true)
			{
				isDialog = true;
			}
			
			PhonebookManager.S_PHONES.add(onPhonesLoaded);
			PhonebookManager.getPhones();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			search.activate();
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			if (closeBtn != null) {
				closeBtn.activate();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			search.deactivate();
			list.deactivate();
			list.S_ITEM_TAP.remove(onItemTap);
			if (closeBtn != null) {
				closeBtn.deactivate();
			}
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function close():void 
		{
			if (isDialog == true)
			{
				DialogManager.closeDialog();
			}
			else
			{
				ServiceScreenManager.closeView();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			PhonebookManager.S_PHONES.remove(onPhonesLoaded);
			
			if (list != null)
				list.dispose();
			list = null;
			if (search != null)
				search.dispose();
			search = null;
			UI.disposeBMD(topIBD);
			topIBD = null;
			if (topBox != null)
				topBox.graphics.clear();
			topBox = null
			if (closeBtn != null)
				closeBtn.dispose();
			closeBtn = null;
			
			clearUsers();
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (data is ChatUserlistModel) {
				(data as ChatUserlistModel).status = ((data as ChatUserlistModel).status == UserStatusType.SELECTED) ? UserStatusType.UNSELECTED : UserStatusType.SELECTED;
				list.updateItemByIndex(n);
				if (_data.callback != null) {
					_data.callback(data.contact, _data.data);
				}
				close();
			}
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