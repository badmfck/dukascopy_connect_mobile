package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TransactionData 
	{
		public var expire:Number = 0;
		public var currency:String = "";
		public var amount:Number = 0;
		
		public function TransactionData(data:Object) 
		{
			if (data != null)
			{
				if ("ccy" in data)
				{
					currency = data.ccy;
				}
				if ("expiration_timestamp" in data)
				{
					expire = data.expiration_timestamp;
				}
				if ("amount" in data)
				{
					amount = data.amount;
				}
			}
		}
	}
}