package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ErrorData 
	{
		public var dccError:String;
		public var id:String;
		public var code:String;
		public var message:String;
		
		public function ErrorData(raw:Object, id:String = null) 
		{
			this.id = id;
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
				if ("dccError" in raw && raw.dccError != null)
				{
					dccError = raw.dccError;
				}
			}
		}
		
		public function getDisplayError():String 
		{
			var result:String;
			if (dccError  != null)
			{
				result = ErrorLocalizer.getText(dccError);
			}
			if (result == null)
			{
				result = message;
			}
			return result;
		}
	}
}