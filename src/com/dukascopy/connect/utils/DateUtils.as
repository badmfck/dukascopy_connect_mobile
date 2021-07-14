package com.dukascopy.connect.utils {

	import com.dukascopy.langs.Lang;
	import flash.utils.describeType;

	/**
	 * ...
	 * @author ...
	 */
	
	public class DateUtils {
		
		public function DateUtils() { }
		
		public static function getComfortDateRepresentationWithMinutes(date:Date):String {
			if (!date || isNaN(date.getMonth()))
				return "";
			
			var result:String;
			var currentDate:Date = new Date();
			var difference:Number = currentDate.getTime() - date.getTime();
			
			if (currentDate.getFullYear() == date.getFullYear() && 
				currentDate.getMonth() == date.getMonth() && 
				currentDate.getDate() == date.getDate()) {
					if (difference < 600000)
						return (Math.max(1, Math.floor(difference/60000))).toString() + " " + Lang.minAgo;
					result = "";
					result = date.getMinutes().toString().concat(result);
					if (result.length == 1)
						result = "0".concat(result);
					result = ":".concat(result);
					result = date.getHours().toString().concat(result);
					if (result.length == 4)
						result = "0".concat(result);
					return result;
			} else {
				currentDate.setTime(currentDate.getTime() - 86400000);
				if (currentDate.getFullYear() == date.getFullYear() && 
					currentDate.getMonth() == date.getMonth() && 
					currentDate.getDate() == date.getDate()) {
						return Lang.textYesterday;
				} else {
					result = "." + date.getFullYear();
					result = (date.getMonth() + 1).toString().concat(result);
					if (result.length == 6)
						result = "0".concat(result);
					result = ".".concat(result);
					result = date.getDate().toString().concat(result);
					if (result.length == 9)
						result = "0".concat(result);
					return result;
				}
			}
			return "";
		}

		public static function format(time:Object,mask:String):String{
			/*var dt=null;
			if(time instanceof Date)
				dt=time;
			else if(time instanceof String){
				//time=
			}*/

			return time as String;

		}
		
		public static function getComfortDateRepresentation(date:Date, showCurrentYear:Boolean = true):String {
			if (date == null || isNaN(date.getMonth()))
				return "";
			
			var result:String;
			var currentDate:Date = new Date();
			var difference:Number = currentDate.getTime() - date.getTime();
			
			if (currentDate.getFullYear() == date.getFullYear() && 
				currentDate.getMonth() == date.getMonth() && 
				currentDate.getDate() == date.getDate()) {
					result = "";
					result = date.getMinutes().toString().concat(result);
					if (result.length == 1)
						result = "0".concat(result);
					result = ":".concat(result);
					result = date.getHours().toString().concat(result);
					if (result.length == 4)
						result = "0".concat(result);
					return result;
			} else {
				currentDate.setTime(currentDate.getTime() - 86400000);
				if (currentDate.getFullYear() == date.getFullYear() && 
					currentDate.getMonth() == date.getMonth() && 
					currentDate.getDate() == date.getDate()) {
					return Lang.textYesterday;
				} else {
					if (date.getFullYear() == currentDate.getFullYear()) {
						showCurrentYear = false;
					}
					if (showCurrentYear) {
						result = "." + date.getFullYear();
					}
					else {
						result = "";
					}
					
					result = (date.getMonth() + 1).toString().concat(result);
					if ((showCurrentYear && result.length == 6) || (!showCurrentYear && result.length == 1))
						result = "0".concat(result);
					result = ".".concat(result);
					result = date.getDate().toString().concat(result);
					if ((showCurrentYear && result.length == 9) || (!showCurrentYear && result.length == 4))
						result = "0".concat(result);
					return result;
				}
			}
			return "";
		}
		
		public static function getComfortDateRepresentationOnlyDate(date:Date, showYear:Boolean = false, delimiter:String = "."):String {
			if (date == null || isNaN(date.getMonth()))
				return "";
			var showCurrentYear:Boolean = true;
			var result:String;
			var currentDate:Date = new Date();
			var difference:Number = currentDate.getTime() - date.getTime();
			
			if (date.getFullYear() == currentDate.getFullYear() && showYear == false) {
				showCurrentYear = false;
			}
			if (showCurrentYear) {
				result = delimiter + date.getFullYear();
			}
			else {
				result = "";
			}
			
			result = (date.getMonth() + 1).toString().concat(result);
			if ((showCurrentYear && result.length == 6) || (!showCurrentYear && result.length == 1))
				result = "0".concat(result);
			result = delimiter.concat(result);
			result = date.getDate().toString().concat(result);
			if ((showCurrentYear && result.length == 9) || (!showCurrentYear && result.length == 4))
				result = "0".concat(result);
			return result;
		}
		
		public static function getDateStringByFormat(date:Date, format:String = "YYYY-MM-DD", useGMT:Boolean = false):String {
			if (date == null)
				return "";
			var result:String = format.toLowerCase();
			if (result.indexOf("yyyy") != -1)
				result = result.replace("yyyy", (useGMT == true) ? date.getUTCFullYear() : date.getFullYear());
			if (result.indexOf("yy") != -1)
				result = result.replace("yy", (useGMT == true) ? String(date.getUTCFullYear()).substr(2) : String(date.getFullYear()).substr(2));
			if (result.indexOf("dd") != -1) {
				if (useGMT == true) {
					if (date.getUTCDate() < 10)
						result = result.replace("dd", "0" + date.getUTCDate());
					else
						result = result.replace("dd", date.getUTCDate());
				} else {
					if (date.getDate() < 10)
						result = result.replace("dd", "0" + date.getDate());
					else
						result = result.replace("dd", date.getDate());
				}
			}
			if (result.indexOf("d") != -1)
				result = result.replace("d", (useGMT == true) ? date.getUTCDate() : date.getDate());
			if (result.indexOf("mm") != -1) {
				if (useGMT == true) {
					if (date.getUTCMonth() < 9)
						result = result.replace("mm", "0" + (date.getUTCMonth() + 1));
					else
						result = result.replace("mm", (date.getUTCMonth() + 1));
				} else {
					if (date.getMonth() < 9)
						result = result.replace("mm", "0" + (date.getMonth() + 1));
					else
						result = result.replace("mm", (date.getMonth() + 1));
				}
			}
			if (result.indexOf("m") != -1)
				result = result.replace("m", (useGMT == true) ? (date.getUTCMonth() + 1) : (date.getMonth() + 1));
			return result;
		}
		
		public static function isToday(date:Date):Boolean {
			var currentDate:Date = new Date();
			if (currentDate.getFullYear() == date.getFullYear() && 
				currentDate.getMonth() == date.getMonth() && 
				currentDate.getDate() == date.getDate()) 
					return true;
			return false;
		}
		
		public static function getInHours(milliseconds:int):Number {
			return milliseconds / (1000 * 60 * 60);
		}
		
		/**
		 *
		 * @param instance - class instance // new ChatMessageInvoiceData();
		 * @return  variables Object
		 */
		public static function getObjectVariableByClass(instance:*):Object {
			var description:XML = describeType(instance);
			var variables:XMLList = description..variable;
			var _defaultKeys:Object = {};
			for each(var variable:XML in variables)
				_defaultKeys[variable.@name] = instance[variable.@name];
			return _defaultKeys;
		}
		
		public static function toString(date:Date):String {
			return date.time.toString();
		}
		
		public static function fromString(string:String):Date {
			var res:Date = new Date();
			var time:Number = Number(string);
			res.setTime(time);
			return res;
		}
		
		static public function getComfortTimeRepresentation(difference:Number):String 
		{
			var minutes:Number = Math.floor((difference / (1000 * 60)) % 60);
			var hours:Number = Math.floor((difference / (1000 * 60 * 60)) % 24);
			var days:Number = Math.floor((difference / (1000 * 60 * 60)) / 24);
			
			var result:String = "";
			if (days > 0) {
				result += days + " " + Lang.days + " ";
			}
			if (hours > 0) {
				result += hours + " " + Lang.textHours + " ";
			}
			if (minutes > 0) {
				result += minutes + " " + Lang.textMinutes + " ";
			}
			
			return result;
		}
		
		static public function getComfortTimeRepresentationSmall(difference:Number):String 
		{
			var minutes:Number = Math.floor((difference / (1000 * 60)) % 60);
			var hours:Number = Math.floor((difference / (1000 * 60 * 60)) % 24);
			var days:Number = Math.floor((difference / (1000 * 60 * 60)) / 24);
			
			var result:String = "";
			if (days > 0) {
				result += days + " " + Lang.days + " ";
			}
			else if (hours > 0) {
				result += hours + " " + Lang.textHours + " ";
			}
			else if (minutes > 0) {
				result += minutes + " " + Lang.textMinutes + " ";
			}
			
			return result;
		}
		
		static public function getTimeInNumbers(difference:Number):String 
		{
			var seconds:Number = Math.floor((difference / (1000)) % 60);
			var minutes:Number = Math.floor((difference / (1000 * 60)) % 60);
			var hours:Number = Math.floor((difference / (1000 * 60 * 60)) % 24);
			var days:Number = Math.floor((difference / (1000 * 60 * 60)) / 24);
			
			if (days > 0)
			{
				var day:String;
				if (days > 1)
				{
					day = Lang.days;
				}
				else{
					day = Lang.day;
				}
				return days.toString() + " " + day + " " + hours.toString() + " " + Lang.textHours;
			}
			else{
				var result:String = seconds.toString();
				if (result.length == 1)
				{
					result = "0" + result;
				}
				result = ":" + result;
				
				result = minutes + result;
				if (result.length == 4)
				{
					result = "0" + result;
				}
				result = ":" + result;
				
				result = hours + result;
				if (result.length == 7)
				{
					result = "0" + result;
				}
				
				return result;
			}
			return "";
		}
		
		static public function getTimeInNumbers2(difference:Number):String 
		{
			var seconds:Number = Math.floor((difference / (1000)) % 60);
			var minutes:Number = Math.floor((difference / (1000 * 60)) % 60);
			var hours:Number = Math.floor((difference / (1000 * 60 * 60)) % 24);
			var days:Number = Math.floor((difference / (1000 * 60 * 60)) / 24);
			
			if (days > 0)
			{
				var day:String;
				if (days > 1)
				{
					day = Lang.days;
				}
				else{
					day = Lang.day;
				}
				return days.toString() + " " + day + " " + hours.toString() + " " + Lang.textHours;
			}
			else{
				var result:String = seconds.toString();
				if (result.length == 1)
				{
					result = "0" + result;
				}
				result = ":" + result;
				
				result = minutes + result;
				
				
				if (hours > 0)
				{
					if (result.length == 4)
					{
						result = "0" + result;
					}
					
					result = ":" + result;
					result = hours + result;
					if (result.length == 7)
					{
						result = "0" + result;
					}
				}
				
				return result;
			}
			return "";
		}
		
		static public function getTimeString(date:Date, onlyDate:Boolean = false, plusYears:int = 0, byUTC:Boolean = true, delimiter:String = "-", needSeconds:Boolean = false):String {
			if (plusYears != 0)
				date.setFullYear(date.getFullYear() + plusYears);
			var dateString:String = getDateStringByFormat(date, "YYYY" + delimiter + "MM" + delimiter + "DD", byUTC);
			if (onlyDate)
				return dateString;
			var minutes:String = date.getUTCMinutes().toString();
			if (minutes.length == 1)
				minutes = "0" + minutes;
			var hours:String;
			if (byUTC == true)
				hours = (date.getUTCHours()).toString();
			else
				hours = (date.getHours()).toString();
			if (hours.length == 1)
				hours = "0" + hours;
			if (needSeconds) {
				var sec:String = (date.getSeconds()).toString();
				if (sec.length == 1)
					sec = "0" + sec;
				return dateString + " " + hours + ":" + minutes + ":" + sec;
			}
			return dateString + " " + hours + ":" + minutes;
		}
		
		static public function month(month:int, year:int):String {
			var index:int = (month - 1);
			var monthkey:String = "month_" + index;
			var result:String = Lang[monthkey];
			if ((new Date()).getFullYear() != year) {
				result += " " + year;
			}
			return result;
		}
	}
}