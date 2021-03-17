package com.dukascopy.connect.sys.workers.saveFileWorker 
{
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.localFiles.LocalFilesManager;
	import com.dukascopy.connect.sys.workers.events.CustomWorkerEvent;
	import com.dukascopy.connect.sys.workers.WorkerBridge;
	import com.dukascopy.connect.sys.workers.WorkerMessage;
	import com.dukascopy.langs.Lang;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SaveFilesWorkerBridge extends WorkerBridge
	{
		[Embed(source="../../../../../../../lib/swf/DukascopyConectWorker.swf", mimeType="application/octet-stream")] 
		private static var BgWorker_ByteClass:Class; 
		
		public function SaveFilesWorkerBridge() 
		{
			
		}
		
		override protected function onMessageFromWorker(event:Event):void {
			var msg:String = channelToMain.receive();
			if (msg == WorkerMessage.MESSAGE) 
			{
				parseInputMessage();
			}
		}
		
		private function parseInputMessage():void 
		{
			sharedByteArray.position = 0;
			if (sharedByteArray.bytesAvailable > 0)
			{
				try
				{
				//	condition.mutex.lock();
					sharedByteArray.position = 0;
					var messageType:String = sharedByteArray.readUTF();
					
					if (messageType == WorkerMessage.FILE_SAVED)
					{
						var fileId:String = sharedByteArray.readUTF();
						var error:Boolean = sharedByteArray.readBoolean();
						dispatchEvent(new CustomWorkerEvent(CustomWorkerEvent.FILE_SAVED, {fileId:fileId, error:error}));
					}
					var length:uint = sharedByteArray.bytesAvailable;
					sharedByteArray.readBytes(sharedByteArray, 0, length);
					sharedByteArray.length = length;
					sharedByteArray.position = 0;
					
			//		condition.notify();
			//		condition.mutex.unlock();
					
					if (sharedByteArray.bytesAvailable > 0)
					{
						parseInputMessage();
					}
				}
				catch (e:Error)
				{
					sharedByteArray.clear();
			//		condition.notify();
			//		condition.mutex.unlock();
				}
			}
		}
		
		override protected function onWorkerReady():void 
		{
			sharedByteArray.writeUTF(WorkerMessage.SET_WORKING_DIRECTORY);
			sharedByteArray.writeUTF(LocalFilesManager.storeDirectory);
			channelToWorker.send(WorkerMessage.MESSAGE);
			
			super.onWorkerReady();
		}
		
		public function start():void 
		{
			var workerBytes:ByteArray = new BgWorker_ByteClass(); 
			var bgWorker:Worker = WorkerDomain.current.createWorker(workerBytes, true);
			
			setWorker(bgWorker);
		}
		
		public function saveFile(fileName:String, data:ByteArray, fileId:String):void 
		{
			if (worker)
			{
				//	condition.mutex.lock();
				data.position = 0;
				sharedByteArray.writeUTF(WorkerMessage.SAVE_FILE);
				sharedByteArray.writeUTF(fileName);
				sharedByteArray.writeUTF(fileId);
				sharedByteArray.writeBytes(data);
			//	condition.notify();
			//	condition.mutex.unlock();
				channelToWorker.send(WorkerMessage.MESSAGE);
			}
			else {
				DialogManager.alert(Lang.textWarning, Lang.unsupportedOnDevice, 
					function(val:int):void
					{
						
					});
			}
		}
	}
}