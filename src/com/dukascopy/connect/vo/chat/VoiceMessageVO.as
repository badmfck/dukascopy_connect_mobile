package com.dukascopy.connect.vo.chat {
	
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import flash.media.AudioPlaybackMode;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class VoiceMessageVO {
		
		public var isPlaying:Boolean = false;
		public var isLoading:Boolean = false;
		public var codec:String = PlaySoundTicket.AUDIO_FORMAT_AAC;
		public var uid:String;
		public var duration:int= 0;
		public var currentTime:int = 0;
		public var speakerMode:String = AudioPlaybackMode.VOICE;
		
		public function VoiceMessageVO(data:Object) {
			if (data == null)
				return;
			if ("codec" in data)
				codec = data.codec;
			if ("uid" in data)
				uid = data.uid;
			if ("duration" in data)
				duration = data.duration;
		}
		
		public function dispose():void {
			uid = null;
			duration = 0;
			currentTime = 0;
			speakerMode = null;
			codec = null;
		}
	}
}