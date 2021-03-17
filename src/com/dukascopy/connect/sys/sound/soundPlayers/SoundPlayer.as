package com.dukascopy.connect.sys.sound.soundPlayers 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.sys.localFiles.FileLoader;
	import com.dukascopy.connect.sys.localFiles.LoadFileData;
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.sound.soundPlayers.Mp3SoundPlayer;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SoundPlayer 
	{
		private var ticket:PlaySoundTicket;
		private var loading:Boolean;
		private var loader:FileLoader;
		private var duration:uint;
		private var stream_ns:NetStream;
		private var stopPlaingTimeout:uint;
		private var player:ISoundPlayer;
		
		public function SoundPlayer(ticket:PlaySoundTicket) 
		{
			this.ticket = ticket;
		}
		
		public function play():void 
		{
			if (player)
			{
				//resume from pause;
				player.play(ticket, null, ticket.soundLink, onPlaybackComplete, onSoundError);
			}
			else
			{
				if (Config.PLATFORM_APPLE)
				{
					player = getPlayer(ticket.format);
					if (player)
					{
						player.play(ticket, null, ticket.soundLink, onPlaybackComplete, onSoundError);
					}
				}
				else if (Config.PLATFORM_ANDROID)
				{
					player = getPlayer(ticket.format);
					if (player)
					{
						player.play(ticket, null, ticket.soundLink, onPlaybackComplete, onSoundError);
					}
				}
				else
				{
					loadFile();
				}
			}
			
			
		}
		
		private function loadFile():void 
		{
			loading = true;
			
			SoundController.S_SOUND_PLAY_LOADING.invoke(ticket);
			
			loader = new FileLoader(onFileLoadStatus);
			loader.loadRemoteFile(ticket.soundLink, "voice");
		}
		
		private function onFileLoadStatus(result:LoadFileData):void 
		{
			switch(result.status)
			{
				case FileLoader.COMPLETE:
				{
					plauAudio(result.data as ByteArray, ticket.soundLink);
					closeLoader();
					loading = false;
					break;
				}
				case FileLoader.LOAD_ERROR:
				{
					closeLoader();
					loading = false;
					break;
				}
				case FileLoader.LOAD_IO_ERROR:
				{
					closeLoader();
					loading = false;
					break;
				}
				case FileLoader.PROGRESS:
				{
					break;
				}
			}
		}
		
		private function closeLoader():void 
		{
			if (loader)
			{
				loader.dispose();
				loader = null;
			}
		}
		
		private function plauAudio(soundData:ByteArray, audioId:String):void 
		{
			player = getPlayer(ticket.format);
			if (player)
			{
				player.play(ticket, soundData, audioId, onPlaybackComplete, onSoundError);
			}
			else
			{
				//!TODO;
			}
		}
		
		private function onSoundError():void 
		{
			SoundController.S_SOUND_PLAY_ERROR.invoke(ticket);
		}
		
		private function onPlaybackComplete():void 
		{
			SoundController.S_SOUND_PLAY_COMPLETE.invoke(ticket);
		}
		
		private function getPlayer(codec:String):ISoundPlayer 
		{
			if (ticket.format == PlaySoundTicket.AUDIO_FORMAT_AAC)
			{
				if (Config.PLATFORM_APPLE)
				{
					return new AacSoundPlayerIOS();
				}
				else if (Config.PLATFORM_ANDROID)
				{
					return new AacSoundPlayerAndroid();
				}
				else
				{
					return null;
				//	return new AacSoundPlayerWindows();
				}
			}
			else if (ticket.format == PlaySoundTicket.AUDIO_FORMAT_MP3)
			{
				return new Mp3SoundPlayer();
			}
			return null;
		}
		
		public function stop(changeSoundMode:Boolean = true):void 
		{
			if (player)
			{
				player.stop(changeSoundMode);
				player = null;
			}
			if (loader)
			{
				loader.dispose();
				loader = null;
			}
			SoundController.S_SOUND_PLAY_STOP.invoke(ticket);
		}
		
		public function getTicket():PlaySoundTicket 
		{
			return ticket;
		}
		
		public function pause():void 
		{
			if (player)
			{
				player.pause();
			}
		}
		
		public function switchSpeaker(speakerType:String):void 
		{
			if (player)
			{
				player.switchSpeaker(speakerType);
			}
		}
		
		public function getStatus():SoundStatusData 
		{
			if (player)
			{
				return player.getStatus();
			}
			else
			{
				return null;
			}
			
		}
	}
}