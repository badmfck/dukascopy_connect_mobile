package com.dukascopy.connect.sys.sound {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.settings.GlobalSettings;
	import com.dukascopy.connect.sys.sound.soundPlayers.ISoundPlayer;
	import com.dukascopy.connect.sys.sound.soundPlayers.SoundPlayer;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Loader;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Alexey Skuryat
	 */
	
	public class SoundController  {
		
		private static  var _soundManager:SoundManager = new SoundManager();
		private static var _volume:Number = 1;
		
		private static var _inPlaying:Boolean = false;
		private static var _outPlaying:Boolean = false;
		private static var _soundOnCalls:Boolean = true;
		static private var currentTicket:PlaySoundTicket;
		static private var soundPlayers:Dictionary;
		
		public static var S_SOUND_PLAY_START:Signal = new Signal('SoundController.S_SOUND_PLAY_START');
		public static var S_SOUND_PLAY_STOP:Signal = new Signal('SoundController.S_SOUND_PLAY_STOP');
		public static var S_SOUND_PLAY_LOADING:Signal = new Signal('SoundController.S_SOUND_PLAY_LOADING');
		public static var S_SOUND_PLAY_ERROR:Signal = new Signal('SoundController.S_SOUND_PLAY_ERROR');
		public static var S_SOUND_PLAY_COMPLETE:Signal = new Signal('SoundController.S_SOUND_PLAY_COMPLETE');
		public static var S_SOUND_PLAY_PROGRESS:Signal = new Signal('SoundController.S_SOUND_PLAY_PROGRESS');
		
		// CONSTRUCTOR ////////////////////////////////////////////////////////////
		public static function init():void {
			if (Config.PLATFORM_ANDROID == false)
			{
				_soundManager.add_sound(new SWFIncommingCallSound() , "in_call");
				_soundManager.add_sound(new SWFOutgoingCallSound() , "out_call");
			}
			
			_soundManager.add_sound(new ChatSound1() , "chatSent", 0.1);
			_soundManager.add_sound(new ChatSound2() , "chatRecieve", 0.1);
			
			_soundManager.volume = _volume;
			
			soundPlayers = new Dictionary();
			
			S_SOUND_PLAY_COMPLETE.add(onSoundPlayComplete);
			S_SOUND_PLAY_ERROR.add(onSoundPlayError);
		}
		
		static private function onSoundPlayError(ticket:PlaySoundTicket):void 
		{
			stopTicketSound(ticket);
		}
		
		static private function onSoundPlayComplete(ticket:PlaySoundTicket):void 
		{
			stopTicketSound(ticket);
		}
		
		// PUBLIC METHODS /////////////////////////////////////////////////////////
		public static function stopAllSounds():void {
			stopIncommingCall();
			stopOutgoingCall();
		}
		
		/**
		 * Messages Sounds
		 */
		public static function playChatMessageSent():void {
			if (GlobalSettings.soundOnMessages == true && MobileGui.isActive == true)
				_soundManager.play("chatRecieve");
		}
		
		public static function playChatMessageReceive():void {
			if (GlobalSettings.soundOnMessages == true && MobileGui.isActive == true)
				_soundManager.play("chatRecieve");
		}
		
		static public function playChatMessageNotification():void {	
			if (GlobalSettings.soundOnMessages == true && MobileGui.isActive == true)
				_soundManager.play("chatSent");
		}
		
		/**
		 * Incomming Call Sound 
		 * @param	stopAfterSec
		 */
		public static function startIncommingCall(stopAfterSec:Number =-1):void {
			if (_inPlaying)
				return;
			_inPlaying = true;
			_soundManager.play("in_call", 100);
		}
		
		public static function stopIncommingCall():void {
			_soundManager.pause("in_call");
			_inPlaying = false;
		}
		
		/**
		 * o Call Sound
		 */
		public static function startOutgoingCall():void {
			if (_outPlaying)
				return;
			_outPlaying = true;
			_soundManager.play("out_call", 100);
		}	
		
		public static function stopOutgoingCall():void {
			_soundManager.pause("out_call");
			_outPlaying = false;
		}
		
		static public function playTicket(ticket:PlaySoundTicket):void 
		{
			if (ticket.action == PlaySoundTicket.ACTION_STOP)
			{
				if (ticket.caller == PlaySoundTicket.CALLER_CHAT)
				{
					if (currentTicket && currentTicket.chatUID == ticket.chatUID && currentTicket.messageUID == ticket.messageUID)
					{
						stopTicketSound(currentTicket);
						currentTicket = null;
					}
				}
			}
			else if (ticket.action == PlaySoundTicket.ACTION_PLAY)
			{
				if (currentTicket)
				{
					if (currentTicket.isIdentical(ticket))
					{
						currentTicket.action = ticket.action;
						currentTicket.speakerType = ticket.speakerType;
					}
					else
					{
						stopTicketSound(currentTicket, false);
						currentTicket = ticket;
					}
				}
				else
				{
					currentTicket = ticket;
				}
				
				playSoundTicket(currentTicket);
			}
			else if (ticket.action == PlaySoundTicket.ACTION_PAUSE)
			{
				if (currentTicket)
				{
					if (currentTicket.isIdentical(ticket))
					{
						if (soundPlayers[currentTicket])
						{
							(soundPlayers[currentTicket] as SoundPlayer).pause();
						}
						else
						{
							//!TODO: mid crit error;
						}
						return;
					}
					else
					{
						//!TODO: probable error;
						stopTicketSound(currentTicket);
						currentTicket = null;
					}
				}
				else
				{
					//!TODO: probable error;
				}
			}
			else if (ticket.action == PlaySoundTicket.ACTION_SWITCH_SPEAKER)
			{
				if (currentTicket)
				{
					if (currentTicket.isIdentical(ticket))
					{
						if (soundPlayers[currentTicket])
						{
							(soundPlayers[currentTicket] as SoundPlayer).switchSpeaker(ticket.speakerType);
						}
						else
						{
							
						}
						return;
					}
				}
				else
				{
					
				}
			}
		}
		
		static private function playSoundTicket(ticket:PlaySoundTicket):void {
			var player:SoundPlayer;
			if (soundPlayers[ticket]) {
				player = soundPlayers[ticket];
			} else {
				player = new SoundPlayer(ticket);
				soundPlayers[ticket] = player;
			}
			
			player.play();
		}
		
		static private function stopTicketSound(ticket:PlaySoundTicket, changeSoundMode:Boolean = true):void 
		{
			if (currentTicket == ticket)
			{
				currentTicket = null;
			}
			
			if (soundPlayers[ticket])
			{
				(soundPlayers[ticket] as SoundPlayer).stop(changeSoundMode);
				soundPlayers[ticket] = null;
				delete soundPlayers[ticket];
			}
		}
		
		static public function stopAllChatSounds():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				NativeExtensionController.stopIncomingCallSound();
				NativeExtensionController.stopOutgoingCallSound();
			}
			
			var playersToStop:Array = new Array();
			
			for each (var player:SoundPlayer in soundPlayers) 
			{
				if (player.getTicket().caller == PlaySoundTicket.CALLER_CHAT)
				{
					playersToStop.push(player);
				}
			}
			
			for (var i:int = 0; i < playersToStop.length; i++) 
			{
				(playersToStop[i] as SoundPlayer).stop();
				soundPlayers[(playersToStop[i] as SoundPlayer).getTicket()] = null;
				delete soundPlayers[(playersToStop[i] as SoundPlayer).getTicket()];
			}
			
			playersToStop = null;
		}
		
		static public function stopSoundsByChat(uid:String):void 
		{
			var playersToStop:Array = new Array();
			
			for each (var player:SoundPlayer in soundPlayers) 
			{
				if (player.getTicket().caller == PlaySoundTicket.CALLER_CHAT && player.getTicket().chatUID == uid)
				{
					playersToStop.push(player);
				}
			}
			
			for (var i:int = 0; i < playersToStop.length; i++) 
			{
				(playersToStop[i] as SoundPlayer).stop();
				soundPlayers[(playersToStop[i] as SoundPlayer).getTicket()] = null;
				delete soundPlayers[(playersToStop[i] as SoundPlayer).getTicket()];
			}
			
			playersToStop = null;
		}
		
		static public function getCurrentSoundTicket():PlaySoundTicket 
		{
			return currentTicket;
		}
		
		static public function getSoundStatus(ticket:PlaySoundTicket):SoundStatusData 
		{
			if (soundPlayers && soundPlayers[ticket])
			{
				return (soundPlayers[ticket] as SoundPlayer).getStatus();
			}
			return null;
		}
		
		// GETTERS AND SETTERS ////////////////////////////////////////////////////
		public static function get volume():Number { return _volume; }
		public static function set volume(value:Number):void {
			_volume = value;
			_soundManager.volume = _soundOnCalls?_volume:0;
		}
		
		static public function get soundOnCalls():Boolean { return _soundOnCalls; }
		static public function set soundOnCalls(value:Boolean):void {
			if (_soundOnCalls == value) return;
			_soundOnCalls = value;
			_soundManager.volume = _soundOnCalls?_volume:0;
		}
	}
}