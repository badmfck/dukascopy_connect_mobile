package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.stickerManager.StickerManager;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererSticker extends ChatMessageRendererBase implements IMessageRenderer {
		
		private var sticker:Sprite;
		
		public function ChatMessageRendererSticker() {
			
		}
		
		override public function dispose():void {
			super.dispose();
			UI.destroy(sticker);
			sticker = null
		}
		
		public function getContentHeight():Number {
			return height;
		}
		
		public function getWidth():uint {
			return width;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			
		}
		
		public function getBackColor():Number {
			return 0xFFFFFF;
		}
		
		public function getHeight(itemData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint {
			var stickerHeight:int =  Math.min(maxWidth, getMaxStickerSize());
			return stickerHeight + vTextMargin; 
		}
		
		private function getMaxStickerSize():int {
			return Config.FINGER_SIZE * 3;
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null):void {
			if (sticker != null) {
				if (sticker.parent != null)
					sticker.parent.removeChild(sticker);
				sticker = null;
			}
			var messageToWorkWith:ChatMessageVO = messageData;
			if (messageData.typeEnum == ChatMessageType.FORWARDED)
				messageToWorkWith = messageToWorkWith.systemMessageVO.forwardVO;
			else if (isContainsForwardView)
				removeChild(forwardView);
			
			var stickerWidth:int = Math.min(getMaxStickerSize(), maxWidth);
			var stickerHeight:int = stickerWidth - getForwardingCommentHeight(messageData);
			var stickerMessageVO:ChatSystemMsgVO = messageToWorkWith.systemMessageVO;
			if (stickerMessageVO != null && stickerMessageVO.stikerId != -1 && stickerMessageVO.stikerVersion != -1)
				sticker = StickerManager.getLocalStickerVector(stickerMessageVO.stikerId, stickerMessageVO.stikerVersion, stickerWidth, stickerHeight);
			if (sticker != null) {
				addChild(sticker);
				sticker.y = 0;
				if (messageData.typeEnum == ChatMessageType.FORWARDED) {
					var isMine:Boolean;
					forwardView.coverDisplayObject(sticker, messageData, maxWidth, !(messageToWorkWith.userUID == Auth.uid));
					sticker.x = forwardView.x + forwardView.leftQuoteWidth + hTextMargin;
					addChild(forwardView);
				} else {
					sticker.x = 0;
					sticker.y = 0;
				}
			}
		}
		
		private function removeChildSafe(child:DisplayObject):void {
			if (child.parent != null)
				child.parent.removeChild(child);
		} 
		
		private function getForwardingCommentHeight(messageVO:ChatMessageVO):int {
			if (messageVO.typeEnum == ChatMessageType.FORWARDED)
				return forwardView.textCommentHeight;
			return 0;
		}
		
		public function get animatedZone():AnimatedZoneVO {
			return null;
		}
		
		public function get isReadyToDisplay():Boolean {
			return true;
		}
	}
}