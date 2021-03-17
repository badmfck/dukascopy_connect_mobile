package com.dukascopy.connect.sys.callManager{
	
	import assets.JailedIllustrationClip;
	import com.adobe.crypto.MD5;
	import com.adobe.images.PNGEncoder;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.RtoAgreementData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenBankAccountAction;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.screens.call.CallScreen;
	import com.dukascopy.connect.screens.call.TalkScreen;
	import com.dukascopy.connect.screens.call.TalkScreenRecognition;
	import com.dukascopy.connect.screens.call.VideoRecognitionScreen;
	import com.dukascopy.connect.screens.chat.main.VIChatScreen;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.connection.WebRTCChannel;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.deviceManager.DeviceManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.idleManager.IdleManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.netStatus.NetStatus;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.CallVO;
	import com.dukascopy.connect.vo.CamSettingVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.hurlant.util.Base64;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.BitmapData;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetStatusEvent;
	import flash.events.PermissionEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.AudioPlaybackMode;
	import flash.media.Camera;
	import flash.media.CameraPosition;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.SoundMixer;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.permissions.PermissionStatus;
	import flash.utils.Timer;
	import flash.events.AudioOutputChangeEvent;

	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class CallManager {
		
		static private const CALL_VERSION:int = 2;
		
		static public const TYPE_INCOMING:String = "typeIncoming";
		static public const TYPE_OUTGOING:String = "typeOutgoing";
		
		static public const DOCUMENT_TYPE_PASSPORT:String = "docpass";
		static public const DOCUMENT_TYPE_ID:String = "docid";
		
		static public const MODE_AUDIO:String = "modeAudio";
		static public const MODE_VIDEO:String = "modeVideo";
		
		static public const QUALITY_LOW:String = "low";
		static public const QUALITY_MEDIUM:String = "medium";
		static public const QUALITY_HIGH:String = "high";
		static public const QUALITY_FPS:String = "slideshow";
		
		static public const STATUS_PLACED:String = "placed";
		static public const STATUS_START:String = "start";
		static public const STATUS_ACCEPTED:String = "accepted";
		static public const STATUS_REJECTED:String = "rejected";
		static public const STATUS_CANCELED:String = "canceled";
		static public const STATUS_BUSY:String = "busy";
		static public const STATUS_CANCELED_BY_SELF:String = "statusCanceledBySelf";
		
		static public const NO_ANSWER_TIME:int = 45; //SEC
		static public const MODE_SHOW_RTO_AGREEMENT:String = "call_rto";
		
		static public var S_STREAM_READY:Signal = new Signal("CallManager.S_STREAM_READY");
		static public var S_VIDEO_SIZE_CHANGED:Signal = new Signal("CallManager.S_STREAM_READY");
		static public var S_CALLVO_CHANGED:Signal = new Signal("CallManager.S_CALLVO_CHANGED");
		static public var S_CALL_STATUS_CHANGED:Signal = new Signal("CallManager.S_CALL_STATUS_CHANGED");
		static public var S_DEBUG_MIC_VALUES:Signal = new Signal("CallManager.S_DEBUG_MIC_VALUES");
		static public var S_SECURITY_CODE:Signal = new Signal("CallManager.S_SECURITY_CODE");
		static public var S_HANGOUT:Signal = new Signal("CallManager.S_HANGOUT");
		
		static public var clientID:String = "";
		
		static private var totalVideoRecognitionStates:int = 3;
		
		static private var inited:Boolean = false;
		static private var callVO:CallVO;
		
		static private var backScreen:Class;
		static private var backScreenData:Object;
		
		// Network
		static private var nc:NetConnection;
		static private var incomeNS:NetStream;
		static private var outgoingNS:NetStream;
		
		static private var talkScreenShown:Boolean = false;
		
		// Microphone settings
		static private var soundCodec:String = SoundCodec.SPEEX;
		static private var framesPerPacket:int = 2;
		static private var rate:int = 11;
		static private var gain:int = 60;
		static private var encodeQuality:int = 5;
		static private var enhancedMic:Boolean = true;
		static public var camera:Camera=null;
		static public var microphone:Microphone = null;
		static private var microphoneAttached:Boolean;
		static private var microphoneMuted:Boolean;
		
		static private var camsettings:/*CamSettingVO*/Array = [];
		static public var currentCameraQuality:String = QUALITY_MEDIUM;
		
		static private var lastPingTimer:Number = 0;
		static private var pingTimer:Timer=null;
		static private var pingDelay:int=1000 * 10;
		static private var pingTimeout:int = 1000 * 30;
		static private var channel:WebRTCChannel;
		
		public function CallManager() {}
		
		public static function init():void {
			if (inited)
				return;
			
			// OLD LOGIC - DEPRECATED
			/*camsettings.push(new CamSettingVO(QUALITY_LOW, 320, 180, 10, 0, 30, 90)); 
			camsettings.push(new CamSettingVO(QUALITY_HIGH, 480, 270, 20, 0, 90, 60));
			camsettings.push(new CamSettingVO(QUALITY_FPS, 1920, 1080, 10, 0, 95, 10));
			camsettings.push(new CamSettingVO(QUALITY_MEDIUM, 362, 204, 15, 0, 80, 75));*/
			
			// CAMS FOR RECOGNITION
			camsettings.push(new CamSettingVO(QUALITY_LOW, 228, 128, 24, 0, 95, 30)); 
			camsettings.push(new CamSettingVO(QUALITY_HIGH, 640, 360, 14, 0, 95, 30));
			camsettings.push(new CamSettingVO(QUALITY_FPS, 1240, 698, 5, 0, 90, 15));
			camsettings.push(new CamSettingVO(QUALITY_MEDIUM, 362, 204, 20, 0, 95, 30));
			
			// NEW LOGIC! MUST BE ACTIVATED AFTER IOS DEPLOY
			/*camsettings.push(new CamSettingVO(QUALITY_LOW, 240, 135, 10, 0, 75, 90)); 
			camsettings.push(new CamSettingVO(QUALITY_HIGH, 489, 270, 15, 0, 80, 60));
			camsettings.push(new CamSettingVO(QUALITY_FPS, 525, 295, 1, 0, 85, 30));
			camsettings.push(new CamSettingVO(QUALITY_MEDIUM, 362, 204, 15, 0, 80, 75));*/
			
			inited = true;
			
			clientID = MD5.hash(new Date().getTime() + "" + Math.random() * 10000); // unique client ID 
			WSClient.S_BLACK_HOLE.add(onBlackHole);
			WS.S_DISCONNECTED.add(onWSDisconnected);
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
			WSClient.S_RID.add(onRequestID);
			
		}
		
		// MRZ SCANNER LOW QUALITY
		static private function onRequestID(data:Object):void{
			try{
			var camname:String = null;
			if (data != null && "camname" in data)
				camname = data.camname;
			var cm:Camera = Camera.getCamera(camname);
			
			if(cm==null){
				WSClient.call_blackHole([data.sender],"rid_back",
							{
								err:"true",
								cams:Camera.names,
								bts:"no camera"
							}
						);
						
				return;
			}
			
			if("mode" in data && data.mode!=null){
				if("w" in data.mode && "h" in data.mode && "fps" in data.mode){
					cm.setMode(data.mode.w, data.mode.h, data.mode.fps);
				}
			}
			
			var video:Video = new Video();
			video.width = 1;
			video.height = 1;
			video.x =-100;
			video.y =-100;
			video.visible = false;
			var m:int = 255;
			var enterFrame:Function = function(e:Event):void{

				if (m <= 0 || video.videoWidth > 0){
					var vw:int = video.videoWidth;
					var vh:int = video.videoHeight;
					if(vw>0 && vh>0){
						var bmp:BitmapData = new BitmapData(vw,vh, false);
						bmp.draw(video);
						video.attachCamera(null);
						video.parent.removeChild(video);
						
						var err:Boolean = false;
						var bts:String = "";
						try{
							bts = Base64.encodeByteArray(PNGEncoder.encode(bmp));
						}catch(e:Error){
							bts = e.message;
						}
						WSClient.call_blackHole([data.sender],"rid_back",
							{
								err:err,
								cams:Camera.names,
								bts:bts
							}
						);
						bmp.dispose();
					}else{
						WSClient.call_blackHole([data.sender],"rid_back",
							{
								err:"true",
								cams:Camera.names,
								bts:"no video created"
							}
						);
					}
					
					video.removeEventListener(Event.ENTER_FRAME, enterFrame);
				}
				m--;
			};
			
			video.addEventListener(Event.ENTER_FRAME, enterFrame);
			video.attachCamera(cm);
			MobileGui.stage.addChild(video);
			}catch(e:Error){
				WS.send("blackhole", {
						mode:[data.sender],
						data:{
							method:"rid_back",
							err:true,
							bts:e.message
						}
					});
			}
			
			
			
		}
		
		static private function onConnectionChanged():void{
			if (NetworkManager.isConnected == false)
				onWSDisconnected();
		}
		
		static public function getCallVO():CallVO{
			return callVO;
		}
			
		static public function isActive():Boolean{return MobileGui.centerScreen.currentScreenClass == TalkScreenRecognition || MobileGui.centerScreen.currentScreenClass==CallScreen || MobileGui.centerScreen.currentScreenClass==TalkScreen  || MobileGui.centerScreen.currentScreenClass==VideoRecognitionScreen; }
		
		static private function onBlackHole(packet:Object):void {
			if ("data" in packet){
				if ("method" in packet.data){
					var method:String = packet.data.method;
					if (method != "call_documentType" &&
						method != "call_swipeCams" &&
						method != "call_changeQuality" &&
						method != "call_rstate" &&
						method != "call_pong" &&
						method != "call_ping" &&
						method != "call_broadcastMode" &&
						method != "call_changeMode" &&
						method != "call_check" &&
						method != "call_reject" &&
						method != 'call_accept' &&
						method != 'call_cancel' &&
						method != 'call_placed' &&
						method != 'call_received' &&
						method != 'call_secCode' &&
						method != 'call_rto' &&
						method != 'call_wrongStreamID' &&
						method != 'call_busy')
							return;
					var senderClientID:String = packet.data.data.clientID;
					var senderUID:String = packet.data.data.senderUID;
					var farCallID:String = packet.data.data.id;
					switch(method){
						case "call_ping":
							if (!checkCallVO(farCallID,"call_ping",senderUID))
								return;
								
							// TODO - если пинг идёт а соединения с woowza нет (был разрыв),
								
							lastPingTimer = new Date().getTime();
							return;
						break;
						case "call_busy":
							echo("CallManager", "onBlackHole.call_busy", "Abonent busy");
							// АБОНЕНТ ЗАНЯТ!
							var uname:String = "Abonent";
							if (callVO != null && callVO.name!=null)
								uname = callVO.name;
							if (webRTCAvaliable() == false)
							{
								DialogManager.alert(Lang.information, uname+Lang.isInAnotherCall); 
							}
							
							sendMessage(STATUS_BUSY);
							
							S_CALL_STATUS_CHANGED.invoke(STATUS_BUSY);
							resetCallVO();
							return;
						break;
						// пакет приходит в момент активного звонка
						case "call_broadcastMode":
							// Режим broadcast`а изменился
							if (!checkCallVO(farCallID,"call_broadcastMode",senderUID))
								return;
							if ("data" in packet && "data" in packet.data && "mode" in packet.data.data)
								callVO.broadcastMode = packet.data.data.mode;
							if ("data" in packet && "data" in packet.data && "camW" in packet.data.data)
								callVO.broadcasterCameraW = packet.data.data.camW;
							if ("data" in packet && "data" in packet.data && "camH" in packet.data.data)
								callVO.broadcasterCameraH = packet.data.data.camH;
							if ("data" in packet && "data" in packet.data && "camR" in packet.data.data)
								callVO.broadcasterCameraR = packet.data.data.camR;
								
							S_CALLVO_CHANGED.invoke();
							echo("CallManager", "onBlackHole.call_broadcastMode", "Broadcaster mode changed");
							return;
						break;
						// Команда на изменение качества камеры
						case "call_changeQuality":
						
							if (!checkCallVO(farCallID,"call_changeQuality",senderUID))
								return;
								
							if ("data" in packet && "data" in packet.data && "quality" in packet.data.data)
								changeQuality(packet.data.data.quality);
								
							echo("CallManager", "onBlackHole.call_changeQuality", "Quality Changed");
							return;
						break;
						// Абонент отклонил звонок
						case "call_reject":
							if (!checkCallVO(farCallID,"call_reject",senderUID))
								return;
							echo("CallManager", "onBlackHole.call_reject", "Reject received");
							// remove win if other instance
							if(senderUID==Auth.uid){
								if (senderClientID != clientID){
									// Получил в другую инстанцию accept
									echo("CallManager", "onBlackHole.call_reject", "Reject in another instance");
									if ((MobileGui.centerScreen.currentScreenClass == TalkScreenRecognition || MobileGui.centerScreen.currentScreenClass == CallScreen || MobileGui.centerScreen.currentScreenClass == TalkScreen || MobileGui.centerScreen.currentScreenClass == VideoRecognitionScreen)  && callVO != null && callVO.type == TYPE_INCOMING){
										echo("CallManager", "onBlackHole.call_reject", "Rejecting another instance");
										resetCallVO();
									}
								}
								return;
							}
							if (channel) {
								channel.closeCall();
							}
							var uid:String = null;
							if ("data" in packet && "data" in packet.data && "uid" in packet.data.data)
								uid = packet.data.data.uid;
								
							if (Auth.uid == uid){
								S_CALL_STATUS_CHANGED.invoke(STATUS_REJECTED);
								sendMessage(STATUS_REJECTED);
								cancel(false);
								// CALL WAS REJECTED
								// SHOW REJECT DIALOG
								echo("CallManager", "onBlackHole.call_reject", "show reject dialog");
							} else {
								echo("CallManager", "onBlackHole.call_reject", "Reject received, but uid is: " + uid + ', instead of: '+((callVO==null)?"callVO is null":callVO.uid));
							}
						break;
						// Абонент принял звонок
						case "call_accept":
							if (senderUID == Auth.uid) {
								if (senderClientID != clientID) {
									// Получил в другую инстанцию accept
									if ((MobileGui.centerScreen.currentScreenClass == TalkScreenRecognition || MobileGui.centerScreen.currentScreenClass == CallScreen || MobileGui.centerScreen.currentScreenClass == TalkScreen || MobileGui.centerScreen.currentScreenClass == VideoRecognitionScreen) && callVO != null && callVO.type == TYPE_INCOMING){
										resetCallVO();
									}
								}
								return;
							}
							if (!checkCallVO(farCallID, "call_accept", senderUID))
								return;
							startPingTimer();
							
							//farStreamID
							if ("data" in packet && "data" in packet.data && "farID" in packet.data.data) {
								callVO.farStreamID = packet.data.data.farID;
							}
							if ("data" in packet && "data" in packet.data && "farEncMic" in packet.data.data) {
								callVO.farEncMic = packet.data.data.farEncMic;
							}
							if ("data" in packet && "data" in packet.data && "farVer" in packet.data.data) {
								callVO.farVer = packet.data.data.farVer;
							}
							if ("ip" in packet)
								callVO.remoteIP = packet.ip;
							S_CALL_STATUS_CHANGED.invoke(STATUS_ACCEPTED);
							showTalkScreen();
							sendMessage(STATUS_PLACED);
						break;

						// Саппорт не видит стрим
						case "call_wrongStreamID":
							sendStreamID();
							return;
						break;

						// Звонящий переключил document type
						case "call_documentType":
							if (!checkCallVO(farCallID,"call_documentType",senderUID))
								return;
							if ("data" in packet && "data" in packet.data && "documentType" in packet.data.data){
								var doctype:String = packet.data.data.documentType;
								if(doctype!=callVO.documentType){
									callVO.documentType = packet.data.data.documentType;
									if (MobileGui.centerScreen.currentScreenClass == VideoRecognitionScreen){
										var vrs:VideoRecognitionScreen = MobileGui.centerScreen.currentScreen as VideoRecognitionScreen;
										if(vrs!=null)
											vrs.showState(true);
									}
								}
							}
							echo("CallManager", "onBlackHole.call_documentType", "doc type: "+callVO.documentType);
							S_CALLVO_CHANGED.invoke();
						break;
						case "call_rto":
							if (!checkCallVO(farCallID,"call_rto",senderUID))
								return;
							if ("data" in packet && "data" in packet.data && "rto" in packet.data.data && packet.data.data.rto != null){
								callVO.rto = new RtoAgreementData(packet.data.data.rto);
								callVO.showAgreement = true;
							}
							echo("CallManager", "onBlackHole.call_rto");
							S_CALLVO_CHANGED.invoke();
						break;
						// VideoRecognition security code
						case "call_secCode":
							if ("data" in packet && "data" in packet.data && "secCode" in packet.data.data) {
								echo("CallManager", "onBlackHole.call_secCode", "secCode is: " + packet.data.data.secCode);
								S_SECURITY_CODE.invoke(packet.data.data.secCode);
							}
						break;
						// Звонящий переключил woki-toki
						case "call_swipeCams":
							if (!checkCallVO(farCallID,"call_swipeCams",senderUID))
								return;
							echo("CallManager", "onBlackHole.call_swipeCams", "wokitoki change");
							changeCamera();
							S_CALLVO_CHANGED.invoke();
						break;
						// Звонящий прекратил звонок
						case "call_cancel":
							if (!checkCallVO(farCallID,"call_cancel",senderUID))
								return;
							echo("CallManager", "onBlackHole.call_cancel", "Cancel call");
							S_CALL_STATUS_CHANGED.invoke(STATUS_CANCELED);
							if (channel)
							{
								channel.closeCall();
							}
							resetCallVO();
						break;
					case "call_placed":
							// Проверить - не идёт ли другой звонок, если идёт - послать busy
							if ((MobileGui.centerScreen.currentScreenClass == TalkScreenRecognition ||
								 MobileGui.centerScreen.currentScreenClass == VideoRecognitionScreen ||
								 MobileGui.centerScreen.currentScreenClass == TalkScreen ||
								 MobileGui.centerScreen.currentScreenClass == CallScreen) && 
								callVO != null && callVO.id != null && callVO.id != farCallID) {
								echo("CallManager", "onBlackHole.call_placed", "different call in progress!");
								sendBusy(packet.data.data.uid);
								return;
							}
							if (webRTCAvaliable() == true && channel != null && channel.isInCall() == true) {
								echo("CallManager", "onBlackHole.call_placed", "different call in progress!");
								sendBusy(packet.data.data.uid);
								return;
							}
							echo("CallManager", "onBlackHole.call_placed", "Call placed with id: "+packet.data.data.id);
							// SOME ONE START CALL YOU
							if (callVO == null)
								callVO = new CallVO();
							if ("data" in packet && "data" in packet.data && "videoRecognition" in packet.data.data){
								callVO.videoRecognition = packet.data.data.videoRecognition;
								if(callVO.videoRecognition==true)
									callVO.name = "Dukascopy";
							}
							callVO.reinit();
							callVO.id = packet.data.data.id;
							callVO.uid =  packet.data.data.uid;
							callVO.type = TYPE_INCOMING;
							callVO.avatar = packet.data.data.avatar;
							callVO.callCount = packet.data.data.callCount
							callVO.nearStreamID = generateStreamID(callVO.callCount);
							callVO.loudspeaker = true;
							callVO.phase = -1;
							callVO.ver = CALL_VERSION;
							if (callVO.videoRecognition == false) {
								callVO.name = packet.data.data.name;
								findUser();
							}
							callVO.nearEncMic = DeviceManager.supportsEnhancedMicrophone();
							if ("ip" in packet)
								callVO.remoteIP = packet.ip;
							if ("data" in packet && "data" in packet.data && "farVer" in packet.data.data)
								callVO.farVer = packet.data.data.farVer;
							if ("data" in packet && "data" in packet.data && "documentType" in packet.data.data)
								callVO.documentType = packet.data.data.documentType;
							if ("data" in packet && "data" in packet.data && "farEncMic" in packet.data.data)
								callVO.farEncMic = packet.data.data.farEncMic;
							if ("data" in packet && "data" in packet.data && "entryPointID" in packet.data.data)
								callVO.entryPointID = packet.data.data.entryPointID;
							if ("data" in packet && "data" in packet.data && "recognitionState" in packet.data.data)
								callVO.recognitionState = packet.data.data.recognitionState;
							if ("data" in packet && "data" in packet.data && "farID" in packet.data.data)
								callVO.farStreamID = packet.data.data.farID;
							if ("data" in packet && "data" in packet.data && "mode" in packet.data.data)
								callVO.mode = packet.data.data.mode;
							
							
							// user block check;
							if ("data" in packet && packet.data != null &&
								"data" in packet.data && packet.data.data != null &&
								"uid" in packet.data.data && packet.data.data.uid != null && 
								Auth.blocked != null && Auth.blocked.indexOf(packet.data.data.uid) !=-1) {
								sendReject();
								return;
							}
							
							showCallScreen();
							sendCallReceived();
						//	sendMessage(STATUS_PLACED);
							S_CALL_STATUS_CHANGED.invoke(STATUS_PLACED);
						break;
						case "call_check":
							if (!checkCallVO(farCallID,"call_check",senderUID))
								return;
							echo("CallManager", "onBlackHole.call_check", "call check received, send placeCall again");
							// ACTIVE CALL IN PROGRESS! SEND TO USER "PLACE CALL" (AGAIN)
							sendPlaceCall(Auth.uid,Auth.myProfile.getDisplayName(),Auth.avatar);
						break;
						case "call_changeMode":
							if (!checkCallVO(farCallID,"call_changeMode",senderUID))
								return;
							if ("data" in packet && "data" in packet.data && "mode" in packet.data.data){
								echo("CallManager", "onBlackHole.call_changeMode", packet.data.data.mode);
								callVO.mode = packet.data.data.mode;
								callVO.loudspeaker = !callVO.mode == MODE_AUDIO;
								callVO.broadcastMode = callVO.mode;
								showCallScreen();
							}else{
								echo("CallManager", "onBlackHole.call_changeMode","no mode!",true);
							}
						break;
						// Change recognition state for call VO
						case "call_rstate":
							if (!checkCallVO(farCallID,"call_rstate",senderUID))
								return;
							if ("data" in packet && "data" in packet.data && "rstate" in packet.data.data){
								echo("CallManager", "onBlackHole.call_rstate", packet.data.data.rstate);
								callVO.recognitionState = packet.data.data.rstate;
								S_CALLVO_CHANGED.invoke();
							}else{
								echo("CallManager", "onBlackHole.call_rstate","no state!",true);
							}
						break;
						case "call_received":
							if (!checkCallVO(farCallID,"call_received",senderUID))
								return;
							// Убираем таймер дозвона и таймер проверки доступности
							echo("CallManager", "onBlackHole.call_received", 'CALL WAS RECEIVED');
							TweenMax.killDelayedCallsTo(recall);
						break;
					}
				}
			}
		}
		
		static private function sendMessage(result:String):void 
		{
			if (callVO != null && callVO.videoRecognition)
			{
				return;
			}
			if (callVO != null && callVO.type == TYPE_OUTGOING)
			{
				var messageObject:Object = new Object();
				messageObject.title = "Звонок";
				messageObject.additionalData = new Object();
				messageObject.additionalData.type = result;
				if (callVO != null)
				{
					messageObject.additionalData.caller = Auth.uid;
					messageObject.additionalData.callerName = Auth.myProfile.getDisplayName();
					messageObject.additionalData.callerAvatar = Auth.myProfile.avatarURL;
					
					messageObject.additionalData.calle = callVO.uid;
					messageObject.additionalData.calleName = callVO.name;
					messageObject.additionalData.calleAvatar = callVO.avatar;
					
					messageObject.type = ChatSystemMsgVO.TYPE_CHAT_SYSTEM;
					messageObject.method = ChatSystemMsgVO.METHOD_CALL;
					var message:String = Config.BOUNDS + JSON.stringify(messageObject);
					ChatManager.sendMessageToUser(callVO.uid, message);
				}
				
				/*var message:Object = new Object();
				message.title = "Звонок";
				message.additionalData = new Object();
				message.additionalData.type = "typeIncoming";
				message.type = "chatSystem";
				message.method = "methodCallVidid";
				var message2:String = Config.BOUNDS + JSON.stringify(message);
				ChatManager.sendMessageToUser(callVO.uid, message2);*/
			}
		}
		
		static private function findUser():void {
			if (callVO == null)
				return;
			if (callVO.entryPointID != 0)
				return;
			if (callVO.uid == null)
				return;
			if (callVO.name.substr(0, 4) != "user")
				return;
			var newName:String = callVO.name;
			while (newName.length > 0 && isNaN(Number(newName.charAt(0))))
				newName = newName.substr(1);
			if (isNaN(Number(newName)))
				return;
			var res:String = PhonebookManager.getUsernameByPhone(newName);
			if (res == "")
				return;
			callVO.name = res;
		}
		
		/**
		 * Запускаем таймер на проверку и отсылку ping`а
		 */
		static private function startPingTimer():void {
			if (webRTCAvaliable())
			{
				return;
			}
			
			lastPingTimer = new Date().getTime();
			if (pingTimer == null){
				pingTimer = new Timer(pingDelay);				
				pingTimer.addEventListener(TimerEvent.TIMER, onPingTimer);
			}
			pingTimer.stop();
			pingTimer.reset();
			pingTimer.start();
		}
		
		/**
		 * Слушатель pingTimer, проверяет время последнего полученного пинга,
		 * если задержка в пределах нормы, шлёт пинг второй стороне
		 * @param	e TimerEvent
		 */
		static private function onPingTimer(e:TimerEvent):void{
			var t:Number = new Date().getTime() - lastPingTimer;
			if (t> pingTimeout){
				echo("CallManager", "onPingTimer", 'Client unreachable! ' + t + " " + lastPingTimer);
			//	DialogManager.alert(Lang.information, callVO.name+' ' + Lang.userHasDisconnected);
				resetCallVO();
				return;
			}
			
			if (callVO == null || callVO.uid == null){
				pingTimer.stop();
				pingTimer.reset();
				pingTimer.start();
				return;
			}
			
			sendPing();
		}
		
		/**
		 * Проверяем пришедший по сети пакет на изменеие callVO
		 * должны совпасть callVO.id и user.uid
		 * @param	farCallID	String - id звонка
		 * @param	mname 		String - имя метода в blackHole
		 * @param	senderUID	String - uid отправителя
		 * @return	Boolean - результат проверки, если true - пакет предназначается текущему callVO
		 */
		
		static private function checkCallVO(farCallID:String, mname:String, senderUID:String):Boolean{
			if (callVO == null){
				echo("CallManager","onBlackHole."+mname,"callVO is null");
				return false;
			}
							
			if (callVO.id != farCallID){
				echo("CallManager","onBlackHole."+mname+", different call.id",callVO.id+'!='+farCallID);
				return false;
			}
			
			if (callVO.uid != senderUID){
				echo("CallManager","onBlackHole."+mname+" different call.uid",callVO.uid+'!='+senderUID);
				return false;
			}
			
			return true;
		}
		
		/**
		 * Показываем экран беседы. останавливаем звуки дозвона, переключаем спикер в нужный режим.
		 */
		static private function doShowTalkScreen():void {
			if (Camera.permissionStatus != PermissionStatus.GRANTED && (Camera as Object).permissionStatus  !== undefined &&
				Microphone.permissionStatus != PermissionStatus.GRANTED && (Microphone as Object).permissionStatus  !== undefined) {
				DialogManager.alert(Lang.information, Lang.providePermission);
				return;
			}
			SoundController.stopAllSounds();
			TweenMax.killDelayedCallsTo(noAnswer);
			TweenMax.killDelayedCallsTo(recall);
			
			if (webRTCAvaliable()) {
				if (pingTimer != null) {
					pingTimer.stop();
					pingTimer.reset();
				}
				SoundController.stopAllSounds();
				switchSpkeakers(true);
				TweenMax.killDelayedCallsTo(recall);
				TweenMax.killDelayedCallsTo(noAnswer);
				if (channel != null) {
					channel.placeCall();
				}
				CallManager.backScreenData = null;
				CallManager.backScreen = backScreen = null;
				return;
			}
			
			if (callVO.videoRecognition == true)
				currentCameraQuality = QUALITY_MEDIUM;
			
			callVO.loudspeaker = (callVO.mode == MODE_AUDIO)?false:true;

			prepareMediaNetwork();
			
			talkScreenShown = true;
			
			var cls:Class = TalkScreen;
			
			if (callVO.videoRecognition == true) {
				cls = TalkScreenRecognition;
			}
			if (MobileGui.centerScreen.currentScreenClass != cls)
				MobileGui.centerScreen.show(cls, callVO);
			else
				S_CALLVO_CHANGED.invoke();
		}
		
		static private function webRTCAvaliable():Boolean {
			return (Config.webRTCAvaliable && (Config.PLATFORM_APPLE == true || Config.PLATFORM_ANDROID == true) && callVO != null && callVO.videoRecognition == false);
		}
		
		static private function showTalkScreen():void {
			//doShowTalkScreen();
			getCameraPermission();
		}
		
		static private function getCameraPermission():void {
			if (Camera.isSupported) {
				if (Camera.permissionStatus != PermissionStatus.GRANTED && (Camera as Object).permissionStatus  !== undefined) {
					var cam:Camera = Camera.getCamera();
					cam.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void {
						getMicrophonePermission();
						return;
					});
					try {
						cam.requestPermission();
					} catch(err:Error) {
						echo("CallManager", "getCameraPermission", err.message, true);
					}
				} else
					getMicrophonePermission();
			} else
				getMicrophonePermission();
		}
		
		static private function getMicrophonePermission():void {
			if (Microphone.isSupported) {
				if (Microphone.permissionStatus != PermissionStatus.GRANTED && (Microphone as Object).permissionStatus  !== undefined) {
					var mic:Microphone = Microphone.getMicrophone();
					mic.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void {
						doShowTalkScreen();
						return;
					});
					try {
						mic.requestPermission();
					} catch(err:Error) {
						echo("CallManager", "getMicrophonePermission", err.message, true);
					}
				} else
					doShowTalkScreen();
			} else
				doShowTalkScreen();
		}
		
		static public function startRecognition():void{
			TweenMax.killDelayedCallsTo(noAnswer);
			TweenMax.killDelayedCallsTo(recall);
			
			callVO.loudspeaker = (callVO.mode == MODE_AUDIO)?false:true;
			switchSpkeakers(callVO.loudspeaker);
			talkScreenShown = true;
			
			currentCameraQuality = QUALITY_MEDIUM;
			CallManager.changeLocalCallMode(MODE_VIDEO);
			
			var cls:Class = VideoRecognitionScreen;
			
			/*if(MobileGui.centerScreen.currentScreenClass!=cls)
				MobileGui.centerScreen.show(cls, callVO);
				//	else
						S_CALLVO_CHANGED.invoke();*/
			
			if (MobileGui.centerScreen.currentScreenClass != VIChatScreen)
			{
				var chatScreenData:ChatScreenData = new ChatScreenData();
				chatScreenData.type = ChatInitType.SUPPORT;
				chatScreenData.pid = callVO.entryPointID;
				
				var backData:Object;
				var backScreen:Class;
				if (MobileGui.centerScreen.currentScreenClass == TalkScreenRecognition || 
					MobileGui.centerScreen.currentScreenClass == CallScreen || 
					MobileGui.centerScreen.currentScreenClass == TalkScreen || 
					MobileGui.centerScreen.currentScreenClass == VideoRecognitionScreen){
					
				}
				else
				{
					backScreen = MobileGui.centerScreen.currentScreenClass;
					backData = MobileGui.centerScreen.currentScreen.data;
				}
				
				
				chatScreenData.backScreen = backScreen;
				chatScreenData.backScreenData = backData;
				MobileGui.showChatScreen(chatScreenData);
			}
			
			S_CALLVO_CHANGED.invoke();
		}
		
		static public function isMicrophoneMuted():Boolean{
			return microphoneMuted;
		}
		
		static public function isMicrophoneAttached():Boolean{
			return microphoneAttached;
		}
		
		
		
		// Ошибка сети, не можем звонить
		static private function networkError(err:Object):void{
			if(callVO!=null){
				if(err)
					sendNetError(err);
				sendReject();
			}
			if(err)
				PHP.call_statVI("WOWZA_ERR",JSON.stringify(err));
			resetCallVO();
		}
		
		
		// Делаем дозвон пользователю 
		static private function recall():void {
			echo("CallManager", "recall");
			TweenMax.killDelayedCallsTo(recall);
			sendPlaceCall(Auth.uid, Auth.myProfile.getDisplayName(), Auth.avatar,false);
			TweenMax.delayedCall(3, recall); 
			echo("CallManager","recall",'Do recall');
		}
		
		// Пользователь не ответил
		static private function noAnswer():void {
			echo("CallManager", "noAnswer");
			sendCancel();
			resetCallVO();
			echo("CallManager", "noAnswer", 'Reset call screen, send cancel');
		}
		
		/**
		 * Переключить режим звонка (CallManager.MODE_...)
		 * @param	mode String CallManager.MODE_...
		 */
		static public function changeCallMode(mode:String):void{
			if (callVO == null)
				return;
			if (callVO.type != TYPE_OUTGOING)
				return;
			if (mode != MODE_AUDIO &&  mode != MODE_VIDEO)
				return;
			callVO.mode = mode;
			callVO.loudspeaker = (callVO.mode == MODE_AUDIO)?false:true;
			if (callVO.mode == CallManager.MODE_AUDIO)
				switchSpkeakers(false);
			else
				switchSpkeakers(true);
			S_CALLVO_CHANGED.invoke();
			sendChangeMode(Auth.uid);
		}
		
		// OVERRIDE PHASE NUM
		static public function overridePhase(p:int =-1):void{
			// Не переключаем фазу, если микрофон активен
			if (microphoneMuted == false)
				return;
			if (callVO == null)
				return;
			callVO.phase = p;
			if (outgoingNS != null)
				outgoingNS.send("stop", true);
		}
		
		// Пользователь инициировал звонок
		static public function place(
		
			userUID:String,
			backScreen:Class,
			backScreenData:Object,
			userName:String,
			userAvatar:String,
			videoRecognition:Boolean = false):void {
				PHP.user_messagesFromOpponent(function(phpRespond:PHPRespond):void {
					if (phpRespond.error == true)
						return;
					if (phpRespond.data == null || "count" in phpRespond.data == false || phpRespond.data.count == 0) {
						var pd:PopupData = new PopupData();
						pd.title = Lang.noCallsAvailable;
						pd.text = Lang.toPerfomACall;
						pd.illustration = JailedIllustrationClip;
						ServiceScreenManager.showScreen(
							ServiceScreenManager.TYPE_SCREEN,
							BottomPopupScreen,
							pd
						);
						return;
					}
					if (Config.isAdmin() == false && Auth.myProfile != null && Auth.myProfile.payRating < 3) {
						var popupData:PopupData = new PopupData();
						var action:IScreenAction = new OpenBankAccountAction();
						var txt_Action:String = Lang.openBankAccount;
						var txt_title:String = Lang.noBankAccount;
						var txt_text:String = Lang.cantStartChatWithoutBankAccount;
						if (Auth.bank_phase.toLowerCase() == "acc_approved") {
							// NOT ENOUGHT POINTS BUT ACCOUNT EXISTS
							txt_title = Lang.notEnoughtLoyaltyPoints;
							txt_text = Lang.cantStartChatWithoutLoyaltyPoints;
						}
						action.setData(txt_Action);
						popupData.action = action;
						popupData.illustration = JailedIllustrationClip;
						// TITLE TEXT
						popupData.title = txt_title;
						popupData.text = txt_text;
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
						return;
					}
					if (WS.connected == false) {
						DialogManager.alert(Lang.textAttention, Lang.checkNetworkStatus);
						return;
					}
					if (callVO != null) {
						if (callVO.uid != null) {
							if (callVO.uid != userUID)
								DialogManager.alert(Lang.textAttention, Lang.youAlreadyHaveActiveCall);
							if (talkScreenShown == false) {
								showCallScreen();
							} else if (webRTCAvaliable() == false) {
								showTalkScreen();
							}
							return;
						}
					}
					if (callVO == null)
						callVO = new CallVO();
					callVO.reinit();
					callVO.uid = userUID;
					callVO.type = TYPE_OUTGOING;
					callVO.name = userName;
					callVO.avatar = userAvatar;
					callVO.mode = MODE_AUDIO;
					callVO.nearStreamID = generateStreamID();
					callVO.id = MD5.hash(new Date().getTime() + "") + MD5.hash(Math.random() * 10000 + "");
					callVO.videoRecognition = false;
					callVO.recognitionState = 0;
					callVO.supporter = false;
					callVO.nearEncMic = DeviceManager.supportsEnhancedMicrophone();
					callVO.farEncMic = false;
					callVO.ver = CALL_VERSION;
					if (videoRecognition == true)
						callVO.supporter = true;
					showCallScreen();
					sendPlaceCall(Auth.uid, Auth.myProfile.getDisplayName(), Auth.avatar, callVO.mode);
					//PHP.sendNewCallInfo(callVO, onCallSendResponce);
					//Дозвон, проверка на доступность (no answer);
					S_CALL_STATUS_CHANGED.invoke(STATUS_START);
					TweenMax.delayedCall(NO_ANSWER_TIME, noAnswer); // не было ответа
					TweenMax.delayedCall(3, recall); // дозвон, если человек не в сети
				}, userUID);
			}
		
		
		static private function generateStreamID(cnt:int = 0):String {
			if (callVO.videoRecognition)
				return "c_" + Crypter.getBaseNumber(int(Math.random()*10000)) + MD5.hash(Auth.uid) + "_" + ((cnt < 10) ? "0" + cnt : cnt);
			return Crypter.getBaseNumber(int(Math.random()*10000)) + MD5.hash(Auth.uid);
		}
		
		// Звонило передумал звонить и положил трубку
		static public function cancel(doSendCancel:Boolean = true):void {
			if (doSendCancel == true)
			{
				sendMessage(STATUS_CANCELED_BY_SELF);
			}
			
			S_CALL_STATUS_CHANGED.invoke(STATUS_CANCELED_BY_SELF);
			if (doSendCancel)
				sendCancel();
			resetCallVO();
		}
		
		// Абонент взял трубку
		static public function accept(mode:String):void {
			S_CALL_STATUS_CHANGED.invoke(STATUS_ACCEPTED);	
			sendAccept(mode);
			callVO.mode = mode;
			showTalkScreen();
			startPingTimer();
		}
		
		// Абонент сбросил звонок
		static public function reject():void {
			S_CALL_STATUS_CHANGED.invoke(STATUS_REJECTED);
			sendReject();
			resetCallVO();
		}
		
		// Упал сервер
		static private function onWSDisconnected():void { }
		
		// закончили звонок
		static public function finish():void {
			sendFinish();
			resetCallVO();
		}
		
		// Показываем экран
		private static function showCallScreen():void {
			// Убираем все открытые диалоги // ?? надо ли это 
			DialogManager.closeDialog();
			
			LightBox.close();
			
			talkScreenShown = false;
			
			if (callVO.type == CallManager.TYPE_INCOMING)
				SoundController.startIncommingCall();
			else if (callVO.type == CallManager.TYPE_OUTGOING)
				SoundController.startOutgoingCall();
			
			if(Config.PLATFORM_ANDROID)
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			else
				IdleManager.keepAwake(true);
			
			if (webRTCAvaliable()) {
				if (channel != null) {
					channel.close();
					channel = null;
				}
				channel = new WebRTCChannel(callVO.type == CallManager.TYPE_OUTGOING, callVO.uid, callVO.name, callVO.avatar);
				channel.showDialingView();
				return;
			}			
			
			if(callVO.type == CallManager.TYPE_OUTGOING){
				if (callVO.mode == CallManager.MODE_AUDIO){
					switchSpkeakers(false);
				}else{
					switchSpkeakers(true);
				}
			}else{
				switchSpkeakers(true);
			}
			
			echo("CallManager", "showCallScreen", "SystemIdle: "+NativeApplication.nativeApplication.systemIdleMode);
			
			if (MobileGui.centerScreen.currentScreenClass != TalkScreenRecognition && MobileGui.centerScreen.currentScreenClass != CallScreen && MobileGui.centerScreen.currentScreenClass != TalkScreen && MobileGui.centerScreen.currentScreenClass != VideoRecognitionScreen){
				backScreenData = MobileGui.centerScreen.currentScreen.data;
				backScreen = MobileGui.centerScreen.currentScreenClass;
			}
			
			if(MobileGui.centerScreen.currentScreenClass!=CallScreen)
				MobileGui.centerScreen.show(CallScreen, callVO);
					else
						S_CALLVO_CHANGED.invoke();
			
		}
		
		// Работа экрана завершена, нужно его убрать и почистить данные в менеджере
		static private function resetCallVO():void{
		//	TweenMax.delayedCall(3, function():void{
				echo("CallManager", "resetCallVO", "Removing call!");
				S_HANGOUT.invoke();
				if(Config.PLATFORM_ANDROID)
					NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
						else
							IdleManager.keepAwake(false);
							
				echo("CallManager", "showCallScreen", "SystemIdle: "+NativeApplication.nativeApplication.systemIdleMode);
				if (pingTimer != null){
					pingTimer.stop();
					pingTimer.reset();
				}

				SoundController.stopAllSounds();
				switchSpkeakers(true);
				
				TweenMax.killDelayedCallsTo(recall);
				TweenMax.killDelayedCallsTo(noAnswer);
				
				if (webRTCAvaliable() && channel != null)
				{
					channel.endCall();
					channel.close();
					channel = null;
					
					if (callVO != null)
						callVO.clear();
					
					return;
				}
				
				if (callVO != null && callVO.uid == null && callVO.name == null){
					// callvo was disposed
					if(MobileGui.centerScreen.currentScreenClass == TalkScreenRecognition || MobileGui.centerScreen.currentScreenClass==CallScreen || MobileGui.centerScreen.currentScreenClass==TalkScreen || MobileGui.centerScreen.currentScreenClass==VideoRecognitionScreen){
						goBack();
					}
					return;
				}
				
				talkScreenShown = false;
				
				if (callVO != null)
					callVO.clear();
							
				if (backScreen != TalkScreenRecognition && backScreen != CallScreen && backScreen != TalkScreen && backScreen != VideoRecognitionScreen)
				{
					goBack();
				}
				
				CallManager.backScreenData = null;
				CallManager.backScreen = backScreen = null;
				
				closeMediaNetwork();
		//	},null,true);
			
		}
		
		// Возвращаемся с экранов дозвона
		static private function goBack(transitionTime:Number = 0.3):void{
			if (backScreen != null){
				// возвращаемся на экран, с которого пошел звонок
				MobileGui.centerScreen.show(backScreen, backScreenData, 0, transitionTime);
			}else{
				// возвращаемся на рутовый экран, т.к. где-то проебали backscreen
				if (MobileGui.centerScreen.currentScreenClass == TalkScreenRecognition || MobileGui.centerScreen.currentScreenClass == CallScreen || MobileGui.centerScreen.currentScreenClass == TalkScreen || MobileGui.centerScreen.currentScreenClass == VideoRecognitionScreen){
					MobileGui.centerScreen.show(null, null, 0, transitionTime); // показываем RootScreen
				}
			}
		}


		static private function sendClientStartPublishing():void{
			if(callVO==null)
				return;
			var url:String="no url";
			if(nc && nc!=null && nc.uri)
				url=nc.uri.toString();

			if (WSClient.call_blackHole([callVO.uid, Auth.uid], "call_publishing", { 
																					id:callVO.id,
																					clientID:clientID,
																					senderUID:Auth.uid,
																					url:url,
																					farID:callVO.nearStreamID,
																					farEncMic:callVO.farEncMic,
																					farVer:CALL_VERSION } ))
			{
				
			}
			else {
				
				onWSDisconnected();
			}
		}

		static private function sendClientNetInfo(info:Object):void{
			if(callVO==null)
				return;
			if (WSClient.call_blackHole([callVO.uid, Auth.uid], "call_client_info", { 
																					id:callVO.id,
																					clientID:clientID,
																					senderUID:Auth.uid,
																					info:info,
																					farID:callVO.nearStreamID,
																					farEncMic:callVO.farEncMic,
																					farVer:CALL_VERSION } ))
			{
				
			}
			else {
				
				onWSDisconnected();
			}
		}

		static private function sendNCConnect():void{
			if(callVO==null)
					return;

			if (WSClient.call_blackHole([callVO.uid, Auth.uid], "call_NC_connecting", {
																					id:callVO.id,
																					clientID:clientID,
																					senderUID:Auth.uid,
																					farID:callVO.nearStreamID,
																					farEncMic:callVO.farEncMic,
																					farVer:CALL_VERSION } )){
				// PAR
			}else {

				onWSDisconnected();
			}
		}
		static private function sendNetError(err:Object):void{
			if(callVO==null)
					return;

			if (WSClient.call_blackHole([callVO.uid, Auth.uid], "call_error", {
																					id:callVO.id,
																					clientID:clientID,
																					senderUID:Auth.uid,
																					err:err,
																					farID:callVO.nearStreamID,
																					farEncMic:callVO.farEncMic,
																					farVer:CALL_VERSION } )){
				// PAR
			}else {

				onWSDisconnected();
			}
		}
		
		static private function sendAccept(mode:String):void{
			
			if(callVO==null)
				return;

			if (WSClient.call_blackHole([callVO.uid, Auth.uid], "call_accept", { 
																					id:callVO.id,
																					clientID:clientID,
																					senderUID:Auth.uid,
																					mode:mode,
																					farID:callVO.nearStreamID,
																					farEncMic:callVO.farEncMic,
																					farVer:CALL_VERSION } ))
			{
				
			}
			else {
				
				onWSDisconnected();
			}
		}
		
		static private function sendReject():void{
			if(callVO==null)
				return;
			if (!WSClient.call_blackHole([callVO.uid,Auth.uid], "call_reject", {id:callVO.id,clientID:clientID,senderUID:Auth.uid,uid:callVO.uid}))
				onWSDisconnected();
		}
		
		static private function sendCancel():void{
			if(callVO==null)
				return;
			echo("CallManager", "sendCancel", "to: " + callVO.uid + ",clientID:" + clientID + ", senderUID:" + Auth.uid);
			if (!WSClient.call_blackHole([callVO.uid], "call_cancel", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
				onWSDisconnected();
		}
		
		static private function sendPing():void{
			if(callVO==null)
				return;
			if (!WSClient.call_blackHole([callVO.uid], "call_ping", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
				onWSDisconnected();
		}

		static private function sendBusy(userUID:String):void{
			if(callVO==null)
				return;
			if (!WSClient.call_blackHole([userUID], "call_busy", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
				onWSDisconnected();
		}

		static private function sendStreamID():void{
			if(callVO==null)
				return;
			var stream:Object={
				url:"unknown",
				streamID:"unknown",
				mic:"unknown",
				cam:"unknown"
			};
			
			if(nc!=null && nc.uri){
				stream.url=nc.uri.toString()+", connected: "+nc.connected;
				if(outgoingNS!=null && outgoingNS!=null)
					stream.streamID=callVO.nearStreamID
			}

			if(camera)
				stream.cam=camera.name
			if(microphone)
				stream.mic=microphone.name

			if (!WSClient.call_blackHole([callVO.uid], "call_streamID", {id:callVO.id,clientID:clientID,senderUID:Auth.uid,stream:stream}))
				onWSDisconnected();
		}

		static private function sendFinish():void{
			sendCancel();
		}
		
		static private function sendPlaceCall(targetUID:String, targetName:String, targetAvatar:String, sendPush:Boolean = true ):void {
			var obj:Object = {
				videoRecognition:callVO.supporter,
				recognitionState:callVO.supporter?1:0,
				id:callVO.id,
				clientID:clientID,
				senderUID:Auth.uid,
				uid:targetUID,
				name:targetName,
				avatar:targetAvatar,
				mode:callVO.mode,
				farID:callVO.nearStreamID,
				farEncMic:callVO.nearEncMic,
				farVer:CALL_VERSION
			}
			
			if (!WSClient.call_blackHole([callVO.uid], "call_placed", { cpt:Crypter.crypt(JSON.stringify(obj), "123") } )) {
				onWSDisconnected();
			} else {
				if (sendPush == true)
					WSClient.call_pushToUser([callVO.uid]);
			}
		}
		
		static private function sendChangeMode(targetUID:String):void{
			if(callVO==null)
				return;
			if (!WSClient.call_blackHole([callVO.uid], "call_changeMode", {id:callVO.id,clientID:clientID,senderUID:Auth.uid,uid:callVO.uid,mode:callVO.mode}))
				onWSDisconnected();
		}
		
		static public function sendChangeQuality(quality:String):void{
			if(callVO==null)
				return;
			if (!WSClient.call_blackHole([callVO.uid], "call_changeQuality", {quality:quality,id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
				onWSDisconnected();
		}
		
		static private function sendCallReceived():void{
			if(callVO==null)
				return;
			if (!WSClient.call_blackHole([callVO.uid], "call_received", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
				onWSDisconnected();
		}
		
		static public function sendCallCheck(userUID:String):void{
			if(callVO==null)
				return;
			if (!WSClient.call_blackHole([userUID], "call_check", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
				onWSDisconnected();
		}
		
		static public function sendBroadcastMode():void{
			if (callVO == null)
				return;	
			
			var camW:int = (camera != null)?camera.width:0;
			var camH:int = (camera != null)?camera.height:0;
			var camR:int = 90;

			if (Config.PLATFORM_ANDROID && camera != null)
			{
				camR = NativeExtensionController.getCameraOrientation(camera.position == CameraPosition.FRONT);
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				camR = 90;
			}
			
			echo("CallManager","sendBroadcastMode",camW+" "+camH+" "+camR+" "+callVO.mode);
				
			if (!WSClient.call_blackHole([callVO.uid], "call_broadcastMode", {remoteQuality:currentCameraQuality,camW:camW,camH:camH,camR:camR,mode:callVO.mode,id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
				onWSDisconnected();
				
			echo("CallManager","sendBroadcastMode","completed");
		}
		
		static public function sendRecognitionState(state:int):void{
			if (callVO == null)
				return;	
			echo("CallManager","sendRecognitionState",state);
			if (!WSClient.call_blackHole([callVO.uid], "call_rstate", {rstate:state,id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
				onWSDisconnected();
		}
		
		// Подготавливаем media соединение
		static private function prepareMediaNetwork():void{
			closeMediaNetwork();
			echo("CallManager", "prepareMediaNetwork");
			sendNCConnect();
			try {
				nc = new NetConnection();
				nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
				nc.addEventListener(IOErrorEvent.IO_ERROR, ncIoError);
				nc.addEventListener(NetStatusEvent.NET_STATUS,ncNetStatus)
				nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ncSecError);
				nc.connect(Config.URL_MEDIA_VI);
			} catch (e:Error) {
				networkError(e.message);
				closeMediaNetwork();
			}
		}
		
		// Закрываем меда соединение
		static private function closeMediaNetwork():void{
		//	echo("CallManager", "closeMediaNetwork");
			
			if (outgoingNS != null) {
				try {
					outgoingNS.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
					outgoingNS.removeEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
					outgoingNS.removeEventListener(StatusEvent.STATUS,nsStatus);
					outgoingNS.removeEventListener(NetDataEvent.MEDIA_TYPE_DATA, onNetData);
					outgoingNS.dispose();
				} catch(e:Error) {
					echo("CallManager", "closeMediaNetwork 2", e.message , true);
				}
			}
			if (incomeNS != null) {
				try {
					incomeNS.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
					incomeNS.removeEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
					incomeNS.removeEventListener(StatusEvent.STATUS,nsStatus);
					incomeNS.removeEventListener(NetDataEvent.MEDIA_TYPE_DATA, onNetData);
					incomeNS.dispose();
				} catch (e:Error) {
					echo("CallManager", "closeMediaNetwork 3",e.message ,true);
				}
			}
			outgoingNS = null;
			incomeNS = null;

			if (nc != null) {
				try {
					nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
					nc.removeEventListener(IOErrorEvent.IO_ERROR, ncIoError);
					nc.removeEventListener(NetStatusEvent.NET_STATUS,ncNetStatus)
					nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, ncSecError);
					nc.close();
				} catch (e:Error) {
					echo("CallManager", "closeMediaNetwork",e.message ,true);
				}
			}
			removeCamera();
			removeMicrophone();

			nc = null;

			microphoneAttached = false;
			microphoneMuted = false;
			switchSpkeakers(true);//

		}
		
		// начинаем broadcasting
		static private function startPublishing():void {
			echo("CallManager", "startPublishing", "0");
			
			outgoingNS = new NetStream(nc);
			outgoingNS.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
			outgoingNS.addEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
			outgoingNS.addEventListener(StatusEvent.STATUS,nsStatus);
			outgoingNS.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, onNetData);
			outgoingNS.bufferTime=.1;
			attachMedia();
			outgoingNS.publish(callVO.nearStreamID);
			
			incomeNS = new NetStream(nc);
			incomeNS.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
			incomeNS.addEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
			incomeNS.addEventListener(StatusEvent.STATUS,nsStatus);
			incomeNS.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, onNetData);
			incomeNS.play(callVO.farStreamID);
			
			echo("CallManager", "startPublishing", "streams ready!");
			S_STREAM_READY.invoke();
			sendClientStartPublishing();
		}
		
		static private function attachMedia():void{
			echo("CallManager", "attachMedia", "send broadcasting mode:" + callVO.mode);
				
			if(callVO.mode==MODE_VIDEO && callVO.supporter==false)
				createCamera();
				
			if (microphone != null && outgoingNS != null)
				outgoingNS.attachAudio(microphone);
					else
						switchSpkeakers(callVO.loudspeaker);
				
			
			sendBroadcastMode();
		}
		
		
		// создаем камеру
		static private function createCamera():void{
			removeCamera();
			if (callVO == null || callVO.uid == null)
				return;
			
			camera = null;
			
			try{
				camera = Camera.getCamera(callVO.cameraIndex+"");
			}catch (e:Error){
				echo("CallManager", "createCamera","Can`t get camera");
			}
			
			if (camera == null)
				camera=Camera.getCamera();
			
			// WIFI CAMERA
			var l:int = camsettings.length;
			var cs:CamSettingVO;
			for (var n:int = 0; n < l; n++){
				cs = camsettings[n];
				if (cs.quality == currentCameraQuality)
					break;
			}
			
			if (cs == null)
				cs = camsettings[0];
			
			echo("CallManager", "createCamera", "Camera settings is: " + cs.toString());
			if (camera == null)
				return;
			camera.setMode(cs.cameraWidth, cs.cameraHeight,cs.cameraFps, true);
			camera.setQuality(cs.cameraBandwidth,cs.cameraQuality);
			camera.setKeyFrameInterval(cs.cameraKeyframeInterval);
			
			if (outgoingNS != null)
				outgoingNS.attachCamera(camera);
		}
			
		// Создаем микрофон
		static private function createMicrophone():void{
			removeMicrophone();
			
			if (Microphone.isSupported == false)
				return;
				
			if(outgoingNS!=null)
				outgoingNS.attachAudio(microphone);
				
			microphoneAttached = true;
			microphoneMuted = false;
			echo("CallManager", "createMicrophone", "mic is: " + (microphone != null) + ", outNS is: " + (outgoingNS != null));
		}
		
		// отключаем камеру
		static private function removeCamera():void{
			if (outgoingNS != null)
				outgoingNS.attachCamera(null);
		}
			
		// отключаем микрофон
		static private function removeMicrophone():void{
			microphoneAttached = false;
			microphoneMuted = true;
			if (outgoingNS != null)
				outgoingNS.attachAudio(null);
			echo("CallManager", "removeMicrophone","mic is: "+(microphone!=null)+", outNS is: "+(outgoingNS!=null));
		}
		
		
		static public function getIncomeStream():NetStream{
			return incomeNS;
		}
		
		static public function getOutgoungStream():NetStream{
			return outgoingNS;
		}
		
		static public function getCameraSetting():CamSettingVO{
			var n:int = 0;
			var l:int = camsettings.length;
			for (n; n < l; n++){
				if (camsettings[n].quality == currentCameraQuality){
					return camsettings[n];
				}
			}
			return camsettings[0];
		}
		
		/**
		 * Changing loudspeaker value
		 * @param	value int -1, switch, 0 - off, 1 - on
		 */
		static public function changeLoudspeaker(value:int =-1):void{
			if (callVO == null || callVO.uid == null)
				return;
			callVO.loudspeaker = (value ==-1)? !callVO.loudspeaker:((value == 0)?false:true);
			switchSpkeakers(callVO.loudspeaker);
			S_CALLVO_CHANGED.invoke();
		}
		
		/**
		 * Меняем качество связи
		 * @param	val
		 */
		static public function changeQuality(val:String):void{
			if (MobileGui.centerScreen.currentScreenClass != TalkScreenRecognition && MobileGui.centerScreen.currentScreenClass != TalkScreen && MobileGui.centerScreen.currentScreenClass != VideoRecognitionScreen && MobileGui.centerScreen.currentScreenClass != VIChatScreen)
				return;
			
			var l:int = camsettings.length;
			var wasFound:Boolean = false;
			for (var n:int = 0; n < l; n++){
				if (camsettings[n].quality == val){
					wasFound = true;
					break;
				}
			}
			
			if (!wasFound)
				val = camsettings[0].quality;
			
			currentCameraQuality = val;
			createCamera();
			S_CALLVO_CHANGED.invoke();
			sendBroadcastMode();
		}
		
		
		/**
		 * Mute/Unmute microphone (trigger)
		 */
		static public function muteMicrophone():void{
			if (microphone == null)
				return;
			if (callVO == null)
				return;
			if (microphone.gain == 0)
				microphone.gain = gain;
					else
						microphone.gain = 0;
						
			callVO.mute = microphone.gain == 0;
			S_CALLVO_CHANGED.invoke();
		}
		
		/**
		 * Changing camera
		 * @param	value int -1, switch, 0 - back, 1 - front
		 */
		static public function changeCamera(value:int =-1):void{
			if (callVO == null || callVO.uid == null)
				return;
				
			if (callVO.mode == MODE_AUDIO)
				return;
			
			if (value<-1 || value>1)
				value = 0;
				
			if (value ==-1)
				value = (callVO.cameraIndex == 0)?1:0;
			
			callVO.cameraIndex = value;
			createCamera();
			S_CALLVO_CHANGED.invoke();
			sendBroadcastMode();
		}
		
				
		/**
		 * переключаем режимы локального звонка
		 */
		static public function changeLocalCallMode(mode:String = null):void{
			if(mode==null){
			if (callVO.mode == MODE_AUDIO)
				callVO.mode = MODE_VIDEO;
					else
						callVO.mode = MODE_AUDIO;
			}else{
				callVO.mode = mode;
				if (callVO.mode != MODE_AUDIO && callVO.mode != MODE_VIDEO)
					callVO.mode = MODE_AUDIO;
			}
			
			attachMedia();
			
			if (callVO.mode == MODE_VIDEO){
				if(callVO.loudspeaker==false){
					callVO.loudspeaker = true;
					switchSpkeakers(callVO.loudspeaker);
				}
				
			}else{
				if(callVO.loudspeaker==true){
					callVO.loudspeaker = false;
					switchSpkeakers(callVO.loudspeaker);
				}
			}
			
			S_CALLVO_CHANGED.invoke();
		}
		
	
		
		
		/**
		 * Переключаем динамики, создаем микрофон
		 * @param	loudspeaker - Boolean: if false - loadspeaker off
		 */
		static private function switchSpkeakers(loudspeaker:Boolean):void {
			loudspeaker = true;
			microphone = null;
			if (outgoingNS != null) {
				outgoingNS.attachAudio(null);
				
				// if (callVO.loudspeaker == true && callVO.farEncMic && callVO.nearEncMic) {
				if (callVO.farEncMic && callVO.nearEncMic && loudspeaker) {
					echo("CallManager", "switchSpkeakers","use Enchanced Microphone");	
					try {
						microphone = Microphone.getEnhancedMicrophone();
					} catch (e:Error) {
						echo("CallManager", "switchSpkeakers", "can`t get enc mic");
					}
				}
				
				
				try {
					microphone = Microphone.getEnhancedMicrophone();
				} catch (e:Error) {
					echo("CallManager", "switchSpkeakers", "can`t get enc mic");
				}
				
				
				if (microphone == null) {
					microphone = Microphone.getMicrophone();
					if (microphone != null)
					{
						microphone.setUseEchoSuppression(true);
					}
					
				}
				
				if (microphone != null)
				{
					microphone.setSilenceLevel(0);
					microphone.encodeQuality = encodeQuality;
					microphone.framesPerPacket = framesPerPacket;
					microphone.rate = rate;
					microphone.codec = soundCodec;
					microphone.gain = gain;
				}
			}
			
			//echo("CallManager", "switchSpkeakers", "callVO.farEncMic: " + callVO.farEncMic + "; callVO.nearEncMic: " + callVO.nearEncMic + "; loudspeaker: " + loudspeaker);
			if (loudspeaker == true) {
				SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
				if (!Config.PLATFORM_APPLE) {
					SoundMixer.useSpeakerphoneForVoice = true; // Do not set on ios ? 
				}
			}else {
				SoundMixer.audioPlaybackMode = AudioPlaybackMode.VOICE;
				if (!Config.PLATFORM_APPLE) {
					SoundMixer.useSpeakerphoneForVoice = false; // if You are on iOS and other is iOS - do not set use speakeerphone for voice to true ( according to Adobe Documentation) 
				}
			}
			
			if (outgoingNS != null)
				outgoingNS.attachAudio(microphone);
		}
		
		static private function nsStatus(e:StatusEvent):void{
			echo("CallManager", "nsStatus", e.code);
		}
		
		static private function onNetData(e:NetDataEvent):void { }
		
		
		// Отслеживаем netStatus
		static private function ncNetStatus(e:NetStatusEvent):void{
			if(e.info)
				sendClientNetInfo(e.info);

			if(e.info.code == NetStatus.NC_CONNECT_SUCCESS){
				echo("CallManager", "ncNetStatus", "Connected");
				startPublishing();
				return;
			}
			
			//TODO - net closed, failed, rejectd
			
			if(e.info.code == NetStatus.NC_CONNECT_FAIL){
				echo("CallManager", "ncNetStatus", "FAIL");
				networkError(e.info);
				return;
			}
			
			// не факт что это конец разговора
			if(e.info.code == NetStatus.NS_PLAY_STREAM_NOT_FOUND){
				echo("CallManager", "ncNetStatus", "NS_PLAY_STREAM_NOT_FOUND");
				return;
			}
			
			if(e.info.code == NetStatus.NS_PLAY_RESET){
				echo("CallManager", "ncNetStatus", "NS_PLAY_RESET");
				return;
			}
			
			if(e.info.code == NetStatus.NS_VIDEO_DIMM_CHANGE){
				echo("CallManager", "ncNetStatus", "NS_PLAY_RESET");
				S_VIDEO_SIZE_CHANGED.invoke();
				return;
			}
			
			if(e.info.code == NetStatus.NS_PLAY_START){
				echo("CallManager", "ncNetStatus", "NS_PLAY_START");
				return;
			}
			
			if(e.info.code == NetStatus.NS_PUBLISH_START){
				echo("CallManager", "ncNetStatus", "NS_PUBLISH_START");
				return;
			}
			
			if (e.info.code == NetStatus.NS_PLAY_PUBLISH_NOTIFY){
				echo("CallManager", "ncNetStatus", "NS_PLAY_PUBLISH_NOTIFY");
				return;
			}
			
			echo("CallManager", "ncNetStatus",e.info.code);
		}
		
		static private function ncSecError(e:SecurityErrorEvent):void{
			echo("CallManager", "ncSecError", e.text, true);
			networkError(e.text);
		}
		
		static private function ncIoError(e:IOErrorEvent):void{
			echo("CallManager", "ncIoError", e.text, true);
			networkError(e.text);
		}
		
		static private function ncAsyncError(e:AsyncErrorEvent):void{
			echo("CallManager", "ncAsyncError", e.text, true);
			networkError(e.text);
		}
		
		public static function getTotalVideoRecognitionStates():int{
			return totalVideoRecognitionStates;
		}
		
		public static function getMicrophone():Microphone{
			return microphone;
		}
		
		static public function getNC():NetConnection {
			return nc;
		}
		
		static public function setMicrophoneMuted(val:Boolean):void {
			microphoneMuted = val;
		}
		
		static public function sendRtoResponse(accepted:Boolean, rto:RtoAgreementData):void {
			var method:String;
			if (accepted == true) {
				method = "call_rtoAccept";
			}else {
				method = "call_rtoDecline";
			}
			
			var rtoData:Object = {};
			if (rto != null) {
				rtoData = rto.toObject();
			}
			
			WSClient.call_blackHole([callVO.uid, Auth.uid], method, { data:rtoData } )
		}
	}
}