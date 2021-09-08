package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ErrorData 
	{
		public var code:String;
		public var message:String;
		
		public function ErrorData(raw:Object) 
		{
			if (raw != null)
			{
				if ("code" in raw && raw.code != null)
				{
					code = raw.code;
				}
				if ("msg" in raw && raw.msg != null)
				{
					message = raw.msg;
				}
			}
		}
	}
}