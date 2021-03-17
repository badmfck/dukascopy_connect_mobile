package com.dukascopy.connect.data.screenAction {
	
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BaseAction {
		
		public var S_ACTION_SUCCESS:Signal = new Signal('BaseAction.S_ACTION_SUCCESS');
		public var S_ACTION_FAIL:Signal = new Signal('BaseAction.S_ACTION_FAIL');
		
		private var iconClass:Class;
		protected var disposed:Boolean;
		protected var data:Object;
		protected var additionalData:Object;
		
		public function BaseAction() { }
		
		public function dispose():void {
			disposed = true;
			data = null;
			additionalData = null;
			if (S_ACTION_SUCCESS)
				S_ACTION_SUCCESS.dispose();
			S_ACTION_SUCCESS = null;
			if (S_ACTION_FAIL)
				S_ACTION_FAIL.dispose();
			S_ACTION_FAIL = null;
		}
		
		public function setData(value:Object):void { data = value; }
		public function getData():Object { return data; }
		
		public function setAdditionalData(value:Object):void { additionalData = value; }
		public function getAdditionalData():Object { return additionalData; }
		
		public function getSuccessSignal():Signal { return S_ACTION_SUCCESS; }
		public function getFailSignal():Signal { return S_ACTION_FAIL; }
	}
}