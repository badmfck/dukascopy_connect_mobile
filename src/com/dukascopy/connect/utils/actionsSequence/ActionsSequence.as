package com.dukascopy.connect.utils.actionsSequence 
{
	import com.dukascopy.connect.data.screenAction.IAction;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ActionsSequence
	{
		private var actions:Array;
		
		private var onSuccess:Function;
		private var onFail:Function;
		private var currentAction:IAction;
		
		public function ActionsSequence(onSuccess:Function, onFail:Function) 
		{
			actions = new Array();
			this.onSuccess = onSuccess;
			this.onFail = onFail;
		}
		
		public function addAction(action:IAction):void
		{
			actions.push(action);
		}
		
		public function execute():void
		{
			processNextAction();
		}
		
		private function processNextAction(data:Object = null):void 
		{
			if (actions && actions.length > 0)
			{
				currentAction = actions.shift();
				currentAction.getSuccessSignal().add(onActionSuccess);
				currentAction.getFailSignal().add(onActionFail);
				if (data)
				{
					currentAction.setData(data);
				}
				currentAction.execute();
			}
			else
			{
			//	clearActions();
				if (onSuccess)
				{
					if (onSuccess.length == 1)
					{
						onSuccess(data);
					}
					else
					{
						onSuccess();
					}
				}
			}
		}
		
		private function onActionFail(data:Object = null):void 
		{
			clearCurrentAction();
			clearActions();
			
			if (onFail)
			{
				onFail(data);
			}
		}
		
		private function clearActions():void 
		{
			if (actions)
			{
				for (var i:int = 0; i < actions.length; i++) 
				{
					(actions[i] as IAction).dispose();
				}
				actions = null;
			}
		}
		
		private function clearCurrentAction():void 
		{
			if (currentAction)
			{
				currentAction.getSuccessSignal().remove(onActionSuccess);
				currentAction.getFailSignal().remove(onActionFail);
				currentAction.dispose();
				currentAction = null;
			}
		}
		
		private function onActionSuccess(data:Object = null):void 
		{
			clearCurrentAction();
			processNextAction(data);
		}
		
		public function dispose():void
		{
			clearCurrentAction();
			clearActions();
			
			onFail = null;
			onSuccess = null;
		}
	}
}