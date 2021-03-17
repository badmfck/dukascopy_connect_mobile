package com.dukascopy.connect.gui.components.groupList {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.groupList.item.ItemGroupList;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class GroupButtons extends Sprite {
		
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private const BTN_ICON_SIZE:int = Config.FINGER_SIZE * 0.36;
		
		private var bg:Shape;
		
		private var itemsVO:Array;
		private var items:Array/*BitmapButton*/;
		
		private var _width:int = 320;
		
		private var disposed:Boolean = false;
		private var drawLine:Boolean;
		
		public function GroupButtons(drawLine:Boolean = true):void {
			this.drawLine = drawLine;
		}
		
		public function add(label:String, callback:Function, iconLeftCls:Class = null, iconRightCls:Class = null):void {
			if (disposed == true)
				return;
			var iconLeft:DisplayObject;
			if (iconLeftCls != null) {
				iconLeft = new iconLeftCls();
				UI.colorize(iconLeft, Style.color(Style.COLOR_ICON_SETTINGS));
				UI.scaleToFit(iconLeft, BTN_ICON_SIZE, BTN_ICON_SIZE);
			}
			var iconRight:DisplayObject;
			if (iconRightCls != null) {
				iconRight = new iconRightCls();
				UI.colorize(iconRight, Style.color(Style.ICON_RIGHT_COLOR));
				UI.scaleToFit(iconRight, BTN_ICON_SIZE * .7, BTN_ICON_SIZE * .7);
			}
			itemsVO ||= [];
			itemsVO.push(
				{
					label: label,
					callback: callback,
					iconLeft: iconLeft,
					iconRight: iconRight
				}
			);
		}
		
		public function create(needToDraw:Boolean = false):void {;
			removeItems();
			if (itemsVO != null) {
				var l:int = itemsVO.length
				var btn:BitmapButton;
				for (var i:int = 0; i < l; i++) {
					btn = new BitmapButton();
					btn.usePreventOnDown = false;
					btn.setDownScale(1);
					btn.setDownColor(Style.color(Style.COLOR_SUBTITLE));
					btn.tapCallback = itemsVO[i].callback;
					btn.setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
					addChild(btn);
					items ||= [];
					items.push(btn);
				}
			}
			if (needToDraw == true)
				drawView();
		}
		
		public function setWidth(w:int):void {
			if (disposed == true) {
				echo("GroupListComponent", "setWidth", "Disposed", true);
				return;
			}
			if (_width == w) {
				echo("GroupListComponent", "setWidth", "WIDTH is the same", true);
				return;
			}
			_width = w;
			drawView();
		}
		
		public function drawView():void {
			if (disposed == true) {
				echo("GroupListComponent", "drawView", "Disposed", true);
				return;
			}
			if (_width == 0) {
				echo("GroupListComponent", "drawView", "WIDTH not set", true);
				return;
			}
			drawItems();
			drawBG();
		}
		
		private function drawItems():void {
			if (disposed == true) {
				echo("GroupListComponent", "drawItems", "Disposed", true);
				return;
			}
			if (itemsVO == null || itemsVO.length == 0) {
				echo("GroupListComponent", "drawItems", "Nothing to draw", true);
				return;
			}
			if (items == null || items.length == 0) {
				echo("GroupListComponent", "drawItems", "Not created", true);
				return;
			}
			var lVO:int = itemsVO.length;
			var l:int = items.length;
			var pos:int = Config.MARGIN;
			for (var i:int = 0; i < l; i++) {
				if (i == lVO) {
					echo("GroupListComponent", "drawItems", "Need to recreate", true);
					break;
				}
				items[i].setBitmapData(getBMDByItemVO(itemsVO[i]));
				items[i].y = pos;
				items[i].x = 0;
				pos += items[i].height;
			}
		}
		
		private function getBMDByItemVO(data:Object):ImageBitmapData {
			return UI.renderSettingsTextAdvanced(
				Lang[data.label],
				_width,
				OPTION_LINE_HEIGHT,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.NONE,
				FontSize.BODY,
				false,
				Style.color(Style.COLOR_TEXT),
				0,
				0,
				data.iconLeft,
				data.iconRight
			);
		}
		
		private function drawBG():void {
			if (disposed == true) {
				echo("GroupListComponent", "drawBG", "Disposed", true);
				return;
			}
			if (items == null || items.length == 0) {
				echo("GroupListComponent", "drawBG", "Not created or Nothing to draw", true);
				return;
			}
			bg ||= new Shape();
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(
				0,
				0,
				_width,
				getFullHeight()
			);
			if (drawLine == true)
			{
				bg.graphics.lineStyle(UI.getLineThickness(), Style.color(Style.COLOR_SEPARATOR));
				bg.graphics.moveTo(0, 0);
				bg.graphics.lineTo(_width, 0);
			}
			
			addChildAt(bg, 0);
		}
		
		private function getFullHeight():Number 
		{
			var result:int = 0;
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					result += items[i].viewHeight;
				}
			}
			if (result > 0)
			{
				result += Config.MARGIN * 2;
			}
			return result;
		}
		
		public function activateScreen():void {
			if (disposed == true) {
				echo("GroupListComponent", "activateScreen", "Disposed", true);
				return;
			}
			if (items == null || items.length == 0) {
				echo("GroupListComponent", "activateScreen", "Not created or Nothing to activate", true);
				return;
			}
			var l:int = items.length;
			for (var i:int = 0; i < l; i++) {
				items[i].show(0);
				items[i].activate();
			}
		}
		
		public function deactivateScreen():void {
			if (disposed == true) {
				echo("GroupListComponent", "deactivateScreen", "Disposed", true);
				return;
			}
			if (items == null || items.length == 0) {
				echo("GroupListComponent", "deactivateScreen", "Not created or Nothing to deactivate", true);
				return;
			}
			var l:int = items.length;
			for (var i:int = 0; i < l; i++)
				items[i].deactivate();
		}
		
		public function dispose():void {
			removeItems();
			if (itemsVO == null || itemsVO.length == 0)
				return;
			var itemVO:Object;
			while (itemsVO.length != 0) {
				itemVO = itemsVO.shift();
				if (itemVO.iconLeft != null)
					UI.destroy(itemVO.iconLeft)
				itemVO.iconLeft = null;
				if (itemVO.iconRight != null)
					UI.destroy(itemVO.iconRight)
				itemVO.iconRight = null;
			}
			itemsVO = null;
			disposed = true;
		}
		
		private function removeItems():void {
			if (items == null || items.length == 0)
				return;
			while (items.length != 0)
				items.shift().dispose();
			items = null;
		}
		
		override public function get height():Number {
			if (bg == null)
				return 0;
			return bg.y + bg.height;
		}
	}
}