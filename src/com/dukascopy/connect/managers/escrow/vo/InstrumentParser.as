package com.dukascopy.connect.managers.escrow.vo 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.utils.NumberFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InstrumentParser 
	{
		
		public function InstrumentParser() 
		{
			
		}
		
		public function parse(instrumentRawData:Object):EscrowInstrument 
		{
			var result:EscrowInstrument;
			if (valid(instrumentRawData))
			{
				var priceValue:Number = (Number(instrumentRawData.bid) + Number(instrumentRawData.ask)) / 2;
				priceValue = Number(NumberFormat.formatAmount(priceValue, instrumentRawData.fiat, true));
				var price:EscrowPrice = new EscrowPrice(instrumentRawData.fiat, priceValue);
				result = new EscrowInstrument(instrumentRawData.name, null, Number(instrumentRawData.precision), instrumentRawData.code, price);
			}
			else
			{
				ApplicationErrors.add();
			}
			
			return result;
		}
		
		private function valid(instrumentRawData:Object):Boolean 
		{
			if (!("ask" in instrumentRawData && !isNaN(Number(instrumentRawData.ask))))
			{
				return false;
			}
			if (!("bid" in instrumentRawData && !isNaN(Number(instrumentRawData.bid))))
			{
				return false;
			}
			if (!("precision" in instrumentRawData && !isNaN(Number(instrumentRawData.precision))))
			{
				return false;
			}
			if (!("code" in instrumentRawData && instrumentRawData.code != null))
			{
				return false;
			}
			if (!("fiat" in instrumentRawData && instrumentRawData.fiat != null))
			{
				return false;
			}
			if (!("name" in instrumentRawData && instrumentRawData.name != null))
			{
				return false;
			}
			/*if (!("stock" in instrumentRawData && instrumentRawData.stock != null))
			{
				return false;
			}*/
			if (!("id" in instrumentRawData))
			{
				return false;
			}
			
			return true;
		}
	}
}