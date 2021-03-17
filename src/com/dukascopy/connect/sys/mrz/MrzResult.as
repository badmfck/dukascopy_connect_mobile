package com.dukascopy.connect.sys.mrz 
{
	import com.dukascopy.langs.Lang;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class MrzResult 
	{
		public var error:Boolean;
		public var data:MrzData;
		public var imagePath:String;
		public var errorText:String;
		public var promoCode:String;
		
		public function MrzResult(error:Boolean, data:MrzData, errorText:String = null) 
		{
			this.error = error;
			this.data = data;
			this.errorText = errorText;
		}
		
		public function getErrorLocalized():String 
		{
			if (error == true && errorText != null)
			{
				switch(errorText)
				{
					case MrzError.ALREADY_STARTED:
					{
						return Lang.mrzScanAlreadyStarted;
					}
					case MrzError.ENGINE_INIT_FAILED:
					{
						return Lang.mrzScanInitFailed;
					}
					case MrzError.NO_CAMERA_PERMISSION:
					{
						return Lang.mrzScanNeedPermission;
					}
					case MrzError.NO_DOCUMENT_FOUND:
					{
						return Lang.mrzScanNoDocumentFound;
					}
					case MrzError.RESULT_DATA_BROKEN_FORMAT:
					{
						return Lang.mrzScanCritError;
					}
					case MrzError.RESULT_DATA_EMPTY:
					{
						return null;
					}
				}
			}
			return null;
		}
	}
}