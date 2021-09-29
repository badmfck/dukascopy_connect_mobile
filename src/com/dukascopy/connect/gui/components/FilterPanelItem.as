package com.dukascopy.connect.gui.components 
{
	import assets.NewCloseIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.IFilterData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FilterPanelItem extends Sprite
	{
		private var itemData:SelectorItemData;
		private var onRemoveCallback:Function;
		private var text:Bitmap;
		private var closeButton:BitmapButton;
		private var maxWidth:int;
		private var vPadding:int;
		private var hPadding:int;
		private var buttonSize:int;
		private var backColor:Number;
		private var buttonHeight:int;
		
		public function FilterPanelItem(itemData:SelectorItemData, object, maxWidth:int, buttonHeight:int, onRemoveCallback:Function) 
		{
			this.itemData = itemData;
			this.maxWidth = maxWidth;
			this.onRemoveCallback = onRemoveCallback;
			this.buttonHeight = buttonHeight;
			
			vPadding = Config.FINGER_SIZE * .1;
			hPadding = Config.FINGER_SIZE * .16;
			buttonSize = Config.FINGER_SIZE * .13;
			backColor = Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED);
			
			draw();
		}
		
		private function draw():void 
		{
			text = new Bitmap();
			addChild(text);
			
			text.bitmapData = TextUtils.createTextFieldData(itemData.label.toUpperCase(), maxWidth - hPadding * 3 - buttonSize, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.CAPTION_1, false, Style.color(Style.COLOR_TEXT), backColor);
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.tapCallback = onCloseClick;
			closeButton.disposeBitmapOnDestroy = true;
			closeButton.setDownScale(1);
			closeButton.setOverlay(HitZoneType.CIRCLE);
			closeButton.setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			addChild(closeButton);
			
			var icon:Sprite = new NewCloseIcon();
			UI.colorize(icon, Style.color(Style.COLOR_TEXT));
			UI.scaleToFit(icon, buttonSize, buttonSize);
			closeButton.setBitmapData(UI.getSnapshot(icon), true);
			
			var itemWidth:int = text.width + hPadding * 3 + buttonSize;

			graphics.beginFill(backColor);
			graphics.drawRoundRect(0, 0, itemWidth, buttonHeight, buttonHeight, buttonHeight);
			graphics.endFill();
			
			text.x = hPadding;
			text.y = int(buttonHeight * .5 - text.height * .5);
			
			closeButton.x = itemWidth - buttonSize - hPadding;
			closeButton.y = int(buttonHeight * .5 - closeButton.height * .5);
		}
		
		private function onCloseClick():void 
		{
			if (onRemoveCallback != null)
			{
				onRemoveCallback(this);
			}
		}
		
		public function activate():void
		{
			closeButton.activate();
		}
		
		public function deactivate():void
		{
			closeButton.deactivate();
		}
		
		public function dispose():void
		{
			//!TODO:;
		}
		
		public function getData():SelectorItemData 
		{
			return itemData;
		}
	}
}