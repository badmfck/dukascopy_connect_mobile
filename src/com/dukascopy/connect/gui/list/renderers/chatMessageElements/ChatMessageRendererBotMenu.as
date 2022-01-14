package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.chat.BotLinks;
	import com.dukascopy.connect.gui.chat.BotMenu;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ChatMessageRendererBotMenu extends ChatMessageRendererBase implements IMessageRenderer {
		
		private const calculatedTextWidthCachedAdress:String = "calculatedTextMessageTextWidth";
		private const boarderSize:int = Config.FINGER_SIZE * .1;
		
		protected var fontSize:int;
		protected var fontSizeTitle:int = Config.FINGER_SIZE * .35;
		protected var textBox:Sprite;
		protected var megaText:MegaText;
		protected var megaTextTitle:MegaText;
		
		private var imagePlaceHolder:Sprite;
		private var imageRenderer:InChatMessageRendererImageDisplay;
		private var botMenu:BotMenu;
		
		private var customBirdPosition:Number = 0;
		
		private var currentData:ChatSystemMsgVO;
		
		private var _birdOverMenu:Boolean = false;
		private var _rect:Rectangle;
		private var colorTitle:uint = 0;
		private var links:BotLinks;
		
		public function ChatMessageRendererBotMenu() {
			super();
			fontSize = Math.ceil(Config.FINGER_SIZE * .28);
			if (fontSize < minFontSize)
				fontSize = minFontSize;
			initBg(COLOR_BG_WHITE);
			textBox = new Sprite();
				megaText = new MegaText();
				megaText.y = vTextMargin;
				megaText.x = hTextMargin;
			textBox.addChild(megaText);
			
				megaTextTitle = new MegaText();
				megaTextTitle.y = vTextMargin;
				megaTextTitle.x = hTextMargin;
			addChild(megaTextTitle);
			
			addChild(textBox);
			imagePlaceHolder = new Sprite();
			addChild(imagePlaceHolder);
			imageRenderer = new InChatMessageRendererImageDisplay(textBoxRadius);
			addChild(imageRenderer);
		}
		
		override public function dispose():void {
			currentData = null;
			_rect = null;
			destroyBotMenu();
			destroyBotLinks();
			megaText.dispose();
			megaText = null;
			megaTextTitle.dispose();
			megaTextTitle = null;
			UI.destroy(textBox);
			textBox = null;
			if (imageRenderer)
				imageRenderer.dispose();
			imageRenderer = null;
			UI.destroy(imagePlaceHolder);
			imagePlaceHolder = null;
			super.dispose();
		}
		
		public function getHeight(messageVO:ChatMessageVO, targetWidth:int, listItem:ListItem):uint {
			if (messageVO == null)
				return 0;
			if (messageVO.systemMessageVO != null && messageVO.systemMessageVO.rateBotWebView != null && messageVO.text == "")
				return 0;
			
			var calculatedHeight:uint = 0;
			if (hasText(messageVO) == true)
				calculatedHeight = getMegaTextHeightByChatMessage(messageVO, targetWidth) + vTextMargin * 2;
			if (hasImage(messageVO) == true) {
				if (calculatedHeight != 0)
					calculatedHeight += vTextMargin;
				calculatedHeight += targetWidth;
			}
			if (hasLinks(messageVO) == true) {
				if (calculatedHeight != 0)
					calculatedHeight += vTextMargin;
				generateLinks(messageVO, targetWidth);
				calculatedHeight += links.getTotalHeight();
				if (hasMenu(messageVO) == false)
				{
					calculatedHeight += vTextMargin * 2;
				}
			}
			if (hasMenu(messageVO) == true) {
				if (calculatedHeight != 0)
					calculatedHeight += vTextMargin;
				generateMenu(messageVO, targetWidth);
				calculatedHeight += botMenu.getTotalHeight();
			}
			return calculatedHeight;
		}
		
		public function draw(messageVO:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			_birdOverMenu = false;
			currentData = messageVO.systemMessageVO;
			var isMine:Boolean = Auth.uid == messageVO.userUID;
			var noText:Boolean  = !hasText(messageVO);
			var noTitle:Boolean  = !hasTitle(messageVO);
			var hasImageInMsg:Boolean = hasImage(messageVO);
			var hasMenuInMsg:Boolean = hasMenu(messageVO);
			var hasLinksInMsg:Boolean = hasLinks(messageVO);
			var posY:int = vTextMargin;
			updateBubbleColors(messageVO);
			boxBg.width = 10;
			if (noTitle == false) {
				megaTextTitle.visible = true;
				megaTextTitle.x = hTextMargin;
				megaTextTitle.y = vTextMargin;
				customBirdPosition = getMegaTitleHeightByChatMessage(messageVO, maxWidth) + vTextMargin;
				boxBg.visible = true;
				boxBg.width = megaTextTitle.tfTextWidth + hTextMargin * 2;
				boxBg.height = customBirdPosition;
				posY = customBirdPosition;
			} else {
				megaTextTitle.visible = false;
				boxBg.visible = false;
			}
			if (noText == false) {
				megaText.visible = true;
				megaText.x = hTextMargin;
				megaText.y = posY;
				customBirdPosition = getMegaTextHeightByChatMessage(messageVO, maxWidth) + vTextMargin * 2;
				boxBg.visible = true;
				boxBg.width = Math.max(megaText.tfTextWidth + hTextMargin * 2, boxBg.width);
				boxBg.height = customBirdPosition;
				posY = customBirdPosition + vTextMargin;
			} else {
				megaText.visible = false;
				boxBg.visible = false;
			}
			if (hasImageInMsg == true) {
				imagePlaceHolder.y = posY;
				if (noText == true)
					customBirdPosition = maxWidth - Config.FINGER_SIZE * .1;
				imagePlaceHolder.graphics.clear();
				imagePlaceHolder.graphics.beginFill(0xffffff, .6);
				imagePlaceHolder.graphics.drawRoundRect(0, 0, maxWidth, maxWidth, textBoxRadius, textBoxRadius);
				imagePlaceHolder.graphics.endFill();
				if (imageRenderer) {					
					imageRenderer.clearImage();
					imageRenderer.x = boarderSize;
					imageRenderer.y = imagePlaceHolder.y + boarderSize;					
					imageRenderer.setPhotoIcon();
					imageRenderer.setSize(maxWidth - boarderSize * 2, maxWidth - boarderSize * 2);					
					var loadedImage:ImageBitmapData = listItem.getLoadedImage('imageThumbURLWithKey');
					if (loadedImage != null)
						imageRenderer.drawImage(loadedImage, maxWidth - boarderSize * 2, maxWidth - boarderSize * 2);	
				}
				posY += maxWidth + vTextMargin;
			} else {			
				if (imageRenderer != null) {
					imageRenderer.hideIcon();
					imageRenderer.clearImage();
				}
				imagePlaceHolder.graphics.clear();
			}
			
			if (hasLinksInMsg == true) {
				generateLinks(messageVO, maxWidth - hTextMargin * 2);
				
				if (posY != 0 && posY != vTextMargin)
				{
					posY -= vTextMargin;
				}
				links.y = posY;
				links.x = hTextMargin;
				
				customBirdPosition = links.y + links.getTotalHeight() + vTextMargin;
				boxBg.visible = true;
				boxBg.width = Math.max(links.width + hTextMargin * 2, boxBg.width);
				boxBg.height = customBirdPosition;
				
				if (noText == true && hasImageInMsg == false && noTitle)
					customBirdPosition = links.getTotalHeight() - Config.FINGER_SIZE * .1;
				posY += links.getTotalHeight() + vTextMargin * 2;
			} else {
				hideLinksMenu();
			}
			
			if (hasMenuInMsg == true) {
				_birdOverMenu = noText && noTitle;
				generateMenu(messageVO, maxWidth);
				botMenu.y = posY;					
				if (noText == true && hasImageInMsg == false)
					customBirdPosition = botMenu.getTotalHeight() - Config.FINGER_SIZE * .1;
				if (messageVO.isMenuPressed == true) {					
					if (messageVO.selectedMenuIndex != -1)
						botMenu.selectedIndex = messageVO.selectedMenuIndex;
				} else {
					botMenu.selectedIndex = -1;
				}
			} else {
				hideBotMenu();
			}
			if (messageVO.wasSmile == 2)
				megaText.render();
		}
		
		protected function getMegaTextHeightByChatMessage(messageVO:ChatMessageVO, targetWidth:int):int {
			
			var messageColor:Number = colorText;
			var additioanlRes:int = 0;
			if (messageVO.systemMessageVO != null && messageVO.systemMessageVO.title != null && messageVO.systemMessageVO.title != "")
			{
				messageColor = 0x7C8081;
				var title:String = messageVO.systemMessageVO.title;
				title = title.replace(/\t/g, " ");
				additioanlRes = megaTextTitle.setText(targetWidth, title, colorTitle, fontSizeTitle, "#" + ct.color, 1.5) + vTextMargin;
			}
			
			var txt:String = messageVO.text;
			if (txt == null) {
				txt = Lang.noText;
				if (messageVO.crypted)
					txt = Lang.cryptedMessage;
			}
			if (txt == "")
				txt = Lang.deletedMessage;
			txt = txt.replace(/\t/g, " ");
			var textSize:int = fontSize;
			if (messageVO.renderInfo != null && messageVO.renderInfo.renderInforenderBigFont == true)
			{
				textSize = textSize * 1.4;
			}
			var res:int = megaText.setText(targetWidth, txt, messageColor, textSize, "#" + ct.color, 1.5, messageVO.wasSmile);
			messageVO.wasSmile = megaText.getWasSmile() ? 2 : 1;
			
			res += additioanlRes;
			
			return res;
		}
		
		protected function getMegaTitleHeightByChatMessage(messageVO:ChatMessageVO, targetWidth:int):int {
			
			var res:int = 0;
			if (messageVO.systemMessageVO != null && messageVO.systemMessageVO.title != null && messageVO.systemMessageVO.title != "")
			{
				var title:String = messageVO.systemMessageVO.title;
				title = title.replace(/\t/g, " ");
				res = megaTextTitle.setText(targetWidth, title, colorTitle, fontSizeTitle, "#" + ct.color, 1.5) + vTextMargin;
			}
			
			return res;
		}
		
		private function generateMenu(messageVO:ChatMessageVO, maxWidth:int):void {
			var buttonsArray:Array = messageVO.systemMessageVO.botMenu.items;
			if (botMenu == null) {
				botMenu = new BotMenu();
				addChild(botMenu);
			}
			botMenu.visible = true;
			botMenu.destroyMenu();
			botMenu.viewWidth = maxWidth;
			botMenu.createMenu(buttonsArray);
		}
		
		private function generateLinks(messageVO:ChatMessageVO, maxWidth:int):void {
			var linksArray:Array = messageVO.systemMessageVO.links;
			if (links == null) {
				links = new BotLinks();
				addChild(links);
			}
			links.visible = true;
			links.destroyLinks();
			links.viewWidth = maxWidth;
			links.createLinks(linksArray);
		}
		
		private function destroyBotMenu():void {
			if (botMenu != null)
				botMenu.dispose();
			botMenu = null;
		}
		
		private function destroyBotLinks():void {
			if (links != null)
				links.dispose();
			links = null;
		}
		
		private function hideLinksMenu():void{
			if (links != null)
				links.visible = false;
		}
		
		private function hideBotMenu():void{
			if (botMenu != null)
				botMenu.visible = false;
		}
		
		private function showBotMenu():void {
			if (botMenu != null)
				botMenu.visible = true;
		}
		
		private function hasTitle(msgVO:ChatMessageVO):Boolean {
			if (msgVO == null)
				return false;
			if (msgVO.systemMessageVO == null || msgVO.systemMessageVO.title == "" || msgVO.systemMessageVO.title == null)
				return false;
			return true;
		}
		
		private function hasText(msgVO:ChatMessageVO):Boolean {
			if (msgVO == null)
				return false;
			if (msgVO.text == "" || msgVO.text == null)
				return false;
			return true;
		}
		
		private function hasImage(msgVO:ChatMessageVO):Boolean {
			if (msgVO == null ||
				msgVO.systemMessageVO == null ||
				msgVO.systemMessageVO.botMenu == null)
					return false;
			return ("image" in msgVO.systemMessageVO.botMenu);
		}
		
		private function hasMenu(msgVO:ChatMessageVO):Boolean {
			if (msgVO == null ||
				msgVO.systemMessageVO == null ||
				msgVO.systemMessageVO.botMenu == null ||
				msgVO.systemMessageVO.botMenu.items == null ||
				msgVO.systemMessageVO.botMenu.items.length == 0)
					return false;
			return true;
		}
		
		private function hasLinks(msgVO:ChatMessageVO):Boolean {
			if (msgVO == null ||
				msgVO.systemMessageVO == null ||
				msgVO.systemMessageVO.links == null ||
				!(msgVO.systemMessageVO.links is Array) ||
				(msgVO.systemMessageVO.links as Array).length == 0)
					return false;
			return true;
		}
		
		public function updateHitzones(itemHitzones:Vector.<HitZoneData>):void {
			var hz:HitZoneData;
			if (imageRenderer != null) {
				
				hz = new HitZoneData();
					hz.type = HitZoneType.BOT_MENU_IMAGE;
					hz.x = 0;
					hz.y = imagePlaceHolder.y;
					hz.width = imagePlaceHolder.width;
					hz.height = imagePlaceHolder.height;
				itemHitzones.push(hz);
			}
			
			if (currentData != null && currentData.links != null && currentData.links.length > 0)
			{
				var linksArray:Array = currentData.links;
				var destY2:int = this.y + links.y;
				var destX2:int = this.x + links.x;
				
				var buttonBounds2:Rectangle;
				for (var i2:int = 0; i2 < linksArray.length; i2++) {
					btn = linksArray[i2];
					buttonBounds2 = links.getBtnBounds(i2);
					destY2 = this.y + links.y + buttonBounds2.y;
					
					hz = new HitZoneData();
						hz.type = HitZoneType.OPEN_LINK;
						hz.text = linksArray[i2].url;
						hz.x = destX2;
						hz.y = destY2;
						hz.width = buttonBounds2.width;
						hz.height = buttonBounds2.height;
					itemHitzones.push(hz);
				}
			}
			
			if (currentData == null ||
				currentData.botMenu == null ||
				currentData.botMenu.items == null ||
				currentData.botMenu.items.length == 0 ||
				botMenu == null)
					return;
			var buttonsArray:Array = currentData.botMenu.items;
			var lineHeight:int = Config.FINGER_SIZE * .6;
			var destY:int = this.y + botMenu.y;
			var destX:int = this.x + botMenu.x;
			var destWidth:int = boxBg.width;
			var btn:Object;
			var buttonBounds:Rectangle;
			for (var i:int = 0; i < buttonsArray.length; i++) {
				btn = buttonsArray[i];
				buttonBounds = botMenu.getBtnBounds(i);
				destY = this.y + botMenu.y + buttonBounds.y;
				var displayText:String = "";
				if (btn.displayText) {
					if (btn.displayText.length > 0)
						displayText = btn.displayText;
				} else {
					displayText = btn.text;
				}
				
				hz = new HitZoneData();
					hz.type = HitZoneType.BOT_MENU_ACTION;
					hz.text = displayText;
					hz.index = i;
					hz.statAction = btn.statAction;
					hz.action = btn.action;
					hz.x = destX;
					hz.y = destY;
					hz.width = buttonBounds.width;
					hz.height = buttonBounds.height;
				itemHitzones.push(hz);
			}
		}
		
		public function getCustomContentHeight():Number { return customBirdPosition; }
		public function getBackColor():Number { return ct.color; }
		public function getWidth():uint { return width; }
		public function getContentHeight():Number { return height; }
		
		override public function get width():Number { return boxBg.width; }
		
		public function get isReadyToDisplay():Boolean { return true; }
		public function get animatedZone():AnimatedZoneVO { return null; }
		public function get birdOverMenu():Boolean { return _birdOverMenu; }
		
		private function get rect():Rectangle {
			if (_rect != null)
				_rect = new Rectangle();
			_rect.x = x + boxBg.x;
			_rect.y = y + boxBg.y;
			_rect.width = boxBg.width;
			_rect.height = boxBg.height;
			return _rect;
		}
	}
}