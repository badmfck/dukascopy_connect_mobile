package com.telefision.sys.injector {
	import flash.utils.describeType;
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class InjectorItem {
		private var instance:*;
		private var className:String;
		public var wasInitialized:Boolean = false;
		public function InjectorItem(instance:*) {
			this.instance = instance;
			className = (describeType(instance).toString().match(/\sname=\"(.*?)\"\s/))[1];
		}
		
		public function getTargetInstance():*{
			return instance;
		}
		
		public function getClassName():String {
			return className;
		}
	}

}