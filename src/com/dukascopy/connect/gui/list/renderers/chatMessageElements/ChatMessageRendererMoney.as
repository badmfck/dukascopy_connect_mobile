package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.MoneyIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.chat.MoneyTransferMessageVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.langs.Lang;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererMoney extends Sprite implements IMessageRenderer {
		
		private var back:Shape;
		private var title:TextField;
		private var message:TextField;
		private var textFormatTitle:TextFormat = new TextFormat();
		private var textFormatMessage:TextFormat = new TextFormat();
		private var textFormatComment:TextFormat = new TextFormat();
		private var radiusBack:Number;
		private var currentBackColor:Number = 0x525F72;
		private var icon:MoneyIcon;
		private var padding:int;
		private var comment:TextField;
		
		public function ChatMessageRendererMoney() {
			initTextFormats();
			create();
		}
		
		public function getContentHeight():Number {
			return back.height;
		}
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			return null;
		}
		
		public function getWidth():uint {
			return back.width;
		}
		
		private function initTextFormats():void {
			textFormatTitle.font = Config.defaultFontName;
			textFormatTitle.size = Config.FINGER_SIZE * .26;
			textFormatTitle.color = 0xFFFFFF;
			textFormatTitle.align = TextFormatAlign.CENTER;
			
			textFormatMessage.font = Config.defaultFontName;
			textFormatMessage.size = Config.FINGER_SIZE * .32;
			textFormatMessage.color = 0xFFFFFF;
			textFormatMessage.bold = false;
			textFormatMessage.align = TextFormatAlign.CENTER;
			
			textFormatComment.font = Config.defaultFontName;
			textFormatComment.size = Config.FINGER_SIZE * .28;
			textFormatComment.color = 0x979FAA;
			textFormatComment.bold = false;
			textFormatComment.align = TextFormatAlign.LEFT;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			
		}
		
		public function getBackColor():Number {
			return currentBackColor;
		}
		
		private function create():void {
			back = new Shape();
			addChild(back);
			
			radiusBack = Math.ceil(Config.FINGER_SIZE * .1);
			
			padding = Config.MARGIN * 1.3;
			
			message = new TextField();
				message.defaultTextFormat = textFormatMessage;
				message.text = "1:00";
				message.height = message.textHeight + 4;
				message.width = message.textWidth + 4 + padding;
				message.text = "";
				message.wordWrap = false;
				message.multiline = false;
			addChild(message);
			
			title = new TextField();
				title.defaultTextFormat = textFormatTitle;
				title.text = "1:00";
				title.height = title.textHeight + 4;
				title.width = title.textWidth + 4 + padding;
				title.text = "";
				title.wordWrap = false;
				title.multiline = false;
			addChild(title);
			
			comment = new TextField();
				comment.defaultTextFormat = textFormatComment;
				comment.wordWrap = true;
				comment.multiline = true;
			addChild(comment);
			
			icon = new MoneyIcon();
			addChild(icon);
			
			UI.scaleToFit(icon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .8);
			
			icon.x = padding;
			icon.y = padding;
			
			title.x = int(icon.x + icon.width + padding);
			title.y = padding;
			
			message.x = int(icon.x + icon.width + padding);
			message.y = int(title.y + title.height + Config.MARGIN * .01);
			
			comment.x = padding;
			comment.y = int(message.y + message.height + Config.DOUBLE_MARGIN);
		}
		
		public function getHeight(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint
		{
			if (messageData != null && 
				messageData.systemMessageVO != null && 
				messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_MONEY_TRANSFER && 
				messageData.systemMessageVO.moneyTransferVO != null)
			{
				if (messageData.systemMessageVO.moneyTransferVO.comment != null && messageData.systemMessageVO.moneyTransferVO.comment != "") {
					setTexts(messageData.systemMessageVO.moneyTransferVO, maxWidth, messageData.userUID);
					return comment.y + comment.height + Config.MARGIN;
				}
				else {
					return Config.FINGER_SIZE * 1.2;
				}
			}
			else {
			 	return Config.FINGER_SIZE * 1.2;
			}
		}
		
		private function setTexts(data:MoneyTransferMessageVO, maxWidth:int, sender:String):void 
		{
			title.text = Lang.moneyTransfer;
			
			var currency:String = data.currency;
			
			if (currency != null && Lang[currency] != null)
			{
				currency = Lang[currency];
			}
			
			message.text = data.amount.toString() + " " + currency;
			
			title.width = title.textWidth + 4;
			message.width = message.textWidth + 4;
			
			comment.width = maxWidth - Config.DOUBLE_MARGIN;
			if (data.comment != null && data.comment != "") {
				comment.text = '" ' + data.comment + ' "';
				if (data.pass == true)
					comment.text += "\n\n" + Lang.passwordProtected;
				comment.width = Math.min(comment.width, comment.textWidth + 6);
				comment.height = Math.min(comment.textHeight + 4, Config.FINGER_SIZE * 4);
			} else {
				comment.text = "";
				if (data.pass == true)
					comment.text += Lang.passwordProtected;
				else
					comment.text = "";
				comment.width = Math.min(comment.width, comment.textWidth + 6);
				comment.height = Math.min(comment.textHeight + 4, Config.FINGER_SIZE * 4);
			}
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null):void
		{
			if (messageData != null && 
				messageData.systemMessageVO != null && 
				messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_MONEY_TRANSFER && 
				messageData.systemMessageVO.moneyTransferVO != null)
			{
				setTexts(messageData.systemMessageVO.moneyTransferVO, maxWidth, messageData.userUID);
				
				var resultHeight:int;
				if (messageData.systemMessageVO.moneyTransferVO.comment != null && messageData.systemMessageVO.moneyTransferVO.comment != "") {
					resultHeight = comment.y + comment.height + Config.MARGIN;
				}
				else {
					resultHeight = Config.FINGER_SIZE * 1.2;
				}
				
				back.graphics.clear();
				back.graphics.beginFill(currentBackColor);
				maxWidth = Math.max(icon.x + icon.width + padding * 3 + Math.max(title.width, message.width),
									comment.width + Config.DOUBLE_MARGIN);
				back.graphics.drawRoundRect(0, 0, maxWidth, resultHeight, radiusBack * 2, radiusBack * 2);
				back.graphics.endFill();
				
				if (messageData.systemMessageVO.moneyTransferVO.comment != null && messageData.systemMessageVO.moneyTransferVO.comment != "") {
					back.graphics.lineStyle(Config.FINGER_SIZE * 0.01 * 2, 0x747F8E, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
					back.graphics.moveTo(0, int(message.y + message.height + Config.MARGIN));
					back.graphics.lineTo(maxWidth, int(message.y + message.height + Config.MARGIN));
				}
			}
		}
		
		public function dispose():void {		
			UI.destroy(back);
			back = null;
			
			UI.destroy(message);
			message = null;
			
			UI.destroy(title);
			title = null;
			
			UI.destroy(comment);
			comment = null;
			
			UI.destroy(icon);
			icon = null;
			
			textFormatTitle = null;
			textFormatMessage = null;
			textFormatComment = null;
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