package com.dukascopy.connect.vo {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.BarabanSettings;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ServerConfigVO {
		
		private var _raw:Object;
		private var _barabanSettings:BarabanSettings;
		private var _cryptoCoinRatio:Array;
		private var _payStatLimits:Array;
		
		public function ServerConfigVO(data:String = null) {
			if (data != null)
				update(data);
		}
		
		public function update(data:String):void {
			if (data == null || data == "")
				return;
			try {
				_raw = JSON.parse(data);
			} catch (err:Error) {
				echo("ServerConfigVO", "update", "Error: " + err.message);
			}
			if (_raw == null)
				return;
			var newKey:String;
			for (var n:String in data) {
				newKey = n.replace(/\s+/g, "");
				if (newKey == n)
					continue;
				_raw[newKey] = _raw[n];
				delete _raw[n];
			}
		}
		
		public function get data():Object { return _raw; }
		
		public function get investmentsEnabled():Boolean {
			if (_raw == null)
				return false;
			return ("ENABLE_INVESTMENTS" in _raw == true && _raw.ENABLE_INVESTMENTS == "1");
		}
		
		public function get barabanEnabled():Boolean {
			if (_raw == null)
				return true;
			return ("BARABAN" in _raw == false || _raw.BARABAN != 0);
		}
		
		public function get hideReportButtonMinMessagesInNewChat():int {
			if (_raw == null)
				return 10;
			if ("HIDE_REPORT_BUTTON_MIN_MESSAGES_IN_NEW_CHAT" in _raw == true)
				return _raw.HIDE_REPORT_BUTTON_MIN_MESSAGES_IN_NEW_CHAT;
			return 10;
		}
		
		public function get hideReportButtonMinChatAge():Number {
			if (_raw == null)
				return 48;
			if ("HIDE_REPORT_BUTTON_MIN_CHAT_AGE" in _raw == true)
				return _raw.HIDE_REPORT_BUTTON_MIN_CHAT_AGE;
			return 48;
		}
		
		public function get barabanSettings():Boolean {
			if (_raw == null)
				return null;
			if (_barabanSettings != null)
				return _barabanSettings;
			if ("barabanSettings" in _raw == true && _raw.barabanSettings != null);
				_barabanSettings = new BarabanSettings(_raw.barabanSettings);
			return _barabanSettings;
		}
		
		public function get cryptoEnabled():Boolean {
			if (Auth.companyID == "08A29C35B3")
				return true;
			if (_raw == null)
				return false;
			return ("CRYPTO" in _raw == true && _raw.CRYPTO == 1)
		}
		
		public function get cryptoRewardIBAN():String {
			if (_raw == null)
				return null;
			if ("CRYPTO_REWARD_IBAN" in _raw == true && _raw.CRYPTO_REWARD_IBAN != null && _raw.CRYPTO_REWARD_IBAN != "")
				return _raw.CRYPTO_REWARD_IBAN;
			return null;
		}
		
		public function get cryptoRewardAccount():String {
			if (_raw == null)
				return null;
			if ("CRYPTO_REWARD_ACCOUNT" in _raw == true && _raw.CRYPTO_REWARD_ACCOUNT != null && _raw.CRYPTO_REWARD_ACCOUNT != "")
				return _raw.CRYPTO_REWARD_ACCOUNT;
			return null;
		}
		
		public function get cryptoRewardFiatMIN():Number {
			if (_raw == null)
				return NaN;
			if ("MIN_FIAT" in _raw == true && isNaN(_raw.MIN_FIAT) != true)
				return _raw.MIN_FIAT;
			return NaN;
		}
		
		public function get cryptoRewardFiatMAX():Number {
			if (_raw == null)
				return NaN;
			if ("CRYPTO_FIAT_MAX" in _raw == true && isNaN(_raw.CRYPTO_FIAT_MAX) != true)
				return _raw.CRYPTO_FIAT_MAX;
			return NaN;
		}
		
		public function get cryptoRewardCoinMAX():Number {
			if (_raw == null)
				return NaN;
			if ("CRYPTO_DEPOSITE_MAX" in _raw == true && isNaN(_raw.CRYPTO_DEPOSITE_MAX) != true)
				return _raw.CRYPTO_DEPOSITE_MAX;
			return NaN;
		}
		
		public function get COINS_CSC_LLF_PRICE_LIMIT():Number {
			if (_raw == null)
				return 1;
			if ("COINS_CSC_LLF_PRICE_LIMIT" in _raw == true && isNaN(_raw.COINS_CSC_LLF_PRICE_LIMIT) != true)
				return _raw.COINS_CSC_LLF_PRICE_LIMIT;
			return 1;
		}
		
		public function get COINS_CSC_LLF_EUR_PER_COIN():Number {
			if (_raw == null)
				return 0.2;
			if ("COINS_CSC_LLF_EUR_PER_COIN" in _raw == true && isNaN(_raw.COINS_CSC_LLF_EUR_PER_COIN) != true)
				return _raw.COINS_CSC_LLF_EUR_PER_COIN;
			return 0.2;
		}
		
		public function get cryptoRewardCoinRatio():Array {
			if (_raw == null)
				return null;
			if (_cryptoCoinRatio != null)
				return _cryptoCoinRatio;
			if ("CRYPTO_DEPOSIT_RATIO" in _raw == true && _raw.CRYPTO_DEPOSIT_RATIO != null && _raw.CRYPTO_DEPOSIT_RATIO != "") {
				_cryptoCoinRatio = _raw.CRYPTO_DEPOSIT_RATIO.split(";");
				var index:int;
				for (var i:int = 0; i < _cryptoCoinRatio.length; i++) {
					index = _cryptoCoinRatio[i].indexOf(",");
					if (index == -1)
						_cryptoCoinRatio.splice(i, 1);
					_cryptoCoinRatio[i] = {
						amount: _cryptoCoinRatio[i].substring(0, index),
						reward: _cryptoCoinRatio[i].substring(index + 1)
					};
				}
			}
			return _cryptoCoinRatio;
		}
		
		public function get payStatLimits():Array {
			if (_raw == null)
				return null;
			if (_payStatLimits != null)
				return _payStatLimits;
			if ("PAY_STAT_LIMITS" in _raw == true && _raw.PAY_STAT_LIMITS != null && _raw.PAY_STAT_LIMITS != "") {
				_payStatLimits = _raw.PAY_STAT_LIMITS.split(";");
				var index:int;
				for (var i:int = 0; i < _payStatLimits.length; i++) {
					index = _payStatLimits[i].indexOf(",");
					if (index == -1)
						_payStatLimits.splice(i, 1);
					_payStatLimits[i] = {
						currency: _payStatLimits[i].substring(0, index),
						min: Number(_payStatLimits[i].substring(index + 1, _payStatLimits[i].indexOf(",", index + 1))),
						max: Number(_payStatLimits[i].substring(_payStatLimits[i].indexOf(",", index + 1) + 1))
					};
				}
			}
			return _payStatLimits;
		}
		
		public function get cryptoBlockchainURL():String {
			if (_raw == null)
				return null;
			if ("URL_CRYPTO" in _raw == true && _raw.URL_CRYPTO != null && _raw.URL_CRYPTO != "")
				return _raw.URL_CRYPTO;
			return null;
		}
		
		public function get passPhotoEnabled():Boolean {
			if (_raw == null)
				return false;
			return ("PASS_PHOTO" in _raw == true && _raw.PASS_PHOTO == 1)
		}
		
		public function get bankBotEnabled():Boolean {
			if (_raw == null)
				return false;
			return ("BANKBOT" in _raw == true && _raw.BANKBOT == 1)
		}
		
		public function get geoPositionEnabled():Boolean {
			if (_raw == null)
				return false;
			return ("GEO_POSITION" in _raw == true && _raw.GEO_POSITION == 1)
		}
		
		public function get lotteryEnabled():Boolean {
			if (_raw == null)
				return false;
			return ("LOTTERY" in _raw == true && _raw.LOTTERY == 1)
		}
		
		public function get paidChannelEnabled():Boolean {
			if (_raw == null)
				return false;
			return ("PAID_CHANNEL" in _raw == true && _raw.PAID_CHANNEL == 1)
		}
		
		public function get referalEnabled():Boolean {
			if (_raw == null)
				return true;
			return ("referral" in _raw == false || _raw.referral != 0)
		}
		
		public function get botsEnabled():Boolean {
			if (_raw == null)
				return false;
			return ("BOTS" in _raw == true && _raw.BOTS == 1)
		}
		
		public function get rtoLinkEU():String {
			if (_raw == null)
				return null;
			if ("RTO_EU_LINK" in _raw == true && _raw.RTO_EU_LINK != null && _raw.RTO_EU_LINK != "")
				return _raw.RTO_EU_LINK;
			return null;
		}
		
		public function get mainAPI():String {
			if (_raw == null)
				return null;
			if ("MAIN_API" in _raw == true && _raw.MAIN_API != null && _raw.MAIN_API != "")
				return _raw.MAIN_API;
			return null;
		}
		
		public function get firstQuestionTimeOUT():Number {
			if (_raw == null)
				return NaN;
			if ("questionWait" in _raw == true && isNaN(_raw.questionWait) == false)
				return _raw.questionWait;
			return NaN;
		}
		
		public function get firstLoadChatMessagesCount():Number {
			if (_raw == null)
				return NaN;
			if ("msgsCount" in _raw == true && isNaN(_raw.msgsCount) == false)
				return _raw.msgsCount;
			return NaN;
		}
		
		public function get firstLoadChatsCount():Number {
			if (_raw == null)
				return NaN;
			if ("chatsCount" in _raw == true && isNaN(_raw.chatsCount) == false)
				return _raw.chatsCount;
			return NaN;
		}
		
		public function get referalCodes():String {
			if (_raw == null)
				return null;
			if ("refCodes" in _raw == true && _raw.refCodes != null && _raw.refCodes != "")
				return _raw.refCodes;
			return null;
		}
		
		public function get jailEnabled():Boolean {
			if (_raw == null)
				return true;
			return ("jail" in _raw == true && _raw.jail.toString() == "1")
		}
		
		public function get protectionsNum():Number {
			if (_raw == null)
				return NaN;
			if ("protectionsNum" in _raw == true && isNaN(_raw.protectionsNum) == false)
				return _raw.protectionsNum;
			return NaN;
		}
		
		public function get georgianTeen():int {
			if (_raw == null)
				return NaN;
			if ("GEORGIAN_TEEN" in _raw == true && isNaN(_raw.GEORGIAN_TEEN) == false)
				return _raw.GEORGIAN_TEEN;
			return 27;
		}
		
		public function get userbanEnabled():Boolean {
			if (_raw == null)
				return true;
			return ("userban" in _raw == true && _raw.userban.toString() != "0")
		}
		
		public function get innerCurrency():String {
			if (_raw == null)
				return "DCO";
			if ("INNER_CURRENCY" in _raw == true && _raw.INNER_CURRENCY != "")
				return _raw.INNER_CURRENCY;
			return "DCO";
		}
		
		public function get useNewPayLoader():Boolean {
			if (_raw == null)
				return Config.isTest();
			if ("PAY_NEW_SIGNATURE" in _raw == true && _raw.PAY_NEW_SIGNATURE == "1")
				return true;
			return Config.isTest();
		}
		
		public function get mrzSkipEnabled():Boolean {
			if (_raw == null)
				return true;
			if ("MRZ_SKIP_ENABLED" in _raw == true && _raw.MRZ_SKIP_ENABLED == "0")
				return false;
			return true;
		}
		
		public function get channelStars():int {
			if (_raw == null)
				return 3;
			if ("CHANNEL_STARS" in _raw == true)
				return int(_raw.CHANNEL_STARS);
			return 3;
		}
		
		public function get minForTrading():int {
			if (_raw == null)
				return 500;
			if ("MIN_FOR_TRADING" in _raw == true)
				return int(_raw.MIN_FOR_TRADING);
			return 500;
		}
		
		public function get applications():String {
			
			var localData:String = '[{"name":"Launch JForex App", "type":"app", "idIOS":"com.dukascopy.iplatform://", "idAndroid":"com.dukascopy.platform", "linkIOS":"https://apps.apple.com/us/app/jforex/id364049165", "linkAndroid":"https://play.google.com/store/apps/details?id=com.dukascopy.platform&hl=uk&gl=US"}, {"name":"Launch JForex Web", "type":"web", "link":"https://live-login.dukascopy.com/web-platform/"}, {"name":"Launch MT4 App", "type":"app", "linkIOS":"https://apps.apple.com/us/app/metatrader-4/id496212596", "idIOS":"net.metaquotes.MetaTrader4Terminal://", "idAndroid":"net.metaquotes.metatrader4", "linkAndroid":"https://play.google.com/store/apps/details?id=net.metaquotes.metatrader4&hl=en&referrer=ref_id%3d1011367727760268752%26hl%3den"}, {"name":"Launch Binary Trader App", "type":"web", "link":"https://login.dukascopy.com/binary/mobile/"}, {"name":"Current account", "type":"web", "link":"https://ebank.dukascopy.com"}]';
			if (_raw == null)
				return localData;
			if ("APPLICATIONS" in _raw == true)
				return _raw.APPLICATIONS;
			return localData;
		}
		
		public function get bankCacheMinute():int {
			if (_raw == null)
				return -1;
			if ("BANK_CACHE_MINUTE" in _raw == true)
				return _raw.BANK_CACHE_MINUTE;
			return -1;
		}
	}
}