package com.dukascopy.connect.sys.viManager.actions {
	
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenURLAction implements IBotAction {
		
		private var action:VIAction;
		private var onSuccess:Function;
		private var onFail:Function;
		
		public function OpenURLAction(action:VIAction) {
			this.action = action;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void {
			this.onSuccess = onSuccess;
			this.onFail = onFail;
			
			if (action.data != null)
				navigateToURL(new URLRequest(action.data as String));
			
			if (onSuccess != null)
				onSuccess(this);
		}
		
		public function getResult():Vector.<ImageBitmapData> {
			return null;
		}
		
		public function getAction():VIAction {
			return action;
		}
		
		public function dispose():void {
			action = null;
			onSuccess = null;
			onFail = null;
		}
		
		
		/* INTERFACE com.dukascopy.connect.sys.viManager.actions.IBotAction */
		
		public function getData():String 
		{
			return null;
		}
	}
}