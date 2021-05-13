package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ChatSystemMessageData;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ChatSystemMessageValueType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
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
	
	public class ChatMessageRendererSystemMessage extends Sprite implements IMessageRenderer {
		
		static protected var avatarSize:int = Config.FINGER_SIZE * .52;
		private var avatar:Shape;
		private var avatarWithLetter:Sprite;
		private var avatarWithLetterTF:TextField;
		
		private var message:TextField;
		private var buttons:Vector.<SystemMessageButton>;
		private var currentData:ChatSystemMessageData;
		private var created:Boolean;
		private var verticalPadding:int;
		private var horizontalPadding:int;
		private var title:TextField;
		private var mainHeight:Number;
		
		public function ChatMessageRendererSystemMessage() {
			
		}
		
		public function getContentHeight():Number {
			return height;
		}
		
		public function getWidth():uint {
			return width;
		}
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			return null;
		}
		
		public function getBackColor():Number {
			return 0xFFFFFF;
		}
		
		public function create():void {
			if (created == true)
				return;
			
			buttons = new Vector.<SystemMessageButton>();
			
			created = true;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = Config.FINGER_SIZE * .26;
			textFormat.color = MainColors.WHITE;
			textFormat.align = TextFormatAlign.LEFT;
			
			var textFormatTitle:TextFormat = new TextFormat();
			textFormatTitle.font = Config.defaultFontName;
			textFormatTitle.size = Config.FINGER_SIZE * .35;
			textFormatTitle.color = MainColors.WHITE;
			textFormatTitle.align = TextFormatAlign.CENTER;
			
			verticalPadding = Config.FINGER_SIZE * .2;
			horizontalPadding = Config.FINGER_SIZE * .3;
			
			title = new TextField();
				title.defaultTextFormat = textFormatTitle;
				title.text = "";
				title.wordWrap = true;
				title.multiline = true;
				title.mouseEnabled = false;
			addChild(title);
			
			title.x = horizontalPadding;
			
			message = new TextField();
				message.defaultTextFormat = textFormat;
				message.text = "";
				message.wordWrap = true;
				message.multiline = true;
				message.mouseEnabled = false;
			addChild(message);
			
			message.x = horizontalPadding;
			
			var button:SystemMessageButton = new SystemMessageButton();
			addChild(button);
			buttons.push(button);
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			if (buttons)
				for (var i:int = 0; i < buttons.length; i++)
					itemHitzones.push( {
						type:(HitZoneType.SYSTEM_MESSAGE_INDEX_ + i.toString()),
						x:(buttons[i].x + x),
						y:buttons[i].y + y,
						width:buttons[i].width,
						height:buttons[i].height
					} );
			if (avatar != null)
			{
				itemHitzones.push( {
					type:(HitZoneType.SYSTEM_MESSAGE_INDEX_ + "avatar"),
					x:x,
					y:avatar.y + y,
					width:width,
					height:title.y + title.height
				} );
			}
			
		}
		
		public function getHeight(itemData:ChatMessageVO, itemWidth:int, listItem:ListItem):uint {
			draw(itemData, itemWidth);
			return mainHeight;
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			var data:ChatSystemMessageData = messageData.systemMessage;
			maxWidth = Math.min(maxWidth, Config.FINGER_SIZE * 6);
			
			if (currentData == data)
				return;
			
			currentData = data;
			
			create();
			createButtons();
			
			var yDrawPosition:int = verticalPadding + Config.FINGER_SIZE * .09;
			
			if (avatar != null)
				avatar.visible = false;
			if (avatarWithLetter != null)
				avatarWithLetter.visible = false;
			if (data.type == ChatSystemMessageValueType.NOT_IN_CONTACTS) {
				createAvatar(maxWidth);
				drawAvatar(data.title);
				avatar.y = avatarWithLetter.y = yDrawPosition;
				yDrawPosition += avatarSize * 2 + verticalPadding;
			}
			
			title.visible = false;
			message.visible = false;
			
			if (data.title) {
				title.visible = true;
				title.width = maxWidth - horizontalPadding * 2;
				title.text = data.title;
				title.height = title.textHeight + 4;
				title.y = yDrawPosition;
				yDrawPosition += title.height + verticalPadding;
			}
			
			if (data.message) {
				message.visible = true;
				message.width = maxWidth - horizontalPadding * 2;
				message.text = data.message;
				message.height = message.textHeight + 4;
				message.y = yDrawPosition;
				yDrawPosition += message.height + verticalPadding;
			}
			
			for (var j:int = 0; j < buttons.length; j++) 
				buttons[j].visible = false;
			
			var buttonRows:Vector.<Vector.<SystemMessageButton>> = new Vector.<Vector.<SystemMessageButton>>();
			var rowWidth:int = 0;
			var buttonsHorizontalGap:int = horizontalPadding;
			var buttonsverticalGap:int = verticalPadding;
			
			if (data.buttons && data.buttons.length > 0) {
				for (var i:int = 0; i < buttons.length; i++)  {
					buttons[i].visible = true;
					buttons[i].draw(data.buttons[i], maxWidth - horizontalPadding * 2);
					
					if (i == 0) {
						buttonRows.push(new Vector.<SystemMessageButton>());
						buttonRows[0].push(buttons[0]);
						rowWidth += buttons[0].width;
					} else {
						if (rowWidth + buttons[i].width + buttonsHorizontalGap > maxWidth - horizontalPadding * 2) {
							buttonRows.push(new Vector.<SystemMessageButton>());
							buttonRows[buttonRows.length - 1].push(buttons[i]);
							rowWidth = buttons[i].width;
						} else {
							buttonRows[buttonRows.length - 1].push(buttons[i]);
							rowWidth += buttons[i].width + buttonsHorizontalGap;
						}
					}
				}
				
				var yPosition:int = yDrawPosition;
				var xPosition:int;
				var rowHeight:int = 0;
				for (var k:int = 0; k < buttonRows.length; k++) {
					rowWidth = 0;
					for (var l:int = 0; l < buttonRows[k].length; l++) {
						rowWidth += buttonRows[k][l].width;
						rowHeight = Math.max(rowHeight, buttonRows[k][l].height);
					}
					rowWidth += (buttonRows[k].length - 1) * buttonsHorizontalGap;
					
					xPosition = maxWidth * .5 - rowWidth * .5;
					
					for (var m:int = 0; m <  buttonRows[k].length; m++) {
						buttonRows[k][m].x = xPosition;
						xPosition += buttonRows[k][m].width + buttonsHorizontalGap;
						
						buttonRows[k][m].y = yPosition;
					}
					
					yPosition += rowHeight + buttonsverticalGap;
				}
			}
			
			buttonRows = null;
			
			if (data.buttons && data.buttons.length > 0)
				mainHeight = buttons[buttons.length - 1].y +  buttons[buttons.length - 1].height + verticalPadding;
			else if(message.visible)
				mainHeight = message.y + message.height + verticalPadding;
			else
				mainHeight = title.y + title.height + verticalPadding;
			
			graphics.clear();
			graphics.beginFill(AppTheme.GREY_DARK, data.backAlpha);
			graphics.drawRoundRect(0, 0, maxWidth, mainHeight, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			graphics.endFill();
		}
		
		private function createAvatar(w:int):void {
			if (avatar != null)
				return;
			avatar = new Shape();
				avatar.x = w * .5 - avatarSize;
			addChild(avatar);
			avatarWithLetter = new Sprite();
				avatarWithLetter.x = avatar.x;
			avatarWithLetterTF = new TextField();
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = Config.FINGER_SIZE*.5;
			textFormat.align = TextFormatAlign.CENTER;
			avatarWithLetterTF.defaultTextFormat = textFormat;
			avatarWithLetterTF.selectable = false;
			avatarWithLetterTF.width = avatarSize * 2;
			avatarWithLetterTF.multiline = false;
			avatarWithLetterTF.text = "|";
			avatarWithLetterTF.height = avatarWithLetterTF.textHeight + 4;
			avatarWithLetterTF.y = int(avatarSize - (avatarWithLetterTF.textHeight + 4) * .5);
			avatarWithLetterTF.text = "";
				avatarWithLetter.addChild(avatarWithLetterTF);
			avatarWithLetter.graphics.beginFill(AppTheme.GREY_MEDIUM);
			UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.GREY_MEDIUM);				
			avatarWithLetter.graphics.endFill();
				avatarWithLetter.visible = false;
			addChild(avatarWithLetter);
		}
		
		private function drawAvatar(val:String):void {
			if (avatar == null)
				return;
			if (ChatManager.getCurrentChat() == null)
				return;
			avatarWithLetter.visible = false;
			avatar.visible = false;
			avatar.graphics.clear();
			var avatarURL:String = ChatManager.getCurrentChat().getUserAvatar(ChatManager.getCurrentChat().ownerUID);
			var a:ImageBitmapData;
			if (avatarURL != null && avatarURL != "")
				a = ImageManager.getImageFromCache(avatarURL);
			if (a != null) {
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, a, ImageManager.SCALE_PORPORTIONAL);
				avatar.visible = true;
			} else if (val != null && val.length > 0 && AppTheme.isLetterSupported(val.charAt(0))) {
				avatarWithLetterTF.text = val.charAt(0).toUpperCase();
				UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize * 2, avatarSize, AppTheme.getColorFromPallete(val));
				avatarWithLetter.visible = true;
			}
		}
		
		private function createButtons():void {
			var l:int = buttons.length;
			if (currentData.buttons && l < currentData.buttons.length) {
				for(var i:int = 0; i < currentData.buttons.length - l; i++) {
					var button:SystemMessageButton = new SystemMessageButton();
					addChild(button);
					buttons.push(button);
				}
			}
		}
		
		public function dispose():void {
			if (message)
				UI.destroy(message);
			message = null;
			if (avatarWithLetterTF)
				avatarWithLetterTF.text = "";
			avatarWithLetterTF = null;
			if (avatarWithLetter)
				UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
			if (avatar != null)
				UI.destroy(avatar);
			avatar = null;
			if (title)
				UI.destroy(title);
			title = null;
			
			if (buttons)
				for (var i:int = 0; i < buttons.length; i++)
					buttons[i].destroy();
			buttons = null;
			
			graphics.clear();
			currentData = null;
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