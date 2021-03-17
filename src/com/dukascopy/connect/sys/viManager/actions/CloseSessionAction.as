package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CloseSessionAction implements IBotAction
	{
		private var targetScreen:BaseScreen;
		private var action:VIAction;
		private var onSuccess:Function;
		private var onFail:Function;
		
		public function CloseSessionAction(action:VIAction, targetScreen:BaseScreen) 
		{
			this.targetScreen = targetScreen;
			this.action = action;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void 
		{
			this.onSuccess = onSuccess;
			this.onFail = onFail;
			
			if (targetScreen != null)
			{
				targetScreen.onBack();
				targetScreen = null;
				
				if (onSuccess != null)
				{
					onSuccess(this);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else
			{
				if (onFail != null)
				{
					onFail(this);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
		}
		
		public function getResult():Vector.<ImageBitmapData> 
		{
			return null;
		}
		
		public function getAction():VIAction 
		{
			return action;
		}
		
		public function dispose():void 
		{
			action = null;
			targetScreen = null;
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