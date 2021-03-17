/**
 * Created by aleksei.leschenko on 29.08.2016.
 */
package com.dukascopy.connect.sys.touchID {
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.dialogs.ScreenChangePayPassDialog;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.touchID.vo.VOTouchItem;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;

	import flash.events.StatusEvent;

	public class TouchIDManager {
		/**
		 * in that key write true\false if was ask touch id(use _noAskTouchID)
		 */
		private var _keyAskTouchID:String = "ask_touch_id";
		private var ASK_STATE_NAN:String = "-1";
		private var ASK_STATE_OFF:String = "0";
		private var ASK_STATE_ON:String = "1";
		private var _askStateDialog:String = "-1";
		/**
		 *
		 */
		private var _keyTouchID:String = "touch_id_info";
		/**
		 *
		 */
		private var _isTouchIDAvailable:Boolean;

		// for _keyAskTouchID
		private var _noAskTouchID:Boolean;

		static public var S_NO_ASK_TOUCH_ID:Signal = new Signal("_NO_ASK_TOUCH_ID");
		//
		private var _inProgress:Boolean;
		//
		private var dataToSave:Object;
		//
		private var _callbackFunction:Function;
		//
		private var _currVO:VOTouchItem = new VOTouchItem();
		public var waite_on_switcher:Boolean;
		/**
		 * manager touch id -> IOS
		 * account = String(Auth.phone)
		 * ask_touch_id = true/false
		 */
		public function TouchIDManager() {

			isTouchIDAvailable = MobileGui.dce.isTouchIDAvailable();

			if(isTouchIDAvailable){
				//for debug
//				Auth.setItem(_keyAskTouchID,"-1");
//				Auth.setItem(_keyTouchID,null);
				getDataTouchID(/*true*/);
				_inProgress = false;
				Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
			}
		}

		// update current state dataToSave
		private function getDataTouchID():void {
			if(dataToSave != null ) {
				return;
			}//read once
			//get value by cash
			var loadedData:String = Auth.getItem(_keyTouchID+PayAPIManager.SWISS_API_NAME);
			//save info how many asked data
			var str:String = Auth.getItem(_keyAskTouchID+PayAPIManager.SWISS_API_NAME); // + CURRENT_API_POSTFIX
			if (ASK_STATE_NAN == str) {
				_askStateDialog = str;
			} else if(ASK_STATE_OFF == str) {
				_askStateDialog = str;
			} else if(ASK_STATE_ON == str) {
				_askStateDialog = str;
			} else {
				_askStateDialog = ASK_STATE_NAN;
			}
			updateAskTouchID(false);
			try {
				dataToSave = JSON.parse(loadedData);
			} catch (e:Error) {
				dataToSave = null;
				return;
			}
		}
		
		private function onAuthNeeded():void {
			clear();
		}
		
		/**
		 *
		 * @return
		 */
		public function getSecretFrom():Boolean {
			if (isTouchIDAvailable == false) {
				return false;
			}
			if(_inProgress ){
				return _askStateDialog != ASK_STATE_OFF;
			}
			
			if(_askStateDialog == ASK_STATE_ON ){
				return false;
			}
			//
			getDataTouchID();
			//
			var wasSecret:Boolean;
			_currVO.account = String(Auth.phone);
			if (dataToSave != null && _currVO.account in dataToSave && _askStateDialog == ASK_STATE_OFF) {
				_currVO.secret = dataToSave[_currVO.account] || "";
				if(_currVO.secret != "") {//dell acc
					MobileGui.dce.removeTouchIDItem(_currVO.account);
					//set new acc
					MobileGui.dce.addTouchIDItem(_currVO.account, _currVO.secret);
					//show native popUp
					MobileGui.dce.getTouchIDItem(_currVO.account, Lang.touchIdPressCansel);
					wasSecret = true;
				}else{
					//MobileGui.dce.removeTouchIDItem(_currVO.account);
				}
			}
			if(wasSecret == false) {
				if(_noAskTouchID == false && _callbackFunction != null){
					_callbackFunction(0,"");// 0 - , "" - ;
				}
			}
			return wasSecret
		}

		public function changePassTouchID(secret:String):void {
			if(_isTouchIDAvailable == false)return;
			if(_currVO.secret != secret){
				_currVO.secret = secret;
				_currVO.account = String(Auth.phone);
				setDataTouchID();
			}
		}

		public function saveTouchID(secret:String, isShowUseTouchID:Boolean = true):void {
			if(_isTouchIDAvailable == false)return;
			if(_inProgress || _askStateDialog == ASK_STATE_OFF)return;

			var wasSecret:Boolean;
			_currVO.account = String(Auth.phone);
			_currVO.secret = secret;
			if(dataToSave != null && _currVO.account in dataToSave && _currVO.secret != ""){
				wasSecret = true;
				if(isShowUseTouchID && _askStateDialog == ASK_STATE_NAN){
					if(waite_on_switcher){
						_askStateDialog = ASK_STATE_OFF;
						updateAskTouchID();
						setDataTouchID();
						waite_on_switcher = false;
					}else{
						if (DialogManager.hasOpenedDialog == true && MobileGui.dialogScreen.currentScreenClass == ScreenChangePayPassDialog)
						{
							return;
						}
						DialogManager.showUseTouchID(callbackUseTouchIDDialog);
					}
				}
			}
			if(wasSecret == false){
				if(_askStateDialog == ASK_STATE_ON){
					if(_callbackFunction != null){
						_callbackFunction(0,"");
					}else{
						//trace(" ");
					}
				}else {
					if(isShowUseTouchID){
						if(waite_on_switcher){
							_askStateDialog = ASK_STATE_OFF;
							updateAskTouchID();
							setDataTouchID();
							waite_on_switcher = false;
						}else{
							DialogManager.showUseTouchID(callbackUseTouchIDDialog);
						}
					}else{
						callbackUseTouchIDDialog("1");//yes by default
					}
				}
			}else{
				setDataTouchID();
			}
		}
		
		public function extensionStatusHandler(e:StatusEvent):void {
			if (_isTouchIDAvailable  == false)
				return;
			var obj:Object;
			switch (e.code) {
				case "didFetchTouchIDItem": {// ok
					if(_callbackFunction != null){
						TweenMax.delayedCall(10, function():void{
							_inProgress = false;
						});
						obj = JSON.parse(e.level);
						_currVO.secret = obj.item || "";
						if(_currVO.secret != ""){
							_callbackFunction(1,_currVO.secret);
							_inProgress = true;
							_callbackFunction = null;
						}
					}
					break;
				}
				case "didFailFetchTouchID": {
					MobileGui.dce.addTouchIDItem(_currVO.account,_currVO.secret);
					obj = JSON.parse(e.level);
					if(_callbackFunction != null){
						_callbackFunction(0,"");
					}
					break;
				}
				case "didFailAddTouchIDItem": {
					MobileGui.dce.removeTouchIDItem(_currVO.account);
					MobileGui.dce.addTouchIDItem(_currVO.account,_currVO.secret);
					break;
				}
				case "didFailFetchTouchID": {
					break;
				}
				case "didAddTouchIDItem": {
					break;
				}
				case "didRemoveTouchIDItem"	: {
					break;
				}
				case "didFailToRemoveTouchIDItem": {
					break;
				}
				case "alert_didTapCancelButton": {
					break;
				}
				case "alert_didTapActionButton": {
					break;
				}
				default: {
					break;
				}
			}
		}

		/**
		 *	isTouchIDAvailable():Boolean;
		 *	addTouchIDItem(account:String,secret:String):void;
		 *	updateTouchIDItem(account:String,secret:String,operationPrompt:String):void;
		 *	removeTouchIDItem(account:String):void;
		 *	getTouchIDItem(account:String,operationPrompt:String):void;
		 *
		 */
		public function doPayPass():void {
			if (MobileGui.dce == null)
				return;
			if (isTouchIDAvailable == false)
				return;
			if (isEmpty(dataToSave)) {
				return;
			}
			_currVO.account = String(Auth.phone);
			if(dataToSave != null && _currVO.account in dataToSave){
				_currVO.secret = dataToSave[_currVO.account];
			}
			MobileGui.dce.getTouchIDItem(_currVO.account,Lang.touchIdPaymentAuth);
		}
		
		private function setDataTouchID():void {
			var newDataString:String = "";
			dataToSave = {};
			dataToSave[_currVO.account] = _currVO.secret;
			newDataString = JSON.stringify(dataToSave);
			Auth.setItem(_keyTouchID +PayAPIManager.SWISS_API_NAME,newDataString);
			saveNoAskTouchID();
		}
		
		private function callbackUseTouchIDDialog(value:String):void {
			var isClear:Boolean; switch (value){
				case "0":{//x||close
					_askStateDialog = ASK_STATE_NAN;
					isClear=true;
					break;
				}
				case "1":{//ok
					_askStateDialog = ASK_STATE_OFF;
					break;
				}
				case "2":{//no
					_askStateDialog = ASK_STATE_ON;
					break;
				}
				default:{
					_askStateDialog = ASK_STATE_NAN;
					break
				}
			}
			if (isClear) {
				clear(false);
			} else {
				updateAskTouchID();
				setDataTouchID();
			}
		}
		
		private function saveNoAskTouchID():void {
			Auth.setItem(_keyAskTouchID + PayAPIManager.SWISS_API_NAME, _askStateDialog);
		}
		
		public function set callbackFunction(value:Function):void {
			_callbackFunction = value;
		}
		
		private function isEmpty(object:Object):Boolean {
			for (var i:* in object) {
				return false;
				break;
			}
			return true;
		}
		
		public function switchOnOff(isOn:Boolean):void {
			if (isOn) {
				_askStateDialog = ASK_STATE_OFF;
			} else {
				_askStateDialog = ASK_STATE_ON;
			}
			updateAskTouchID(false);
			setDataTouchID();
		}
		
		public function clear(needCallback:Boolean = true):void {
			if (needCallback) {
				_currVO.clear();
				_askStateDialog = ASK_STATE_NAN;
				_inProgress = false;
				Auth.setItem(_keyTouchID+PayAPIManager.SWISS_API_NAME,"");
				Auth.setItem(_keyAskTouchID+PayAPIManager.SWISS_API_NAME,_askStateDialog);
				dataToSave = null;
				waite_on_switcher = false;
				return;
			}
			updateAskTouchID(false);
			setDataTouchID();
			dataToSave = null;
		}
		
		public function updateAskTouchID(invoke:Boolean = true):void {
			switch(_askStateDialog){
				case ASK_STATE_NAN:{
					_noAskTouchID = true;
					break;
				}
				case ASK_STATE_OFF:{
					_noAskTouchID = false;
					break;
				}
				case ASK_STATE_ON:{
					_noAskTouchID = true;
					break;
				}
			}
			if (S_NO_ASK_TOUCH_ID != null && invoke)
				S_NO_ASK_TOUCH_ID.invoke();
		}
		
		public function removeCurrent():void 
		{
			if (MobileGui.dce != null)
			{
				MobileGui.dce.removeTouchIDItem(String(Auth.phone));
			}
		}
		
		public function get noAskTouchID():Boolean {
			updateAskTouchID(false);
			return _noAskTouchID;
		}
		
		public function get isTouchIDAvailable():Boolean { return _isTouchIDAvailable; }
		public function set isTouchIDAvailable(value:Boolean):void {
			_isTouchIDAvailable = value;
		}
		
		public function get secret():String {
			return _currVO.secret;
		}
		
		public function get useTouchID():Boolean {
			if (isTouchIDAvailable == false)
				return  false;
			return !noAskTouchID;
		}
		
		public function get callbackFunction():Function {
			return _callbackFunction;
		}
	}
}