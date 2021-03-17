package com.dukascopy.connect.sys.businessListManager {
	
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.BLNotificationVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.CompanyVO;
	import com.dukascopy.connect.vo.DepartmentVO;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Igor
	 */
	
	public class BusinessListManager {
		
		static public var S_COMPANY_UPDATED:Signal = new Signal("BusinessListManager.S_COMPANY_UPDATED");
		static public var S_COMPANY_LOAD_ERROR:Signal = new Signal("BusinessListManager.S_COMPANY_LOAD_ERROR");
		static public var S_COMPANIES_LIST_UPDATED:Signal = new Signal("BusinessListManager.S_COMPANIES_LIST_UPDATED");
		static public var S_COMPANY_CLEARED:Signal = new Signal("BusinessListManager.S_COMPANY_CLEARED");
		static public var S_COMPANY_GET_CALLED:Signal = new Signal("BusinessListManager.S_COMPANY_GET_CALLED");
		static public var S_NOTIFICATIONS_LIST_UPDATED:Signal = new Signal("BusinessListManager.S_NOTIFICATIONS_LIST_UPDATED");
		static public var S_COMPANY_CHAT_OPENED:Signal = new Signal("BusinessListManager.S_COMPANY_CHAT_OPENED");
		static public var S_NOTIFICATION_NEW:Signal = new Signal("BusinessListManager.S_NOTIFICATION_NEW");
		static public var S_NOTIFICATION_ACCEPTED:Signal = new Signal("BusinessListManager.S_NOTIFICATION_ACCEPTED");
		
		static public var S_CHAT_CLOSE:Signal = new Signal("BusinessListManager.S_CHAT_CLOSE");
		
		static public var notifications:Array;
		
		static private var currentOpenedChatUID:String = null;
		
		static private var busy:Boolean = false;
		static private var inited:Boolean = false;
		
		static private var _company:CompanyVO;
		private static var _inDCNetwork:Boolean = true;
		private static var companyWasRemoved:Boolean = false;
		private static var _companyResponded:Boolean = false;

		public function BusinessListManager() { }
		
		static public function init():void {
			if (inited == true)
				return;
			inited = true;
			
			if (Auth.companyID == null || Auth.companyID.length == 0)
				return;
			
			if (WS.connected)
				onWSConnected();
			else
				WS.S_CONNECTED.add(onWSConnected);
			
			WSClient.S_BL_ENTRY_POINTS_NOTIFICATIONS.add(onEntryPointsAllNotifications);
			WSClient.S_BL_NOTIFICATION_UPDATED.add(onNotificationUpdate);
			WSClient.S_BL_NOTIFICATION_ACCEPTED_ERR.add(onNotificationAcceptedErr);
			WSClient.S_BL_NOTIFICATION_ADD.add(onNotificationAdd);
			WSClient.S_BL_ENTRY_POINT_FORVARD.add(onEPForvard);
			WSClient.S_BL_ENTRY_POINT_CANCEL.add(onEPCancel);
			WSClient.S_BL_ADD_TO_COMPANY_CHAT_BY_REQUEST.add(acceptNotification);
			WS.S_DISCONNECTED.add(addListenerWSConnect);
		}
		
		static private function onWSConnected():void {
			// get company if was removed 
			if (companyWasRemoved) {
				companyWasRemoved = false;
				getCompany();
			}
			WS.S_CONNECTED.remove(onWSConnected);			
			WSClient.call_getEntryPointNotifications();
			WSClient.call_getCompanyOnlineUsers();
		}
		
		static private function addListenerWSConnect():void {
			/*_companyResponded = false;
			if (Auth.companyID != null && Auth.companyID.length > 0) {
				_company = null;
				companyWasRemoved = true;
				S_COMPANY_CLEARED.invoke();
			}
			WS.S_CONNECTED.add(onWSConnected);*/
		}
		
		static public function getCompany():void {
			S_COMPANY_GET_CALLED.invoke();
			if (companyWasRemoved) {
				S_COMPANY_LOAD_ERROR.invoke();
				return;
			}
			onCompanyHashLoadedFromStore(null, false);
		}
		
		static private function onCompanyLoadedFromStore(data:Object, err:Boolean):void {
			if (err == false) {
				_company = new CompanyVO(data);
				S_COMPANY_UPDATED.invoke(_company);
			}		
			Store.load("companyHash", onCompanyHashLoadedFromStore);
		}
		
		static private function onCompanyHashLoadedFromStore(data:String, err:Boolean):void {
			if (Auth.companyID == null || Auth.companyID.length == 0){
				PHP.company_getEPs(onCompanyLoadedFromPHP, data);			
			}else{
				PHP.company_get(onCompanyLoadedFromPHP, data);			
			}
		}
		
		static private function onCompanyLoadedFromPHP(phpRespond:PHPRespond):void {
			_companyResponded  = true;
			if (phpRespond.error == true) {
				trace("BusinessListManager::onRespond -> ERROR: " + phpRespond.errorMsg);
				DialogManager.alert(Lang.textAttention, Lang.checkNetworkStatus);//phpRespond.errorMsg
				S_COMPANY_LOAD_ERROR.invoke();
				phpRespond.dispose();
				return;
			}
			init();
			if (phpRespond.data == null) {
				trace("BusinessListManager::onRespond -> INFO: Company has not changes.");
				phpRespond.dispose();
				return;
			}
			
			if (Auth.companyID != null && Auth.companyID.length > 0) {
				if(!("m" in phpRespond.data)) {
					_inDCNetwork = false;
					S_COMPANY_LOAD_ERROR.invoke();
					DialogManager.alert('Warning', 'You are not in dukascopy network.', function(i:int):void {
						return;	
					});
					phpRespond.dispose();
					return;
				} else {
					_inDCNetwork = true;
				}
			}	
			_company = new CompanyVO(phpRespond.data);
			S_COMPANY_UPDATED.invoke(_company);
			phpRespond.dispose();
		}
		
		static private function onEPCancel(data:Object):void {
			/*if (!Reflect.hasField(data,'reason')){
				Lib.alert('Can`t cancel! no reason!');
				return;
			}
			
			if (!Reflect.hasField(data,'chatUID')) {
				Lib.alert('Can`t cancel! no convUid!');
				return;
			}
			
			if (data.reason.toLowerCase() != 'ok'){
				Lib.alert(data.reason);
				return;
			}
			trace('CONVERSATION CANCELED!');
			S_CHAT_CLOSE.invoke(data.chatUID);
			currentOpenedChatUID = null;*/
		}
		
		static private function onEPForvard(data:Object):void {
			/*if (!Reflect.hasField(data,'reason')){
				Lib.alert('Can`t forvard! no reason!');
				return;
			}
			
			if (!Reflect.hasField(data,'chatUID')) {
				Lib.alert('No chat uid');
				return;
			}
			
			if (!Reflect.hasField(data,'userUid')) {
				Lib.alert('No user uid for forward');
				return;
			}
			
			if (!Reflect.hasField(data,'senderUid')) {
				Lib.alert('No sender uid for forward');
				return;
			}
			
			if (data.reason.toLowerCase() != 'ok')
				Lib.alert(data.reason);
			else {
				if (data.userUid == Auth.getUser().uid)
					acceptNotification(data.chatUID);
				else
					cancelSession(data.chatUID);
			}*/
		}
		
		static private function onNotificationAcceptedErr(data:Object):void {
			/*if (Reflect.hasField(data,'reason'))
				Alert.show('Error!','Can`t take this chat. '+data.reason);
					else
						Alert.show('Error!', 'Can`t take this chat. No reason from server');
			busy = false;*/
		}
		
		static private function onNotificationUpdate(data:Object):void {
			if (notifications == null)
				notifications = [];
			var groupChanged:Boolean = false;
			var l:int = notifications.length;
			var wasFounded:Boolean = false;
			var notice:BLNotificationVO;
			for (var i:int = 0; i < l; i++) {
				notice = notifications[i];
				if (notice.chatUID == data.chatUID) {
					wasFounded = true;
					var nEvent:String = notice.event;
					if ((notice.acceptors == null || notice.acceptors.length == 0) && (data.acceptor == null || data.acceptor.length == 0))
						groupChanged = false;
					else if (notice.acceptors != null && notice.acceptors.length != 0 && data.acceptor != null && data.acceptor.length != 0)
						groupChanged = false;
					else
						groupChanged = true;
					notice.update(data);
					if (notice.event == BLNotificationVO.EVENT_OCCUPIED) {
						trace('GOT OCCUPED EVENT!');
						if (notice.occupiedBy == Auth.uid) {
							if (currentOpenedChatUID == null && busy == false)
								trace('OPEN CONVERSATION??? ITS OPENED BY ME BUT IN ANOTHER CLIENT');
							else {
								trace('OCCUPED BY ME');
								if (data.chat == false) {
									busy = false;
									if ('chatUID' in data)
										finishSession(data.chatUID);
								} else {
									onNotificationAccepted(data.chat, data.pointId);
								}
							}
						} else {
							if (!isMemberInEntryPoint(Auth.uid, notice.pointID)) {
								var meInOccuped:Boolean = false;
								for (var j:int = 0; j < notice.acceptors.length; j++) {
									if (notice.acceptors[j].uid == Auth.uid){
										meInOccuped = true;
										break;
									}
								}
								
								if (meInOccuped == false) {
									trace('NOTIFICATION ACCEPTED NOT BY ME OR MEMBERS FROM MY EP, REMOVE IT');
									removeNotificationFromArray(notice);
								}
								break;
							}
						}
					}
					if (notice.event == BLNotificationVO.EVENT_CANCELED_BY_CLIENT) {
						if (notice.chatUID == currentOpenedChatUID) {
							S_CHAT_CLOSE.invoke(notice.chatUID);
							currentOpenedChatUID = null;
						}	
						trace('NOTIFICATION CANCELED BY CLIENT, REMOVE IT');
						removeNotificationFromArray(notice);
						break;
					}
					// Надо проверить! event_canceled должен приходить только тому, кто реально сделал cancel системе
					if (notice.event == BLNotificationVO.EVENT_CANCELED){
						if (!isMemberInEntryPoint(Auth.uid, notice.pointID)){
							trace('NOTIFICATION CANCELED, ITS NOT MINE EP! REMOVE IT');
							removeNotificationFromArray(notice);
						}
						break;
					}
					
					if (notice.event == BLNotificationVO.EVENT_FINISHED) {
						if (notice.chatUID == currentOpenedChatUID) {
							S_CHAT_CLOSE.invoke(notice.chatUID);
							currentOpenedChatUID = null;
							DialogManager.alert(Lang.information, Lang.chatWasFinished);
							//Alert.show('Info', 'Chat session was finished');
						}	
						removeNotificationFromArray(notice);
						break;
					}
					
					if (notice.event == BLNotificationVO.EVENT_TIMEOUT) {
						if (notice.chatUID == currentOpenedChatUID) {
							S_CHAT_CLOSE.invoke(notice.chatUID);
							currentOpenedChatUID = null;
							DialogManager.alert(Lang.information, Lang.sessionWasCanceledByTimeout);
							//Alert.show('Info', 'Chat session was canceled by timeout');
						}	
						
						if (!isMemberInEntryPoint(Auth.uid, notice.pointID))
							removeNotificationFromArray(notice);
						break;
					}
					
					break;
				}
			}
			
			if (wasFounded == false) {
				if ("msg" in data && data.msg != null) {
					notice = onNotificationAdd(data);
					if (notice.event == BLNotificationVO.EVENT_OCCUPIED && notice.occupiedBy == Auth.uid) {
						if (busy == true) {
							if (currentOpenedChatUID == notice.chatUID) {
								onNotificationAccepted(data.chat);
							}
						} else
							acceptNotification(notice.chatUID);
					}
				} else{
					S_NOTIFICATIONS_LIST_UPDATED.invoke();
				}
			} else if (groupChanged == true)
				S_NOTIFICATIONS_LIST_UPDATED.invoke();
		}
		
		static private function isMemberInEntryPoint(userUid:String, epId:int):Boolean {
			if (company == null)
				return false;
			if (Auth.uid == userUid) {
				for (var i:int = 0; i < company.me.points.length; i++) 
					if (company.me.points[i] == epId)
						return true;
				return false;
			}
				
			var arr:Array = getMembersByEntryPoint(epId);
			if (arr == null)
				return false;
			for (var j:int = 0; j < arr.length; j++) {
				if (arr[j].userUID == userUid)
					return true;
			}
			return false;
		}
		
		/**
		 * Вернуть пользователей привязаных к точке входа
		 * @param	id	int - номер точки входа, если -1 то возвращаются все члены компании
		 * @param	onlineOnly - true/false - показывать только онлайн пользователей либо всех
		 * @return возращается массив из MemberVO
		 */
		static private function getMembersByEntryPoint(id:int = -1, onlineOnly:Boolean = false):Array {
			if (company == null || company.members == null)
				return null;
				
			if (id == -1 && onlineOnly == false)
				return company.members;
			
			var l:int = company.members.length;
			var arr:Array = [];
			var epID:int;
			for (var i:int = 0; i < l; i++) {
				for (var j:int = 0; j < company.members[i].points.length; j++) {
					epID = company.members[i].points[j];
					if (epID == id || id == -1)
						arr[arr.length] = company.members[i];
				}
			}
			return arr;
		}
		
		static private function dispatchNotificationsAsObject():Array {
			/*if (Widget.AIR_ENABLE == false)
				return null;
			var res:Array = [];
			for (n in notifications) {
				var obj:Object = n.getObject();
				obj.pointShort = Auth.getEntryPointByID(obj.pointID).short;
				res.push(obj);
			}
			return res;*/
			return [];
		}
		
		/**
		 * Загрузились все уведомления
		 * @param	data
		 */
		static private function onEntryPointsAllNotifications(data:Array):void {
			if (notifications != null)
				notifications = [];
			
			if (data != null)
				for (var i:int = 0; i < data.length; i++) 
					onNotificationAdd(data[i], false);
			S_NOTIFICATIONS_LIST_UPDATED.invoke();
		}
		
		/**
		 * Новое уведомление от сервера пришло
		 * @param	data
		 */
		static private function onNotificationAdd(data:Object, showNote:Boolean = true):BLNotificationVO {
			if (notifications == null)
				notifications = [];
			
			var l:int = notifications.length;
			for (var i:int = 0; i < l; i++)
				if (notifications[i].chatUID == data.chatUID)
					return notifications[i];
			
			var notification:BLNotificationVO = new BLNotificationVO(data);
			notifications.push(notification);
			
			if (showNote)
				S_NOTIFICATIONS_LIST_UPDATED.invoke();
			
			return notification;
		}
		
		/**
		 * Участник компании ткнул в нотификейшен
		 * @param	convUID
		 */
		static public function acceptNotification(chatUID:String):void {
			if (busy)
				return;
			busy = true;
			WSClient.call_entryPointAccept(chatUID);
		}
		
		/**
		 * Пришло подтверждение с WS (теперь Я в чате и два сервера знают об этом)
		 * @param	data
		 */
		static private function onNotificationAccepted(chatData:Object = null, pointID:int = -1):void {
			busy = false;
			
			if (chatData == false)
				return;
			chatData.securityKey = company.securityKey;
			var cvo:ChatVO = new ChatVO(chatData);
			if (pointID > -1)
				cvo.setEPID(pointID);
			S_COMPANY_CHAT_OPENED.invoke(cvo);
		}
		
		static private function removeNotificationFromArray(notice:BLNotificationVO):void {
			var l:int = notifications.length;
			for (var i:int = 0; i < l; i++) {
				if (notifications[i] == notice) {
					notifications.splice(i, 1);
					break;
				}
			}
		}
		
		static public function getNotificationByConvUid(uid:String):BLNotificationVO {
			/*if (notifications == null)
				return null;
			for (n in notifications)
				if (n.chatUID == uid)
					return n;
			return null;*/
			return null
		}
		
		static public function getOnDutyCount(id:int):int {
			// TODO Get on duty count from server, store it, return value.
			// on each connect reset values and ask status from server.
			// WS will invoke method to update values in live.
			return 0;
		}
		
		static public function getMembersCountForEP(epID:int):int {
			/*if (Auth.company == null || notifications==null)
				return 0;
			var cnt:Int = 0;
			for(m in Auth.company.members){
				for(pid in m.points){
					if (pid == epID)
						cnt++;
				}
			}
			return cnt;*/
			return 0;
		}
		
		static public function getNotificationOccupedByMe():Array {
			/*if (notifications == null)
				return [];
			var res:Array = [];
			for (n in notifications) {
				if (n.event == BLNotificationVO.EVENT_OCCUPIED || n.event == BLNotificationVO.EVENT_FINISHED) {
					//CHECK FOR ME
					if (n.acceptors != null) {
						for (a in n.acceptors){
							if (a.uid == Auth.getUser().uid){
								res[res.length] = n;
								break;
							}
						}
					}
				}
					
			}
			return res;*/
			return [];
		}
		
		static public function getEntryPointByChatUID(chatUID:String):EntryPointVO {
			/*if (Auth.company == null || notifications==null)
				return null;
			for(notice in notifications){
				if (notice.chatUID == chatUID){
					return Auth.getEntryPointByID(notice.pointID);
				}
			}*/
			return null;
		}
		
		static public function getNotifications():void {
			WSClient.call_getEntryPointNotifications();
		}
		
		static public function getNotificationOfMine():Array {
			/*if (notifications == null)
				return [];
			var res:Array = [];
			for (n in notifications) {
				for (epID in Auth.company.me.points) {
					if (n.pointID == epID) {
						res[res.length] = n;
						break;
					}
				}
			}
			return res;*/
			return [];
		}
		
		static public function addMemberToChat(chatUID:String, userUIDs:Array):void {
			/*if (!WS.call_addMemberToCompanyChat(userUIDs, chatUID))
				Lib.alert("Can`t forward chat! No connection to server");*/
		}
		
		static public function forwardSession(chatUID:String, userUIDs:Array):void {
			/*if (!WS.call_entryPointForward(userUIDs[0], chatUID))
				Lib.alert("Can`t forward chat! No connection to server");*/
		}
		
		static public function finishSession(chatUID:String):void {
			/*if (!WS.call_entryPointFinish(chatUID))
				Lib.alert("Can`t finish session! No connection to server");*/
		}
		
		static public function cancelSession(chatUID:String):void {
			if (!WSClient.call_entryPointCancel(chatUID))
				DialogManager.alert(Lang.textAlert, "Can`t cancel session! No connection to server");
		}
		
		static public function getDepartment(depID:int):DepartmentVO {
			if (_company == null || _company.departments == null)
				return null;
			var l:int = _company.departments.length;
			for (var i:int = 0; i < l; i++)
				if (_company.departments[i].id == depID)
					return _company.departments[i];
			return null;
		}
		
		static public function getNamesOfEntryPointsAsString(pointsIDs:Array):String {
			if (_company == null || _company.entryPoints == null)
				return null;
			var str:String = '';
			var cepl:int = _company.entryPoints.length;
			var epl:int = pointsIDs.length;
			for (var i:int = 0; i < cepl; i++) {
				for (var j:int = 0; j < epl; j++) {
					if (_company.entryPoints[i].id == pointsIDs[j])
						str += _company.entryPoints[i].short + ', ';
				}
			}
			return str.substr(0, str.length - 2).toUpperCase();
		}
		
		
		static private var fastStock:Array = [];
		static public function getMemberIndexByUserUid(uid:String):int {
			
			var l:int;
			var i:int;
			if (_company == null || _company.members==null)
				return -1;
				
			if (fastStock.length < _company.members.length * .7) {
				// try to search fast
				l = fastStock.length;
				for (i = 0; i < l; i++){
					if (fastStock[i][0] == uid){
						return fastStock[i][1];
					}
				}
			}
			
			
			l = _company.members.length;
			for (i = 0; i < l; i++){
				if (_company.members[i].userUID == uid){
					fastStock.push([uid,i]);
					return i;
				}
			}
			return -1;
		}
		
		static public function getEntryPointByID(id:int):EntryPointVO {
			if (_company == null || _company.entryPoints == null)
				return null;
			var l:int = _company.entryPoints.length;
			for (var i:int = 0; i < l; i++)
				if (_company.entryPoints[i].id == id)
					return _company.entryPoints[i];
			return null;
		}
		
		static public function get company():CompanyVO { return _company; }
		static public function get allNotifications():Array {
			if (notifications == null)
				return null;
			var res:Array = [];
			var waitingAdded:Boolean = false;
			var occupedAdded:Boolean = false;
			var l:int = notifications.length;
			var notification:BLNotificationVO;
			for (var i:int = 0; i < l; i++) {
				notification = notifications[i];
				if (notification.acceptors.length == 0) {
					if (waitingAdded == false) {
						waitingAdded = true;
						res.unshift( { title:Lang.waiting, count:0 } );
					}
					res[0].count++;
					res.splice(1, 0, notification);
					continue;
				}
				if (occupedAdded == false) {
					occupedAdded = true;
					res.push( { title:Lang.inProcess, count:0 } );
				}
				if (waitingAdded == true)
					res[res[0].count + 1].count++;
				else
					res[0].count++;
				res.push(notification);
			}
			return res;
		}
		
		public static function get inDCNetwork():Boolean		{			return _inDCNetwork;		}
		
		static public function get companyResponded():Boolean 	{		return _companyResponded;	}
	}
}