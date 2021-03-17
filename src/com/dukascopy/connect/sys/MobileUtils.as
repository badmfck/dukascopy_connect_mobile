package com.dukascopy.connect.sys {
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	public class MobileUtils {
		
		public function MobileUtils() { }
		
		static public function getTime(time:Number, needPrefix:Boolean = false, fromServer:Boolean = true):String {
			if (time <= 0) return "Never";
			if (fromServer)
				var lmTime:Number = time * 1000;
			GlobalDate.update();
			var currentDate:Date = GlobalDate.date;
			var date:Date = GlobalDate.comparedDate;
			date.setTime(currentDate.getTime());
			date.setHours(0, 0, 0, 0);
			if (lmTime > date.getTime()) {
				date.setTime(lmTime);
				var h:int = date.getHours();
				var m:int = date.getMinutes();
				var ds:String = h + ":";
				if (ds.length == 2)
					ds = "0" + ds;
				ds += (m < 10) ? "0" + m : m;
				return (needPrefix) ? "at " + ds : ds;
			} else if (lmTime < date.getTime() - 86400000) {
				date.setTime(lmTime);
				var dateStr:String = String(date.getDate());
				if (dateStr.length == 1)
					dateStr = "0" + dateStr;
				var monthStr:String = String(date.getMonth() + 1);
				if (monthStr.length == 1)
					monthStr = "0" + monthStr;
				return (needPrefix) ? "on " + dateStr + "." + monthStr + "." + date.getFullYear() : dateStr + "." + monthStr + "." + date.getFullYear();
			}
			return "yesterday";
		}
	}
}