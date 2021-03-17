package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.Confeti;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import fl.motion.Color;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererTipsWinner extends Sprite implements IMessageRenderer {
		
		private var back:Shape;
		private var title:TextField;
		private var message:TextField;
		private var textFormatTitle:TextFormat = new TextFormat();
		private var textFormatMessage:TextFormat = new TextFormat();
		private var textFormatButton:TextFormat = new TextFormat();
		private var radiusBack:Number;
		private var currentBackColor:Number = 0x3B4452;
		private var giftMask:Sprite;
		private var giftContainer:Sprite;
		private var button:Sprite;
		private var buttonText:TextField;
		private var comment:TextField;
		private var confeti:Confeti;
		
		public function ChatMessageRendererTipsWinner() {
			initTextFormats();
			create();
		}
		
		public function getContentHeight():Number {
			return back.y + back.height;
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
			textFormatTitle.size = Config.FINGER_SIZE * .54;
			textFormatTitle.color = 0xFFFFFF;
			textFormatTitle.align = TextFormatAlign.CENTER;
			
			textFormatMessage.font = Config.defaultFontName;
			textFormatMessage.size = Config.FINGER_SIZE * .28;
			textFormatMessage.color = 0xFFFFFF;
			textFormatMessage.align = TextFormatAlign.CENTER;
			
			textFormatButton.font = Config.defaultFontName;
			textFormatButton.size = Config.FINGER_SIZE * .28;
			textFormatButton.color = 0;
			textFormatButton.align = TextFormatAlign.CENTER;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			if (parent) {
				var buttonPoint:Point = new Point(button.x, button.y)
				
				buttonPoint.x = buttonPoint.x + x;
				buttonPoint.y = buttonPoint.y + y;
				
				itemHitzones.push( {
					type:HitZoneType.SHOW_REACTIONS, 
					x:buttonPoint.x,
					y:buttonPoint.y, 
					width:(button.width),
					height:(button.height)
				} );
			}
		}
		
		public function getBackColor():Number {
			return currentBackColor;
		}
		
		private function create():void {
			back = new Shape();
			addChild(back);
			back.y = Config.FINGER_SIZE * .66;
			
			radiusBack = Math.ceil(Config.FINGER_SIZE * .1);
			
			giftContainer = new Sprite();
			addChild(giftContainer);
			
			confeti = new Confeti();
			giftContainer.addChild(confeti);
			confeti.alpha = 0.2;
			giftContainer.y = back.y;
			
			giftMask = new Sprite();
			addChild(giftMask);
			giftMask.y = back.y;
			
			message = new TextField();
			message.alpha = 0.75;
				message.defaultTextFormat = textFormatMessage;
				message.wordWrap = true;
				message.multiline = true;
			addChild(message);
			
			title = new TextField();
				title.defaultTextFormat = textFormatTitle;
				title.text = "1:00";
				title.height = title.textHeight + 4;
				title.width = title.textWidth + 4 + Config.MARGIN;
				title.text = "";
				title.wordWrap = false;
				title.multiline = false;
			addChild(title);
			
			title.x = int(Config.MARGIN);
			title.y = int(back.y + Config.FINGER_SIZE*.33 + Config.FINGER_SIZE * .33);
			
			message.x = int(Config.MARGIN);
			message.y = title.y + title.height + Config.FINGER_SIZE * .13;
			
			button = new Sprite();
			addChild(button);
			
			buttonText = new TextField();
				buttonText.defaultTextFormat = textFormatButton;
				buttonText.text = "1:00";
				buttonText.height = buttonText.textHeight + 4;
				buttonText.width = buttonText.textWidth + 4 + Config.MARGIN;
				buttonText.text = "";
				buttonText.wordWrap = false;
				buttonText.multiline = false;
			addChild(buttonText);
		}
		
		public function getHeight(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint
		{
			var data:GiftData = messageData.systemMessageVO.giftVO;
			
			setTexts(data, maxWidth, messageData.userUID == Auth.uid);
			
			return back.y + back.height;
		}
		
		private function setTexts(data:GiftData, maxWidth:int, isMineMessage:Boolean = false):void 
		{
			var str:String;
			
			var colors:Array = Gifts.getColors(data.type);
			
			var currency:String = "€";
			if ((data.type == GiftType.GIFT_X || data.type == GiftType.FIXED_TIPS) && data.currency != TypeCurrency.EUR && data.currency != null && data.currency != "")
			{
				currency = data.currency + " ";
			}
			
			var userName:String = "";
			
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.QUESTION) {
				if (isMineMessage == true) {
					str = Lang.youSentExtraTips;
				}
				else {
					str = Lang.youEeceivedExtraTips;
				}
				button.visible = false;
			}
			else {
				//public question
				button.visible = true;
				str = Lang.publicQuestionWinnerText;
				if (data.user != null && data.user.getDisplayName() != null)
				{
					userName = data.user.getDisplayName();
					
					str = LangManager.replace(Lang.regExtValue, str, userName);
				}
				else
				{
					str = LangManager.replace(Lang.regExtValue, str, "");
				}
				
				buttonText.text = Lang.showResults;
				buttonText.width = buttonText.textWidth + 4;
				
				str = LangManager.replace(Lang.regExtValue, str, data.getValue().toString() + " " + currency);
			}
			
			title.text = currency + data.getValue().toString();
			
			message.text = str;
			
			title.width = maxWidth - Config.MARGIN* 2;
			
			message.width = maxWidth - Config.MARGIN * 2;
			message.height = message.textHeight + 4;
			
			if (colors != null)
			{
				currentBackColor = colors[1];
				if (button.visible == true) {
					buttonText.textColor = colors[1];
				}
			}
			
			var verticalPadding:int = Config.FINGER_SIZE * .06;
			if (button.visible == true) {
				var buttonHeight:int = buttonText.height + verticalPadding * 2;
				button.graphics.clear();
				button.graphics.beginFill(0xFFFFFF, 1);
				button.graphics.drawRoundRect(0, 0, buttonText.width + Config.FINGER_SIZE, buttonHeight, buttonHeight, buttonHeight);
				button.graphics.endFill();
				button.x = int(maxWidth * .5 - button.width * .5);
				
				var buttonPosition:int;
				buttonPosition = int(message.y + message.height + Config.FINGER_SIZE * .25);
				
				button.y = buttonPosition;
				
				buttonText.x = int(button.x + button.width * .5 - buttonText.width * .5);
				buttonText.y = int(button.y + button.height * .5 - buttonText.height * .5);
			}
			
			var itemHeight:int = button.y + button.height + Config.FINGER_SIZE * .37 - Config.FINGER_SIZE * .66;
			if (button.visible == true) {
				itemHeight = button.y + button.height + Config.FINGER_SIZE * .37 - Config.FINGER_SIZE * .66;
			}
			else {
				itemHeight = message.y + message.height - Config.FINGER_SIZE * .3;
			}
			
			back.graphics.clear();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(maxWidth, itemHeight, Math.PI / 2);
			back.graphics.beginGradientFill(GradientType.LINEAR, colors, [1, 1], [0x00, 0xFF], matrix);
			back.graphics.drawRoundRect(0, 0, maxWidth, itemHeight, radiusBack * 2, radiusBack * 2);
			back.graphics.endFill();
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null):void
		{
			var data:GiftData = messageData.systemMessageVO.giftVO;
			giftContainer.removeChildren();
			giftContainer.addChild(confeti);
			setTexts(data, maxWidth, messageData.userUID == Auth.uid);
			
			var giftClip:Sprite = Gifts.getGiftImage(data.type);
			if (giftClip != null)
			{
				UI.scaleToFit(giftClip, Config.FINGER_SIZE * 3.5, Config.FINGER_SIZE * 3.5);
				var color:Color = new Color();
				var colors:Array = Gifts.getColors(data.type);
				if (colors != null)
				{
					color.setTint(colors[1], 0.4);
					giftClip.transform.colorTransform = color;
				}
			//	giftClip.rotation = -80 * Math.PI / 180;
				
				giftMask.graphics.clear();
				giftMask.graphics.beginFill(0);
				giftMask.graphics.drawRoundRect(0, 0, back.width, back.height, radiusBack * 2, radiusBack * 2);
				giftMask.graphics.endFill();
				
				giftContainer.addChild(giftClip);
				giftContainer.mask = giftMask;
				giftClip.y = back.y + back.height - giftClip.height * .8;
				giftClip.x = back.width - giftClip.width * .7;
			}
			
			UI.scaleToFit(confeti, maxWidth, maxWidth);
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
			
			UI.destroy(giftMask);
			giftMask = null;
			
			UI.destroy(giftContainer);
			giftContainer = null;
			
			UI.destroy(button);
			button = null;
			
			UI.destroy(buttonText);
			buttonText = null;
			
			UI.destroy(confeti);
			confeti = null;
			
			textFormatTitle = null;
			textFormatMessage = null;
			textFormatButton = null;
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