package com.dukascopy.connect.sys.promoEvents 
{
	import assets.JailedIllustrationClip;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.promoEvent.PromoEvent;
	import com.dukascopy.connect.data.promoEvent.PromoEventWinner;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.EmptyAction;
	import com.dukascopy.connect.data.screenAction.customActions.InviteFriendsAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenBankAccountAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenUnjailPopupAction;
	import com.dukascopy.connect.data.screenAction.customActions.UploadPhotoAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class PromoEvents 
	{
		static private var events:Vector.<PromoEvent>;
		static private var requestTimeout:Number = 1000*60*10;
		static private var lastRequestTime:Number = 0;
		static private var sendLocationInProcess:Boolean;
		static private var busy:Boolean;
		static private var winners:Vector.<PromoEventWinner>;
		static private var disclamerShown:Boolean;
		static private var currentLoto:String;
		static public var eventsResponded:Boolean;
		
		static public var S_EVENTS:Signal = new Signal("PromoEvents.S_EVENTS");
		static public var S_ADD:Signal = new Signal("PromoEvents.S_ADD");
		static public var S_LOAD_START:Signal = new Signal("PromoEvents.S_LOAD_START");
		static public var S_LOAD_END:Signal = new Signal("PromoEvents.S_LOAD_END");
		static public var S_EVENTS_ERROR_NO_INTERNET:Signal = new Signal("PromoEvents.S_EVENTS_ERROR_NO_INTERNET");
		static public var S_WINNERS:Signal = new Signal("PromoEvents.S_WINNERS");
		static public var S_ACCESS_RESULT:Signal = new Signal("PromoEvents.S_ACCESS_RESULT");
		
		static public const ERROR_ALREADY_IN_EVENT:String = "lotl.03";
		static public const ERROR_NEED_PAYMENTS:String = "lotl.04";
		static public const ERROR_BANNED:String = "lotl.05";
		static public const ERROR_JAILED:String = "lotl.06";
		static public const ERROR_NEED_REFERRALS:String = "lotl.07";
		static public const ERROR_NEED_AVATAR:String = "lotl.08";
		
		public function PromoEvents() 
		{
			
		}
		
		public static function init():void
		{
			Auth.S_NEED_AUTHORIZATION.add(clean);
		}
		
		static private function clean():void
		{
			if (events != null)
			{
				clearEvents();
				cleanWinners();
			}
			lastRequestTime = 0;
			eventsResponded = false;
		}
		
		static private function cleanWinners():void 
		{
			if (winners == null)
			{
				return;
			}
			var l:int = winners.length;
			for (var i:int = 0; i < l; i++)
			{
				winners[i].dispose();
			}
			winners = null;
		}
		
		static public function getEvents():Vector.<PromoEvent>
		{
			if (busy == false && (new Date()).getTime() - lastRequestTime > requestTimeout)
			{
				busy = true;
				S_LOAD_START.invoke();
				PHP.call_lotto_getActive(onEventsRespond);
			}
			
			if (events != null)
			{
				return events;
			}
			return null;
		}
		
		static public function participate(id:String):void 
		{
			callParticipate(id);
			
			/*if (disclamerShown == true)
			{
				callParticipate(id);
			}
			else
			{
				currentLoto = id;
				Store.load(Store.PROMO_DISCLAMER_SHOWN, onDisclamerStatusLoaded);
			}*/
		}
		
		static private function onDisclamerStatusLoaded(data:Object, err:Boolean):void 
		{
			if (err)
			{
				disclamerShown = true;
				showRules();
			}
			callParticipate(currentLoto);
		}
		
		static private function callParticipate(id:String):void 
		{
			PHP.call_lotto_addMe(id, onAddMeRespond);
		}
		
		static public function loadResult():void 
		{
			PHP.call_lotto_getWinners(onWinnersRespond);
		}
		
		static public function getWinner(eventId:String):PromoEventWinner 
		{
			if (winners != null)
			{
				var l:int = winners.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (winners[i].id == eventId)
					{
						return winners[i];
					}
				}
			}
			return null;
		}
		
		static public function clearCurrent():void 
		{
			lastRequestTime = 0;
			clearEvents();
			S_EVENTS.invoke();
		}
		
		static public function getWinners():Vector.<PromoEventWinner> 
		{
			return winners;
		}
		
		static public function refreshImmediately():void 
		{
			lastRequestTime = 0;
			getEvents();
		}
		
		static public function showRules():void {
			Store.save(Store.PROMO_DISCLAMER_SHOWN, "true");
			DialogManager.showPromoEventsRules( { title:Lang.textRules } );
		}
		
		static public function inviteFriends():void 
		{
			if (ReferralProgram.myPromoData != null && ReferralProgram.myPromoData.loaded == true){
				showShare();
			}
			else
			{
				ReferralProgram.S_UPDATED.add(onReferralDataReady);
				ReferralProgram.update();
			}
		}
		
		static public function getInvitesInfo(id:String):void 
		{
			checkAccess(id);
		}
		
		static private function checkAccess(id:String):void 
		{
			PHP.call_lotto_checkAccess(onCheckAccessRespond, id);
		}
		
		static private function onCheckAccessRespond(respond:PHPRespond):void
		{
			if (respond.error == true)
			{
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				if (respond.errorMsg == PHP.NETWORK_ERROR)
				{
					ToastMessage.display(Lang.alertProvideInternetConnection);
				}
				else if (respond.errorMsg != null && respond.errorMsg.length >= 7)
				{
					//!TODO:;
				}
			}
			else if(respond.data != null)
			{
				var needAccount:Boolean = (respond.data === false);
				var usersInvited:int = 0;
				if (needAccount == false)
				{
					usersInvited = int(respond.data);
				}
			}
			S_ACCESS_RESULT.invoke(respond.additionalData.id, !respond.error, needAccount, usersInvited);
			respond.dispose();
		}
		
		static private function showShare():void 
		{
			var message:String = Lang.invitePromocodeMessage;
			message = LangManager.replace(Lang.regExtValue, message, ReferralProgram.myPromoData.code);
			message = LangManager.replace(Lang.regExtValue, message, ReferralProgram.myPromoData.code);
			NativeExtensionController.shareText(message);
		}
		
		static private function onReferralDataReady(success:Boolean = true, errorMessage:String = null):void 
		{
			if (success == true)
			{
				ReferralProgram.S_UPDATED.remove(onReferralDataReady);
				if (ReferralProgram.myPromoData.loaded == true)
				{
					showShare();
				}
			}
			else
			{
				ToastMessage.display(errorMessage);
			}
		}
		
		static private function onWinnersRespond(respond:PHPRespond):void
		{
			S_LOAD_END.invoke();
			if (respond.error == true)
			{
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				if (respond.errorMsg == PHP.NETWORK_ERROR)
				{
					
				}
				else if (respond.errorMsg != null && respond.errorMsg.length >= 7)
				{
					
				}
			}
			else if(respond.data != null && respond.data is Array)
			{
				//!TODO: заполнить данные по текущим розыгрышам
				var l:int = (respond.data as Array).length;
				var winner:PromoEventWinner;
				winners = new Vector.<PromoEventWinner>();
				for (var i:int = 0; i < l; i++) 
				{
					winner = new PromoEventWinner(respond.data[i]);
					winners.push(winner);
				}
				
				if (events != null)
				{
					l = events.length;
					var l2:int = winners.length;
					for (var j:int = 0; j < l; j++) 
					{
						for (var i2:int = 0; i2 < l2; i2++) 
						{
							if (events[j].id == winners[i2].id)
							{
								if (winners[i2].userUID == Auth.uid)
								{
									events[j].lastResult = PromoEvent.RESULT_WIN;
								}
								else{
									events[j].lastResult = PromoEvent.RESULT_LOSE;
								}
							}
						}
					}
				}
				
				
				S_WINNERS.invoke();
			}
			
			respond.dispose();
		}
		
		static private function onAddMeRespond(respond:PHPRespond):void
		{
			var eventId:String = respond.additionalData.id;
			
			if (respond.error == true)
			{
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				
				if (respond.errorMsg == PHP.NETWORK_ERROR)
				{
					S_ADD.invoke(eventId, false, message);
				}
				else if (respond.errorMsg != null && respond.errorMsg.length >= 7)
				{
					if (respond.errorMsg.substr(0, 7) == ERROR_ALREADY_IN_EVENT)
					{
						S_ADD.invoke(eventId, true, null);
					}
					else{
						var popupData:PopupData;
						var action:IScreenAction;
						
						if (respond.errorMsg.substr(0, 7) == ERROR_JAILED)
						{
							popupData = new PopupData();
							action = new OpenUnjailPopupAction();
							action.setData(Lang.getOutOfJail);
							popupData.action = action;
							popupData.illustration = JailedIllustrationClip;
							popupData.title = Lang.youInJail;
							popupData.text = Lang.youcantParticiparteInEventJailed;
							ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
							S_ADD.invoke(eventId, false, null);
						}
						else if (respond.errorMsg.substr(0, 7) == ERROR_BANNED)
						{
							popupData = new PopupData();
							action = new EmptyAction();
							action.setData(Lang.textOk);
							popupData.action = action;
							popupData.illustration = JailedIllustrationClip;
							popupData.title = Lang.youInBan;
							popupData.text = Lang.youcantParticiparteInEventBanned;
							ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
							S_ADD.invoke(eventId, false, null);
						}
						else if (respond.errorMsg.substr(0, 7) == ERROR_NEED_PAYMENTS)
						{
							popupData = new PopupData();
							action = new OpenBankAccountAction();
							action.setData(Lang.openBankAccount);
							popupData.action = action;
							popupData.illustration = JailedIllustrationClip;
							popupData.title = Lang.noBankAccount;
							popupData.text = Lang.youcantParticiparteInEventNoBankAccount;
							ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
							S_ADD.invoke(eventId, false, null);
						}
						else if (respond.errorMsg.substr(0, 7) == ERROR_NEED_REFERRALS)
						{
							popupData = new PopupData();
							action = new InviteFriendsAction();
							action.setData(Lang.inviteFriends);
							popupData.action = action;
							popupData.illustration = JailedIllustrationClip;
							popupData.title = null;
							popupData.text = Lang.needMoreReferrals;
							ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
							S_ADD.invoke(eventId, false, null);
						}
						else if (respond.errorMsg.substr(0, 7) == ERROR_NEED_AVATAR)
						{
							popupData = new PopupData();
							action = new UploadPhotoAction();
							action.setData(Lang.uploadPhoto);
							popupData.action = action;
							popupData.illustration = JailedIllustrationClip;
							popupData.title = null;
							popupData.text = Lang.needAvatar;
							ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
							S_ADD.invoke(eventId, false, null);
						}
						else{
							S_ADD.invoke(eventId, false, message);
						}
					}
				}
			}
			else
			{
				var event:PromoEvent = getEventById(eventId);
				if (event != null)
				{
					event.participant = true;
					event.cnt ++;
				}
				S_ADD.invoke(eventId, true, null);
			}
			
			respond.dispose();
		}
		
		static private function getEventById(eventId:String):PromoEvent 
		{
			if (events == null)
			{
				return null;
			}
			var l:int = events.length;
			for (var i:int = 0; i < l; i++) 
			{
				if (events[i].id == eventId)
				{
					return events[i];
				}
			}
			return null;
		}
		
		static private function onEventsRespond(respond:PHPRespond):void
		{
			eventsResponded = true;
			S_LOAD_END.invoke();
			busy = false;
			lastRequestTime = (new Date()).getTime();
			if (respond.error == true) {
				S_EVENTS.invoke();
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				
				if (respond.errorMsg == PHP.NETWORK_ERROR)
				{
					
				}
				else if (respond.errorMsg != null && respond.errorMsg.length >= 7)
				{
					//!TODO
				}
			}
			else
			{
				if ("data" in respond && respond.data != null && respond.data is Object)
				{
					var newEvents:Vector.<PromoEvent> = new Vector.<PromoEvent>();
					
					var locationItem:PromoEvent;
					for each(var item:Object in respond.data)
					{
						locationItem = new PromoEvent(item);
						newEvents.push(locationItem);
					}
					if (events == null)
					{
						events = newEvents;
					}
					else{
						var updatedLocations:Vector.<PromoEvent> = new Vector.<PromoEvent>();
						var l:int = events.length;
						var l2:int = newEvents.length;
						var exist:Boolean;
						for (var j:int = 0; j < l; j++) 
						{
							exist = false;
							for (var k:int = 0; k < l2; k++) 
							{
								if (events[j].id == newEvents[k].id)
								{
									exist = true;
									events[j].update(newEvents[k]);
									updatedLocations.push(events[j]);
									newEvents[k].dispose();
								}
							}
							if (!exist)
							{
								events[j].dispose();
							}
						}
						
						for (var m:int = 0; m < l2; m++) 
						{
							if (!newEvents[m].disposed)
							{
								updatedLocations.push(newEvents[m]);
							}
						}
						events = updatedLocations;
					}
					if (events != null)
					{
						events = events.sort(sordData);
					}
					S_EVENTS.invoke();
				}
			}
			
			respond.dispose();
		}
		
		static private function sordData(a:PromoEvent, b:PromoEvent):int {
			var value:int = 0;
			
			if (a.stop > b.stop)
				value = 1;
			else
				value = -1;
			
			return value;
		}
		
		static private function clearEvents():void 
		{
			lastRequestTime = 0;
			if (events == null)
			{
				return;
			}
			var l:int = events.length;
			for (var i:int = 0; i < l; i++)
			{
				events[i].dispose();
			}
			events = null;
		}
	}
}