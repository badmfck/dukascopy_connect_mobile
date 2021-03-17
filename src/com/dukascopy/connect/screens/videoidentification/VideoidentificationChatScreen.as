package com.dukascopy.connect.screens.videoidentification{
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccount;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankMessage;
	import com.dukascopy.connect.gui.list.renderers.viBot.ListVIMessage;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.chat.video.FloatVideo;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.sound.SoundManager;
	import com.dukascopy.connect.sys.speechControl.SpeechControl;
	import com.dukascopy.connect.sys.viManager.VIBot;
	import com.dukascopy.connect.sys.viManager.VIManager;
	import com.dukascopy.connect.sys.viManager.data.BotResponse;
	import com.dukascopy.connect.sys.viManager.data.RemoteMessage;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.BankMessageVO;
	import com.dukascopy.langs.Lang;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class VideoidentificationChatScreen extends BaseScreen {
		
		private var actions:Array = [];
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var bot:VIBot;
		private var floatVideo:FloatVideo;
		private var videoSize:Rectangle;
		private var viChat:String;
		
		public function VideoidentificationChatScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			topBar = new TopBarScreen();
			
			videoSize = new Rectangle(0, 0, Config.FINGER_SIZE * 2.5, Config.FINGER_SIZE * 3.5);
			
			list = new List("viChat");
			list.setStartVerticalSpace(videoSize.height + Config.DOUBLE_MARGIN);
			list.newMessageAnimationTime = 0.3;
			list.background = true;
			list.backgroundColor = 0XC4DEF1;
			list.view.y = topBar.trueHeight;
			list.setAdditionalBottomHeight(Config.APPLE_BOTTOM_OFFSET);
			
			_view.addChild(list.view);
			_view.addChild(topBar);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			topBar.setData(Lang.videoIdentification, true, actions);
			topBar.drawView(_width);
			
			list.setWidthAndHeight(_width, _height - topBar.trueHeight);
			
			if (data != null && "chatUID" in data)
			{
				viChat = data.chatUID;
			}
			
			start();
			
		//	addVideo();
		}
		
		public function addVideo():void
		{
			if (floatVideo == null)
			{
				var restricted:Rectangle = new Rectangle(0, topBar.trueHeight, _width, _height - topBar.trueHeight)
				
				floatVideo = new FloatVideo(restricted, onExpand);
				view.addChild(floatVideo);
				
				floatVideo.setStream(null, videoSize);
				
				floatVideo.x = int(_width - Config.MARGIN - videoSize.width);
				floatVideo.y = int(topBar.y + topBar.trueHeight + Config.MARGIN);
				
				if (_isActivated)
				{
					floatVideo.activate();
				}
				
				if (bot != null)
				{
					bot.videoControl = floatVideo;
				}
			}
			
			addHistoryMessages();
		}
		
		private function addHistoryMessages():void 
		{
			
		}
		
		private function onExpand():void 
		{
			
		}
		
		private function start():void 
		{
			VIManager.S_START_SUCCESS.add(onStarted);
			VIManager.S_INITED.add(attachBot);
			
			VIManager.start(viChat);
		}
		
		private function attachBot(bot:VIBot):void 
		{
			//trace("ATTACHED");
			
			this.bot = bot;
			bot.onResponse(onBotResponse);
			bot.mainScreen = this;
			if (bot.videoControl != null && floatVideo == null)
			{
				floatVideo = bot.videoControl;
				view.addChild(floatVideo);
				
				floatVideo.x = int(_width - Config.MARGIN - videoSize.width);
				floatVideo.y = int(topBar.y + topBar.trueHeight + Config.MARGIN);
			}
		}
		
		private function onStarted():void 
		{
			addVideo();
		}
		
		private function onBotResponse(response:BotResponse):void 
		{
			if (response.message.sound != null)
			{
				playSound(response.message.sound);
			}
			appendItem(response.message);
		}
		
		private function playSound(sound:String):void 
		{
			var ticket:PlaySoundTicket = new PlaySoundTicket();
			ticket.soundLink = sound;
			ticket.action = PlaySoundTicket.ACTION_PLAY;
			SoundController.playTicket(ticket);
		}
		
		private function updateLastItem():void {
			if (_isDisposed == true)
				return;
			if (list == null)
				return;
			list.updateItemByIndex(list.getStock().length - 1, false);
		}
		
		private function appendItem(obj:Object):void {
			if (_isDisposed == true)
				return;
			if (list == null)
				return;
			if (list.data == null) {
				if (obj is RemoteMessage) {
					list.setData([obj], ListVIMessage);
				}
				return;
			}
			list.appendItem(obj, ListVIMessage, null, false, true);
			list.scrollBottom(true);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			if (topBar != null)
				topBar.drawView(_width);
			if (list != null)
				list.setWidthAndHeight(_width, _height - topBar.trueHeight);
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			if (topBar != null)
				topBar.activate();
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			
			if (floatVideo != null)
			{
				floatVideo.activate();
			}
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (isDisposed == true)
			{
				return;
			}
			
			var selectedItem:ListItem;
			var lastHitzoneObject:Object;
			var lhz:String;
			
			selectedItem = list.getItemByNum(n);
			lastHitzoneObject =  selectedItem.getLastHitZoneObject();
			lhz = lastHitzoneObject != null ? lastHitzoneObject.type : null;
			if (lhz == HitZoneType.BOT_MENU) {
				var message:RemoteMessage = selectedItem.data as RemoteMessage;
				if (message.actions != null && 
					message.actions.length > lastHitzoneObject.param && 
					message.actions[lastHitzoneObject.param] != null && 
					message.actions[lastHitzoneObject.param].tapped == false &&
					message.actions[lastHitzoneObject.param].disabled == false)
				{
					if (bot != null)
					{
						bot.acceptAction(message, lastHitzoneObject.param);
						if (list != null)
						{
							list.updateItemByIndex(n, false);
						}
					}
				}
			}
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (topBar != null)
				topBar.deactivate();
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			/*if (settingsButton != null)
				settingsButton.deactivate();*/
			
			if (floatVideo != null)
			{
				floatVideo.deactivate();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (bot != null)
			{
				bot.onResponse(null);
				bot = null;
			}
			
		//	VIManager.onExit();
			
			if (floatVideo != null)
			{
			//	floatVideo.dispose();
				floatVideo = null;
			}
			
			VIManager.S_START_SUCCESS.remove(onStarted);
			VIManager.S_INITED.remove(attachBot);
			
			if (list != null)
				list.dispose();
			list = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			actions = null;
		}
		
		override public function onBack(e:Event = null):void {
			super.onBack(e);
		}
	}
}