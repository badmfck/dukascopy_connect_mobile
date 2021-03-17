package com.dukascopy.connect.sys.debug 
{
	import com.dukascopy.connect.sys.php.PHPRespond;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class Stack 
	{
		static private var stack:Array;
		static private var timer:Timer;
		
		public function Stack() 
		{
			
		}
		
		static public function remove(pHPRespond:PHPRespond):void 
		{
			init();
			var index:int = stack.indexOf(pHPRespond);
			if (index != -1)
			{
				stack.removeAt(index);
			}
		}
		
		static public function add(pHPRespond:PHPRespond):void 
		{
			init();
			stack.push(pHPRespond);
		}
		
		static private function init():void 
		{
			if (stack == null)
			{
				stack = new Array();
				timer = new Timer(5000);
				timer.addEventListener(TimerEvent.TIMER, show);
			//	timer.start();
			}
		}
		
		static private function show(e:TimerEvent):void 
		{
			//trace("-------------OBJECTS:", stack.length);
		}
	}
}