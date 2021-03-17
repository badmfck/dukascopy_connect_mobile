package com.dukascopy.connect.screens.dialogs.calendar 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.calendar.TimeRange;
	import com.dukascopy.connect.utils.TextUtils;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RangeItem extends Sprite
	{
		public var timeRange:TimeRange;
		private var itemHeight:int;
		private var bitmap:Bitmap;
		private var finalHeight:Number;
		private var lastColor:uint;
		private var color:Color;
		public var rangeIndex:int;
		
		public function RangeItem() 
		{
			bitmap = new Bitmap();
			bitmap.smoothing = true;
			addChild(bitmap);
		}
		
		public function setRange(timeRange:TimeRange, itemHeight:int, rangeIndex:int):void 
		{
			this.rangeIndex = rangeIndex;
			this.timeRange = timeRange;
			this.itemHeight = itemHeight;
			draw();
		}
		
		private function draw():void 
		{
			var value:String = timeRange.value.toString();
			if (value.length == 1)
			{
				value = "0" + value;
			}
			
			clearBitmap();
			
			bitmap.bitmapData = TextUtils.createTextFieldData(
													value, 
													Config.FINGER_SIZE * 3, 
													10, 
													false, 
													TextFormatAlign.LEFT,
													TextFieldAutoSize.LEFT, 
													itemHeight, 
													false, 
													0xFFFFFF, 
													0, true);
			bitmap.x = -(bitmap.width * .5);
			bitmap.y = -(bitmap.height * .5);
			
			finalHeight = bitmap.height;
			
		//	trace(itemHeight, bitmap.height);
		}
		
		private function clearBitmap():void 
		{
			if (bitmap != null && bitmap.bitmapData != null)
			{
				bitmap.bitmapData.dispose();
				bitmap.bitmapData = null;
			}
		}
		
		public function setSize(value:Number):void
		{
			if (value == itemHeight)
			{
				return;
			}
			itemHeight = value;
			draw();
		}
		
		public function setPosition(index:int, position:Number):void 
		{
			y = position;
		}
		
		public function setColor(middleColor:uint):void 
		{
			if (lastColor == middleColor)
			{
				return;
			}
			lastColor = middleColor;
			if (color == null)
			{
				color = new Color();
			}
			color.color = middleColor;
			transform.colorTransform = color;
		}
		
		public function dispose():void 
		{
			timeRange = null;
			color = null;
			
			if (bitmap != null)
			{
				UI.destroy(bitmap);
				bitmap = null;
			}
		}
	}
}