package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.RateBotData;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.screens.serviceScreen.WebViewReactionPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import flash.events.StatusEvent;
	import flash.net.URLVariables;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BotReactionAction extends BaseAction implements IAction {
		
		private var rateBotData:RateBotData;
		private var chatUID:String;
		private var userUID:String;
		private var requestId:String;
		
		public function BotReactionAction(rateBotData:RateBotData, chatUID:String, userUID:String) {
			this.rateBotData = rateBotData;
			this.chatUID = chatUID;
			this.userUID = userUID;
		}
		
		public function execute():void {
			if (Config.PLATFORM_ANDROID == true) {
				requestId = Math.random().toString()
				MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
				NativeExtensionController.showWebViewReaction(rateBotData.link, rateBotData.action, requestId);
			} else {
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG,
					WebViewReactionPopup,
					{
						link:rateBotData.link,
						action:rateBotData.action,
						callback:onWebViewActionTrigger
					}
				);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			if (Config.PLATFORM_ANDROID == true) {
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void {
			if (e.code == "webViewReaction") {
				var args:Object;
				try {
					args = JSON.parse(e.level);
				} catch (err:Error) {
					ApplicationErrors.add();
				}
				if (args != null && args.hasOwnProperty("method") && args.hasOwnProperty("value") && args.value == requestId) {
					switch (args.method) {
						case "action": 
						{
							onResult(getAction(args.url), getUrlData(args.url));
							break;
						}
						case "close": 
						{
							onResult("popup_closed");
							break;
						}
						case "remove": 
						{
							if (disposed == false) {
								onResult("popup_closed");
							}
							break;
						}
					}
				}
			}
		}
		
		private function onResult(action:String, urlData:Object = null):void {
			if (disposed == false) {
				ChatManager.sendBotActionMessage(action, null, urlData, chatUID, userUID);
				dispose();
			}
		}
		
		private function onWebViewActionTrigger(success:Boolean, url:String):void {
			if (success == true) {
				onResult(getAction(url), getUrlData(url));
			} else {
				onResult("popup_closed");
			}
		}
		
		private function getAction(url:String):String {
			var action:String = "no_action";
			if (url != null) {
				var vars:URLVariables = new URLVariables(url);
				for (var key:String in vars) {
					if (key != null && key.indexOf(rateBotData.action) != -1) {
						action = vars[key];
					}
				}
			}
			return action;
		}
		
		private function getUrlData(url:String):Object {
			var result:Object = new Object();
			if (url != null) {
				var vars:URLVariables = new URLVariables(url);
				for (var key:String in vars) {
					if (key != null && key.indexOf("?" + rateBotData.action) == -1) {
						result[key] = vars[key];
					}
				}
			}
			return result;
		}
	}
}