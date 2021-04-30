package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.MoneyIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.chat.CallMessageVO;
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
	import white.Phone;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererCall extends Sprite implements IMessageRenderer {
		
		private var back:Shape;
		private var title:TextField;
		private var textFormat:TextFormat = new TextFormat();
		private var radiusBack:Number;
		private var currentBackColor:Number = 0x525F72;
		private var icon:Phone;
		private var padding:int;
		
		public function ChatMessageRendererCall() {
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
			textFormat.font = Config.defaultFontName;
			textFormat.size = FontSize.SUBHEAD;
			textFormat.color = Style.color(Style.COLOR_BACKGROUND);
			textFormat.color = 0xFFFFFF;
			textFormat.align = TextFormatAlign.LEFT;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			
		}
		
		public function getBackColor():Number {
			return currentBackColor;
		}
		
		private function create():void {
			back = new Shape();
			addChild(back);
			
			radiusBack = Math.ceil(Config.FINGER_SIZE * .86);
			
			padding = Config.MARGIN * 1.3;
			
			title = new TextField();
				title.defaultTextFormat = textFormat;
				title.text = "1:00";
				title.height = title.textHeight + 4;
				title.width = title.textWidth + 4 + padding;
				title.text = "";
				title.wordWrap = true;
				title.multiline = true;
			addChild(title);
			
			icon = new Phone();
			addChild(icon);
			
			UI.scaleToFit(icon, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			UI.colorize(icon, Style.color(Style.COLOR_BACKGROUND));
			
			icon.y = int(Config.FINGER_SIZE * .86 * .5 - icon.height * .5);
			
			title.x = int(Config.FINGER_SIZE * 0.1 + Config.FINGER_SIZE * .66 + Config.FINGER_SIZE * .2);
		}
		
		public function getHeight(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint
		{
			if (messageData != null && 
				messageData.systemMessageVO != null && 
				messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_CALL && 
				messageData.systemMessageVO.callVO != null)
			{
				return Config.FINGER_SIZE * .86;
			}
			else {
			 	return Config.FINGER_SIZE * .86;
			}
		}
		
		private function setTexts(data:CallMessageVO, maxWidth:int, sender:String):void 
		{
			title.text = "";
			title.width =  maxWidth;
			title.text = data.getText();
			
			title.width = Math.min(title.textWidth + 8, maxWidth);
			
			title.height = title.textHeight + 4;
			title.y = int(Config.FINGER_SIZE * .86 * .5 - title.height * .5);
			icon.x = int(title.x + title.width + Config.FINGER_SIZE * .2);
		}
		
		public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void
		{
			if (messageData != null && 
				messageData.systemMessageVO != null && 
				(messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_CALL_VIDID || messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_CALL) && 
				messageData.systemMessageVO.callVO != null)
			{
				var targetWidth:int = maxWidth - Config.FINGER_SIZE * .1 - Config.FINGER_SIZE * .2 - Config.FINGER_SIZE * .1;
				
				if (messageData.systemMessageVO.callVO.vidid == true)
				{
					icon.visible = false;
				}
				else
				{
					targetWidth -= Config.FINGER_SIZE * .66 + icon.width + Config.FINGER_SIZE * .2;
					icon.visible = true;
				}
				
				setTexts(messageData.systemMessageVO.callVO, targetWidth, messageData.userUID);
				
				back.graphics.clear();
				back.graphics.beginFill(messageData.systemMessageVO.callVO.getColor(currentBackColor));
				
				if (messageData.systemMessageVO.callVO.vidid == true)
				{
					maxWidth = title.x + title.width + Config.FINGER_SIZE * .3;
				}
				else
				{
					maxWidth = Math.max(icon.x + icon.width + Config.FINGER_SIZE * .2);
				}
				back.graphics.drawRoundRect(0, 0, maxWidth, Config.FINGER_SIZE * .86, radiusBack, radiusBack);
				back.graphics.endFill();
			}
		}
		
		public function dispose():void {		
			UI.destroy(back);
			back = null;
			
			UI.destroy(title);
			title = null;
			
			UI.destroy(icon);
			icon = null;
			
			textFormat = null;
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