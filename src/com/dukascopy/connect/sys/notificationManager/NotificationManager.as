package com.dukascopy.connect.sys.notificationManager 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.settings.GlobalSettings;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Alexey
	 */
	public class NotificationManager 
	{
		public static var S_NOTIFICATION_CLICKED:Signal = new Signal("NotificationManager.S_NOTIFICATION_CLICKED");
		
		// some params
		private static const NOTIFICATION_SHOW_TIME:Number = 40;// .6;
		private static const NOTIFICATION_HIDE_TIME:Number = 30;// .4;
		private static const NOTIFICATION_DISPLAY_TIME:Number = 2.5;
		
		private static const SHADER_COLOR_DARK:uint = 0x000000;
		private static const SHADER_COLOR_LIGHT:uint = 0x000000;

		private static var planeColor:uint = 0xFF0000;
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
	
	
		
		
		
		public function NotificationManager() 
		{
			
		}
		
		
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
			ICON_SIZE =  Math.ceil(Config.FINGER_SIZE * .35) * 2;

			if (Config.PLATFORM_APPLE)
				topOffset = Config.FINGER_SIZE*.2;
			planesHolder.y = 0;// topOffset;
			planesHolder.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			
			WSClient.S_CHAT_MSG.add(onChatMessage);
		}
		
		// EVENT HANDLERS =======================================
		//---------------------------------------------------------------------------------------------
		
		static private function onChatMessage(data:Object):void {
			echo("NotoficationManager", "onChatMessage", data);
			if (!GlobalSettings.notifications) return;	
			if (!('chatUID' in data))	return;
			var isMine:Boolean = data['user_uid'] == Auth.uid;
			var notificationMessage:String;
			
			if (isMine) {
				notificationMessage = "You have sent message from other instance";
			}else {
				notificationMessage = data['user_name'] + " sent you a message";		
			}			
			
			if (ChatManager.currentChat==null || ChatManager.currentChat.uid != data["chatUID"]){
				NotificationManager.pushNewMessageNotification(notificationMessage ,onNotificationClickCallback,data["chatUID"]);
			}else{
				var currentScreen:BaseScreen = MobileGui.centerScreen.currentScreen;
				if (currentScreen == null || !(Utils.isSubclassOf(MobileGui.centerScreen.currentScreenClass, ChatScreen))) {
					NotificationManager.pushNewMessageNotification(notificationMessage ,onNotificationClickCallback,data["chatUID"]);
				}
			}
		}	
		
		static private function onNotificationClickCallback(vo:NotificationVO):void		{
			if (vo.callbackData != null) {
				var destinationChatUID:String = vo.callbackData as String;
				if (destinationChatUID != "") {	
					trace(vo.message +" Open cahat with "+destinationChatUID);	
					//openChat(destinationChatUID);
					MobileGui.showChatScreen({ uid:destinationChatUID , type:"chat" } );
				//	MobileGui.changeMainScreen(ChatScreen, { uid:destinationChatUID , type:"chat" } );
					NotificationManager.clearNotifiationsByType(vo.type);
				}			
			}
		}
		
		
		
		static private function onClick(e:MouseEvent):void {
			if (isClickable) {
				e.stopImmediatePropagation();
				e.preventDefault();
				var notificationData:NotificationVO = currentData;
				if (notificationData.callback != null) {
					notificationData.callback(notificationData);
				}
				S_NOTIFICATION_CLICKED.invoke(notificationData);
				forceHide();
			}
		}
		
		
		// ACCESSOR INTERFACE =======================================
		//----------------------------------------------------------------------------------------------------------------------
		
		public static function pushNewMessageNotification(txt:String, callback:Function = null, callbackData:Object = null,type:int = NotificationVO.TYPE_NEW_MESSAGE):void
		{
			if (!GlobalSettings.notifications) return;	
			var newVO:NotificationVO = getVO();
			newVO.type = type;
			newVO.message = txt;
			newVO.hasIcon = true;
			newVO.callback = callback;
			newVO.callbackData = callbackData;
			newVO.NOTIFICATION_BG_COLOR =  0xff0000;
			newVO.NOTIFICATION_TEXT_COLOR = 0xffffff;
			newVO.iconType = 12;// Frame of icon 
			pushNotification(newVO);
			
		}
		
			
		
		public static function pushNewBuissinessNotification(txt:String, callback:Function = null, callbackData:Object = null,type:int = NotificationVO.TYPE_BUISSINESS_MESSAGE):void
		{
			if (!GlobalSettings.notifications) return;	
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
		public static function clearNotifiationsByType(type:int):void {
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
		
			/** WIDTH **/
		public static function setWidth(value:Number):void {
			if (value == _viewWidth) return;
			_viewWidth = value;
			//update text 
			//tf.width = _viewWidth;
			
			//redraw renderer
			if (planeBitmapData != null && planeBitmapData.rect.width != value) {
				var planeHeight:int =  ICON_SIZE+Config.DOUBLE_MARGIN * 2+topOffset;
				var oldBMD:BitmapData = planeBitmapData;
				planeBitmapData = new ImageBitmapData("NotificationManager.planeBitmapData", _viewWidth, planeHeight, false, planeColor);	
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
				tempRect.height =  ICON_SIZE+Config.DOUBLE_MARGIN * 2+topOffset;
				planesHolder.scrollRect =tempRect;
			}

		}
		
		/** NEXT **/
		private static function showNext():void {
			if (isBusy) return;
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
			echo("NotificationManager", "onPlaneShowComplete"); 
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
			echo("NotificationManager", "hidePlane");
			isClickable = false;
			notificationCanvas.height =	currentBitmapData.height -1; 
			
			if(dataStock.length>0){
				var cloneBitmap:Bitmap = new Bitmap();
				cloneBitmap.bitmapData = notificationCanvas.bitmapData.clone();
				cloneBitmap.x = notificationCanvas.x;
				cloneBitmap.y = notificationCanvas.y;
				planesHolder.addChild(cloneBitmap);
				
				TweenMax.killTweensOf(cloneBitmap);
				TweenMax.to(cloneBitmap, NOTIFICATION_SHOW_TIME+1 , {useFrames:true, y:cloneBitmap.height,  colorTransform: { tint:SHADER_COLOR_DARK, tintAmount:0.4 }, ease:Quart.easeInOut,  onComplete:onCloneHideComplete, onCompleteParams:[cloneBitmap]});
				
				onPlaneHideComplete();
			} else {
				// hide last notification to top
				TweenMax.killTweensOf(notificationCanvas);
				TweenMax.to(notificationCanvas, NOTIFICATION_HIDE_TIME, {useFrames:true, y: -currentBitmapData.height,  colorTransform: { tint:SHADER_COLOR_DARK, tintAmount:0.4 }, ease:Quint.easeInOut,  onComplete:onPlaneHideComplete } );
			}
		}
			
		
		/** HIDE COMPLETE **/
		static private function onPlaneHideComplete():void {
		    echo("NotificationManager","onPlaneHideComplete");
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
			echo("NotificationManager","onCloneHideComplete");
			if (bmp != null) {
				UI.destroy(bmp);
				bmp =null;
			}
		}
		
		//RENDER =================================================================

		/*** GENERATE NOTIFICATION RENDERER  **/
		private static function renderToBitmapData(vo:NotificationVO):BitmapData {
			//var planeHeight:int =  iconSize+PADDING * 2 + topOffset;		
				var planeHeight:int =  ICON_SIZE+Config.DOUBLE_MARGIN * 2+topOffset;
			// Plane BG 
			planeBitmapData ||= new ImageBitmapData("NotificationManager.planeBitmapData", _viewWidth, planeHeight, false, vo.NOTIFICATION_BG_COLOR);
			planeBitmapData.lock();
			planeBitmapData.fillRect(planeBitmapData.rect, planeColor);			
			var textX:int;
			var textY:int ;
			var iconX:int = Config.DOUBLE_MARGIN;
			var iconY:int = Config.DOUBLE_MARGIN + topOffset;
			
			if (vo.type == NotificationVO.TYPE_NEW_MESSAGE || vo.type == NotificationVO.TYPE_BUISSINESS_MESSAGE) {
				// render default notification
				if(vo.hasIcon){
					msgIconData = UI.getIconByFrame(vo.iconType, ICON_SIZE,ICON_SIZE); // 12 - msg icon 13- warning icon 
					planeBitmapData.copyPixels(msgIconData, msgIconData.rect, getPoint(iconX, iconY));
				}				
				var textWidth:int = vo.hasIcon?_viewWidth - ICON_SIZE - Config.DOUBLE_MARGIN * 4: _viewWidth - Config.DOUBLE_MARGIN * 2; 
				var textHeight:int = Config.FINGER_SIZE * .21 * 3 ;
					var textBmd:BitmapData = UI.renderText(vo.message,textWidth, textHeight, false,TextFormatAlign.LEFT,TextFieldAutoSize.NONE,Config.FINGER_SIZE * 0.21,true,vo.NOTIFICATION_TEXT_COLOR,vo.NOTIFICATION_BG_COLOR);
					textY = iconY + ICON_SIZE * .5 - textBmd.height*.2;
					textX = vo.hasIcon?ICON_SIZE+Config.DOUBLE_MARGIN*2:_viewWidth-textWidth-Config.DOUBLE_MARGIN;// PADDING + iconX + iconSize;
					planeBitmapData.copyPixels(textBmd, textBmd.rect, getPoint(textX, textY));
					textBmd.dispose();
					textBmd = null;
			}
			planeBitmapData.unlock();
			return planeBitmapData;
		}
		
		/** MSG ICON **/
		//private static function getMessageIcon():BitmapData {
			//var src:BitmapData = Assets.getBitmap(Assets.NOTIFICATION_MSG_ICON);
			//var resizedBmd:BitmapData = FastUtils.scaleManual(src, iconSize / src.height);
			//src = null;
			//Assets.disposeBitmap(Assets.NOTIFICATION_MSG_ICON);
			//return resizedBmd;
		//}
		
		// END RENDER ===============================
		
		
		private static function getPoint(x:int=0, y:int=0):Point {
			tempPoint.x = x;
			tempPoint.y = y;
			return tempPoint;
		}
		
		
		/** GET VO **/
		public static function getVO():NotificationVO {
			if (objectPool.length > 0) {
				return objectPool.pop();
			}
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