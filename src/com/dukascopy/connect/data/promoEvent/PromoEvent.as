package com.dukascopy.connect.data.promoEvent 
{
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class PromoEvent 
	{
		public static const STATUS_NEW:String = "new";
		public static const STATUS_ACCEPTED:String = "accepted";
		public static const STATUS_STOPPED:String = "stopped";
		
		public static const PAYOUT_MANUAL:String = "manual";
		public static const PAYOUT_AUTO:String = "auto";
		
		static public const TYPE_MONEY:String = "typeMoney";
		static public const TYPE_IPHONE:String = "typeIphone";
		static public const TYPE_NEW_EVENT_SOON:String = "typeNewEventSoon";
		
		static public const RESULT_WIN:String = "resultWin";
		static public const RESULT_LOSE:String = "resultLose";
		static public const RESULT_NONE:String = "resultNone";
		
		static public const IMAGE_TYPE_1:String = "1";
		static public const IMAGE_TYPE_2:String = "2";
		static public const IMAGE_TYPE_3:String = "3";
		static public const IMAGE_TYPE_4:String = "4";
		static public const IMAGE_TYPE_5:String = "5";
		static public const IMAGE_TYPE_6:String = "6";
		static public const IMAGE_TYPE_8:String = "7";
		static public const IMAGE_TYPE_9:String = "8";
		
		static public const PARTICIPATE_NEED_ACCOUNT:String = "participateNeedAccount";
		static public const PARTICIPATE_NEED_ACCOUNT_3_FRIENDS:String = "participateNeedAccount3Friends";
		static public const PARTICIPATE_NEED_AVATAR:String = "participateNeedAvatar";
		static public const PARTICIPATE_FREE:String = "participateFree";
		static public const PARTICIPATE_NEED_DUK:String = "participateDuk";
		
		public var id:String;
		public var start:Number;
		public var stop:Number;
		public var payout:String;
		public var status:String;
		public var admin_uid:String;
		public var amount:Number;
		public var currency:String;
		public var name:String;
		public var result:String;
		public var cnt:int = 0;
		public var type:String;
		public var lastResult:String = RESULT_NONE;
		public var participant:Boolean = false;
		public var options:Vector.<EventLocalizedOptions>;
		public var disposed:Boolean;
		public var typeParticipate:String = PARTICIPATE_FREE;
		
		public function PromoEvent(rawData:Object) 
		{
			if (rawData != null)
			{
				parse(rawData);
			}
		}
		
		public function get image():String 
		{
			var result:String = IMAGE_TYPE_1;
			
			if (options != null && options.length > 0)
			{
				var l:int = options.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (LangManager.model != null)
					{
						if (options[i].lang == LangManager.model.getCurrentLanguageID())
						{
							result = options[i].banner_uid;
						}
					}
				}
				result = options[0].banner_uid;
			}
			
			if (result == null)
			{
				if (type == TYPE_IPHONE)
				{
					result = IMAGE_TYPE_2;
				}
				else if (type == TYPE_MONEY)
				{
					result = IMAGE_TYPE_1;
				}
			}
			
			if (typeParticipate == PARTICIPATE_NEED_ACCOUNT)
			{
				return IMAGE_TYPE_5;
			}
			if (typeParticipate == PARTICIPATE_NEED_AVATAR)
			{
				return IMAGE_TYPE_9;
			}
			if (typeParticipate == PARTICIPATE_NEED_DUK)
			{
				return IMAGE_TYPE_8;
			}
			else if (typeParticipate == PARTICIPATE_NEED_ACCOUNT_3_FRIENDS)
			{
				return IMAGE_TYPE_6;
			}
			
			if (result != IMAGE_TYPE_1 &&
				result != IMAGE_TYPE_2 &&
				result != IMAGE_TYPE_3 &&
				result != IMAGE_TYPE_5 &&
				result != IMAGE_TYPE_6 &&
				result != IMAGE_TYPE_4)
			{
				result = IMAGE_TYPE_1;
			}
			
			return result;
		}
		
		public function update(promoEvent:PromoEvent):void 
		{
			result = promoEvent.result;
			cnt = promoEvent.cnt;
			participant = promoEvent.participant;
		}
		
		private function parse(rawData:Object):void 
		{
			if ("id" in rawData)
			{
				id = rawData.id;
			}
			
			if ("start" in rawData)
			{
				start = rawData.start;
			}
			
			if ("stop" in rawData)
			{
				// 10 сек сверху
				stop = rawData.stop + 10;
			}
			
			if ("payout" in rawData)
			{
				payout = rawData.payout;
			}
			
			if ("status" in rawData)
			{
				status = rawData.status;
			}
			
			if ("admin_uid" in rawData)
			{
				admin_uid = rawData.admin_uid;
			}
			
			if ("amount" in rawData)
			{
				amount = rawData.amount;
			}
			
			if (amount == 0)
			{
				type = TYPE_IPHONE;
			}
			else{
				type = TYPE_MONEY;
			}
			
			if ("currency" in rawData)
			{
				currency = rawData.currency;
			}
			
			if ("name" in rawData)
			{
				name = rawData.name;
			}
			
			if ("result" in rawData)
			{
				result = rawData.result;
			}
			
			if ("cnt" in rawData)
			{
				cnt = rawData.cnt;
			}
			
			if ("prevResult" in rawData)
			{
				if (rawData.prevResult == "miss")
				{
					lastResult = RESULT_NONE;
				}
				else if (rawData.prevResult == "no")
				{
					lastResult = RESULT_LOSE;
				}
				else if (rawData.prevResult == "yes")
				{
					// winner
					lastResult = RESULT_WIN;
				}
			}
			
			if ("participant" in rawData)
			{
				participant = rawData.participant;
			}
			
			if ("type" in rawData)
			{
				if (rawData.type == 1)
				{
					typeParticipate = PARTICIPATE_NEED_ACCOUNT;
				}
				else if (rawData.type == 2)
				{
					typeParticipate = PARTICIPATE_NEED_ACCOUNT_3_FRIENDS;
				}
				else if (rawData.type == 3)
				{
					typeParticipate = PARTICIPATE_NEED_AVATAR;
				}
				else if (rawData.type == 4)
				{
					typeParticipate = PARTICIPATE_NEED_DUK;
				}
				else
				{
					typeParticipate = PARTICIPATE_FREE;
				}
			}
			else
			{
				typeParticipate = PARTICIPATE_FREE;
			}
			
		//	typeParticipate = PARTICIPATE_NEED_DUK;
			
			if ("options" in rawData && rawData.options != null && rawData.options is Array)
			{
				options = new Vector.<EventLocalizedOptions>();
				var option:EventLocalizedOptions;
				var l:int = (rawData.options as Array).length;
				for (var i:int = 0; i < l; i++) 
				{
					option = new EventLocalizedOptions(rawData.options[i]);
					options.push(option);
				}
			}
		}
		
		public function dispose():void
		{
			//!TODO;
			disposed = true;
		}
		
		public function getChannelId():String
		{
			if (options != null && options.length > 0)
			{
				var l:int = options.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (LangManager.model != null)
					{
						if (options[i].lang == LangManager.model.getCurrentLanguageID())
						{
							return options[i].cuid;
						}
					}
					return options[0].cuid;
				}
			}
			return null;
		}
		
		public function getDescription():String {
			if (options != null && options.length > 0) {
				var l:int = options.length;
				var key:String;
				for (var i:int = 0; i < l; i++) {
					if (options[i].lang == "en") {
						key = "LOTTO_" + options[i].description.replace(/\s/gi, "_").toUpperCase();
						if (key in Lang.lottoText == false)
							return options[i].description;
						if (Lang.lottoText[key] != null)
						{
							return Lang.lottoText[key];
						}
					}
				}
				return options[0].description;
			}
			return name;
		}
	}
}