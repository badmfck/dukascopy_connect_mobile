package com.dukascopy.connect.gui.list.renderers.chatMessageElements 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ChatSystemMessageData;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author ...
	 */
	public class ChatSystemMessageRenderer extends Sprite
	{
		private var message:TextField;
		private var buttons:Vector.<SystemMessageButton>;
		private var currentData:ChatSystemMessageData;
		private var created:Boolean;
		private var verticalPadding:int;
		private var horizontalPadding:int;
		private var title:TextField;
		private var mainHeight:Number;
		
		public function ChatSystemMessageRenderer() 
		{
			
		}
		
		public function create():void
		{
			if (created)
			{
				return;
			}
			
			buttons = new Vector.<SystemMessageButton>();
			
			created = true;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = Config.FINGER_SIZE * .26;
			textFormat.color = MainColors.WHITE;
			textFormat.align = TextFormatAlign.CENTER;
			
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
		
		public function getHeight(data:ChatSystemMessageData, itemWidth:int):int
		{
			draw(data, itemWidth);
			
			return mainHeight + Config.FINGER_SIZE * .5;
		}
		
		public function draw(data:ChatSystemMessageData, itemWidth:int):Sprite 
		{
			if (currentData == data)
			{
				return this;
			}
			
			currentData = data;
			
			create();
			createButtons();
			
			var yDrawPosition:int = verticalPadding;
			
			title.visible = false;
			message.visible = false;
			
			if (data.title)
			{
				title.visible = true;
				
				title.width = itemWidth - horizontalPadding * 2;
				title.text = data.title;
				title.height = title.textHeight + 4;
				
				title.y = yDrawPosition;
				
				yDrawPosition += title.height + verticalPadding;
			}
			
			if (data.message)
			{
				message.visible = true;
				
				message.width = itemWidth - horizontalPadding * 2;
				message.text = data.message;
				message.height = message.textHeight + 4;
				
				message.y = yDrawPosition;
				
				yDrawPosition += message.height + verticalPadding;
			}
			
			for (var j:int = 0; j < buttons.length; j++) 
			{
				buttons[j].visible = false;
			}
			
			var buttonRows:Vector.<Vector.<SystemMessageButton>> = new Vector.<Vector.<SystemMessageButton>>();
			var rowWidth:int = 0;
			var buttonsHorizontalGap:int = horizontalPadding;
			var buttonsverticalGap:int = verticalPadding;
			
			if (data.buttons && data.buttons.length > 0)
			{
				for (var i:int = 0; i < data.buttons.length; i++) 
				{
					buttons[i].visible = true;
					buttons[i].draw(data.buttons[i], itemWidth - horizontalPadding * 2);
					
					if (i == 0)
					{
						buttonRows.push(new Vector.<SystemMessageButton>());
						buttonRows[0].push(buttons[0]);
						rowWidth += buttons[0].width;
					}
					else
					{
						if (rowWidth + buttons[i].width + buttonsHorizontalGap > itemWidth - horizontalPadding * 2)
						{
							buttonRows.push(new Vector.<SystemMessageButton>());
							buttonRows[buttonRows.length - 1].push(buttons[i]);
							rowWidth = buttons[i].width;
						}
						else
						{
							buttonRows[buttonRows.length - 1].push(buttons[i]);
							rowWidth += buttons[i] + buttonsHorizontalGap;
						}
					}
				}
				
				var yPosition:int = yDrawPosition;
				var xPosition:int;
				var rowHeight:int = 0;
				for (var k:int = 0; k < buttonRows.length; k++) 
				{
					rowWidth = 0;
					for (var l:int = 0; l < buttonRows[k].length; l++) 
					{
						rowWidth += buttonRows[k][l].width;
						rowHeight = Math.max(rowHeight, buttonRows[k][l].height);
					}
					rowWidth += (buttonRows[k].length - 1) * buttonsHorizontalGap;
					
					xPosition = itemWidth * .5 - rowWidth * .5;
					
					for (var m:int = 0; m <  buttonRows[k].length; m++) 
					{
						buttonRows[k][m].x = xPosition;
						xPosition += buttonRows[k][m].width + buttonsHorizontalGap;
						
						buttonRows[k][m].y = yPosition;
					}
					
					yPosition += rowHeight + buttonsverticalGap;
				}
			}
			
			buttonRows = null;
			
			if (data.buttons && data.buttons.length > 0)
			{
				mainHeight = buttons[buttons.length - 1].y +  buttons[buttons.length - 1].height + verticalPadding * 2;
			}
			else if(message.visible)
			{
				mainHeight = message.y + message.height + verticalPadding;
			}
			else
			{
				mainHeight = title.y + title.height + verticalPadding;
			}
			
			graphics.clear();
			graphics.beginFill(AppTheme.GREY_DARK, data.backAlpha);
			graphics.drawRoundRect(0, 0, itemWidth, mainHeight, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			graphics.endFill();
			
			return this;
		}
		
		private function createButtons():void 
		{
			if (currentData.buttons && buttons.length < currentData.buttons.length)
			{
				for (var i:int = 0; i < currentData.buttons.length - buttons.length; i++) 
				{
					var button:SystemMessageButton = new SystemMessageButton();
					addChild(button);
					buttons.push(button);
				}
			}
		}
		
		public function getHitZones():Array
		{
			var zones:Array = new Array();
			
			var buttonPoint:Point
			
			if (buttons)
			{
				for (var i:int = 0; i < currentData.buttons.length; i++) 
				{
					buttonPoint = parent.globalToLocal(localToGlobal(new Point(buttons[i].x, buttons[i].y)));
					
					buttonPoint.x = buttons[i].x + x;
					buttonPoint.y = buttons[i].y + y;
					
					var hz:HitZoneData = new HitZoneData();
					hz.type = HitZoneType.SYSTEM_MESSAGE_INDEX_ + i.toString();
					hz.param = ;
					hz.x = buttonPoint.x;
					hz.y = buttonPoint.y;
					hz.width = width:buttons[i].width;
					hz.height = height:buttons[i].height;
					
					zones.push(hz);
				}
			}
			
			return zones;
		}
		
		public function dispose():void
		{
			if (message)
			{
				UI.destroy(message);
				message = null;
			}
			
			if (title)
			{
				UI.destroy(title);
				title = null;
			}
			
			if (buttons)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].destroy();
				}
				buttons = null;
			}
			
			graphics.clear();
			currentData = null;
		}
	}
}