package com.dukascopy.connect.sys {
	import com.telefision.sys.signals.Signal;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class GlobalDate {
		
		public static var S_NEW_DATE:Signal = new Signal("GlobalDate.S_NEW_DATE");
		
		private static var currentDate:int = 0;
		
		private static var _date:Date;
		private static var _dateCompared:Date;
		private static var _dateCurrent:Date;
		
		static private var initialized:Boolean = false;
		
		public static function init():void {
			if (initialized == true)
				return;
			initialized = true;
			var timer:Timer = new Timer(60000);
			_dateCurrent = new Date();
			currentDate = _dateCurrent.getDate();
			timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				_dateCurrent = new Date();
				var date:int = _dateCurrent.getDate();
				if (currentDate == date)
					return;
				currentDate = date;
				S_NEW_DATE.invoke(currentDate);
			});
			timer.start();
		}
		
		public static function update():void {
			_date = new Date();
		}
		
		public static function get date():Date {
			if (!_date)
				_date = new Date();
			return _date;
		}
		
		public static function get comparedDate():Date {
			if (!_dateCompared)
				_dateCompared = new Date();
			return _dateCompared;
		}
		
		static public function get dateCurrent():Date {
			return _dateCurrent;
		}
	}
}