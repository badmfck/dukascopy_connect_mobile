package com.dukascopy.connect.vo{
	import com.dukascopy.connect.data.RtoAgreementData;
	import com.dukascopy.connect.sys.callManager.CallManager;
	
	/**
	 * @author Igro Bloom
	 */
	public class CallVO{
		
		public var id:String; // уникальный идентификатор звонка
		public var uid:String; // UID адресата
		public var type:String;  // Тип звонка (CallManager.TYPE_INCOME, TYPE_OUTGOING
		public var avatar:String; // URL аватарки пользователя
		public var name:String; // Имя пользователя
		public var mode:String; // режим звонка (CallManager.MODE_AUDIO, MODE_VIDEO)
		public var nearStreamID:String; // ID своего стрима (publish)
		public var farStreamID:String; // ID стрима адресата (play)
		public var broadcastMode:String; // ID стрима адресата (play)
		public var phase:int = 0; // фаза разговора на loudspeaker
		
		public var recognitionState:int = 0;// videorecognition statie, from 0 to N - controlled remotely
		public var videoRecognition:Boolean = false; // if true video recognition in process
		
		public var supporter:Boolean = false;
		
		public var entryPointID:int = 0;
		
		public var loudspeaker:Boolean = false;
		public var cameraIndex:int = 1;
		public var mute:Boolean = false;
		public var broadcasterCameraW:int=0;
		public var broadcasterCameraH:int=0;
		public var broadcasterCameraR:int=0;
		public var documentType:String=null;
		public var remoteIP:String = null;
		public var farEncMic:Boolean = false;
		public var nearEncMic:Boolean = false;
		public var callCount:int = 0;
		
		public var ver:int = 0;
		public var farVer:int = 0;
		public var showAgreement:Boolean = false;
		public var rto:RtoAgreementData;
		
		public function get cleared():Boolean 
		{
			return _cleared;
		}
		
		private var _cleared:Boolean;
		
		public function CallVO() { }
		
		public function clear():void {
			id=null;
			uid=null;
			type=null;
			avatar=null;
			name=null;
			mode=null;
			nearStreamID=null;
			farStreamID = null;
			documentType = null;
			loudspeaker = false;
			remoteIP=null
			mute = false;
			callCount = 0;
			broadcastMode = CallManager.MODE_AUDIO;
			
			broadcasterCameraW = 0;
			broadcasterCameraH = 0;
			broadcasterCameraR = 0;
			entryPointID = 0;
			
			recognitionState = 0;
			videoRecognition = false;
			
			supporter = false;
			
			phase = 0;
			farEncMic = false;
			nearEncMic = false;
			
			_cleared = true;
		}
		
		public function reinit():void
		{
			_cleared = false;
		}
		
		public function toString():String{
			return "id: " + id + ", uid:" + uid + ", type: " +
			type+", mode:" + mode+", nearStreamID:" +
			nearStreamID + ", farStreamID: " + farStreamID + ", loudspeaker:" +
			loudspeaker + ", cameraIndex:" + cameraIndex + ", mute:" + mute+", broadcastMode:" +
			broadcastMode+", broadcasterCameraW:" + broadcasterCameraW + ", broadcasterCameraH:" + broadcasterCameraH +
			", broadcasterCameraR:" + broadcasterCameraR
			+", videoRecognition: " + videoRecognition
			+", recognitionState: " + recognitionState
			+", supporter: "+supporter
			+", documentType: "+documentType
			+", remoteIP: "+remoteIP
			+", entry point ID: "+entryPointID;
		}
		
	}
}