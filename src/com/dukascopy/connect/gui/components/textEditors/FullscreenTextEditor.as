package com.dukascopy.connect.gui.components.textEditors {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.textedit.TextComposer;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class FullscreenTextEditor {
		
		private var messageComposer:TextComposer;
		private var callback:Function;
		
		public function FullscreenTextEditor() { }
		
		private function createMessageComposer():void {
			if (messageComposer == null)
				messageComposer = new TextComposer();
			messageComposer.MAX_CHARS = 512;
		}
		
		public function editText(value:String, callback:Function):void {
			this.callback = callback;
			if (MobileGui.centerScreen != null && MobileGui.centerScreen.currentScreen != null)
				MobileGui.centerScreen.deactivate();
			createMessageComposer();
			messageComposer.setSize(MobileGui.stage.stageWidth, MobileGui.stage.stageHeight);
			MobileGui.stage.addChild(messageComposer);
			var messageText:String  = value != null ? value : "";
			messageComposer.show(onMessageComposeComplete, Lang.TEXT_COMPOSE_MESSAGE, messageText);
		}
		
		public function setSize(width:int, height:int):void {
			if (messageComposer)
				messageComposer.setSize(width, height);
		}
		
		private function onMessageComposeComplete(isOk:Boolean, result:String = "", dataObject:Object = null):void {
			if (isOk == true) {
				messageComposer.hide(true);
				if (callback != null)
					callback(isOk, result);
			} else {
				messageComposer.hide();
				if (callback != null)
					callback(isOk);
			}
			if (MobileGui.centerScreen != null && MobileGui.centerScreen.currentScreen != null) {
				if (MobileGui.serviceScreen != null && MobileGui.serviceScreen.currentScreen != null) {
					if (MobileGui.serviceScreen != null && MobileGui.serviceScreen.currentScreen != null)
						MobileGui.serviceScreen.activate();
					else
						MobileGui.centerScreen.activate();
				} else
					MobileGui.centerScreen.activate();
			}
		}
		
		public function dispose():void {
			callback = null;
			if (messageComposer != null)
				messageComposer.dispose();
			messageComposer = null;
		}
	}
}