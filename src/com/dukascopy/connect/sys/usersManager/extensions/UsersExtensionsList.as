package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.gui.components.message.ToastMessage;
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
	public class UsersExtensionsList 
	{
		private var signal:Signal;
		private var loading:Boolean;
		private var dataHash:String;
		private var data:Array;
		private var lastLoadTime:Number;
		private var updateTimeout:int = 10000;
		
		public function UsersExtensionsList(signal:Signal) 
		{
			this.signal = signal;
		}
		
		public function loadData():void 
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
					else
					{
						signal.invoke(data);
					}
				}
			}
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
			if (dataHash == null) {
				Store.load(Store.VAR_USERS_EXTENSIONS_HASH, onLoadDataHashFromStore);
			}
			else{
				PHP.gift_getCurrentGifts(onDataLoadedFromPHP, dataHash);
			}
		}
		
		private function onLoadDataHashFromStore(dataObject:Object, error:Boolean):void {
			if (dataObject != null) {
				dataHash = dataObject as String;
			}
			
			PHP.gift_getCurrentGifts(onDataLoadedFromPHP, dataHash);
		}
		
		private function onDataLoadedFromPHP(respond:PHPRespond):void {
			lastLoadTime = (new Date()).getTime();
			loading = false;
			
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				ToastMessage.display(message);
			}
			else {
				if ("data" in respond && respond.data != null && "gifts" in respond.data && respond.data.gifts != null) {
					dataHash = respond.data.hash;
					Store.save(Store.VAR_USERS_EXTENSIONS, respond.data.gifts);
					Store.save(Store.VAR_USERS_EXTENSIONS_HASH, dataHash);
					parseData(respond.data.gifts as Array);
					signal.invoke(data);
				}
				else {
					signal.invoke(data);
				}
			}
			respond.dispose();
		}
		
		private function parseData(dataArray:Array):void {
			if (data != null) {
				cleanData();
			}
			data = new Array();
			
			var parser:ExtensionParser = new ExtensionParser();
			var l:int = dataArray.length;
			var extension:Extension;
			for (var i:int = 0; i < l; i++) {
				extension = parser.parse(dataArray[i]);
				if (extension != null) {
					if (extension.isExpired() == false)
					{
						data.push(extension);
					}
				}
			}
			
			parser = null;
		}
		
		private function cleanData():void {
			if (data != null)	{
				var l:int = data.length;
				for (var i:int = 0; i < l; i++) {
					(data[i] as Extension).dispose();
				}
			}
		}
		
		private function loadDataFromStore():void {
			loading = true;
			Store.load(Store.VAR_USERS_EXTENSIONS, onLoadDataFromStore);
		}
	}
}