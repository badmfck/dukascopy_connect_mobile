package com.dukascopy.connect.sys.notificationManager {
	
	import assets.IconNotificationFile;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.Utils;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey Skuryat. Telefision Team RIGA.
	 */
	
	public class InnerNotificationManager {
		
		public static var S_NOTIFICATION_CLICKED:Signal = new Signal("InnerNotificationManager.S_NOTIFICATION_CLICKED");
		public static var S_NOTIFICATION_NEED:Signal = new Signal("InnerNotificationManager.S_NOTIFICATION_NEED");
		
		private static const NOTIFICATION_CODE:String = "NOTIFICATION_CODE_001";
		static private var waitingForActivate:Boolean = false;
		private static var notificationCallBack:Function;
		static private var messageCount:int = 0;
		// some params
		private static const NOTIFICATION_SHOW_TIME:Number = 40;// .6;
		private static const NOTIFICATION_HIDE_TIME:Number = 30;// .4;
		private static const NOTIFICATION_DISPLAY_TIME:Number = 2.5;
		
		private static const SHADER_COLOR_DARK:uint = 0x000000;
		private static const SHADER_COLOR_LIGHT:uint = 0x000000;

		private static var planeColor:uint = AppTheme.RED_MEDIUM;
		private static var textColor:uint = 0xFFFFFF;
		
		private static var isBusy:Boolean  = false;
		private static var isInitialized:Boolean = false;
		private static var isClickable:Boolean = false;
		
		// ui 
		private static var container:DisplayObjectContainer;
		private static var planesHolder:Sprite = new Sprite();
		private static var currentBitmapData:BitmapData;
		private static var notificationCanvas:Bitmap = new Bitmap();
		private static var planeBitmapData:ImageBitmapData;
		private static var msgIconData:BitmapData;
		private static var closeIconData:BitmapData;
			
		// vars 
		private static var dataStock:/*ObjectsPoolItem*/Array = [];
		private static var objectPool:Vector.<NotificationVO> = new Vector.<NotificationVO>;
		private static var currentData:NotificationVO;
		
		
		// Sizes 
		private static var _viewWidth:int = 650;		
		private static var iconSize:int = 80;
		private static var PADDING:int = 20;		
		private static var ICON_SIZE:int = 20;		
		private static  var topOffset:Number = 0;
		
		// 3D setup 
		private static var pp:PerspectiveProjection = new PerspectiveProjection();
		private static var centerPoint:Point = new Point();
		private static var tempPoint:Point = new Point();
		
		// do not allow notifications to show but keep them in stock
		public static var isPaused:Boolean = false;
		
		public function InnerNotificationManager() {}
		
		
		/** INIT */
		public static function init(_container:DisplayObjectContainer):void {
			if (isInitialized) return;
			TweenPlugin.activate([ColorTransformPlugin, TintPlugin]);
			container = _container;
			container.addChild(planesHolder);
			
			notificationCanvas.visible = false;
			isInitialized = true;
			
			// define all sizes and params 
			PADDING = Config.DOUBLE_MARGIN;
			ICON_SIZE =  Math.ceil(Config.FINGER_SIZE * .30) * 2;

			if (Config.PLATFORM_APPLE)
				topOffset = Config.APPLE_TOP_OFFSET;// Config.FINGER_SIZE * .2;
			planesHolder.y = 0;// topOffset;
			planesHolder.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			
			WSClient.S_CHAT_MSG.add(onChatMessage);
			WSClient.S_PUZZLE_PAID.add(onPuzzlePaid);
			//WSClient.S_UPDATE_ENTRY_POINTS.add(onEntryPointsUpdated);
		}
		
		static private function onEntryPointsUpdated(data:Object):void {
			
		}
		
		static private function onNotificationClickCallbackEP(vo:NotificationVO):void {
			
		}
		
		// EVENT HANDLERS =======================================
		//---------------------------------------------------------------------------------------------
		static private function onPuzzlePaid(data:Object):void {
			echo("InnerNotificationManager", "onPuzzlePaid");
			if (CallManager.isActive())
				return;
			if (!Auth.getPushNitificationsAllowed())
				return;
			
			if (!('chatUID' in data))
				return;
				
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			var isCurrentlyInChatScreen:Boolean = MobileGui.centerScreen != null && MobileGui.centerScreen.currentScreenClass == ChatScreen;
			if (currentChat!=null && currentChat.type == ChatRoomType.COMPANY && isCurrentlyInChatScreen){
				return;
			}
			
			var chatModel:ChatVO = ChatManager.getChatByUID(data.chatUID);
			if (chatModel) {
				if (!chatModel.getPushAllowed()) {
					return;
				}
			}
			
			if (data.text != null && data.text.indexOf(Config.BOUNDS) == 0)
				return;
				
				
			var userName:String = Lang.textSomeone;		
			
			if ("user_name" in data) {
				userName = data['user_name'];
			}
			
			if (chatModel && chatModel.type == ChatRoomType.COMPANY) {
				userName = chatModel.title;
			}	
			
			if (("anonymous" in data) && data.anonymous == true) {
				userName = Lang.textIncognito;
			}
			
			var isMine:Boolean = data['user_uid'] == Auth.uid;
			if (isMine == true)
				return;
				
			var notificationMessage:String = "";			
			if (chatModel && chatModel.type == ChatRoomType.GROUP) {
				notificationMessage =  userName + Lang.boughtAPuzzle; // na vsjakij sluchaj 
			}else{
				notificationMessage = userName + Lang.boughtYourPuzzle;	
			}
			
		
			
			if (ChatManager.getCurrentChat() == null || ChatManager.getCurrentChat().uid != data["chatUID"] ) {
				if (clickedChatUID != "" && data["chatUID"] == clickedChatUID)
					return;
				InnerNotificationManager.pushNewMessageNotification(notificationMessage ,onNotificationClickCallback,data["chatUID"]);
			} else {
				if (clickedChatUID != "" && data["chatUID"] == clickedChatUID)
					return;
				var currentScreen:BaseScreen = MobileGui.centerScreen.currentScreen;
				if (currentScreen == null || !(currentScreen is ChatScreen)) {
					InnerNotificationManager.pushNewMessageNotification(notificationMessage ,onNotificationClickCallback,data["chatUID"]);
				}
			}
			
		}
		
		
		static private function onChatMessage(data:Object):void {
			echo("InnerNotificationManager", "onChatMessage");
			
			sendPushToNative(data);
			
			if (!Auth.getPushNitificationsAllowed())
				return;
			
			if (CallManager.isActive())
				return;
			
			if (!('chatUID' in data))
				return;	
				
			var isMine:Boolean = data['user_uid'] == Auth.uid;
			if (isMine == true)
				return;
				
			var chatModel:ChatVO = ChatManager.getChatByUID(data.chatUID);
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			
			var isCurrentlyInChatScreen:Boolean = MobileGui.centerScreen != null && Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreen);
			//var isCurrentlyInChatScreen:Boolean = MobileGui.centerScreen != null && MobileGui.centerScreen.currentScreenClass == ChatScreen;
			
			/*if (chatModel) {	
				if (chatModel.pid == Config.EP_VI_DEF || chatModel.pid == Config.EP_VI_EUR || chatModel.pid == Config.EP_VI_PAY ){	
					if (isCurrentlyInChatScreen && currentChat!= null){
						 if(currentChat.pid != Config.EP_VI_PAY 
							&& currentChat.pid != Config.EP_VI_EUR 	
							&& currentChat.pid != Config.EP_VI_DEF	
							&& currentChat.pid != Config.EP_911 
							&& currentChat.pid != Config.EP_MAIN  
							&& currentChat.pid != Config.EP_PAYMENTS){ 
								var chatScreenData:ChatScreenData = new ChatScreenData();
								chatScreenData.type = ChatInitType.CHAT;
								chatScreenData.chatVO = chatModel;
								chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
								chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
								MobileGui.showChatScreen(chatScreenData);
								return;
							}
					}else{
						var chatScreenData2:ChatScreenData = new ChatScreenData();
							chatScreenData2.type = ChatInitType.CHAT;
							chatScreenData2.chatVO = chatModel;
							chatScreenData2.backScreen = MobileGui.centerScreen.currentScreenClass;
							chatScreenData2.backScreenData = MobileGui.centerScreen.currentScreen.data;
							MobileGui.showChatScreen(chatScreenData2);
							return;
					}
				}
			}else{
				if ("pointID" in data) {
					 var destPID:int = data.pointID;
					 if( destPID == Config.EP_VI_DEF || destPID == Config.EP_VI_EUR || destPID == Config.EP_VI_PAY ){						 
						if (isCurrentlyInChatScreen && currentChat!= null){   
							 if(currentChat.pid != Config.EP_VI_PAY 
								&& currentChat.pid != Config.EP_VI_EUR 	
								&& currentChat.pid != Config.EP_VI_DEF 
								&& currentChat.pid != Config.EP_911 	 
								&& currentChat.pid != Config.EP_MAIN  
								&& currentChat.pid != Config.EP_PAYMENTS){
									var chatScreenData3:ChatScreenData = new ChatScreenData();
									chatScreenData3.pid = destPID;
									chatScreenData3.type = ChatInitType.SUPPORT;
									MobileGui.showChatScreen(chatScreenData3);
									return;
							}						 
						}else{
							var chatScreenData4:ChatScreenData = new ChatScreenData();
								chatScreenData4.pid = destPID;
								chatScreenData4.type = ChatInitType.SUPPORT;
								MobileGui.showChatScreen(chatScreenData4);
								return;
						}
					}				
				}
			}*/
			
				
			if (currentChat!=null && currentChat.type == ChatRoomType.COMPANY && isCurrentlyInChatScreen){
				return;
			}		
			
			
			if (chatModel) {					
				if (!chatModel.getPushAllowed()) {
					return;
				}
			}
			
			if (data.text != null && data.text.indexOf(Config.BOUNDS) == 0)
				return;
			var userName:String = Lang.textSomeone;
		
			if ("user_name" in data) {
				userName = data['user_name'];
			}
			if (chatModel && chatModel.type == ChatRoomType.COMPANY) {
				userName = Lang.textSupport;// chatModel.title;
			}
			
			
			
			if (("anonymous" in data) && data.anonymous == true){
				userName = Lang.textIncognito;
			}
			
		
			if (MobileGui.isActive == false)
				return;
				
			var notificationMessage:String = "";
			
			if (chatModel && chatModel.type == ChatRoomType.GROUP) {
				notificationMessage = userName + Lang.sentGroupMessage;
			} else {
				notificationMessage = userName + Lang.sentYouMessage;
			}
			
			if (ChatManager.getCurrentChat() == null || ChatManager.getCurrentChat().uid != data["chatUID"] ) {
				if (clickedChatUID != "" && data["chatUID"] == clickedChatUID)
					return;
				InnerNotificationManager.pushNewMessageNotification(notificationMessage, onNotificationClickCallback, data["chatUID"]);
			} else {
				if (clickedChatUID != "" && data["chatUID"] == clickedChatUID)
					return;
				var currentScreen:BaseScreen = MobileGui.centerScreen.currentScreen;
				if (currentScreen == null || !(currentScreen is ChatScreen)) {
					InnerNotificationManager.pushNewMessageNotification(notificationMessage, onNotificationClickCallback, data["chatUID"]);
				}
			}
		}
		
		static private function sendPushToNative(data:Object):void 
		{
			if (Config.PLATFORM_ANDROID == false)
			{
				return;
			}
			var needSend:Boolean = true;
			
			if (!Auth.getPushNitificationsAllowed())
			{
				needSend = false;
			}
			
			var isMine:Boolean = data['user_uid'] == Auth.uid;
			if (isMine == true)
			{
				needSend = false;
			}
			
			var chatModel:ChatVO;
			if ("chatUID" in data)
			{
				chatModel = ChatManager.getChatByUID(data.chatUID);
				var currentChat:ChatVO = ChatManager.getCurrentChat();
				
				var isCurrentlyInChatScreen:Boolean = MobileGui.centerScreen != null && Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreen);
				
				if (chatModel != null) {					
					if (!chatModel.getPushAllowed())
					{
						needSend = false;
					}
				}
				
				if (currentChat != null && chatModel != null && chatModel.uid == currentChat.uid && Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreen))
				{
					needSend = false;
				}
			}
			
			if (needSend)
			{
				NativeExtensionController.addPushMessage(data, chatModel);
			}
		}
		
		/*static private function appActivateHandler(e:Event):void {
			//NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, appActivateHandler);
			//waitingForActivate = false;
			//startTimerForClearing();
		}
		
		static private function startTimerForClearing():void {
			//TweenMax.delayedCall(1, clearNotifications);
		}
		
		public static function clearNotifications(e:Event = null):void {
			//notificationManager ||= new NotificationManager();
			//
			//messageCount = 0;
			//
			//NativeApplication.nativeApplication.removeEventListener(Event.EXITING, clearNotifications);
			//notificationManager.cancelAll();
			//notificationManager.dispose();
			//notificationManager = null;
		}*/
		
		/*private static function notificationActionHandler(e:NotificationEvent):void { 
			if (notificationCallBack != null) {
				notificationCallBack(e.actionData.extraParam);
				notificationCallBack = null;
			}
			clearNotifications();
		}*/
		
		private static var clickedChatUID:String = "";
		
		static public function onNotificationClickCallback(vo:NotificationVO):void {
			
			LightBox.close();
			
			if (vo.callbackData != null) {
				var destinationChatUID:String = vo.callbackData as String;
				if (destinationChatUID != "") {	
					trace(vo.message +" Open cahat with "+destinationChatUID);	
					//openChat(destinationChatUID);
					
					if (MobileGui.serviceScreen != null && MobileGui.serviceScreen.currentScreen != null) {
						ServiceScreenManager.closeView();
						MobileGui.centerScreen.activate();
					}
					
					var chatScreenData:ChatScreenData = new ChatScreenData();
						chatScreenData.chatUID = destinationChatUID;
						chatScreenData.type = ChatInitType.CHAT;
						chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
						chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
					
					MobileGui.showChatScreen(chatScreenData);
				//	MobileGui.changeMainScreen(ChatScreen, { uid:destinationChatUID , type:"chat", backScreen:MobileGui.centerScreen.currentScreenClass } );
					//InnerNotificationManager.clearAllNotifications();					
					InnerNotificationManager.removeNotificationsByChatUID(destinationChatUID);
					
					clickedChatUID = destinationChatUID;
					TweenMax.killDelayedCallsTo(resetClickedChatUID);
					TweenMax.delayedCall(1, resetClickedChatUID);
					//InnerNotificationManager.clearNotifiationsByType(vo.type);
				}			
			}
		}
		
		private static function resetClickedChatUID():void
		{
			clickedChatUID = "";
		}
		
		static private function onClick(e:MouseEvent):void {
			if (isClickable) {
				e.stopImmediatePropagation();
				e.preventDefault();
				var notificationData:NotificationVO = currentData;				
				// check if close icon was pressed
				if (e.stageX > MobileGui.stage.stageWidth - Config.FINGER_SIZE) {									
					if (notificationData!=null && notificationData.callbackData != null) {
						var destinationChatUID:String = notificationData.callbackData as String;
						if (destinationChatUID != "") {	
							removeNotificationsByChatUID(destinationChatUID);
						}
						forceHide();
						return;						
					}		
					clearAllNotifications();
					forceHide();					
					return;
				}
							
				if (notificationData.callback != null) {
					notificationData.callback(notificationData);
				}
				S_NOTIFICATION_CLICKED.invoke(notificationData);
				forceHide();
			}
		}
		
		// ACCESSOR INTERFACE =======================================
		//----------------------------------------------------------------------------------------------------------------------
		
		public static function pushNewMessageNotification(txt:String, callback:Function = null, callbackData:Object = null,type:int = NotificationVO.TYPE_NEW_MESSAGE):void		{
			var newVO:NotificationVO = getVO();
			newVO.type = type;
			newVO.message = txt;
			newVO.hasIcon = true;
			newVO.callback = callback;
			newVO.callbackData = callbackData;
			newVO.NOTIFICATION_BG_COLOR = planeColor;
			newVO.NOTIFICATION_TEXT_COLOR = 0xffffff;
			newVO.iconType = 12;// Frame of icon 
			pushNotification(newVO);
			
			NewMessageNotifier.dispatchUpdate();
		}
		
		public static function pushNewBuissinessNotification(txt:String, callback:Function = null, callbackData:Object = null,type:int = NotificationVO.TYPE_BUISSINESS_MESSAGE):void
		{
			var newVO:NotificationVO = getVO();
			newVO.type = type;
			newVO.message = txt;
			newVO.hasIcon = true;
			newVO.callback = callback;
			newVO.callbackData = callbackData;
			newVO.NOTIFICATION_BG_COLOR =  0xff0000;
			newVO.NOTIFICATION_TEXT_COLOR = 0xffffff;
			newVO.iconType = 14;// Frame of icon 
			pushNotification(newVO);
		}
		
		public static function pushNotification(vo:NotificationVO):void
		{
			if (!isInitialized) {
				trace("InnerNotificationManager::pushNotification -> Not initialized");
				return;
			}
			dataStock[dataStock.length] = vo;
			showNext();			
		}
		
		public static function clearAllNotifications():void
		{
			if (!isInitialized) {
				trace("InnerNotificationManager::clearAllNotifications -> Not initialized");
				return;
			}
			
			const l:int = dataStock.length;
			var dataObj:NotificationVO;
			for (var i:int = 0; i < l; i++) {
				dataObj = dataStock[i];
				returnVO(dataObj);
			}
			dataStock.length = 0;
			isClickable = false;
		}
		
		/** CLEAR PUSH NOTIFICATIONS BY TYPE  **/
		public static function k(type:int):void {
			if (!isInitialized) {
				trace("NotificationManager::clearNotifiationsByType -> Not initialized");
				return;
			}
			
			if (isNaN(type)) {
				trace("NotificationManager::clearNotifiationsByType -> Cannot clear notification by type " + type);
				return;
			}
			
			var dataObj:NotificationVO;
			var resultArray:Array = [];
			const l:int = dataStock.length;			
			for (var i:int = 0; i <l ; i++) {
				dataObj = dataStock[i];
				if(dataObj.type == type){
					returnVO(dataObj);
					dataStock[i] = null;
				} else
					resultArray[resultArray.length] = dataObj;
			}
			dataStock = resultArray;
			isClickable = dataStock.length > 0;
		}
		
		/** CLEAR PUSH NOTIFICATIONS BY CHAT UID  **/
		public static function removeNotificationsByChatUID(chatUID:String):void {
			if (!isInitialized) {
				trace("NotificationManager::removeNotificationsByChatUID -> Not initialized");
				return;
			}			
			if (chatUID == null) {
				trace("NotificationManager::removeNotificationsByChatUID -> Cannot clear notification by ChatUID " + chatUID);
				return;
			}
			
			var dataObj:NotificationVO;
			var resultArray:Array = [];
			const l:int = dataStock.length;			
			for (var i:int = 0; i <l ; i++) {
				dataObj = dataStock[i];
			
				if(dataObj.callbackData as String == chatUID){
					returnVO(dataObj);
					dataStock[i] = null;
				} else
					resultArray[resultArray.length] = dataObj;
			}
			dataStock = resultArray;
			isClickable = dataStock.length > 0;
		}
		
		/** FORCE TO HIDE CURRENT NOTIFICATION */
		public static function forceHide():void {
			if (!isInitialized) {
				trace("InnerNotificationManager::forceHide -> Not initialized");
				return;
			}
			TweenMax.killTweensOf(notificationCanvas);
			TweenMax.killDelayedCallsTo(hidePlane);
			hidePlane();
		}
		
		private static var tempRect:Rectangle = new Rectangle();
		//static private var notificationManager:NotificationManager;
		
			/** WIDTH **/
			
			// WIDTH SETS TO 0
		public static function setWidth(value:Number):void {
			if (value < 1) value = 1;
			if (value == _viewWidth) return;
			_viewWidth = value;
			//update text 
			//tf.width = _viewWidth;
			
			//redraw renderer
			if (planeBitmapData != null && planeBitmapData.rect.width != value) {
				var planeHeight:int =  ICON_SIZE+Config.DOUBLE_MARGIN * 2+topOffset;
				var oldBMD:BitmapData = planeBitmapData;
				
				//TODO - ERROR _viewWidth==0 !!!!!!!!!!!!!!!!!!
				
				planeBitmapData = new ImageBitmapData("InnerNotificationManager.planeBitmapData", _viewWidth, planeHeight, false, planeColor);	
				oldBMD.dispose();
				if (currentData != null) {
					currentBitmapData = renderToBitmapData(currentData);
					notificationCanvas.bitmapData = currentBitmapData;
				}
			}
			
			if (planesHolder != null) {
				tempRect.x = 0;
				tempRect.y = 0;
				tempRect.width = _viewWidth;
				tempRect.height =  ICON_SIZE+Config.MARGIN * 2+topOffset;
				planesHolder.scrollRect = tempRect;
			}
		}
		
		
		// Pause Showing Notification
		public static function pause():void{
			isPaused = true;
		}
		
		// Unpause Showing Notification
		public static function unpause():void {
			if (!isPaused) return;
			isPaused = false;
			showNext();
		}
		
		
		
		/** NEXT **/
		private static function showNext():void {
			
			if (isPaused) return;
			if (isBusy) return;
			if (Auth.isDialogOpened() == true)
				return;
			const l:int  = dataStock.length;
			if (l > 0) {
				isBusy = true;
				isClickable = false;
				//alocate canvas bitmap if canvasbitmap is null
				currentData =  dataStock.shift();
				currentBitmapData = renderToBitmapData(currentData);
				container.addChild(planesHolder);
				showPlane();
			} else {
				isBusy = false;
				isClickable = false;
				// release canvas bitmap
			}
		}
		
		/** SHOW **/
		private static function showPlane():void {
			notificationCanvas.bitmapData = currentBitmapData;
			planesHolder.addChild(notificationCanvas);
			
			notificationCanvas.visible = true;
			notificationCanvas.y = -currentBitmapData.height;
			notificationCanvas.height =	currentBitmapData.height -1; 		
			
			TweenMax.killTweensOf(notificationCanvas);
			TweenMax.to(notificationCanvas, 0, { colorTransform: { tint:SHADER_COLOR_DARK, tintAmount:0.4 } } );
			TweenMax.to(notificationCanvas, NOTIFICATION_SHOW_TIME, {useFrames:true, y:0, colorTransform: { tint:SHADER_COLOR_DARK, tintAmount:0 }, ease:Quart.easeInOut, onComplete:onPlaneShowComplete } );
		}
		
		/** SHOW COMPLETE **/
		static private function onPlaneShowComplete():void {
			echo("InnerNotificationManager", "onPlaneShowComplete");
			isClickable = true;
			var displayTime:Number = NOTIFICATION_DISPLAY_TIME;
			if (currentData && "display_time" in currentData ) {
				displayTime = currentData["display_time"];
			}
			notificationCanvas.height =	currentBitmapData.height;
			notificationCanvas.transform.matrix3D = null;			
			TweenMax.killDelayedCallsTo(hidePlane);
			TweenMax.delayedCall(displayTime, hidePlane);
		}
		
		/** HIDE **/
		static private function hidePlane():void {
			echo("InnerNotificationManager", "hidePlane");
			isClickable = false;
			notificationCanvas.height =	currentBitmapData.height -1; 
			
			if(dataStock.length>0){
				//TweenMax.killTweensOf(notificationCanvas);
				//TweenMax.to(notificationCanvas,NOTIFICATION_HIDE_TIME,{useFrames:true,y:currentBitmapData.height,  colorTransform: { tint:SHADER_COLOR_DARK, tintAmount:0.4 },ease:Quint.easeInOut,  onComplete:onPlaneHideComplete});
				//
				var cloneBitmap:Bitmap = new Bitmap();
				cloneBitmap.bitmapData = notificationCanvas.bitmapData.clone();
				cloneBitmap.x = notificationCanvas.x;
				cloneBitmap.y = notificationCanvas.y;
				planesHolder.addChild(cloneBitmap);				
				TweenMax.killTweensOf(cloneBitmap);
				TweenMax.to(cloneBitmap, NOTIFICATION_SHOW_TIME+1 , {useFrames:true, y:cloneBitmap.height,  colorTransform: { tint:SHADER_COLOR_DARK, tintAmount:0.4 }, ease:Quart.easeInOut,  onComplete:onCloneHideComplete, onCompleteParams:[cloneBitmap]});
				onPlaneHideComplete();
			}else {
				// hide last notification to top
				TweenMax.killTweensOf(notificationCanvas);
				TweenMax.to(notificationCanvas, NOTIFICATION_HIDE_TIME, { useFrames:true, y: -currentBitmapData.height,  colorTransform: { tint:SHADER_COLOR_DARK, tintAmount:0.4 }, ease:Quint.easeInOut,  onComplete:onPlaneHideComplete } );
			}
		}
		
		/** HIDE COMPLETE **/
		static private function onPlaneHideComplete():void {
			echo("InnerNotificationManager","onPlaneHideComplete");
			isClickable = false;			
			returnVO(currentData);			
			currentData = null;			
			notificationCanvas.bitmapData = null;
			notificationCanvas.visible = false;
			isBusy = false;
			showNext();
		}
		
		/** CLONE HIDE COMPLETE **/
		static private function onCloneHideComplete(bmp:Bitmap):void {
			echo("InnerNotificationManager", "onCloneHideComplete");
			if (bmp != null) {
				UI.destroy(bmp);					
				bmp =null;
			}
		}
		
		//RENDER =================================================================
		
		/*** GENERATE NOTIFICATION RENDERER  **/
		private static function renderToBitmapData(vo:NotificationVO):BitmapData {
			//var planeHeight:int =  iconSize+PADDING * 2 + topOffset;		
			var planeHeight:int =  ICON_SIZE+Config.MARGIN/*Config.DOUBLE_MARGIN */* 2 + topOffset;		
			// Plane BG 
			planeBitmapData ||= new ImageBitmapData("InnerNotificationManager.renderToBitmapData", _viewWidth, planeHeight, false, vo.NOTIFICATION_BG_COLOR);
			planeBitmapData.lock();
			planeBitmapData.fillRect(planeBitmapData.rect, planeColor);			
			var textX:int;
			var textY:int ;
			var iconX:int = Config.DOUBLE_MARGIN;
			var iconY:int =/* Config.DOUBLE_MARGIN */Config.MARGIN+ topOffset;
			
			if (vo.type == NotificationVO.TYPE_NEW_MESSAGE || vo.type == NotificationVO.TYPE_BUISSINESS_MESSAGE || vo.type == NotificationVO.TYPE_FILE) {
				// render default notification
				if (vo.hasIcon) {
					
					//!TODO: why icons in Wowzacams.swc? Why this icons in one clip in different frames? How to add new icon without FLA?! Why icon creation and layout logic in one "IF"?
					//So, hack
					if (vo.type == NotificationVO.TYPE_FILE)
					{
						var iconFile:IconNotificationFile = new IconNotificationFile();
						UI.scaleToFit(iconFile, ICON_SIZE, ICON_SIZE);
						msgIconData = UI.getSnapshot(iconFile, StageQuality.HIGH, "InnerNitificationsManager.iconFile");
					}
					else {
						msgIconData = UI.getIconByFrame(vo.iconType, ICON_SIZE,ICON_SIZE); // 12 - msg icon 13- warning icon 
					}
					if (msgIconData)
					{
						planeBitmapData.copyPixels(msgIconData, msgIconData.rect, getPoint(iconX, iconY));
						msgIconData.dispose();
					}
				}				
				var textWidth:int = vo.hasIcon?_viewWidth - ICON_SIZE - Config.DOUBLE_MARGIN * 4: _viewWidth - Config.DOUBLE_MARGIN * 2; 
				var textHeight:int = Config.FINGER_SIZE * .21 * 3 ;
				
				// textWidth esli 
				if(textWidth>0){
					var textBmd:BitmapData = UI.renderText(vo.message,textWidth, textHeight, false,TextFormatAlign.LEFT,TextFieldAutoSize.NONE,Config.FINGER_SIZE * 0.21,true,vo.NOTIFICATION_TEXT_COLOR,vo.NOTIFICATION_BG_COLOR);
						textY = iconY + ICON_SIZE * .5 - textBmd.height*.2;
						textX = vo.hasIcon?ICON_SIZE+Config.DOUBLE_MARGIN*2:_viewWidth-textWidth-Config.DOUBLE_MARGIN;// PADDING + iconX + iconSize;
						planeBitmapData.copyPixels(textBmd, textBmd.rect, getPoint(textX, textY));
						textBmd.dispose();
						textBmd = null;
				}
			}
			// render close Icon 
			var closeIconSize:int =  Config.FINGER_SIZE_DOT_35;	
			if(MobileGui.stage!=null){
				var closeIconBMD:BitmapData = getCloseIcon(closeIconSize);
				planeBitmapData.copyPixels(closeIconBMD, closeIconBMD.rect, getPoint(MobileGui.stage.stageWidth - closeIconSize- Config.DOUBLE_MARGIN, planeHeight*.5 - closeIconSize*.5+topOffset*.5));
			}
			planeBitmapData.unlock();
			return planeBitmapData;
		}
		
		private static function getCloseIcon(size:int):BitmapData {
			if (closeIconData == null){
				// we use only one instance for all notifications so do not dispose closeIconData 
				// maybe should dispose on timer if notifications is not showing anymore
				var asset:SWFCloseIconThin = new SWFCloseIconThin();
				var c:ColorTransform = new ColorTransform();
				c.color = 0xffffff;
				asset.transform.colorTransform = c;
				closeIconData ||= UI.renderAsset(asset, size, size, true, "InerNotificationManager.closeIcon"); 
				c = null;
			}
			return closeIconData;
		}
		
		private static function getPoint(x:int=0, y:int=0):Point {
			tempPoint.x = x;
			tempPoint.y = y;
			return tempPoint;
		}
		
		/** GET VO **/
		public static function getVO():NotificationVO {
			if (objectPool.length > 0)
				return objectPool.pop();
			return new NotificationVO();
		}
		
		/** RETURN VO **/
		private static function returnVO(vo:NotificationVO):void{
			if (vo==null)
				return;
			vo.reset();
			objectPool[objectPool.length] = vo;
		}
	}
}