package com.dukascopy.connect.sys.theme 
{
	import com.dukascopy.connect.Config;
	/**
	 * Class containing all visual variables for storing theme colors...
	 * 
	 * Need to structurize theme color separation 
	 * @author Alexey
	 */
	public class AppTheme 
	{
		
		public function AppTheme() 	{ }
		
		public static var SCREEN_BACKGROUND_COLOR:uint = 0xffffff;
		public static var SCREEN_BACKGROUND_COLOR_GREY:uint = 0xf7f7f7;
		
		
		// Red color acents 
		public static var RED_DARK:uint = 0xa12d31;// 0x8b1718;
		public static var RED_MEDIUM:uint = 0xcd3f43;// 0xae1e1e;
		public static var RED_LIGHT:uint = 0xf2cfd0;//0xcd3f43;//  0xd92626;
		
		
		// Grey color acents
		public static var GREY_DARK:uint = 0x3b4452;
		public static const GREY_MEDIUM:uint = 0x93a2ae;
		public static var GREY_SEMI_LIGHT:uint = 0xe6eaed;
		public static var GREY_LIGHT:uint = 0xf7f7f7;
		public static var GREY_MEDIUM_LIGHT:uint = 0xCCCCCC;
		
		// Green color acents
		public static var GREEN_DARK:uint = 0x599230;
		public static var GREEN_MEDIUM:uint = 0x77c043;
		public static var GREEN_LIGHT:uint = 0x8ECA62;
		
		public static var WHITE:uint = 0xFFFFFF;
		public static var BLACK:uint = 0x000000;
		
		private static const allLetters:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZабвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";

		public static var lightColorPallete:Array=[
			0xABCCDE,
			0xEAC6C2,
			0xA5C99D,
			0xABBBDA,
			0xA1CBC9,
			0xDFD4AE,

			0xA3D9CF,
			0xE2CBB6,
			0xD5C3EC,
			0xD7B9C4,
			0xBDC8C7,
			0xD0CDC0,

			0xDEDCAB,
			0xAEE0B3,
			0xF3BDBD,
			0xC6BEC1,
			0xEAC8B0,
			0xE8B2B2,

			0x9BB1BC,
			0x7A9491,
			0x8F9567,
			0x697C80,
			0x607661,
			0x84A5B4
		]

		public static var colorPallete:Array = [0xABCCDE,
												0xEAC6C2,
												0xA5C99D,
												0xABBBDA,
												0xA1CBC9,
												0xDFD4AE,
												0xA3D9CF,
												0xE2CBB6,
												0xD5C3EC,
												0xD7B9C4,
												0xBDC8C7,
												0xD0CDC0,
												0xDEDCAB,
												0xAEE0B3,
												0xF3BDBD,
												0xC6BEC1,
												0xEAC8B0,
												0xE8B2B2,
												0xC1BDEB,
												0xD6DDA8,
												0xB4DBE8,
												0xF3C5D5,
												0xACDCD9,
												0xDBB9B9]
		
		static private var currentPalleteColor:Number = 0;
		
		public static function isLetterSupported(char:String):Boolean 
		{
			var regexp:RegExp = /[0-9a-zA-Zа-яёА-Я]/;
			return regexp.test(char);
		}
		
		public static function getColorFromPallete(text:String = null):Number
		{
			if (text != null)
			{
			//	var index:int = allLetters.indexOf(char);
				
				var index:uint = 0;
				for (var i:int = 0; i < text.length; i++) 
				{
					index += text.charCodeAt(i);
				}
				
				if (index >= colorPallete.length)
				{
					index = index % colorPallete.length;
				}
				
				return colorPallete[index];
				
			}
			currentPalleteColor ++;
			if (currentPalleteColor >= colorPallete.length)
			{
				currentPalleteColor = 0;
			}
			return colorPallete[currentPalleteColor];
		}
	}
}