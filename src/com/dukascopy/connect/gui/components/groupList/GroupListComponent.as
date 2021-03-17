/**
 * Created by aleksei.leschenko on 30.03.2017.
 */
package com.dukascopy.connect.gui.components.groupList {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.groupList.item.ItemGroupList;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class GroupListComponent extends Sprite {
		private var _header:Bitmap;
		private var _line1:Bitmap;
		
		protected var _width:int;
		protected var _height:int=240;
		private var _itemGroupLists:Vector.<ItemGroupList>;
		private var _isDrawBG:Boolean;
		private var _txtHeader:String = "";
		
		public function GroupListComponent() {
			
		}
		
		public function setWidthAndHeight(width:int, height:int):void {
			_isDrawBG = true;
			_width = width;
			_height = height;
			if(_line1){
				_line1.width = _width;
			}
			drawHeader();
			if(_itemGroupLists)
			{
				var itemGroupList:ItemGroupList;
				for (var i:int = 0; i < _itemGroupLists.length; i++) {
					itemGroupList = _itemGroupLists[i];
					itemGroupList.setWidthAndHeight(_width, Config.FINGER_SIZE);
				}
			}
		}
		
		public function drawView():void {
			
			var posItem:Number = 0;
			
			if(_header != null){
				_header.y = int((Config.FINGER_SIZE  - _header.height) * .5);
				_header.x = Config.DOUBLE_MARGIN;
				posItem = _header.y + _header.height + Config.DOUBLE_MARGIN;
			}
			
			if(_itemGroupLists != null)
			{
				
				var posBG:Number;
				posItem = 0
				if(_line1 != null) {
					_line1.x = 0;
					_line1.y = posItem;
				}
				posBG = posItem;
				var itemGroupList:ItemGroupList;
				for (var i:int = 0; i < _itemGroupLists.length; i++) {
					itemGroupList = _itemGroupLists[i];
					itemGroupList.drawView();
				//	itemGroupList.x = Config.DOUBLE_MARGIN;
					itemGroupList.y = posItem;
					posItem += itemGroupList.height;
				}
			}
			
			if(_isDrawBG && itemGroupList != null){
				graphics.clear();
			//	graphics.beginFill(0, 0.5); // zero alpha fill
			//	graphics.lineStyle(0, 0, 0); // invisible lines
			//	graphics.drawRect(0, 0, _width, Config.FINGER_SIZE);
				
				graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				var pos:int = 0;
				if (_line1 != null)
				{
					pos = _line1.y;
				}
			//	graphics.drawRect(itemGroupList.x, pos/*posBG*/, itemGroupList.x + itemGroupList.width, posItem - posBG /*this.height - posBG*/);
				
				graphics.endFill();
				_isDrawBG = false;
			}
		}
		
		public function activateScreen():void {
			if (_itemGroupLists != null)
			{
				for (var i:int = 0; i < _itemGroupLists.length; i++) {
					_itemGroupLists[i].activate();
				}
			}
		}
		
		public function deactivateScreen():void {
			if (_itemGroupLists != null)
			{
				for (var i:int = 0; i < _itemGroupLists.length; i++) {
					_itemGroupLists[i].deactivate();
				}
			}
		}
		
		public function dispose():void {
			if (_header != null)
			{
				UI.destroy(_header);
			}
			_header = null;
			
			if (_line1 != null)
			{
				UI.destroy(_line1);
			}
			_line1 = null;
			
			if(_itemGroupLists != null)
			{
				var itemGroupList:ItemGroupList;
				for (var i:int = 0; i < _itemGroupLists.length; i++) {
					itemGroupList = _itemGroupLists[i];
					itemGroupList.dispose();
					itemGroupList = null;
				}
			}
			_itemGroupLists = null;
		}
		
		public function add(txtHeader:String = "", itemGroupLists:Vector.<ItemGroupList> = null):void {
			_itemGroupLists = itemGroupLists;
			if (txtHeader != null && txtHeader != "")
			{
				_txtHeader = txtHeader;
				_header = new Bitmap(null, "auto", true);
				drawHeader();
				
				addChild(_header);
				var hLineBitmapData:ImageBitmapData = new ImageBitmapData("ItemGroupList.hLine", 1, 1, false, Style.color(Style.COLOR_SEPARATOR));
				_line1 = new Bitmap(hLineBitmapData);
				hLineBitmapData = null;
			}
			
			///
			for (var i:int = 0; i < _itemGroupLists.length; i++) {
				var itemGroupList:ItemGroupList = _itemGroupLists[i];
				addChild(itemGroupList);
			}
			if (_line1 != null)
			{
				addChild(_line1);
			}
		}
		
		private function drawHeader():void {
			if (_header != null)
			{
				if(_header.bitmapData!= null) {
				UI.disposeBMD(_header.bitmapData);
				}
					_header.bitmapData = UI.renderText(_txtHeader,
							_width,
							Config.FINGER_SIZE,
							false,
							TextFormatAlign.LEFT,
							TextFieldAutoSize.LEFT,
							FontSize.CAPTION_1,
							false,
							Style.color(Style.COLOR_SUBTITLE),
							0,
							true, "GroupListComponent.header");
				}
		}
		
		override public function get height():Number {
			if(_itemGroupLists.length > 0){
				var itemGroupList:ItemGroupList = _itemGroupLists[_itemGroupLists.length-1];
				return /*_header.y + */itemGroupList.y+itemGroupList.height;
			}else{
				return super.height;
			}
		}
		
		public function changeState(type:String,  id:String, selected:Boolean):void {//TODO:new VOItemGL(id)....
			if(_itemGroupLists.length > 0){
				for (var i:int = 0; i < _itemGroupLists.length; i++) {
					var itemGroupList:ItemGroupList = _itemGroupLists[i];
					if(itemGroupList.type == type && itemGroupList.id == id){
						itemGroupList._switch.isSelected = selected;
						break;
					}
				}
			}
		}
	}
}
