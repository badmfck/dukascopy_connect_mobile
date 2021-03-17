package com.dukascopy.connect.sys.sound.soundPlayers 
{
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Mp3SoundPlayer implements ISoundPlayer
	{
		private var stopPlaingTimeout:uint;
		private var onPlaybackComplete:Function;
		private var sound:Sound;
		private var channel:SoundChannel;
		private var onError:Function;
		
		public function Mp3SoundPlayer() 
		{
			
		}
		
		/* INTERFACE com.dukascopy.connect.sys.sound.ISoundPlayer */
		
		public function play(ticket:PlaySoundTicket, soundData:ByteArray, audioId:String, onPlaybackComplete:Function, onError:Function):void 
		{
			this.onPlaybackComplete = onPlaybackComplete;
			this.onError = onError;
			
			soundData.position = 0;
			sound = new Sound();
			sound.addEventListener(Event.COMPLETE, onSoundComplete);
			sound.loadCompressedDataFromByteArray(soundData, soundData.length);
			sound.play();
		}
		
		private function onSoundComplete(e:Event):void 
		{
			channel = sound.play();
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundPlayed);
		}
		
		private function onSoundPlayed(e:Event):void 
		{
			onAudioPlayed();
		}
		
		private function onAudioPlayed():void 
		{
			if (onPlaybackComplete)
			{
				onPlaybackComplete();
			}
		}
		
		public function stop(changeSoundMode:Boolean = true):void
		{
			try
			{
				channel.stop();
				sound.close();
			}
			catch (e:Error)
			{
				
			}
			channel = null;
			sound = null;
			onPlaybackComplete = null;
		}
		
		/* INTERFACE com.dukascopy.connect.sys.sound.soundPlayers.ISoundPlayer */
		
		public function pause():void 
		{
			
		}
		
		/* INTERFACE com.dukascopy.connect.sys.sound.soundPlayers.ISoundPlayer */
		
		public function switchSpeaker(speakerType:String):void 
		{
			
		}
		
		/* INTERFACE com.dukascopy.connect.sys.sound.soundPlayers.ISoundPlayer */
		
		public function getStatus():SoundStatusData 
		{
			return null;
		}
	}
}