package com.dukascopy.connect.sys.viManager 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	import com.dukascopy.connect.sys.viManager.type.LangKey;
	import com.dukascopy.connect.sys.viManager.type.RemoteMessageType;
	import com.dukascopy.connect.sys.viManager.type.ServerMessageType;
	import com.dukascopy.connect.sys.viManager.type.SignalType;
	import com.dukascopy.connect.sys.viManager.type.VIActionType;
	import com.greensock.TweenMax;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VIServer 
	{
		public static var messages:Array;
		private var sendMessageFunction:Function;
		private var lastRespond:RemoteMessage;
		private var prewRespond:RemoteMessage;
		private var steps:Array;
		
		public function VIServer(sendMessageFunction:Function) 
		{
			this.sendMessageFunction = sendMessageFunction;
			
			steps = new Array();
			
			createStandartMessages();
		}
		
		private function createStandartMessages():void 
		{
			messages = new Array();
			
			var back:VIAction = new VIAction();
				back.key = LangKey.back;
				back.action = VIActionType.BACK;
				back.title = "Назад";
			
			
			var actionOpenSettings:VIAction = new VIAction();
				actionOpenSettings.key = LangKey.openSettings;
				actionOpenSettings.action = VIActionType.OPEN_SETTINGS;
				actionOpenSettings.title = "Открыть настройки";
			
			
			var messageIntro:RemoteMessage = new RemoteMessage();
				messageIntro.type = RemoteMessageType.ACTION;
				messageIntro.message = LangKey.viInitialMessage;
				messageIntro.defaultMessage = "Добрый день!\nВы готовы пройти видеоидентификацию?";
				messageIntro.actions = new Vector.<VIAction>;
				messageIntro.sound = "http://wb-dev.telefision.com/demoForm/voice_1.mp3";
				
				var actionStart:VIAction = new VIAction();
				actionStart.key = LangKey.startIdentification;
				actionStart.action = VIActionType.START_IDENTIFICATION;
				actionStart.title = "Да, начать";
				
				var actionReject:VIAction = new VIAction();
				actionReject.key = LangKey.postponeIdentifiction;
				actionReject.action = VIActionType.POSTPONE_IDENTIFICATION;
				actionReject.title = "Нет, позже";
				
				messageIntro.actions.push(actionStart);
				messageIntro.actions.push(actionReject);
			messages[ServerMessageType.START_MESSAGE] = messageIntro;
			
			
			var messageСheckVideo:RemoteMessage = new RemoteMessage();
				messageСheckVideo.type = RemoteMessageType.SYSTEM;
				messageСheckVideo.action = VIActionType.CHECK_VIDEO_PERMISSION;
				messageСheckVideo.successAction = VIActionType.VIDEO_PERMISSION_SUCCESS;
				messageСheckVideo.failAction = VIActionType.VIDEO_PERMISSION_FAIL;
				
			messages[ServerMessageType.CHECK_VIDEO] = messageСheckVideo;
			
			var messageСheckAudio:RemoteMessage = new RemoteMessage();
				messageСheckAudio.type = RemoteMessageType.SYSTEM;
				messageСheckAudio.action = VIActionType.CHECK_AUDIO_PERMISSION;
				messageСheckAudio.successAction = VIActionType.AUDIO_PERMISSION_SUCCESS;
				messageСheckAudio.failAction = VIActionType.AUDIO_PERMISSION_FAIL;
				
			messages[ServerMessageType.CHECK_AUDIO] = messageСheckAudio;
			
			
			var messageGetVideo:RemoteMessage = new RemoteMessage();
				messageGetVideo.type = RemoteMessageType.SYSTEM;
				messageGetVideo.action = VIActionType.GET_VIDEO_PERMISSION;
				messageGetVideo.successAction = VIActionType.GET_PERMISSION_SUCCESS;
				messageGetVideo.failAction = VIActionType.GET_PERMISSION_FAIL;
				
			messages[ServerMessageType.GET_VIDEO] = messageGetVideo;
			
			
			var messageGetAudio:RemoteMessage = new RemoteMessage();
				messageGetAudio.type = RemoteMessageType.SYSTEM;
				messageGetAudio.action = VIActionType.GET_AUDIO_PERMISSION;
				messageGetAudio.successAction = VIActionType.GET_AUDIO_PERMISSION_SUCCESS;
				messageGetAudio.failAction = VIActionType.GET_AUDIO_PERMISSION_FAIL;
				
			messages[ServerMessageType.GET_AUDIO] = messageGetAudio;
			
			
			var messageAddVideo:RemoteMessage = new RemoteMessage();
				messageAddVideo.type = RemoteMessageType.SYSTEM;
				messageAddVideo.action = VIActionType.ADD_VIDEO;
				messageAddVideo.successAction = VIActionType.ADD_VIDEO_SUCCESS;
				messageAddVideo.failAction = VIActionType.ADD_VIDEO_FAIL;
				
			messages[ServerMessageType.ADD_VIDEO] = messageAddVideo;
			
			
			var messageOpenSettings:RemoteMessage = new RemoteMessage();
				messageOpenSettings.type = RemoteMessageType.SYSTEM;
				messageOpenSettings.action = VIActionType.OPEN_SETTINGS;
				messageOpenSettings.successAction = VIActionType.OPEN_SETTINGS_SUCCESS;
				messageOpenSettings.failAction = VIActionType.OPEN_SETTINGS_FAIL;
				
			messages[ServerMessageType.OPEN_SETTINGS] = messageOpenSettings;
			
			
			var messagePermissionVideo:RemoteMessage = new RemoteMessage();
				messagePermissionVideo.type = RemoteMessageType.ACTION;
				messagePermissionVideo.message = LangKey.needCameraPermissions;
				messagePermissionVideo.defaultMessage = "Для продолжения необходимо предоставить доступ к камере";
				messagePermissionVideo.actions = new Vector.<VIAction>;
				messagePermissionVideo.sound = null;
				
				var actionGiveVideoPermission:VIAction = new VIAction();
				actionGiveVideoPermission.key = LangKey.giveVideoPermission;
				actionGiveVideoPermission.action = VIActionType.GIVE_VIDEO_PERMISSION;
				actionGiveVideoPermission.title = "Предоставить";
				
				messagePermissionVideo.actions.push(actionGiveVideoPermission);
				messagePermissionVideo.actions.push(back);
			messages[ServerMessageType.NEED_VIDEO_PERMISSION] = messagePermissionVideo;
			
			
			var messagePermissionAudio:RemoteMessage = new RemoteMessage();
				messagePermissionAudio.type = RemoteMessageType.ACTION;
				messagePermissionAudio.message = LangKey.needMicrophonePermissions;
				messagePermissionAudio.defaultMessage = "Для продолжения необходимо предоставить доступ к микрофону";
				messagePermissionAudio.actions = new Vector.<VIAction>;
				messagePermissionAudio.sound = null;
				
				var actionGiveAudioPermission:VIAction = new VIAction();
				actionGiveAudioPermission.key = LangKey.giveAudioPermission;
				actionGiveAudioPermission.action = VIActionType.GIVE_AUDIO_PERMISSION;
				actionGiveAudioPermission.title = "Предоставить";
				
				messagePermissionAudio.actions.push(actionGiveAudioPermission);
				messagePermissionAudio.actions.push(back);
			messages[ServerMessageType.NEED_AUDIO_PERMISSION] = messagePermissionAudio;
			
			
			var needVideoPermissionOnFail:RemoteMessage = new RemoteMessage();
				needVideoPermissionOnFail.type = RemoteMessageType.ACTION;
				needVideoPermissionOnFail.message = LangKey.needCameraPermissionsOnFail;
				needVideoPermissionOnFail.defaultMessage = "Не удалось включить камеру, проверьте разрешения в настройках";
				needVideoPermissionOnFail.actions = new Vector.<VIAction>;
				
				needVideoPermissionOnFail.actions.push(actionOpenSettings);
				needVideoPermissionOnFail.actions.push(back);
			messages[ServerMessageType.NEED_VIDEO_PERMISSION_ON_FAIL] = needVideoPermissionOnFail;
			
			
			var needAudioPermissionOnFail:RemoteMessage = new RemoteMessage();
				needAudioPermissionOnFail.type = RemoteMessageType.ACTION;
				needAudioPermissionOnFail.message = LangKey.needAudioPermissionsOnFail;
				needAudioPermissionOnFail.defaultMessage = "Не удалось включить микрофон, проверьте разрешения в настройках";
				needAudioPermissionOnFail.actions = new Vector.<VIAction>;
				
				needAudioPermissionOnFail.actions.push(actionOpenSettings);
				needAudioPermissionOnFail.actions.push(back);
			messages[ServerMessageType.NEED_AUDIO_PERMISSION_ON_FAIL] = needAudioPermissionOnFail;
			
			
			var messageMakeMRZPassport:RemoteMessage = new RemoteMessage();
				messageMakeMRZPassport.type = RemoteMessageType.ACTION;
				messageMakeMRZPassport.message = LangKey.makePassposrWithMRZ;
				messageMakeMRZPassport.defaultMessage = "Сосканируйте свой документ с видимой MRZ зоной";
				messageMakeMRZPassport.sound = "https://wb-dev.telefision.com/demoForm/voice_2.mp3";
				messageMakeMRZPassport.actions = new Vector.<VIAction>;
				
				var actoinMakePhoto:VIAction = new VIAction();
				actoinMakePhoto.key = LangKey.makePhoto;
				actoinMakePhoto.action = VIActionType.MAKE_PHOTO_MRZ_PASSPOST;
				actoinMakePhoto.camera = VIAction.CAMERA_REAR;
				actoinMakePhoto.description = "Сфотографируйте паспорт с MRZ";
				actoinMakePhoto.title = "Сфотографировать";
				
				var haveQuestionsAboutPasspostPhoto:VIAction = new VIAction();
				haveQuestionsAboutPasspostPhoto.key = LangKey.haveQuestionsPasspostPhoto;
				haveQuestionsAboutPasspostPhoto.action = VIActionType.QUESTIONS_PHOTO_MRZ_PASSPOST;
				haveQuestionsAboutPasspostPhoto.title = "У меня есть вопросы";
				
				messageMakeMRZPassport.actions.push(actoinMakePhoto);
				messageMakeMRZPassport.actions.push(haveQuestionsAboutPasspostPhoto);
			messages[ServerMessageType.MAKE_PASSPOST_MRZ_PHOTO] = messageMakeMRZPassport;
			
			
			var goodbay:RemoteMessage = new RemoteMessage();
				goodbay.type = RemoteMessageType.ACTION;
				goodbay.message = LangKey.goodbay;
				goodbay.defaultMessage = "Досвидание";
			messages[ServerMessageType.GOODBAY] = goodbay;
			
			
			var passportQuestions:RemoteMessage = new RemoteMessage();
				passportQuestions.type = RemoteMessageType.ACTION;
				passportQuestions.message = LangKey.makePassposrWithMRZ;
				passportQuestions.defaultMessage = "Уточните что вас интересует";
				passportQuestions.actions = new Vector.<VIAction>;
				
				var question_1:VIAction = new VIAction();
				question_1.key = LangKey.whyPassport;
				question_1.action = VIActionType.QUESTION_PASSPORT;
				question_1.title = "Зачем фото пасспорта?";
				
				var question_2:VIAction = new VIAction();
				question_2.key = LangKey.whatIsMRZ;
				question_2.action = VIActionType.QUESTION_MRZ;
				question_2.title = "Что такое MRZ?";
				
				var question_3:VIAction = new VIAction();
				question_3.key = LangKey.contactSupport;
				question_3.action = VIActionType.CONTACT_SUPPORT;
				question_3.title = "Чат с консультантом";
				
				passportQuestions.actions.push(question_1);
				passportQuestions.actions.push(question_2);
				passportQuestions.actions.push(question_3);
				passportQuestions.actions.push(back);
			messages[ServerMessageType.PASSPORT_QUESTIONS] = passportQuestions;
			
			
			var passportQuestions_respond_1:RemoteMessage = new RemoteMessage();
				passportQuestions_respond_1.type = RemoteMessageType.ACTION;
				passportQuestions_respond_1.message = LangKey.because;
				passportQuestions_respond_1.defaultMessage = "Надо";
				passportQuestions_respond_1.actions = new Vector.<VIAction>;
				passportQuestions_respond_1.actions.push(back);
			messages[ServerMessageType.PASSPORT_QUESTIONS_RESPOND_1] = passportQuestions_respond_1;
			
			
			var passportQuestions_respond_2:RemoteMessage = new RemoteMessage();
				passportQuestions_respond_2.type = RemoteMessageType.ACTION;
				passportQuestions_respond_2.message = LangKey.mrzDescription;
				passportQuestions_respond_2.defaultMessage = "Machine-readable passport (MRP) is a machine-readable travel document (MRTD) with the data on the identity page encoded in optical character recognition format. Many countries began to issue machine-readable travel documents in the 1980s. Most travel passports worldwide are MRPs. They are standardized by the ICAO Document 9303 (endorsed by the International Organization for Standardization and the International Electrotechnical Commission as ISO/IEC 7501-1) and have a special machine-readable zone (MRZ), which is usually at the bottom of the identity page at the beginning of a passport. The ICAO Document 9303 describes three types of documents. Usually passport booklets are issued in 'Type 3' format, while identity cards and passport cards typically use the 'Type 1' format. The machine-readable zone of a Type 3 travel document spans two lines, and each line is 44 characters long. The following information must be provided in the zone: name, passport number, nationality, date of birth, sex, and passport expiration date. There is room for optional, often country-dependent, supplementary information. The machine-readable zone of a Type 1 travel document spans three lines, and each line is 30 characters long.";
				passportQuestions_respond_2.actions = new Vector.<VIAction>;
				passportQuestions_respond_2.actions.push(back);
			messages[ServerMessageType.PASSPORT_QUESTIONS_RESPOND_2] = passportQuestions_respond_2;
			
			
			var passportQuestions_respond_3:RemoteMessage = new RemoteMessage();
				passportQuestions_respond_3.type = RemoteMessageType.ACTION;
				passportQuestions_respond_3.message = LangKey.supportUnavaliable;
				passportQuestions_respond_3.defaultMessage = "Консультант не хочет разговаривать";
				passportQuestions_respond_3.actions = new Vector.<VIAction>;
				passportQuestions_respond_3.actions.push(back);
			messages[ServerMessageType.PASSPORT_QUESTIONS_RESPOND_3] = passportQuestions_respond_3;
			
			
			var messageMakeSelfie:RemoteMessage = new RemoteMessage();
				messageMakeSelfie.type = RemoteMessageType.ACTION;
				messageMakeSelfie.message = LangKey.makePassposrWithMRZ;
				messageMakeSelfie.defaultMessage = "Сделайте (своё) селфи";
				messageMakeSelfie.sound = "https://wb-dev.telefision.com/demoForm/voice_3.mp3";
				messageMakeSelfie.actions = new Vector.<VIAction>;
				
				var actoinMakeSelfie:VIAction = new VIAction();
				actoinMakeSelfie.key = LangKey.makePhoto;
				actoinMakeSelfie.action = VIActionType.MAKE_PHOTO_SELFIE;
				actoinMakeSelfie.camera = VIAction.CAMERA_FRONT;
				actoinMakeSelfie.description = "Сделайте селфи";
				actoinMakeSelfie.title = "Сфотографировать";
				
				messageMakeSelfie.actions.push(actoinMakeSelfie);
			messages[ServerMessageType.MAKE_PASSPOST_SELFIE] = messageMakeSelfie;
			
			
			var messageMakeGologramm:RemoteMessage = new RemoteMessage();
				messageMakeGologramm.type = RemoteMessageType.ACTION;
				messageMakeGologramm.message = LangKey.makePassposrWithMRZ;
				messageMakeGologramm.defaultMessage = "Сделайте еще 4 фото паспорта под разными углами";
				messageMakeGologramm.sound = "https://wb-dev.telefision.com/demoForm/voice_4.mp3";
				messageMakeGologramm.actions = new Vector.<VIAction>;
				
				var actoinMakeGologramm:VIAction = new VIAction();
				actoinMakeGologramm.key = LangKey.makePhoto;
				actoinMakeGologramm.action = VIActionType.MAKE_PHOTO_GOLOGRAM;
				actoinMakeGologramm.camera = VIAction.CAMERA_REAR;
				actoinMakeGologramm.description = "Сделайте 4 фото паспорта под разными углами";
				actoinMakeGologramm.photoNum = 4;
				actoinMakeGologramm.title = "Сфотографировать";
				
				messageMakeGologramm.actions.push(actoinMakeGologramm);
			messages[ServerMessageType.MAKE_GOLOGRAMM] = messageMakeGologramm;
			
			var messageMakeSpasibo:RemoteMessage = new RemoteMessage();
				messageMakeSpasibo.type = RemoteMessageType.ACTION;
				messageMakeSpasibo.message = LangKey.makePassposrWithMRZ;
				messageMakeSpasibo.defaultMessage = "Спасибо, ожидайте оператора, не выходите из этого экрана, иначе вы потеряете свою очередь";
				
			messages[ServerMessageType.SPASIBO] = messageMakeSpasibo;
		}
		
		public function sendMessage(message:Object):void 
		{
			TweenMax.delayedCall(1, respond, [message]);
		}
		
		public function dispose():void 
		{
			messages = null;
			sendMessageFunction = null;
			lastRespond = null;
			prewRespond = null;
			prewRespond = null;
		}
		
		private function respond(messageRaw:String):void 
		{
			var rawData:Object = JSON.parse(messageRaw);
			var message:RemoteMessage = new RemoteMessage(rawData);
			
			switch(message.type)
			{
				case RemoteMessageType.SYSTEM:			
				{
					parseSystem(message);
					break;
				}
				
				case RemoteMessageType.SELECT_ACTION:			
				{
					parseActionSelect(message);
					break;
				}
			}
		}
		
		private function parseActionSelect(message:RemoteMessage):void 
		{
			message.type = RemoteMessageType.SELECT_ACTION;
			
			if ("signal" in message && message.signal != null)
			{
				switch(message.signal)
				{
					case VIActionType.START_IDENTIFICATION:
					{
						respondMessage(messages[ServerMessageType.CHECK_VIDEO]);
						break;
					}
					
					case VIActionType.VIDEO_PERMISSION_SUCCESS:
					case VIActionType.GET_PERMISSION_SUCCESS:
					{
						respondMessage(messages[ServerMessageType.CHECK_AUDIO]);
						break;
					}
					
					case VIActionType.AUDIO_PERMISSION_SUCCESS:
					case VIActionType.GET_AUDIO_PERMISSION_SUCCESS:
					{
						respondMessage(messages[ServerMessageType.ADD_VIDEO]);
						respondMessage(messages[ServerMessageType.MAKE_PASSPOST_MRZ_PHOTO]);
						break;
					}
					
					case VIActionType.AUDIO_PERMISSION_FAIL:
					{
						respondMessage(messages[ServerMessageType.NEED_AUDIO_PERMISSION]);
						break;
					}
					
					case VIActionType.GET_AUDIO_PERMISSION_FAIL:
					{
						respondMessage(messages[ServerMessageType.NEED_AUDIO_PERMISSION_ON_FAIL]);
						break;
					}
					
					case VIActionType.VIDEO_PERMISSION_FAIL:
					{
						respondMessage(messages[ServerMessageType.NEED_VIDEO_PERMISSION]);
						break;
					}
					
					case VIActionType.GET_PERMISSION_FAIL:
					{
						respondMessage(messages[ServerMessageType.NEED_VIDEO_PERMISSION_ON_FAIL]);
						break;
					}
					
					case VIActionType.GIVE_VIDEO_PERMISSION:
					{
						respondMessage(messages[ServerMessageType.GET_VIDEO]);
						break;
					}
					
					case VIActionType.GIVE_AUDIO_PERMISSION:
					{
						respondMessage(messages[ServerMessageType.GET_AUDIO]);
						break;
					}
					
					case VIActionType.POSTPONE_IDENTIFICATION:
					{
						respondMessage(messages[ServerMessageType.GOODBAY]);
						break;
					}
					
					case VIActionType.QUESTIONS_PHOTO_MRZ_PASSPOST:
					{
						respondMessage(messages[ServerMessageType.PASSPORT_QUESTIONS]);
						break;
					}
					
					case VIActionType.QUESTION_PASSPORT:
					{
						respondMessage(messages[ServerMessageType.PASSPORT_QUESTIONS_RESPOND_1]);
						break;
					}
					
					case VIActionType.QUESTION_MRZ:
					{
						respondMessage(messages[ServerMessageType.PASSPORT_QUESTIONS_RESPOND_2]);
						break;
					}
					
					case VIActionType.OPEN_SETTINGS:
					{
						respondMessage(messages[ServerMessageType.OPEN_SETTINGS]);
						break;
					}
					
					case VIActionType.CONTACT_SUPPORT:
					{
						respondMessage(messages[ServerMessageType.PASSPORT_QUESTIONS_RESPOND_3]);
						break;
					}
					
					case VIActionType.MAKE_PHOTO_MRZ_PASSPOST:
					{
						respondMessage(messages[ServerMessageType.MAKE_PASSPOST_SELFIE]);
						break;
					}
					
					case VIActionType.MAKE_PHOTO_SELFIE:
					{
						respondMessage(messages[ServerMessageType.MAKE_GOLOGRAMM]);
						break;
					}
					
					case VIActionType.MAKE_PHOTO_GOLOGRAM:
					{
						respondMessage(messages[ServerMessageType.SPASIBO]);
						break;
					}
					
					case VIActionType.BACK:
					{
						if (steps != null && steps.length > 1)
						{
							steps.pop();
							respondMessage(steps.pop());
						}
						
						break;
					}
				}
			}
		}
		
		private function parseSystem(message:RemoteMessage):void 
		{
			message.type = RemoteMessageType.SYSTEM;
			
			if ("signal" in message && message.signal != null)
			{
				switch(message.signal)
				{
					case SignalType.READY_START:
					{
						respondMessage(messages[ServerMessageType.START_MESSAGE]);
						break;
					}
				}
			}
		}
		
		private function respondMessage(message:RemoteMessage):void 
		{
			steps.push(message);
			
			if (sendMessageFunction != null)
			{
				sendMessageFunction(JSON.stringify(message.getRaw()));
			}
			else
			{
				ApplicationErrors.add();
			}
		}
	}
}