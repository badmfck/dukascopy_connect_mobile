package com.dukascopy.connect.data.voiceCommand 
{
	/**
	 * ...
	 * @author ...
	 */
	public class VoiceCommandType 
	{
		static public const TYPE_EXCHANGE:String = "typeExchange";
		
		public var type:String;
		
		public function VoiceCommandType(type:String) 
		{
			this.type = type;
		}	
	}
}