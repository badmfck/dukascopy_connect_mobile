package com.dukascopy.connect.sys.speechControl 
{
	import com.dukascopy.connect.data.voiceCommand.VoiceCommand;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.speechControl.recognizer.ExchangeRecognizer;
	import com.dukascopy.connect.sys.speechControl.recognizer.ICommandRecognizer;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CommandRecognizer 
	{
		private var recognizers:Vector.<com.dukascopy.connect.sys.speechControl.recognizer.ICommandRecognizer>;
		
		public function CommandRecognizer() 
		{
			recognizers = new Vector.<ICommandRecognizer>();
			
			recognizers.push(new ExchangeRecognizer());
		//	recognizers.push(new ExchangeRecognizer());
		}
		
		public function recognize(items:Array):VoiceCommand 
		{
			if (recognizers == null)
			{
				ApplicationErrors.add();
				return null;
			}
			
			var l:int = items.length;
			for (var i:int = 0; i < l; i++) 
			{
				if (items[i] != null && items[i] is String)
				{
					items[i] = (items[i] as String).toLowerCase();
				}
			}
			
			var k:int = recognizers.length;
			
			var result:VoiceCommand;
			
			for (var j:int = 0; j < k; j++) 
			{
				result = recognizers[j].recognize(items);
				if (result != null)
				{
					return result;
				}
			}
			return null;
		}
	}
}