package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.LoadingButtonIcon;
	import assets.SoundSwitchIcon1;
	import assets.SoundSwitchIcon2;
	import assets.StopButtonIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.chat.VoiceMessageVO;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.AudioPlaybackMode;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererVoice extends Sprite implements IMessageRenderer {
		
		private var back:Shape;
		private var message:TextField;
		private var iconPlay:assetsPlayButtonIcon;
		private var iconStop:StopButtonIcon;
		private var iconLoading:LoadingButtonIcon;
		private var iconLoudSpeaker:SoundSwitchIcon1;
		private var iconSpeaker:SoundSwitchIcon2;
		private var buttonSize:int = Config.FINGER_SIZE * 0.65;
		private var progressClip:Sprite;
		private var progressMask:Shape;
		
		protected var textFormatTime:TextFormat = new TextFormat();
		
		public function ChatMessageRendererVoice() {
			initTextFormats();
			create();
		}
		
		public function getContentHeight():Number {
			return height;
		}
		
		public function getWidth():uint {
			return width;
		}
		
		private function initTextFormats():void {
			textFormatTime.font = Config.defaultFontName;
			textFormatTime.size = Config.FINGER_SIZE * .3;
			textFormatTime.color = 0x92A2AE;
		}
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			return null;
		}
		
		public function updateHitzones(itemHitzones:Vector.<HitZoneData>):void {
			if (parent) {
				var playPoint:Point = new Point(iconPlay.x - Config.MARGIN, iconPlay.y - Config.MARGIN);
				var switchPoint:Point = new Point(iconLoudSpeaker.x - Config.MARGIN, iconLoudSpeaker.y - Config.MARGIN)
				
				playPoint.x = playPoint.x + x;
				playPoint.y = playPoint.y + y;
				
				switchPoint.x = switchPoint.x + x;
				switchPoint.y = switchPoint.y + y;
				
				var hitZonePlay:Object = { } ;
				var hitZoneSwitchSpeaker:Object = {  } ;
				
				var hz:HitZoneData = new HitZoneData();
				hz.type = HitZoneType.PLAY_SOUND;
				hz.x = playPoint.x;
				hz.y = playPoint.y;
				hz.width = Config.MARGIN * 2 + iconPlay.width;
				hz.height = Config.MARGIN * 2 + iconPlay.height;
				itemHitzones.push(hz);
				
				hz = new HitZoneData();
				hz.type = HitZoneType.SWITCH_SOUND_SPEAKER;
				hz.x = switchPoint.x;
				hz.y = switchPoint.y;
				hz.width = Config.MARGIN * 2 + iconLoudSpeaker.width;
				hz.height = Config.MARGIN * 2 + iconLoudSpeaker.width;
				itemHitzones.push(hz);
			}
		}
		
		public function getBackColor():Number {
			return 0x3B4452;
		}
		
		private function create():void {
			back = new Shape();
			addChild(back);
			
			progressMask = new Shape();
			addChild(progressMask);
			
			progressClip = new Sprite();
			progressClip.graphics.beginFill(0x505C70, 1);
			progressClip.graphics.drawRect(0, 0, 10, buttonSize + Config.MARGIN * 2);
			progressClip.graphics.endFill();
			addChild(progressClip);
			
			progressClip.mask = progressMask;
			
			message = new TextField();
				message.defaultTextFormat = textFormatTime;
				message.text = "1:00";
				message.height = message.textHeight + 4;
				message.width = message.textWidth + 4 + Config.MARGIN;
				message.text = "";
				message.wordWrap = false;
				message.multiline = false;
			addChild(message);
			
			iconPlay = new assetsPlayButtonIcon();
			UI.scaleToFit(iconPlay, buttonSize, buttonSize);
			addChild(iconPlay);
			
			iconLoading = new LoadingButtonIcon();
			UI.scaleToFit(iconLoading, buttonSize, buttonSize);
			addChild(iconLoading);
			
			iconStop = new StopButtonIcon();
			UI.scaleToFit(iconStop, buttonSize, buttonSize);
			addChild(iconStop);
			
			iconLoudSpeaker = new SoundSwitchIcon1();
			UI.scaleToFit(iconLoudSpeaker, buttonSize, buttonSize);
			addChild(iconLoudSpeaker);
			
			iconSpeaker = new SoundSwitchIcon2();
			UI.scaleToFit(iconSpeaker, buttonSize, buttonSize);
			addChild(iconSpeaker);
			
			iconPlay.visible = false;
			iconStop.visible = false;
			iconLoading.visible = false;
			
			var radiusBack:int = Math.ceil(Config.FINGER_SIZE * .25);
			back.graphics.beginFill(0x3B4452, 1);
			back.graphics.drawRoundRect(0, 0, Config.FINGER_SIZE, Config.FINGER_SIZE, radiusBack * 2, radiusBack * 2);
			back.graphics.endFill();
			back.scale9Grid = new Rectangle(radiusBack, radiusBack, radiusBack, radiusBack);
			
			
			iconPlay.x = Config.MARGIN;
			iconPlay.y = Config.MARGIN;
			
			iconStop.x = Config.MARGIN;
			iconStop.y = Config.MARGIN;
			
			iconLoading.x = Config.MARGIN;
			iconLoading.y = Config.MARGIN;
			
			message.x = int(iconPlay.x + iconPlay.width + Config.MARGIN * 1.5);
			message.y = int(iconPlay.y + iconPlay.height * .5 - message.height * .5);
			
			back.width = message.width + Config.MARGIN * 5.5 + iconPlay.width + iconSpeaker.width;
			back.height = Math.max(message.height, iconPlay.height) + Config.MARGIN * 2;
			
			iconSpeaker.x = iconLoudSpeaker.x = int(back.width - iconSpeaker.width - Config.MARGIN);
			iconSpeaker.y = iconLoudSpeaker.y = Config.MARGIN;
			
			progressMask.graphics.beginFill(0x3B4452, 1);
			progressMask.graphics.drawRoundRect(
				0,
				0, 
				message.width + Config.MARGIN * 5.5 + iconPlay.width + iconSpeaker.width, 
				Math.max(message.height, iconPlay.height) + Config.MARGIN * 2, 
				radiusBack * 2, radiusBack * 2
			);
			progressMask.graphics.endFill();
		}
		
		public function getHeight(itemData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint {
			return int(buttonSize + Config.MARGIN * 2);
		}
		
		private function formatTime(seconds:int):String {
			if (seconds < 0)
				seconds = 0;
			
			var result:String = (seconds % 60).toString();
			if (result.length == 1)
				result = "0" + result;
			result = ":" + result;
			result = Math.floor(seconds / 60) + result;
			
			return result;
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			var data:VoiceMessageVO = messageData.systemMessageVO.voiceVO;
			
			iconPlay.visible = false;
			iconStop.visible = false;
			
			if (data.isPlaying == true)
				message.text = formatTime(data.currentTime);
			else if (data.currentTime != 0)
				message.text = formatTime(data.currentTime);
			else
				message.text = formatTime(data.duration);
			
			progressClip.width = Math.min(back.width, back.width * (data.duration - data.currentTime) / data.duration);
			
			if (data.currentTime == data.duration || (data.currentTime == 0))
				progressClip.visible = false;
			else
				progressClip.visible = true;
			
			if (data.speakerMode == AudioPlaybackMode.VOICE) {
				iconLoudSpeaker.visible = false;
				iconSpeaker.visible = true;
			} else if (data.speakerMode == AudioPlaybackMode.MEDIA) {
				iconLoudSpeaker.visible = true;
				iconSpeaker.visible = false;
			}
			
			iconPlay.visible = true;
			
			if (data.isLoading == true) {
				iconPlay.visible = false;
				iconStop.visible = false;
				iconLoading.visible = true;	
			} else {
				iconLoading.visible = false;
				if (data.isPlaying == true) {
					iconPlay.visible = false;
					iconStop.visible = true;
				} else {
					iconPlay.visible = true;
					iconStop.visible = false;
				}
			}
		}
		
		public function dispose():void {
			UI.destroy(back);
			back = null;
			UI.destroy(message);
			message = null;
			UI.destroy(iconPlay);
			iconPlay = null;
			UI.destroy(iconStop);
			iconStop = null;
			UI.destroy(iconLoading);
			iconLoading = null;
			UI.destroy(progressMask);
			progressMask = null;
			UI.destroy(progressClip);
			progressClip = null;
			textFormatTime = null;
		}
		
		
		public function get animatedZone():AnimatedZoneVO {
			return null;
		}
		
		public function get isReadyToDisplay():Boolean {
			return true;
		}
		
		public function getSmallGap(listItem:ListItem):int {
			return ChatMessageRendererBase.smallGap;
		}
	}
}