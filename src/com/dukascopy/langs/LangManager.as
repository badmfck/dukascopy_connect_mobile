package com.dukascopy.langs  {
	
	/**
	 * ...
	 * @author Aleksei L
	 */
	
	public class LangManager {
		
		public static var model:LangModel;
		public static var initialized:Boolean = false;
		
		static public function init():void {
			if (initialized == true)
				return;
			initialized = true;
			
			model = new LangModel();
			model.init();
		}
		
		/**
		 *
		 * @param id - name lang // en, ru,...
		 */
		static public function selectLangByIndex(id:int, callback:Function):void {
			if (initialized == true) {
				model.selectLangByIndex(id, callback);
			} else {
				if (callback != null) {
					callback();
				}
			}
		}
		
		/**
		 *
		 * @return
		 */
		static public function getAvailableLanguages():Array {
			if (initialized == true) {
				return model.getAvailableLanguages();
			} else {
				return null;
			}
		}
		
		/**
		 *
		 * @param regExt
		 * @param txt
		 * @param valueToReplace
		 * @return
		 */
		public static function replace(regExt:RegExp, txt:String, valueToReplace:String):String {
			return txt.replace(regExt, valueToReplace);
		}
		
		public static function eachFirstCharToUpperCase(txt:String):String {
			var arr:Array = txt.split(" ");
			var strResult:String = "";
			for (var i:int = 0; i < arr.length; i++) {
				var str:String = arr[i];
				str = str.slice(0, 1).toUpperCase() + str.slice(1, str.length).toLowerCase();
				if (strResult != "") {
					strResult = strResult + " " + str;
				} else {
					strResult = str;
				}
			}
			return strResult;
		}
	}
}