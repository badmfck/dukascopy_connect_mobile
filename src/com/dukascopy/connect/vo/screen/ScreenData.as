package com.dukascopy.connect.vo.screen
{
	import com.dukascopy.connect.utils.TextUtils;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ScreenData 
	{
		public var backScreen:Class;
		//need type ScreenData;
		public var backScreenData:Object;
		public var additionalData:Object;
		
		public function ScreenData() 
		{
			
		}
		
		public function toString():String
		{
			return TextUtils.objectToString(this);
		}
	}
}