package com.dukascopy.connect.sys.sound {
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class PlaySoundTicket {
		
		static public const TYPE_REMOTE_UID:String = "remoteUid";
		
		static public const CALLER_CHAT:String = "callerChat";
		
		static public const ACTION_PAUSE:String = "actionPause";
		static public const ACTION_SWITCH_SPEAKER:String = "actionSwitchSpeaker";
		static public const ACTION_PLAY:String = "play";
		static public const ACTION_STOP:String = "stop";
		
		static public const AUDIO_FORMAT_AAC:String = "audioFormatAac";
		static public const AUDIO_FORMAT_MP3:String = "audioFormatMp3";
		
		public var type:String;
		public var soundLink:String;
		public var chatUID:String;
		public var messageUID:int;
		public var action:String;
		public var caller:String;
		public var format:String = AUDIO_FORMAT_AAC;
		public var duration:int;
		public var currentPlayed:int;
		public var speakerType:String;
		
		public function PlaySoundTicket() { }
		
		public function isIdentical(ticket:PlaySoundTicket):Boolean {
			if (ticket.caller == caller) {
				if (ticket.caller == CALLER_CHAT && chatUID == ticket.chatUID && messageUID == ticket.messageUID) {
					return true;
				}
			}
			return false;
		}
	}
}