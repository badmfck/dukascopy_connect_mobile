package com.dukascopy.connect.sys.payments {
	import com.dukascopy.connect.sys.echo.echo;

	public class PayRespond {
	
		// Authorization Level Errors
		static public const ERROR_CODE_SESSION_INVALID:int = 2000;
		static public const ERROR_NEED_PASSWORD:int = 2010;
		static public const ERROR_NEED_PASSWORD_CHANGE:int = 2011;
		static public const ERROR_CODE_TOO_MANY_WRONG_PASSWORD_ENTERED:int = 2012;
		static public const ERROR_CODE_ACCOUNT_IS_BLOCKED:int = 2015;
		static public const ERROR_CODE_NETWORK:int = -2;
		
		static public const ERROR_PASSWORD_INVALID:int = 3202;		// Password is invalid
		static public const ERROR_VERIFICATION_BLOCKED:int = 3212;	// Too many failed attempts during short period of time
		static public const ERROR_NOT_APPROVED_ACCOUNT:int = 2020;	// Password is valid but correspondent account has not yet been approved.
		
		static public const ERROR_TRIAL_LIMIT_REACHED:int = 3010; // trial limit reached
		static public const ERROR_SERVER_NOT_RESPONDING:int = 0; // server kosjachit
		static public const ERROR_EXPIRED_TIMESTAMP:int = 1020; // server kosjachit
		static public const ERROR_TRANSACTION_LIMIT:int = 3408; //
		static public const ERROR_DAILY_LIMIT:int = 3409; //
		static public const ERROR_PASS_CHANGE_INVALID:int = 4101; //
		
		
		private var _errorCode:int = -1;
		private var _error:Boolean=false;
		private var _errorMsg:String='';
		private var _data:Object = null;
		private var _savedRequestData:Object = null;
		
		private var _php:PayLoader;

		public function PayRespond(php:PayLoader) {
			_php = php;
		}
		
		public function setData(error:Boolean, errorMsg:String, data:Object = null, errorCode:int = -1):PayRespond {
			_data = data;
			_error = error;
			_errorMsg = errorMsg;
			_errorCode = errorCode;
			if (_error == true) {
				if (_php != null)
					echo("PayRespond (" + _php.id + ")", "setData", "ERROR\n	code: " + _errorCode + "\n	message: " + _errorMsg);
				else
					echo("PayRespond", "setData", "ERROR\n	code: " + _errorCode + "\n	message: " + _errorMsg);
			}
			return this;
		}
		
		/**
		 * Saves data which was called to get this Response 
		 * for reapiting call with the same data
		 * this is used when error ocurred (ex. need password) and we need to call it again 
		 * @param	requestData
		 */
		public function setSavedRequestData(requestData:Object):void {
			_savedRequestData = requestData;
		}
		
		public function get hasAuthorizationError():Boolean {
			if (_errorCode == ERROR_NEED_PASSWORD_CHANGE  || 
				_errorCode == ERROR_NEED_PASSWORD  || 
				_errorCode == ERROR_CODE_SESSION_INVALID || 
				_errorCode == ERROR_CODE_ACCOUNT_IS_BLOCKED || 
				_errorCode == ERROR_NOT_APPROVED_ACCOUNT)
					return true;
			return false;
		}
		public function get hasNetworkError():Boolean {
			return _errorCode == ERROR_CODE_NETWORK;
		}
		
		public function get hasServerRespondError():Boolean {
			return _errorCode == ERROR_SERVER_NOT_RESPONDING;
		}
		
		public function get hasTrialVersionError():Boolean {
			return _errorCode == ERROR_TRIAL_LIMIT_REACHED;
		}
		
		public function get data():Object { return _data; }
		public function get error():Boolean { return _error; }	
		public function get errorCode():int { return _errorCode; }	
		public function get errorMsg():String { return _errorMsg; }	
		public function get savedRequestData():Object { return _savedRequestData }
		
		//public function get isSwiss():Boolean { return _data.url }
		
		public function dispose():void {
			_data = null;
			_savedRequestData = null;
			_errorMsg = null;
			_error = false;
			_errorCode = -1;
			if (_php != null) {
				echo("PayRespond (" + _php.id + ")", "dispose", "");
				_php.dispose();
			}
		}
	}
}