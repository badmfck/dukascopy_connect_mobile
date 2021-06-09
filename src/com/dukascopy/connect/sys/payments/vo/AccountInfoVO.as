package com.dukascopy.connect.sys.payments.vo {
	
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.auth.Auth;

	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */

	public class AccountInfoVO {
		
		// Used
		private var _customerNumber:int;
		private var _firstName:String;
		private var _lastName:String;
		private var _phone:String;
		private var _email:String;
		private var _country:String;
		private var _address:String;
		private var _zip:String;
		private var _city:String;
		private var _limits:Array/*AccountLimitVO*/;
		private var _accounts:Array;
		private var _accountsAll:Array;
		private var _settings:SettingPWP;
		private var _disablePrepaidCards:Boolean;
		private var _yourCardWithdrawal:Boolean = true;
		
		private var _investmentReferenceCurrency:String;
		private var _consolidateCurrency:String = "EUR";
		private var _enableInvestments:Boolean;
		private var _coins:Array;
		private var _deliveryExpedited:Boolean = false;
		private var _enableSaving:Boolean = false;
		private var _enableTrading:Boolean = false;
		private var _enableApplePay:Boolean = false;
		private var _updatePersonalInfo:Boolean = false;
		private var _limitsIncreaseRequest:Boolean = false;
		
		private var _virtualMC:Boolean = false;
		private var _plasticMC:Boolean = false;
		
		private var _ethAddress:String;
		private var _btcAddress:String;
		public var updateTime:Number;
		// Unused
		//private var _nationality:String;
		//private var _title:String;
		//private var _birthDate:String;
		//private var _birthPlace:String;
		//private var _pointers:Array/*AccountPointerVO*/;
		//private var _links:Array;
		//private var _ppCardsCurrency:Array/*String*/;
		//private var _ppCardDeposit:Boolean;
		//private var _readOnly:Boolean;
		//private var _isMerchant:Boolean;
		//private var _enableSkrill:Boolean;
		//private var _enableNeteller:Boolean;
		//private var _disablePlasticPPCardOrder:Boolean;
		//private var _directBranchTransfers:Boolean;
		//private var _dinpayDepositTypes:Boolean;
		//private var _dinpayDeposit:Boolean;
		//private var _ccWithdrawal:Boolean;
		
		static private var wasSend:Boolean=false;
		private var _address_card:String;
		private var _city_card:String;
		private var _country_card:String;
		private var _zip_card:String;
		
		public function AccountInfoVO() {
			// BAD PRACTICE! (sorry)
			if(!wasSend){
				wasSend=true;
				PHP.call_statVI("pacces", Auth.devID);
			}
		 }
		
		public function update(data:Object):void {
			if (data == null)
				return;
			var key:String;
			key = "CUSTOMER_NUMBER";
			if (key in data == true)
				_customerNumber = data[key];
			key = "FIRST_NAME";
			if (key in data == true)
				_firstName = data[key];
			key = "LAST_NAME";
			if (key in data == true)
				_lastName = data[key];
			key = "PHONE";
			if (key in data == true)
				_phone = data[key];
			key = "EMAIL";
			if (key in data == true)
				_email = data[key];
			//---------------------------
			key = "CARD_DELIVERY_COUNTRY";
			if (key in data == true)
				_country_card = data[key];
			key = "CARD_DELIVERY_ADDRESS";
			if (key in data == true)
				_address_card = data[key];
			key = "CARD_DELIVERY_ZIP";
			if (key in data == true)
				_zip_card = data[key];
			key = "CARD_DELIVERY_CITY";
			if (key in data == true)
				_city_card = data[key];
			//---------------------------
			key = "COUNTRY";
			if (key in data == true)
				_country = data[key];
			key = "ADDRESS";
			if (key in data == true)
				_address = data[key] || "";
			key = "ZIP";
			if (key in data == true)
				_zip = data[key];
			key = "CITY";
			if (key in data == true)
				_city = data[key];
			
			
			key = "limits";
			if (key in data == true)
				setLimits(data[key]);
			key = "accounts";
			if (key in data == true) {
				_accountsAll = null;
				_accounts = data[key];
			}
			key = "settings";
			if (key in data == true)
				updateSettings(data[key]);
			key = "disable_prepaid_cards";
			if (key in data == true)
				_disablePrepaidCards = data[key];
			key = "enable-investments";
			if (key in data == true)
				_enableInvestments = data[key];
			key = "ETH_ADDRESS";
			if (key in data == true)
				_ethAddress = data[key];
			key = "BTC_ADDRESS";
			if (key in data == true)
				_btcAddress = data[key];
			key = "enable-corner-virtual-mc";
			if (key in data == true)
				_virtualMC = data[key];
			key = "enable-corner-plastic-mc";
			if (key in data == true)
				_plasticMC = data[key];
			key = "enable-corner-expedited";
			if (key in data == true)
				_deliveryExpedited = data[key];
			key = "enable-savings";
			if (key in data == true)
				_enableSaving = data[key];
			key = "enable-fiat-trading";
			if (key in data == true)
				_enableTrading = data[key];
			key = "enable-apple-pay";
			if (key in data == true)
				_enableApplePay = data[key];
			key = "update-personal-info";
			if (key in data == true)
				_updatePersonalInfo = data[key];
			key = "limits_increase_request";
			if (key in data == true)
				_limitsIncreaseRequest = data[key];
			
			updateTime = new Date().getTime();
		}
		
		private function setLimits(data:Array):void {
			if (data == null || data.length == 0)
				return;
			clearLimits();
			var l:int = data.length;
			for (var i:int = 0; i < l; i++)
				_limits.push(new AccountLimitVO(data[i]));
		}
		
		private function clearLimits():void {
			_limits ||= [];
			if (_limits.length == 0)
				return;
			while (_limits.length != 0)
				_limits.shift().dispose();
		}
		
		public function updateSettings(settingsObj:Object):void {
			_settings ||= new SettingPWP(null);
			_settings.update(settingsObj);
			if ("INVESTMENT_REFERENCE_CURRENCY" in settingsObj)
				_investmentReferenceCurrency = settingsObj["INVESTMENT_REFERENCE_CURRENCY"];
			if ("CONSOLIDATE_CURRENCY" in settingsObj)
				_consolidateCurrency = settingsObj["CONSOLIDATE_CURRENCY"];
		}
		
		public function setCoins(val:Array):void {
			_accountsAll = null;
			_coins = val;
		}
		
		public function get customerNumber():int { return _customerNumber; }
		public function get firstName():String { return _firstName; }
		public function get lastName():String { return _lastName; }
		public function get phone():String { return _phone; }
		public function get email():String { return _email; }
		public function get country():String { return _country; }
		public function get address():String { return _address; }
		public function get zip():String { return _zip; }
		public function get city():String { return _city; }
		public function get settings():SettingPWP { return _settings; }
		public function get yourCardWithdrawal():Boolean { return _yourCardWithdrawal; }
		public function get disablePrepaidCards():Boolean { return _disablePrepaidCards; }
		public function get investmentReferenceCurrency():String { return _investmentReferenceCurrency; }
		public function get consolidateCurrency():String { return _consolidateCurrency; }
		public function get enableInvestments():Boolean {	return _enableInvestments; }
		public function get coins():Array { return _coins; }
		public function get ethAddress():String { return _ethAddress; }
		public function get btcAddress():String { return _btcAddress; }
		
		public function get accounts():Array {
			_accounts ||= [];
			return _accounts;
		}
		
		public function get accountsAll():Array {
			if (_accountsAll != null)
				return _accountsAll;
			if (_coins != null && _accounts != null)
				_accountsAll = _coins.concat(_accounts);
			else if (_coins != null)
				_accountsAll = _coins.concat();
			else if (_accounts != null)
				_accountsAll = _accounts.concat();
			_accountsAll ||= [];
			return _accountsAll;
		}
		
		public function get limits():Array/*AccountLimitVO*/ {
			_limits ||= [];
			return _limits;
		}
		
		public function get virtualMC():Boolean { return _virtualMC; }
		public function get plasticMC():Boolean { return _plasticMC; }
		public function get deliveryExpedited():Boolean { return _deliveryExpedited; }
		public function get enableSaving():Boolean { return _enableSaving; }
		public function get enableTrading():Boolean { return _enableTrading; }
		public function get enableApplePay():Boolean { return _enableApplePay; }
		
		public function get address_card():String 
		{
			return _address_card;
		}
		
		public function get city_card():String 
		{
			return _city_card;
		}
		
		public function get country_card():String 
		{
			return _country_card;
		}
		
		public function get zip_card():String 
		{
			return _zip_card;
		}
		
		public function get updatePersonalInfo():Boolean { return _updatePersonalInfo; }
		public function get limitsIncreaseRequest():Boolean { return _limitsIncreaseRequest; }
	}
}