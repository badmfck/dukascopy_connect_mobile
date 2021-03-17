package com.dukascopy.connect.gui.videoStreaming 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.videoStreaming.VideoStreaming;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StreamIndicator extends Sprite
	{
		private var background:Sprite;
		private var avatar:CircleAvatar;
		private var text:flash.display.Bitmap;
		private var itemWidth:int;
		private var avatarSize:int;
		
		public function StreamIndicator() 
		{
			avatarSize = Config.FINGER_SIZE * .6;
			
			background = new Sprite();
			addChild(background);
			
			avatar = new CircleAvatar();
			addChild(avatar);
			
			avatar.setData(null, avatarSize, false, false, Auth.avatarLarge);
			
			text = new Bitmap();
			addChild(text);
			
			text.bitmapData = TextUtils.createTextFieldData(
											Lang.youStreaming, Config.FINGER_SIZE * 2.3, 10, true, 
											TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
											Config.FINGER_SIZE * .24, true, 0xFFFFFF, 0x4A5566);
			
			itemWidth = Math.max(text.width, avatarSize * 2) + Config.FINGER_SIZE * .6;
			
			avatar.x = int(itemWidth * .5 - avatarSize);
			avatar.y = int(Config.FINGER_SIZE * .19);
			text.y = int(avatar.y + avatarSize * 2 + Config.FINGER_SIZE * .39);
			text.x = int(itemWidth * .5 - text.width * .5);
			
			var pos:int = avatarSize * 2 + Config.FINGER_SIZE * .4;
			background.graphics.beginFill(0x3B4452);
			background.graphics.drawRect(0, 0, itemWidth, pos);
			background.graphics.endFill();
			
			background.graphics.beginFill(0x4A5566);
			background.graphics.drawRect(0, pos, itemWidth, text.height + Config.FINGER_SIZE * .3);
			background.graphics.endFill();
			
			PointerManager.addTap(this, openStream);
		}
		
		private function openStream(e:Event = null):void 
		{
			PointerManager.removeTap(this, openStream);
			
			var chatScreenData:ChatScreenData = new ChatScreenData();
				chatScreenData.type = ChatInitType.CHAT;
				chatScreenData.chatUID = VideoStreaming.currentChat;
				chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
				chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData, 0, 0);
		}
		
		public function hide():void
		{
			TweenMax.killTweensOf(this);
			TweenMax.to(this, 0.2, {x:MobileGui.stage.fullScreenWidth, onComplete:dispose});
		}
		
		public function dispose():void
		{
			MobileGui.stage.removeChild(this);
			
			PointerManager.removeTap(this, openStream);
			
			avatar.dispose();
			avatar = null;
			
			UI.destroy(text);
			text = null;
			
			UI.destroy(background);
			background = null;
		}
		
		public function show():void 
		{
			x = int(MobileGui.stage.fullScreenWidth);
			TweenMax.to(this, 0.2, {x:int(MobileGui.stage.fullScreenWidth - width)});
			y = Config.APPLE_TOP_OFFSET + Config.FINGER_SIZE * 1.4;
		}
	}
}