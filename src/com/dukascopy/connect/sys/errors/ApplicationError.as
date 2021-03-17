package com.dukascopy.connect.sys.errors 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ApplicationError extends Error
	{
		static public const MESSAGE_CONTROLLER_NOT_INITIALIZED:String = "MessageController: call to class before initialization";
		static public const USER_DATA_MANAGER_WRONG_DATA:String = "UserProfileManager.getUserData(): call with incompatible data type";
		static public const SELECTOR_COMPONENT_WRONG_RENDERER:String = "selectorComponentWrongRenderer";
		static public const USER_POPUP_WRONG_DATA:String = "userPopupWrongData";
		static public const BAN_INFO_POPUP_WRONG_DATA:String = "banInfoPopupWrongData";
		static public const SEND_VOICE_ACTION_WRONG_DATA:String = "sendVoiceActionWrongData";
		
		public function ApplicationError(message:String) 
		{
			super(message);
		}
	}
}