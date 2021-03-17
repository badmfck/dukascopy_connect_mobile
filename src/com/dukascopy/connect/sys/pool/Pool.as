package com.dukascopy.connect.sys.pool{
	
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class Pool{
		
		static private var stocks:Array = [];
		
		public function Pool(){}
		
		static public function getItem(itemClass:Class):IPoolItem {
			var item:IPoolItem;
			var m:int = stocks.length;
			var itemsStock:Array = null;
			
			// FIND STOCK
			while (m--) {
				var i:Array = stocks[m];
				if (i[0] == itemClass) {
					itemsStock = i[1];
					break;
				}
			}
						
			
			// CREATE NEW, ADD TO STOCK, RETURN
			if (itemsStock == null) {
				item = new itemClass();
				item.inUse = true;
				itemsStock = [item];
				stocks.push([itemClass, itemsStock]);
				return item;
			}
			
			
			// FIND UNBUSY, RETURN OR CREATE AND RETURN
			m = itemsStock.length;
			while (m--) {
				item = itemsStock[m];
				if (item.inUse == false) {
					item.inUse = true;
					return item;
				}
			}
			item = new itemClass();
			itemsStock.push(item);
			item.inUse = true;
			return item;
			
		}
	}
}