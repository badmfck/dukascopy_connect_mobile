package com.dukascopy.connect.sys.viManager.type 
{
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ServerMessageType 
	{
		static public const START_MESSAGE:String = "startMessage";
		static public const GOODBAY:String = "goodbay";
		static public const MAKE_PASSPOST_MRZ_PHOTO:String = "makePasspostMrzPhoto";
		static public const PASSPORT_QUESTIONS:String = "passportQuestions";
		static public const PASSPORT_QUESTIONS_RESPOND_1:String = "r1";
		static public const PASSPORT_QUESTIONS_RESPOND_2:String = "r2";
		static public const PASSPORT_QUESTIONS_RESPOND_3:String = "r3";
		static public const MAKE_PASSPOST_SELFIE:String = "selfie";
		static public const MAKE_GOLOGRAMM:String = "gologramm";
		static public const SPASIBO:String = "spasibo";
		static public const NEED_VIDEO_PERMISSION:String = "videoPermission";
		static public const CHECK_VIDEO:String = "checkVideo";
		static public const GET_VIDEO:String = "getVideo";
		static public const NEED_VIDEO_PERMISSION_ON_FAIL:String = "needVideoOnFail";
		static public const ADD_VIDEO:String = "addVideo";
		static public const OPEN_SETTINGS:String = "openSettings";
		static public const CHECK_AUDIO:String = "checkAudio";
		static public const GET_AUDIO:String = "getAudio";
		static public const NEED_AUDIO_PERMISSION_ON_FAIL:String = "needAudioOnFail";
		static public const NEED_AUDIO_PERMISSION:String = "needAudioPermission";
		
		public function ServerMessageType() 
		{
			
		}
	}
}