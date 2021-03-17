package com.telefision.sys.injector {
	import com.telefision.sys.signals.Signal;
	import flash.utils.describeType;

	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class Injector {
		private static var stock:Vector.<InjectorItem> = new Vector.<InjectorItem>();
		public static const S_ADD_INJECTION:Signal = new Signal("Injector.S_ADD_INJECTION");
		
		private static var classesNames:Array = [];
		
		/**
		 * Add some class instance to injector
		 * @param	itm	some class instance;
		 * @return	added instance;
		 */
		public static function add(itm:*):*{
			var m:int = stock.length;
			var exists:Boolean = false;
			var ii:InjectorItem = new InjectorItem(itm);
			while (m) {
				m--;
				if (stock[m].getClassName()==ii.getClassName()){
					exists = true;
					break;
				}
			}
			if(exists){
				trace(' INJECTOR -> ERROR! -> Class ' + itm + ' already added to pool');
				return itm;
			}
			stock.push(ii);
			S_ADD_INJECTION.invoke(itm);
			return itm;
		}
		
		/**
		 * Get instance form injector by its class
		 * @param	cls Class of needed instance
		 * @return	an class instance
		 */
		public static function grab(cls:Class):*{
			var name:String;
			var n:int = 0;
			n = classesNames.length;
			while(n--){
				if (classesNames[n][0] == cls)
					name = classesNames[n][1];
			}
			
			if (name == null) {
				name = (describeType(cls).toString().match(/\sname=\"(.*?)\"\s/))[1];
				classesNames.push([cls, name]);
			}
			
			
			n = stock.length;
			while (n--) {
				if (stock[n].getClassName()==name)
					return stock[n].getTargetInstance();
			}
			return null;
		}
		
		/**
		 * call initInjection() method (if exists) in all instances.
		 */
		public static function initializeInjections():void {
			for (var n:int = 0; n < stock.length;n++){
				try {
					if(!stock[n].wasInitialized){
						stock[n].getTargetInstance().initInjection();
						stock[n].wasInitialized = true;
					}else {
						trace(' Injector -> INFO -> ' + stock[n].getTargetInstance()+' was initialized');
					}
				}catch (e:Error) {
					if(e.errorID==1069)
						trace(' Injector -> WARNING -> no initInjection() method in: ' + stock[n].getTargetInstance());
							else trace(e.getStackTrace());
				}
			}
		}
		
	}

}