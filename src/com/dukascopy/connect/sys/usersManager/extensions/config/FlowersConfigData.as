package com.dukascopy.connect.sys.usersManager.extensions.config 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.usersManager.extensions.FlowerData;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FlowersConfigData 
	{
		private var data:Dictionary;
		
		public function FlowersConfigData() 
		{
			data = new Dictionary();
		}
		
		public function addFlower(flowerData:FlowerData):void 
		{
			if (flowerData != null)
			{
				data[flowerData.id] = flowerData;
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function getFlower(productId:int):FlowerData 
		{
			return data[productId];
		}
	}
}