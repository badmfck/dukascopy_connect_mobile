package com.dukascopy.connect.sys.workers.events 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CustomWorkerEvent extends Event
	{
		public var data:Object;
		static public const FILE_SAVED:String = "fileSaved";
		
		public function CustomWorkerEvent(type:String, data:Object) 
		{
			this.data = data;
			super(type);
		}
		
	}

}