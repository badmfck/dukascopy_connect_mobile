package com.dukascopy.connect.vo{
	/**
	 * @author Igor Bloom
	 */
	public class CamSettingVO{
		public var quality:String;
		
		public var cameraWidth:int;
		public var cameraHeight:int;
		public var cameraFps:int;
		public var cameraBandwidth:int;
		public var cameraQuality:int;
		public var cameraKeyframeInterval:int;
		
		public function CamSettingVO(quality:String, cameraWidth:int, cameraHeight:int, cameraFps:int, cameraBandwidth:int, cameraQuality:int, cameraKeyframeInterval:int){
			this.quality = quality;
			this.cameraKeyframeInterval = cameraKeyframeInterval;
			this.cameraQuality = cameraQuality;
			this.cameraBandwidth = cameraBandwidth;
			this.cameraHeight = cameraHeight;
			this.cameraWidth = cameraWidth;
			this.cameraFps = cameraFps;
			
		}
		
		public function toString():String{
			return 'quality:'+quality + ', cameraWidth:' + cameraWidth + ', cameraHeight:' + cameraHeight + ', cameraFps:' + cameraFps + ', cameraBandwidth:' + cameraBandwidth +', cameraQuality:'+cameraQuality+', cameraKeyframeInterval:'+cameraKeyframeInterval;
		}
		
	}

}