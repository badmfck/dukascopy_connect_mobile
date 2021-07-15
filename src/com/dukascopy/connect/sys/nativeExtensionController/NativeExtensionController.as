package com.dukascopy.connect.sys.nativeExtensionController {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.data.SystemInfo;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.WebViewScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenChangePayPassDialog;
	import com.dukascopy.connect.screens.dialogs.UseFingerprintDialog;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.handler.IDataHandler;
	import com.dukascopy.connect.sys.nativeExtensionController.handler.MapDataHandler;
	import com.dukascopy.connect.sys.notificationManager.PushNotificationsNative;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayAuthManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.touchID.TouchIDManager;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.utils.FilesSaveUtility;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.chat.VideoMessageVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.dukascopyextension.DukascopyExtensionAndroid;
	import com.dukascopy.langs.Lang;
	import com.freshplanet.ane.KeyboardSize.MeasureKeyboard;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import connect.DukascopyExtension;
	import flash.desktop.NativeApplication;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import ru.flashpress.uid.FPUniqueId;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class NativeExtensionController {
		
		static public var S_ORIENTATION_CHANGE:Signal = new Signal("NativeExtensionController.S_ORIENTATION_CHANGE");
		static public var S_PERMISSION:Signal = new Signal("NativeExtensionController.S_PERMISSION");
		static public var S_NATIVE_ERROR:Signal = new Signal("NativeExtensionController.S_NATIVE_ERROR");
		static public var S_LOCATION:Signal = new Signal("NativeExtensionController.S_LOCATION");
		static public var S_SPEECH:Signal = new Signal("NativeExtensionController.S_SPEECH");
		static public var S_NETWORK:Signal = new Signal("NativeExtensionController.S_NETWORK");
		
		static public var S_MRZ_RESULT:Signal = new Signal("NativeExtensionController.S_MRZ_RESULT");
		static public var S_MRZ_ERROR:Signal = new Signal("NativeExtensionController.S_MRZ_ERROR");
		static public var S_MRZ_STOPPED:Signal = new Signal("NativeExtensionController.S_MRZ_STOPPED");
		static public var S_WEB_VIEW_SIGNAL:Signal = new Signal("NativeExtensionController.S_WEB_VIEW_SIGNAL");
		static public var S_DEVICE_INFO:Signal = new Signal("NativeExtensionController.S_DEVICE_INFO");
		static public var S_SYSTEM_INFO:Signal = new Signal("NativeExtensionController.S_SYSTEM_INFO");
		static public var S_WEB_VIEW_CLOSED:Signal = new Signal("NativeExtensionController.S_WEB_VIEW_CLOSED");
		static public var S_PIN:Signal = new Signal("NativeExtensionController.S_PIN");
		static public var S_PIN_ERROR:Signal = new Signal("NativeExtensionController.S_PIN_ERROR");
		static public var S_PIN_ACTION:Signal = new Signal("NativeExtensionController.S_PIN_ACTION");
		
		public static var touchIDManager:TouchIDManager;
		static private var _oldOrientation:String;
		static private var pendingPushMessages:Array;
		static private var pendingMessages:Array;
		static public var deviceInfo:DeviceInfo;
		
		static public const PICK_MEDIA:String = "pickMedia";
		static public const VIDEO_PLAYER:String = "videoPlayer";
		
		static public const RECORD_SOUND_PERMISSIONS:String = "recordSoundPermissions";
		static public const CAMERA_PERMISSIONS:String = "cameraPermissions";
		
		static public const NATIVE_ERROR_NEED_CONTACTS_PERMISSION:String = "needContactsPermissions";
		static public const MAP_SET_USER_POSITION:String = "mapSetUserPosition";
		static public const MAP_SHOW:String = "show";
		static public const STORAGE_PERMISSIONS:String = "storsagePermission";
		static public var payPassByFingerprint:Boolean;
		static public var open_link_in_browser_mark:String = "Codes-List";
		
		public function NativeExtensionController() {
			
		}
		
		public static function init():void {
			if (Config.PLATFORM_APPLE) {
				try {
					MobileGui.dce = new DukascopyExtension();
					MobileGui.dce.registerForMemoryWarning();
					MobileGui.dce.setupAVAudioSession();
					/*if (Style.boolean(Style.LIGHT_STATUS_BAR))
					{
						MobileGui.dce.setLightStatusBarStyle();
					} else {
						MobileGui.dce.setDarkStatusBarType();
					}*/
					MobileGui.dce.initReachabilityManager();
					MobileGui.dce.setupOrientationChangeObserver();
					var r:Boolean = MobileGui.dce.isReachable();
					MobileGui.dce.addEventListener(StatusEvent.STATUS, extensionStatusHandler);
					touchIDManager = new TouchIDManager();
					FilesSaveUtility.init(MobileGui.dce);
					if (MobileGui.dce != null && Config.webRTCAvaliable == true) {
						MobileGui.dce.setupWebRTC();
					}
				} catch (err:Error) {
					echo("MobileGui", "constructor", err.message);
				}
			} else if (Config.PLATFORM_ANDROID) {
				PayAPIManager.S_LOGIN_SUCCESS.add(onPaymentLogin);
				try {
					MobileGui.androidExtension = new DukascopyExtensionAndroid();
					MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
					NativeExtensionController.setStatusBarColor(Style.color(Style.STATUS_COLOR));
					MobileGui.androidExtension.initNotifications(getNotificationsStrings());
				} catch (errr:Error) {
					echo("MobileGui", "constructor", errr.message);
				}
			}
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onAppExit);
			Auth.S_NEED_AUTHORIZATION.add(clear);
			PayAuthManager.S_ON_PASS_CHANGE_SUCCESS.add(onOayPassChanged);
			PayManager.S_PASS_CHANGE_RESPOND.add(onOayPassChanged);
		}
		
		static private function onOayPassChanged(respond:PayRespond):void {
			if (respond.error == false) {
				if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null) {
					MobileGui.androidExtension.fingerprint_clear();
				} else if(Config.PLATFORM_APPLE == true && MobileGui.dce != null && touchIDManager != null) {
					touchIDManager.clear(true);
					touchIDManager.removeCurrent();
				}
			}
		}
		
		static private function getNotificationsStrings():String {
			var strings:Object = new Object();
			strings.newMessage_1 = Lang.newMessage_1;
			strings.newMessage_2 = Lang.newMessage_2;
			strings.newMessage_5 = Lang.newMessage_5;
			var result:String = JSON.stringify(strings);
			return result;
		}
		
		static private function clear():void {
			pendingPushMessages = null;
			if (Config.PLATFORM_ANDROID == true) {
				MobileGui.androidExtension.clearNotificationsData();
			}
			clearFingerprint();
		}
		
		static private function onPaymentLogin(loginData:Object):void {
			if (loginData != null && "data" in loginData && loginData.data != null && "password" in loginData.data && loginData.data.password != null)
			{
				Store.load(Store.DONT_ASK_FINGERPRINT, 
					function(data:Boolean, error:Boolean):void
					{
						if (error == true || data == false)
						{
							Store.load(Store.USE_FINGERPRINT, 
								function(data:Boolean, error:Boolean):void
								{
									if (error == true || data == false)
									{
										if (DialogManager.hasOpenedDialog == true && MobileGui.dialogScreen.currentScreenClass == ScreenChangePayPassDialog)
										{
											return;
										}
										DialogManager.showDialog(UseFingerprintDialog, {title:Lang.login, text:Lang.loginByFingerprint, buttonSecond:Lang.CANCEL, callBack:
											function(val:int, dontAskAgain:Boolean = false):void
											{
												if (val == 1)
												{
													savePin(loginData.data.password);
													Store.save(Store.USE_FINGERPRINT, true);
												}
												else
												{
													Store.save(Store.USE_FINGERPRINT, false);
												}
												if (dontAskAgain == true)
												{
													Store.save(Store.DONT_ASK_FINGERPRINT, true);
												}
										}});
									}
									else
									{
										if (Config.PLATFORM_ANDROID && MobileGui.androidExtension.fingerprint_pinExist() == false && MobileGui.androidExtension.fingerprint_avaliable() == true)
										{
											savePin(loginData.data.password);
										}
									}
								}
							);
						}
						else
						{
							if (Config.PLATFORM_ANDROID && MobileGui.androidExtension.fingerprint_pinExist() == false && MobileGui.androidExtension.fingerprint_avaliable() == true)
							{
								savePin(loginData.data.password);
							}
						}
					}
				);
			}
		}
		
		static private function fingerprintStatusLoaded():void 
		{
			
		}
		
		static private function savePin(pass:String):void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.fingerprint_savePin(pass);
			}
		}
		
		private static function extensionStatusHandler(e:StatusEvent):void
		{
			switch (e.code)
			{
				case "systemNotification": 
				{
					if (e.level == "didReceiveMemoryWarning")
						cleanMemoryNow();
					break;
				}
				case "mrz_result": {
					S_MRZ_RESULT.invoke(e.level);
					break;
				}
				case "mrz_error": {
					S_MRZ_ERROR.invoke(e.level);
					break;
				}
				case "mrz_stopped": {
					S_MRZ_STOPPED.invoke();
					break;
				}
				case "deviceInfo": {
					
					var deviceInfoData:Object
					try
					{
						deviceInfoData = JSON.parse(e.level);
					}
					catch (e:Error)
					{
						
					}
					if (deviceInfoData != null)
					{
						deviceInfo = new DeviceInfo(deviceInfoData);
						S_DEVICE_INFO.invoke();
					}
					
					break;
				}
				case "didAddVideoToCameraRoll": 
				{
					var path:String = e.level;
					ToastMessage.display(Lang.videoSaveSuccess);
					break;
				}
				case "orientationChaged": 
				{
					
					/*
					   0	UIDeviceOrientationUnknown,
					   1	UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
					   2	UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
					   3	UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
					   4	UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
					   5	UIDeviceOrientationFaceUp,              // Device oriented flat, face up
					   7	U6IDeviceOrientationFaceDown
					 */
					
					var orientation:String = StageOrientation.DEFAULT;
					
					if (e.level == "0" || e.level == "1" || e.level == "2")
					{
						orientation = StageOrientation.DEFAULT;
					}
					else if (e.level == "3")
					{
						orientation = StageOrientation.ROTATED_LEFT;
					}
					else if (e.level == "4")
					{
						orientation = StageOrientation.ROTATED_RIGHT;
					}
					else if (e.level == "5")
					{
						orientation = MobileGui.currentOrientation;
					}
					_oldOrientation = MobileGui.currentOrientation;
					MobileGui.setCurrentOrientation(orientation);
					
					if (_oldOrientation != MobileGui.currentOrientation)
					{
						S_ORIENTATION_CHANGE.invoke();
					}
					
					break;
				}
				default: 
				{
					touchIDManager.extensionStatusHandler(e);
					break;
				}
			}
		}
		
		private static function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			switch (e.code) {
				
				case "filePicker": {
					trace("file:", "imagePicker");
					var resultData:Object;
					try
					{
						resultData = JSON.parse(e.level);
					}
					catch (e:Error)
					{
						
					}
					if (resultData != null)
					{
						if (resultData.signal == "didPick")
						{
							trace("file:", "didPick");
							if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null)
							{
								var mediaFileData:MediaFileData = new MediaFileData();	
								var file:File = new File(resultData.path);
								if (file.exists)
								{
									trace("file:", "File: " + resultData.path);
									mediaFileData.path = resultData.path;
									mediaFileData.id = resultData.path;
									
									var filePath:String = resultData.path;
									var filename:String = filePath;
									
									if (filePath != null)
									{
										var delimiter:String = "/";
										if (filePath.indexOf("/") != -1)
										{
											delimiter = "/";
										}
										else if (filePath.indexOf("\\") != -1)
										{
											delimiter = "\\";
										}
										var res:Array = filePath.split(delimiter);
										if (res != null && res.length > 0)
										{
											filename = res[res.length - 1]
										}
									}
									
									mediaFileData.setOriginalName(filename);
									mediaFileData.chatUID = resultData.chatUID;
									var chat:ChatVO = ChatManager.getChatByUID(resultData.chatUID);
									if (chat != null)
									{
										mediaFileData.key = chat.securityKey;
									}
									mediaFileData.localResource = resultData.path;
									
									mediaFileData.type = MediaFileData.MEDIA_TYPE_FILE;
									PhotoGaleryManager.S_GALLERY_MEDIA_LOADED.invoke(mediaFileData);
								}
							}
						}
						else if (resultData.signal == "didCancel")
						{
							
						}
					}
					break;
				}
				case "webViewClose": 
				{
					echo("webview: webViewClose", e.level);
					S_WEB_VIEW_CLOSED.invoke(e.level);
					break;
				}
				case "systemInfo": {
					
					var systemInfoData:Object
					try
					{
						systemInfoData = JSON.parse(e.level);
					}
					catch (e:Error)
					{
						
					}
					if (systemInfoData != null)
					{
						S_SYSTEM_INFO.invoke(new SystemInfo(systemInfoData));
					}
					
					break;
				}
				/*case "testInput": 
				{
					sendToMe(e.level);
					break;
				}*/
				case "video": {
					if (e.level == "saveSuccess")
						ToastMessage.display(Lang.videoSaveSuccess);
					else if (e.level == "saveError")
						ToastMessage.display(Lang.videoSaveFail);
					break;
				}
				case "soundPermissionResult": {
					if (e.level == "true")
						S_PERMISSION.invoke(RECORD_SOUND_PERMISSIONS, true);
					else if (e.level == "false")
						S_PERMISSION.invoke(RECORD_SOUND_PERMISSIONS, false);
					break;
				}
				case "errorMessage": {
					if (e.level == NATIVE_ERROR_NEED_CONTACTS_PERMISSION)
						S_NATIVE_ERROR.invoke(NATIVE_ERROR_NEED_CONTACTS_PERMISSION);
					break;
				}
				case "SECTOR_MAP": {
					var handler:IDataHandler = new MapDataHandler();
					handler.handle(e.level);
					break;
				}
				case "speech": {
					S_SPEECH.invoke(e.level);
					break;
				}
				
				case "network": {
					S_NETWORK.invoke(e.level == "true");
					break;
				}
				
				case "token": {
					PushNotificationsNative.setToken(e.level);
					break;
				}
				
				case "mrz_result": {
					S_MRZ_RESULT.invoke(e.level);
					break;
				}
				case "mrz_error": {
					S_MRZ_ERROR.invoke(e.level);
					break;
				}
				case "mrz_stopped": {
					S_MRZ_STOPPED.invoke();
					break;
				}
				case "deviceInfo": {
					
					var deviceInfoData:Object
					try
					{
						deviceInfoData = JSON.parse(e.level);
					}
					catch (e:Error)
					{
						
					}
					if (deviceInfoData != null)
					{
						deviceInfo = new DeviceInfo(deviceInfoData);
						S_DEVICE_INFO.invoke();
					}
					
					break;
				}
				case "webViewSignal": {
					
					echo("webview: webViewSignal", e.level);
					var webViewData:Object;
					try
					{
						webViewData = JSON.parse(e.level);
						S_WEB_VIEW_SIGNAL.invoke(
													{
														signal : webViewData.signal,
														params : webViewData.params
													});
					}
					catch (error:Error)
					{
						ApplicationErrors.add();
					}
					
					S_MRZ_STOPPED.invoke();
					break;
				}
				case "cameraPermissionResult": {
					if (e.level == "true")
						S_PERMISSION.invoke(CAMERA_PERMISSIONS, true);
					else if (e.level == "false")
						S_PERMISSION.invoke(CAMERA_PERMISSIONS, false);
					break;
				}
				
				case "storagePermissionResult": {
					if (e.level == "true")
						S_PERMISSION.invoke(STORAGE_PERMISSIONS, true);
					else if (e.level == "false")
						S_PERMISSION.invoke(STORAGE_PERMISSIONS, false);
					break;
				}
				
				case "fingerprint_success": {
					S_PIN.invoke(true, e.level);
					break;
				}
				case "fingerprint_failed": {
					S_PIN.invoke(false, null, Lang.tryAgain);
					break;
				}
				case "fingerprint_error": {
					var data:Object;
					var errorText:String;
					try{
						data = JSON.parse(e.level);
						if (data != null)
						{
							errorText = getFingerprintError(data.errMsgId);
						}
					}
					catch (e:Error)
					{
						
					}
					
					S_PIN_ERROR.invoke(false, null, errorText);
					break;
				}
				case "fingerprint_info": {
					S_PIN_ACTION.invoke(e.level);
					break;
				}
			}
		}
		
		static public function sendToMe(text:String):void 
		{
			return;
			var date:Date = new Date();
			
		//	MobileGui.traceText(date.getMinutes() + ":" + date.getSeconds() + " | " + date.getMilliseconds() + "    " + text);
			
		//	return;
			var existingChat:ChatVO = ChatManager.getChatWithUsersList(["I6D0DqWRDmWU"]);
			if (existingChat != null && existingChat.uid != null && existingChat.uid.length != 0 && WS.connected)
			{
				if (pendingMessages != null)
				{
					for (var i:int = 0; i < pendingMessages.length; i++) 
					{
						ChatManager.sendMessageToOtherChat(pendingMessages[i], existingChat.uid, existingChat.securityKey, false);
					}
					pendingMessages = null;
				}
				
				ChatManager.sendMessageToOtherChat(date.getMinutes() + ":" + date.getSeconds() + " | " + date.getMilliseconds() + "    " + text, existingChat.uid, existingChat.securityKey, false);
			}
			else
			{
				if (pendingMessages == null)
				{
					pendingMessages = new Array();
				}
				
				pendingMessages.push(date.getMinutes() + ":" + date.getSeconds() + " | " + date.getMilliseconds() + "    " + text);
				
				if (existingChat == null)
				{
					PHP.chat_start(onChatLoadedFromPHPAndOpen, ["I6D0DqWRDmWU"], false, "SendMessageToUserAction");
				}
			}
		}
		
		static private function onChatLoadedFromPHPAndOpen(phpRespond:PHPRespond):void {
			if (phpRespond.error == true)
			{
				ToastMessage.display(phpRespond.errorMsg);
			}
			else if (phpRespond.data == null)
			{
				
			}
			else
			{
				var c:ChatVO = ChatManager.getChatByUID(phpRespond.data.uid);
				
				if (c == null) {
					c = new ChatVO(phpRespond.data);
					
				} else
					c.setData(phpRespond.data);
				
				if (pendingMessages != null && WS.connected)
				{
					for (var i:int = 0; i < pendingMessages.length; i++) 
					{
						ChatManager.sendMessageToOtherChat(pendingMessages[i], c.uid, c.securityKey, false);
					}
					pendingMessages = null;
				}
			}
			
			phpRespond.dispose();
		}
		
		private static function getFingerprintError(errorCode:int):String
		{
			switch(errorCode)
			{
				case 1:
				{
					return Lang.fingerprintError_hardwareUnavaliable;
					break;
				}
				case 2:
				{
					return Lang.fingerprintError_unableProcess;
					break;
				}
				case 3:
				{
					return Lang.fingerprintError_timeout;
					break;
				}
				case 4:
				{
					return Lang.fingerprintError_noSpace;
					break;
				}
				case 5:
				{
					return Lang.fingerprintError_sensorUnavaliable;
					break;
				}
				case 6:
				{
					return Lang.fingerprintError_systemError;
					break;
				}
				case 7:
				{
					return Lang.fingerprintError_tooManyAttempts;
					break;
				}
				case 9:
				{
					return Lang.fingerprintError_tooManyAttempts;
					break;
				}
			}
			return null;
		}
		
		private static function cleanMemoryNow():void
		{
			System.gc();
		}
		
		static private function onAppExit(e:Event):void 
		{
			if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				if (Config.webRTCAvaliable == true && MobileGui.dce != null)
				{
					MobileGui.dce.cleanupWebRTC();
				}
			//	MobileGui.dce.cleanupWebRTC();
			}
		}
		
		static public function setAuthKey(authKey:String):void 
		{
			if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				if (authKey == null)
				{
					MobileGui.dce.removeAuthKeyInKeychain();
				}
				else
				{
					MobileGui.dce.updateAuthKeyInKeychain(authKey);
				}
			}
		}
		
		static public function updateLanguageData():void 
		{
			if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				var keys:Array = [];
				
				keys["voice.permission.description"] = Lang.voicePermission;
				keys["voice.permission.title"] = Lang.sendVoiceToFriends;
				keys["voice.permission.denied.description"] = Lang.voicePermissionDenied;
				keys["voice.permission.denied.title"] = Lang.startSendVoice;
				
				keys["photo.permission.denied.title"] = Lang.startSendPhoto;
				keys["photo.permission.denied.description"] = Lang.photoPermissionDenied;
				keys["photo.permission.title"] = Lang.sendPhotoToFriends;
				keys["photo.permission.description"] = Lang.photoPermission;
				
				keys["voice.record"] = Lang.holdToRecord;
				keys["voice.cancel"] = Lang.releaseToCancel;
				keys["voice.release"] = Lang.releaseToSend;
				
				keys["attach.view.makePhoto"] = Lang.textCamera;
				keys["attach.view.sendInvoice"] = Lang.sendInvoice;
				keys["attach.view.photoGallery"] = Lang.photoGallery;
				keys["attach.view.sendVoice"] = Lang.addPuzzle;
				keys["attach.view.sendMoney"] = Lang.sendMoney;
				
				keys["button.grant.access"] = Lang.grantAccess;
				keys["button.openSettings"] = Lang.openSettings;
				
				keys["attach.view.sendGift"] = Lang.sendGift;
				keys["attach.view.praiseNow"] = Lang.praiseNow;
				keys["attach.view.skip"] = Lang.skip;
				keys["attach.view.next"] = Lang.textNext;
				
				keys["attach.view.giftsTitleStep1"] = Lang.giftsTitleStep1;
				keys["attach.view.giftsTextStep1"] = Lang.giftsTextStep1;
				keys["attach.view.giftsTitleStep2"] = Lang.giftsTitleStep2;
				keys["attach.view.giftsTextStep2"] = Lang.giftsTextStep2;
				keys["attach.view.giftsTitleStep3"] = Lang.giftsTitleStep3;
				keys["attach.view.giftsTextStep3"] = Lang.giftsTextStep3;
				
				keys["record.video.view.title"] = Lang.sendTo;
				keys["record.video.view.send"] = Lang.textSend;
				
				keys["video.recording.permission.title"] = Lang.shereOnDukascopy;
				keys["video.recording.permission.description"] = Lang.enableCameraAccess;
				
				keys["video.recording.permission.camera.enabled"] = Lang.cameraEnabled;
				keys["video.recording.permission.mic.enabled"] = Lang.micEnambled;
				
				keys["video.recording.permission.camera.disabled"] = Lang.cameraAccess;
				keys["video.recording.permission.mic.disabled"] = Lang.micAccess;
				
				var text:String = "";
				
				for (var key:String in keys)
				{
					text += '"' + key + '"="' + keys[key] + '"; \n';
				}
				
				var file:File = File.applicationStorageDirectory.resolvePath("dukascopy.strings");
				var stream:FileStream = new FileStream();
				try {
					stream.open(file, FileMode.WRITE);
					stream.writeUTFBytes(text);
					stream.close();
					
					MobileGui.dce.updateLocalization(file.nativePath);
				}
				catch (error:Error)
				{
					
				}
			}
		}
		
		static public function showVideo(video:VideoMessageVO, title:String):void 
		{
			if (title == null)
			{
				title = "";
			}
			if (video != null && video.loaded == true)
			{
				if (Config.PLATFORM_APPLE)
				{
					MobileGui.dce.playVideoInFullScreen(video.getVideo());
				}
				else if(Config.PLATFORM_ANDROID)
				{
					if (getVersion() <= 19)
					{
						DialogManager.alert("", Lang.unsupportedAndroidVersion);
						return;
					}
					
					var videoPath:String;
					
					if (video.localResource != null)
					{
						var file:File = new File(video.localResource);
						if (file.exists)
						{
							videoPath = video.localResource;
						}
						else
						{
							videoPath = video.getVideo();
						}
						file = null;
					}
					else
					{
						videoPath = video.getVideo();
					}
					var videoName:String = "";
					if (video.title != null)
					{
						videoName = video.title;
					}
					MobileGui.androidExtension.showVideo(videoPath, title, videoName, getStrings(VIDEO_PLAYER));
				}
			}
		}
		
		static public function getStrings(type:String):String 
		{
			var strings:Object;
			switch(type)
			{
				case PICK_MEDIA:
				{
					strings = new Object();
					strings.title = Lang.chooseMediaFile;
					strings.videos = Lang.textVideos;
					strings.images = Lang.textImages;
					return JSON.stringify(strings);
					break;
				}
				case VIDEO_PLAYER:
				{
					strings = new Object();
					strings.successSaveVideo = Lang.videoSaveSuccess;
					strings.failSaveVideo = Lang.videoSaveFail;
					strings.save = Lang.textSave;
					strings.saved = Lang.textSaved;
					return JSON.stringify(strings);
					break;
				}
			}
			return null;
		}
		
		static public function removeFile(path:String):void 
		{
			if (Config.PLATFORM_APPLE)
			{
				MobileGui.dce.removeFile(path);
			}
		}
		
		static public function saveVideo(value:VideoMessageVO):void {
			if (value != null) {
				
				value.saveAvaliable = false;
				
				ToastMessage.display(Lang.videoSaving);
				
				var videoName:String = "";
				if (value.title != null)
					videoName = value.title;
				if (Config.PLATFORM_APPLE == true)
					MobileGui.dce.addVideoToCameraRoll(value.getVideo());
				else if (Config.PLATFORM_ANDROID == true)
				{
					if (getVersion() <= 19)
					{
						DialogManager.alert("", Lang.unsupportedAndroidVersion);
						return;
					}
					MobileGui.androidExtension.saveVideo(value.getVideo(), videoName);
				}
			}
		}
		
		static public function requestSoundPermission():void {
			if (Config.PLATFORM_ANDROID == true) {
				if (getVersion() <= 19)
				{
					DialogManager.alert("", Lang.unsupportedAndroidVersion);
					return;
				}
				MobileGui.androidExtension.requestSoundPermission();
			}
		}
		
		static public function requestStoragePermission():void {
			if (Config.PLATFORM_ANDROID == true) {
				if (getVersion() <= 19)
				{
					DialogManager.alert("", Lang.unsupportedAndroidVersion);
					return;
				}
				MobileGui.androidExtension.requestStoragePermission();
			}
		}
		
		static public function shareText(message:String):void {
			if (Config.PLATFORM_ANDROID == true) {
				MobileGui.androidExtension.shareText(message);
			}
			else if (Config.PLATFORM_APPLE == true) {
				MobileGui.dce.showShareSheet(message);
			}
		}
		
		static public function onUserLocation(user:ChatUserVO, location:Location):void 
		{
			var data:Object = new Object();
			data.userUID = user.uid;
			data.avatar = user.avatarURL;
			data.lat = location.latitude;
			data.lon = location.longitude;
			MobileGui.androidExtension.callMap(MAP_SET_USER_POSITION, data);
		}
		
		static public function showMap():void 
		{
			MobileGui.androidExtension.callMap(MAP_SHOW);
		}
		
		static public function vibrate():void 
		{
			if (Config.PLATFORM_ANDROID == true) {
				MobileGui.androidExtension.vibrate();
			}
		}
		
		static public function getVersion():int 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				return MobileGui.androidExtension.getVersion();
			}
			return 0;
		}
		
		static public function openSettings():void 
		{
			if (Config.PLATFORM_APPLE)
			{
				navigateToURL(new URLRequest("app-settings:root=Privacy&path=LOCATION"));
			}
			else if(Config.PLATFORM_ANDROID){
				MobileGui.androidExtension.showAppSettings();
			}
		}
		
		static public function listenSpeech():void 
		{
			if (Config.PLATFORM_APPLE)
			{
				
			}
			else if (Config.PLATFORM_ANDROID)
			{
				MobileGui.androidExtension.startSpeech();
			}
		}
		
		static public function stopListenSpeech():void 
		{
			if (Config.PLATFORM_APPLE)
			{
				
			}
			else if (Config.PLATFORM_ANDROID)
			{
				MobileGui.androidExtension.stopSpeech();
			}
			else{
				
			}
		}
		
		static public function tryGetGeoPermission():void 
		{
			if (Config.PLATFORM_ANDROID)
			{
			//	MobileGui.androidExtension.tryGetGeoPermission();
			}
		}
		
		static public function startMrz():void 
		{
			if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.startMRZ(Lang.positionDocumentInFrame, Lang.begin);
			}
			else if (Config.PLATFORM_APPLE){
				//MobileGui.dce.startMRZ(Lang.positionDocumentInFrame, Lang.textBack);
			}
		}
		
		static public function stopMrz():void{
			if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null){
				MobileGui.androidExtension.stopMRZ();
			}else if (Config.PLATFORM_APPLE){
				//MobileGui.dce.stopMrz();
			}
		}
		
		static public function getCameraPermissions():void{
			if (MobileGui.androidExtension != null)
				MobileGui.androidExtension.getCameraPermissions();
		}
		
		static public function stopIncomingCallSound():void{
			if (MobileGui.androidExtension != null)
				MobileGui.androidExtension.stopIncomeSound();
		}
		
		static public function playIncomingCallSound():void{
			if (MobileGui.androidExtension != null)
			{
				TweenMax.killDelayedCallsTo(MobileGui.androidExtension.playIncomeSound);
				TweenMax.delayedCall(0.5, MobileGui.androidExtension.playIncomeSound);
			}
		}
		
		static public function showWebView(url:String, title:String, currentScreen:Class = null, currentScreenData:Object = null):Boolean 
		{
			echo("webview: showWebView", url);
			if (Config.PLATFORM_ANDROID)
			{
				if (MobileGui.androidExtension != null)
					MobileGui.androidExtension.showWebView(url, title, open_link_in_browser_mark);
				else
					ApplicationErrors.add();
				
				return true;
			}
			else
			{
				MobileGui.changeMainScreen(
						WebViewScreen,
						{
							title:title,
							backScreen:currentScreen,
							link:url,
							backScreenData:currentScreenData
						}
					);
			}
			return false;
		}
		
		static public function callWebView(data:String, clear:Boolean):void 
		{
			echo("webview: callWebView", data);
			if (MobileGui.androidExtension != null)
				MobileGui.androidExtension.callwWebView(data, clear);
		}
		
		static public function getCameraOrientation(front:Boolean):Number 
		{
			return MobileGui.androidExtension.getCameraOrientation(front);
		}
		
		static public function getDeviceInfo():void 
		{
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.getDeviceInfo();
			}
		}
		
		static public function getSystemInfo():void 
		{
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.getPhoneInfo();
			}
		}
		
		static public function getIsRealDevice():Object 
		{
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				var string:String = MobileGui.androidExtension.getIsRealDevice();
				if (string != null)
				{
					var data:Object;
					try
					{
						data = JSON.parse(string);
					}
					catch (e:Error)
					{
						
					}
					if (data != null)
					{
						return data;
					}
				}
			}
			return null;
		}
		
		static public function speakMessage(text:String):void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.speakText(text);
			}
		}
		
		static public function lightOn():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.addLight();
			}
		}
		
		static public function lightOff():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.lightOff();
			}
		}
		
		static public function baseCamera():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.baseCamera();
			}
		}
		
		static public function bankPinExist():Boolean 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				return MobileGui.androidExtension.fingerprint_pinExist();
			}
			return true;
		}
		
		static public function stopFingerprint():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.fingerprint_stopGetPin();
			}
		}
		
		static public function startListenFingerprint():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.fingerprint_getPin();
			}
		}
		
		static public function clearFingerprint():void 
		{
			Store.remove(Store.DONT_ASK_FINGERPRINT);
			Store.remove(Store.USE_FINGERPRINT);
			
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.fingerprint_clear();
			}
			else if(Config.PLATFORM_APPLE == true && MobileGui.dce != null && touchIDManager != null)
			{
				touchIDManager.clear(true);
				touchIDManager.removeCurrent();
			}
		}
		
		static public function saveFileToDownloadFolder(url:String, openFile:Boolean = true):String {
			if (Config.PLATFORM_ANDROID == true) {
				MobileGui.preventScreenRemove = true;
				return MobileGui.androidExtension.moveToDownloadFolder(url, openFile);
			}
			return null;
		}
		
		static public function markChatRead(chat:ChatVO):void {
			if (chat != null) {
				if (Config.PLATFORM_ANDROID == true) {
					MobileGui.androidExtension.markChatRead(chat.uid);
				}
			}
		}
		
		static public function setStatusBarColor(color:Number):void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.setStatusBarColor(color);
			}
		}
		
		static public function isNotificationClicked():Boolean 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				return MobileGui.androidExtension.isNotificationClick()
			}
			
			return false;
		}
		
		static public function addPushMessage(messageData:Object, chatModel:ChatVO = null):void 
		{
			var messageObject:Object = new Object();
						if (messageData != null)
			{
				if (chatModel == null && "chat_uid" in messageData && messageData.chat_uid != null)
				{
					if (pendingPushMessages == null)
					{
						pendingPushMessages = new Array();
					}
					pendingPushMessages.push(messageData);
					ChatManager.S_CHAT_PREPARED.add(onChatLoaded);
					ChatManager.openChatByUID(messageData.chat_uid);
				}
				else
				{
					var userName:String = "";
					if ("user_name" in messageData)
					{
						if ("anonymous" in messageData && messageData.anonymous == true)
						{
							userName = Lang.textIncognito;
						}
						else
						{
							userName = messageData.user_name;
						}
					}
					
					if (chatModel && chatModel.type == ChatRoomType.COMPANY) {
						if (chatModel.title != null)
						{
							userName = chatModel.title;
						}
						else
						{
							userName = Lang.textSupport;
						}
					}
					messageObject.messageFrom = userName;
					
					if ("user_avatar" in messageData)
					{
						if (!("anonymous" in messageData) || messageData.anonymous == false)
						{
							messageObject.avatar = messageData.user_avatar;
						}
					}
					
					if ("text" in messageData)
					{
						messageObject.text = messageData.text;
					}
					
					if ("user_uid" in messageData)
					{
						messageObject.userUid = messageData.user_uid;
					}
					
					if ("id" in messageData)
					{
						messageObject.id = messageData.id;
					}
					
					if ("num" in messageData)
					{
						messageObject.num = messageData.num;
					}
					
					if ("chat_uid" in messageData)
					{
						messageObject.chatUID = messageData.chat_uid;
					}
					
					if (chatModel != null)
					{
						var messageVO:ChatMessageVO = new ChatMessageVO(messageData);
						messageVO.decrypt(chatModel.chatSecurityKey);
						messageObject.message = messageVO.text;
					}
					
					messageObject.type = "text";
					
					var messageString:String;
					try
					{
						messageString = JSON.stringify(messageObject);
					}
					catch (e:Error)
					{
						ApplicationErrors.add(e.message);
					}
					
					if (messageString != null && PushNotificationsNative.sleepMode == false)
					{
						MobileGui.androidExtension.addPushMessage(messageString);
					}
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		static public function getDeviceId():String 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				return MobileGui.androidExtension.getDeviceId();
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				return FPUniqueId.id;
			}
			return null;
		}
		
		static public function getKeyboardHeightDeprecated():int 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				return MobileGui.androidExtension.getKeyboardHeightDeprecated();
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				if (MeasureKeyboard.getInstance() != null)
				{
					MeasureKeyboard.getInstance().getKeyboardHeight();
				}
			}
			
			return 0;
		}
		
		static public function showWebViewReaction(link:String, action:String, id:String):void 
		{
			echo("webview: showWebViewReaction", link);
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.showWebViewReaction(link, action, id, "#" + (Style.color(Style.COLOR_BACKGROUND)).toString(16), "#" + (Style.color(Style.COLOR_ICON_SETTINGS)).toString(16));
			}
		}
		
		static public function onChatScreenClosed():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.onChatScreenClosed();
			}
		}
		
		static public function pickFile(chatUID:String):void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.pickFile(chatUID);
			}
			else if (Config.PLATFORM_WINDOWS)
			{
				var selector:File = new File();
				selector.addEventListener(Event.SELECT, onFileSelect);
				selector.browse();
			}
		}
		
		static public function playOutgoingCallSound():void 
		{
			if (MobileGui.androidExtension != null)
			{
				TweenMax.killDelayedCallsTo(MobileGui.androidExtension.playCallSound);
				TweenMax.delayedCall(0.5, MobileGui.androidExtension.playCallSound);
			}
		}
		
		static public function stopOutgoingCallSound():void 
		{
			if (MobileGui.androidExtension != null)
				MobileGui.androidExtension.stopCallSound();
		}
		
		static public function detectLink(message:String, messageId:Number):void 
		{
			if (MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.detectLink(message, messageId);
			}
		}
		
		static public function getTimezoneId():String 
		{
			var result:String;
			if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null)
			{
				result = MobileGui.androidExtension.getTimezoneId();
			}
			return result;
		}
		
		static public function existInDownloadFolder(fileName:String):Boolean 
		{
			if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null)
			{
				return MobileGui.androidExtension.existInDownloadFolder(fileName);
			}
			return false;
		}
		
		static public function openFileInDownloads(fileName:String):void 
		{
			if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null)
			{
				return MobileGui.androidExtension.openFileInDownloads(fileName);
			}
		}
		
		static private function onFileSelect(e:Event):void 
		{
			var path:String = (e.target as File).nativePath;
			
			if (ChatManager.getCurrentChat() != null)
			{
				var mediaFileData:MediaFileData = new MediaFileData();	
			
				mediaFileData.path = path;
				mediaFileData.id = path;
				mediaFileData.setOriginalName((e.target as File).name);
				mediaFileData.chatUID = ChatManager.getCurrentChat().uid;
				mediaFileData.key = ChatManager.getCurrentChat().securityKey;
				mediaFileData.localResource = path;
				mediaFileData.type = MediaFileData.MEDIA_TYPE_FILE;
				PhotoGaleryManager.S_GALLERY_MEDIA_LOADED.invoke(mediaFileData);
			}
		}
		
		static private function onChatLoaded(chat:ChatVO):void 
		{
			if (pendingPushMessages != null && pendingPushMessages.length > 0 && chat != null)
			{
				var l:int = pendingPushMessages.length;
				var message:Object;
				for (var i:int = 0; i < l; i++) 
				{
					message = pendingPushMessages[i];
					if (message != null && "chat_uid" in message && message.chat_uid == chat.uid)
					{
						pendingPushMessages.removeAt(pendingPushMessages.indexOf(message));
						addPushMessage(message, chat);
						onChatLoaded(chat);
						return;
					}
				}
			}
		}
	}
}