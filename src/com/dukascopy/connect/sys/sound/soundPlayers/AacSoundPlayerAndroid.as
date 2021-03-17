package com.dukascopy.connect.sys.sound.soundPlayers 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.dukascopyextension.DukascopyExtensionAndroid;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.media.AudioPlaybackMode;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class AacSoundPlayerAndroid implements ISoundPlayer
	{
		private var onPlaybackComplete:Function;
		private var onError:Function;
		private var nativeBriedge:DukascopyExtensionAndroid;
		private var audioPath:String;
		private var ticket:PlaySoundTicket;
		private var playTimer:Timer;
		private var isPlayig:Boolean;
		private var isLoading:Boolean;
		private var playStartTime:int;
		private var currentPosition:int = 0;
		
		public function AacSoundPlayerAndroid() 
		{
			nativeBriedge = MobileGui.androidExtension;
			if (nativeBriedge)
			{
				nativeBriedge.addEventListener(StatusEvent.STATUS, statusHandler);
			}
		}
		
		/* INTERFACE com.dukascopy.connect.sys.sound.ISoundPlayer */
		
		private function statusHandler(e:StatusEvent):void
		{
			if (e.code == "audioPlayer") {
				var obj:Object = JSON.parse(e.level);
				
				var action:String;
				var path:String;
				
				for (var key:String in obj)
				{
					action = key;
					path = obj[action];
				}
				
				if (path == audioPath)
				{
					switch(action)
					{
						case "startLoading":
						{
							isLoading = true;
							SoundController.S_SOUND_PLAY_LOADING.invoke(ticket);
							break;
						}
						case "startPlaying":
						{
							onSoundStartPlay();
							break;
						}
						case "didFinishPlaying":
						{
							onAudioPlayed();
							break;
						}
						case "errorDidOccur":
						{
							onErrorOccure();
							break;
						}
						case "decodeErrorDidOccur":
						{
							onErrorOccure();
							break;
						}
					}
				}
			}
		}
		
		private function onSoundStartPlay():void 
		{
			isPlayig = true;
			isLoading = true;
			if (!playTimer)
			{
				playTimer = new Timer(1000, ticket.duration);
				playTimer.addEventListener(TimerEvent.TIMER, onPlayProgress);
			}
			playStartTime = getTimer();
			playTimer.start();
			
			SoundController.S_SOUND_PLAY_START.invoke(ticket);
		}
		
		public function switchSpeaker(speakerType:String):void
		{
			if (nativeBriedge)
			{
				if (speakerType == AudioPlaybackMode.MEDIA)
				{
					nativeBriedge.switchSound(audioPath, true);
				}
				else if (speakerType == AudioPlaybackMode.VOICE)
				{
					nativeBriedge.switchSound(audioPath, false);
				}
			}
		}
		
		private function onPlayProgress(e:TimerEvent):void 
		{
			var played:int = getTimer() - playStartTime;
			
			ticket.currentPlayed = int((currentPosition + played)/1000);
			SoundController.S_SOUND_PLAY_PROGRESS.invoke(ticket);
		}
		
		private function clearPlayTimer():void 
		{
			if (playTimer)
			{
				playTimer.stop();
				playTimer.removeEventListener(TimerEvent.TIMER, onPlayProgress);
				playTimer = null;
			}
		}
		
		private function onErrorOccure():void 
		{
			isPlayig = false;
			isLoading = false;
			if (onError)
			{
				onError();
			}
		}
		
		public function play(ticket:PlaySoundTicket, soundData:ByteArray, audioId:String, onPlaybackComplete:Function, onError:Function):void 
		{
			//!TODO: переписать, не передавать тикет сюда вниз;
			
			if (playTimer)
			{
				ticket.currentPlayed = int(currentPosition/1000);
			}
			else
			{
				ticket.currentPlayed = 0;
			}
			
			var loud:Boolean = false;
			if (ticket.speakerType == AudioPlaybackMode.MEDIA)
			{
				loud = true;
			}
			
			this.ticket = ticket;
			this.onPlaybackComplete = onPlaybackComplete;
			this.onError = onError;
			
			if (nativeBriedge)
			{
				audioPath = Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&uid=" + audioId + "&key=" + Auth.key;
				nativeBriedge.play(audioPath, ticket.soundLink, File.cacheDirectory.url.slice(6), loud);
			}
		}
		
		private function onAudioPlayed():void {
			isPlayig = false;
			isLoading = false;
			currentPosition = 0;
			SoundController.S_SOUND_PLAY_PROGRESS.invoke(ticket);
			SoundController.S_SOUND_PLAY_STOP.invoke(ticket);
			clearPlayTimer();
			if (onPlaybackComplete)
				onPlaybackComplete();
		}
		
		public function stop(changeSoundMode:Boolean = true):void {
			isPlayig = false;
			isLoading = false;
			currentPosition = 0;
			clearPlayTimer();
			if (nativeBriedge)
				nativeBriedge.stop(audioPath, ticket.soundLink);
			onError = null;
			onPlaybackComplete = null;
			if (nativeBriedge)
				nativeBriedge.removeEventListener(StatusEvent.STATUS, statusHandler);
		}
		
		/* INTERFACE com.dukascopy.connect.sys.sound.soundPlayers.ISoundPlayer */
		
		public function pause():void {
			var played:int = getTimer() - playStartTime;
			currentPosition = currentPosition + played;
			SoundController.S_SOUND_PLAY_PROGRESS.invoke(ticket);
			isPlayig = false;
			if (playTimer)
				playTimer.stop();
			if (nativeBriedge)
				nativeBriedge.pause(audioPath, ticket.soundLink);
		}
		
		/* INTERFACE com.dukascopy.connect.sys.sound.soundPlayers.ISoundPlayer */
		
		public function getStatus():SoundStatusData {
			var status:SoundStatusData = new SoundStatusData();
			
			status.isPlaying = isPlayig;
			status.isLoading = isLoading;
			
			return status;
		}
	}
}