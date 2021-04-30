package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.ChatMessageCryptedIcon;
	import assets.ChatMessageUncryptedIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererText extends ChatMessageRendererBase implements IMessageRenderer {
		
		static private var myLockColor:uint = 0xFFFFFF;
		static private var otherLockColor:uint = 0x000000;
		
		private var colorBG:uint;
		
		protected var textBox:Sprite;
		
		protected var fontSize:int;
		protected var megaText:MegaText;
		
		private var _crypted:Sprite;
		private var _uncrypted:Sprite;
		
		private const calculatedTextWidthCachedAdress:String = "calculatedTextMessageTextWidth";
		
		private var lockColorTransform:ColorTransform;
		
		private function get crypted():Sprite {
			if (_crypted == null) {
				_crypted = new ChatMessageCryptedIcon();
				UI.scaleToFit(_crypted, Config.FINGER_SIZE*.4, Config.FINGER_SIZE*.4);
			}
			return _crypted;
		}
		private function get uncrypted():Sprite {
			if (_uncrypted == null) {
				_uncrypted = new ChatMessageUncryptedIcon();
				UI.scaleToFit(_uncrypted, Config.FINGER_SIZE*.4, Config.FINGER_SIZE*.4);
			}
			return _uncrypted;
		}
		
		private function hideCryptedIcon():void {
			if (_crypted == null)
				return;
			if (crypted.parent != null)
				crypted.parent.removeChild(crypted);
		}
		
		private function hideUncryptedIcon():void {
			if (_uncrypted == null)
				return;
			if (uncrypted.parent != null)
				uncrypted.parent.removeChild(uncrypted);
		}
		
		public function ChatMessageRendererText() {
			super();
			
			fontSize = Math.ceil(Config.FINGER_SIZE * .30);
			if (fontSize < minFontSize)
				fontSize = minFontSize;
			
			textBox = new Sprite();
			initBg(COLOR_BG_WHITE)
			
			megaText = new MegaText();
			megaText.y = vTextMargin;
			megaText.x = hTextMargin;
			textBox.addChild(megaText);
			
			addChild(textBox);
			lockColorTransform = new ColorTransform();
		}
		
		override public function dispose():void {
			super.dispose();
			megaText.dispose();
			UI.destroy(textBox);
			textBox = null;
			UI.destroy(_crypted);
			_crypted = null;
			UI.destroy(_uncrypted);
			_uncrypted = null;
			lockColorTransform = null;
		}
		
		public function getContentHeight():Number {
			return height;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			itemHitzones.push( { type:HitZoneType.BALLOON, x:x , y:y, width: textBox.width, height: textBox.height } );
		}
		
		public function getBackColor():Number {
			return ct.color;
		}
		
		public function getWidth():uint {
			return width;
		}
		
		public function getHeight(messageVO:ChatMessageVO, targetWidth:int,listItem:ListItem):uint {
			if (messageVO == null)
				return 0;
			
			if (messageVO.systemMessageVO != null && messageVO.systemMessageVO.type == "credentials")
			{
				return 0;
			}
			
			var isLastMessageForwarded:Boolean = messageVO.typeEnum == ChatMessageType.FORWARDED;
			var cryptedIconOffset:int = 0;
			
			var maxTextWidth:int =  targetWidth;
			if (messageVO.paranoic == true) {
				if (messageVO.crypted == true) {
					cryptedIconOffset = hTextMargin * 2 + crypted.width;
					maxTextWidth -= (hTextMargin + crypted.width);
				} else {
					cryptedIconOffset = hTextMargin * 2 + uncrypted.width;
					maxTextWidth -= (hTextMargin + uncrypted.width);
				}
			}
			if (isLastMessageForwarded) {
				messageVO = messageVO.systemMessageVO.forwardVO;
				maxTextWidth -= forwardView.leftQuoteWidth + forwardView.rightQuoteWidth + hTextMargin * 2;
			}	
			listItem.getCustomData()[calculatedTextWidthCachedAdress] = maxTextWidth;
			var megaTextHeight:int = getMegaTextHeightByChatMessage(messageVO, maxTextWidth);
			
			var res:uint = megaTextHeight + vTextMargin * 2;
			if (isLastMessageForwarded)
				res += forwardView.textCommentHeight + vTextMargin*2;
			return res;
		}
		
		private function readOrCalculateMaxTextWidth(listItem:ListItem, targetWidth:int):int {
			var res:int;
			var customListItemData:Object = listItem.getCustomData();
			if (customListItemData[calculatedTextWidthCachedAdress] is int) {
				res = customListItemData[calculatedTextWidthCachedAdress];
				if (res > 0 && res <= targetWidth)
					return res;
			}
			getHeight(listItem.data as ChatMessageVO, targetWidth,listItem);
			if (customListItemData[calculatedTextWidthCachedAdress] is int) {
				res = customListItemData[calculatedTextWidthCachedAdress];
				if (res > 0 && res <= targetWidth)
					return res;
			}
			return 100;//страховка, сюда выполнение попадать не должно
		}
		
		protected function getMegaTextHeightByChatMessage(messageVO:ChatMessageVO/*, isForwarded:Boolean*/,  targetWidth:int):int {
			var txt:String = messageVO.text;
			if (txt == null)
				txt = Lang.noText;
			if (messageVO.crypted)
				txt = Lang.cryptedMessage;
			if (txt == "")
				txt = Lang.deletedMessage;
			txt = txt.replace(/\t/g, " ");
			var textSize:int = fontSize;
			if (messageVO.renderInfo != null && messageVO.renderInfo.renderInforenderBigFont == true)
			{
				textSize = textSize * 1.4;
			}
			var textColor:Number = colorText;
			if (messageVO.renderInfo != null && !isNaN(messageVO.renderInfo.color))
			{
				textColor = messageVO.renderInfo.color;
			}
			var res:int = megaText.setText(targetWidth, txt, textColor, textSize, "#" + getBackColor().toString(16), 1.5, messageVO.wasSmile);
			messageVO.wasSmile = megaText.getWasSmile() ? 2 : 1;
			return res;
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			var result:HitZoneData = new HitZoneData();
			result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
			result.x = x;
			result.y = y;
			result.width = getWidth();
			result.height = getContentHeight();
			result.radius = textBoxRadius;
			return result;
		}
		
		public function draw(messageVO:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			updateBubbleColors(messageVO);
			var isMine:Boolean = Auth.uid === messageVO.userUID;
			var messageToWorkWith:ChatMessageVO = messageVO;
			var isLastMessageForwarded:Boolean = messageVO.typeEnum == ChatMessageType.FORWARDED;
			if (isLastMessageForwarded)
				messageToWorkWith = messageToWorkWith.systemMessageVO.forwardVO;
			
			var cryptedIconOffset:int = 0;
			if (messageVO.paranoic) {
				if (messageVO.crypted) {
					cryptedIconOffset = hTextMargin + crypted.width;
					hideUncryptedIcon();
				} else {
					cryptedIconOffset = hTextMargin + uncrypted.width;
					hideCryptedIcon();
				}
				megaText.x = cryptedIconOffset;
			} else {
				hideUncryptedIcon();
				hideCryptedIcon();
				megaText.x = hTextMargin;
			}
			var maxTextWidth:int = readOrCalculateMaxTextWidth(listItem, maxWidth);
			var megaTextHeight:int = getMegaTextHeightByChatMessage(messageToWorkWith, maxTextWidth);
			
			var bgH:int = megaTextHeight + vTextMargin * 2;
			var bgW:int;
			
			textBox.graphics.clear();
			
			if (isLastMessageForwarded == true) {
				if (isMine == true) {				
					forwardView.setQuotesColor(Style.color(Style.MESSAGE_COLOR_SELF));
					forwardView.setTextColor(Style.color(Style.MESSAGE_COLOR_SELF));
				} else {
					forwardView.setTextColor(Style.color(Style.MESSAGE_COLOR));
					forwardView.setQuotesColor(Style.color(Style.MESSAGE_COLOR));
				}
				forwardView.coverDisplayObject(megaText, messageVO, maxWidth,!isMine);
				addChild(forwardView);
				var offset:int = cryptedIconOffset;
				if (offset == 0)
					offset = hTextMargin;
				
				bgW = forwardView.width + hTextMargin * 2;
				forwardView.x = hTextMargin;
				forwardView.y = vTextMargin;
				bgH = forwardView.height + vTextMargin * 2;
				megaText.y = forwardView.y;
				megaText.x = forwardView.x + forwardView.leftQuoteOffset + hTextMargin;
			} else {
				megaText.x = hTextMargin;
				megaText.y = vTextMargin;
				bgW = Math.min(megaText.tfTextWidth, megaText.getMaxWidth()) + hTextMargin * 2;
				removeForwardView();
			}
			
			if (messageVO.paranoic) {
				bgW += cryptedIconOffset+hTextMargin;
				if (isContainsForwardView)
					forwardView.x += cryptedIconOffset;
				megaText.x += cryptedIconOffset;
				
				if (messageVO.crypted) {
					crypted.x = megaText.x - hTextMargin - crypted.width;
					crypted.y = megaText.y + megaText.height / 2 - crypted.height / 2;
					setColorToDisplayObjectIfRequired(crypted,lockColorTransform,isMine ? myLockColor : otherLockColor);
					addChild(crypted);
				} else {
					if (isLastMessageForwarded)
						uncrypted.x = forwardView.x - hTextMargin - uncrypted.width;
					else
						uncrypted.x = megaText.x - hTextMargin - uncrypted.width;
					uncrypted.y = megaText.y + megaText.height / 2 - uncrypted.height / 2;					
					setColorToDisplayObjectIfRequired(uncrypted,lockColorTransform,isMine ? myLockColor : otherLockColor);
					addChild(uncrypted);
				}
			} else {
				if (uncrypted.parent!=null)
					uncrypted.parent.removeChild(uncrypted);
				if (crypted.parent!=null)
					crypted.parent.removeChild(crypted);
			}
			
			if (minWidth != -1)
			{
				bgW = Math.max(minWidth, bgW);
			}
			
			boxBg.width = bgW;
			boxBg.height = bgH;
			
			if (messageToWorkWith.wasSmile == 2)
				megaText.render();
		}
		
		override public function get width():Number {
			return boxBg.width;
		}
		
		public function get animatedZone():AnimatedZoneVO {
			return null;
		}
		
		public function get isReadyToDisplay():Boolean {
			return true;
		}
	}
}