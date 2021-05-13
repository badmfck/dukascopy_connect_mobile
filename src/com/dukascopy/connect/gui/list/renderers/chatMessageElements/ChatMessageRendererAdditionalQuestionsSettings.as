package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.QuestionAdditionalMessagesType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ChatMessageRendererAdditionalQuestionsSettings extends ChatMessageRendererAction implements IMessageRenderer {
		
		private var buttonBitmap:Bitmap;
		private var questionBitmap:Bitmap;
		private var bodyText:String;
		
		private var currentMessage:ChatMessageVO;
		
		public function ChatMessageRendererAdditionalQuestionsSettings() {
			super();
		}
		
		override protected function createTextFormat():void {
			super.createTextFormat();
			textFormat.underline = false;
		}
		
		override protected function create():void {
			super.create();
			
			tf.x = vTextMargin;
			tf.text = "|";
			
			buttonBitmap = new Bitmap();
			buttonBitmap.x = vTextMargin;
			addChild(buttonBitmap);
			
			tf.text = "";
			
			tipsText.multiline = true;
			tipsText.wordWrap = true;
			tipsText.defaultTextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE * .2, textColor, false);
			
			var questionIconSize:int = Config.FINGER_SIZE * .35;
			questionBitmap = new Bitmap();
			questionBitmap.bitmapData = UI.renderAsset(new SWFQuestionIconBlue(), questionIconSize, questionIconSize);
			addChild(questionBitmap);
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			var zone:Rectangle = questionBitmap.getBounds(this);
			
			var result:HitZoneData = new HitZoneData();
			
			if (zone.contains(itemTouchPoint.x - x, itemTouchPoint.y - y))
			{
				result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
				result.x = x + questionBitmap.x - Config.MARGIN * 2;
				result.y = y + questionBitmap.y - Config.MARGIN * 2;
				result.width = questionBitmap.width + Config.MARGIN * 4;
				result.height = result.width;
				result.radius = result.width;
				return result;
			}
			else
			{
				
				var roundedTop:Boolean = true;
				var roundedBottom:Boolean = true;
				var cmVO:ChatMessageVO;
				if (listItem != null) {
					if (listItem.num != 0) {
						cmVO = listItem.list.data[listItem.num - 1];
						tf.y = vTextMargin;
						if (cmVO.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION) {
							tf.y = 0;
							roundedTop = false;
						}
					}
					if (listItem.list.data.length > listItem.num + 1) {
						cmVO = listItem.list.data[listItem.num + 1];
						if (cmVO != null && cmVO.crypted == true)
							cmVO.decrypt(null);
						if (cmVO.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION)
							roundedBottom = false;
					}
				}
				
				if (roundedTop && roundedBottom)
				{
					result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
				}
				else if (roundedTop)
				{
					result.type = HitZoneType.MENU_FIRST_ELEMENT;
				}
				else if (roundedBottom)
				{
					result.type = HitZoneType.MENU_LAST_ELEMENT;
				}
				else{
					result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
				}
				
				result.x = x;
				result.y = y;
				result.width = getWidth();
				result.height = getContentHeight();
				result.radius = textBoxRadius;
				return result;
			}
		}
		
		private function getBodyText(itemData:ChatMessageVO):String {
			var res:String = "";
			switch(itemData.systemMessageVO.method) {
				case ChatSystemMsgVO.METHOD_LOCAL_EXTRA_TIPS:
					var currency:String = QuestionsManager.getTipsCurrency();
					if (Lang[currency] != null)
					{
						currency = Lang[currency];
					}
					res = (isNaN(QuestionsManager.getTipsAmount()) == true) ? Lang.extraTipsBody : QuestionsManager.getTipsAmount() + " " + currency + " ";
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_SECRET:
					res = (QuestionsManager.getQuestionSecretMode() == true) ? Lang.textOn : Lang.textOff;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_LANGUAGES:
					res = QuestionsManager.getQuestionLanguagesString();
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_TYPE:
					res = QuestionsManager.getQuestionTypeLabel();
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_GEO:
					res = (QuestionsManager.getQuestionGeoMode() != null) ? QuestionsManager.getQuestionGeoMode().cityName : Lang.textOff;
					break;
				default:
					break;
			}
			if (res == "")
				res = "<i>" + Lang.pressToChange + "</i> ";
			return res;
		}
		
		private function getMessageText(itemData:ChatMessageVO):String {
			var res:String = "";
			switch(itemData.systemMessageVO.method) {
				case ChatSystemMsgVO.METHOD_LOCAL_EXTRA_TIPS:
					res = Lang.extraTipsTitle;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_GEO:
					res = Lang.geoTitle;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_SECRET:
					res = Lang.secretTitle;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_LANGUAGES:
					res = QuestionsManager.getQuestionLanguagesString();
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_TYPE:
					res = Lang.questionType;
					break;
				default:
					break;
			}
			return res + ":";
		}
		
		override public function getHeight(itemData:ChatMessageVO, maxWidth:int, listItem:ListItem):uint {
			draw(itemData, maxWidth, listItem);
			return boxBg.y + boxBg.height;
			//return height;
		}
		
		override public function draw(messageData:ChatMessageVO, maxWidth:int, listItem:ListItem = null, securityKey:Array = null, minWidth:int = -1):void {
			currentMessage = messageData;
			
			tipsText.visible = false;
			
			tf.width = maxWidth - vTextMargin * 2;
			tf.text = getMessageText(messageData);
			tf.width = tf.textWidth + 5;//TODO magic numbers
			tf.height = tf.textHeight + 4;
			
			var roundedTop:Boolean = true;
			var roundedBottom:Boolean = true;
			var cmVO:ChatMessageVO;
			if (listItem != null) {
				if (listItem.num != 0) {
					cmVO = listItem.list.data[listItem.num - 1];
					tf.y = vTextMargin;
					if (cmVO.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION) {
						tf.y = 0;
						roundedTop = false;
					}
				}
				if (listItem.list.data.length > listItem.num + 1) {
					cmVO = listItem.list.data[listItem.num + 1];
					if (cmVO != null && cmVO.crypted == true)
						cmVO.decrypt(null);
					if (cmVO.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION)
						roundedBottom = false;
				}
			}
			
			questionBitmap.y = tf.y;
			
			prepareButtonBitmapAndReturnHeight(maxWidth, getBodyText(messageData));
			
			questionBitmap.x = buttonBitmap.x + buttonBitmap.width - questionBitmap.width;
			
			if (messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_LOCAL_TYPE) {
				tipsText.visible = true;
				tipsText.x = tf.x;
				tipsText.y = tf.y + tf.height;
				tipsText.width = questionBitmap.x - tipsText.x - Config.MARGIN;
				tipsText.htmlText = Lang.textAdditionalTypeInfoDesc;
				tipsText.height = tipsText.textHeight + 5;
			}
			
			if (tipsText.visible == true)
				buttonBitmap.y = tipsText.y + tipsText.height + Config.MARGIN;
			else
				buttonBitmap.y = tf.y + tf.height + Config.MARGIN;
			
			initBg(bgColor, roundedTop, roundedBottom);
			boxBg.width = maxWidth;
			boxBg.height = buttonBitmap.y + buttonBitmap.height + vTextMargin;
		}
		
		private function prepareButtonBitmapAndReturnHeight(maxWidth:int, text:String):int {
			if (buttonBitmap != null) {
				if (buttonBitmap.width == int(maxWidth - hTextMargin * 2) && bodyText == text)
					return buttonBitmap.height;
			}
			bodyText = text;
			UI.disposeBMD(buttonBitmap.bitmapData);
			buttonBitmap.bitmapData = UI.renderTextPlane("<i>" + bodyText + "</i> " ,
				int(maxWidth - hTextMargin * 2),
				Config.FINGER_SIZE,
				true, 
				TextFormatAlign.LEFT, 
				TextFieldAutoSize.LEFT, 
				fontSize, 
				true, 
				COLOR_TEXT_INFO,
				0xFFFFFF,				
				0xf2e407,
				textBoxRadius,
				1,
				Config.FINGER_SIZE*.1,
				10,
				null,
				false,
				true
			);
			return buttonBitmap.height;
		}
		
		override public function updateHitzones(itemHitzones:Array):void {
			itemHitzones.push( { type:HitZoneType.BALLOON, x:x , y:y, width: boxBg.width, height: boxBg.height } );
			var hitZoneType:String;
			switch (currentMessage.systemMessageVO.method) {
				case ChatSystemMsgVO.METHOD_LOCAL_EXTRA_TIPS:
					hitZoneType = HitZoneType.TIPS_INFO;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_GEO:
					hitZoneType = HitZoneType.GEO_INFO;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_SECRET:
					hitZoneType = HitZoneType.SECRET_INFO;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_LANGUAGES:
					hitZoneType = HitZoneType.LANGS_INFO;
					break;
				case ChatSystemMsgVO.METHOD_LOCAL_TYPE:
					hitZoneType = HitZoneType.TYPE_INFO;
					break;
			}
			if (hitZoneType != null)
				itemHitzones.unshift( { type:hitZoneType, x:(x + questionBitmap.x), y:(y + questionBitmap.y), width:questionBitmap.width, height:questionBitmap.height } );
		}
		
		override public function dispose():void {
			super.dispose();
			UI.destroy(buttonBitmap);
			buttonBitmap = null;
			UI.destroy(questionBitmap);
			questionBitmap = null;
		}
		
		override public function getSmallGap(listItem:ListItem):int {
			if (listItem != null) {
				if (listItem.num != 0) {
					var cmVO:ChatMessageVO;
					if (listItem.num - 1 >= 0)
						cmVO = listItem.list.data[listItem.num - 1];
					if (cmVO != null && cmVO.crypted == true)
						cmVO.decrypt(null);
					if (cmVO == null || cmVO.typeEnum != ChatSystemMsgVO.TYPE_LOCAL_QUESTION)
						return super.getSmallGap(listItem);
				}
			}
			return 0;
		}
	}
}