package com.dukascopy.connect.screens.context 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.utils.TextUtils;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author ...
	 */
	public class ContextMenuButton extends Sprite
	{	
		private var action:IScreenAction;
		private var text:Bitmap;
		private var itemHeight:int;
		private var paddingH:int;
		private var icon:Bitmap;
		private var iconWidth:int;
		private var first:Boolean;
		private var last:Boolean;
		private var itemWidth:int;
		private var backColor:uint;
		private var selected:Boolean;
		private var darkTheme:Boolean;
		
		private var line_darkTheme:uint = 0xFFFFFF;
		private var line_lightTheme:uint = 0x000000;
		
		private var select_darkTheme:uint = 0x1C1C1C;
		private var select_lightTheme:uint = 0x999999;
		
		private var unselect_darkTheme:uint = 0x333333;
		private var unselect_lightTheme:uint = 0xFFFFFF;
		
		public function ContextMenuButton() {
			itemHeight = Config.FINGER_SIZE * .85;
			paddingH = Config.DOUBLE_MARGIN;
			iconWidth = Config.FINGER_SIZE * .35;
			
			text = new Bitmap();
			addChild(text);
			
			icon = new Bitmap();
			addChild(icon);
		}
		
		public function getHeight():int {
			return height;
		}
		
		public function getWidth():int {
			return text.width + paddingH * 3 + iconWidth;
		}
		
		public function createText(action:IScreenAction, maxWidth:int):void {
			this.action = action;
			
			if (action.getIconClass() != null) {
				var iconClip:Sprite = new (action.getIconClass())();
				var color:Color = new Color();
				color.color = 0;
				iconClip.transform.colorTransform = color;
				iconClip.alpha = 0.5;
				UI.scaleToFit(iconClip, iconWidth, iconWidth);
				icon.bitmapData = UI.getSnapshot(iconClip, StageQuality.HIGH, "ContextMenuButton.icon");
				icon.x = int(paddingH + iconWidth * .5 - icon.width * .5);
				icon.y = int(itemHeight * .5 - icon.height * .5);
			}
			
			text.bitmapData = TextUtils.createTextFieldData(action.getData() as String, maxWidth - paddingH * 3 - iconWidth, 
															10, false, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .30, false, 
															0x000000, 0xFFFFFF, true, false, true);
			text.y = int(itemHeight * .5 - text.height * .5);
			text.x = iconWidth + paddingH * 2;
		}
		
		public function createBack(first:Boolean, last:Boolean, itemWidth:int):void {
			
			this.first = first;
			this.last = last;
			this.itemWidth = itemWidth;
			
			backColor = getUnselectColor();
			updateBack();
		}
		
		private function updateBack():void {
			var radius:int = Config.FINGER_SIZE * .13;
			graphics.clear();
			graphics.beginFill(backColor, getBackAlpha());
			
			var lineThickness:int = Math.ceil(Config.FINGER_SIZE * .01);
			
			if (first == true && last == true) {
				graphics.drawRoundRectComplex(0, 0, itemWidth, itemHeight, radius, radius, radius, radius);
			}
			else if (first == true) {
				graphics.drawRoundRectComplex(0, 0, itemWidth, itemHeight + lineThickness, radius, radius, 0, 0);
				addBottomLine(itemWidth, lineThickness);
			}
			else if (last == true) {
				graphics.drawRoundRectComplex(0, 0, itemWidth, itemHeight, 0, 0, radius, radius);
			}
			else {
				graphics.drawRoundRectComplex(0, 0, itemWidth, itemHeight + lineThickness, 0, 0, 0, 0);
				addBottomLine(itemWidth, lineThickness);
			}
			graphics.endFill();
		}
		
		private function getBackAlpha():Number 
		{
			if (darkTheme == true)
			{
				return 0.9;
			}
			else{
				return 0.7;
			}
		}
		
		private function addBottomLine(itemWidth:int, lineThickness:int):void {
			
			graphics.lineStyle(lineThickness, getLineColor(), 0.2);
			graphics.moveTo(paddingH, itemHeight + lineThickness*.5);
			graphics.lineTo(itemWidth - paddingH, itemHeight + lineThickness*.5);
		}
		
		private function getLineColor():uint 
		{
			if (darkTheme == true)
			{
				return line_darkTheme;
			}
			else{
				return line_lightTheme;
			}
		}
		
		public function dispose():void {
			if (action != null) {
				action.dispose();
				action = null;
			}
			
			if (text != null) {
				UI.destroy(text);
				text = null;
			}
			if (icon != null) {
				UI.destroy(icon);
				icon = null;
			}
		}
		
		public function getAction():IScreenAction {
			return action;
		}
		
		public function select():void {
			if (selected) {
				return;
			}
			selected = true;
			backColor = getSelectColor();
			updateBack();
		}
		
		private function getSelectColor():uint 
		{
			if (darkTheme == true)
			{
				return select_darkTheme;
			}
			else{
				return select_lightTheme;
			}
		}
		
		public function unselect():void {
			if (!selected){
				return;
			}
			selected = false;
			backColor = getUnselectColor();
			updateBack();
		}
		
		private function getUnselectColor():uint 
		{
			if (darkTheme == true)
			{
				return unselect_darkTheme;
			}
			else{
				return unselect_lightTheme;
			}
		}
		
		public function toDark():void 
		{
			darkTheme = true;
			backColor = getUnselectColor();
			updateBack();
			
			var brightness:Number = 255;
			text.bitmapData.applyFilter(text.bitmapData, text.bitmapData.rect, new Point(), new ColorMatrixFilter(
																					[
																						1, 0, 0, 0, brightness,
																						0, 1, 0, 0, brightness, 
																						0, 0, 1, 0, brightness, 
																						0, 0, 0, 1, 0]));
			icon.bitmapData.applyFilter(icon.bitmapData, icon.bitmapData.rect, new Point(), new ColorMatrixFilter(
																					[
																						1, 0, 0, 0, brightness,
																						0, 1, 0, 0, brightness, 
																						0, 0, 1, 0, brightness, 
																						0, 0, 0, 1, 0]));
			icon.alpha = 1;
		}
	}
}