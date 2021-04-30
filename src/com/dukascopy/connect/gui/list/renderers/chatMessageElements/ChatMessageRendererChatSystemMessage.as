package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererChatSystemMessage extends Sprite implements IMessageRenderer {
		
		private var message:TextField;
		private var currentData:ChatSystemMsgVO;
		private var created:Boolean;
		private var verticalPadding:int;
		private var horizontalPadding:int;
		private var mainHeight:Number;
		private var textBoxRadius:Number;
		private var textFormat:TextFormat;
		
		public function ChatMessageRendererChatSystemMessage() {
			textBoxRadius = Math.ceil(Config.FINGER_SIZE * .2);
		}
		
		public function create():void {
			if (created == true)
				return;
			created = true;
			textFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = Config.FINGER_SIZE * .22;
			textFormat.color = Style.color(Style.COLOR_BACKGROUND);
			textFormat.align = TextFormatAlign.LEFT;
			verticalPadding = Config.FINGER_SIZE * .15;
			horizontalPadding = Config.FINGER_SIZE * .2;
			message = new TextField();
			message.defaultTextFormat = textFormat;
			message.text = "";
			message.wordWrap = true;
			message.multiline = true;
			message.mouseEnabled = false;
			addChild(message);
			message.x = horizontalPadding;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			if (currentData == null)
				return;
			if (parent == null)
				return;
			if (currentData.botMenu != null) {
				var buttonsArray:Array = currentData.botMenu.items;
				var lineHeight:int = Config.FINGER_SIZE * .6;
				var destY:int = lineHeight;
				var btn:Object;
				for (var i:int = 0; i < buttonsArray.length; i++) {
					btn = buttonsArray[i];
					itemHitzones.push( { type:HitZoneType.BOT_MENU_ACTION, x:horizontalPadding, y:destY, width:width, height:lineHeight, action:btn.action, sys:btn.sys } );
					destY += lineHeight;
				}
			}
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			var data:ChatSystemMsgVO = messageData.systemMessageVO;
			if (currentData == data)
				return;
			
			maxWidth = Math.min(maxWidth, Config.FINGER_SIZE * 6);
			currentData = data;
			create();
			message.visible = false;
			var text:String;
			if (data.text != null)
				text = data.text;
			if (data.botMenu != null) {
				var botMenuTitle:String = data.botMenu.title;
				var buttonsArray:Array = data.botMenu.items;
				var lineHeight:int = verticalPadding + Config.FINGER_SIZE * .22;
				var destY:int = lineHeight;
				var btn:Object;
				for (var i:int = 0; i < buttonsArray.length; i++) {	
					btn = buttonsArray[i];
					text += "<br><br>" + btn.text;
				}
			}
			if (text != null) {
				message.visible = true;
				message.width = maxWidth - horizontalPadding * 2;
				message.htmlText = text;
				message.height = message.textHeight + 4;
				message.y = verticalPadding;
			}	
			mainHeight = message.height + verticalPadding * 2;
			graphics.clear();
			graphics.beginFill(AppTheme.GREY_DARK);
			graphics.drawRoundRect(0, 0, maxWidth, mainHeight, textBoxRadius, textBoxRadius);
			graphics.endFill();	
		}
		
		public function dispose():void {
			if (message != null)
				UI.destroy(message);
			message = null;
			graphics.clear();
			currentData = null;
		}
		
		public function get animatedZone():AnimatedZoneVO { return null; }
		public function get isReadyToDisplay():Boolean { return true; }
		
		public function getSmallGap(listItem:ListItem):int { return ChatMessageRendererBase.smallGap; }
		public function getContentHeight():Number { return height; }
		public function getBackColor():Number { return 0xFFFFFF; }
		public function getWidth():uint { return width; }
		public function getHeight(itemData:ChatMessageVO, itemWidth:int, listItem:ListItem):uint {
			draw(itemData, itemWidth);
			return mainHeight;
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.chatMessageElements.IMessageRenderer */
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData 
		{
			return null;
		}
	}
}