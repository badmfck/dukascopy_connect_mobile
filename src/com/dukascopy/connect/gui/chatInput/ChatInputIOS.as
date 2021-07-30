package com.dukascopy.connect.gui.chatInput {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LocalSoundFileData;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.AddInvoiceAction;
	import com.dukascopy.connect.data.screenAction.customActions.CreatePuzzleAction;
	import com.dukascopy.connect.data.screenAction.customActions.SendMoneyAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chat.DraftMessage;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.greensock.TweenMax;
	import com.greensock.easing.Ease;
	import com.telefision.sys.signals.Signal;
	import connect.IosChatUser;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.StatusEvent;
	import flash.utils.getTimer;
	import mx.utils.StringUtil;
	import com.dukascopy.dccext.DCCExtCommand;
	import com.dukascopy.dccext.DCCExtData;
	import flash.filesystem.File;
	import com.dukascopy.dccext.DCCExtMethod;
	import com.dukascopy.dccext.DCCExt;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov
	 */
	
	public class ChatInputIOS extends Sprite implements IChatInput {
		
		static public var S_INPUT_POSITION:Signal = new Signal("ChatInputIOS.S_INPUT_POSITION");
		static public var S_INPUT_ANIMATE:Signal = new Signal("ChatInputIOS.S_INPUT_POSITION");
		static public var S_INPUT_SHOW_START:Signal = new Signal("ChatInputIOS.S_INPUT_SHOW_START");
		static public var S_INPUT_HIDE_END:Signal = new Signal("ChatInputIOS.S_INPUT_HIDE_END");
		static public var S_INPUT_HIDE_START:Signal = new Signal("ChatInputIOS.S_INPUT_HIDE_START");
		static public const SNAPSHOT_TYPE_911:String = "911";
		
		private var bg:Bitmap;
		
		private var onChatSend:Function;
		private var lastBlackHoleTime:Number;
		
		private var tweenParams:Object;
		private var easeFunction:Ease;
		private var wasShowCalled:Boolean = false;
		private var maxTopY:int;
		private var extraFunctionsAvaliable:Boolean = true;
		private var stickersAvaliable:Boolean = true;
		private var shown:Boolean;
		private var currentInputText:String;
		private var inputViewHeight:Number = 0;
		private var lastPayButtonsStatus:Boolean = true;
		private var pendingEdit:String;
		
		public function ChatInputIOS(defaultText:String = null, snapshotType:String = null) {
			bg = new Bitmap();
			if (MobileGui.dce != null) {
				MobileGui.dce.addEventListener(StatusEvent.STATUS, statusHandler);
				bg.bitmapData = MobileGui.dce.inputViewSnapshot(defaultText, snapshotType);
			} else
				bg.bitmapData = UI.getColorTexture(Style.color(Style.COLOR_BACKGROUND));
			addChild(bg);
			y = MobileGui.stage.stageHeight - getStartHeight();
			y -= Config.APPLE_BOTTOM_OFFSET;
			graphics.beginFill(Style.color(Style.COLOR_INPUT_BACKGROUND));
			graphics.drawRect(0, 0, MobileGui.stage.width, Config.FINGER_SIZE * 6);
			graphics.endFill();
		}
		
		public static function init():void {
			if (MobileGui.dce != null) {
				MobileGui.dce.inputViewSetup();
				MobileGui.dce.inputViewEnableAttachButton();
			}
		}
		
		public function hideStickersAndAttachButton():void {
			
		}
		
		public function setLeftMargin(value:int):void {
			
		}
		
		override public function get height():Number {
			return inputViewHeight;
		}
		
		public function setMaxTopY(val:int):void {
			maxTopY = val;
			if (MobileGui.dce != null)
				MobileGui.dce.inputViewSetMaxTopY(val);
		}
		
		public function getView():DisplayObject {
			return this;
		}
		
		public function show(defaultText:String = null):void {
			init();
			if (shown == true)
				return;
			TweenMax.killDelayedCallsTo(callNativeShow);
			TweenMax.delayedCall(1, callNativeShow, [defaultText], true);
			
			graphics.beginFill(Style.color(Style.COLOR_INPUT_BACKGROUND));
			graphics.drawRect(0, 0, MobileGui.stage.width, Config.FINGER_SIZE * 6);
			graphics.endFill();
		}
		
		private function callNativeShow(defaultText:String):void {
			if (MobileGui.dce != null) {
				wasShowCalled = true;
				shown = true;
				
				MobileGui.dce.inputViewShow(getChatUser(), defaultText);
				if (lastPayButtonsStatus == false) {
					initButtons(lastPayButtonsStatus);
					lastPayButtonsStatus = true;
				}
				if (currentInputText != null) {
					MobileGui.dce.inputViewSetText(currentInputText);
					currentInputText = null;
				}
				if (extraFunctionsAvaliable == false) {
					MobileGui.dce.inputViewDisableAttachButton();
				}
				if (pendingEdit != null) {
					callNativeEdit(pendingEdit);
					pendingEdit = null;
				}
			}
		}
		
		private function getChatUser():IosChatUser {
			var user:IosChatUser = new IosChatUser();
			if (ChatManager.getCurrentChat() != null) {
				if (ChatManager.getCurrentChat().type == ChatRoomType.GROUP || ChatRoomType.CHANNEL) {
					user.avatar = ChatManager.getCurrentChat().avatar;
					user.name = ChatManager.getCurrentChat().title;
				}
				if ((ChatManager.getCurrentChat().type == ChatRoomType.QUESTION || ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) && 
					ChatManager.getCurrentChat().questionID != null && 
					ChatManager.getCurrentChat().questionID != "") {
					if (ChatManager.getCurrentChat().getQuestion() != null && ChatManager.getCurrentChat().getQuestion().incognito == true) {
						user.avatar = null;
						user.name = null;
					}
				}
			}
			return user;
		}
		
		public function hide():void {
			if (MobileGui.dce != null && shown)
				currentInputText = MobileGui.dce.typedText();
			if (bg != null && shown) {
				redrawScreenshot();
				bg.visible = true;
			}
			wasShowCalled = false;
			shown = false;
			
			TweenMax.killDelayedCallsTo(callNativeShow);
			callNativeHide();
			
			storeKeyboardPosition(0);
			pendingEdit = null;
		}
		
		private function storeKeyboardPosition(yPosition:Number):void {
			MobileGui.setSoftKeyboardY(yPosition);
		}
		
		public function hideBackground():void {
			if (bg)
				bg.visible = false;
			if (shown == false) {
				graphics.clear();
			}
		}
		
		public function dispose():void {
			TweenMax.killDelayedCallsTo(onUserWritingTimer);
			onChatSend = null;
			
			if (MobileGui.dce != null) {
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandler);
				MobileGui.dce.resetInputViewSnapshot();
			}
			TweenMax.delayedCall(1, callNativeHide, null, true);
			UI.destroy(bg);
			bg = null;
			
			storeKeyboardPosition(0);
			pendingEdit = null;
		}
		
		private function callNativeHide():void {
			if (MobileGui.dce != null) {
				MobileGui.dce.inputViewHide();
			}
		}
		
		public function showBG():void {
			bg.visible = true;
			
			graphics.beginFill(Style.color(Style.COLOR_INPUT_BACKGROUND));
			graphics.drawRect(0, 0, MobileGui.stage.width, Config.FINGER_SIZE * 6);
			graphics.endFill();
		}
		
		public function setWidth(width:int):void { }
		
		public function activate():void {
			if (MobileGui.dce != null)
				MobileGui.dce.inputViewHideOverlayView();
		}
		
		public function setCallBack(onChatSend:Function):void {
			this.onChatSend = onChatSend;
		}
		
		public function setValue(text:String):void {
			pendingEdit = null;
			TweenMax.delayedCall(2, callNativeEdit, [text], true);
		}
		
		private function callNativeEdit(text:String):void 
		{
			if (MobileGui.dce != null)
			{
				if (shown)
				{
					MobileGui.dce.inputViewEditMessage(text);
				}
				else
				{
					pendingEdit = text;
				}
			}
		}
		
		public function deactivate():void {
			if (MobileGui.dce != null)
				MobileGui.dce.inputViewShowOverlayView(0xFFFFFF, 0.5);
		}
		
		public function setY(openChatY:int):void {
			
		}
		
		protected function onTextChanged():void {
			
			DraftMessage.setValue(ChatManager.getCurrentChat().uid, ChatManager.getCurrentChat().chatSecurityKey, MobileGui.dce.inputViewText());
			
			if (getTimer() - lastBlackHoleTime < 5000)
				return;
			onUserWritingTimer();
		}
		
		protected function onUserWritingTimer():void {
			TweenMax.killDelayedCallsTo(onUserWritingTimer);
			if (ChatManager.getCurrentChat() == null)
				return;
			if (MobileGui.centerScreen.currentScreenClass != ChatScreen)
				return;
			TweenMax.delayedCall(2, onUserWritingTimer);
			
			var curentTS:Number = getTimer();
			if (curentTS - lastBlackHoleTime < 5000) {
				TweenMax.killDelayedCallsTo(onUserWritingTimer);
				return;
			}
			lastBlackHoleTime = curentTS;
			WSClient.call_chatSendAll(ChatManager.getCurrentChat().uid, {
				method: "userWriting",
				userUID: Auth.uid,
				userName: Auth.username,
				chatUID: ChatManager.getCurrentChat().uid
			} );
		}
		
		private function statusHandler(e:StatusEvent):void {

			var duration:Number = 0;
			var data:Object;
			switch (e.code) {
				case "inputView": {

					if(e.level=="galleryBtnPressed"){
						getFiles();
						return;
					}

					if (e.level == "didChangeText")
						onTextChanged();
					else if (e.level == "didShow" && wasShowCalled) {
						if (MobileGui.dce != null)
							MobileGui.dce.inputViewSetMaxTopY(maxTopY);
						bg.visible = false;
					}
					break;
				}
				case "inputViewHeightChangeStart":
				case "inputViewKeyboardShowStart":
				case "inputViewKeyboardHideStart": {
					
					if (e.code == "inputViewKeyboardShowStart")
					{
						S_INPUT_SHOW_START.invoke();
					}
					
					
					try {
						tweenParams = JSON.parse(e.level);
						if ("inputViewHeight" in tweenParams)
						{
							inputViewHeight = tweenParams.inputViewHeight;
						}
						startAnimation();
						storeKeyboardPosition(tweenParams.inputViewY);
					} catch (error:Error) {
						echo("ChatInputIOS", "statusHandler::" + e.code, "ERROR: " + error.message);
					}
					if (e.code == "inputViewKeyboardHideStart")
					{
						S_INPUT_HIDE_START.invoke(tweenParams.duration);
					}
					break;
				}
				case "inputViewHeightChangeEnd":
				case "inputViewKeyboardShowEnd":
				case "inputViewKeyboardHideEnd": {
					if (shown)
					{
						hideBackground();
					}
					
					if (e.code == "inputViewKeyboardHideEnd")
					{
						S_INPUT_HIDE_END.invoke();
					}
					
					data = JSON.parse(e.level);
					TweenMax.killTweensOf(this);
					
					////!!!!!!!!!!!!
					TweenMax.to(this, 10, { useFrames:true, y:data.inputViewY } );
					//y = data.inputViewY;
				
					storeKeyboardPosition(data.inputViewY);
					if ("inputViewHeight" in data)
						inputViewHeight = data.inputViewHeight;
					break;
				}
				case "inputViewSend": {
					data = JSON.parse(e.level);
					if (data && ("message" in data)) {
						DraftMessage.clearValue(ChatManager.getCurrentChat().uid);
						if (onChatSend) {
							var value:String = StringUtil.trim(data.message);
							if (value.length > 0)
								onChatSend(value);
						}
					}
					break;
				}
				case "didRecordVoice": {
					try {
						data = JSON.parse(e.level);
					} catch (error:Error) {
						echo("ChatInputIOS", "statusHandler::" + e.code, "ERROR: " + error.message);
					}
					if (data && ("url" in data) && ("duration" in data) && onChatSend)
						onChatSend(new LocalSoundFileData(data.url, data.duration), ChatMessageType.VOICE);
					break;
				}
				case "inputViewSticker": {
					if (stickersAvaliable) {
						var stickerId:String;
						var strings:Array = e.level.split("id_");
						if (strings == null || strings.length != 2) {
							echo("ChatInputIOS", "statusHandler::" + e.code, "ERROR: WRONG DATA");
							break;
						}
						stickerId = strings[1];
						onChatSend(Config.BOUNDS + JSON.stringify( { title:"Sent a sticker", additionalData:stickerId + ",1", type:"sticker", method:"stickerSent" } ));
						break;
					}
				}
				case "inputViewAttach": {
					if (extraFunctionsAvaliable) {
						var action:IScreenAction;
						switch (e.level) {
							case "sendMoney": {
								echo("ChatInputIOS", "inputViewAttach", "sendMoney");
								action = new SendMoneyAction();	
								action.execute();
								break;
							}
							case "photoGallery": {
								echo("ChatInputIOS", "inputViewAttach", "photoGallery");
								PhotoGaleryManager.takeImage(true);
								break;
							}
							case "invoice": {
								echo("ChatInputIOS", "inputViewAttach", "invoice");
								action = new AddInvoiceAction();	
								action.execute();
								break;
							}
							case "makePhoto": {
								echo("ChatInputIOS", "inputViewAttach", "makePhoto");
								PhotoGaleryManager.takeCamera(true);
								break;
							}
							case "puzzle": {
								echo("ChatInputIOS", "inputViewAttach", "puzzle");
								
								var puzzle:IScreenAction = new CreatePuzzleAction();
								puzzle.execute();
								break;
							}
							case "sendGiftWithValue1": {
								echo("ChatInputIOS", "inputViewAttach", "sendGiftWithValue1");
								Gifts.startGift(GiftType.GIFT_1);
								break;
							}
							case "sendGiftWithValue5": {
								echo("ChatInputIOS", "inputViewAttach", "sendGiftWithValue5");
								Gifts.startGift(GiftType.GIFT_5);
								break;
							}
							case "sendGiftWithValue10": {
								echo("ChatInputIOS", "inputViewAttach", "sendGiftWithValue10");
								Gifts.startGift(GiftType.GIFT_10);
								break;
							}
							case "sendGiftWithValue25": {
								echo("ChatInputIOS", "inputViewAttach", "sendGiftWithValue25");
								Gifts.startGift(GiftType.GIFT_25);
								break;
							}
							case "sendGiftWithValue50": {
								echo("ChatInputIOS", "inputViewAttach", "sendGiftWithValue50");
								Gifts.startGift(GiftType.GIFT_50);
								break;
							}
							case "sendGiftWithValueXXX": {
								echo("ChatInputIOS", "inputViewAttach", "sendGiftWithValueXXX");
								Gifts.startGift(GiftType.GIFT_X);
								break;
							}
						}
					}
					break;
				}
				case "imagePicker": {
					if (e.level == "didCancel") {
						
					} else if (e.level == "didPick") {
						if (MobileGui.dce != null)
						{
							var imageData:BitmapData = MobileGui.dce.pickedImage();
							if (imageData) {
								var ibd:ImageBitmapData = new ImageBitmapData("uploadedImage", imageData.width, imageData.height, true, 0);
								ibd.copyBitmapData(imageData);
								imageData.dispose();
								imageData = null;
								
								var fileTitle:String = new Date().getTime() + ' ';
								PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.invoke(true, ibd, fileTitle);
							} else {
								
							}
						}
					}
					break;
				}
				case "didPickVideo": {
					
					try
					{
						data = JSON.parse(e.level);
					}
					catch (e:Error)
					{
						ApplicationErrors.add("json error");
					}
					
					if (data != null)
					{
						var mediaFileData:MediaFileData = new MediaFileData();
						
						if ("video" in data && data.video != "" && data.video != null)
						{
							mediaFileData.path = data.video;
						}
						
						if ("pre_video" in data && data.pre_video != "" && data.pre_video != null)
						{
							mediaFileData.localResource = data.pre_video;
						}
						else {
							mediaFileData.localResource = mediaFileData.path;
						}
						if ("duration" in data && data.duration != "" && data.duration != null)
						{
							mediaFileData.duration = Number(data.duration)*1000;
						}
						
						mediaFileData.thumb = data.preview;
						mediaFileData.type = MediaFileData.MEDIA_TYPE_VIDEO;
						if ("id" in data)
						{
							mediaFileData.id = data.id;
						}
						else
						{
							mediaFileData.id = (new Date()).getTime().toString();
						}
						
						if (mediaFileData.localResource != null)
						{
							if (mediaFileData.localResource.indexOf("file://") != -1)
							{
								mediaFileData.localResource = mediaFileData.localResource.slice(7);
							}
						}
						PhotoGaleryManager.S_GALLERY_MEDIA_LOADED.invoke(mediaFileData);
					}
					
					break;
				}
			}
		}


		private function getFiles():void{
            DCCExt.call(new DCCExtCommand(
                DCCExtMethod.FILE_BROWSE,
                {}
            ),function(e:DCCExtData):void{
                var filePath:String=e.data.file;
                var file:File=new File(filePath); //File.applicationStorageDirectory+"tmp/com.swfx.connect/inbox/..etc"
				if(!file.exists){
					//TODO: show error message
					echo("ChatInputIOS","getFiles","file not exists",true);
					return;
				}

				var mediaFileData:MediaFileData = new MediaFileData();	
				mediaFileData.setOriginalName(file.name);
				var chat:ChatVO=ChatManager.getCurrentChat();
				if(!chat){
					//TODO: show error message
					echo("ChatInputIOS","getFiles","No current chat!",true);
					return;
				}
									
				mediaFileData.key = chat.securityKey;
				mediaFileData.chatUID=chat.uid;
				mediaFileData.localResource = file.nativePath;
				if (mediaFileData.localResource.indexOf("file://") != -1)
					mediaFileData.localResource = mediaFileData.localResource.substr(7);
				mediaFileData.path=mediaFileData.localResource;

				mediaFileData.type = MediaFileData.MEDIA_TYPE_FILE;
				PhotoGaleryManager.S_GALLERY_MEDIA_LOADED.invoke(mediaFileData);
				echo("ChatInputIOS","getFiles","Try to upload!");
            })
        }
		
		private function callBackAddInvoice(i:int, paramsObj:Object):void {
			if (MobileGui.dce != null)
				MobileGui.dce.inputViewActivate();
			if (i != 1)
				return;
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			if (currentChat == null)
				return;
			var chatUser:ChatUserVO = UsersManager.getInterlocutor(currentChat);
			if (chatUser == null)
				return;
			var qVO:QuestionVO = currentChat.getQuestion();
			var fromIncognitoQuestion:Boolean = (qVO != null && qVO.incognito == true && qVO.userUID == Auth.uid);
			var myPhone:String = "+" + Auth.countryCode + Auth.getMyPhone();
			if (paramsObj != null &&
				"amount" in paramsObj == true &&
				"currency" in paramsObj == true &&
				"amount" in paramsObj == true) {
					var data:ChatMessageInvoiceData = ChatMessageInvoiceData.create(Number(paramsObj.amount),
						paramsObj.currency,
						paramsObj.message,
						(fromIncognitoQuestion == true) ? "Secret" :Auth.username,
						Auth.uid,
						(chatUser.secretMode == true) ? "Secret" : chatUser.name,
						chatUser.uid,
						myPhone,
						InvoiceStatus.NEW
					);
					ChatManager.sendInvoiceByData(data);
			}
		}
		
		private function startAnimation():void {
			TweenMax.killTweensOf(this);
			TweenMax.to(this, tweenParams.duration * MobileGui.stage.frameRate, { useFrames:true, y:tweenParams.inputViewY } );
		}
		
		override public function set y(value:Number):void {
			if (isNaN(value))
				return;
			if (value == super.y)
				return;
			super.y = value;
			S_INPUT_POSITION.invoke();
		}
		
		public function getStartHeight():Number {
			if (MobileGui.dce != null)
				return MobileGui.dce.inputViewInitialHeightInPixels();
			return 0;
		}
		
		public function blockStickers(val:Boolean = true):void {
			stickersAvaliable = !val;
		}
		
		public function blockExtraFunctions():void {
			if (MobileGui.dce != null)
				MobileGui.dce.inputViewDisableAttachButton();
			extraFunctionsAvaliable = false;
		}
		
		public function initButtons(showPayButtons:Boolean = false):void {
			if (!showPayButtons) {
				if (MobileGui.dce != null)
				{
					lastPayButtonsStatus = false;
					MobileGui.dce.inputViewDisablePayButton();
				}
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IChatInput */
		
		public function isShown():Boolean 
		{
			return shown;
		}
		
		public function redrawScreenshot():void 
		{
			//не работает если инпут спрятан;
			if (MobileGui.dce != null && shown == true)
			{
				//безусловно делаем новый скриншот инпута в текущем состоянии;
				var newImage:BitmapData = MobileGui.dce.snapshotOfCurrentInputView();
				if (newImage != null)
				{
					if (bg.bitmapData)
					{
						bg.bitmapData.dispose();
						bg.bitmapData = null;
					}
					bg.bitmapData = newImage;
				}
			}
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IChatInput */
		
		public function hideStickersButton():void 
		{
			
		}
		
		public function hideAttachButton():void 
		{
			
		}
		
		public function disableVoiceRecord():void 
		{
			
		}
		
		/* INTERFACE com.dukascopy.connect.gui.chatInput.IChatInput */
		
		public function getHeight():int 
		{
			return 0;
		}
	}
}