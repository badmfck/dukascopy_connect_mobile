package com.dukascopy.connect.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ColorUtils
	{
		
		public function ColorUtils()
		{
		
		}
		
		public static function getColorBrightness(color:Number):Number
		{
			var rgb:Array = HexToRGB(color);
			
			return Math.sqrt((rgb[0] * rgb[0] * 0.241) + (rgb[1] * rgb[1] * 0.691) + (rgb[2] * rgb[2] * 0.068)) / 255;
		}
		
		public static function HexToRGB(hex:uint):Array
		{
			var rgb:Array = [];
			
			var r:uint = hex >> 16 & 0xFF;
			var g:uint = hex >> 8 & 0xFF;
			var b:uint = hex & 0xFF;
			
			rgb.push(r, g, b);
			return rgb;
		}
		
		public static function getAverageColorBrightness(image:DisplayObject):Number
		{
			var bmp:BitmapData = new BitmapData(image.width, image.height, true, 0x00000000);
			
			bmp.draw(image);
			
			var v:Vector.<Vector.<Number>> = bmp.histogram();
			var r:Number = 0;
			var g:Number = 0;
			var b:Number = 0;
			var a:Number = 0;
			
			for (var i:int = 0; i < 256; i++)
			{
				r += i * v[0][i] / 255;
				g += i * v[1][i] / 255;
				b += i * v[2][i] / 255;
				a += i * v[3][i] / 255;
			}
			
			var brightness:Number = (r + g + b) / (3 * a);
			
			bmp.dispose();
			
			return brightness;
		}
	}
}