package com.dukascopy.connect.sys.localFiles 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LoadFileData 
	{
		public var progress:int;
		public var fileId:String;
		public var status:String;
		public var data:Object;
		
		public function LoadFileData(fileId:String, status:String, data:Object = null, progress:int = 0) 
		{
			this.fileId = fileId;
			this.status = status;
			this.data = data;
			this.progress = progress;
		}	
	}
}