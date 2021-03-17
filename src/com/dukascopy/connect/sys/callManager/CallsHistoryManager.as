package com.dukascopy.connect.sys.callManager 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.CallHistoryType;
	import com.dukascopy.connect.vo.CallVO;
	import com.dukascopy.connect.vo.CallsHistoryItemVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CallsHistoryManager {
		
		static public const S_CALLS:Signal = new Signal("CallsHistoryManager.S_CALLS");
		static public const S_CALLS_FINISHED_LOADING:Signal = new Signal("CallsHistoryManager.S_CALLS_FINISHED_LOADING");
		static public const S_MISSED_NUM:Signal = new Signal("CallsHistoryManager.S_MISSED_NUM");
		
		static private var _calls:Vector.<CallsHistoryItemVO>;
		static private var currentHash:String = "";
		
		static private var inited:Boolean = false;
		static private var active:Boolean = false;
		static private var busy:Boolean = false;
		static private var _callsResponded:Boolean = false;
		static private var newMissedCallsNum:int = 0;
		
		public function CallsHistoryManager() { }
		
		public static function activate():void {
			active = true;
		}
		
		public static function deactivate():void {
			active = false;
			//clear();
		}
		
		/**
		 * добавление/обновление звонка
		 * @param	callId		String - id звонка
		 * @param	callType	String - направление звонка CallHistoryType (incoming, outgoing)
		 * @param	mode 		String - CallManager.MODE_
		 * @param	userUID		String - uid собеседника
		 * @param	userName	String - имя собеседника
		 * @param	userAvatar	String - аватар собеседника
		 * @param	status		String - accepted, rejected, canceled, placed
		 * @param	timestamp	Number - unix timestamp события звонка
		 */
		private static function addCall(callVO:CallVO, status:String):void {
			_calls ||= new Vector.<CallsHistoryItemVO>();
			var chiVO:CallsHistoryItemVO;
			var l:int = _calls.length;
			for (var i:int = 0; i < l; i++) {
				if (_calls[i].id == callVO.id) {
					chiVO = _calls[i];
					break;
				}
			}
			if (chiVO != null) {
				if (callVO.type == CallManager.TYPE_OUTGOING) {
					PHP.updateCallInfo(chiVO.id, getCallStatusForPHP(chiVO.state, status), onCallInfoUpdated);
				} else {
					//если находимся не на экране звонков, входящий пропущенный необходимо отобразить в счётчике новых пропущенных;
					if (callVO.entryPointID > 0)
						PHP.updateCallInfo(chiVO.id, getCallStatusForPHP(chiVO.state, status, callVO.type == CallManager.TYPE_INCOMING), onCallInfoUpdated);
					if (chiVO.state == "placed" && status == "canceled") {
						chiVO.unsetViewed();
					}
					chiVO.setState(getCallStatusForPHP(chiVO.state, status, callVO.type == CallManager.TYPE_INCOMING));
				}
			} else {
				var chiData:Object = {
					cID: callVO.id,
					sTime: Math.floor((new Date()).getTime() / 1000),
					type: (callVO.type == CallManager.TYPE_OUTGOING),
					state: convertToPhpStatus(status)
				}
				chiVO = new CallsHistoryItemVO(chiData);
				
				var user:UserVO = UsersManager.getFullUserData(callVO.uid);
				if (user == null) {
					user = UsersManager.getUserByCallUserObject(callVO);
				}
				chiVO.setUser(user);
				
				if (callVO.entryPointID != 0)
					chiVO.setData( { pid: callVO.entryPointID, pidTitle: callVO.name } );
				if ((callVO.type == CallManager.TYPE_OUTGOING || callVO.entryPointID > 0) && chiVO.userUID != null)
					PHP.sendNewCallInfo(chiVO, onCallInfoSent);
				_calls.push(chiVO);
				sort();
			}
			calcNewMissed();
			S_MISSED_NUM.invoke(newMissedCallsNum);
			S_CALLS.invoke();
		}
		
		static public function convertToPhpStatus(status:String):String {
			switch(status)
			{
				case "placed":
					return "placed";
					break;
				case "start":
					return "start";
					break;
				case "accepted":
					return "accepted";
					break;
				case "rejected":
					return "rejected";
					break;
				case "canceled":
					return "canceled";
					break;
				case "busy":
					return "busy";
					break;;
				default:
					return "placed";
					break;
			}
		}
		
		static private function getCallStatusForPHP(oldStatus:String, newStatus:String, incoming:Boolean = false):String 
		{
			if (oldStatus == "missed")
			{
				return "missed";
			}
			else if (oldStatus == "start")
			{
				if (newStatus == CallManager.STATUS_CANCELED_BY_SELF)
				{
					return "missed";
				}
				
				return newStatus;
			}
			else if (oldStatus == "placed")
			{
				if (newStatus == "canceled")
				{
					if (incoming)
					{
						return "missed";
					}
					return CallManager.STATUS_CANCELED;
				}
				else if (newStatus == CallManager.STATUS_CANCELED_BY_SELF)
				{
					return "missed";
				}
				return newStatus;
			}
			
			return newStatus;
		//	 @param string $t enum ('placed', 'accepted', 'canceled', 'busy', 'rejected', 'finished', missed, busy)
		}
		
		static private function onCallInfoUpdated(r:PHPRespond):void {
			trace(r);
			r.dispose();
		}
		
		public static function getNewMissedNum():int {
			return newMissedCallsNum;
		}
		
		static private function onCallInfoSent(r:PHPRespond):void {
			trace(r);
			r.dispose();
		}
		
		static public function init():void {
			if (inited == true)
				return;
			inited = true;
			WS.S_CONNECTED.add(onWSConnected);
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
			CallManager.S_CALL_STATUS_CHANGED.add(onCallStatusChanged);
			Auth.S_AUTHORIZED.add(onAutorized);
		}
		
		static private function onAutorized():void {
			//getCalls();
		}
		
		static private function onCallStatusChanged(status:String):void{
			//слать статус с нужными данными на сервер
			
			
			var cvo:CallVO = CallManager.getCallVO();
			if (cvo == null){
				echo("CallsHistoryManager", "onCallStatusChanged", "callvo is null!", true);
				return;
			}
			
			addCall(cvo, status);
		}
		
		static private function onAuthNeeded():void {
			// TODO - NEED DISPOSE CONTACTS, ILYA
			_calls = null;
			currentHash = "";
			inited = false;
			active = false;
			busy = false;
			_callsResponded = false;
		}
		
		static private function onWSConnected():void {
			if (active == false)
				return;
			//clear();
			TweenMax.delayedCall(1, function():void {
				echo("CallsHistoryManager", "onWSConnected", "TweenMax.delayedCall");
				if (currentHash != null && currentHash != "") {
					loadCallsFromPHP(currentHash);
					return;
				}
				Store.load(Store.VAR_CALLS_HASH, onLoadHashFromStore);
			}, null, true);
		}
		
		static public function getCalls():void {
			
			if (_calls != null) {
				S_CALLS.invoke();
				return;
			}
			
			TweenMax.delayedCall(1, function():void {
				echo("CallsHistoryManager", "getCalls", "TweenMax.delayedCall");
				Store.load(Store.VAR_CALLS, onLoadCallsFromStore);
			}, null, true);
		}
		
		static public function getAllCalls():Vector.<CallsHistoryItemVO>
		{
			return calls;
		}
		
		static public function getMissedCalls():Vector.<CallsHistoryItemVO> {
			if (!_calls)
				return null;
			var missedCalls:Vector.<CallsHistoryItemVO> = new Vector.<CallsHistoryItemVO>();
			var l:int = _calls.length;
			for (var i:int = 0; i < l; i++) {
				if ((_calls[i].state == "missed" && _calls[i].type == CallHistoryType.INCOMING)) {
					missedCalls.push(_calls[i]);
				}
			}
			return missedCalls;
		}
		
		static public function markNewAsSeen():void {
			PHP.markCallsSeen(onCurrentCallsSeenPhpResponce);
			if (!_calls)
				return;
			var l:int = _calls.length;
			for (var i:int = 0; i < l; i++)
				_calls[i].setViewed();
			calcNewMissed();
			S_MISSED_NUM.invoke(0);
		}
		
		static public function getMissedNum():int {
			calcNewMissed();
			return newMissedCallsNum;
		}
		
		static private function onCurrentCallsSeenPhpResponce(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				S_CALLS.invoke();
				busy = false;
				phpRespond.dispose();
				return;
			}
			phpRespond.dispose();
		}
		
		static private function onLoadCallsFromStore(data:Object, error:Boolean):void {
			TweenMax.delayedCall(1, function():void {
				echo("CallsHistoryManager", "onLoadCallsFromStore", "TweenMax.delayedCall");
				if (data != null) {
					if (_calls != null)
						clear();
					_calls = new Vector.<CallsHistoryItemVO>;
					var callsCount:int = data.length;
					for (var i:int = 0; i < callsCount; i++)
						addCallModel(new CallsHistoryItemVO(data[i]));
					calcNewMissed();
					S_MISSED_NUM.invoke(newMissedCallsNum);
					sort();
					_callsResponded = true;
					S_CALLS.invoke();
				}
				TweenMax.delayedCall(1, function():void {
					echo("CallsHistoryManager", "onLoadCallsFromStore", "TweenMax.delayedCall (data is null)");
					Store.load(Store.VAR_CALLS_HASH, onLoadHashFromStore);
				}, null, true);
			}, null, true);
		}
		
		static private function onLoadHashFromStore(data:String, error:Boolean):void {
			TweenMax.delayedCall(1, function():void {
				echo("CallsHistoryManager", "onLoadHashFromStore", "TweenMax.delayedCall");
				if (_calls == null)
					data = "";
				loadCallsFromPHP(data);
			}, null, true);
		}
		
		static private function loadCallsFromPHP(hash:String):void {
			if (!hash) {
				hash = "0";
			}
			TweenMax.delayedCall(1, function():void {
				echo("CallsHistoryManager", "loadCallsFromPHP", "TweenMax.delayedCall");
				PHP.calls_get(onLoadCallsFromPHP, hash);
			}, null, true);
		}
		
		static private function onLoadCallsFromPHP(phpRespond:PHPRespond):void {
			_callsResponded = true;
			S_CALLS_FINISHED_LOADING.invoke(phpRespond.error);
			if (phpRespond.error == true) {
				S_CALLS.invoke();
				busy = false;
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				S_CALLS.invoke();
				busy = false;
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data is Boolean) {
				S_CALLS.invoke();
				busy = false;
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data && phpRespond.data.calls == null) {
				S_CALLS.invoke();
				busy = false;
				phpRespond.dispose();
				return;
			}
			TweenMax.delayedCall(1, function():void {
				echo("CallsHistoryManager", "onLoadCallsFromPHP", "TweenMax.delayedCall");
				busy = false;
				Store.save(Store.VAR_CALLS, phpRespond.data.calls);
				if (phpRespond.data.hash != null)
					Store.save(Store.VAR_CALLS_HASH, phpRespond.data.hash);
				if (_calls != null)
					clear();
				_calls = new Vector.<CallsHistoryItemVO>();
				var callsCount:int = phpRespond.data.calls.length;
				for (var i:int = 0; i < callsCount; i++)
					addCallModel(new CallsHistoryItemVO(phpRespond.data.calls[i]));
				calcNewMissed();
				S_MISSED_NUM.invoke(newMissedCallsNum);
				sort();
				S_CALLS.invoke();
				phpRespond.dispose();
			}, null, true);
		}
		
		static private function calcNewMissed():void 
		{
			newMissedCallsNum = 0;
			if (!_calls)
			{
				return;
			}
			var l:int = _calls.length;
			for (var i:int = 0; i < l; i++) 
			{
				if (_calls[i].state == "missed" && !_calls[i].view && _calls[i].type == CallHistoryType.INCOMING)
				{
					newMissedCallsNum ++;
				}
			}
		}
		
		static private function sort():void {
			var array:Array = [];
			while(_calls.length > 0) array.push(_calls.pop());
			
			array.sortOn("sTime", Array.NUMERIC);
			while (array.length > 0) _calls.push(array.pop());
		}
		
		static private function addCallModel(cvo:CallsHistoryItemVO):void {
			_calls.push(cvo);
		}
		
		static private function clear():void {
			if (_calls != null) {
				while (calls.length != 0) {
					calls[0].dispose();
					calls[0] = null;
					calls.splice(0, 1);
				}
			}
			_calls = null;
		}
		
		static public function get calls():Vector.<CallsHistoryItemVO> {
			return _calls;
		}
		
		static public function get callsResponded():Boolean {
			return _callsResponded;
		}
	}
}