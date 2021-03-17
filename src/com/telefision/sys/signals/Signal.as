package com.telefision.sys.signals {
	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class Signal {
		
		public static var isDebug:Boolean = false;
		public static var count:int = 0;
		//public static var invoked:Array = [];
		private static var names:Array;
		private static var name:String="static signal";
		
		private var disabled:Boolean = false;
		private var methodStock:Array = [];
		private var delayedAdd:Array=[];
		private var delayedRemove:Array=[];
		private var isInvoking:Boolean=false;
		private var name:String = '';
		private var isTraceSignalInvokation:Boolean = false;
		private var _callBacksCount:int = 0;
		
		public function Signal(name:String = null) {
			if (name != null)
				this.name = name
			if (isDebug) {
				names ||= [];
				count++;
				names.push(name);
			}
		}
		
		public function traceSignalInvokation(val:Boolean = false):void {	
			isTraceSignalInvokation = val;
		}
		
		/**
		 * Add method to signal. will call when invoke
		 * @param	method	Function 
		 * @return	Function added method
		 */
		public function add(method:Function, source:String = 'unknown'):Function {
			if (methodStock == null)
				return method;
			var m:int = methodStock.length;
			var l1:int = m;
			while (m) {
				m--;
				if (methodStock[m] == method)
					return method;
			}
			if(!isInvoking){
				methodStock.push(method);
				_callBacksCount = methodStock.length;
			}else
				delayedAdd.push(method);
			return method;
		}
		
		/**
		 * Remove method from signal
		 * @param	method
		 */
		public function remove(method:Function):void {
			if (methodStock == null)
				return;
			var m:int = methodStock.length;
			var l1:int = m;
			var tmp:Array = [];
			while (m) {
				m--;
				// МЕТОД ВЫПОЛНЯЕТСЯ
				if (isInvoking == true){
					if (method == methodStock[m]) {
						if (delayedRemove != null)
							delayedRemove.push(method);
						methodStock[m] = null;
						//trace('SIGNAL -> '+name+' -> DELAYED REMOVE, delayed: ' +delayedRemove.length );
						return;
					}
				} else {
					// МЕТОД НЕ ВЫПОЛНЯЕТСЯ
					if (methodStock[m]!=null && methodStock[m] != method)
						tmp.push(methodStock[m]);
				}
			}
			if (isInvoking)
				return;
			methodStock = tmp;
			_callBacksCount = methodStock.length;
		}
		
		/**
		 * Makes invoke with anonyms parameters.
		 * @param	...rest	all methods called with this params. if no params, then calling with default params (if is set)
		 */
		public function invoke(...rest):void {
			//invoked.push(name);
			//trace(name + " ==> START");
			//trace(getInvokedString());
			isInvoking = true;
			if (methodStock == null) {
				if (isTraceSignalInvokation)
					trace(name, 'INVOKE - methods stock null');
				//invoked.pop();
				//trace(name + " ==> END");
				return;
			}
			if (disabled) {
				if (isTraceSignalInvokation)
					trace(name, 'INVOKE - disabled');
				//invoked.pop();
				//trace(name + " ==> END");
				return;
			}
			if (isTraceSignalInvokation)
				trace(name, 'INVOKE - methods: ' + methodStock.length);
			var l:int = -1;
			var n:int = methodStock.length-1;
			for (n; n > l; n--)
				if (methodStock[n]!=null)
					methodStock[n].apply(this, rest);
			isInvoking = false;
			if (delayedAdd != null && delayedAdd.length > 0){
				n = 0;
				l = delayedAdd.length;
				for (n; n < l; n++)
					add(delayedAdd[n]);
				delayedAdd = [];
			}
			if (delayedRemove != null && delayedRemove.length > 0) {
				n = 0;
				l = delayedRemove.length;
				for (n; n < l; n++)
					remove(delayedRemove[n]);
				delayedRemove = [];
			}
			//invoked.pop();
			//trace(name + " ==> END");
		}
		
		/*private function getInvokedString():String {
			var res:String = "";
			for (var i:int = 0; i < invoked.length; i++) {
				res += invoked[i] + "::";
			}
			return res.substr(0, res.length - 2);
		}*/
		
		/**
		 * Dispose signal.
		 */
		public function dispose():void {
			if (methodStock != null)
				methodStock.length = 0;
			methodStock = null;
			if (delayedAdd != null)
				delayedAdd.length = 0;
			delayedAdd = null;
			if (delayedRemove != null)
				delayedRemove.length = 0;
			delayedRemove = null;
			_callBacksCount = 0;
			if (isDebug == true) {	
				count--;
				if (names != null)
					names.splice(names.indexOf(name), 1);
			}
		}
		
		public function getName():String {
			return name;
		}
		
		/**
		 * Remove all callbacks
		 */
		public function removeAll():void {
			methodStock = [];
			_callBacksCount = 0;
		}
		
		/**
		 * Disable signal works
		 * @param	val Boolean: true - means disabled, false - means enabled
		 */
		public function disable(val:Boolean):void {
			disabled = val;
		}
		
		static public function showNames():void {
			if (!isDebug)
				return;
			for (var n:int = 0; n < names.length; n++) {
				trace(names[n]);
			}
		}
		
		
		
		public function get callBacksCount():int {
			return  _callBacksCount;
		}
	}
}