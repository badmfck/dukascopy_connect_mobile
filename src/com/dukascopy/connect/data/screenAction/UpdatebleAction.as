package com.dukascopy.connect.data.screenAction {
	
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class UpdatebleAction extends ScreenAction {
		
		public var S_UPDATE:Signal = new Signal('UpdatebleAction.S_UPDATE');
		
		public function UpdatebleAction() { }
		
		override public function dispose():void {
			super.dispose();
			if (S_UPDATE != null)
				S_UPDATE.dispose();
			S_UPDATE = null;
		}
		
		public function getUpdateSignal():Signal { return S_UPDATE; }
	}
}