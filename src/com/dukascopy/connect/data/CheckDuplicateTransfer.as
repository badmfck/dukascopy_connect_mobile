package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CheckDuplicateTransfer 
	{
		static private var transfers:Vector.<TransferRequestData>;
		
		public function CheckDuplicateTransfer() 
		{
			
		}
		
		static public function addTransfer(data:Object):Boolean 
		{
			if (data == null)
			{
				return true;
			}
			
			if ("to" in data == false)
			{
				return true;
			}
			
			if (transfers == null)
			{
				transfers = new Vector.<TransferRequestData>();
			}
			
			for (var i:int = 0; i < transfers.length; i++) 
			{
				if (transfers[i].to == data.to)
				{
					if ((new Date()).getTime() - transfers[i].time < 1000*5)
					{
						return false;
					}
				}
			}
			var newRequest:TransferRequestData = new TransferRequestData();
			newRequest.time = (new Date()).getTime();
			newRequest.to = data.to;
			transfers.push(newRequest);
			
			return true;
		}
		
		static public function clear(toUID:String):void 
		{
			if (transfers != null)
			{
				for (var i:int = 0; i < transfers.length; i++) 
				{
					if (transfers[i].to == toUID)
					{
						transfers.removeAt(i);
						return;
					}
				}
			}
		}
	}
}