package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.ChatMessageCryptedIcon;
	import assets.ChatMessageUncryptedIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererReply extends ChatMessageRendererBase implements IMessageRenderer {
		
		static private var myLockColor:uint = 0xFFFFFF;
		static private var otherLockColor:uint = 0x000000;
		
		private var colorBG:uint;
		
		protected var textBox:Sprite;
		private var author:TextField;
		protected var fontSize:int;
		protected var megaText:MegaText;
		
		public function ChatMessageRendererReply() {
			super();
			
			fontSize = Math.ceil(Config.FINGER_SIZE * .30);
			if (fontSize < minFontSize)
				fontSize = minFontSize;
			
			textBox = new Sprite();
			initBg(COLOR_BG_WHITE)
			
			megaText = new MegaText();
			megaText.x = hTextMargin + Config.FINGER_SIZE * .2;
			textBox.addChild(megaText);
			
			author = new TextField();
			textBox.addChild(author);
			
			var tf:TextFormat = new TextFormat();
			tf.font = Config.defaultFontName;
			tf.size = FontSize.SUBHEAD;
			tf.color = Color.BLUE;
			author.defaultTextFormat = tf;
			author.multiline = true;
			author.wordWrap = true;
			author.x = hTextMargin + Config.FINGER_SIZE * .2;
			author.y = int(Config.FINGER_SIZE * .15);
			
			author.width = Config.FINGER_SIZE * 3;
			author.text = "Rr";
			author.height = author.textHeight + 4;
			author.text = "";
			megaText.y = int(author.y + author.height + Config.FINGER_SIZE * .03);
			
			addChild(textBox);
		}
		
		override public function dispose():void {
			super.dispose();
			megaText.dispose();
			UI.destroy(textBox);
			textBox = null;
			
			UI.destroy(author);
			author = null;
		}
		
		public function getContentHeight():Number {
			return megaText.y + megaText.height + Config.FINGER_SIZE * .1;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			itemHitzones.push( { type:HitZoneType.REPLY_MESSAGE, x:x , y:y, width: textBox.width, height: textBox.height } );
		}
		
		public function getWidth():uint {
			return width;
		}
		
		public function getHeight(messageVO:ChatMessageVO, targetWidth:int, listItem:ListItem):uint {
			if (messageVO == null)
				return 0;
			
			var maxTextWidth:int =  targetWidth;
			var res:uint = getMegaTextHeightByChatMessage(messageVO, targetWidth) + vTextMargin * 2;
			
			maxTextWidth = targetWidth - Config.FINGER_SIZE * .2 - Config.FINGER_SIZE * .2;
			author.width = maxTextWidth;
			author.text = messageVO.systemMessageVO.replayMessage.author;
			author.height = author.textHeight + 4;
			author.width = author.textWidth + 4;
			
			res += int(author.height + Config.FINGER_SIZE * .21);
			
			return res;
		}
		
		protected function getMegaTextHeightByChatMessage(messageVO:ChatMessageVO/*, isForwarded:Boolean*/,  targetWidth:int):int {
			var txt:String = messageVO.systemMessageVO.replayMessage.message;
			if (txt == null)
				txt = Lang.noText;
			if (messageVO.crypted)
				txt = Lang.cryptedMessage;
			if (txt == "")
				txt = Lang.deletedMessage;
			txt = txt.replace(/\t/g, " ");
			var textSize:int = FontSize.SUBHEAD;
			var textColor:Number = colorText;
			if (messageVO.renderInfo != null && !isNaN(messageVO.renderInfo.color))
			{
				textColor = messageVO.renderInfo.color;
			}
			
			var res:int = megaText.setText(targetWidth, txt, textColor, textSize, "#" + getBackColor().toString(16), 1.5, messageVO.wasSmile);
			
			if (megaText.getTextField().numLines > 1) {
				var newMessage:String;
				if (megaText.getTextField().getLineLength(0) - 3 > 0)
				{
					newMessage = txt.substr(0, megaText.getTextField().getLineLength(0) - 3) + "...";
				}
				else
				{
					newMessage = txt.substr(0, megaText.getTextField().getLineLength(0));
				}
				
				res = megaText.setText(
					targetWidth, 
					newMessage, 
					textColor, 
					/*0x8ca7bc, */
					textSize,
					"#" + getBackColor().toString(16),
					1.5,
					messageVO.wasSmile
				);
			}
			
			return res;
		}
		
		public function getContentWidth(messageVO:ChatMessageVO):int
		{
			/*author.text = messageVO.systemMessageVO.replayMessage.author;
			author.height = author.textHeight + 4;*/
			
			return Math.max(author.width + hTextMargin * 2 + Config.FINGER_SIZE * .2, Config.FINGER_SIZE * 3);
		}
		
		public function draw(messageVO:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			updateBubbleColors(messageVO);
			
			var maxTextWidth:int = maxWidth - Config.FINGER_SIZE * .2 - Config.FINGER_SIZE * .2;
			author.width = maxTextWidth;
			author.text = messageVO.systemMessageVO.replayMessage.author;
			author.height = author.textHeight + 4;
			author.width = author.textWidth + 4;
			
			var thickness:int;
			var isMine:Boolean = Auth.uid === messageVO.userUID;
			if (isMine)
			{
				textBox.graphics.clear();
				textBox.graphics.beginFill(Color.GREY_DARK);
				thickness = Config.FINGER_SIZE * .05;
				textBox.graphics.drawRect(int(Config.FINGER_SIZE * .2), int(vTextMargin), thickness, int(Config.FINGER_SIZE * .75));
				textBox.graphics.endFill();
				
				author.textColor = Color.GREY_DARK;
			}
			else
			{
				textBox.graphics.clear();
				textBox.graphics.beginFill(Color.BLUE);
				thickness = Config.FINGER_SIZE * .05;
				textBox.graphics.drawRect(int(Config.FINGER_SIZE * .2), int(vTextMargin), thickness, int(Config.FINGER_SIZE * .75));
				textBox.graphics.endFill();
				
				author.textColor = Color.GREEN;
			}
			
			megaText.y = int(author.y + author.height + Config.FINGER_SIZE * .03);
			
			var megaTextHeight:int = getMegaTextHeightByChatMessage(messageVO, Math.max(maxTextWidth, author.width));
			
			var bgH:int = megaTextHeight + vTextMargin + megaText.y;
			var bgW:int;
			
			boxBg.width = maxWidth;
			boxBg.height = bgH + Config.FINGER_SIZE * .9;
			
			if (messageVO.wasSmile == 2)
				megaText.render();
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.chatMessageElements.IMessageRenderer */
		
		public function getBackColor():Number {
			return ct.color;
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