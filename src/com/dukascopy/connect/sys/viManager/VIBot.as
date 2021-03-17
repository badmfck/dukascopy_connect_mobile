package com.dukascopy.connect.sys.viManager {
	
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.chat.video.FloatVideo;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.viManager.actions.AddVideoAction;
	import com.dukascopy.connect.sys.viManager.actions.CheckAudioPermissionAction;
	import com.dukascopy.connect.sys.viManager.actions.CheckVideoPermissionAction;
	import com.dukascopy.connect.sys.viManager.actions.CloseSessionAction;
	import com.dukascopy.connect.sys.viManager.actions.GetAudioPermissionAction;
	import com.dukascopy.connect.sys.viManager.actions.GetVideoPermissionAction;
	import com.dukascopy.connect.sys.viManager.actions.IBotAction;
	import com.dukascopy.connect.sys.viManager.actions.IBotSystemAction;
	import com.dukascopy.connect.sys.viManager.actions.OpenSettingsAction;
	import com.dukascopy.connect.sys.viManager.actions.OpenURLAction;
	import com.dukascopy.connect.sys.viManager.actions.StartVideoBroadcastAction;
	import com.dukascopy.connect.sys.viManager.actions.TakeMRZAction;
	import com.dukascopy.connect.sys.viManager.actions.TakePhotoAction;
	import com.dukascopy.connect.sys.viManager.actions.TakePhotoGologrammAction;
	import com.dukascopy.connect.sys.viManager.data.BotResponse;
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	import com.dukascopy.connect.sys.viManager.data.VISessoinData;
	import com.dukascopy.connect.sys.viManager.type.LangKey;
	import com.dukascopy.connect.sys.viManager.type.RemoteMessageType;
	import com.dukascopy.connect.sys.viManager.type.SignalType;
	import com.dukascopy.connect.sys.viManager.type.VIActionType;
	import com.dukascopy.langs.Lang;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class VIBot {
		
		public var videoControl:FloatVideo;
		private var sessionData:VISessoinData;
		private var sendMessage:Function;
		private var responseFunction:Function;
		private var closed:Boolean;
		public var mainScreen:BaseScreen;
		public var videoConnection:VideoConnection;
		
		public function VIBot(sessionData:VISessoinData, sendMessage:Function) {
			this.sessionData = sessionData;
			this.sendMessage = sendMessage;
		}
		
		private function send(method:String, message:Object):void {
			trace("SEND", method);
			if (message == null) {
				ApplicationErrors.add();
				return;
			}
			if (sendMessage != null) {
				var packet:Object = {
					method: method,
					data: message
				}
				sendMessage(JSON.stringify(packet));
			}
		}
		
		public function remoteMessage(raw:Object):void {
			var message:RemoteMessage = new RemoteMessage(raw);
			switch(message.type) {
				case RemoteMessageType.ACTION:
				case RemoteMessageType.NAVIGATE:
				case RemoteMessageType.MENU: {
					displayAction(message, true);
					send("received", message.name);
					break;
				}
				case RemoteMessageType.SYSTEM: {
					executeSystem(message);
					break;
				}
			}
		}
		
		private function executeSystem(message:RemoteMessage):void 
		{
			var actionLocal:IBotSystemAction;
			
			if (message.action == VIActionType.CHECK_VIDEO_PERMISSION)
			{
				actionLocal = new CheckVideoPermissionAction(message);
			}
			else if (message.action == VIActionType.GET_VIDEO_PERMISSION)
			{
				actionLocal = new GetVideoPermissionAction(message);
			}
			else if (message.action == VIActionType.ADD_VIDEO)
			{
				actionLocal = new AddVideoAction(message, mainScreen);
			}
			else if (message.action == VIActionType.OPEN_SETTINGS)
			{
				actionLocal = new OpenSettingsAction(message, mainScreen);
			}
			if (message.action == VIActionType.CHECK_AUDIO_PERMISSION)
			{
				actionLocal = new CheckAudioPermissionAction(message);
			}
			else if (message.action == VIActionType.GET_AUDIO_PERMISSION)
			{
				actionLocal = new GetAudioPermissionAction(message);
			}
			
			if (actionLocal != null)
			{
				actionLocal.execute(onSuccessSystemAction, onFailSystemAction);
			}
		}
		
		private function onSuccessSystemAction(action:IBotSystemAction):void 
		{
			var message:RemoteMessage = action.getAction();
			if (message != null && message.type == RemoteMessageType.SYSTEM)
			{
				
				var actionSuccess:VIAction = new VIAction();
				actionSuccess.action = message.successAction;
				sendActionToServer(actionSuccess);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onFailSystemAction(action:IBotSystemAction):void 
		{
			var message:RemoteMessage = action.getAction();
			if (message != null && message.type == RemoteMessageType.SYSTEM)
			{
				var actionSuccess:VIAction = new VIAction();
				actionSuccess.action = message.failAction;
				sendActionToServer(actionSuccess);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function displayAction(message:RemoteMessage, store:Boolean = false):void 
		{
			if (closed == true)
			{
				return;
			}
			
			var response:BotResponse = new BotResponse();
			response.message = message;
			
			if (responseFunction != null && responseFunction.length == 1)
			{
				if (store == true)
				{
					storeMessage(response.message);
				}
				
				responseFunction(response);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function storeMessage(message:RemoteMessage):void 
		{
			sessionData.addMessage(message);
		}
		
		public function onResponse(responseFunction:Function):void 
		{
			this.responseFunction = responseFunction;
		}
		
		public function acceptAction(message:RemoteMessage, index:int):void 
		{
			var actionToSend:VIAction = message.actions[index];
			
			executeAction(actionToSend);
			
			if (actionToSend.tapped == true)
			{
				for (var i:int = 0; i < message.actions.length; i++) 
				{
					if (message.actions[i] != actionToSend)
					{
						message.actions[i].disabled = true;
					}
				}
			}
		}
		
		public function onExit():void 
		{
			if (closed == true)
			{
				return;
			}
			closed = true;
			
			var exitAction:VIAction = new VIAction();
			exitAction.action = VIActionType.CLIENT_EXIT;
			//sendActionToServer(exitAction);
		}
		
		public function onDisconnect():void 
		{
			var message:RemoteMessage = new RemoteMessage();
			message.type = RemoteMessageType.ACTION;
			message.message = Lang.noConnectionBot;
			
			var closeAction:VIAction = new VIAction();
			closeAction.text = LangKey.closeSession;
			closeAction.action = VIActionType.CLOSE_SESSION;
			closeAction.title = "Завершить";
			
			message.actions = new Vector.<VIAction>();
			message.actions.push(closeAction);
			
			displayAction(message);
			
			closed = true;
		}
		
		public function setMessages(messages:Vector.<RemoteMessage>):void 
		{
			var l:int = messages.length;
			for (var i:int = 0; i < l; i++) 
			{
				displayAction(messages[i], false);
			}
		}
		
		private function executeAction(action:VIAction):void {
			if (isSimpleResponse(action)) {
				action.tapped = true;
				sendActionToServer(action);
			} else {
				executeLocal(action);
			}
		}
		
		private function executeLocal(action:VIAction):void {
			var actionLocal:IBotAction;
			if (action.action == VIActionType.MAKE_PHOTO) {
				mainScreen.deactivateScreen();
				if (action.type == VIActionType.MAKE_PHOTO_MRZ_PASSPOST)
					actionLocal = new TakeMRZAction(videoControl, action);
				else if (action.type == VIActionType.MAKE_PHOTO_SELFIE)
					actionLocal = new TakePhotoAction(videoControl, action);
				else if (action.type == VIActionType.MAKE_PHOTO_REGULAR)
					actionLocal = new TakePhotoGologrammAction(videoControl, action);
			} else if (action.action == VIActionType.URL) {
				actionLocal = new OpenURLAction(action);
			} else if (action.action == VIActionType.CLOSE_SESSION) {
				actionLocal = new CloseSessionAction(action, mainScreen);
			} else if (action.action == VIActionType.BROADCAST) {
				actionLocal = new StartVideoBroadcastAction(videoConnection, action, videoControl);
			}
			
			if (actionLocal != null) {
				actionLocal.execute(onSuccessLocalAction, onFailLocalAction);
			}
		}
		
		private function onSuccessLocalAction(action:IBotAction):void 
		{
			mainScreen.activateScreen();
			
			sessionData.addPhoto(action.getAction().action, action.getResult());
			
			action.getAction().tapped = true;
			
			var responseAction:VIAction = action.getAction();
			
			var localResponseMessage:RemoteMessage;
			if (action.getAction().type == VIActionType.MAKE_PHOTO_MRZ_PASSPOST)
			{
				localResponseMessage = new RemoteMessage();
				localResponseMessage.mine = true;
				localResponseMessage.message = Lang.photoPassportReady;
			}
			else if (action.getAction().type == VIActionType.MAKE_PHOTO_SELFIE)
			{
				localResponseMessage = new RemoteMessage();
				localResponseMessage.mine = true;
				localResponseMessage.message = Lang.photoSelfieReady;
			}
			else if (action.getAction().type == VIActionType.MAKE_PHOTO_REGULAR)
			{
				localResponseMessage = new RemoteMessage();
				localResponseMessage.mine = true;
				localResponseMessage.message = Lang.photoGologramReady;
			}
			else if (action.getAction().action == VIActionType.BROADCAST)
			{
				responseAction.data = new Object();
				responseAction.data.streamId = action.getData();
				responseAction.data.cam = videoConnection.getBroadcastMode();
			}
			
			var images:Vector.<ImageBitmapData> = action.getResult();
			
			if (images != null)
			{
				for (var i:int = 0; i < images.length; i++) 
				{
					if (images[i] != null)
					{
						if (localResponseMessage != null)
						{
							localResponseMessage.photo = new ImageBitmapData("viBotChatImage", images[i].width, images[i].height);
							localResponseMessage.photo.copyPixels(images[i], images[i].rect, new Point());
							displayPhoto(localResponseMessage);
						}
						
						responseAction.addPhoto(images[i]);
					}
				}
			}
			
			sendActionToServer(responseAction);
			
			action.dispose();
		}
		
		private function displayPhoto(message:RemoteMessage):void {
			displayAction(message);
		}
		
		private function onFailLocalAction(action:IBotAction):void {
			var responseAction:VIAction = action.getAction();
			if (action.getAction().type == VIActionType.BROADCAST) {
				responseAction.data = new Object();
				responseAction.data.streamId = null;
				responseAction.data.error = action.getData();
				
				sendActionToServer(responseAction);
			}
			
			mainScreen.activateScreen();
			
			action.dispose();
		}
		
		private function isSimpleResponse(action:VIAction):Boolean {
			if (action.action == VIActionType.MAKE_PHOTO ||
				action.action == VIActionType.BROADCAST ||
				action.action == VIActionType.CLOSE_SESSION ||
				action.action == VIActionType.URL) {
				return false;
			}
			return true;
		}
		
		private function sendActionToServer(action:VIAction):void {
			send(SignalType.COMMAND, {
				action: action.action,
				destination: action.destination,
				type: action.type,
				data: action.data
			} );
		}
	}
}