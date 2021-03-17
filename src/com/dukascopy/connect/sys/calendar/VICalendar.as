package com.dukascopy.connect.sys.calendar 
{
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VICalendar 
	{
		public var success:Boolean;
		public var ready:Boolean;
		public var defaultTimeInterval:Number = 10;
		private var loading:Boolean;
		private var bookedDays:Object;
		private var days:Object;
		private var disposed:Boolean;
		public var lastDate:Date;
		
		public function VICalendar() 
		{
			loadData();
		}
		
		public function load():void 
		{
			if (loading == false)
			{
				loadData();
			}
		}
		
		public function getFreeTimeRanges(selectedDate:Date):DayBookData 
		{
			if (days != null && days[createTimeMark(selectedDate)] != null)
			{
				return days[createTimeMark(selectedDate)] as DayBookData;
			}
			return null;
		}
		
		public function loadRanges(selectedDate:Date):void 
		{
			PHP.call_barabanGetDay(onDayRangesLoaded, selectedDate);
		}
		
		public function getUnavaliableDays(year_month:String):BookedDays 
		{
			if (bookedDays != null && bookedDays[year_month] != null)
			{
				return bookedDays[year_month] as BookedDays;
			}
			return null;
		}
		
		public function dispose():void 
		{
			disposed = true;
		}
		
		private function onDayRangesLoaded(respond:PHPRespond):void 
		{
			if (disposed)
			{
				return;
			}
			if (respond.error == true)
			{
				if (respond.errorMsg == PHP.NETWORK_ERROR)
				{
					ToastMessage.display(Lang.alertProvideInternetConnection);
				}
				else{
					ToastMessage.display(Lang.textError);
				}
			}
			else
			{
				var date:Date = new Date();
				date.setTime(respond.data.start * 1000);
				addDayBookingData(respond.data.first, createTimeMark(date), date.getTimezoneOffset(), date);
			}
			
			Calendar.S_DAY_RANGES.invoke(respond.additionalData.date);
			respond.dispose();
		}
		
		private function loadData():void 
		{
			loading = true;
			ready = false;
			var now:Date = new Date();
			
			PHP.call_barabanCheckRange(onDataLoaded, now, 14, true);
		}
		
		private function onDataLoaded(respond:PHPRespond):void 
		{
			if (disposed)
			{
				return;
			}
			loading = false;
			ready = true;
			success = !respond.error;
			
			if (respond.error == true)
			{
				ToastMessage.display(respond.errorMsg);
			}
			else if (respond.data == null || ("end" in respond.data) == false)
			{
				ToastMessage.display(Lang.serverError);
			}
			else
			{
				parseData(respond.data);
			}
			respond.dispose();
			Calendar.S_CALENDAR_VI_READY.invoke();
		}
		
		private function parseData(data:Object):void 
		{
			var date:Date = new Date();
			date.setTime(data.start * 1000);
			
			lastDate = new Date();
			lastDate.setTime(data.end.startUTS * 1000);
			
			addUnavaliableDays(data.booked, date.getFullYear().toString() + "_" + date.getMonth().toString(), date.getDate());
			
			addDayBookingData(data.first, createTimeMark(date), date.getTimezoneOffset(), date);
		}
		
		private function createTimeMark(date:Date):String 
		{
			return date.getFullYear().toString() + "_" + date.getMonth().toString() + "_" + date.getDate().toString();
		}
		
		private function addUnavaliableDays(booked:Array, year_month:String, startDay:int):void 
		{
			if (bookedDays == null)
			{
				bookedDays = new Object();
			}
			var days:BookedDays = new BookedDays();
			if (booked != null)
			{
				var l:int = booked.length;
				for (var i:int = 0; i < l; i++) 
				{
					days.add(booked[i] + startDay - 1);
				}
			}
			bookedDays[year_month] = days;
		}
		
		private function addDayBookingData(rawData:Object, dateMask:String, difference:Number, start:Date):void 
		{
			var dayData:DayBookData = new DayBookData(rawData, difference, start);
			if (days == null)
			{
				days = new Object();
			}
			days[dateMask] = dayData;
		}
	}
}