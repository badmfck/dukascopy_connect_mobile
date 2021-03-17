package com.dukascopy.connect.sys.speechControl.recognizer 
{
	import com.dukascopy.connect.data.voiceCommand.VoiceCommand;
	import com.dukascopy.connect.data.voiceCommand.VoiceCommandType;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ExchangeRecognizer implements ICommandRecognizer
	{
		private var keywords:Vector.<String>;
		
		private var type:com.dukascopy.connect.data.voiceCommand.VoiceCommandType;
		private var curencyRecognizer:com.dukascopy.connect.sys.speechControl.recognizer.CurrencyRecognizer;
		
		public function ExchangeRecognizer() 
		{
			type = new VoiceCommandType(VoiceCommandType.TYPE_EXCHANGE);
			
			keywords = new Vector.<String>();
			
			keywords.push("обменять");
			keywords.push("обмен");
			keywords.push("поменять");
			keywords.push("поменяй");
			keywords.push("обменяй");
		}
		
		/* INTERFACE com.dukascopy.connect.sys.speechControl.recognizer.ICommandRecognizer */
		
		public function recognize(items:Array):VoiceCommand 
		{
			var l:int = items.length;
			var k:int = keywords.length;
			
			for (var i:int = 0; i < l; i++) 
			{
				for (var j:int = 0; j < l; j++) 
				{
					if (items[i] == keywords[j])
					{
						return parse(items, i);
					}
				}
			}
			
			return null;
		}
		
		private function parse(items:Array, startIndex:int):VoiceCommand 
		{
			var command:VoiceCommand = new VoiceCommand(type);
			curencyRecognizer = new CurrencyRecognizer();
			
			var l:int = items.length;
			
			
			var debitValue:Number;
			var creditValue:Number;
			
			var debitCurrency:String;
			var creditCurrency:String;
			
			
			// DEBIT VALUE
			var index:int = findValue(items, startIndex + 1);
			if (index != -1)
			{
				debitValue = Number(items[index]);
			}
			else{
				return null;
			}
			
			
			// DEBIT CURRENCY
			index = findCurrency(items, index + 1);
			if (index != -1)
			{
				debitCurrency = curencyRecognizer.recognize(items[index]);
			}
			else{
				return null;
			}
			
			
			/*// CREDIT VALUE
			index = findValue(items, startIndex + 1);
			if (index != -1)
			{
				creditValue = Number(items[index]);
			}
			else{
				return null;
			}*/
			
			
			// CREDIT CURRENCY
			index = findCurrency(items, index + 1);
			if (index != -1)
			{
				creditCurrency = curencyRecognizer.recognize(items[index]);
			}
			else{
				return null;
			}
			
			command.debitValue = debitValue;
		//	command.creditValue = creditValue;
			command.debitCurrency = debitCurrency;
			command.creditCurrency = creditCurrency;
			
			return command;
		}
		
		private function findValue(items:Array, index:int):int 
		{
			var l:int = items.length;
			for (var i:int = index; i < l; i++) 
			{
				if (!isNaN(Number(items[i])))
				{
					return i;
				}
			}
			return -1;
		}
		
		private function findCurrency(items:Array, index:int):int 
		{
			var l:int = items.length;
			var currency:String;
			for (var i:int = index; i < l; i++) 
			{
				currency = curencyRecognizer.recognize(items[i]);
				if (currency != null)
				{
					return i;
				}
			}
			return -1;
		}
	}
}