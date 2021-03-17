package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.applicationShop.parser.OrderDataParser;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TopExtensionsList 
	{
		private var signal:Signal;
		private var loading:Boolean;
		private var data:Array;
		private var lastLoadTime:Number;
		private var updateTimeout:int = 1000*60*10;
		private var dataHash:String;
		private var limit:int;
		
		public function TopExtensionsList(signal:Signal, limit:int = -1) 
		{
			this.signal = signal;
			this.limit = limit;
		}
		
		public function loadData():Array 
		{
			if (loading == false)
			{
				if (data == null)
				{
					loadDataFromStore();
				}
				else
				{
					if (isNaN(lastLoadTime) == true || (new Date()).getTime() - lastLoadTime > updateTimeout && loading == false)
					{
						loadDataFromPHP();
					}
				}
			}
			return data;
		}
		
		public function dispose():void 
		{
			signal = null;
			data = null;
		}
		
		private function onLoadDataFromStore(dataObject:Object, error:Boolean):void {
			if (dataObject != null && dataObject is Array) {
				parseData(dataObject as Array);
				signal.invoke(data);
			}
			
			loadDataFromPHP();
		}
		
		private function loadDataFromPHP():void {
			loading = true;
			if (limit != -1)
			{
				PHP.miss_getActualRound(onDataLoadedFromPHP, dataHash, limit, 1);
			}
			else
			{
				PHP.miss_getActualRound(onDataLoadedFromPHP, dataHash);
			}
		}
		
		private function onDataLoadedFromPHP(respond:PHPRespond):void {
			lastLoadTime = (new Date()).getTime();
			loading = false;
			
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				ToastMessage.display(message);
			}
			else {
				if ("data" in respond && respond.data != null) {
					Store.save(getStoreKey(), respond.data);
					parseData(respond.data as Array);
					signal.invoke(data);
				}
				else {
					signal.invoke(data);
				}
			}
			respond.dispose();
		}
		
		private function getStoreKey():String 
		{
			if(limit == -1)
			{
				return Store.VAR_TOP_CURRENT;
			}
			return Store.VAR_TOP_CURRENT_MISS;
		}
		
		private function parseData(dataArray:Array):void {
			if (data != null) {
				cleanData();
			}
			data = new Array();
			var parser:MissParser = new MissParser();
			var l:int = dataArray.length;
			var extension:MissData;
			for (var i:int = 0; i < l; i++) {
				extension = parser.parse(dataArray[i]);
				if (extension != null) {
					data.push(extension);
				}
			}
			data.sortOn(["rank"], Array.DESCENDING | Array.NUMERIC);
			parser = null;
			var control:MissData = new MissData();
			control.type = MissData.CONTROL_BACK;
			data.unshift(control);
		}
		
		private function cleanData():void {
			if (data != null)	{
				var l:int = data.length;
				for (var i:int = 0; i < l; i++) {
					(data[i] as MissData).dispose();
				}
			}
		}
		
		private function loadDataFromStore():void {
			loading = true;
			Store.load(getStoreKey(), onLoadDataFromStore);
		}
	}
}