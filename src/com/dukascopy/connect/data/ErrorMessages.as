package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author SergeyDobarin
	 */
	public class ErrorMessages 
	{
		static public const PHP_IRC_MAX_CHANNELS:String = "irc..10";
		static public const PHP_IRC_NO_PAYMENTS_ACCOUNT:String = "irc..09";
		static public const PHP_IRC_NO_USER:String = "irc..03";
		static public const PHP_IRC_NO_CHAT:String = "irc..02";
		static public const PHP_IRC_NO_ACCESS:String = "irc..04";
		
		/*const ERROR_NO_CHAT_UID = 'irc..01 No chat uid provided';
		const ERROR_CHANGE_AVATAR_FORBIDDEN = 'irc..05 No rights to change avatar';
		const ERROR_NO_DIRECT_CALL = 'irc..06 No direct call';
		const ERROR_NO_COMPANY_MEMBER = 'irc..07 No company member';
		const ERROR_WRONG_MODE = 'irc..08 Wrong mode';*/
		
		public function ErrorMessages() 
		{
			
		}
		
		static public function getLocal(errorMsg:String):String
		{
			if (!errorMsg)
			{
				//TODO: общая ошибка;
				return null;
			}
			
			if (errorMsg == PHP.NETWORK_ERROR)
			{
				return Lang.alertProvideInternetConnection;
			}
			
			if (errorMsg.indexOf("SERVER ERROR") != -1)
			{
				return Lang.serverError + errorMsg;
			}
			
			if (errorMsg.length >= 7)
			{
				errorMsg = errorMsg.slice(0, 7);
			}
			else
			{
				//TODO: неверный формат ошибки;
			}
			
			switch(errorMsg)
			{
				case PHP_IRC_NO_USER:
				{
					return Lang.errorUserNotFound;
					break;
				}
				case PHP_IRC_NO_CHAT:
				{
					return Lang.errorChannelNotFound;
					break;
				}
				case PHP_IRC_NO_ACCESS:
				{
					return Lang.errorYouHaveNoAccess;
					break;
				}
				case PHP_IRC_MAX_CHANNELS:
				{
					return Lang.maxChannels;
					break;
				}
				case PHP_IRC_NO_PAYMENTS_ACCOUNT:
				{
					return Lang.needPaymentsToCreateChannel;
					break;
				}
			}
			
			//!TODO: уточнить что выводить;
			return Lang.somethingWentWrong;
		}
	}
}