package com.dukascopy.connect.sys.payments {
	
	import com.dukascopy.connect.data.CardDeliveryAddress;
	import com.dukascopy.connect.data.CheckDuplicateTransfer;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.net.URLRequestMethod;
	
	/**
	 * Absolutely all requests should have the following "api level" parameters:
		_api_client_id	Unique API Client ID of your application provided by system administrators
		_api_timestamp	unix timestamp of the request. Server may implement check of timestamp difference (for instance 300 seconds)
		_api_nonce	some unique ID for all requests (for instance, md5(microtime().mt_rand()) - server may implement check and refuse requests with the same nonce
		_api_signature	request signature, detailed description below
	 *
	 * @author Alexey
	 */
	
	public class PayServer {
		
		static public function call_getServerTime(_callback:Function, _callID:String = "", callbackFunction:Function = null, callbackFunction1:Function = null):void {
			var php:PayLoader = call("", _callback, null, URLRequestMethod.GET, PayConfig.PAY_API_URL + "time.php");
			if (php.savedRequestData != null) {
				php.savedRequestData.callbackFunction = callbackFunction;
				php.savedRequestData.callbackFunction1 = callbackFunction1;
				php.savedRequestData.callID = _callID;
			}
		}
		
		/**
		 * This method returns various system wise options. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681821
		 */
		static public function call_getSystemOptions(_callback:Function):void {
			call("system/options", _callback, null, URLRequestMethod.GET);
		}
		
		/**
		 * This method creates a new session for existing account. See description (Login with Telefision Token):
		 * https://intranet.dukascopy.dom/wiki/display/webdev/POST+login
		 */
		static public function call_loginWithToken(_callback:Function, _tfToken:String, pass:String, callbackFunction:Function = null):void {
			var php:PayLoader = call("auth/tf", _callback, { token:_tfToken, password:pass } );
			if (php.savedRequestData != null)
				php.savedRequestData.callbackFunction = callbackFunction;
		}
		
		/**
		 * This method unlock session. See description:
		 * https://intranet.dukascopy.dom/wiki/display/webdev/POST+session
		 */
		static public function call_passCheck(_callback:Function, pass:String, _callID:String = ""):void {
			var php:PayLoader = call("session", _callback, { password:pass } );
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method changes current password. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=76153208
		 */
		static public function call_passChange(_callback:Function, currentPass:String, newPass:String, _callID:String = ""):void {
			var php:PayLoader = call("account/password", _callback, { current:currentPass, 'new':newPass } );
			if (php.savedRequestData != null)
			{
				php.savedRequestData.pass = newPass;
				php.savedRequestData.callID = _callID;
			}
		}
		
		/**
		 * This method resets the user's password via two step verification. See description:
		 * https://intranet.dukascopy.dom/wiki/display/webdev/POST+forgot
		 */
		static public function call_postForgot(_callback:Function, _data:Object = null, _callID:String = ""):void {
			var php:PayLoader = call("forgot", _callback, _data);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method locks existing session on password. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=105283604
		 */
		static public function call_lock(_callback:Function):void {
			call("session/lock", _callback);
		}
		
		/**
		 * This method returns information about customer's account. See description:
		 * https://intranet.dukascopy.dom/wiki/display/webdev/GET+account
		 */
		static public function call_getAccount(_callback:Function):void {
			call("account", _callback, null, URLRequestMethod.GET);
		}
		
		/**
		 * This method returns list of "coin" accounts. See description:
		 * https://intranet.dukascopy.dom/wiki/display/webdev/GET+coin
		 */
		static public function call_getCrypto(_callback:Function):void {
			call("coin", _callback, { with_blockchain: 1 }, URLRequestMethod.GET);
		}
		
		/**
		 * This request is used to get list of account's term deposits. See description:
		 * https://intranet.dukascopy.dom/wiki/display/webdev/GET+term-deposit
		 */
		static public function call_getCryptoRDs(_callback:Function):void {
			call("term-deposit", _callback, null, URLRequestMethod.GET);
		}
		
		/**
		 * Endpoint returns url of "iframe" where client can declare his ETH wallet's address. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=121995298
		 */
		static public function call_getDeclareEthAddressLink(_callback:Function, type:String):void {
			if (type == "DCO")
				type = "ETH";
			if (type == "UST")
				type = "ETH";
			call("coin/declare-wallet", _callback, { type:type } );
		}
		
		/**
		 * Simple balance values collection of accounts groups. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100305249
		 */
		static public function call_getAIC(_callback:Function):void {
			call("account/aic", _callback, null, URLRequestMethod.GET);
		}
		
		/**
		 * All account data. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=92340243
		 */
		static public function call_getHome(_callback:Function, withCards:Boolean):void {
			var data:Object = {
				with_other: 1,
				with_savings: 1
			};
			if (withCards == true)
				data.with_cards = true;
			var pl:PayLoader = call("account/home", _callback, data, URLRequestMethod.GET);
		}
		
		/**
		 * This method changes settings of the account. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=88506393
		 */
		static public function call_postAccountSettings(_callback:Function, pwp_enabled:int = -1 , pwp_limit_amount:int = -1, pwp_limit_daily:int = -1, _callID:String = ""):void {
			var data:Object = new Object();
			if (pwp_enabled != -1 && (pwp_enabled == 0 || pwp_enabled == 1))
				data.PWP_ENABLED = pwp_enabled;
			if (pwp_limit_amount != -1)
				data.PWP_LIMIT_AMOUNT = pwp_limit_amount ;
			if (pwp_limit_daily != -1)
				data.PWP_LIMIT_DAILY = pwp_limit_daily;
			var php:PayLoader =  call("account/settings", _callback, data);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method changes settings of the account. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=88506393
		 */
		static public function call_postSettings(_callback:Function, data:Object, _callID:String):void {
			var php:PayLoader =  call("account/settings", _callback, data);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns simple account statement information. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681936
		 */
		static public function call_getMoneyHistory(
			_callback:Function,
			_page:int,
			_itemsPerPage:int,
			_status:String,
			_type:String,
			_dateFrom:String,
			_dateTo:String,
			_destination:String,
			_callID:String = "",
			_appCallback:Function = null,
			_wallet:String = "",
			userAcc:String = "",
			operationType:String = ""):void {
				var data:Object = {
					page:_page,
					status:_status,
					type:_type,
					page_size:_itemsPerPage,
					date_from:_dateFrom,
					date_to:_dateTo,
					destination:_destination,
					wallet:_wallet,
					sender_or_receiver:userAcc,
					operation_type:operationType,
					group_coin_trades:(operationType != "") ? "" : 1
				}
				var php:PayLoader = call("money/history", _callback, data, URLRequestMethod.GET);
				if (php.savedRequestData != null) {
					php.savedRequestData.callID = _callID;
					php.savedRequestData.appCallback = _appCallback;
					php.savedRequestData.accountNumber = _wallet;
				}
		}
		
		/**
		 * This GET method returns details of particular operation identified by UID. For example. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681948
		 * 
		 * This POST method attempts to complete pending incoming transfer operation identified by UID. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681981
		 */
		static public function call_getMoneySpecific(_callback:Function, _operationUID:String, _code:String = "", hash:String = null):void {
			var php:PayLoader;
			if (_code == "")
				php = call("money/history/" + _operationUID, _callback, null, URLRequestMethod.GET);
			else
				php = call("money/history/" + _operationUID, _callback, { code:_code } );
			if (php != null && php.savedRequestData != null) {
				if (hash == null)
					php.savedRequestData.callID = _operationUID;
				else
					php.savedRequestData.callID = hash;
			}
		}
		
		/**
		 * Getting information about various cards belonging to the current user. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=73236505
		 */		
		static public function call_getAccountCards(_callback:Function):void {
			call("account/cards", _callback, null, URLRequestMethod.GET);
		}
		
		/**
		 * This endpoint is for ordering new prepaid cards, both plastic and virtual. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=78349385
		 */		
		static public function call_putAccountCards(_callback:Function, _from:Number, _type:String , _currency:String, _cardType:String, _delivery:String, _callID:String = "", deliveryAddress:CardDeliveryAddress = null):void {
			var data:Object = {
				from:_from,
				type:_type,
				currency:_currency,
				shipment_type:_delivery,
				async:1
			}
			if (deliveryAddress != null)
			{
				data.update_address = true;
				data.street = deliveryAddress.address;
				data.city = deliveryAddress.city;
				data.country = deliveryAddress.country;
				data.postal_code = deliveryAddress.code;
				data.reason = deliveryAddress.reason;
				
				if (deliveryAddress.nameChanged)
				{
					data.update_full_name = true;
					data.delivery_full_name = deliveryAddress.name;
				}
			}
			if (_cardType != null)
				data.psystem = _cardType;
			var php:PayLoader = call("account/cards", _callback, data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Method to create Personal info update request.. See description:
		 * https://intranet.site.dukascopy.com/wiki/pages/viewpage.action?pageId=134775995
		 */		
		static public function call_accountUpdate(_callback:Function, userData:Object, _callID:String = ""):void {
			var php:PayLoader = call("account/update", _callback, userData);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Method to limits increase request.. See description:
		 * https://intranet.site.dukascopy.com/wiki/pages/viewpage.action?pageId=134775911
		 */		
		static public function call_limitsIncrease(_callback:Function, limits:Object, _callID:String = ""):void {
			var php:PayLoader = call("account/limits/increase", _callback, limits, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method performs different actions on particular prepaid card listed by GET account∕cards. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=76709915
		 */
		static public function call_actionCard(_callback:Function , _cardDiggits:String, data:Object, _callID:String = ""):void {
			var php:PayLoader = call("account/cards/" + _cardDiggits, _callback, data);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Method to create a new coin deal. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100893417
		 */
		static public function call_cryptoOfferCreate(_callback:Function, data:Object, _callID:String = ""):void {
			var php:PayLoader = call("coin/deal", _callback, data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Returns all coin information for current user. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100893379
		 */
		static public function call_cryptoDeals(_callback:Function):void {
			var php:PayLoader = call("coin/deal", _callback, { periods:"all" }, URLRequestMethod.GET);
		}
		
		/**
		 * Activates existing deal owned by current user. See description:
		 * 
		 */
		static public function call_cryptoOfferActivate(_callback:Function, id:String, _callID:String = ""):void {
			var php:PayLoader = call("coin/deal/" + id + "/activate", _callback);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Deactivates existing deal owned by current user. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100893479
		 */
		static public function call_cryptoOfferDeactivate(_callback:Function, id:String, _callID:String = ""):void {
			var php:PayLoader = call("coin/deal/" + id + "/deactivate", _callback);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Main method for coin deal trade execution. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100893499
		 */
		static public function call_cryptoTrade(_callback:Function, id:String, side:String, quantity:Number, price:Number, _callID:String = ""):void {
			var data:Object = {
				side:side,
				quantity:quantity,
				price:price
			}
			var php:PayLoader = call("coin/deal/" + id + "/trade", _callback, data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Removes existing deal owned by current user. See description:
		 * 
		 */
		static public function call_cryptoOfferDelete(_callback:Function, id:String, _callID:String = ""):void {
			var php:PayLoader = call("coin/deal/" + id + "/delete", _callback);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Request to witdraw crypto assets to external blockchain wallet. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=106397709
		 */
		static public function call_cryptoWithdrawal(_callback:Function, address:String, amount:Number, coin:String, _callID:String = ""):void {
			var data:Object = {
				address: address,
				amount: amount,
				coin: coin
			}
			var php:PayLoader = call("coin/withdrawal", _callback, data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Method is used to start delivery of investment asset. See description:
		 * https://intranet.site.dukascopy.com/wiki/pages/viewpage.action?pageId=134448186
		 */
		static public function call_investmentDelivery(_callback:Function, address:String, amount:Number, coin:String, feeAcc:String, _callID:String = ""):void {
			var data:Object = {
				address: address,
				amount: amount,
				instrument: coin,
				fee_account: feeAcc
			}
			var php:PayLoader = call("account/investment/delivery", _callback, data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This request is used to get address for dukascoin deposit. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=106397714
		 */
		static public function call_cryptoDepositAddress(_callback:Function, address:String, amount:Number, coin:String, _callID:String = ""):void {
			var data:Object = {
				address: address,
				amount: amount,
				coin: coin
			}
			var php:PayLoader = call("coin/deposit/address", _callback, data, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This request is used to get address for dukascoin deposit. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=135430487
		 */
		static public function call_cryptoDepositAddressInvestment(_callback:Function, address:String, amount:Number, coin:String, _callID:String = ""):void {
			var data:Object = {
				address: address,
				amount: amount,
				instrument: coin
			}
			var php:PayLoader = call("account/investment/deposit/address", _callback, data, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method performs block action on particular prepaid card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=76709915
		 */
		static public function call_blockCard(_callback:Function, _cardDiggits:String, _callID:String = ""):void {
			var php:PayLoader = call("account/cards/" + _cardDiggits, _callback, { action:"block" } );
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method performs unblock action on particular prepaid card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=76709915
		 */
		static public function call_unblockCard(_callback:Function, _cardDiggits:String, _callID:String = ""):void {
			var php:PayLoader = call("account/cards/" + _cardDiggits, _callback, { action:"unblock" } );
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method performs activate action on particular prepaid card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=76709915
		 */
		static public function call_activateCard(_callback:Function, _cardDiggits:String,code:String, _callID:String = ""):void {
			var php:PayLoader = call("account/cards/" + _cardDiggits, _callback, { action:"activate", verification_value:code } );
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method performs sendPIN action on particular prepaid card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=76709915
		 */
		static public function call_sendPinForCard(_callback:Function, _cardDiggits:String, channel:String = "", _callID:String = ""):void {
			var php:PayLoader = call("account/cards/" + _cardDiggits, _callback, { action:"sendPIN", channnel:channel } );
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns commission calculated for ordering new prepaid card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=78349329
		 */
		static public function call_getCardCommission(_callback:Function , _type:String, _currency:String, _debitCurrency:String = null, _cardType:String = null, _delivery:String = "STANDARD", _callID:String = null):void {
			var data:Object = {
				type: _type,
				currency: _currency
			}
			if (_type == "PLASTIC")
				data.shipment_type = _delivery;
			if (_cardType != null)
				data.psystem = _cardType;
			if (_debitCurrency != null)
				data.debit_currency = _debitCurrency;
			var php:PayLoader = call("account/cards/commission" , _callback, data, URLRequestMethod.GET);
			if (php.savedRequestData != null && _callID != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method initiates deposit process by different means. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681992
		 * 
		 * This method initiates deposit from Third Party linked card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=128090118
		 */
		static public function call_putMoneyMyCardDeposit(_callback:Function, _amount:Number,  _currency:String, _type:String, _card_uid:String, _sentByEmail:Boolean, _callID:String ="", cvv:String = null):void {
			var data:Object = {
				amount: _amount,
				currency: _currency,
				type: _type,
				card_uid:_card_uid,
				email: _sentByEmail
			}
			if (cvv != null) {
				data.cvv = cvv;
				data.closable = 0;
			}
			var php:PayLoader = call("money/deposit" + ((cvv != null) ? "/linked-card" : ""), _callback, data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method initiates deposit process by different means. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681992
		 */
		static public function call_putDeposit(_callback:Function, _data:Object, _callID:String = ""):void {
			var php:PayLoader = call("money/deposit", _callback, _data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method initiates deposit process by different means. See description:
		 * https://intranet.site.dukascopy.com/wiki/pages/viewpage.action?pageId=134775786
		 */
		static public function call_putDepositApplePay(_callback:Function, _callID:String = ""):void {
			var php:PayLoader = call("money/deposit/apple-pay", _callback, null, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method is used to perform third party deposits. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100305381
		 */
		static public function call_putDepositThirdParty(_callback:Function, _data:Object, _callID:String = ""):void {
			_data.referer = "https://www.dukascopy.bank";
			var php:PayLoader = call("money/deposit-third-party", _callback, _data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method initiates withdrawal process by different means. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70682033
		 * 
		 * This method generates link to PGateway Bank withdrawal form. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=132317192
		 * 
		 * This method initiates withdrawal process to linked card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=135430220
		 */
		static public function call_putMoneyWithdrawal(_callback:Function, _from:Number, _type:String, _amount:Number, _currency:String, _card:String, _swift:String, _callID:String= ""):void {
			var requestObject:Object ;
			if (_card != null)
				requestObject = { from:_from, amount:_amount, currency:_currency, card:_card};				
			else
				requestObject =  { from:_from, amount:_amount, currency:_currency};
			var action:String = "money/withdrawal";
			if (_type == "WIRE") {
				action = "money/withdrawal/bank-transfer";
				requestObject.swift = _swift;
			} else if (_type == "CARD") {
					action = "money/withdrawal/linked-card";
			} else {
				requestObject.type = _type;
				if (_type == "PPCARD") {
					requestObject.async = true;
				}
			}
			var php:PayLoader = call(action, _callback,  requestObject, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method initiates withdrawal process by different means. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70682033
		 * 
		 * This method generates link to PGateway Bank withdrawal form. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=132317192
		 */
		static public function call_putMoneyWithdrawalOther(_callback:Function, _from:String, _currency:String, _type:String, _callID:String = ""):void {
			var php:PayLoader;
			var requestObject:Object ;
			requestObject =  { from:_from, currency:_currency };
			var action:String = "money/withdrawal";
			if (_type == "WIRE") {
				action = "money/withdrawal/bank-transfer";
			} else {
				requestObject.type = _type;
				if (_type == "PPCARD") {
					requestObject.async = true;
				}
			}
			php = call(action, _callback,  requestObject, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Will be returned commission value which will be applied to deposit transaction. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=84050017
		 */
		static public function call_getMoneyDepositCommission(_callback:Function, _amount:Number, _currency:String, _type:String, _callID:String = ""):void {
			var php:PayLoader = call("money/deposit/commission", _callback, { amount:_amount, currency:_currency, type:_type }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Will be returned commission value which will be applied to deposit transaction. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=84050017
		 */
		static public function call_getMoneyDepositCommissionLinked(_callback:Function, _amount:Number, _currency:String, _card:String, _callID:String = ""):void {
			var php:PayLoader = call("money/deposit/commission/linked-card", _callback, { amount:_amount, currency:_currency, card:_card }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns commission calculated for money withdrawals. It is similar to GET money∕send∕commission. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70682132
		 */
		static public function call_getMoneyWithdrawalCommission(_callback:Function, _amount:Number, _currency:String, _type:String, _swift:String, _callID:String = "", debitCurrrency:String = null):void {
			var requestObject:Object;
			var method:String = "money/withdrawal/commission";
			
			if (_type == "WIRE") {
				requestObject = { amount:_amount, currency:_currency, type:_type, swift:_swift };
			} else if (_type == "CARD") {
				method = "money/withdrawal/commission/linked-card";
				requestObject = { amount:_amount, currency:_currency, card:_swift };
			} else {
				requestObject = { amount:_amount, currency:_currency, type:_type };
			}
			
			if (debitCurrrency != null) {
				requestObject.debit_currency = debitCurrrency;
			}
			var php:PayLoader = call(method, _callback, requestObject , URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method transfers money between "other" accounts of the client, returned by GET account∕home request. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681550
		 */
		static public function call_putMoneyTransfer(_callback:Function, _fromAccount:String, _toAccount:String, _amount:Number, _currency:String, _callID:String = ""):void {
			var php:PayLoader = call("money/transfer", _callback, { from:_fromAccount, to:_toAccount, amount:_amount, currency:_currency }, URLRequestMethod.PUT);
			php.timeoutErrorText = Lang.moneyTransferTimeoutError;
			php.timeoutErrorCode = PayLoader.ERROR_SERVER_NOT_RESPOND;
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns current exchange rate for any operation. Rate is not guaranteed and is provided for informational purposes only. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=75497500
		 */
		static public function call_getMoneyTransferRate(_callback:Function, _fromCurrency:String, _toCurrency:String, _amount:Number, _currency:String, _callID:String = ""):void {
			var php:PayLoader = call("money/transfer/rate", _callback, { from:_fromCurrency, to:_toCurrency, amount:_amount, currency:_currency }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		static public function callGetInstrumentRatesHistory(_callback:Function, _instrument:String, callback:Function):void {
			var php:PayLoader = call("account/investment/chart", _callback, { instrument:_instrument }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
			{
				php.savedRequestData.callback = callback;
			}
		}
		
		/**
		 * This method is used to send money between users of Dukascopy Payments. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681770
		 */
		static public function call_putMoneySendAdvanced(_callback:Function, data:Object, _callID:String = ""):void {
			
			if (CheckDuplicateTransfer.addTransfer(data) == false)
			{
				echo("money.call_putMoneySendAdvanced", "CheckDuplicateTransfer");
				if (_callback != null)
				{
					var respond:PayRespond = new PayRespond(null);
					respond.setData(true, Lang.pleaseTryLater);
					
					var _savedRequestData:Object = { };
					_savedRequestData.url = PayConfig.PAY_API_URL + "money/send";
					_savedRequestData.data = data;
					_savedRequestData.method = "money/send";
					_savedRequestData.callBack = _callback;
					_savedRequestData.callID = _callID;
					respond.setSavedRequestData(_savedRequestData);
					
					_callback(respond);
					
				}
				return;
			}
			
			var php:PayLoader = call("money/send", _callback, data, URLRequestMethod.PUT);
	        if (php.savedRequestData != null)
	            php.savedRequestData.callID = _callID;
			PayStatManager.sendStat(data);
		}
		
		/**
		 * This request is used to create term deposit. See description:
		 * https://intranet.dukascopy.dom/wiki/display/webdev/PUT+term-deposit
		 */
		static public function call_putRDeposit(_callback:Function, data:Object, _callID:String = ""):void {
			var php:PayLoader = call("term-deposit", _callback, data, URLRequestMethod.PUT);
	        if (php.savedRequestData != null)
	            php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method is used to send money from one user of Dukascopy Payments (customer) to another (merchant). See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=99057937
		 */
		static public function call_putMoneyMerchant(_callback:Function, data:Object, _callID:String = ""):void {
			var php:PayLoader = call("money/merchant", _callback, data, URLRequestMethod.PUT);
	        if (php.savedRequestData != null)
	            php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns commission calculated for sending money. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681926
		 */
		static public function call_getMoneySendCommision(_callback:Function, _amount:Number, _currency:String, _callID:String = ""):void {
			var php:PayLoader = call("money/send/commission", _callback, { amount:_amount, currency:_currency, debit_currency:"EUR" }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns commission for coin operations on marketplace. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=127238145
		 */
		static public function call_getCoinSellCommision(_callback:Function, _amount:Number, price:Number, _callID:String = ""):void {
			var php:PayLoader = call("coin/commission", _callback, { amount:_amount, price:price, coin:"DCO", side:"SELL" }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		static public function call_getCoinSellBulkCommision(_callback:Function, request:Object, _callID:String = ""):void {
			var php:PayLoader = call("coin/commission/bulk", _callback, request, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns commission for coin deposit. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=133169157
		 */
		static public function call_getCoinBCDCommision(_callback:Function, _amount:Number, _callID:String = ""):void {
			var php:PayLoader = call("coin/deposit/commission", _callback, { amount:_amount, coin:"DCO" }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		static public function call_getInvestmentBlockchainCommision(_callback:Function, _amount:Number, instrument:String, _callID:String = ""):void {
			var php:PayLoader = call("account/investment/delivery/fee", _callback, { amount:_amount, instrument:instrument }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method attempts to complete pending incoming transfer operation identified by UID. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681981
		 */
		static public function call_postMoneyHistory(_callback:Function, _operationUID:String):void {
			call("money/history/" + _operationUID, _callback);
		}
		
		/**
		 * This method creates empty "wallet" account of the client. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681907
		 */
		static public function call_putAccountWallet(_callback:Function, _currency:String, _description:String, _callID:String =""):void {
			var php:PayLoader = call("account/wallet", _callback, { currency:_currency, description:_description }, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method creates empty "savings" account of the client, maximum of 1 per currency. See description:
		 * https://intranet.site.dukascopy.com/wiki/pages/viewpage.action?pageId=134448017
		 */
		static public function call_putSavingWallet(_callback:Function, _currency:String, _callID:String =""):void {
			var php:PayLoader = call("account/savings", _callback, { currency:_currency }, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method updates "wallet" account of the client. Currently only description can be updated. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70682384
		 */
		static public function call_postAccountWallet(_callback:Function, _account:String, _description:String, _callID:String = ""):void {
			var php:PayLoader = call("account/wallet", _callback, { account:_account, description:_description } );
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method transfers money between "wallet" accounts of the client. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100303684
		 */
		static public function call_internalTransfer(_callback:Function, data:Object, _callID:String = ""):void {
			var php:PayLoader = call("money/exchange", _callback, data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
	            php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method verifies the card for withdrawals which was previously added by PUT money∕cards. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=83034353
		 */
		static public function call_postMoneyCards(_callback:Function, _callID:String = "", obj:Object = null):void {
			var php:PayLoader = call("money/cards", _callback, obj);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns the list of "linked cards" added by client for withdrawals to card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=83034347
		 */
		static public function call_getMoneyCards(_callback:Function, _callID:String = ""):void {
			var php:PayLoader = call("money/cards", _callback, null, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method initiates adding of the card for withdrawals to card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=83034351
		 */
		static public function call_putMoneyCards(_callback:Function, _callID:String = ""):void {
			var php:PayLoader = call("money/cards", _callback, null, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method removes the card which was previously added by PUT money∕cards. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=83034508
		 */
		static public function call_deleteMoneyCards(_callback:Function, _callID:String = "", uid:String = ""):void {
			var php:PayLoader = call("money/cards", _callback, { card_uid:uid }, URLRequestMethod.DELETE);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Getting information about various cards belonging to the current user. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=73236505
		 */
		static public function call_getCards(_callback:Function, with_extra:Boolean = true, _callID:String = ""):void {
			var php:PayLoader = call("account/cards", _callback, { with_extra: true }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns list of transactions (statement) of particular prepaid card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=73236528
		 */
		static public function call_getCardInfo(_callback:Function, _cardNumber:String, data:Object = null, _callID:String = ""):void {
			if (_cardNumber == "")
				return;				
			var php:PayLoader = call("account/cards/" + _cardNumber, _callback, data, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method returns list of transactions (statement) of particular prepaid card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=73236528
		 */
		static public function cardStatement(cardNumber:String, from:String, to:String, timezone:String = null):void {
			if (cardNumber == "")
				return;
			var request:Object = new Object();
			request.from = from;
			request.to = to;
			request.load = "summary";
			request.asfile = "pdf";
			if (timezone != null) {
				request.timezone = timezone;
			}
			call("account/cards/" + cardNumber, null, request, URLRequestMethod.GET, null, true);
		}
		
		/**
		 * This method generates PDF document for chosen operation (which should have PENDING or COMPLETED status). See description:
		 * https://jira.site.dukascopy.com/wiki/display/webdev/GetOperationPDF
		 */
		static public function operationStatement(uid:String):void {
			if (uid == "")
				return;
			call("money/history/pdf", null, { uid:uid }, URLRequestMethod.GET, null, true);
		}
		
		/**
		 * This method returns list of transactions (statement) of particular prepaid card. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=70681606
		 */
		static public function walletStatement(accountNumber:String, from:String, to:String, timezone:String = null):void {
			if (accountNumber == "")
				return;
			var request:Object = new Object();
			request.date_from = from;
			request.date_to = to;
			request.asfile = "pdf";
			request.extended = true;
			request.account = accountNumber;
			if (timezone != null) {
				request.timezone = timezone;
			}
			call("account/statement", null, { date_from:from, date_to:to, asfile:"pdf", extended:true, account:accountNumber, timezone:timezone }, URLRequestMethod.GET, null, true);
		}
		
		/**
		 *  See description:
		 * 
		 */
		static public function call_removeTrial(_callback:Function, answersData:Object):void {
			call("account/kyc", _callback, answersData, URLRequestMethod.PUT);
		}
		
		/**
		 * This method returns list of news items. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=78086155
		 */
		static public function call_getNews(_callback:Function, lang:String = "en", _callID:String=""):void {
			var php:PayLoader = call("account/news", _callback, { l:lang }, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This method marks one of the news item received by GET account∕news as read by current account. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=78086152
		 */
		static public function call_postNews(_callback:Function, id:String):void {
			call("account/news/" + id, _callback);
		}
		
		/**
		 * Simple method without input parameters, returns list of investment accounts as an array of objects. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=99713153
		 */
		static public function call_getInvestment(_callback:Function,_callID:String =""):void {
			var php:PayLoader = call("account/investment", _callback, null, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Method is used to calculate rate of BUY or SELL investment trade. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=99713160
		 */
		static public function call_getInvestmentRate(_callback:Function, _data:Object = null, _callID:String = ""):void {
			var php:PayLoader = call("account/investment/rate", _callback, _data, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This request returns Fat Catz information. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=119406594
		 */
		static public function call_getFatCatz(_callback:Function):void {
			call("coin/fcdata", _callback, null, URLRequestMethod.GET);
		}
		
		/**
		 * Method is used to get detailed information about active investment. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100303187
		 */
		static public function call_getInvestmentDetails(_callback:Function,_instrument:String = null, _callID:String =""):void {
			var php:PayLoader = call("account/investment/details", _callback, {instrument:_instrument}, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Method is used to get trades information for selected investment instrument. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=100303198
		 */
		static public function call_getInvestmentTrades(_callback:Function,_instrument:String = null,_page:int=1, _callID:String =""):void {
			var php:PayLoader = call("account/investment/trades", _callback, {instrument:_instrument, page:_page}, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * Method is used to initiate BUY or SELL investment trade. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=99713165
		 */
		static public function call_putInvestment(_callback:Function, _data:Object = null, _callID:String =""):void {
			var php:PayLoader = call("account/investment", _callback, _data, URLRequestMethod.PUT);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 *  See description:
		 * 
		 */
		static public function call_postAccountTrading(_callback:Function, _data:Object = null, _callID:String =""):void {
			var php:PayLoader = call("account/trading", _callback, _data);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This request is used to get list of term deposit schemes. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=121831446
		 */
		static public function call_getPossibleRD(_callback:Function, _data:Object, _callID:String):void {
			if (_data != null)
				_data.with_blockchain = 1;
			var php:PayLoader = call("term-deposit/schemes", _callback, _data, URLRequestMethod.GET);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _callID;
		}
		
		/**
		 * This request is used to cancel term deposit. See description:
		 * https://intranet.dukascopy.dom/wiki/pages/viewpage.action?pageId=121831458
		 */
		static public function call_postRDCancel(_callback:Function, _data:Object):void {
			var php:PayLoader = call("term-deposit/cancel", _callback, _data);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = _data.code;
		}
		
		///////////////////////
		// SYSTEM METHODS -> //
		///////////////////////
		static private function call(method:String, callBack:Function=null, data:Object=null, requestMethod:String = 'POST', url:String = null, asFile:Boolean = false):PayLoader {
			var php:PayLoader = new PayLoader();
			if (url == null) {
				if (PayConfig.PAY_API_URL == "")
					return php;
				url = PayConfig.PAY_API_URL + method;
			}
			if (asFile == false) {
				php.load(url, callBack, data, requestMethod);
			} else {
				php.loadAsFile(url, callBack, data, requestMethod);
				php.dispose();
			}
			return php;
		}
		
		/**
		 * Call method again using stored request data that is saved when we do request 
		 * @param	savedRequestData
		 */
		static public function callAgain(savedRequestData:Object):void {
			if (savedRequestData == null)
				return;
			var php:PayLoader = new PayLoader();
			php.load(savedRequestData.url, savedRequestData.callBack, savedRequestData.data, savedRequestData.method);
			if (php.savedRequestData != null)
				php.savedRequestData.callID = savedRequestData.callID;
		}
	}
}