package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.MessageStatusReadIcon;
	import assets.MessageStatusSentIcon;
	import assets.MessageStatusSindionIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class MessageStatusClip extends Sprite {
		
		private var read:DisplayObject;
		private var sent:MessageStatusSentIcon;
		private var sending:MessageStatusSindionIcon;
		private var icon:DisplayObject;
		
		public function MessageStatusClip() {
			read = new MessageStatusReadIcon();
			sent = new MessageStatusSentIcon();
			sending = new MessageStatusSindionIcon();
			
			var size:int = Config.FINGER_SIZE * .25;
			
			UI.scaleToFit(read, size, size);
			UI.scaleToFit(sent, size, size);
			UI.scaleToFit(sending, size, size);
			
			addChild(read);
			addChild(sent);
			addChild(sending);
			
			read.visible = false;
			sent.visible = false;
			sending.visible = false;
		}
		
		public function setStatus(status:String):void {
			var newIcon:DisplayObject;
			switch(status) {
				case ChatMessageVO.STATUS_SENDING: {
					newIcon = sending;
					break;
				}
				case ChatMessageVO.STATUS_SENT: {
					newIcon = sent;
					break;
				}
				case ChatMessageVO.STATUS_READ: {
					newIcon = read;
					break;
				}
				case null: {
					newIcon = null;
					break;
				}
			}
			if (icon != newIcon) {
				if (icon != null)
					icon.visible = false;
				icon = newIcon;
				if (icon != null)
					icon.visible = true;
			}
		}
	}
}