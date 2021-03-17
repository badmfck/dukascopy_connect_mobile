package com.dukascopy.connect.sys.workers 
{
	import com.dukascopy.connect.sys.workers.events.WorkerEvent;
	import flash.concurrent.Condition;
	import flash.concurrent.Mutex;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class WorkerBridge extends EventDispatcher
	{
		protected var condition:Condition;
		protected var conditionMutex:Mutex;
		protected var _ready:Boolean;
		protected var channelToMain:MessageChannel;
		protected var channelToWorker:MessageChannel;
		protected var sharedByteArray:ByteArray;
		
		protected var worker:Worker;
		
		public function WorkerBridge() 
		{
			
		}
		
		protected function setWorker(worker:Worker):void 
		{
			conditionMutex = new Mutex();
		//	conditionMutex.lock();
			condition = new Condition(conditionMutex);
			
			this.worker = worker;
			if (worker) {
				worker.addEventListener(Event.WORKER_STATE, onWorkerState);
				//Create shared message channels
				channelToMain = worker.createMessageChannel(Worker.current);
				channelToMain.addEventListener(Event.CHANNEL_MESSAGE, onMessageFromWorker);
			 
				channelToWorker  = Worker.current.createMessageChannel(worker);
			 
				worker.setSharedProperty("channelToMain", channelToMain);
				worker.setSharedProperty("channelToWorker", channelToWorker);
			 
				//Create shareable byteArray
				sharedByteArray = new ByteArray();
				sharedByteArray.shareable = true;
				worker.setSharedProperty("sharedByteAttay", sharedByteArray);
				worker.setSharedProperty("condition", condition);
				
				worker.start();
			}
			else {
				dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_READY));
			}
		}
		
		protected function onMessageFromWorker(event:Event):void {
			
		}
		
		protected function onWorkerState(e:Event):void 
		{
			if (worker.state == WorkerState.RUNNING)
			{
				_ready = true;
				onWorkerReady();
			}
		}
		
		protected function onWorkerReady():void 
		{
			dispatchEvent(new WorkerEvent(WorkerEvent.WORKER_READY));
		}
		
		public function isReady():Boolean 
		{
			return _ready;
		}
	}
}