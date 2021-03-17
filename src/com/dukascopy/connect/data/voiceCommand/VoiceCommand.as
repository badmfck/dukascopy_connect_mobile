package com.dukascopy.connect.data.voiceCommand 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VoiceCommand 
	{
		public var type:VoiceCommandType;
		public var debitValue:Number;
		public var debitCurrency:String;
		public var creditCurrency:String;
		
		public function VoiceCommand(type:VoiceCommandType) 
		{
			this.type = type;
		}
	}
}