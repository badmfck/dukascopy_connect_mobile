package com.dukascopy.connect.sys.categories {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * Manager to store categories 
	 * @author Alexey Skuryat
	 */
	
	public class CategoryManager 
	{
		public  static var S_CATEGORIES_LOADED:Signal = new Signal("CategoryManager.S_CATEGORIES_LOADED"); // todo move to init and create only when needed
		private static var categoriesArray:Array = [];
		private static var categoriesLoaded:Boolean = false;		
		private static var _isInited:Boolean = false;
		private static var _filter:String = "";
		private static var _categoriesDataProvider:Vector.<SelectorItemData> = null;
		private static var _filterString:String = "";
		private static var _filteredArray:Vector.<SelectorItemData> = new Vector.<SelectorItemData>;
		private static var _filteredLangsArray:Vector.<SelectorItemData> = new Vector.<SelectorItemData>;
		private static var needDisclaimer:Boolean = false;
		
		public function CategoryManager() {
				
		}
		public static function init():void	{	
			if (_isInited) return;
			_isInited = true;		
			loadAllCategories();
			
			Auth.S_NEED_AUTHORIZATION.add(clear);
		}
		
		static private function clear():void {
			needDisclaimer = false;
		}
		
		
		public static function loadAllCategories():void	{
			categoriesLoaded = false;
			PHP.search_category(onCategoriesLoaded, "");
		}
		
		private static function onCategoriesLoaded(respond:PHPRespond):void	{
			categoriesLoaded = true;
			if (respond.error) {
				S_CATEGORIES_LOADED.invoke();
				return;
			}
			// handle error
			categoriesArray = respond.data as Array;
			// update categories data here?
			
			if (_categoriesDataProvider == null) {
				_categoriesDataProvider = new Vector.<SelectorItemData>;
			}
			_categoriesDataProvider.length = 0;
			if (categoriesArray != null) {
				var l:int = categoriesArray.length;
				if (l> 0)
					for (var i:int = 0; i < categoriesArray.length; i++)
						_categoriesDataProvider.push(new SelectorItemData("", categoriesArray[i]));
			}
			S_CATEGORIES_LOADED.invoke();			
		}	
		
		public static function getCategoriesData():Vector.<SelectorItemData>{
			if (_categoriesDataProvider == null){
				_categoriesDataProvider = new Vector.<SelectorItemData>;
			}
			_categoriesDataProvider.length = 0;
			var l:int = categoriesArray.length;
			if (l> 0){
				for (var i:int = 0; i < l; i++) {					
					_categoriesDataProvider.push(new SelectorItemData("", categoriesArray[i])); // todo create reusable Data
				}				
			}			
			return _categoriesDataProvider;
		}
		
		public static function setFilter(value:String):void	{
			_filterString = value;
			S_CATEGORIES_LOADED.invoke(); // TODO USe another signal 			
		}
		
		public static function getCategoriesArrayFiltered():Vector.<SelectorItemData>{
			_filteredArray.length = 0;					
			if(_categoriesDataProvider !=null){
				for (var i:int = 0; i < _categoriesDataProvider.length; i++) {
					var item:SelectorItemData = _categoriesDataProvider[i];
					if (item == null) continue;
					if (item.data.name == null) continue;
					if (item.data.name.toLowerCase().indexOf(_filterString.toLocaleLowerCase()) != -1){
						_filteredArray.push(item);
					}
				}					
			}
			return _filteredArray;
		}
		
		public static function getLanguagesArrayFiltered():Vector.<SelectorItemData>{
			if(_filteredLangsArray.length==0){
				var item:SelectorItemData = new SelectorItemData("lang", {name:"Русский", total:0});
				_filteredLangsArray.push(item);		
				 item = new SelectorItemData("lang", {name:"Deutsch" , total:0});
				_filteredLangsArray.push(item);
				item = new SelectorItemData("lang", {name:"English" , total:0});
				_filteredLangsArray.push(item);		
				item = new SelectorItemData("lang", {name:"Español" , total:0});
				_filteredLangsArray.push(item);		
			}
			return _filteredLangsArray;
		}
		
		
		public static function getCategoriesArray():Array	{
			return categoriesArray;
		}
		
		
		static public function getCategoriesLoaded():Boolean {
			return categoriesLoaded;
		}
		
		static public function getNeedDisclaimer(callback:Function):void {
			if (callback == null)
				return;
			if (needDisclaimer == true) {
				callback(true, false);
				return;
			}
			Store.load(Store.CATEGORY_NEED_DISCLAIMER, callback);
		}
		
		static public function setNeedDisclaimer():void {
			PHP.info_saveLog(null, "datingDisclaimer", "agree", Config.VERSION, "mobile");
			needDisclaimer = true;
			Store.save(Store.CATEGORY_NEED_DISCLAIMER, true);
		}
		
		static public function getCategoriesByID(categories:Array):Vector.<SelectorItemData> {
			if (categories == null || categories.length == 0)
				return null;
			if (_categoriesDataProvider == null || _categoriesDataProvider.length == 0) {
				loadAllCategories();
				return null;
			}
			var res:Vector.<SelectorItemData>;
			for (var i:int = 0; i < _categoriesDataProvider.length; i++) {
				if (_categoriesDataProvider[i].data.id == categories[0]) {
					res ||= new Vector.<SelectorItemData>;
					res.push(_categoriesDataProvider[i]);
					return res;
				}
			}
			return null;
		}
	}
}