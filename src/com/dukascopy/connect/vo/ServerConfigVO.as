package com.dukascopy.connect.vo {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.BarabanSettings;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.langs.Lang;
	
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
			
			var apps:Array = new Array();
			
			var jf:Object = new Object();
			jf.name = Lang.launchJForex;
			jf.type = "app";
			jf.idIOS = "com.dukascopy.iplatform://";
			jf.idAndroid = "com.dukascopy.platform";
			jf.linkIOS = "https://apps.apple.com/us/app/jforex/id364049165"
			jf.linkAndroid = "https://play.google.com/store/apps/details?id=com.dukascopy.platform&hl=uk&gl=US";
			apps.push(jf);
			
			var jfw:Object = new Object();
			jfw.name = Lang.launchJForexWeb;
			jfw.type = "web";
			jfw.link = "https://live-login.dukascopy.com/web-platform/";
			jfw.linkIOS = "https://apps.apple.com/us/app/jforex/id364049165"
			jfw.linkAndroid = "https://play.google.com/store/apps/details?id=com.dukascopy.platform&hl=uk&gl=US";
			apps.push(jfw);
			
			var mt4:Object = new Object();
			mt4.name = Lang.launchMT4;
			mt4.type = "app";
			mt4.idIOS = "net.metaquotes.MetaTrader4Terminal://";
			mt4.idAndroid = "net.metaquotes.metatrader4";
			mt4.linkIOS = "https://apps.apple.com/us/app/metatrader-4/id496212596"
			mt4.linkAndroid = "https://play.google.com/store/apps/details?id=net.metaquotes.metatrader4&hl=en&referrer=ref_id%3d1011367727760268752%26hl%3den";
			apps.push(mt4);
			
			var bt:Object = new Object();
			bt.name = Lang.launchBinaryTrader;
			bt.type = "web";
			bt.link = "https://login.dukascopy.com/binary/mobile/";
			apps.push(bt);
			
			var acc:Object = new Object();
			acc.name = Lang.launchCurrentAccount;
			acc.type = "web";
			acc.link = "https://ebank.dukascopy.com";
			apps.push(acc);
			
			var localData:String = JSON.stringify(apps);
			if (_raw == null)
				return localData;
			if ("APPLICATIONS" in _raw == true)
				return _raw.APPLICATIONS;
			return localData;
		}
		
		public function get escrowReportType():String {
			
			var localData:String = '[{"label":"escrow_report_1", "code":"1"},'+
									'{"label":"escrow_report_2", "code":"2"},' +
									'{"label":"escrow_report_3", "code":"3"},' +
									'{"label":"escrow_report_4", "code":"4"},' +
									'{"label":"escrow_report_5", "code":"5"},' +
									'{"label":"escrow_report_6", "code":"6"}' +
									']';
			if (_raw == null)
				return localData;
			if ("APPLICATIONS" in _raw == true)
				return _raw.ESCROW_REPORT_TYPE;
			return localData;
		}
		
		public function get bankCacheMinute():int {
			if (_raw == null)
				return -1;
			if ("BANK_CACHE_MINUTE" in _raw == true)
				return _raw.BANK_CACHE_MINUTE;
			return -1;
		}
		
		public function get supportBotUID():String {
			if (_raw == null)
				return "WgDNWdIEW4I6IsWg";
			if ("SUPPORT_BOT_UID" in _raw == true)
				return _raw.SUPPORT_BOT_UID;
			return "WgDNWdIEW4I6IsWg";
		}
		
		public function get escrow_time_offer_accepted():int {
			var result:Number = 5;
			if (_raw != null && "offer_accepted" in _raw == true)
				result = int(_raw.offer_accepted /  (1000 * 60));
			return result;
		}
		
		public function get escrow_time_deal_completed():int {
			var result:Number = 30;
			if (_raw != null && "deal_completed" in _raw == true)
				result = int(_raw.deal_completed /  (1000 * 60));
			return result;
		}
		
		public function get escrow_time_deal_expired():int {
			var result:Number = 60;
			if (_raw != null && "deal_expired" in _raw == true)
				result = int(_raw.deal_expired /  (1000 * 60));
			return result;
		}
		
		public function get escrow_time_deal_confirm_crypto():int {
			var result:Number = 24 * 60;
			if (_raw != null && "deal_confirm_crypto" in _raw == true)
				result = int(_raw.deal_confirm_crypto / (1000 * 60));
			return result;
		}
		
		public function get disableP2P():Boolean {
			if (_raw == null)
				return false;
			if ("DISABLE_P2P" in _raw == true && _raw.DISABLE_P2P == "true")
				return true;
			return false;
		}
	}
}