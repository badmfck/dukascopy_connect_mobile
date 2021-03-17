package com.dukascopy.connect.screens.dialogs.bottom 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ActionSheetItemIOS extends BitmapButton
	{
		public var onClick:Function;
		private var color:Number;
		private var backAlpha:Number;
		private var data:Object;
		
		public function ActionSheetItemIOS(data:Object, color:Number, backAlpha:Number) 
		{
			this.data = data;
			this.color = color;
			this.backAlpha = backAlpha;
			
			setStandartButtonParams();
			setDownColor(NaN);
			setDownScale(1);
			cancelOnVerticalMovement = true;
			tapCallback = callClick;
			setOverlayRadius(Style.value(Style.RADIUS_IOS_ACTION_SHEET_BACK));
			setOverlayPadding(0);
		}
		
		private function callClick():void 
		{
			if (onClick != null)
			{
				onClick(data);
			}
		}
		
		public function draw(label:String, buttonWidth:int, first:Boolean, last:Boolean):void 
		{
			var padding:int = Config.FINGER_SIZE * .2;
			var textWidth:int = buttonWidth - padding * 2;
			var buttonHeight:int = Style.value(Style.HEIGHT_IOS_ACTION_SHEET_BACK);
			
			var text:ImageBitmapData = TextUtils.createTextFieldData(
				label,
				textWidth,
				10,
				false,
				TextFormatAlign.CENTER, 
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				false,
				Color.IOS_TEXT_BLUE,
				Style.color(Style.COLOR_BACKGROUND),
				true
			);
			
			var topRadius:int = 0;
			var bottomRadius:int = 0;
			if (first == true)
			{
				topRadius = Style.value(Style.RADIUS_IOS_ACTION_SHEET_BACK);
			}
			if (last == true)
			{
				bottomRadius = Style.value(Style.RADIUS_IOS_ACTION_SHEET_BACK);
			}
			
			var container:Sprite = new Sprite();
			container.graphics.beginFill(color, backAlpha);
			container.graphics.drawRoundRectComplex(0, 0, buttonWidth, buttonHeight, topRadius, topRadius, bottomRadius, bottomRadius);
			container.graphics.endFill();
			
			var backBitmapData:ImageBitmapData = UI.getSnapshot(container);
			backBitmapData.copyPixels(text, text.rect, new Point(int(buttonWidth * .5 - text.width * .5), int(buttonHeight * .5 - text.height * .5)), null, null, true);
			setBitmapData(backBitmapData, true);
			UI.destroy(container);
			UI.disposeBMD(text);
			container = null;
			text = null;
			
			if (first && last)
			{
				setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			}
			else if (first)
			{
				setOverlay(HitZoneType.MENU_FIRST_ELEMENT);
			}
			else if (last)
			{
				setOverlay(HitZoneType.MENU_LAST_ELEMENT);
			}
			else
			{
				setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			onClick = null;
			data = null;
		}
	}
}