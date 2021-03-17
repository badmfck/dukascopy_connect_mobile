package com.dukascopy.connect.data {
	
	import com.dukascopy.connect.data.screenAction.IAction;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class ButtonActionData {
		
		public var text:String;
		public var action:IAction;
		public var backColor:Number = 0xFFC600;
		public var textColor:Number = 0xFFFFFF;
		public var outlineColor:Number = 0xFFC600;
		
		public function ButtonActionData() {
			
		}
		
		public function dispose():void {
			text = null;
			if (action)
				action.dispose();
			action = null;
		}
	}
}