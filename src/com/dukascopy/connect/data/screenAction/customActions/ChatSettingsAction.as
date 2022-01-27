package com.dukascopy.connect.data.screenAction.customActions{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.chat.ChannelInfoModeratorScreen;
	import com.dukascopy.connect.screens.chat.ChannelInfoScreen;
	import com.dukascopy.connect.screens.chat.ChatSettingsScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatRoomType;
	
	public class ChatSettingsAction extends ScreenAction implements IScreenAction{
		public function ChatSettingsAction(){
		}
		
		public function execute():void{
			var screenClass:Class = ChatSettingsScreen;
			if (ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				if (ChatManager.getCurrentChat().isOwner(Auth.uid) || ChatManager.getCurrentChat().isModerator(Auth.uid) || Config.ADMIN_UIDS.indexOf(Auth.uid) != -1)
					screenClass = ChannelInfoModeratorScreen;
				else
					screenClass = ChannelInfoScreen;
			}
			MobileGui.changeMainScreen(
				screenClass,
				{
					data:
						{
							chatId:ChatManager.getCurrentChat().uid,
							chatSettings:ChatManager.getCurrentChat().settings
						},
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:MobileGui.centerScreen.currentScreen.data
				},
				ScreenManager.DIRECTION_RIGHT_LEFT
			);
		}
		
		override public function getIconClass():Class {
			
			return Style.icon(Style.ICON_SETTINGS);
		}
	}
}