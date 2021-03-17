package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BackgroundModel 
	{
		public var id:String;
		public var big:Class;
		public var small:Class;
		public var averageColor:uint;
		public var invertedColor:uint;
		
		public function BackgroundModel(id:String = null, big:Class = null, smallItemPath:Class = null, averageBackgroundColor:uint=0xffffff, invertedBackgroundColor:uint = 0xffffff) 
		{
			this.id = id;
			this.big = big;
			this.small = smallItemPath;
			this.averageColor = averageBackgroundColor;
			this.invertedColor = invertedBackgroundColor;
		}
		
	}

}