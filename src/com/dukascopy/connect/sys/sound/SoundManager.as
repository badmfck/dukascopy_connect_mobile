package com.dukascopy.connect.sys.sound {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.greensock.TweenMax;
	import flash.display.Loader;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Alexey Skuryat
	 */
	
	public class SoundManager {
		
		private static var SOUND_NOT_FOUND:String = "Sound Not Found";
		
		private var _library:Loader;
		private var _sounds:Dictionary;
		private var _channels:Dictionary;
		private var _volumes:Dictionary;
		private var _volume:Number;
		private var _volumesMax:Dictionary;
		
		public function SoundManager() {
			_volume = 1;
			_sounds = new Dictionary();
			_channels = new Dictionary();
			_volumes = new Dictionary();
			_volumesMax = new Dictionary();
		}
		
		/*** ADD LIBRARY (loaded swf) ***/
		public function library(library:Loader):void {
			_library = library;
		}
		
		/*** REGISTER SOUND IF LIBRARY IS SETED ***/
		public function register(linkage:String, key:String, startMaxVolume:Number = 1):void {
			var gd:Function;
			var hs:Function;
			
			if (!_library) {
				trace('No Library Loaded');
				return;
			}
			
			gd = _library.contentLoaderInfo.applicationDomain.getDefinition;
			hs = _library.contentLoaderInfo.applicationDomain.hasDefinition;
			
			var sound:*;
			var cls:Class;
			
			if (hs(linkage)) {
				cls = Class(gd(linkage));
				sound = new cls(); 
				if (sound is Sound) {
					_sounds[key] = sound;
					_volumes[key] = _volume * startMaxVolume;
					_volumesMax[key] = startMaxVolume;
				} else {
					trace('Linkage is not a Sound: ', sound);
					sound = null;
				}
			} else
				trace('Invalid Linkage: ', linkage);
		}
		
		/*** ADD SOUND TO DICTIONARY ***/
		public function add_sound(sound:Sound, key:String, startMaxVolume:Number = 1):void {
			if (startMaxVolume > 1)
			{
				startMaxVolume = 1;
			}
			if (startMaxVolume < 0)
			{
				startMaxVolume = 0;
			}
			if (_sounds && _sounds[key] is Sound)
				return;
			_sounds[key] = sound;
			_volumes[key] = _volume * startMaxVolume;
			_volumesMax[key] = startMaxVolume;	
		}
		
		/*** PLAY SOUND BY KEY ***/
		public function play(key:String, loops:int = 0):void {
		//	var playable:Boolean = false;
			if (Config.PLATFORM_ANDROID == true)
			{
				if (key == "in_call")
				{
					NativeExtensionController.playIncomingCallSound();
					return;
				}
				if (key == "out_call")
				{
					NativeExtensionController.playOutgoingCallSound();
					return;
				}
			}
			
			if (Config.PLATFORM_ANDROID == true && Config.MUTE_SOUNDS_ON_ANDROID == true)
			{
				return;
			}
			
			var sound:Sound;
			var channel:SoundChannel;
			if (_sounds && _sounds[key] is Sound) {
				if (_channels && _channels[key] is SoundChannel)
					pause(key);
				sound = _sounds[key];
				channel = sound.play(0, loops, new SoundTransform(_volumes[key]));
				if (!channel)
					return;
				_channels[key] = channel;
			} else
				trace(SOUND_NOT_FOUND);
		}
		
		/*** PAUSE SOUND BY KEY ***/
		public function pause(key:String):void {
			
			if (key == "in_call")
			{
				if (Config.PLATFORM_ANDROID == true)
				{
					NativeExtensionController.stopIncomingCallSound();
					return;
				}
			}
			
			if (key == "out_call")
			{
				if (Config.PLATFORM_ANDROID == true)
				{
					NativeExtensionController.stopOutgoingCallSound();
					return;
				}
			}
			
			var channel:SoundChannel;
			if (_channels && _channels[key] is SoundChannel) {
				channel = _channels[key];
				channel.stop();
			} else
				trace(SOUND_NOT_FOUND);
		}
		
		/*** GET SET GLOBAL VOLUME ***/
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void{
			if (value < 0)
				value = 0;
			if (value > 1)
				value = 1;
			_volume = value;
			
			if (_volumes != null)
				for (var key:Object in _volumes)
					_volumes[key] = value * _volumesMax[key];
			
			if (_channels != null) {
				for (var keyChannel:Object in _channels)
				{
					if (_channels[keyChannel] == null)
						return;
					TweenMax.to(_channels[keyChannel], 0, { volume:_volumes[keyChannel] } );
				}
			}
		}
		
		/*** GET  SET VOLUME BY KEY ***/
		public function get_volume(key:String):Number {
			if (_volumes && _volumes[key] is Number)
				return _volumes[key]; 
			trace(SOUND_NOT_FOUND);
			return NaN;
		}
		
		public function set_volume(key:String, value:Number):void {
			var channel:SoundChannel;
			if (value < 0)
				value = 0;
			if (value > 1)
				value = 1;
			if (_volumes && _volumes[key] is Number) {
				_volumes[key] = value * _volumesMax[key];
				if (_channels && _channels[key] is SoundChannel) {
					channel = _channels[key];
					TweenMax.to(channel, 0, { volume:_volumes[key] } );
				}
			} else
				trace(SOUND_NOT_FOUND);
		}
		
		/*** FADE OUT BY KEY ***/
		public function fade_out(key:String = null, _time:Number = 1):void {
			var channel:SoundChannel;
			if (key) {
				if (_channels && _channels[key] is SoundChannel) {
					channel = _channels[key];
					TweenMax.to(channel, _time, { volume:0 } );
				} else
					trace(SOUND_NOT_FOUND);
			} else
				TweenMax.to(this, _time, { volume:0 } );
		}
		
		/*** FADE IN BY KEY ***/
		public function fade_in(key:String = null, _time:Number = 1):void {
			var channel:SoundChannel;
			if (key) {
				if (_channels && _channels[key] is SoundChannel) {
					channel = _channels[key];
					TweenMax.to(channel, _time, { volume:_volumes[key] } );
				} else
					echo("SoundManager","fade_in",(key+" "+_time+" "+SOUND_NOT_FOUND),true);
			} else
				TweenMax.to(this, _time, { volume:_volumes[key] } );
		}
		
		/*** DISPOSE SOUND MANAGER ***/
		public function dispose():void {
			_volumes = new Dictionary();
			_sounds = new Dictionary();
			_channels = new Dictionary();
			_volumesMax = new Dictionary();
			_volumesMax = null;
			_volumes = null;
			_sounds = null;
			_channels = null;
			_library = null;
		}
	}
}