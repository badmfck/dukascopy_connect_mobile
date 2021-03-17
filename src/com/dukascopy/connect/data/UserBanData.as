package com.dukascopy.connect.data 
{
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserBanData 
	{
		static public const DURATION_PERMANENT:String = "durationPermanent";
		static public const DURATION_MONTH:String = "durationMonth";
		static public const DURATION_DAY:String = "durationDay";
		static public const DURATION_HOUR:String = "durationHour";
		
		public var reason:String;
		public var duration:String;
		
		public var banCreatedTime:Number;
		public var banEndTime:Number;
		public var moderator:String;
		public var uid:String;
		
		public function UserBanData() 
		{
			
		}
		
		public function getDurationTime():Number 
		{
			var time:Number;
			switch(duration)
			{
				case DURATION_PERMANENT:
				{
					break;
				}
				case DURATION_MONTH:
				{
					time = 60 * 24 * 30;
					break;
				}
				case DURATION_DAY:
				{
					time = 60 * 24;
					break;
				}
				case DURATION_HOUR:
				{
					time = 60;
					break;
				}
			}
			return time;
		}
		
		public function getDurationText():String 
		{
			var result:String = "";
			if (!isNaN(banCreatedTime) && !isNaN(banEndTime))
			{
				var durationTime:Number = (banEndTime - banCreatedTime) / (60 * 60);
				switch(durationTime)
				{
					case 1:
					{
						result = "1 " + Lang.textHour;
						break;
					}
					case 24:
					{
						result = "1 " + Lang.textDay;
						break;
					}
					case 24*30:
					{
						result = "1 " + Lang.textMonth;
						break;
					}
					case 0:
					{
						result = Lang.textPermanent;
						break;
					}
					default:
					{
						result = ((banEndTime - banCreatedTime) / (1000* 60 * 60)).toString() + " " + Lang.textHours;
					}
				}
			}
			return result;
		}
	}
}