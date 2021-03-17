package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RemoteSoundFileData extends RemoteFileData
	{
		public var duration:int;
		
		public function RemoteSoundFileData(id:String, duration:int) 
		{
			super(id);
			this.duration = duration;
		}
	}
}