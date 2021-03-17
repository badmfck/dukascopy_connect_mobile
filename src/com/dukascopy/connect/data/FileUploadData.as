package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FileUploadData 
	{
		static public const FAIL:String = "fail";
		static public const DONE:String = "done";
		static public const CANCEL:String = "cancel";
		static public const START:String = "start";
		
		public var fileName:String;
		public var id:String;
		public var status:String;
		
		public function FileUploadData() 
		{
			
		}
	}
}