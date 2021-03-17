package com.dukascopy.connect.sys.sound.soundPlayers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import com.dukascopy.connect.sys.sound.SoundController;
	import connect.DukascopyExtension;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AacSoundPlayerIOS implements ISoundPlayer {
		
		private var onPlaybackComplete:Function;
		private var onError:Function;
		private var nativeBriedge:DukascopyExtension;
		private var audioPath:String;
		private var ticket:PlaySoundTicket;
		private var playTimer:Timer;
		private var isPlayig:Boolean;
		private var isLoading:Boolean;
		private var time:int;
		
		public function AacSoundPlayerIOS() {
			nativeBriedge = MobileGui.dce;
			if (nativeBriedge)
				nativeBriedge.addEventListener(StatusEvent.STATUS, statusHandler);
		}
		
		private function statusHandler(e:StatusEvent):void {
			if (e.code == "audioPlayer") {
				
				var obj:Object = JSON.parse(e.level);
				var action:String;
				var path:String;
				for (var key:String in obj) {
					action = key;
					path = obj[action];
				}
				
				if (path == audioPath) {
					switch(action) {
						case "startLoading": {
							isLoading = true;
							SoundController.S_SOUND_PLAY_LOADING.invoke(ticket);
							break;
						}
						case "startPlaying": {
							onSoundStartPlay();
							break;
						}
						case "didFinishPlaying": {
							onAudioPlayed();
							break;
						}
						case "errorDidOccur": {
							onErrorOccure();
							break;
						}
						case "loadingError": {
							onErrorOccure();
							break;
						}
						case "decodeErrorDidOccur": {
							onErrorOccure();
							break;
						}
					}
				}
			}
		}
		
		private function onSoundStartPlay():void {
			isLoading = false;
			isPlayig = true;
			if (!playTimer) {
				playTimer = new Timer(1000, ticket.duration);
				playTimer.addEventListener(TimerEvent.TIMER, onPlayProgress);
			}
			if (SoundMixer.audioPlaybackMode != ticket.speakerType)
			{
				SoundMixer.audioPlaybackMode = ticket.speakerType;
			}
			playTimer.start();
			SoundController.S_SOUND_PLAY_START.invoke(ticket);
		}
		
		private function onPlayProgress(e:TimerEvent):void {
			ticket.currentPlayed = playTimer.currentCount;
			SoundController.S_SOUND_PLAY_PROGRESS.invoke(ticket);
		}
		
		private function onErrorOccure():void {
			isPlayig = false;
			isLoading = false;
			if (onError)
				onError();
		}
		
		public function play(ticket:PlaySoundTicket, soundData:ByteArray, audioId:String, onPlaybackComplete:Function, onError:Function):void {
			//!TODO: переписать, не передавать тикет сюда вниз;
			if (playTimer)
				ticket.currentPlayed = playTimer.currentCount;
			else
				ticket.currentPlayed = ticket.duration;
			this.ticket = ticket;
			this.onPlaybackComplete = onPlaybackComplete;
			this.onError = onError;
			if (nativeBriedge) {
				audioPath = Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&uid=" + audioId + "&key=" + Auth.key;
				nativeBriedge.startPlayingRecordedVoice(audioPath);
			}
		}
		
		private function onAudioPlayed():void {
			isPlayig = false;
			isLoading = false;
			clearPlayTimer();
			if (onPlaybackComplete)
				onPlaybackComplete();
		}
		
		private function clearPlayTimer():void {
			if (playTimer) {
				playTimer.stop();
				playTimer.removeEventListener(TimerEvent.TIMER, onPlayProgress);
				playTimer = null;
			}
		}
		
		public function stop(changeSoundMode:Boolean = true):void {
			isPlayig = false;
			isLoading = false;
			if (changeSoundMode && SoundMixer.audioPlaybackMode != AudioPlaybackMode.MEDIA)
			{
				SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
			}
			
			clearPlayTimer();
			
			if (nativeBriedge)
				nativeBriedge.stopRecordedVoice();
			if (nativeBriedge)
				nativeBriedge.removeEventListener(StatusEvent.STATUS, statusHandler);
			
			onError = null;
			onPlaybackComplete = null;
		}
		
		public function switchSpeaker(speakerType:String):void
		{
			if (SoundMixer.audioPlaybackMode != speakerType)
			{
				SoundMixer.audioPlaybackMode = speakerType;
			}
		}
		
		public function pause():void {
			isPlayig = false;
			if (SoundMixer.audioPlaybackMode != AudioPlaybackMode.MEDIA)
			{
				SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
			}
			if (playTimer)
				playTimer.stop();
			if (nativeBriedge)
				nativeBriedge.pauseRecordedVoice();
		}
		
		public function getStatus():SoundStatusData {
			var status:SoundStatusData = new SoundStatusData();
			status.isPlaying = isPlayig;
			status.isLoading = isLoading;
			return status;
		}
	}
}