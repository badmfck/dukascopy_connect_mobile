package com.dukascopy.connect.managers.crypto 
{
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.store.Store;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CryptoRates 
	{
		private var data:Array = new Array();
		private var updateTimeout:Number = 1000 * 60 * 60;
		
		public function CryptoRates() 
		{
			initSignals();
		}
		
		private function initSignals():void 
		{
			GD.S_ESCROW_INSTRUMENT_RATES_REQUEST.add(getRates);
		}
		
		private function getRates(instrument:EscrowInstrument):void
		{
			if (instrument != null)
			{
				var currentRates:InvestmentRates = getCurrent(instrument);
				if (currentRates != null)
				{
					var now:Number = new Date().time;
					
					if (now - currentRates.time > updateTimeout)
					{
						loadRates(instrument);
					}
					else
					{
						if (instrument.rates == null || now > instrument.rates.time)
						{
							GD.S_ESCROW_INSTRUMENT_RATES.invoke(instrument.code, currentRates);
						}
					}
				}
				else
				{
					loadLocalRates(instrument);
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function loadLocalRates(instrument:EscrowInstrument):void 
		{
			Store.load(Store.ESCROW_INSTRUMENT_RATES + instrument.code, 
				function(data:Object = null, error:Boolean = false):void
				{
					if (error == true || data == null)
					{
						loadRates(instrument);
					}
					else if (data != null)
					{
						var rates:InvestmentRates = parse(data);
						if (rates != null)
						{
							data[instrument.code] = rates;
							GD.S_ESCROW_INSTRUMENT_RATES.invoke(instrument.code, rates);
						}
						else
						{
							ApplicationErrors.add();
						}
					}
				});
		}
		
		private function parse(ratesRaw:Object):InvestmentRates
		{
			var result:InvestmentRates;
			if (ratesRaw != null && "instrument" in ratesRaw && ratesRaw.instrument != null &&
				"data" in ratesRaw && ratesRaw.data != null &&
				"currency" in ratesRaw && ratesRaw.currency != null)
			{
				result = new InvestmentRates();
				result.currency = ratesRaw.currency;
				result.instrument = ratesRaw.instrument;
				if (ratesRaw.data is Array)
				{
					var l:int = (ratesRaw.data as Array).length;
					var ticks:Vector.<RateTick> = new Vector.<RateTick>();
					var maxTick:Number = 0;
					var minTick:Number = 1000000000;
					var tick:RateTick;
					for (var i:int = 0; i < l; i++) 
					{
						tick = new RateTick(ratesRaw.data[i])
						ticks.push(tick);
						if (tick.val > maxTick)
						{
							maxTick = tick.val;
						}
						if (tick.val < minTick)
						{
							minTick = tick.val;
						}
					}
					result.max = maxTick;
					result.min = minTick;
				}
				result.data = ticks;
				
			}
			return result;
		}
		
		private function loadRates(instrument:EscrowInstrument):void 
		{
 			PayManager.callGetInstrumentRatesHistory(instrument.code, 
				function(respond:PayRespond):void
				{
					if (respond.error)
					{
						//!TODO:;
					}
					else
					{
						var rates:InvestmentRates = parse(respond.data);
						data[rates.instrument] = rates;
						rates.time = new Date().time;
						GD.S_ESCROW_INSTRUMENT_RATES.invoke(rates.instrument, rates);
						Store.save(Store.ESCROW_INSTRUMENT_RATES + rates.instrument, rates);
					}
				});
		}
		
		private function getCurrent(instrument:EscrowInstrument):InvestmentRates 
		{
			if (instrument != null && data != null)
			{
				return data[instrument.code];
			}
			return null;
		}
	}
}