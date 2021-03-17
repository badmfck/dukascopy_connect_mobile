package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.Quotes1;
	import assets.Quotes2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.sys.GlobalDate;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererForwardView extends Sprite {
		
		private const textMargin:int = Math.ceil(Config.FINGER_SIZE * .2);
		
		private var leftQuote:Sprite;
		private var rightQuote:Sprite;
		private var forwardingCommentTF:TextField;
		private var ftf:TextFormat;
		private var quotesColorTransform:ColorTransform;
		
		private var trueHeight:int;
		private var trueWidth:int;
		private var lQuoteOffset:int;
		
		public function ChatMessageRendererForwardView() {
			forwardingCommentTF = new TextField();
				ftf = new TextFormat();
				ftf.font = Config.defaultFontName;
				ftf.size = Config.FINGER_SIZE * .20;
				ftf.color = Style.color(Style.COLOR_TEXT);
			forwardingCommentTF.defaultTextFormat = ftf;
			forwardingCommentTF.multiline = false;
			forwardingCommentTF.wordWrap = false;
			forwardingCommentTF.height = 300;
			forwardingCommentTF.text = "Q";
			forwardingCommentTF.height = forwardingCommentTF.textHeight + 4;
			addChild(forwardingCommentTF);
			
			quotesColorTransform = new ColorTransform();
			quotesColorTransform.color = Style.color(Style.COLOR_TEXT);
			var sizeCoef:Number;
			var quotesSize:int = Config.FINGER_SIZE * .15;
			
			leftQuote = new Quotes2();
			leftQuote.transform.colorTransform = quotesColorTransform;
			sizeCoef = leftQuote.width / leftQuote.height;
			leftQuote.width = quotesSize * sizeCoef;
			leftQuote.height = quotesSize;
			addChild(leftQuote);
			
			rightQuote = new Quotes1();
			rightQuote.transform.colorTransform = quotesColorTransform;
			sizeCoef = rightQuote.width / rightQuote.height;
			rightQuote.width = quotesSize * sizeCoef;
			rightQuote.height = quotesSize;
			addChild(rightQuote);
		}
		
		public function coverDisplayObject(displayObject:DisplayObject, /*commentText:String*/ message:ChatMessageVO, maxWidth:int, isAlignQuotesToRight:Boolean = false):void {
			var usingWidth:int = displayObject.width;
			if (displayObject is MegaText)
				usingWidth = (displayObject as MegaText).tfTextWidth;
			else
				usingWidth = displayObject.width;
			
			//TODO - сделать так чтобы текст показывался полностью на нескольких строках или обрезался и ставил "..."
			var commentText:String = getForwardingCommentText(message);
			forwardingCommentTF.width = maxWidth;
			forwardingCommentTF.text = commentText;
			forwardingCommentTF.width = forwardingCommentTF.textWidth + 4;
			forwardingCommentTF.y = displayObject.height + textMargin;
			
			if (isAlignQuotesToRight) {
				if (rightQuote.width + leftQuote.width + usingWidth + textMargin * 2 < forwardingCommentTF.textWidth + 4) {
					rightQuote.x = forwardingCommentTF.textWidth + 4 - rightQuote.width;
					leftQuote.x = rightQuote.x - usingWidth - textMargin * 2 - leftQuote.width; 
					forwardingCommentTF.x = rightQuote.x + rightQuote.width - forwardingCommentTF.textWidth - 2;
				} else {
					leftQuote.x = 0;
					rightQuote.x = leftQuote.x + leftQuote.width + usingWidth + textMargin * 2;
					forwardingCommentTF.x = leftQuote.x;
				}
			} else {
				leftQuote.x = 0;
				rightQuote.x = leftQuote.x + leftQuote.width + usingWidth + textMargin * 2;
				if (rightQuote.width + leftQuote.width + usingWidth + textMargin * 2 < forwardingCommentTF.textWidth + 4)
					forwardingCommentTF.x = leftQuote.x;
				else
					forwardingCommentTF.x = rightQuote.x + rightQuote.width - forwardingCommentTF.textWidth - 2;
			}
			
			trueHeight = forwardingCommentTF.y + forwardingCommentTF.textHeight;
			trueWidth = Math.max(rightQuote.x + rightQuote.width, forwardingCommentTF.textWidth);
			lQuoteOffset = leftQuoteWidth + leftQuote.x;
		}
		
		public function setQuotesColor(color:int):void {
			if (updateIsColorTransformChanged(quotesColorTransform, color) == true) {
				rightQuote.transform.colorTransform = quotesColorTransform;
				leftQuote.transform.colorTransform = quotesColorTransform;
			}
		}
		
		public function setTextColor(color:int):void {
			ftf.color = color;
			forwardingCommentTF.defaultTextFormat = ftf;
		}
		
		protected function updateIsColorTransformChanged(colorTransform:ColorTransform, newColor:int):Boolean {
			if (colorTransform.color == newColor)
				return false;
			colorTransform.color = newColor;
			return true;
		}
		
		public function dispose():void {
			UI.destroy(leftQuote);
			leftQuote = null;
			UI.destroy(rightQuote);
			rightQuote = null;
			UI.destroy(forwardingCommentTF);
			forwardingCommentTF = null;
			ftf = null;
			quotesColorTransform = null;
		}
		
		private function getForwardingCommentText(messageVO:ChatMessageVO):String
		{
			var res:String;
			switch(messageVO.typeEnum)
			{
				case ChatMessageType.INVOICE:
					var data:ChatMessageInvoiceData = messageVO.systemMessageVO.invoiceVO;
					if (data.forwardedFromUserID == null)
					{
						break;
					}
					res = data.forwardedFromUserName+ " " + getForwardingMessageAge(Number(data.forwardedMessageDate)/1000);
					break;
				case ChatMessageType.FORWARDED:
					var messageToWorkWith:ChatMessageVO = messageVO.systemMessageVO.forwardVO;
					var name:String;
					if (messageToWorkWith.userUID == Auth.uid)
					{
						name = Auth.username;
					}
					else
					{
					//	userToForwardFrom = UserProfileManager.gzetUserData(messageToWorkWith, false);
						if (messageToWorkWith.name != null)
						{
							name = messageToWorkWith.name;
						}
						else
						{
							name = "";
						}
					}
					res = name + " " + getForwardingMessageAge(messageToWorkWith.created).toString();
					break;
				default:
					break;
			}
			return res;
		}
		
		protected function getForwardingMessageAge(createdTime:Number):String {
			var date:Date = GlobalDate.date;
			date.setTime(createdTime * 1000);
			return DateUtils.getComfortDateRepresentationWithMinutes(date);
		}
		
		
		override public function get height():Number { return trueHeight; }
		override public function get width():Number { return trueWidth; }
		public function get leftQuoteOffset():int { return lQuoteOffset }
		public function get leftQuoteWidth():int { return leftQuote.width; }
		public function get rightQuoteWidth():int { return rightQuote.width; }
		public function get textCommentHeight():int { return forwardingCommentTF.textHeight; } //TODO нужно + 4 или нет?
	}
}