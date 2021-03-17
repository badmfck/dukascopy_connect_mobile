package com.dukascopy.connect.data.screenAction.customActions
{
	import com.dukascopy.connect.data.screenAction.IUpdatableAction;
	import com.dukascopy.connect.data.screenAction.UpdatebleAction;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TimerAction extends UpdatebleAction implements IUpdatableAction
	{
		private var timer:Timer;
		private var _currentTime:int;
		private var _enable:Boolean;
		
		public function TimerAction()
		{
			setIconClass(null);
		}
		
		public function get currentTime():int 
		{
			return _currentTime;
		}
		
		public function execute():void
		{
			if (getSuccessSignal() != null)
			{
				getSuccessSignal().invoke();
			}
		}
		
		public function setTime(time:int):void
		{
			if (time > 0)
			{
				_enable = false;
				_currentTime = time;
				removeTimer();
				timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER, onTick);
				timer.start();
			}
			else
			{
				_enable = true;
			}
		}
		
		private function removeTimer():void 
		{
			if (timer != null)
			{
				timer.removeEventListener(TimerEvent.TIMER, onTick);
				timer.stop();
				timer = null;
			}
		}
		
		private function onTick(e:TimerEvent):void 
		{
			if (disposed)
			{
				removeTimer();
				return;
			}
			_currentTime -= 1;
			if (_currentTime <= 0)
			{
				_currentTime = 0;
				removeTimer();
				_enable = true;
			}
			if (getUpdateSignal() != null)
			{
				getUpdateSignal().invoke(this);
			}
		}
		
		/* INTERFACE com.dukascopy.connect.data.screenAction.IUpdatableAction */
		
		public function get enable():Boolean 
		{
			return _enable;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}