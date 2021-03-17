package com.dukascopy.connect.sys.promocodes {
	
	import com.dukascopy.connect.data.ReferralProgramData;
	import com.dukascopy.connect.data.ReferralProgramData;
	import com.dukascopy.connect.data.ReferralProgramInviteData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.promocodes.EnterPromocodePopup;
	import com.dukascopy.connect.screens.promocodes.EnterPromocodeScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.globalization.StringTools;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ReferralProgram 
	{
		static public var S_UPDATED:Signal = new Signal("ReferralProgram.S_UPDATED");
		static public var S_CODE_SEND_RESULT:Signal = new Signal("ReferralProgram.S_CODE_SEND_RESULT");
		
		static public const INVITE_STATUS_COMPLETED:String = "completed";
		static public const INVITE_STATUS_REJECTED:String = "rejected";
		static public var agreementAccepted:Boolean = false;
		
		static private var _myPromoData:ReferralProgramData;
		static private var busy:Boolean;
		static private var codeEnteringAvaliabilityChecked:Boolean = false;
		static private var codeEnterTime:Number = NaN;
		static public var canEnerCodeStatus:Boolean = false;
		static private var avaliable:Boolean = true;
		static private var needShowEnterCodeScreen:Boolean;
		static private var refCodes:Array;
		static private var referralDialogShown:Boolean = false;
		static private var _dialogWasClosed:Boolean= false;
		static private var blockedAtStart:Boolean;
		
		public function ReferralProgram() {
			
		}
		
		public static function init():void {
			Auth.S_NEED_AUTHORIZATION.add(clean);
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
			blockedAtStart = true;
			TweenMax.delayedCall(1000, unblock);
		}
		
		static private function unblock():void 
		{
			blockedAtStart = false;
		}
		
		static private function onConnectionChanged():void {
			if (NetworkManager.isConnected && Auth.key != "web" && blockedAtStart == false) {
				update();
			}
		}
		
		static private function clean():void {
			canEnerCodeStatus = false;
			codeEnterTime = NaN;
			codeEnteringAvaliabilityChecked = false;
			busy = false;
			_myPromoData = new ReferralProgramData();
			PayAPIManager.S_SWISS_API_CHECKED.remove(onAccountInfoFirstInstall);
		}
		
		// Нужно показать enter code
		static public function promptEnterCode():void {
			if (avaliable == false)
				return;
			var time:Number = (new Date()).getTime();
			Store.save(Store.FIRST_INSTALL_TIME, time);
			listenPaymentsAccountFirstInstall();
		}
		
		static public function update():void {
			if (avaliable == false)
				return;
			
			if (busy == true) {
				S_UPDATED.invoke(false);
				return;
			}
			
			busy = true;
			Store.load(Store.MY_REFERRAL_CODE, onReferralCodeLoadedFromStore);
		}
		
		static public function enterCode():void {
			if (avaliable == false)
				return;
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EnterPromocodeScreen);
		}
		
		static public function checkEnterCodeAvaliability():void {
			if (avaliable == false)
				return;
			
			if (!isNaN(codeEnterTime)){
				if (!isNaN(codeEnterTime) && (new Date()).getTime() - Number(codeEnterTime) < 10 * 60 * 60 * 1000) {
					if (codeEnteringAvaliabilityChecked == false) {
						checkEnterCodeAvaliabilityOnServer();
					}
					else {
						S_UPDATED.invoke(true);
					}
				}
			}
			else{
				Store.load(Store.FIRST_INSTALL_TIME, onFirstInstallTimeLoaded);
			}
		}
		
		static public function canEnterCode():Boolean {
			if (avaliable == false)
				return false;
			
			if (!isNaN(codeEnterTime) && (new Date()).getTime() - codeEnterTime < 10*60*60*1000 && codeEnteringAvaliabilityChecked == true && canEnerCodeStatus == true) {
				return true;
			}
			return false;
		}
		
		static public function sendCode(value:String):void {
			if (avaliable == false)
				return;
			PHP.referral_enterCode(onCodeResponse, value, Auth.devID);
		}
		
		static public function disable():void {
			avaliable = false;
		}
		
		static public function isAvaliable():Boolean {
			return avaliable;
		}
		
		static public function setRefCodes(val:String):void {
			val = val.replace(/[\s\r\n-]/g, "");
			refCodes = val.split(",");
		}
		
		static private function onCodeResponse(respond:PHPRespond):void {
			
			PHP.call_statVI("refCodeEntered");
			
			if (respond.error == true) {
				S_CODE_SEND_RESULT.invoke(false, ErrorLocalizer.getText(respond.errorMsg, ErrorLocalizer.ENTER_PROMOCODE_TARGET));
			}
			else{
				canEnerCodeStatus = false;
				codeEnteringAvaliabilityChecked = true;
				S_CODE_SEND_RESULT.invoke(true);
			}
			
			respond.dispose();
		}
		
		static private function onFirstInstallTimeLoaded(data:Object, err:Boolean):void {
			if (err == true || isNaN(Number(data))) {
				checkEnterCodeAvaliabilityOnServer();
			}
			else{
				codeEnterTime = Number(data);
				if ((new Date()).getTime() - codeEnterTime < 10 * 60 * 60 * 1000)
				{
					checkEnterCodeAvaliabilityOnServer();
				}
			}
		}
		
		static private function checkEnterCodeAvaliabilityOnServer():void {
			PHP.referral_getInvite(onInviteDataLoaded);
		}
		
		static private function onInviteDataLoaded(response:PHPRespond):void {
			if (response.error == true) {
				
			}
			else{
				codeEnteringAvaliabilityChecked = true;
				
				if ("data" in response && response.data == false) {
					canEnerCodeStatus = true;
				}
				else {
					canEnerCodeStatus = false;
				}
				S_UPDATED.invoke(true);
			}
			response.dispose();
		}
		
		static private function onReferralCodeLoadedFromStore(code:String, error:Boolean):void {
			if (code == null || error == true) {
				generateCode();
			} else {
				loadReferralData();
			}
		}
		
		static private function loadReferralData():void {
			Store.load(Store.REFERRAL_PROGRAM_DATA, onLocalReferralDataLoaded);
		}
		
		static private function onLocalReferralDataLoaded(data:Object, error:Boolean):void {
			if (data == null || error == true) {
				
			} else {
				if (data != null && data is Array && (data as Array).length == 0) {
					S_UPDATED.invoke(false);
				} else {
					fillReferralData(data);
					S_UPDATED.invoke(true);
				}
			}
			PHP.referral_getReferralProgramData(onReferralProgramDataLoaded);
		}
		
		static private function generateCode():void {
			if (Auth.bank_phase == BankPhaze.ACC_APPROVED)
			{
				PHP.referral_getCode(onReferralProgramCodeReady);
			}
		}
		
		static private function onReferralProgramCodeReady(respond:PHPRespond):void {
			if (respond.error == true) {
				busy = false;
				S_UPDATED.invoke(false, ErrorLocalizer.getText(respond.errorMsg));
			}
			else {
				Store.save(Store.MY_REFERRAL_CODE, respond.data);
				loadReferralData();
			}
			
			respond.dispose();
		}
		
		static private function onReferralProgramDataLoaded(respond:PHPRespond):void {
			busy = false;
			
			if (respond.error == true) {
				S_UPDATED.invoke(false, ErrorLocalizer.getText(respond.errorMsg));
			} else {
				if (respond.data != null && respond.data is Array && (respond.data as Array).length == 0) {
					generateCode();
				} else {
					myPromoData.loaded = true;
					fillReferralData(respond.data);
					Store.save(Store.REFERRAL_PROGRAM_DATA, respond.data);
					S_UPDATED.invoke(true);
				}
				
			}
			
			respond.dispose();
		}
		
		static private function fillReferralData(data:Object):void {
			if ("code" in data) {
				myPromoData.code = data.code;
				myPromoData.lastLoadTime = (new Date()).getTime();
				if (data.invites != null && data.invites is Array && (data.invites as Array).length > 0) {
					var invites:Vector.<ReferralProgramInviteData> = new Vector.<ReferralProgramInviteData>();
					var length:int = (data.invites as Array).length;
					for (var i:int = 0; i < length; i++)
						invites.push(new ReferralProgramInviteData(data.invites[i]));
					invites.reverse();
					myPromoData.invites = invites;
				}
				myPromoData.money = data.completed * 5;
				myPromoData.totalCompleted = data.completed;
				myPromoData.totalInvites = data.total;
			}
		}
		
		static private function listenPaymentsAccountFirstInstall():void {
			onAccountInfoFirstInstall();
		}
		
		static private function onAccountInfoFirstInstall():void {
			if (avaliable == false)
				return;
			if (PayAPIManager.hasSwissAccount == false) {
				if (ServiceScreenManager.hasOpenedDialog == true) {
					needShowEnterCodeScreen = true;
					ServiceScreenManager.S_CLOSE_DIALOG.add(onCurrentServiceScreenClosed);
				} else {
					showEnterCodePopup();
				}
			}
		}
		
		static public function refDialogWasClosed():void {
			referralDialogShown = false;
			_dialogWasClosed = true;
		}
		
		static public function isRefDialogShown():Boolean {
			return referralDialogShown;
		}
		
		static private function showEnterCodePopup():void {
			if (Auth.bank_phase != "EMPTY" && Auth.bank_phase != "UNKNOWN")
				return;
			referralDialogShown = true;
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EnterPromocodePopup);
		}
		
		static private function onCurrentServiceScreenClosed():void {
			if (needShowEnterCodeScreen == true) {
				needShowEnterCodeScreen = false;
				ServiceScreenManager.S_CLOSE_DIALOG.remove(onCurrentServiceScreenClosed);
				TweenMax.delayedCall(2, showEnterCodePopup);
			}
		}
		
		static public function get myPromoData():ReferralProgramData {
			if (_myPromoData == null) {
				_myPromoData = new ReferralProgramData();
			}
			return _myPromoData;
		}
		
		static public function get dialogWasClosed():Boolean 
		{
			return _dialogWasClosed;
		}
		
		static public function getPromocodeDescription(value:String):String {
			if (value == null || value == "")
				return Lang.enterInviteCode;
			if (refCodes == null || refCodes.indexOf(value) == -1)
				return Lang.enterInviteCode;
			if ("REFERAL_" + value in Lang.refCodesText == false)
				return Lang.enterInviteCode;
			return Lang.refCodesText["REFERAL_" + value.toUpperCase()];
		}
	}
}