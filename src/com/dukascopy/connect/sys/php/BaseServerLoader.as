package com.dukascopy.connect.sys.php {
	
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class BaseServerLoader {
		
		protected var rawRespond:Boolean;
		protected var callBack:Function;
		
		public function BaseServerLoader() {
			
		}
		
		public function dispose():void {
			callBack = null;
		}
		
		static public function createRespond(error:String, strData:String, callBack:Function, respond:PHPRespond = null, rawRespond:Boolean = false, id:int = 0, additionalData:Object = null):void {
			if (respond == null)
				respond = new PHPRespond();
			// Network error
			if (error != null) {
				echo("PHPLoader (" + id + ")", "createRespond", "Network error");
				sendCallBack(respond.setData(true, error, null, additionalData), callBack, id);
				return;
			}
			// raw respond
			if (rawRespond == true) {
				echo("PHPLoader (" + id + ")", "createRespond", "Raw respond");
				sendCallBack(respond.setData(false, '', strData, additionalData), callBack, id);
				return;
			}
			var data:Object = null;
			try {
				data = JSON.parse(strData);
			} catch (err:Error) {
				echo("PHPLoader (" + id + ")", "createRespond", "ERROR: JSON can't parse (Reason: " + err.message + ")");
				sendCallBack(respond.setData(true, 'Json error:  ' + strData.substr(0, 200), null, additionalData), callBack, id);
				return;
			}
			if (!('status' in data)){
				echo("PHPLoader (" + id + ")","createRespond", "PHP -> ERROR -> "+respond.errorMsg);
				sendCallBack(respond.setData(true, 'No status object', data, additionalData), callBack, id);
				return;
			}
			if (!('error' in data.status)){
				echo("PHPLoader (" + id + ")","createRespond", "PHP -> ERROR -> "+respond.errorMsg);
				sendCallBack(respond.setData(true, 'No proper status object, no error', data, additionalData), callBack, id);
				return;
			}
			// CORE ERROR
			if (data.status.error == true){
				if (callBack != null){
					if (String((data.status.errorMsg) + "").toLowerCase().indexOf('core') == 0) {
						var errorCode:String = data.status.errorMsg.substr(5, 2);
						if (errorCode == "09" || errorCode == "08" || errorCode == "01" || errorCode == "02" || errorCode == "03" || errorCode == "04") {
							Auth.isExpired = true;
							DialogManager.alert(Lang.textError, data.status.errorMsg.substr(8));
							Auth.clearAuthorization(errorCode);
						}
					}
					sendCallBack(respond.setData(true, data.status.errorMsg, data, additionalData),callBack, id);
				}
				return;
			}
			// NO DATA OBJECT
			if (!('data' in data)) {
				echo("PHPLoader (" + id + ")", "createRespond", "PHP -> ERROR -> " + respond.errorMsg);
				sendCallBack(respond.setData(true, 'No data object', null, additionalData), callBack, id);
				return;
			}
			// NORMAL
			if ("status" in data && "respondTime" in data.status && data.status.respondTime > 1)
				echo("PHPLoader (" + id + ")", "createRespond", "respondTime: " + data.status.respondTime);
			sendCallBack(respond.setData(false, '', data.data, additionalData),callBack, id);
		}
		
		static private function sendCallBack(respond:PHPRespond,callBack:Function,id:int = 0):void {
			if (callBack == null) {
				respond.dispose();
				return;
			}
			TweenMax.delayedCall(1, function():void { 
				echo("PHPLoader (" + id + ")", "sendCallBack", "TweenMax.delayedCall");
				if (callBack == null) {
					respond.dispose();
					return;
				}
				callBack(respond);
			}, null, true);
			
		}
	}
}