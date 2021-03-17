package com.dukascopy.connect.data.paidBan 
{
	import com.dukascopy.connect.data.paidBan.PaidBanReason;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanReasons 
	{
		public static const REASON_1:int = 1;
		public static const REASON_2:int = 2;
		public static const REASON_3:int = 3;
		public static const REASON_4:int = 4;
		public static const REASON_5:int = 5;
		public static const REASON_6:int = 6;
		public static const REASON_7:int = 7;
		public static const REASON_8:int = 8;
		public static const REASON_9:int = 9;
		public static const REASON_10:int = 10;
		public static const REASON_11:int = 11;
		public static const REASON_12:int = 12;
		public static const REASON_13:int = 13;
		public static const REASON_14:int = 14;
		public static const REASON_15:int = 15;
		public static const REASON_16:int = 16;
		static public const REASON_17:int = 17;
		static public const REASON_18:int = 18;
		
		static private var resons:Vector.<PaidBanReason>;
		static private var currentLang:String;
		
		public function PaidBanReasons() {
			
		}
		
		public static function getReasons():Vector.<PaidBanReason> {
			if (resons == null || currentLang != LangManager.model.getCurrentLanguageID()) {
				currentLang = LangManager.model.getCurrentLanguageID();
				resons = new Vector.<PaidBanReason>();
				resons.push(new PaidBanReason(REASON_1, Lang.banReason1));
				resons.push(new PaidBanReason(REASON_2, Lang.banReason2));
				resons.push(new PaidBanReason(REASON_3, Lang.banReason3));
				resons.push(new PaidBanReason(REASON_4, Lang.banReason4));
				
				//flirt
				resons.push(new PaidBanReason(REASON_17, Lang.banReason17));
				resons.push(new PaidBanReason(REASON_18, Lang.banReason18));
				
				resons.push(new PaidBanReason(REASON_5, Lang.banReason5));
				resons.push(new PaidBanReason(REASON_6, Lang.banReason6));
				resons.push(new PaidBanReason(REASON_7, Lang.banReason7));
				resons.push(new PaidBanReason(REASON_8, Lang.banReason8));
				resons.push(new PaidBanReason(REASON_9, Lang.banReason9));
				resons.push(new PaidBanReason(REASON_10, Lang.banReason10));
				resons.push(new PaidBanReason(REASON_11, Lang.banReason11));
				resons.push(new PaidBanReason(REASON_12, Lang.banReason12));
				resons.push(new PaidBanReason(REASON_16, Lang.banReason16));
				resons.push(new PaidBanReason(REASON_14, Lang.banReason14));
				resons.push(new PaidBanReason(REASON_15, Lang.banReason15));
				resons.push(new PaidBanReason(REASON_13, Lang.banReason13));
			}
			return resons;
		}
		
		static public function getReason(reasonId:int):String	{
			var resonsCollection:Vector.<PaidBanReason> = getReasons();
			if (resonsCollection != null) {
				var l:int = resonsCollection.length;
				for (var i:int = 0; i < l; i++) {
					if (resonsCollection[i].id == reasonId) {
						return resonsCollection[i].label;
					}
				}
			}
			return null;
		}
	}
}