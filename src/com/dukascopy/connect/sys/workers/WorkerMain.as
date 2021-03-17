package com.dukascopy.connect.sys.workers 
{
	import com.dukascopy.connect.sys.workers.events.CustomWorkerEvent;
	import com.dukascopy.connect.sys.workers.events.WorkerEvent;
	import com.dukascopy.connect.sys.workers.saveFileWorker.SaveFilesWorkerBridge;
	import com.telefision.sys.signals.Signal;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class WorkerMain extends EventDispatcher
	{
		static private var instance:WorkerMain;
	//	private var saveFilesWorkerBridge:SaveFilesWorkerBridge;
		private var workersNum:Number;
		private var currentWorkersReady:Number;
		
		public static var S_FILE_SAVE_RESULT:Signal = new Signal("WorkerMain.S_FILE_SAVE_RESULT");
		
		public function WorkerMain() 
		{
			workersNum = 1;
			currentWorkersReady = 0;
		}
		
		public static function getInstance():WorkerMain
		{
			if (!instance)
			{
				instance = new WorkerMain();
			}
			return instance;
		}
		
		public static function init():void
		{
			getInstance().init();
		}
		
		static public function isReady():Boolean 
		{
			return getInstance().isReady();
		}
		
		static public function saveFile(fileName:String, data:ByteArray, fileId:String):void 
		{
			/*if (getInstance().saveFilesWorkerBridge)
			{
				getInstance().saveFilesWorkerBridge.saveFile(fileName, data, fileId);
			}*/
		}
		
		public function isReady():Boolean
		{
			//if (!saveFilesWorkerBridge)
			//{
				//return false;
			//}
			//return saveFilesWorkerBridge.isReady();
			return false;
		}
		
		private function init():void 
		{
			//saveFilesWorkerBridge = new SaveFilesWorkerBridge();
			//saveFilesWorkerBridge.addEventListener(WorkerEvent.WORKER_READY, onWorkerReady);
			//saveFilesWorkerBridge.addEventListener(CustomWorkerEvent.FILE_SAVED, onFileSaved);
			//saveFilesWorkerBridge.start();
		}
		
		private function onFileSaved(e:CustomWorkerEvent):void 
		{
			S_FILE_SAVE_RESULT.invoke(e.data.fileId, e.data.error);
		}
		
		private function onWorkerReady(e:WorkerEvent):void 
		{
			(e.target as WorkerBridge).removeEventListener(WorkerEvent.WORKER_READY, onWorkerReady);
			currentWorkersReady++;
			if (currentWorkersReady == workersNum)
			{
				dispatchEvent(new WorkerEvent(WorkerEvent.ALL_WORKERS_READY));
			}
		}
	}
}