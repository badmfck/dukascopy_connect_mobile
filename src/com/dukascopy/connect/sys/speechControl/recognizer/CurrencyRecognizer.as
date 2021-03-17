package com.dukascopy.connect.sys.speechControl.recognizer 
{
	import com.dukascopy.connect.data.voiceCommand.VoiceCommand;
	import com.dukascopy.connect.data.voiceCommand.VoiceCommandType;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CurrencyRecognizer
	{
		private var recognizers:Vector.<SimpleRecognizer>;
		
		public function CurrencyRecognizer() 
		{
			recognizers = new Vector.<SimpleRecognizer>();
			
			var recognizer_EUR:SimpleRecognizer = new SimpleRecognizer(TypeCurrency.EUR, 
																				[
																					"евро",
																					"еврики",
																					"евриков",
																					"еврика"
																				]);
			recognizers.push(recognizer_EUR);
			
			var recognizer_RUB:SimpleRecognizer = new SimpleRecognizer(TypeCurrency.RUB, 
																				[
																					"рубль",
																					"рубля",
																					"рублей",
																					"рубли",
																					"руб",
																					"рубчиков",
																					"рубчики",
																					"рубчика",
																				]);
			recognizers.push(recognizer_RUB);
			
			var recognizer_USD:SimpleRecognizer = new SimpleRecognizer(TypeCurrency.RUB, 
																				[
																					"зеленых",
																					"бакс",
																					"бакса",
																					"баксы",
																					"баксов",
																					"зелени",
																					"зелень",
																					
																					"доллар",
																					"доллара",
																					"долларов",
																					"доллары",
																					"доллар",
																					
																					"долар",
																					"долара",
																					"доларов",
																					"долары",
																					"долар",
																				]);
			recognizers.push(recognizer_USD);
		}
		
		public function recognize(item:String):String 
		{
			var k:int = recognizers.length;
			
			for (var i:int = 0; i < k; i++) 
			{
				if (recognizers[i].recognize(item) == true)
				{
					return recognizers[i].result;
				}
			}
			
			return null;
		}
	}
}