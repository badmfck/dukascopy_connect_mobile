package com.dukascopy.connect.data.coinMarketplace.stat 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StatPointParser 
	{
		
		public function StatPointParser() 
		{
			
		}
		
		public function parse(rawData:Array):StatPointData
		{
			if (isValid(rawData))
			{
				return new StatPointData(rawData[0], rawData[1].key, rawData[1].value);
			}
			else
			{
				ApplicationErrors.add();
			}
			return null;
		}
		
		private function isValid(rawData:Array):Boolean 
		{
			if (rawData == null)
			{
				return false;
			}
			if (rawData.length < 2)
			{
				return false;
			}
			if (rawData[1] == null)
			{
				return false;
			}
			if ("key" in rawData[1] && !isNaN(rawData[1].key) && "value" in rawData[1] && !isNaN(rawData[1].value))
			{
				return true;
			}
			return false;
		}
	}
}