package com.dukascopy.connect.data 
{
	import assets.StarIcon3;
	import com.dukascopy.connect.sys.style.Style;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class AlertScreenData 
	{
		public var icon:Class;
		public var title:String;
		public var text:String;
		public var button:String;
		public var callback:Function;
		public var iconColor:Number = Style.color(Style.COLOR_TEXT);
		public var mainTitle:String;
		public var textColor:Number = NaN;
		public var callbackData:Object;
		
		public function AlertScreenData() 
		{
			
		}
	}
}