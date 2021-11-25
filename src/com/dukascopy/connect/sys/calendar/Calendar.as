package com.dukascopy.connect.sys.calendar 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.dialogs.calendar.RecognitionDateRemindPopup;
	import com.dukascopy.connect.screens.dialogs.calendar.SelectRecognitionDatePopup;
	import com.dukascopy.connect.sys.Utils;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.notificationManager.PushNotificationsNative;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Calendar 
	{
		static public var S_CALENDAR_VI_READY:Signal = new Signal("Calendar.S_CALENDAR_VI_READY");
		static public var S_DAY_RANGES:Signal = new Signal("Calendar.S_DAY_RANGES");
		static public var S_APPOINTMENT_DATA:Signal = new Signal("Calendar.S_APPOINTMENT_DATA");
		static public var S_APPOINTMENT_BOOK:Signal = new Signal("Calendar.S_APPOINTMENT_BOOK");
		static public var S_APPOINTMENT_BOOK_FAIL:Signal = new Signal("Calendar.S_APPOINTMENT_BOOK_FAIL");
		static public var S_APPOINTMENT_BOOK_CANCEL:Signal = new Signal("Calendar.S_APPOINTMENT_BOOK_CANCEL");
		static public var S_START_VI:Signal = new Signal("Calendar.S_START_VI");
		
		static public var viAppointmentData:VIAppointmentData;
		public static var viCalendar:VICalendar;
		static public var appointmentUnavaliable:Boolean = false;
		static private var needShowAppointmentPopup:Boolean;
		static public var needStartVI:Boolean;
		
		public function Calendar(){
			
		}
		
		public function getCurrentMonth():Month 
		{
			var date:Date = new Date();
			var month:Month = new Month(date);
			return month;
		}
		
		static public function getPrewMonth(month:Month):Month 
		{
			var date:Date = new Date();
			date.setFullYear(month.year);
			date.setDate(1);
			date.setMonth(month.monthIndex - 1);
			var monthNext:Month = new Month(date);
			return monthNext;
		}
		
		static public function getNextMonth(month:Month):Month 
		{
			var date:Date = new Date();
			date.setFullYear(month.year);
			date.setDate(1);
			var index:int = month.monthIndex + 1;
			date.setMonth(index);
			var monthNext:Month = new Month(date);
			return monthNext;
		}
		
		static public function loadClosedRecognitionCalendar():void
		{
			if (viCalendar == null)
			{
				viCalendar = new VICalendar();
			}
			else
			{
				viCalendar.load();
			}
		}
		
		static public function cancelVIAppointment(id:String):void 
		{
			PHP.call_barabanRelease(onViAppointmentBookCancelResponse, id);
		}
		
		static private function onViAppointmentBookCancelResponse(respond:PHPRespond):void 
		{
			viAppointmentData = null;
			if (respond.error == false)
			{
				TweenMax.killDelayedCallsTo(showAppointmentPopup);
				TweenMax.killDelayedCallsTo(processToVI);
				TweenMax.killDelayedCallsTo(showLateVIPopup);
				needShowAppointmentPopup = false;
				
				ChatManager.sendBarabanRequest(-1);
			}
			S_APPOINTMENT_BOOK_CANCEL.invoke(!respond.error, respond.errorMsg);
			respond.dispose();
		}
		
		static public function loadAppointmentData():void 
		{
			if (viAppointmentData == null)
			{
				viAppointmentData = new VIAppointmentData();
			}
			else
			{
				viAppointmentData.load();
			}
		}
		
		static public function bookVIAppointment(date:Date, hours:TimeRange, minutes:TimeRange):void 
		{
			//!TODO:;
			date.setHours(hours.value);
			date.setMinutes(minutes.value);
			
			PHP.call_barabanBook(onViAppointmentBookRespond, date);
		}
		
		static public function init():void 
		{
			Auth.S_NEED_AUTHORIZATION.add(clear);
		}
		
		static private function clear():void 
		{
			TweenMax.killDelayedCallsTo(showAppointmentPopup);
			TweenMax.killDelayedCallsTo(processToVI);
			TweenMax.killDelayedCallsTo(showLateVIPopup);
			needShowAppointmentPopup = false;
			
			if (viAppointmentData != null)
			{
				viAppointmentData.dispose();
				viAppointmentData = null;
			}
			if (viCalendar != null)
			{
				viCalendar.dispose();
				viCalendar = null;
			}
		}
		
		static public function checkAppointmentData():void 
		{
			needShowAppointmentPopup = true;
			S_APPOINTMENT_DATA.add(onAppointmentData);
			loadAppointmentData();
		}
		
		static private function onAppointmentData():void 
		{
			S_APPOINTMENT_DATA.remove(onAppointmentData);
			
			if (needShowAppointmentPopup)
			{
				if (viAppointmentData != null && viAppointmentData.success == true && viAppointmentData.exist == true)
				{
					var current:Date = new Date();
					var diff:Number = -(current.getTime() - viAppointmentData.date.getTime())/1000;
					if (diff > 0)
					{
						if (diff < 10 * 60 && diff > 60)
						{
							needShowAppointmentPopup = false;
							TweenMax.delayedCall(3, showAppointmentPopup);
						}
						else if(diff > 10 * 60)
						{
							TweenMax.delayedCall(diff - 10*60, showAppointmentPopup);
						}
						TweenMax.delayedCall(diff, processToVI);
					}
					else
					{
						if (Math.abs(diff)/60 < Config.barabanSettings.maxLateMinutes)
						{
							TweenMax.delayedCall(3, processToVI);
						}
						else
						{
							TweenMax.delayedCall(3, showLateVIPopup);
						}
					}
				}
			}
		}
		
		static private function addAppointmentListeners():void 
		{
			if (viAppointmentData != null && viAppointmentData.success == true && viAppointmentData.exist == true)
			{
				var current:Date = new Date();
				var diff:Number = -(current.getTime() - viAppointmentData.date.getTime())/1000;
				if (diff > 0)
				{
					if (diff < 10 * 60 && diff > 60)
					{
						needShowAppointmentPopup = false;
					}
					else if(diff > 10 * 60)
					{
						TweenMax.delayedCall(diff - 10*60, showAppointmentPopup);
					}
					TweenMax.delayedCall(diff, processToVI);
				}
				else
				{
					if (Math.abs(diff)/60 < Config.barabanSettings.maxLateMinutes)
					{
						TweenMax.delayedCall(3, processToVI);
					}
				}
			}
		}
		
		static private function showLateVIPopup():void 
		{
			DialogManager.alert(Lang.videoIdentificationTitle, Lang.videoidentificationLateDescription, onVILateResponse, Lang.textOk, Lang.CANCEL);
		}
		
		static private function onVILateResponse(val:int):void 
		{
			if (val == 1)
			{
				TweenMax.delayedCall(1, showVICalendar);
			}
			else
			{
				if (viAppointmentData != null)
				{
					cancelVIAppointment(viAppointmentData.id);
				}
			}
		}
		
		static private function showVICalendar():void 
		{
			DialogManager.showDialog(SelectRecognitionDatePopup, null);
		}
		
		static private function processToVI():void 
		{
			DialogManager.closeDialog();
			ServiceScreenManager.closeView();
			TweenMax.killDelayedCallsTo(processToVI);
			
			if (Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreen))
			{
				if (Auth.bank_phaseData.toUpperCase() == "MCA" && Auth.bank_phase.toLowerCase() == "vidid_queue")
				{
					S_START_VI.invoke();
				}
			}
			else
			{
				ChatManager.S_CHAT_OPENED.add(onChatStarted);
				needStartVI = true;
				PushNotificationsNative.setNotificationDataForSupport(Config.EP_VI_DEF);
			}
		}
		
		static private function onChatStarted():void 
		{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.COMPANY && ChatManager.getCurrentChat().pid == Config.EP_VI_DEF)
			{

				PHP.call_statVI("videoChatOpened", Config.EP_VI_DEF + "");

				ChatManager.S_CHAT_OPENED.remove(onChatStarted);
				if (needStartVI == true)
				{
					needStartVI = false;
				}
				if (Auth.bank_phaseData.toUpperCase() == "MCA" && Auth.bank_phase.toLowerCase() == "vidid_queue")
				{
					S_START_VI.invoke();
				}
			}
		}
		
		static private function showAppointmentPopup():void 
		{
			needShowAppointmentPopup = false;
			TweenMax.killDelayedCallsTo(showAppointmentPopup);
			DialogManager.showDialog(RecognitionDateRemindPopup, null);
		}
		
		static private function onViAppointmentBookRespond(respond:PHPRespond):void 
		{
			if (respond.error)
			{
				if (respond.errorMsg.indexOf("brbn.04") != -1)
				{
					appointmentUnavaliable = true;
					
					respond.dispose();
				}
				ToastMessage.display("Error, plase try again");
				S_APPOINTMENT_BOOK_FAIL.invoke();
			}
			
			if (respond.data != null && "info" in respond.data && respond.data.info != null)
			{
				
				viAppointmentData = new VIAppointmentData(respond.data);
				if (viAppointmentData != null && viAppointmentData.date != null)
				{
					ChatManager.sendBarabanRequest(viAppointmentData.date.getTime());
				}
				
				addAppointmentListeners();
			}
			else
			{
				ToastMessage.display("Error, plase try again");
				respond.dispose();
				return;
			}
		
			
			S_APPOINTMENT_BOOK.invoke(!respond.error, respond.errorMsg);
			respond.dispose();
		}
	}
}