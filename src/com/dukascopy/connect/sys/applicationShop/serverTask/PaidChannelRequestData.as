package com.dukascopy.connect.sys.applicationShop.serverTask 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidChannelRequestData 
	{
		public var settingsValues:Object;
		public var mode:String;
		public var title:String;
		
		public function PaidChannelRequestData(title:String = null, mode:String = null, settingsValues:Object = null) 
		{
			this.title = title;
			this.mode = mode;
			this.settingsValues = settingsValues;
		}
	}
}