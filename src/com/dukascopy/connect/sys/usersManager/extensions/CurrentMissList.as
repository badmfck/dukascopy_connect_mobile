package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.auth.Auth;
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
	public class CurrentMissList 
	{
		private var signal:Signal;
		private var loading:Boolean;
		private var data:Array;
		private var lastLoadTime:Number;
		private var updateTimeout:int = 1000*60*1;
		private var dataHash:String;
		
		public function CurrentMissList(signal:Signal) 
		{
			this.signal = signal;
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
			if (dataObject != null) {
				parseData(dataObject);
				signal.invoke(data);
			}
			
			loadDataFromPHP();
		}
		
		private function loadDataFromPHP():void {
			loading = true;
			PHP.miss_getReview(onDataLoadedFromPHP, dataHash);
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
					Store.save(Store.VAR_TOP_MISS, respond.data);
					parseData(respond.data);
					signal.invoke(data);
				}
				else {
					signal.invoke(data);
				}
			}
			respond.dispose();
		}
		
		private function parseData(dataArray:Object):void {
			if (data != null) {
				cleanData();
			}
			data = new Array();
			
			var parser:MissParser = new MissParser();
			var l:int;
			var i:int;
			var extension:MissData;
			
			if (dataArray != null && "current" in dataArray && dataArray.current != null && dataArray.current is Array)
			{
				l = dataArray.current.length;
				for (i = 0; i < l; i++) {
					extension = parser.parse(dataArray.current[i]);
					if (extension != null) {
						data.push(extension);
					}
				}
			}
			data.sortOn(["rank"], Array.DESCENDING | Array.NUMERIC);
			
			var control:MissData = new MissData();
			control.type = MissData.CONTROL_EXPAND;
			data.push(control);
			
			if (Auth.bank_phase == "ACC_APPROVED")
			{
				var winners:Array = new Array();
				
				if (dataArray != null && "history" in dataArray && dataArray.history != null && dataArray.history is Array)
				{
					l = dataArray.history.length;
					for (i = 0; i < l; i++) {
						extension = parser.parse(dataArray.history[i]);
						if (extension != null) {
							winners.push(extension);
						}
					}
				}
				
				winners = winners.sort(sortByDate);
				data = data.concat(winners);
			}
			
			parser = null;
		}
		
		private function sortByDate(a:MissData, b:MissData):int {
			if (a.year < b.year)
			{
				return 1;
			}
			if (a.year > b.year)
			{
				return -1;
			}
			else
			{
				if (a.month < b.month)
				{
					return 1;
				}
				if (a.month > b.month)
				{
					return -1;
				}
			}
			return 0;
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
			Store.load(Store.VAR_TOP_MISS, onLoadDataFromStore);
		}
	}
}