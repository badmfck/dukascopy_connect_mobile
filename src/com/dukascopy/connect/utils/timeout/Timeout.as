package com.dukascopy.connect.utils.timeout 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Timeout 
	{
		private var callback:Function;
		static private var timeouts:Array;
		public var instance:uint;
		private static var id:uint;
		static private var count:uint = 0;
		private var registered:Boolean;
		private var startTime:int;
		private var time:Number;
		
		public function Timeout() 
		{
			id++;
			instance = id;
		}
		
		public function add(time:Number, callback:Function):void
		{
		//	trace("----    add");
			this.time = time;
			this.callback = callback;
			startTime = getTimer();
			if (registered == false)
			{
				register(this);
				registered = true;
			}
		}
		
		public function dispose():void
		{
			callback = null;
			unregister(this);
			registered = false;
		}
		
		private function update(newTime:int):void 
		{
		//	trace("----u", (newTime - startTime) / 1000 , time);
			var timeGone:Number = newTime - startTime;
			if (timeGone < 0)
			{
				ApplicationErrors.add();
				dispose();
			}
			else if (timeGone / 1000 >= time)
			{
				execute();
			}
		}
		
		private function execute():void 
		{
		//	trace("---------execute");
			if (callback != null)
			{
				callback();
			}
			dispose();
		}
		
		public static function register(timeout:Timeout):void 
		{
			if (timeouts == null)
			{
				timeouts = new Array();
			}
			timeouts[timeout.instance] = timeout;
			
			if (count == 0)
			{
				startListenEnterFrame();
			}
			count ++;
		}
		
		static private function startListenEnterFrame():void 
		{
		//	trace("----------------------startListenEnterFrame");
			if (MobileGui.stage != null)
			{
				MobileGui.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		static private function onEnterFrame(e:Event):void 
		{
			if (timeouts != null)
			{
				for each (var item:Timeout in timeouts) 
				{
					item.update(getTimer());
				}
			}
		}
		
		public static function unregister(timeout:Timeout):void 
		{
			if (timeouts == null)
			{
				ApplicationErrors.add();
			}
			else
			{
				timeouts[timeout.instance] = null;
				delete timeouts[timeout.instance];
				count --;
				
				if (count == 0)
				{
					stopListenEnterFrame();
				}
				else if (count < 0)
				{
					ApplicationErrors.add();
				}
			}
		}
		
		public function stop():void 
		{
			dispose();
		}
		
		static private function stopListenEnterFrame():void 
		{
		//	trace("----------------------stopListenEnterFrame");
			if (MobileGui.stage != null)
			{
				MobileGui.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
	}
}