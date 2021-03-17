package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.type.SoundType;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SoundCollection 
	{
		public static var sounds:Object = { };
			sounds[SoundType.OUTGOING_CALL] = Assets.SOUND_1;
			sounds[SoundType.INCOMING_CALL] = Assets.SOUND_2;		
		
		public function SoundCollection() 
		{
			Assets
		}
		
	}

}