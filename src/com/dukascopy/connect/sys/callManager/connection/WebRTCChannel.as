package com.dukascopy.connect.sys.callManager.connection 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WSClient;
	import connect.IosChatUser;
	import flash.events.StatusEvent;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class WebRTCChannel 
	{
		private var state:String;
		private var initiator:Boolean;
		private var callee:String;
		private var userName:String;
		private var userAvatar:String;
		private var inCall:Boolean = false;
		
		static public const STATE_PREPARE:String = "statePrepare";
		static public const METHOD_BLACK_HOLE:String = "callSignaling";
		
		public function WebRTCChannel(initiator:Boolean, callee:String, userName:String, userAvatar:String) 
		{
			this.initiator = initiator;
			this.userName = userName;
			this.userAvatar = userAvatar;
			
			this.userAvatar = UsersManager.getAvatarImageById(callee, userAvatar, Config.FINGER_SIZE * 3);
			
			this.callee = callee;
			init();
		}
		
		private function init():void
		{
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, statusHandlerAndroid);
				
				WSClient.S_SIGNALING.add(onSocketData);
			}
			else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				MobileGui.dce.addEventListener(StatusEvent.STATUS, statusHandlerIos);
			}
		}
		
		public function close():void
		{
			WSClient.S_SIGNALING.remove(onSocketData);
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, statusHandlerAndroid);
			}
			else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandlerIos);
			}
			inCall = false;
		}
		
		private function onSocketData(data:Object):void 
		{
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.onCallMessage(JSON.stringify(data.message));
			}
		}
		
		public function placeCall():void
		{
			inCall = true;
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.onCallStarted(initiator);
			}
			else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				var user:IosChatUser = new IosChatUser();
				user.id = callee;
				user.name = userName;
				user.avatar = userAvatar;
				
				if (initiator)
				{
					MobileGui.dce.showCallerCallView();
				}
				else
				{
					MobileGui.dce.showCalleeCallView();
				}
			}
		}
		
		public function showDialingView():void 
		{
			if (inCall) {
				return;
			}
			inCall = true;
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.startCall(initiator, userName, userAvatar, Auth.uid);
			}
			else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				var user:IosChatUser = new IosChatUser();
				user.id = callee;
				user.name = userName;
				user.avatar = userAvatar;
				
				if (initiator)
				{
					MobileGui.dce.showCallerDialingView(user, Auth.uid);
				}
				else
				{
					MobileGui.dce.showCalleeDialingView(user, Auth.uid);
				}
			}
		}
		
		public function endCall():void 
		{
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.closeCall();
			}
			else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				//!
			//	MobileGui.dce.hideCallView();
			}
			inCall = false;
		}
		
		public function closeCall():void
		{
			if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				MobileGui.dce.hideCallView();
			}
			inCall = false;
		}
		
		public function isInCall():Boolean 
		{
			return inCall;
		}
		
		private function statusHandlerIos(e:StatusEvent):void
		{
			if (e.code == "call")
			{
				if (e.level == "didCancelOutgoingDialing")
				{
					CallManager.cancel();
				}
				else if (e.level == "didCancelIncomingDialing")
				{
					CallManager.reject();
				}
				else if (e.level == "didAcceptCall")
				{
					CallManager.accept(CallManager.MODE_AUDIO);
				}
				else if (e.level == "didFinishCall")
				{
					CallManager.finish();
				}
			}
		}
		
		private function statusHandlerAndroid(e:StatusEvent):void
		{
			var data:Object;
			
			if (e.code == "Call.sendMessage")
			{
				e.stopImmediatePropagation();
				e.preventDefault();
				
				data = new Object();
				data.message = JSON.parse(e.level);
				
				WSClient.call_blackHole([callee], METHOD_BLACK_HOLE, data);
			}
			else if (e.code == "Call.sendBlock")
			{
				e.stopImmediatePropagation();
				e.preventDefault();
				
				data = new Object();
				data.message = JSON.parse(e.level);
				
				WSClient.call_blackHole([callee], METHOD_BLACK_HOLE, data);
			}
			else if (e.code == "Call.call")
			{
				if (e.level == "cancelCall")
				{
					CallManager.cancel();
				}
				else if (e.level == "rejectCall")
				{
					CallManager.reject();
				}
				else if (e.level == "acceptCall")
				{
					CallManager.accept(CallManager.MODE_AUDIO);
				}
				else if (e.level == "callEnded")
				{
					CallManager.finish();
				}
			}
		}
	}
}