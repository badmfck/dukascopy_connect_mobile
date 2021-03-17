package com.dukascopy.connect.sys.sound.soundPlayers 
{
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface ISoundPlayer 
	{
		function play(ticket:PlaySoundTicket, soundData:ByteArray, audioId:String, onPlaybackComplete:Function, onError:Function):void;
		function stop(changeSoundMode:Boolean = true):void;
		function pause():void;
		function switchSpeaker(speakerType:String):void;
		function getStatus():SoundStatusData;
	}
}