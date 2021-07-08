package com.dukascopy.connect.vo {
	
	/**
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankMessageVO {
		
		private var _isMain:Boolean = false;
		private var _saveItem:Boolean = false;
		private var _isLast:Boolean = false;
		private var _text:String;
		private var _menu:Array;
		private var _buttons:Array;
		private var _mine:Boolean;
		private var _disabled:Boolean;
		private var _item:Object;
		private var _isItem:Boolean;
		private var _menuLayout:String = "";
		private var _addDesc:Array;
		
		public var additionalData:Object;
		
		public var waitingType:String;
		
		private var _linksArray:Array;
		
		public function BankMessageVO(val:String) {
			var data:Object = null;
			try {
				data = JSON.parse(val);
			} catch (e:Error) {
				_text = val;
				return;
			}
			setData(data);
			grabAllLinks();
		}
		
		private function setData(obj:Object):void {
			if (obj == null)
				return;
			if ("menuLayout" in obj && obj["menuLayout"] != null && obj["menuLayout"] is String) {
				_menuLayout = obj["menuLayout"];
			}
			if ("isMain" in obj == true)
				_isMain = obj.isMain;
			if ("saveItem" in obj == true)
				_saveItem = obj.saveItem;
			if ("addDesc" in obj == true)
				_addDesc = obj.addDesc;
			if ("isLast" in obj == true)
				_isLast = obj.isLast;
			if ("desc" in obj == true &&
				obj.desc != null &&
				obj.desc is String &&
				obj.desc.length != 0)
					_text = obj.desc;
			if ("menu" in obj == true &&
				obj.menu != null &&
				obj.menu is Array &&
				obj.menu.length != 0)
					_menu = obj.menu;
			if ("buttons" in obj == true &&
				obj.buttons != null &&
				obj.buttons is Array &&
				obj.buttons.length != 0)
					_buttons = obj.buttons;
			if ("item" in obj == true &&
				obj.item != null) {
					_item = obj.item;
					if (_text == null || _text == "")
						_text = _item.text;
			}
			if ("isItem" in obj &&
				obj.isItem == true)
					_isItem = obj.isItem;
		}
		
		public function setMine():void {
			_mine = true;
		}
		
		public function disable():void {
			_disabled = true;
		}
		
		public function enable():void {
			_disabled = false;
		}
		
		public function get text():String { return (_text != null) ? _text : ""; }
		public function get menu():Array { return _menu; }
		public function get buttons():Array { return _buttons; }
		public function get mine():Boolean { return _mine; }
		public function get disabled():Boolean { return _disabled; }
		public function get item():Object { return _item; }
		public function get menuLayout():String{ return _menuLayout;}
		public function get isItem():Boolean { return _isItem; }
		public function get isMain():Boolean { return _isMain; }
		public function get saveItem():Boolean { return _saveItem; }
		public function get isLast():Boolean { return _isLast; }
		public function get addDesc():Array { return _addDesc; }
		public function get linksArray():Array { return _linksArray; }
		
		public function set text(val:String):void {
			_text = val;
		}
		
		private function grabAllLinks():void {
			if (_linksArray != null)
				_linksArray = null;
			if (_text == null)
				return;
			var splitedText:Array = _text.split("<a");
			var rawLink:String;
			var endIndex:int;
			var linkObj:Object;
			var link:String;
			var hrefIndex:int;
			var leftSplited:String;
			for (var i:int = 0; i < splitedText.length; i++) {
				rawLink = splitedText[i];
				endIndex = rawLink.indexOf("</a>");
				if (endIndex == -1)
					continue;
				link = rawLink.substring(0, endIndex);
				if (link.length > 5) {
					link = "<a" + link + "</a>";
					linkObj = { };
					linkObj.fullLink = link;
					if (_linksArray == null)
						_linksArray = [];
					_linksArray.push(linkObj);
					hrefIndex = link.indexOf("href='");
					if (hrefIndex == -1)
						continue;
					leftSplited =  link.substr(hrefIndex, link.length - 1);
					leftSplited = leftSplited.substring(6, leftSplited.length - 1);
					var quotesIndex:int = leftSplited.indexOf("'");
					if (quotesIndex == -1)
						continue;
					leftSplited = leftSplited.substr(0, quotesIndex);
					linkObj.shortLink = leftSplited;
				}
			}
		}
		
		public function dispose():void {
			_text = null;
			_menu = null;
			_buttons = null;
			_mine = false;
			_disabled = false;
			_menuLayout = "";
			_linksArray = null;
		}
	}
}