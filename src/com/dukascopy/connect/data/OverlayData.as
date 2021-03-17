package com.dukascopy.connect.data 
{
	import assets.FlowerType_1_small;
	import assets.FlowerType_2_small;
	import assets.FlowerType_3_small;
	import assets.FlowerType_4_small;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OverlayData 
	{
		static public const CROWN:String = "crown";
		static public const TOAD:String = "toad";
		static public const JAIL:String = "jail";
		static public const FLOWER_1:String = "FLOWER_1";
		static public const FLOWER_2:String = "FLOWER_2";
		static public const FLOWER_3:String = "FLOWER_3";
		static public const FLOWER_4:String = "FLOWER_4";
		
		public var crown:Boolean;
		public var toad:Boolean;
		public var jail:Boolean;
		public var flower_1:Boolean;
		public var flower_2:Boolean;
		public var flower_3:Boolean;
		public var flower_4:Boolean;
		
		public function OverlayData() 
		{
			
		}
		
		static public function getIcon(type:String):Class 
		{
			switch(type)
			{
				case CROWN:
				{
					return SWFCrownIcon;
					break;
				}
				case TOAD:
				{
					return SWFFrog;
					break;
				}
				case JAIL:
				{
					return Style.icon(Style.ICON_JAILED);
					break;
				}
				case FLOWER_1:
				{
					return FlowerType_1_small;
					break;
				}
				case FLOWER_2:
				{
					return FlowerType_2_small;
					break;
				}
				case FLOWER_3:
				{
					return FlowerType_3_small;
					break;
				}
				case FLOWER_4:
				{
					return FlowerType_4_small;
					break;
				}
			}
			return Sprite;
		}
	}
}