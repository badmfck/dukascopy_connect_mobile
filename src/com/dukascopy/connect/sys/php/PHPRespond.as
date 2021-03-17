package com.dukascopy.connect.sys.php {
	
	import com.dukascopy.connect.data.ResponseResolver;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;

	/**
	 * ...
	 * @author ...
	 */
	
	public class PHPRespond {
		
		private var _additionalData:Object;
		private var _error:Boolean = false;
		private var _errorMsg:String = "";
		private var _errorMsgLocalized:String = "";
		private var _data:Object = null;
		private var php:IDataLoader;
		
		public function PHPRespond(php:IDataLoader = null) {
			this.php = php;
		}
		
		public function setData(error:Boolean, errorMsg:String, data:Object = null, additionalData:Object = null):PHPRespond {
			_data = data;
			_additionalData = additionalData;
			_errorMsg = errorMsg;
			if (errorMsg != null && errorMsg != "")
			{
				_errorMsgLocalized = ErrorLocalizer.getText(_errorMsg);
			}
			
			_error = error;
			if (_error == true)
				echo("PHPRespond (" + ((php == null) ? "null" : php.getID()) + ")", "setData", "Error: " + _errorMsg);
			return this;
		}
		
		public function dispose():void {
			_data = null;
			if (_additionalData is ResponseResolver)
				_additionalData.dispose();
			_additionalData = null;
			_errorMsg = null;
			_error = false;
			if (php != null) {
				echo("PHPRespond (" + php.getID() + ")", "dispose", "");
				php.dispose();
			}
			php = null;
		}
		
		public function get error():Boolean { return _error; }
		public function get errorMsg():String { return _errorMsg; }
		public function get errorMsgLocalized():String { return _errorMsgLocalized; }
		public function get data():Object { return _data; }
		public function get additionalData():Object { return _additionalData; }
	}
}