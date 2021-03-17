package com.dukascopy.connect.gui.button 
{
	import assets.CheckboxClip;
	import assets.CheckboxClipSelected;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
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
	public class Checkbox extends BitmapButton
	{
		private var selected:Boolean;
		private var text:String;
		private var itemWidth:Number;
		
		public function Checkbox(text:String) 
		{
			super("");
			this.text = text;
			selected = false;
		//	setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			setStandartButtonParams();
			setDownScale(1);
			setDownColor(Style.color(Style.COLOR_BACKGROUND));
			disposeBitmapOnDestroy = true;
		}
		
		private function changeSelection():void 
		{
			if (selected == true)
			{
				unselect();
			}
			else
			{
				select();
			}
		}
		
		override protected function onClick():void 
		{
			changeSelection();
		}
		
		public function draw(itemWidth:Number):void
		{
			if (isNaN(itemWidth))
			{
				itemWidth = Config.FINGER_SIZE * 3;
			}
			this.itemWidth = itemWidth;
			var bd:ImageBitmapData = TextUtils.createTextFieldData(text, itemWidth, 10, true, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, FontSize.BODY, false, 
																	Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true, true);
			
			var icon:Sprite;
			if (selected == true)
			{
				icon = new CheckboxClipSelected();
			}
			else
			{
				icon = new CheckboxClip();
			}
			
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .4), int(Config.FINGER_SIZE * .4));
			
			var iconBD:ImageBitmapData = UI.getSnapshot(icon);
			
			var result:ImageBitmapData = new ImageBitmapData("Checkbox", bd.width + iconBD.width + Config.FINGER_SIZE * .2, Math.max(bd.height, iconBD.height, Config.FINGER_SIZE * .8), false, Style.color(Style.COLOR_BACKGROUND));
			
			result.copyPixels(iconBD, iconBD.rect, new Point(0, int(result.height * .5 - iconBD.height * .5)), null, new Point(), true);
			result.copyPixels(bd, bd.rect, new Point(int(iconBD.width + Config.FINGER_SIZE * .2), int(result.height * .5 - bd.height * .5)), null, new Point(), true);
			setBitmapData(result, true);
			
			bd.dispose();
			iconBD.dispose();
			
			bd = null;
			iconBD = null;
		}
		
		public function unselect():void
		{
			selected = false;
			draw(itemWidth);
		}
		
		public function select():void
		{
			selected = true;
			draw(itemWidth);
		}
		
		public function isSelected():Boolean 
		{
			return selected;
		}
	}
}