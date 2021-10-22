package com.dukascopy.connect.sys.configManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.BarabanSettings;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankBotController;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.vo.ServerConfigVO;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ConfigManager {
		
		static public var S_CONFIG_READY:Signal = new Signal("ConfigManager.S_CONFIG_READY");
		
		static private var _rawConfig:ServerConfigVO = new ServerConfigVO();
		static private var _callBack:Function;
		
		static private var lastTS:Number = NaN;
		static private var updateDelay:Number = 60 * 60 * 1000;
		
		public function ConfigManager() { }
		
		static public function init(cb:Function):void {
			_callBack = cb;
			
			TweenMax.delayedCall(3, invokeCallback);
			
			getConfig();
			
			WS.S_CONNECTED.add(getConfig);
			
			GD.S_BANK_CACHE_CONFIG_REQUEST.add(onBankCacheRequested, "ConfigManager");
		}
		
		static private function onBankCacheRequested(callback:Function):void {
			callback(_rawConfig.bankCacheMinute);
		}
		
		static private function getConfig():void {
			var currentTS:Number = new Date().getTime();
			if (isNaN(lastTS) == false && currentTS - lastTS < updateDelay)
				return;
			lastTS = currentTS;
			getConfigFromPHP();
		}
		
		static private function getConfigFromPHP():void {
			PHP.call_getConfig(onConfig);
		}
		
		static private function onConfig(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				echo("ConfigManager", "onConfig", "Error: " + phpRespond.errorMsg + "; Callback: " + (_callBack == null));
				TweenMax.delayedCall(60, getConfigFromPHP);
			} else
				echo("ConfigManager", "onConfig", "Callback: " + (_callBack == null));
			if (phpRespond.error == false) {
				_rawConfig.update(phpRespond.data as String);
			}
			setConfig();
			TweenMax.delayedCall(3, onReady, null, true);
		}
		
		static private function onReady():void {
			invokeCallback();
			S_CONFIG_READY.invoke();
		}
		
		static private function setConfig():void {
			if (_rawConfig == null || _rawConfig.data == null)
				return;
			var temp:Array;
			var index:int;
			var i:int;
			
			var loadedConfigData:Object = _rawConfig.data;
			if ("ENABLE_INVESTMENTS" in loadedConfigData && loadedConfigData.ENABLE_INVESTMENTS == "1") {
				Config.ENABLE_INVESTMENTS = true;
			}
			if ("BARABAN" in loadedConfigData &&
				loadedConfigData.BARABAN == 0)
					Config.BARABAN = false;
			if ("START_DUK_AMMOUNT" in loadedConfigData &&	loadedConfigData.START_DUK_AMMOUNT != null)
					Config.START_DUK_AMMOUNT = Number(loadedConfigData.START_DUK_AMMOUNT);
			
			TweenMax.delayedCall(2, updateBankBotControllerConfig, [loadedConfigData]);
			TweenMax.delayedCall(1, updateBankManagerControllerConfig, [loadedConfigData]);
			
			if ("FT_COUNTRIES_AGES" in loadedConfigData == true &&
				loadedConfigData.FT_COUNTRIES_AGES != "") {
					temp = loadedConfigData.FT_COUNTRIES_AGES.split(";");
					for (i = temp.length - 1; i > -1; i--) {
						index = temp[i].search(/\D/gi);
						if (index == -1) {
							temp.splice(i, 1);
							continue;
						}
						temp[i] = { code: int(temp[i].substring(0, index)), age: int(temp[i].substring(index + 1)) };
					}
					Config.FT_COUNTRIES_AGES = temp;
			}
			if ("PASS_PHOTO" in loadedConfigData &&
				loadedConfigData.PASS_PHOTO == 1)
					Config.PASS_PHOTO = true;
			if ("BANKBOT" in loadedConfigData &&
				loadedConfigData.BANKBOT == 1)
					Config.BANKBOT = true;				
			if ("FAST_TRACK" in loadedConfigData &&
				loadedConfigData.FAST_TRACK == 1)
					Config.FAST_TRACK = true;		
			if ("GEO_POSITION" in loadedConfigData &&
				loadedConfigData.GEO_POSITION == 1)
					Config.GEO_POSITION = true;
			if ("LOTTERY" in loadedConfigData &&
				loadedConfigData.LOTTERY == 1)
					Config.LOTTERY = true;
			if ("MAX_OPEN_ACC_AGE" in loadedConfigData && !isNaN(Number(loadedConfigData.MAX_OPEN_ACC_AGE)))
					Config.MAX_OPEN_ACC_AGE = loadedConfigData.MAX_OPEN_ACC_AGE;
			if ("FAST_TRACK_COST" in loadedConfigData && !isNaN(Number(loadedConfigData.FAST_TRACK_COST)))
					Config.FAST_TRACK_COST = loadedConfigData.FAST_TRACK_COST;
			if ("FAST_TRACK_PROPOSAL_DELAY" in loadedConfigData && !isNaN(Number(loadedConfigData.FAST_TRACK_PROPOSAL_DELAY)))
					Config.FAST_TRACK_PROPOSAL_DELAY = loadedConfigData.FAST_TRACK_PROPOSAL_DELAY;
			if ("PAID_CHANNEL" in loadedConfigData &&
				loadedConfigData.PAID_CHANNEL == 1)
					Config.PAID_CHANNEL = true;	
			if ("BOTS" in loadedConfigData &&
				loadedConfigData.BOTS == 1)
					Config.BOTS = true;
			if ("referral" in loadedConfigData &&
				loadedConfigData.referral != null &&
				loadedConfigData.referral.toString() == "0")
					ReferralProgram.disable();
			if ("questionWait" in loadedConfigData &&
				loadedConfigData.questionWait != null)
					QuestionsManager.setFirstQuestionTimeOut(Number(loadedConfigData.questionWait));
			if ("msgsCount" in loadedConfigData &&
				loadedConfigData.msgsCount != null)
					ChatManager.setFirstMsgsCount(Number(loadedConfigData.msgsCount));
			if ("chatsCount" in loadedConfigData &&
				loadedConfigData.chatsCount != null)
					ChatManager.setFirstChatsCount(Number(loadedConfigData.chatsCount));
			if ("refCodes" in loadedConfigData &&
				loadedConfigData.refCodes != null)
					ReferralProgram.setRefCodes(loadedConfigData.refCodes);
			if ("jail" in loadedConfigData == false ||
				loadedConfigData.jail == null ||
				loadedConfigData.jail.toString() != "1")
					PaidBan.hideJail();
			if ("protectionsNum" in loadedConfigData &&
				!isNaN(Number(loadedConfigData.protectionsNum)))
					Config.JAIL_SECTION_PROTECTIONS_NUM = loadedConfigData.protectionsNum;
			if ("userban" in loadedConfigData &&
				loadedConfigData.userban != null &&
				loadedConfigData.userban.toString() == "0")
					PaidBan.disable();
			if ("barabanSettings" in loadedConfigData && loadedConfigData.barabanSettings != null)
				Config.barabanSettings = new BarabanSettings(loadedConfigData.barabanSettings);
			if ("MAX_IDENTIFICATION_QUEUE_ALL" in loadedConfigData)
				Config.MAX_IDENTIFICATION_QUEUE_ALL = loadedConfigData.MAX_IDENTIFICATION_QUEUE_ALL;
			if ("MAX_IDENTIFICATION_QUEUE_SNG" in loadedConfigData)
				Config.MAX_IDENTIFICATION_QUEUE_SNG = loadedConfigData.MAX_IDENTIFICATION_QUEUE_SNG;
			if ("START_URL" in loadedConfigData == true &&
				loadedConfigData.START_URL != "")
					Config.START_URL = loadedConfigData.START_URL;
			if ("MIN_CHAT_OPEN_PAY_RATING" in loadedConfigData == true && loadedConfigData.MIN_CHAT_OPEN_PAY_RATING != "")
				Config.MIN_CHAT_OPEN_PAY_RATING = parseInt(loadedConfigData.MIN_CHAT_OPEN_PAY_RATING);
			if ("MIN_VERSION" in loadedConfigData == true && loadedConfigData.MIN_VERSION != "")
				Config.MIN_VERSION = parseInt(String(loadedConfigData.MIN_VERSION + "").replace(/\D/gi, ""));
			if ("MIN_ANDROID_SDK" in loadedConfigData == true && loadedConfigData.MIN_ANDROID_SDK != "")
				Config.MIN_ANDROID_SDK = parseInt(String(loadedConfigData.MIN_ANDROID_SDK + "").replace(/\D/gi, ""));
			
			if ("open_link_in_browser_mark" in loadedConfigData == true && loadedConfigData.open_link_in_browser_mark != "")
				NativeExtensionController.open_link_in_browser_mark = loadedConfigData.open_link_in_browser_mark;
			
//			GD.S_CONFIG_UPDATED.invoke();
		}
		
		static private function updateBankManagerControllerConfig(loadedConfigData:Object):void 
		{
			if ("CRYPTO_REWARD_ACCOUNT" in loadedConfigData == true &&
				loadedConfigData.CRYPTO_REWARD_ACCOUNT != "")
					BankManager.rewardAccount = loadedConfigData.CRYPTO_REWARD_ACCOUNT;
			if ("URL_CRYPTO" in loadedConfigData == true &&
				loadedConfigData.URL_CRYPTO != "")
					BankManager.blockchainConditionsURL = loadedConfigData.URL_CRYPTO;
			if ("MIN_FIAT" in loadedConfigData == true &&
				isNaN(Number(loadedConfigData.MIN_FIAT)) == false)
					BankManager.fiatMin = loadedConfigData.MIN_FIAT;
			if ("CRYPTO_FIAT_MAX" in loadedConfigData == true &&
				isNaN(Number(loadedConfigData.CRYPTO_FIAT_MAX)) == false)
					BankManager.fiatMax = loadedConfigData.CRYPTO_FIAT_MAX;
			if ("CRYPTO_DEPOSITE_MAX" in loadedConfigData == true &&
				isNaN(Number(loadedConfigData.CRYPTO_DEPOSITE_MAX)) == false)
					BankManager.coinMax = loadedConfigData.CRYPTO_DEPOSITE_MAX;
		}
		
		static private function updateBankBotControllerConfig(loadedConfigData:Object):void 
		{
			var temp:Array;
			var index:int;
			var i:int;
			
			if (Auth.companyID != "08A29C35B3") {
				if ("CRYPTO" in loadedConfigData &&
					loadedConfigData.CRYPTO == 1) {
						delete BankBotController.getScenario().scenario.main.menu[6].disabled;
				} else {
					BankBotController.getScenario().scenario.main.menu[6].disabled = true;
				}
				if ("DUKASCASH" in loadedConfigData &&
					loadedConfigData.DUKASCASH == 1) {
						delete BankBotController.getScenario().scenario.main.menu[7].disabled;
				} else {
					BankBotController.getScenario().scenario.main.menu[7].disabled = true;
				}
			} else {
				delete BankBotController.getScenario().scenario.main.menu[6].disabled;
				delete BankBotController.getScenario().scenario.main.menu[7].disabled;
			}
			if ("CRYPTO_REWARD_IBAN" in loadedConfigData == true &&
				loadedConfigData.CRYPTO_REWARD_IBAN != "")
					BankBotController.rewardIBAN = loadedConfigData.CRYPTO_REWARD_IBAN;
			if ("URL_FAT_CATZ_CONDITION" in loadedConfigData == true &&
				loadedConfigData.URL_FAT_CATZ_CONDITION != "")
					BankBotController.fatCatzURL = loadedConfigData.URL_FAT_CATZ_CONDITION;
			if ("CRYPTO_DEPOSIT_RATIO" in loadedConfigData == true &&
				loadedConfigData.COIN_DEPOSIT_RATIO != "") {
					temp = loadedConfigData.CRYPTO_DEPOSIT_RATIO.split(";");
					for (i = 0; i < temp.length; i++) {
						index = temp[i].indexOf(",");
						if (index == -1)
							temp.splice(i, 1);
						temp[i] = { amount: temp[i].substring(0, index), reward: temp[i].substring(index + 1) };
					}
					BankBotController.rewards = temp;
			}
			if ("CRYPTO_CASH_CONTRACTS" in loadedConfigData == true &&
				loadedConfigData.CRYPTO_CASH_CONTRACTS != "") {
					temp = loadedConfigData.CRYPTO_CASH_CONTRACTS.split(";");
					for (i = 0; i < temp.length; i++) {
						index = temp[i].indexOf(",");
						if (index == -1)
							temp.splice(i, 1);
						temp[i] = { title: temp[i].substring(0, index), address: temp[i].substring(index + 1) };
					}
					BankBotController.cashContracts = temp;
			}
			if ("CRYPTO_FIAT_RATIO" in loadedConfigData == true &&
				loadedConfigData.CRYPTO_FIAT_RATIO != "") {
					BankBotController.rewardFiat = loadedConfigData.CRYPTO_FIAT_RATIO;
			}
		}
		
		static public function invokeCallback():void {
			TweenMax.killDelayedCallsTo(invokeCallback);
			if (_callBack != null)
				_callBack();
			_callBack = null;
		}
		
		static public function cancelLoad():void {
			TweenMax.killDelayedCallsTo(invokeCallback);
			_callBack = null;
		}
		
		static public function get rawConfig():Object {
			if (_rawConfig == null)
				return null;
			return _rawConfig.data;
		}
		
		static public function get config():ServerConfigVO {
			if (_rawConfig == null)
				return null;
			return _rawConfig;
		}
	}
}