package com.dukascopy.connect.sys.speechControl.recognizer 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SimpleRecognizer
	{
		private var keywords:Array;
		public var result:String;
		
		public function SimpleRecognizer(result:String, keywords:Array) 
		{
			this.result = result;
			this.keywords = keywords;
		}
		
		public function recognize(item:String):Boolean 
		{
			var k:int = keywords.length;
			
			for (var j:int = 0; j < k; j++) 
			{
				if (item == keywords[j])
					{
					return true;
				}
			}
			
			return false;
		}
	}
}