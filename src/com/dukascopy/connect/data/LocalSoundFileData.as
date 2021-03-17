package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LocalSoundFileData 
	{
		public var path:String;
		public var duration:int;
		
		public function LocalSoundFileData(path:String, duration:int) 
		{
			this.path = path;
			this.duration = duration;
		}
	}
}