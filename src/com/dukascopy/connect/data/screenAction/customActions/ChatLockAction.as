package com.dukascopy.connect.data.screenAction.customActions{
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	
	public class ChatLockAction extends ScreenAction implements IScreenAction{
		public function ChatLockAction(){
		}
		
		public function execute():void{
			if (ChatManager.getCurrentChat() != null) {
				if (ChatManager.getCurrentChat().locked)
					showDoUnlockAlert();
				else 
					showDoLockAlert();
			}
		}
		
		private function showDoLockAlert():void	{
			DialogManager.showPin(function(val:int, pin:String):void {
				if (val != 1)
					return;
				if (pin.length == 0)
					return;
				TweenMax.delayedCall(1, function():void {
					ChatManager.addPin(pin);
					onLockValueChanged();
				}, null, true);
			} );
		}
		
		private function showDoUnlockAlert():void {
			DialogManager.alert(Lang.textAlert, Lang.areYouSureRemovePin, function(val:int):void {
				if (val != 1)
					return;
				ChatManager.removePin();
				onLockValueChanged();
			}, Lang.textYes.toUpperCase(), Lang.textCancel.toUpperCase());
		}
		
		private function onLockValueChanged():void {
			GD.CHAT_LOCK_CHANGED.invoke();
		}
		
		override public function getIconClass():Class {
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().locked)
			{
				return Style.icon(Style.ICON_LOCK);
			}
			
			return Style.icon(Style.ICON_UNLOCK);
		}
	}
}