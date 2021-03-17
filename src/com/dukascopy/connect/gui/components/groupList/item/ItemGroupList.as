package com.dukascopy.connect.gui.components.groupList.item {
	
	import assets.IconArrowRight;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.groupList.item.vo.VOItemGL;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class ItemGroupList extends Sprite implements IItemGroupList{
		
		public static const TYPE_BTN:String = "button";
		public static const TYPE_SWITCH:String = "switch";
		
		private var _icon:Bitmap;
		private var _line1:Bitmap;
		private var _textBitmap:Bitmap;
		private var _labelText:String = "";
		private var _width:Number;
		private var _arrow :Bitmap;
		public var _switch :OptionSwitcher;
		private var btnField:BitmapButton;
		private var _type:String;
		private var _id:String;
		private var container:Sprite;
		private var _callback:Function;
		private var _height:int;
		
		public function ItemGroupList(icon:DisplayObjectContainer, title:String, id:String = "", callback:Function = null, type:String = TYPE_BTN) {
			_type = type;
			_id = id;
			_callback = callback;
			container = new Sprite();
			
			if (icon != null && icon is DisplayObjectContainer) {
				_icon = new Bitmap(null, "auto", true);
				UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
				_icon.bitmapData = UI.renderAsset(icon, Config.FINGER_SIZE * 0.36, Config.FINGER_SIZE * 0.36, true, "ItemGroupList.icon");
				addChild(_icon);
			}
			_labelText = title;
			//
			_textBitmap = new Bitmap(null, "auto", true);
			
			var hLineBitmapData:ImageBitmapData = new ImageBitmapData("ItemGroupList.hLine", 1, UI.getLineThickness(), false, Style.color(Style.COLOR_SEPARATOR));
			_line1 = new Bitmap(hLineBitmapData);
			hLineBitmapData = null;
			//arraw
			if(_type == TYPE_BTN) {
				createArrawByType(type);
			} else if(_type == TYPE_SWITCH){
				_switch = new OptionSwitcher();
				
				_switch.onSwitchCallback = onSwitchCallback;
			}
			
			addChild(container);
			if (_icon != null)
			{
				container.addChild(_icon);
			}
			container.addChild(_textBitmap);
			if (_arrow != null)
			{
				container.addChild(_arrow);
			}
			if (_switch != null)
			{
				addChild(_switch);
			}
			if (btnField != null)
			{
				addChild(btnField);
			}
			addChild(_line1);
			
			drawTextBitmap();
		}
		
		private function createArrawByType(type:String):void {
			_arrow = new Bitmap(null, "auto", true);
			if(type == TYPE_BTN){
				_arrow.bitmapData = createIconByMCandName(new IconArrowRight(), "ItemGroupList.IconArrowRight", true);
			}/*else if(type == TYPE_PLUS){
				_arraw.bitmapData = createIconByMCandName(new assets.AddItemButton(), "ItemGroupList.IconArrowRight", true);
			}*/
			
			btnField = new BitmapButton();
			btnField.setStandartButtonParams();
			btnField.setDownScale(1);
			btnField.setDownColor(AppTheme.WHITE);
			btnField.disposeBitmapOnDestroy = true;
			btnField.tapCallback = onButtonOneClick;
			btnField.usePreventOnDown = false;
			btnField.activate();
		}
		
		private function createIconByMCandName(mc:Sprite, nameIcon:String, isBlock = false):BitmapData {
			var topBarBtnSize:Number = Config.FINGER_SIZE * .4;
			if (isBlock) {
				var myColorTransform:ColorTransform = new ColorTransform();
				myColorTransform.color = Style.color(Style.ICON_RIGHT_COLOR);
				mc.transform.colorTransform = myColorTransform;
			}
			return UI.renderAsset(mc, topBarBtnSize, topBarBtnSize, true, nameIcon);
		}
		private function doCallback(vo:VOItemGL):void {
			if(_callback != null) {
				_callback(vo);
			}
		}
		
		private function drawTextBitmap():void {
			if(_textBitmap.bitmapData != null) {
				UI.disposeBMD(_textBitmap.bitmapData);
			}
			_textBitmap.bitmapData = null;
			var wTemp:Number;
			if(_icon != null){
				wTemp = _width - (_icon.x + _icon.width + Config.DIALOG_MARGIN * 2);
			}else{
				wTemp = _width - Config.DIALOG_MARGIN * 2;
			}
			_textBitmap.bitmapData = UI.renderText(_labelText, wTemp,  Config.FINGER_SIZE, false, TextFormatAlign.LEFT, 
													TextFieldAutoSize.LEFT, FontSize.BODY, false, 
													Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true);
			
			if(btnField != null){
				container.visible = true;
				drawView();
				container.graphics.clear();
				container.graphics.beginFill(0,0);
				container.graphics.lineStyle(0,0,0);
				container.graphics.drawRect(0,0,_textBitmap.y - _textBitmap.height,Config.FINGER_SIZE);
				container.graphics.endFill();
				btnField.setBitmapData(UI.getSnapshot(container, StageQuality.HIGH, "ItemGroupList"));
				container.visible = false;
				container.mouseEnabled = false;
			}
		}
		
		// Open Messanger Clicked
		private function onButtonOneClick():void {
			//trace("Open Messanger Clicked");
			var vo:VOItemGL = new VOItemGL(id);
			doCallback(vo);
		}
		
		private function onSwitchCallback(selected:Boolean):void {
			var vo:VOItemGL = new VOItemGL(id);
			vo.switchSelected = selected;
			doCallback(vo);
		}
		
		public function drawView():void {
			drawTextBitmap();
			
			if (_type == TYPE_SWITCH && _switch != null)
			{
				_switch.create(_width - Config.DOUBLE_MARGIN * 2, Config.FINGER_SIZE * .8, null, " ", _switch.isSelected, true, Style.color(Style.COLOR_TEXT));
			}
			
			if (_icon != null){
				_icon.x = Config.DOUBLE_MARGIN;
				_icon.y = int((_height - _icon.height) * .5);
				_textBitmap.x = int(Config.FINGER_SIZE * .8);
			}else{
				_textBitmap.x = Config.DOUBLE_MARGIN;
			}
			
			_textBitmap.y = int((_height - _textBitmap.height) * .5);
			
			if(_arrow){
				_arrow.x = _width - (_arrow.width + Config.DOUBLE_MARGIN);
				_arrow.y = int((_height - _arrow.height) * .5);
			}
			if (_switch) {
				_switch.x = _width - _switch.viewWidth;
				_switch.y = int((_height - _switch.viewHeight) * .5);
			}
			if (btnField) {
				btnField.x = 0;
				btnField.y = 0;
			}
			_line1.x = 0;
			_line1.y = _height - _line1.height;
			if (_line1.width !=_width)
				_line1.width = _width;
		}
		
		public function dispose():void {		
			UI.destroy(_icon);
			_icon = null;		
			UI.destroy(_textBitmap);
			_textBitmap = null;				
			UI.destroy(_line1);
			_line1 = null;			
			if (_switch != null)
				_switch.dispose();
			_switch = null;
			if (btnField != null)
				btnField.dispose();
			btnField = null;
		}
		
		public function setWidthAndHeight(itemWidth:int, itemHeight:int):void {
			_line1.width = _width;
			if (_width != width || _height != itemHeight) {
				_width = itemWidth;
				_height = itemHeight;
			}
		}
		
		public function activate():void 
		{
			if (_switch != null)
			{
				_switch.activate();
			}
		}
		
		public function deactivate():void 
		{
			if (_switch != null)
			{
				_switch.deactivate();
			}
		}
		
		override public function get height():Number{
			return _line1.y + _line1.height;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get type():String {
			return _type;
		}
	}
}