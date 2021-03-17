package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ScanPassportResult 
	{
		public var success:Boolean;
		public var photo:ImageBitmapData;
		
		public function ScanPassportResult(success:Boolean, photo:ImageBitmapData = null) 
		{
			this.success = success;
			this.photo = photo;
		}
	}
}