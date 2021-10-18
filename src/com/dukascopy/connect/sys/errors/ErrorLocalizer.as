package com.dukascopy.connect.sys.errors {
	
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ErrorLocalizer {
		
		//private static const ERROR_CREATE_CODE:String = 'prfl.00'; //Unknown error
		private static const ERROR_NEED_AUTHORIZATION:String = 'prfl.01'; //Need to be authorized
		private static const ERROR_NO_USER:String = 'prfl.02'; //Unknown user
		private static const ERROR_BAD_DATA:String = 'prfl.03'; //Invalid input data
		//private static const ERROR_BAD_USER:String = 'prfl.04'; //Invalid user data
		//private static const ERROR_INVALID_NAME:String = 'prfl.05'; //Can not change name on the provided one
		//private static const ERROR_FILE_DATA:String = 'prfl.06'; //Invalid file data
		private static const WRONG_CODE:String = 'auth.02'; //Wrong code or device
		private static const WRONG_PHONE_NUMBER:String = 'auth.08'; //Wrong phone number
		private static const REPEATED_REQUEST_SMS:String = 'sms..04'; //You have requested sms code... повторный запрос
		private static const CALLS_LIMIT:String = 'sms..11'; //Todays calls limit reached
		
		static public const PAYMENTS_ERROR_NO_MONEY:String = "3302";
		static public const PAYMENTS_ERROR_AMOUNT_TOO_SMALL:String = "4501";

		private static const alert_from_server:Object = {
			auth_01:"noCreateCode",
			auth_03:"codeExpired",
			auth_04:"noAddFxcommUser",
			auth_05:"fxcommResponseIsInvalid",
			auth_06:"fxcommFormatWasChanged",
			auth_07:"fxcommAuthError",
			auth_09:"noUserCheckKey",
			auth_10:"ldapAuthError",
			auth_11:"mustBeLoggedIn",
			auth_12:"wrongTraderApi",
			auth_13:"wrongTraderHash",
			auth_14:"wrongTraderTokenResponse",
			auth_15:"wrongTraderToken",
			auth_16:"ldapWrongRespond",
			auth_17:"wrongNetwork",
			auth_18:"noExternalIpsInConfig",
			auth_19:"unauthorizedAccess",
			auth_21:"userAlreadyExistsUID",
			auth_22:"wrongPayerHash",
			auth_23:"wrongPayerTokenResponse",
			auth_24:"wrongPayerToken",
			ban__01:"noChatUidProvided",
			ban__02:"noChat",
			ban__03:"noUser",
			ban__04:"noAccess",
			ban__05:"usersToMatch",
			ban__06:"userNotExists",
			ban__07:"userOrIPAlreadyBanned",
			block01:"noUser",
			block02:"noAccess",
			block03:"noSecurityKey",
			block04:"userAlreadyBlocked",
			call_01:"unauthorizedAccess",
			call_02:"wrongInputParameters",
			call_03:"noUser",
			call_04:"noCallRecord",
			call_05:"duplicateIDforOtherUsers",
			cfg__02:"noDirectoryToStore",
			chat_01:"noChatUidProvided",
			chat_02:"noChat",
			chat_03:"noUser",
			chat_04:"noAccess",
			chat_05:"usersToMatch",
			chat_06:"userNotExists",
			chat_07:"userNotInChat",
			chat_08:"noUsersToAdd",
			chat_09:"noRemoveOwnerFromChat",
			chat_10:"noLeavePrivateChat",
			chat_11:"noGetCompanySecurityKey",
			chat_12:"noUserUidProvied",
			chat_13:"noDirectCall",
			chat_14:"wrongChatType",
			chat_15:"onlyOwnerCanRemoveUsers",
			chat_16:"invalidBase64Data",
			chat_17:"canNotFindWritePath",
			chat_18:"noChangeAvatar",
			chat_19:"databaseError",
			chat_20:"userWasBannedInChatRoom",
			chatd00:"someDatabaseError",
			chatd01:"accessDenied",
			chatd02:"needToByAuthorized",
			chatd03:"badInputParameters",
			cmp__01:"youHaveNoCompany",
			cmp__02:"noCompanyFound",
			cmp__03:"companyMemberNoCreate",
			cmp__04:"noStartChatWithAnonym",
			cmp__05:"wrongEntryPoint",
			cmp__06:"noCompanySecurityKey",
			cmp__07:"wrongCompanySecurityKey",
			cmp__08:"accessDenied",
			cmp__09:"wrongSupporterUID",
			cmp__10:"databaseError",
			com__01:"wrongData",
			com__02:"noUser",
			com__03:"mySQLError",
			com__04:"notAllowed",
			com__05:"unknownUser",
			cont_01:"unauthorizedAccess",
			cont_02:"wrongFxcommRespond",
			cont_03:"noFxcommUser",
			core_01:"noUserCheckKey",
			core_02:"authKeyExpired",
			core_03:"noSecurityKey",
			core_04:"authKeyIsCompromised",
			core_05:"cDATADamaged",
			core_06:"noMethod",
			core_07:"invalidUTF8Symbols",
			core_08:"youAreBanned",
			core_09:"youAreBanned",
			core_10:"databaseError",
			geo__00:"someDatabaseError",
			geo__01:"accessDenied",
			file_01:"userUnknown",
			file_02:"wrongFileInputData",
			file_03:"badInputParameters",
			file_04:"needAuthorization",
			file_05:"wrongUserParamsInStorage",
			file_07:"accessDenied",
			file_08:"noFileInStorage",
			//file_08:"dbErrorDueGuestCreation",
			file_09:"noThumbInStorage",
			file_11:"storageError",
			file_12:"chunkNotUploaded",
			hist_01:"needAuthorization",
			hist_02:"noCompanyUser",
			hist_03:"wrongCompanyMember",
			hist_04:"noChatFound",
			hist_05:"maxPeriodSearchExceeded",
			hist_06:"noGivenCriteria",
			prfl_07:"fXCommGalleryFail",
			rms__01:"invalidInputData",
			rms__02:"wrongUsername",
			rms__03:"RMSError",
			sms__00:"textOK",
			sms__01:"userUnknown",
			sms__03:"wrongParams",
			sms__05:"needFullAuthorization",
			sms__06:"antispamRobot",
			sms__07:"wrongPhoneNumber",
			sms__08:"requestCodeViaSmsFirst",
			sms__09:"yourTodaysCallsLimit",
			sms__10:"todaysCallsLimitIP",
			sms__12:"otherError",
			sms__13:"phoneBannedFromVoiceCalls",
			srch_01:"unauthorizedAccess",
			srch_02:"wrongInputData",
			stat_01:"unauthorizedAccess",
			stck_01:"wrongGroupID",
			stck_02:"wrongStickerID",
			stck_03:"fileHasBeenBroken",
			stck_04:"notValidInputData",
			stck_05:"databaseError",
			stck_06:"notEmptyGroup",
			stck_10:"needToBeInside",
			store01:"nameCanNotBeEmpty",
			store02:"numberMustContainOnly",
			store03:"databaseError",
			store04:"nothingToUpdate",
			store05:"nothingToDecrement",
			store06:"numberAndDataNoNULL",
			supp_01:"unauthorizedAccess",
			supp_02:"wrongInputParameters",
			supp_03:"noUser",
			supp_05:"wrongEntryPoint",
			supp_06:"wrongSupporterUID",
			team_01:"unauthorizedAccess",
			team_02:"teamMembersIsEmpty",
			team_03:"membersIsEmpty",
			team_04:"wrongRequestSign",
			que__25:"setTipsForQuestion",
			que__04:"youCantAddQuestion",
			que__16:"questionYouAreBanned",
			refer00:"unknownError",
			refer01:"mySQLError",
			refer02:"needAuthorized",
			refer03:"registeredInPayments",
			refer04:"userUnknown",
			refer05:"invalidInputData",
			refer06:"inviteAlreadyStored",
			refer07:"alreadyInvited",
			refer08:"deviceAlreadyInList",
			refer09:"unknownPromoCode",
			lotl_04:"registeredInPayments",
			refer10:"alreadyInPayments",
			que__26:"error_remove_ads_has_answers",
			cp2p_01:"error_cant_start_deal_active_deals"
		};
		"cp2p.01 Cant start new deal with this user having active deal"
		static public const FIND_USER_TARGET:String = "findUser";
		static public const ENTER_PROMOCODE_TARGET:String = "enterPromocodeTarget";
		
		private static const noTargetOrKey:String = "Error!!!Needed phrase is missing in ErrorLocalizer.";
		
		public function ErrorLocalizer() { }
		
		static public function getText(errorMsg:String, target:String = null):String {
			if (errorMsg == PHP.NETWORK_ERROR)
				return Lang.alertProvideInternetConnection;
			var codeError:String;
			if (errorMsg != null && errorMsg.length >= 7)
			{
				if (isNaN(Number(errorMsg.charAt(5))))
				{
					return errorMsg;
				}
				codeError = errorMsg.slice(0, 7);
			}
			else
				return Lang.textError;
			var result:String;

			//////////////////////////
			var server_code:String = codeError.replace(/\./g, "_");
			if (server_code in alert_from_server) {
				result = Lang[alert_from_server[server_code]];
				if (result != null)
					return result;
			}
			//////////////////////////
			
			switch(codeError) {
				case ERROR_BAD_DATA: {
					result = resultBadDataError(target);
					break;
				}
				case ERROR_NO_USER: {
					result = resultNoUserError(target);
					break;
				}
				case ERROR_NEED_AUTHORIZATION: {
					result = resultAuthNeededError(target);
					break;
				}
				case WRONG_CODE: {
					result = wrongCode_error(target);
					break;
				}
				case REPEATED_REQUEST_SMS: {
					result = youHaveRequestedSMS_error(target);
					break;
				}
				case CALLS_LIMIT: {
					result = callsLimitReached_error(target);
					break;
				}
				case WRONG_PHONE_NUMBER: {
					result = wrongPhone_error(target);
					break;
				}
				default: {
					result = errorMsg.substr(8); 
				}
			}
			
			return result;
		}
		
		static public function getPaymentsError(errorCode:String = null, defaultText:String = null):String 
		{
			switch(errorCode)
			{
				case PAYMENTS_ERROR_NO_MONEY:
				{
					return Lang.notEnoughAssets;
				}
				case PAYMENTS_ERROR_NO_MONEY:
				{
					return Lang.payments_error_amount_too_small;
				}
			}
			return defaultText;
		}
		
		static private function resultAuthNeededError(target:String):String {
			switch(target) {
				case FIND_USER_TARGET: {
					return Lang.notAuthorized;
					break;
				}
			}
			return Lang.notAuthorized;
		}
		
		static private function resultNoUserError(target:String):String {
			switch(target) {
				case FIND_USER_TARGET: {
					return Lang.phoneNotFound;
					break;
				}
			}
			return Lang.unknownUser;
		}
		
		static private function resultBadDataError(target:String):String {
			switch(target) {
				case FIND_USER_TARGET: {
					return Lang.wrongPhoneNumber;
					break;
				}
			}
			return Lang.invalidInputData;
		}
		
		static private function wrongCode_error(target:String):String {
			if (target == "AUTH")
				return Lang.wrongCode;
			return noTargetOrKey;
		}
		
		static private function wrongPhone_error(target:String):String {
			if (target == "AUTH")
				return Lang.wrongPhoneNumber;
			return noTargetOrKey;
		}
		
		static private function youHaveRequestedSMS_error(target:String):String {
			if (target == "AUTH")
				return Lang.youHaveRequestedSMS;
			return noTargetOrKey;
		}
		
		static private function callsLimitReached_error(target:String):String {
			if (target == "AUTH")
				return Lang.callsLimitReached;
			return noTargetOrKey;
		}
	}
}