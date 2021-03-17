package com.dukascopy.connect.gui.videoStreaming 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.VideoStatus;
	import flash.net.NetStream;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StageVideoComponent
	{
		private var stage:Stage;
		private var area:Rectangle;
		private var stageVideo:StageVideo;
		private var needAttachCamera:Boolean;
		private var ready:Boolean;
		private var camera:flash.media.Camera;
		public var hided:Boolean;
		
		public function StageVideoComponent(area:Rectangle) 
		{
			this.area = area;
		}
		
		public function start(stage:Stage):void
		{
			if (stage == null)
			{
				ApplicationErrors.add();
				return;
			}
			this.stage = stage;
			
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
		}
		
		public function displayFromCamera():void 
		{
			needAttachCamera = true;
			checkPendingTask();
		}
		
		public function close():void 
		{
			if (stage != null)
			{
				stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
			}
			if (stageVideo)
			{
				stageVideo.attachCamera(null);
				camera = null;
				stageVideo.removeEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange)
				stageVideo = null;
			}
		}
		
		public function cutDown():void 
		{
			/*if (stageVideo != null)
			{
				stageVideo.attachCamera(null);
			}
			else
			{
				ApplicationErrors.add();
			}*/
		}
		
		public function resume():void 
		{
			/*if (stageVideo != null && camera != null)
			{
				stageVideo.attachCamera(camera);
			}
			else
			{
				ApplicationErrors.add();
			}*/
		}
		
		public function display(ns:NetStream):void 
		{
			if (ns != null)
			{
				
			}
			else
			{
				displayFromCamera();
			}
		}
		
		public function setPosition():void 
		{
			
		}
		
		public function hide():void 
		{
			hided = true;
			if (stageVideo != null)
			{
				stageVideo.attachCamera(null);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function show():void 
		{
			hided = false;
			if (stageVideo != null && camera != null)
			{
				stageVideo.attachCamera(camera);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onStageVideoState(event:StageVideoAvailabilityEvent):void 
		{
			var available:Boolean = (event.availability == StageVideoAvailability.AVAILABLE);
			
			if (available)
			{
				process();
			}
			else
			{
				if (stage != null)
				{
				//	stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
				}
				ApplicationErrors.add();
			}
		}
		
		private function process():void 
		{
			if (stage == null)
			{
				return;
			}
			
			var v:Vector.<StageVideo> = stage.stageVideos;
			if (v.length >= 1)
			{
				stageVideo = v[0];
				stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange);
				
				ready = true;
				checkPendingTask();
			}
		}
		
		private function checkPendingTask():void 
		{
			if (ready == true)
			{
				if (needAttachCamera == true)
				{
					needAttachCamera = false;
					if(Camera.isSupported){
						camera = Camera.getCamera();
						camera.setMode(area.width, area.height, 15);
						var resultArea:Rectangle = new Rectangle();
						var k:Number = Math.max(area.width / camera.width, area.height / camera.height);
						
						resultArea.x = area.x;
						resultArea.y = area.y;
						resultArea.height = int(camera.height * k);
						resultArea.width = int(camera.width * k);
						stageVideo.viewPort = resultArea;
						stageVideo.attachCamera(camera);
					}
				}
			}
			
		}
		
		private function stageVideoStateChange(event:StageVideoEvent):void
		{
			var status:String = event.status;
			if (status == VideoStatus.UNAVAILABLE || status == VideoStatus.SOFTWARE)
            {
				
            }
		}
	}
}