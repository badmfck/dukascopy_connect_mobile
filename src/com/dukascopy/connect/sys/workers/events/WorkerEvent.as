package com.dukascopy.connect.sys.workers.events 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class WorkerEvent extends Event
	{
		static public const WORKER_READY:String = "workerReady";
		static public const ALL_WORKERS_READY:String = "workersReady";
		
		public function WorkerEvent(type:String) 
		{
			super(type);
		}
	}
}