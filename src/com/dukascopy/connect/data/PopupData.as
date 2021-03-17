package com.dukascopy.connect.data 
{
	import assets.BoredIllustrationClip;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PopupData 
	{
		public var action:IScreenAction;
		public var illustration:Class;
		public var title:String;
		public var text:String;
		public var callback:Function;
		public var data:Object;
		public var timeData:Object;
		
		public function PopupData() 
		{
			
		}
	}
}