package com.dukascopy.connect.sys.usersManager.extensions.config 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.usersManager.extensions.FlowerData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FlowersConfigParser 
	{
		public function FlowersConfigParser() {
			
		}
		
		public function parse(data:Object):FlowersConfigData {
			var result:FlowersConfigData;
			
			if (valid(data)) {
				result = new FlowersConfigData();
				
				var flowerData:FlowerData;
				for (var index:int in data) 
				{
					//TODO: add parser;
					flowerData = new FlowerData();
					flowerData.anon = data[index].anon;
				//	flowerData.currency = data[index].currency;
					flowerData.currency = "DCO";
					flowerData.info = data[index].info;
					flowerData.name = data[index].name;
					flowerData.pricePerDay = data[index].pricePerDay;
					flowerData.id = index;
					result.addFlower(flowerData);
				}
			}
			else {
				ApplicationErrors.add("wrong data format");
			}
			
			return result;
		}
		
		private function valid(data:Object):Boolean {
			var result:Boolean = true;
			
			/*data : Object {
				1 : Object {
					anon : true 
					currency : "EUR" 
					info : null 
					name : "flower gerbera" 
					pricePerDay : 0.2 
				}
				2 : Object {
					anon : true 
					currency : "EUR" 
					info : Array 
					name : "flower chamomille" 
					pricePerDay : 0.1 
				}
				3 : Object {
					anon : true 
					currency : "EUR" 
					info : Array 
					name : "flower rose" 
					pricePerDay : 0.25 
				}
				4 : Object {
					anon : true 
					currency : "EUR" 
					info : Array 
					name : "flower premium" 
					pricePerDay : 0.5 
				}
			}*/
			
			
			
			/*if (data == null) {
				result = false;
			}
			if (data.hasOwnProperty("protect") == false || data.protect == null || (data.protect is Array) == false || (data.protect as Array).length != 2) {
				result = false;
			}
			if (data.hasOwnProperty("remove") == false || data.remove == null || (data.remove is Array) == false || (data.remove as Array).length != 2) {
				result = false;
			}
			if (data.hasOwnProperty("set") == false || data.set == null || (data.set is Array) == false || (data.set as Array).length != 2) {
				result = false;
			}
			if (data.hasOwnProperty("setAsAnon") == false || data.setAsAnon == null || (data.setAsAnon is Array) == false || (data.setAsAnon as Array).length != 2) {
				result = false;
			}*/
			
			return result;
		}
	}
}