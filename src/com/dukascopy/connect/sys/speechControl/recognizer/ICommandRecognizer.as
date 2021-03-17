package com.dukascopy.connect.sys.speechControl.recognizer 
{
	import com.dukascopy.connect.data.voiceCommand.VoiceCommand;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface ICommandRecognizer 
	{
		function recognize(texts:Array):VoiceCommand;
	}	
}